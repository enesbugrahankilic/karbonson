// lib/services/difficulty_recommendation_service.dart
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../data/questions_database.dart';

/// Kullanıcının quiz performansını analiz eden ve zorluk seviyesi öneren servis
class DifficultyRecommendationService {
  static const String _userStatsKey = 'userQuizStats';
  static const String _performanceHistoryKey = 'performanceHistory';
  static const String _lastRecommendationKey = 'lastRecommendation';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();

  // Kullanıcı performans metrikleri
  Map<String, dynamic> _userStats = {};
  List<Map<String, dynamic>> _performanceHistory = [];
  String? _lastRecommendation;

  /// Kullanıcı istatistiklerini yükle
  Future<void> loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid;
      
      if (userId == null) return;

      final statsJson = prefs.getString(_userStatsKey);
      final historyJson = prefs.getString(_performanceHistoryKey);
      _lastRecommendation = prefs.getString(_lastRecommendationKey);

      if (statsJson != null) {
        _userStats = Map<String, dynamic>.from({});
        // Parse stats JSON if needed
      }

      if (historyJson != null) {
        _performanceHistory = [];
        // Parse history JSON if needed
      }
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  /// Kullanıcı istatistiklerini kaydet
  Future<void> saveUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid;
      
      if (userId == null) return;

      await prefs.setString(_userStatsKey, _userStats.toString());
      await prefs.setString(_performanceHistoryKey, _performanceHistory.toString());
      await prefs.setString(_lastRecommendationKey, _lastRecommendation ?? '');
    } catch (e) {
      print('Error saving user stats: $e');
    }
  }

  /// Quiz sonrası performansı analiz et
  void recordQuizPerformance({
    required DifficultyLevel difficulty,
    required int score,
    required int totalQuestions,
    required List<String> wrongAnswerCategories,
    required Duration completionTime,
  }) {
    final accuracy = (score / (totalQuestions * 10)) * 100;
    final performanceData = {
      'difficulty': difficulty.toString(),
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'wrongCategories': wrongAnswerCategories,
      'completionTime': completionTime.inMinutes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _performanceHistory.add(performanceData);
    
    // Son 10 quiz sonucunu sakla
    if (_performanceHistory.length > 10) {
      _performanceHistory.removeAt(0);
    }

    _updateUserStats(difficulty, accuracy);
    saveUserStats();
  }

  /// Kullanıcı istatistiklerini güncelle
  void _updateUserStats(DifficultyLevel difficulty, double accuracy) {
    if (!_userStats.containsKey(difficulty.toString())) {
      _userStats[difficulty.toString()] = {
        'totalQuizzes': 0,
        'averageAccuracy': 0.0,
        'bestScore': 0,
        'lastPlayed': DateTime.now().millisecondsSinceEpoch,
      };
    }

    final stats = _userStats[difficulty.toString()] as Map<String, dynamic>;
    final currentQuizzes = stats['totalQuizzes'] as int;
    final currentAvg = stats['averageAccuracy'] as double;

    final newAvg = ((currentAvg * currentQuizzes) + accuracy) / (currentQuizzes + 1);
    
    stats['totalQuizzes'] = currentQuizzes + 1;
    stats['averageAccuracy'] = newAvg;
    stats['bestScore'] = max(stats['bestScore'] as int, (accuracy.round()));
    stats['lastPlayed'] = DateTime.now().millisecondsSinceEpoch;

    _userStats[difficulty.toString()] = stats;
  }

  /// Önerilen zorluk seviyesini belirle
  DifficultyLevel getRecommendedDifficulty() {
    if (_performanceHistory.isEmpty) {
      // İlk kez quiz yapan kullanıcı için kolay seviye
      return DifficultyLevel.easy;
    }

    // Son 3 quiz sonucunu analiz et
    final recentQuizzes = _performanceHistory.take(3).toList();
    final avgAccuracy = recentQuizzes
        .map((quiz) => quiz['accuracy'] as double)
        .reduce((a, b) => a + b) / recentQuizzes.length;

    final lastDifficulty = DifficultyLevel.values.firstWhere(
      (d) => d.toString() == recentQuizzes.last['difficulty'],
      orElse: () => DifficultyLevel.easy,
    );

    // Performansa göre zorluk seviyesi önerisi
    if (avgAccuracy >= 85) {
      // Çok iyi performans - bir üst seviye
      switch (lastDifficulty) {
        case DifficultyLevel.easy:
          return DifficultyLevel.medium;
        case DifficultyLevel.medium:
          return DifficultyLevel.hard;
        case DifficultyLevel.hard:
          return DifficultyLevel.hard; // En üst seviye
      }
    } else if (avgAccuracy >= 70) {
      // İyi performans - mevcut seviye
      return lastDifficulty;
    } else if (avgAccuracy >= 50) {
      // Orta performans - bir alt seviye
      switch (lastDifficulty) {
        case DifficultyLevel.hard:
          return DifficultyLevel.medium;
        case DifficultyLevel.medium:
          return DifficultyLevel.easy;
        case DifficultyLevel.easy:
          return DifficultyLevel.easy; // En alt seviye
      }
    } else {
      // Düşük performans - kolay seviye
      return DifficultyLevel.easy;
    }
  }

  /// Kullanıcının güçlü ve zayıf konularını analiz et
  Map<String, dynamic> getWeakAreas() {
    final categoryPerformance = <String, Map<String, dynamic>>{};
    
    for (final quiz in _performanceHistory) {
      final wrongCategories = (quiz['wrongCategories'] as List?)?.cast<String>() ?? [];
      
      for (final category in wrongCategories) {
        if (!categoryPerformance.containsKey(category)) {
          categoryPerformance[category] = {
            'wrongCount': 0,
            'totalQuizzes': 0,
          };
        }
        
        final stats = categoryPerformance[category]!;
        stats['wrongCount'] = (stats['wrongCount'] as int) + 1;
        stats['totalQuizzes'] = (stats['totalQuizzes'] as int) + 1;
      }
    }

    // Zayıf alanları belirle (yanlış oranı yüksek olan kategoriler)
    final weakAreas = <String>[];
    categoryPerformance.forEach((category, stats) {
      final wrongRatio = (stats['wrongCount'] as int) / (stats['totalQuizzes'] as int);
      if (wrongRatio > 0.3) { // %30'dan fazla yanlış oranı
        weakAreas.add(category);
      }
    });

    return {
      'weakAreas': weakAreas,
      'categoryStats': categoryPerformance,
      'recommendation': weakAreas.isNotEmpty 
        ? 'Bu konularda daha fazla çalışmanızı öneriyoruz.'
        : 'Tüm konularda dengeli performans gösteriyorsunuz!',
    };
  }

  /// İlerleme raporu oluştur
  Map<String, dynamic> getProgressReport() {
    final report = <String, dynamic>{};
    
    for (final difficulty in DifficultyLevel.values) {
      final difficultyStr = difficulty.toString();
      final stats = _userStats[difficultyStr] as Map<String, dynamic>?;

      if (stats != null) {
        report[difficultyStr] = {
          'totalQuizzes': stats['totalQuizzes'] ?? 0,
          'averageAccuracy': (stats['averageAccuracy'] ?? 0.0).toStringAsFixed(1),
          'bestScore': stats['bestScore'] ?? 0,
          'displayName': difficulty.displayName,
        };
      }
    }

    report['overallRecommendation'] = getRecommendedDifficulty().displayName;
    report['weakAreas'] = getWeakAreas();
    
    return report;
  }

  /// Önerilen soru sayısını belirle
  int getRecommendedQuestionCount(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 15;
      case DifficultyLevel.medium:
        return 12;
      case DifficultyLevel.hard:
        return 10;
    }
  }

  /// Performans trendini analiz et
  Map<String, dynamic> getPerformanceTrend() {
    if (_performanceHistory.length < 3) {
      return {
        'trend': 'insufficient_data',
        'message': 'Daha fazla quiz tamamlayarak trend analizi yapabilirsiniz.',
      };
    }

    final recentQuizzes = _performanceHistory.take(5).toList();
    final accuracyScores = recentQuizzes.map((q) => q['accuracy'] as double).toList();
    
    // Linear regression basit uygulaması
    final n = accuracyScores.length;
    final sumX = List.generate(n, (i) => i).reduce((a, b) => a + b);
    final sumY = accuracyScores.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => i * accuracyScores[i]).reduce((a, b) => a + b);
    final sumX2 = List.generate(n, (i) => i * i).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    String trend;
    if (slope > 2) {
      trend = 'improving';
    } else if (slope < -2) {
      trend = 'declining';
    } else {
      trend = 'stable';
    }

    return {
      'trend': trend,
      'slope': slope.toStringAsFixed(2),
      'message': _getTrendMessage(trend),
      'recentAccuracy': accuracyScores.last.toStringAsFixed(1),
    };
  }

  String _getTrendMessage(String trend) {
    switch (trend) {
      case 'improving':
        return 'Harika! Performansınız sürekli artıyor! 🎉';
      case 'declining':
        return 'Son dönemde performansınız düşüyor. Belki daha kolay seviye denemek istersiniz? 📚';
      case 'stable':
        return 'Performansınız stabil. Biraz daha zorlayabilirsiniz! 💪';
      default:
        return 'Daha fazla veri toplanıyor...';
    }
  }

  /// İstatistikleri temizle (test için)
  void clearStats() {
    _userStats.clear();
    _performanceHistory.clear();
    _lastRecommendation = null;
    saveUserStats();
  }

  /// Debug bilgisi
  Map<String, dynamic> getDebugInfo() {
    return {
      'userStats': _userStats,
      'performanceHistory': _performanceHistory,
      'lastRecommendation': _lastRecommendation,
      'totalQuizzes': _performanceHistory.length,
    };
  }
}
