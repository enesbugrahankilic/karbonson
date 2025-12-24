// lib/services/sms_template_service.dart
// SMS şablonları ve mesaj oluşturucu servisi

import '../models/task_reminder.dart';
import '../models/user_preferences.dart';
import '../models/weekly_report.dart';

/// SMS mesaj şablonları servisi
class SmsTemplateService {
  /// Günlük hatırlatma mesajı oluştur
  static String generateDailyReminderMessage(TaskReminder task, String language) {
    if (language == 'tr') {
      final timeStr = _formatTime(task.scheduledTime);
      return '🎯 Günlük hatırlatma: "${task.title}" görevin $timeStr\'da başlıyor! Hemen başla ve serini devam ettir. 💪';
    } else {
      final timeStr = _formatTime(task.scheduledTime);
      return '🎯 Daily reminder: Your task "${task.title}" starts at $timeStr! Start now and keep your streak going. 💪';
    }
  }

  /// Kaçırılan görev hatırlatması
  static String generateMissedTaskReminder(List<TaskReminder> missedTasks, String language) {
    if (language == 'tr') {
      if (missedTasks.length == 1) {
        return '❌ Kaçırdığın görev: "${missedTasks.first.title}". Bugün yeni bir görev al ve tekrar başla! 🔄';
      } else {
        final taskNames = missedTasks.take(3).map((t) => '"${t.title}"').join(', ');
        return '❌ Kaçırdığın ${missedTasks.length} görev var: $taskNames${missedTasks.length > 3 ? '...' : ''}. Yeni bir başlangıç yap! 🔄';
      }
    } else {
      if (missedTasks.length == 1) {
        return '❌ Missed task: "${missedTasks.first.title}". Take a new task and start again! 🔄';
      } else {
        final taskNames = missedTasks.take(3).map((t) => '"${t.title}"').join(', ');
        return '❌ You missed ${missedTasks.length} tasks: $taskNames${missedTasks.length > 3 ? '...' : ''}. Make a fresh start! 🔄';
      }
    }
  }

  /// Seri hatırlatması
  static String generateStreakReminder(int currentStreak, String language) {
    if (language == 'tr') {
      if (currentStreak == 0) {
        return '🔥 Yeni bir seri başlat! İlk görevini tamamla ve uzun bir yolculuğa çık. ✨';
      } else if (currentStreak < 5) {
        return '🔥 Harika! $currentStreak günlük serin var. Bir sonraki görevi tamamla ve serini uzat! 💪';
      } else if (currentStreak < 10) {
        return '🔥 Mükemmel! $currentStreak günlük serin var. Bu inanılmaz! Hedefin 10 gün. 🚀';
      } else {
        return '🔥 Efsane! $currentStreak günlük serin var! Sen gerçek bir şampiyonsun! 🏆';
      }
    } else {
      if (currentStreak == 0) {
        return '🔥 Start a new streak! Complete your first task and begin an amazing journey. ✨';
      } else if (currentStreak < 5) {
        return '🔥 Great! You have a $currentStreak-day streak. Complete the next task to extend it! 💪';
      } else if (currentStreak < 10) {
        return '🔥 Awesome! You have a $currentStreak-day streak. Incredible! Target is 10 days. 🚀';
      } else {
        return '🔥 Legendary! You have a $currentStreak-day streak! You\'re a true champion! 🏆';
      }
    }
  }

  /// Haftalık rapor mesajı
  static String generateWeeklyReportMessage(WeeklyReport report, String language) {
    if (language == 'tr') {
      final rateStr = report.completionRate.toStringAsFixed(0);
      return '📊 Haftalık Raporun:\n✅ Tamamlanan: ${report.completedTasks}/${report.totalTasks}\n📈 Başarı oranı: %$rateStr\n🔥 Mevcut seri: ${report.currentStreak} gün\n🏆 En uzun seri: ${report.longestStreak} gün\n\nHarika iş çıkarıyorsun! 💪';
    } else {
      final rateStr = report.completionRate.toStringAsFixed(0);
      return '📊 Your Weekly Report:\n✅ Completed: ${report.completedTasks}/${report.totalTasks}\n📈 Success rate: $rateStr%\n🔥 Current streak: ${report.currentStreak} days\n🏆 Longest streak: ${report.longestStreak} days\n\nGreat work! 💪';
    }
  }

  /// Teşvik mesajı
  static String generateEncouragementMessage(int currentStreak) {
    final messages = [
      '🎉 Tüm görevler tamamlandı! Sen harikasın! ✨',
      '💪 Bugün mükemmeldin! Yarın da aynı enerjiyle! 🌟',
      '🏆 Muhteşem bir gün! Serini yarın da devam ettir! 🔥',
      '⭐ Başarıların beni gururlandırıyor! Yarın görüşürüz! 👏',
      '🚀 Bugün harikaydın! Yarın da aynı başarıyı bekliyorum! 💯'
    ];
    
    return messages[currentStreak % messages.length];
  }

  /// Zamanı formatla
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Motivasyon mesajları
  static List<String> getMotivationalMessages(String language) {
    if (language == 'tr') {
      return [
        'Her gün bir adım daha ileri! 💪',
        'Küçük adımlar büyük değişimler yaratır! ✨',
        'Sen yapabilirsin! İnancım tam! 🔥',
        'Bugün senin günün! 🌟',
        'Hedefine odaklan, başarı senin olacak! 🎯',
        'Disiplin başarının anahtarıdır! 🔑',
        'Bugün yarından daha iyisini yapabilirsin! 📈',
        'Konsantre ol ve devam et! 🎯'
      ];
    } else {
      return [
        'One step closer every day! 💪',
        'Small steps create big changes! ✨',
        'You can do it! I believe in you! 🔥',
        'Today is your day! 🌟',
        'Focus on your goal, success is yours! 🎯',
        'Discipline is the key to success! 🔑',
        'You can do better today than yesterday! 📈',
        'Focus and keep going! 🎯'
      ];
    }
  }

  /// Kategori bazlı özel mesajlar
  static String getCategoryMessage(String category, String language) {
    final Map<String, Map<String, String>> categoryMessages = {
      'exercise': {
        'tr': '💪 Egzersiz zamanı! Vücudun sana teşekkür edecek!',
        'en': '💪 Time for exercise! Your body will thank you!'
      },
      'study': {
        'tr': '📚 Çalışma zamanı! Bilgi güçtür!',
        'en': '📚 Study time! Knowledge is power!'
      },
      'work': {
        'tr': '💼 İş zamanı! Hedeflerine odaklan!',
        'en': '💼 Work time! Focus on your goals!'
      },
      'health': {
        'tr': '🍎 Sağlık zamanı! Kendine iyi bak!',
        'en': '🍎 Health time! Take care of yourself!'
      },
      'personal': {
        'tr': '🌱 Kişisel gelişim zamanı! Kendini geliştir!',
        'en': '🌱 Personal development time! Improve yourself!'
      }
    };

    return categoryMessages[category]?[language] ?? 
           (language == 'tr' ? '🎯 Görev zamanı! Harekete geç!' : '🎯 Task time! Take action!');
  }
}