// lib/services/sms_reminder_scheduler.dart
// SMS Reminder zamanlama ve otomasyon servisi

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sms_reminder_service.dart';
import '../models/user_preferences.dart';

/// Zamanlama sonucu
class SchedulerResult {
  final bool isSuccess;
  final String message;
  final String? userId;

  const SchedulerResult({
    required this.isSuccess,
    required this.message,
    this.userId,
  });

  factory SchedulerResult.success(String message, {String? userId}) {
    return SchedulerResult(
      isSuccess: true,
      message: message,
      userId: userId,
    );
  }

  factory SchedulerResult.failure(String message) {
    return SchedulerResult(
      isSuccess: false,
      message: message,
    );
  }
}

/// SMS Reminder Zamanlama Servisi
class SmsReminderScheduler {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static Timer? _dailyTimer;
  static Timer? _weeklyTimer;
  static Timer? _streakTimer;

  /// ✅ Günlük hatırlatma zamanlayıcısını başlat
  static void startDailyReminderScheduler() {
    // Mevcut timer'ı durdur
    _dailyTimer?.cancel();

    // Her gün saat 20:00'da çalışacak şekilde zamanla
    _scheduleDailyReminder();
    
    if (kDebugMode) {
      debugPrint('📅 Günlük hatırlatma zamanlayıcısı başlatıldı (20:00)');
    }
  }

  /// ✅ Haftalık rapor zamanlayıcısını başlat
  static void startWeeklyReportScheduler() {
    _weeklyTimer?.cancel();

    // Her pazar saat 21:00'da çalışacak şekilde zamanla
    _scheduleWeeklyReport();
    
    if (kDebugMode) {
      debugPrint('📊 Haftalık rapor zamanlayıcısı başlatıldı (Pazar 21:00)');
    }
  }

  /// ✅ Seri hatırlatma zamanlayıcısını başlat
  static void startStreakReminderScheduler() {
    _streakTimer?.cancel();

    // Her gün saat 09:00'da çalışacak şekilde zamanla
    _scheduleStreakReminder();
    
    if (kDebugMode) {
      debugPrint('🔥 Seri hatırlatma zamanlayıcısı başlatıldı (09:00)');
    }
  }

  /// ✅ Tüm zamanlayıcıları durdur
  static void stopAllSchedulers() {
    _dailyTimer?.cancel();
    _weeklyTimer?.cancel();
    _streakTimer?.cancel();
    
    if (kDebugMode) {
      debugPrint('⏹️ Tüm SMS reminder zamanlayıcıları durduruldu');
    }
  }

  /// ✅ Belirli bir kullanıcı için manuel hatırlatma gönder
  static Future<SchedulerResult> sendManualReminder({
    required String userId,
    required String reminderType, // 'daily', 'missed', 'streak', 'weekly'
  }) async {
    try {
      final phoneNumber = await SmsReminderService.getUserPhoneNumber(userId);
      if (phoneNumber == null) {
        return SchedulerResult.failure('Kullanıcı telefon numarası bulunamadı');
      }

      SmsReminderResult result;
      
      switch (reminderType.toLowerCase()) {
        case 'daily':
          result = await SmsReminderService.sendDailyReminder(userId: userId, phoneNumber: phoneNumber);
          break;
        case 'missed':
          result = await SmsReminderService.sendMissedTaskReminder(userId: userId, phoneNumber: phoneNumber);
          break;
        case 'streak':
          result = await SmsReminderService.sendStreakReminder(userId: userId, phoneNumber: phoneNumber);
          break;
        case 'weekly':
          result = await SmsReminderService.sendWeeklyReport(userId: userId, phoneNumber: phoneNumber);
          break;
        default:
          return SchedulerResult.failure('Geçersiz hatırlatma türü: $reminderType');
      }

      if (result.isSuccess) {
        return SchedulerResult.success('${reminderType} hatırlatması gönderildi', userId: userId);
      } else {
        return SchedulerResult.failure(result.message);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Manuel hatırlatma hatası: $e');
      }
      return SchedulerResult.failure('Hatırlatma gönderilemedi: $e');
    }
  }

  /// ✅ Kaçırılan görevler için otomatik kontrol
  static Future<void> checkAndSendMissedTaskReminders() async {
    try {
      final usersSnapshot = await _firestore.collection('user_preferences')
          .where('smsNotificationsEnabled', isEqualTo: true)
          .where('missedTaskReminders', isEqualTo: true)
          .get();

      for (final doc in usersSnapshot.docs) {
        final userId = doc.id;
        final preferences = UserPreferences.fromMap(doc.data());
        
        // Hafta sonu kontrolü
        final now = DateTime.now();
        final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
        
        if (isWeekend && !preferences.weekendReminders) {
          continue; // Hafta sonu hatırlatmaları kapalıysa atla
        }

        final result = await SmsReminderService.sendMissedTaskReminder(userId: userId);
        if (kDebugMode && result.isSuccess) {
          debugPrint('✅ Kaçırılan görev hatırlatması gönderildi: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Kaçırılan görev kontrolü hatası: $e');
      }
    }
  }

  // === ÖZEL ZAMANLAMA METODLARI ===

  /// Günlük hatırlatmayı zamanla
  static void _scheduleDailyReminder() {
    final now = DateTime.now();
    final today20 = DateTime(now.year, now.month, now.day, 20, 0); // 20:00
    
    Duration delay;
    if (now.isBefore(today20)) {
      // Eğer bugün 20:00 geçmemişse, bugün 20:00'da çalıştır
      delay = today20.difference(now);
    } else {
      // Eğer 20:00 geçmişse, yarın 20:00'da çalıştır
      final tomorrow20 = today20.add(const Duration(days: 1));
      delay = tomorrow20.difference(now);
    }

    _dailyTimer = Timer(delay, () async {
      await _executeDailyReminderForAllUsers();
      // Bir sonraki gün için tekrar zamanla
      _scheduleDailyReminder();
    });
  }

  /// Haftalık raporu zamanla
  static void _scheduleWeeklyReport() {
    final now = DateTime.now();
    // Sonraki pazarı bul
    int daysUntilSunday = (7 - now.weekday) % 7;
    if (daysUntilSunday == 0) daysUntilSunday = 7; // Eğer bugün pazar ise, gelecek pazarı al
    
    final nextSunday = DateTime(now.year, now.month, now.day + daysUntilSunday, 21, 0); // 21:00
    final delay = nextSunday.difference(now);

    _weeklyTimer = Timer(delay, () async {
      await _executeWeeklyReportForAllUsers();
      // Bir sonraki hafta için tekrar zamanla
      _scheduleWeeklyReport();
    });
  }

  /// Seri hatırlatmasını zamanla
  static void _scheduleStreakReminder() {
    final now = DateTime.now();
    final today09 = DateTime(now.year, now.month, now.day, 9, 0); // 09:00
    
    Duration delay;
    if (now.isBefore(today09)) {
      delay = today09.difference(now);
    } else {
      final tomorrow09 = today09.add(const Duration(days: 1));
      delay = tomorrow09.difference(now);
    }

    _streakTimer = Timer(delay, () async {
      await _executeStreakReminderForAllUsers();
      // Bir sonraki gün için tekrar zamanla
      _scheduleStreakReminder();
    });
  }

  /// Tüm kullanıcılar için günlük hatırlatma çalıştır
  static Future<void> _executeDailyReminderForAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('user_preferences')
          .where('smsNotificationsEnabled', isEqualTo: true)
          .where('dailyRemindersEnabled', isEqualTo: true)
          .get();

      for (final doc in usersSnapshot.docs) {
        final userId = doc.id;
        final preferences = UserPreferences.fromMap(doc.data());
        
        // Hafta sonu kontrolü
        final now = DateTime.now();
        final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
        
        if (isWeekend && !preferences.weekendReminders) {
          continue;
        }

        final result = await SmsReminderService.sendDailyReminder(userId: userId);
        if (kDebugMode && result.isSuccess) {
          debugPrint('✅ Günlük hatırlatma gönderildi: $userId');
        }
      }

      if (kDebugMode) {
        debugPrint('📅 Günlük hatırlatmalar tamamlandı (${usersSnapshot.docs.length} kullanıcı)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Günlük hatırlatma hatası: $e');
      }
    }
  }

  /// Tüm kullanıcılar için haftalık rapor çalıştır
  static Future<void> _executeWeeklyReportForAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('user_preferences')
          .where('smsNotificationsEnabled', isEqualTo: true)
          .where('weeklyReportsEnabled', isEqualTo: true)
          .get();

      for (final doc in usersSnapshot.docs) {
        final userId = doc.id;
        final result = await SmsReminderService.sendWeeklyReport(userId: userId);
        if (kDebugMode && result.isSuccess) {
          debugPrint('✅ Haftalık rapor gönderildi: $userId');
        }
      }

      if (kDebugMode) {
        debugPrint('📊 Haftalık raporlar tamamlandı (${usersSnapshot.docs.length} kullanıcı)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Haftalık rapor hatası: $e');
      }
    }
  }

  /// Tüm kullanıcılar için seri hatırlatması çalıştır
  static Future<void> _executeStreakReminderForAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('user_preferences')
          .where('smsNotificationsEnabled', isEqualTo: true)
          .where('streakRemindersEnabled', isEqualTo: true)
          .get();

      for (final doc in usersSnapshot.docs) {
        final userId = doc.id;
        final preferences = UserPreferences.fromMap(doc.data());
        
        // Hafta sonu kontrolü
        final now = DateTime.now();
        final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
        
        if (isWeekend && !preferences.weekendReminders) {
          continue;
        }

        final result = await SmsReminderService.sendStreakReminder(userId: userId);
        if (kDebugMode && result.isSuccess) {
          debugPrint('✅ Seri hatırlatması gönderildi: $userId');
        }
      }

      if (kDebugMode) {
        debugPrint('🔥 Seri hatırlatmaları tamamlandı (${usersSnapshot.docs.length} kullanıcı)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Seri hatırlatması hatası: $e');
      }
    }
  }

  /// Zamanlayıcı durumunu kontrol et
  static Map<String, bool> getSchedulerStatus() {
    return {
      'daily': _dailyTimer?.isActive ?? false,
      'weekly': _weeklyTimer?.isActive ?? false,
      'streak': _streakTimer?.isActive ?? false,
    };
  }

  /// Bir sonraki çalışma zamanlarını al
  static Map<String, DateTime?> getNextScheduledTimes() {
    final now = DateTime.now();
    
    return {
      'daily': now.add(const Duration(hours: 24)), // Basit tahmin
      'weekly': now.add(const Duration(days: 7)), // Basit tahmin
      'streak': now.add(const Duration(hours: 24)), // Basit tahmin
    };
  }
}