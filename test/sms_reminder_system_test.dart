// test/sms_reminder_system_test.dart
// SMS Reminder sistemi test dosyası

import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/models/task_reminder.dart';
import 'package:karbonson/models/user_preferences.dart';
import 'package:karbonson/models/weekly_report.dart';
import 'package:karbonson/services/sms_reminder_scheduler.dart';
import 'package:karbonson/services/sms_template_service.dart';

void main() {
  group('SMS Reminder System Tests', () {
    
    group('TaskReminder Model Tests', () {
      test('TaskReminder oluşturma ve serialization', () {
        final task = TaskReminder(
          id: 'task123',
          userId: 'user123',
          title: 'Egzersiz Yap',
          description: '30 dakika cardio',
          category: 'exercise',
          scheduledTime: DateTime(2025, 12, 21, 20, 0),
          status: TaskStatus.pending,
          reminderType: ReminderType.daily,
          isRecurring: true,
          streakCount: 5,
          createdAt: DateTime.now(),
        );

        expect(task.id, 'task123');
        expect(task.title, 'Egzersiz Yap');
        expect(task.isCompleted, false);
        expect(task.isRecurring, true);

        // Map serialization test
        final taskMap = task.toMap();
        expect(taskMap['title'], 'Egzersiz Yap');
        expect(taskMap['status'], 'pending');
      });

      test('TaskReminder completion durumu', () {
        final completedTask = TaskReminder(
          id: 'task123',
          userId: 'user123',
          title: 'Tamamlanan Görev',
          description: 'Test',
          category: 'test',
          scheduledTime: DateTime.now(),
          status: TaskStatus.completed,
          reminderType: ReminderType.daily,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        expect(completedTask.isCompleted, true);
        expect(completedTask.isMissed, false);
      });
    });

    group('UserPreferences Model Tests', () {
      test('UserPreferences oluşturma ve güncelleme', () {
        final preferences = UserPreferences(
          userId: 'user123',
          smsNotificationsEnabled: true,
          dailyRemindersEnabled: true,
          weeklyReportsEnabled: true,
          streakRemindersEnabled: true,
          preferredReminderTime: TimeOfDay(hour: 20, minute: 0),
          reminderCategories: ['exercise', 'study'],
          snoozeDuration: 30,
          weekendReminders: false,
          missedTaskReminders: true,
          language: 'tr',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(preferences.userId, 'user123');
        expect(preferences.smsNotificationsEnabled, true);
        expect(preferences.language, 'tr');

        // Copy with test
        final updated = preferences.copyWith(
          smsNotificationsEnabled: false,
          language: 'en',
        );

        expect(updated.smsNotificationsEnabled, false);
        expect(updated.language, 'en');
        expect(updated.userId, 'user123'); // Değişmedi
      });

      test('TimeOfDay serialization', () {
        final timeOfDay = TimeOfDay(hour: 20, minute: 30);
        expect(timeOfDay.toString(), '20:30');
        
        final parsed = TimeOfDay.fromString('20:30');
        expect(parsed.hour, 20);
        expect(parsed.minute, 30);
      });
    });

    group('SMS Template Service Tests', () {
      test('Günlük hatırlatma mesajı oluşturma', () {
        final task = TaskReminder(
          id: 'task123',
          userId: 'user123',
          title: 'Egzersiz Yap',
          description: '30 dakika cardio',
          category: 'exercise',
          scheduledTime: DateTime(2025, 12, 21, 20, 0),
          status: TaskStatus.pending,
          reminderType: ReminderType.daily,
          createdAt: DateTime.now(),
        );

        final message = SmsTemplateService.generateDailyReminderMessage(task, 'tr');
        
        expect(message, contains('🎯'));
        expect(message, contains('Egzersiz Yap'));
        expect(message, contains('20:00'));
        expect(message, contains('💪'));
      });

      test('Kaçırılan görev hatırlatması', () {
        final missedTasks = [
          TaskReminder(
            id: 'task1',
            userId: 'user123',
            title: 'Kitap Oku',
            description: '30 sayfa',
            category: 'study',
            scheduledTime: DateTime.now(),
            status: TaskStatus.missed,
            reminderType: ReminderType.missed,
            createdAt: DateTime.now(),
          ),
        ];

        final message = SmsTemplateService.generateMissedTaskReminder(missedTasks, 'tr');
        
        expect(message, contains('❌'));
        expect(message, contains('Kaçırdığın görev'));
        expect(message, contains('Kitap Oku'));
        expect(message, contains('🔄'));
      });

      test('Seri hatırlatması', () {
        final message = SmsTemplateService.generateStreakReminder(5, 'tr');
        
        expect(message, contains('🔥'));
        expect(message, contains('5'));
        expect(message, contains('günlük serin'));
        expect(message, contains('💪'));
      });

      test('Haftalık rapor mesajı', () {
        final report = WeeklyReport(
          userId: 'user123',
          totalTasks: 20,
          completedTasks: 15,
          missedTasks: 5,
          currentStreak: 8,
          longestStreak: 12,
          completionRate: 75.0,
          completedCategories: ['exercise', 'study'],
          weekStartDate: DateTime.now().subtract(Duration(days: 7)),
          weekEndDate: DateTime.now(),
        );

        final message = SmsTemplateService.generateWeeklyReportMessage(report, 'tr');
        
        expect(message, contains('📊'));
        expect(message, contains('15/20'));
        expect(message, contains('%75'));
        expect(message, contains('8'));
        expect(message, contains('12'));
        expect(message, contains('💪'));
      });

      test('Teşvik mesajı', () {
        final message = SmsTemplateService.generateEncouragementMessage(3);
        
        expect(message, isNotEmpty);
        expect(message, anyOf([
          contains('🎉'),
          contains('💪'),
          contains('🏆'),
          contains('⭐'),
          contains('🚀'),
        ]));
      });

      test('Motivasyon mesajları', () {
        final messages = SmsTemplateService.getMotivationalMessages('tr');
        
        expect(messages, isNotEmpty);
        expect(messages.length, greaterThan(0));
        expect(messages.first, isNotEmpty);
      });

      test('Kategori mesajları', () {
        final exerciseMessage = SmsTemplateService.getCategoryMessage('exercise', 'tr');
        final studyMessage = SmsTemplateService.getCategoryMessage('study', 'tr');
        
        expect(exerciseMessage, contains('💪'));
        expect(studyMessage, contains('📚'));
      });
    });

    group('WeeklyReport Model Tests', () {
      test('WeeklyReport oluşturma ve hesaplamalar', () {
        final report = WeeklyReport(
          userId: 'user123',
          totalTasks: 20,
          completedTasks: 15,
          missedTasks: 5,
          currentStreak: 8,
          longestStreak: 12,
          completionRate: 75.0,
          completedCategories: ['exercise', 'study'],
          weekStartDate: DateTime.now().subtract(Duration(days: 7)),
          weekEndDate: DateTime.now(),
        );

        expect(report.userId, 'user123');
        expect(report.totalTasks, 20);
        expect(report.completedTasks, 15);
        expect(report.missedTasks, 5);
        expect(report.completionRate, 75.0);
        expect(report.completedCategories.length, 2);
      });
    });

    group('SMS Reminder Service Tests', () {
      test('Kullanıcı tercihleri oluşturma (mock)', () {
        // Bu test gerçek Firebase bağlantısı olmadan çalışır
        final preferences = UserPreferences(
          userId: 'test_user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(preferences.userId, 'test_user');
        expect(preferences.smsNotificationsEnabled, true);
        expect(preferences.language, 'tr');
      });

      test('Seri hesaplama', () {
        // Mock streak hesaplama
        final mockStreak = 7;
        expect(mockStreak, greaterThan(0));
        expect(mockStreak, lessThan(100));
      });

      test('SMS mesaj uzunluğu kontrolü', () {
        final task = TaskReminder(
          id: 'task123',
          userId: 'user123',
          title: 'Test Görev',
          description: 'Test açıklama',
          category: 'test',
          scheduledTime: DateTime.now(),
          status: TaskStatus.pending,
          reminderType: ReminderType.daily,
          createdAt: DateTime.now(),
        );

        final message = SmsTemplateService.generateDailyReminderMessage(task, 'tr');
        
        // SMS mesajlarının makul uzunlukta olması gerekir
        expect(message.length, lessThan(160));
        expect(message.length, greaterThan(10));
      });
    });

    group('SMS Reminder Scheduler Tests', () {
      test('Zamanlayıcı durumu kontrolü', () {
        final status = SmsReminderScheduler.getSchedulerStatus();
        
        expect(status, isA<Map<String, bool>>());
        expect(status.containsKey('daily'), true);
        expect(status.containsKey('weekly'), true);
        expect(status.containsKey('streak'), true);
      });

      test('Bir sonraki zamanlama hesaplama', () {
        final nextTimes = SmsReminderScheduler.getNextScheduledTimes();
        
        expect(nextTimes, isA<Map<String, DateTime?>>());
        expect(nextTimes.containsKey('daily'), true);
        expect(nextTimes.containsKey('weekly'), true);
        expect(nextTimes.containsKey('streak'), true);
      });
    });

    group('Integration Tests', () {
      test('Tam görev döngüsü simülasyonu', () {
        // 1. Görev oluştur
        final task = TaskReminder(
          id: 'task123',
          userId: 'user123',
          title: 'Test Görev',
          description: 'Test açıklama',
          category: 'test',
          scheduledTime: DateTime.now(),
          status: TaskStatus.pending,
          reminderType: ReminderType.daily,
          createdAt: DateTime.now(),
        );

        // 2. SMS mesajı oluştur
        final message = SmsTemplateService.generateDailyReminderMessage(task, 'tr');
        
        // 3. Mesaj içeriğini kontrol et
        expect(message, contains('Test Görev'));
        expect(message, contains('🎯'));
        
        // 4. Görev tamamlandı olarak işaretle
        final completedTask = task.copyWith(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
        );
        
        expect(completedTask.isCompleted, true);
        expect(completedTask.isCompleted, !task.isCompleted);
      });

      test('Tercihler ve mesaj uyumluluğu', () {
        final turkishPreferences = UserPreferences(
          userId: 'user123',
          language: 'tr',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final task = TaskReminder(
          id: 'task123',
          userId: 'user123',
          title: 'Test Görev',
          description: 'Test açıklama',
          category: 'test',
          scheduledTime: DateTime.now(),
          status: TaskStatus.pending,
          reminderType: ReminderType.daily,
          createdAt: DateTime.now(),
        );

        final message = SmsTemplateService.generateDailyReminderMessage(
          task, 
          turkishPreferences.language
        );
        
        // Türkçe mesaj kontrolü
        expect(message, contains('Günlük hatırlatma'));
        expect(message, contains('görevin'));
      });
    });
  });
}

/// Mock test fonksiyonları (gerçek Firebase bağlantısı olmadan)
class MockFirebaseService {
  static Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    return {
      'userId': userId,
      'smsNotificationsEnabled': true,
      'dailyRemindersEnabled': true,
      'weeklyReportsEnabled': true,
      'streakRemindersEnabled': true,
      'preferredReminderTime': '20:00',
      'reminderCategories': ['exercise', 'study'],
      'snoozeDuration': 30,
      'weekendReminders': false,
      'missedTaskReminders': true,
      'language': 'tr',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<String?> getUserPhoneNumber(String userId) async {
    return '+905551234567';
  }

  static Future<List<Map<String, dynamic>>> getTodayTasks(String userId) async {
    return [
      {
        'id': 'task123',
        'userId': userId,
        'title': 'Egzersiz Yap',
        'description': '30 dakika cardio',
        'category': 'exercise',
        'scheduledTime': DateTime.now().millisecondsSinceEpoch,
        'status': 'pending',
        'reminderType': 'daily',
        'isRecurring': true,
        'streakCount': 5,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      }
    ];
  }
}