// lib/services/sms_reminder_service.dart
// SMS Reminder sistemi ana servisi

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task_reminder.dart';
import '../models/user_preferences.dart';
import '../models/weekly_report.dart';
import 'sms_template_service.dart';

/// SMS Reminder servisi sonucu
class SmsReminderResult {
  final bool isSuccess;
  final String message;
  final String? taskId;
  final ReminderType? reminderType;

  const SmsReminderResult({
    required this.isSuccess,
    required this.message,
    this.taskId,
    this.reminderType,
  });

  factory SmsReminderResult.success(String message, {String? taskId, ReminderType? type}) {
    return SmsReminderResult(
      isSuccess: true,
      message: message,
      taskId: taskId,
      reminderType: type,
    );
  }

  factory SmsReminderResult.failure(String message) {
    return SmsReminderResult(
      isSuccess: false,
      message: message,
    );
  }
}



/// SMS Reminder servisi
class SmsReminderService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Günlük hatırlatma gönder
  static Future<SmsReminderResult> sendDailyReminder({
    required String userId,
    String? phoneNumber,
  }) async {
    try {
      // Kullanıcı tercihlerini al
      final preferences = await getUserPreferences(userId);
      if (!preferences.smsNotificationsEnabled || !preferences.dailyRemindersEnabled) {
        return SmsReminderResult.failure('Kullanıcı SMS bildirimlerini kapatmış');
      }

      // Kullanıcının telefon numarasını al
      phoneNumber ??= await getUserPhoneNumber(userId);
      if (phoneNumber == null) {
        return SmsReminderResult.failure('Kullanıcı telefon numarası bulunamadı');
      }

      // Bugünün görevlerini al
      final todayTasks = await getTodayTasks(userId);
      final incompleteTasks = todayTasks.where((task) => !task.isCompleted).toList();

      if (incompleteTasks.isEmpty) {
        // Tüm görevler tamamlanmış, teşvik mesajı gönder
        return await _sendEncouragementMessage(phoneNumber, userId);
      }

      // En önemli görevi bul (en yakın zamanlı)
      final nextTask = incompleteTasks.reduce((a, b) => 
        a.scheduledTime.isBefore(b.scheduledTime) ? a : b);

      // SMS gönder
      final message = SmsTemplateService.generateDailyReminderMessage(nextTask, preferences.language);
      final success = await _sendSms(phoneNumber, message);

      if (success) {
        // Hatırlatma logunu kaydet
        await _logReminder(
          userId: userId,
          phoneNumber: phoneNumber,
          taskId: nextTask.id,
          reminderType: ReminderType.daily,
          message: message,
        );

        return SmsReminderResult.success(
          'Günlük hatırlatma gönderildi: ${nextTask.title}',
          taskId: nextTask.id,
          type: ReminderType.daily,
        );
      } else {
        return SmsReminderResult.failure('SMS gönderilemedi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Günlük hatırlatma hatası: $e');
      }
      return SmsReminderResult.failure('Hatırlatma gönderilemedi: $e');
    }
  }

  /// ✅ Kaçırılan görev hatırlatması
  static Future<SmsReminderResult> sendMissedTaskReminder({
    required String userId,
    String? phoneNumber,
  }) async {
    try {
      final preferences = await getUserPreferences(userId);
      if (!preferences.smsNotificationsEnabled || !preferences.missedTaskReminders) {
        return SmsReminderResult.failure('Kullanıcı kaçırılan görev hatırlatmalarını kapatmış');
      }

      phoneNumber ??= await getUserPhoneNumber(userId);
      if (phoneNumber == null) {
        return SmsReminderResult.failure('Kullanıcı telefon numarası bulunamadı');
      }

      // Son 24 saatte kaçırılan görevleri al
      final missedTasks = await getMissedTasks(userId, lastHours: 24);
      
      if (missedTasks.isEmpty) {
        return SmsReminderResult.failure('Kaçırılan görev bulunamadı');
      }

      final message = SmsTemplateService.generateMissedTaskReminder(missedTasks, preferences.language);
      final success = await _sendSms(phoneNumber, message);

      if (success) {
        await _logReminder(
          userId: userId,
          phoneNumber: phoneNumber,
          taskId: missedTasks.first.id,
          reminderType: ReminderType.missed,
          message: message,
        );

        return SmsReminderResult.success(
          'Kaçırılan görev hatırlatması gönderildi',
          taskId: missedTasks.first.id,
          type: ReminderType.missed,
        );
      } else {
        return SmsReminderResult.failure('SMS gönderilemedi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Kaçırılan görev hatırlatması hatası: $e');
      }
      return SmsReminderResult.failure('Hatırlatma gönderilemedi: $e');
    }
  }

  /// ✅ Seri (streak) hatırlatması
  static Future<SmsReminderResult> sendStreakReminder({
    required String userId,
    String? phoneNumber,
  }) async {
    try {
      final preferences = await getUserPreferences(userId);
      if (!preferences.smsNotificationsEnabled || !preferences.streakRemindersEnabled) {
        return SmsReminderResult.failure('Kullanıcı seri hatırlatmalarını kapatmış');
      }

      phoneNumber ??= await getUserPhoneNumber(userId);
      if (phoneNumber == null) {
        return SmsReminderResult.failure('Kullanıcı telefon numarası bulunamadı');
      }

      final currentStreak = await getCurrentStreak(userId);
      final message = SmsTemplateService.generateStreakReminder(currentStreak, preferences.language);
      final success = await _sendSms(phoneNumber, message);

      if (success) {
        await _logReminder(
          userId: userId,
          phoneNumber: phoneNumber,
          reminderType: ReminderType.streak,
          message: message,
        );

        return SmsReminderResult.success(
          'Seri hatırlatması gönderildi (Streak: $currentStreak)',
          type: ReminderType.streak,
        );
      } else {
        return SmsReminderResult.failure('SMS gönderilemedi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Seri hatırlatması hatası: $e');
      }
      return SmsReminderResult.failure('Hatırlatma gönderilemedi: $e');
    }
  }

  /// ✅ Haftalık rapor gönder
  static Future<SmsReminderResult> sendWeeklyReport({
    required String userId,
    String? phoneNumber,
  }) async {
    try {
      final preferences = await getUserPreferences(userId);
      if (!preferences.smsNotificationsEnabled || !preferences.weeklyReportsEnabled) {
        return SmsReminderResult.failure('Kullanıcı haftalık raporları kapatmış');
      }

      phoneNumber ??= await getUserPhoneNumber(userId);
      if (phoneNumber == null) {
        return SmsReminderResult.failure('Kullanıcı telefon numarası bulunamadı');
      }

      final report = await generateWeeklyReport(userId);
      final message = SmsTemplateService.generateWeeklyReportMessage(report, preferences.language);
      final success = await _sendSms(phoneNumber, message);

      if (success) {
        await _logReminder(
          userId: userId,
          phoneNumber: phoneNumber,
          reminderType: ReminderType.weeklyReport,
          message: message,
        );

        return SmsReminderResult.success(
          'Haftalık rapor gönderildi',
          type: ReminderType.weeklyReport,
        );
      } else {
        return SmsReminderResult.failure('SMS gönderilemedi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haftalık rapor hatası: $e');
      }
      return SmsReminderResult.failure('Rapor gönderilemedi: $e');
    }
  }

  /// ✅ Görev tamamlandı olarak işaretle
  static Future<bool> markTaskAsCompleted({
    required String taskId,
    required String userId,
  }) async {
    try {
      final taskRef = _firestore.collection('task_reminders').doc(taskId);
      final updateData = {
        'status': TaskStatus.completed.name,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
        'streakCount': FieldValue.increment(1),
      };

      await taskRef.update(updateData);

      // Seri güncelle
      await _updateUserStreak(userId);

      if (kDebugMode) {
        debugPrint('Görev tamamlandı: $taskId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Görev tamamlama hatası: $e');
      }
      return false;
    }
  }

  /// ✅ Görev ertele (snooze)
  static Future<bool> snoozeTask({
    required String taskId,
    required String userId,
    Duration? snoozeDuration,
  }) async {
    try {
      final preferences = await getUserPreferences(userId);
      final duration = snoozeDuration ?? Duration(minutes: preferences.snoozeDuration);
      final snoozedUntil = DateTime.now().add(duration);

      await _firestore.collection('task_reminders').doc(taskId).update({
        'status': TaskStatus.snoozed.name,
        'snoozedUntil': snoozedUntil.millisecondsSinceEpoch,
      });

      if (kDebugMode) {
        debugPrint('Görev ertelendi: $taskId until $snoozedUntil');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Görev erteleme hatası: $e');
      }
      return false;
    }
  }

  // === YARDIMCI METODLAR ===

  /// Kullanıcı tercihlerini al
  static Future<UserPreferences> getUserPreferences(String userId) async {
    try {
      final doc = await _firestore.collection('user_preferences').doc(userId).get();
      if (doc.exists) {
        return UserPreferences.fromMap(doc.data()!);
      } else {
        // Varsayılan tercihler oluştur
        return await _createDefaultPreferences(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Tercihler alma hatası: $e');
      }
      // Varsayılan tercihler döndür
      return UserPreferences(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Kullanıcı telefon numarasını al
  static Future<String?> getUserPhoneNumber(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['phoneNumber'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Telefon numarası alma hatası: $e');
      }
      return null;
    }
  }

  /// Bugünün görevlerini al
  static Future<List<TaskReminder>> getTodayTasks(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('task_reminders')
          .where('userId', isEqualTo: userId)
          .where('scheduledTime', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('scheduledTime', isLessThan: endOfDay.millisecondsSinceEpoch)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskReminder.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Bugünün görevlerini alma hatası: $e');
      }
      return [];
    }
  }

  /// Kaçırılan görevleri al
  static Future<List<TaskReminder>> getMissedTasks(String userId, {int lastHours = 24}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(hours: lastHours));
      
      final querySnapshot = await _firestore
          .collection('task_reminders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: TaskStatus.missed.name)
          .where('scheduledTime', isGreaterThan: cutoffTime.millisecondsSinceEpoch)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskReminder.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Kaçırılan görevleri alma hatası: $e');
      }
      return [];
    }
  }

  /// Mevcut seriyi al
  static Future<int> getCurrentStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('user_stats').doc(userId).get();
      return userDoc.data()?['currentStreak'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Seri alma hatası: $e');
      }
      return 0;
    }
  }

  /// Haftalık rapor oluştur
  static Future<WeeklyReport> generateWeeklyReport(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Pazartesi
      final weekEnd = weekStart.add(const Duration(days: 7));

      final querySnapshot = await _firestore
          .collection('task_reminders')
          .where('userId', isEqualTo: userId)
          .where('scheduledTime', isGreaterThanOrEqualTo: weekStart.millisecondsSinceEpoch)
          .where('scheduledTime', isLessThan: weekEnd.millisecondsSinceEpoch)
          .get();

      final tasks = querySnapshot.docs.map((doc) => TaskReminder.fromMap(doc.data())).toList();
      
      final completedTasks = tasks.where((task) => task.isCompleted).length;
      final missedTasks = tasks.where((task) => task.isMissed).length;
      final totalTasks = tasks.length;
      
      final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
      
      final completedCategories = tasks
          .where((task) => task.isCompleted)
          .map((task) => task.category)
          .toSet()
          .toList();

      final currentStreak = await getCurrentStreak(userId);
      final longestStreak = await getLongestStreak(userId);

      return WeeklyReport(
        userId: userId,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        missedTasks: missedTasks,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        completionRate: completionRate,
        completedCategories: completedCategories,
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haftalık rapor oluşturma hatası: $e');
      }
      // Boş rapor döndür
      return WeeklyReport(
        userId: userId,
        totalTasks: 0,
        completedTasks: 0,
        missedTasks: 0,
        currentStreak: 0,
        longestStreak: 0,
        completionRate: 0.0,
        completedCategories: [],
        weekStartDate: DateTime.now(),
        weekEndDate: DateTime.now(),
      );
    }
  }

  /// En uzun seriyi al
  static Future<int> getLongestStreak(String userId) async {
    try {
      final userDoc = await _firestore.collection('user_stats').doc(userId).get();
      return userDoc.data()?['longestStreak'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('En uzun seri alma hatası: $e');
      }
      return 0;
    }
  }

  /// SMS gönder (Twilio kullanarak)
  static Future<bool> _sendSms(String phoneNumber, String message) async {
    try {
      // Debug modda simülasyon
      if (kDebugMode) {
        debugPrint('📱 SMS Gönderildi: $phoneNumber');
        debugPrint('💬 Mesaj: $message');
        return true;
      }

      // Production'da Twilio ile gönder
      return await _sendViaTwilio(phoneNumber, message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SMS gönderme hatası: $e');
      }
      return false;
    }
  }

  /// Twilio ile SMS gönder
  static Future<bool> _sendViaTwilio(String phoneNumber, String message) async {
    try {
      // SmsProviderConfig'i import et
      final accountSid = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // Placeholder - gerçek config'ten alınmalı
      final authToken = 'your_auth_token_here'; // Placeholder
      final fromNumber = '+1234567890'; // Placeholder

      final url = Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

      final auth = base64Encode(utf8.encode('$accountSid:$authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': fromNumber,
          'To': phoneNumber,
          'Body': message,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('✅ Twilio SMS sent successfully to $phoneNumber');
        }
        return true;
      } else {
        if (kDebugMode) {
          debugPrint(
              '❌ Twilio error: ${response.statusCode} - ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Twilio SMS error: $e');
      }
      return false;
    }
  }

  /// Teşvik mesajı gönder
  static Future<SmsReminderResult> _sendEncouragementMessage(String phoneNumber, String userId) async {
    try {
      final streak = await getCurrentStreak(userId);
      final message = SmsTemplateService.generateEncouragementMessage(streak);
      final success = await _sendSms(phoneNumber, message);

      if (success) {
        await _logReminder(
          userId: userId,
          phoneNumber: phoneNumber,
          reminderType: ReminderType.daily,
          message: message,
        );

        return SmsReminderResult.success('Teşvik mesajı gönderildi', type: ReminderType.daily);
      } else {
        return SmsReminderResult.failure('Teşvik mesajı gönderilemedi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Teşvik mesajı hatası: $e');
      }
      return SmsReminderResult.failure('Teşvik mesajı gönderilemedi: $e');
    }
  }

  /// Hatırlatma logunu kaydet
  static Future<void> _logReminder({
    required String userId,
    required String phoneNumber,
    String? taskId,
    required ReminderType reminderType,
    required String message,
  }) async {
    try {
      await _firestore.collection('sms_reminder_logs').add({
        'userId': userId,
        'phoneNumber': phoneNumber,
        'taskId': taskId,
        'reminderType': reminderType.name,
        'message': message,
        'sentAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'sent',
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Log kaydetme hatası: $e');
      }
    }
  }

  /// Varsayılan tercihler oluştur
  static Future<UserPreferences> _createDefaultPreferences(String userId) async {
    try {
      final now = DateTime.now();
      final preferences = UserPreferences(
        userId: userId,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('user_preferences').doc(userId).set(preferences.toMap());
      return preferences;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Varsayılan tercih oluşturma hatası: $e');
      }
      rethrow;
    }
  }

  /// Kullanıcı serisini güncelle
  static Future<void> _updateUserStreak(String userId) async {
    try {
      final currentStreak = await getCurrentStreak(userId);
      final newStreak = currentStreak + 1;
      
      await _firestore.collection('user_stats').doc(userId).set({
        'currentStreak': newStreak,
        'longestStreak': FieldValue.increment(0), // En uzun seri ayrı hesaplanmalı
        'lastTaskCompletedAt': DateTime.now().millisecondsSinceEpoch,
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Seri güncelleme hatası: $e');
      }
    }
  }
}