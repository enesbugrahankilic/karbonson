// lib/core/navigation/smart_navigation_helper.dart
// Akıllı navigasyon yardımcı sınıfı - Yeni akış tasarımı implementasyonu

import 'package:flutter/material.dart';
import '../navigation/app_router.dart';

/// Akıllı navigasyon yardımcı sınıfı
/// Kullanıcı davranışlarına göre bağlamsal yönlendirmeler yapar
class SmartNavigationHelper {
  
  /// Quiz sonrası akıllı yönlendirme
  /// Kullanıcının performansına göre en uygun sayfaya yönlendirir
  static void navigateAfterQuiz({
    required BuildContext context,
    required int score,
    required int totalQuestions,
    required List<String> wrongCategories,
  }) {
    final scorePercentage = (score / totalQuestions) * 100;
    
    if (scorePercentage >= 80) {
      // Yüksek performans: Liderlik tablosu ve sosyal paylaşım
      _showSuccessDialog(context, score, totalQuestions, () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.leaderboard,
          (route) => route.settings.name == AppRoutes.home,
        );
      });
    } else if (scorePercentage >= 60) {
      // Orta performans: Başarılar ve gelişim önerileri
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.achievement,
        (route) => route.settings.name == AppRoutes.home,
        arguments: {'showNewAchievements': true},
      );
    } else {
      // Düşük performans: Eğitim ve AI öneriler
      _showImprovementDialog(context, score, totalQuestions, wrongCategories, () {
        Navigator.pushNamed(
          context,
          AppRoutes.aiRecommendations,
          arguments: {
            'weakCategories': wrongCategories,
            'currentScore': score,
          },
        );
      });
    }
  }

  /// Düello sonrası akıllı yönlendirme
  static void navigateAfterDuel({
    required BuildContext context,
    required bool isWin,
    required String opponentName,
    required int playerScore,
    required int opponentScore,
  }) {
    if (isWin) {
      // Kazanma durumu: Arkadaş ekleme önerisi
      _showDuelWinDialog(context, opponentName, playerScore, opponentScore, () {
        Navigator.pushNamed(
          context,
          AppRoutes.friends,
          arguments: {'suggestAddFriend': opponentName},
        );
      });
    } else {
      // Kaybetme durumu: Gelişim önerileri
      _showDuelLoseDialog(context, opponentName, () {
        Navigator.pushNamed(
          context,
          AppRoutes.aiRecommendations,
          arguments: {
            'recentPerformance': 'duel_loss',
            'opponentScore': opponentScore,
          },
        );
      });
    }
  }

  /// Arkadaşlık isteği sonrası navigasyon
  static void navigateAfterFriendRequest({
    required BuildContext context,
    required String friendNickname,
    required bool isAccepted,
  }) {
    if (isAccepted) {
      // Arkadaşlık kabul edildi: Ortak oyun önerisi
      Navigator.pushNamed(
        context,
        AppRoutes.roomManagement,
        arguments: {
          'suggestInviteFriend': friendNickname,
          'suggestedActivity': 'duel',
        },
      );
    } else {
      // Arkadaşlık reddedildi: Diğer arkadaşları göster
      Navigator.pushNamed(
        context,
        AppRoutes.friends,
        arguments: {'focusTab': 'all_users'},
      );
    }
  }

  /// Günlük görev tamamlama sonrası navigasyon
  static void navigateAfterDailyChallenge({
    required BuildContext context,
    required bool allCompleted,
    required int completedChallenges,
    required int totalChallenges,
  }) {
    if (allCompleted && totalChallenges >= 3) {
      // Tüm günlük görevler tamamlandı: Ödül ve sosyal paylaşım
      Navigator.pushNamed(
        context,
        AppRoutes.achievement,
        arguments: {'showDailyReward': true},
      );
    } else {
      // Kısmi tamamlanma: Kalan görevleri göster
      Navigator.pushNamed(
        context,
        AppRoutes.dailyChallenge,
        arguments: {'showProgress': true},
      );
    }
  }

  /// Başarı kazanma sonrası navigasyon
  static void navigateAfterAchievement({
    required BuildContext context,
    required String achievementType,
    required int achievementCount,
  }) {
    if (achievementCount >= 5) {
      // 5+ başarı: Liderlik tablosunda sıralamayı göster
      Navigator.pushNamed(
        context,
        AppRoutes.leaderboard,
        arguments: {'highlightUser': true},
      );
    } else {
      // Yeni başarı: Profilde göster
      Navigator.pushNamed(
        context,
        AppRoutes.profile,
        arguments: {'showNewAchievement': true},
      );
    }
  }

  /// Settings'den güvenlik ayarlarına akıllı yönlendirme
  static void navigateToSecuritySettings({
    required BuildContext context,
    required String currentSecurityLevel,
  }) {
    switch (currentSecurityLevel) {
      case 'none':
        Navigator.pushNamed(
          context,
          AppRoutes.twoFactorAuthSetup,
          arguments: {'suggestSetup': true},
        );
        break;
      case 'basic_2fa':
        Navigator.pushNamed(
          context,
          AppRoutes.comprehensive2FASetup,
          arguments: {'upgradeToComprehensive': true},
        );
        break;
      case 'comprehensive':
        Navigator.pushNamed(
          context,
          AppRoutes.settings,
          arguments: {'suggestPasswordUpdate': true},
        );
        break;
      default:
        Navigator.pushNamed(
          context,
          AppRoutes.settings,
          arguments: {'returnToSettings': true},
        );
    }
  }

  /// Tutorial sonrası akıllı başlangıç önerisi
  static void navigateAfterTutorial({
    required BuildContext context,
    required String userExperienceLevel,
  }) {
    switch (userExperienceLevel) {
      case 'beginner':
        // Yeni kullanıcı: Kolay quiz önerisi
        Navigator.pushNamed(
          context,
          AppRoutes.quiz,
          arguments: {
            'difficulty': 'easy',
            'category': 'energy',
            'questionCount': 5,
            'suggestedBy': 'tutorial',
          },
        );
        break;
      case 'intermediate':
        // Orta seviye: Düello önerisi
        Navigator.pushNamed(
          context,
          AppRoutes.friends,
          arguments: {'suggestQuickDuel': true},
        );
        break;
      case 'advanced':
        // İleri seviye: Karmaşık quiz önerisi
        Navigator.pushNamed(
          context,
          AppRoutes.quiz,
          arguments: {
            'difficulty': 'hard',
            'category': null, // Tümü
            'questionCount': 20,
            'suggestedBy': 'tutorial',
          },
        );
        break;
    }
  }

  /// Ana sayfadan hızlı erişim akıllı yönlendirmesi
  static void navigateFromQuickAccess({
    required BuildContext context,
    required String accessType,
    Map<String, dynamic>? arguments,
  }) {
    switch (accessType) {
      case 'quick_quiz':
        _handleQuickQuizNavigation(context, arguments);
        break;
      case 'duel':
        _handleDuelNavigation(context, arguments);
        break;
      case 'friends':
        _handleFriendsNavigation(context, arguments);
        break;
      case 'leaderboard':
        _handleLeaderboardNavigation(context, arguments);
        break;
      case 'achievements':
        _handleAchievementsNavigation(context, arguments);
        break;
      default:
        Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  // Private helper methods

  static void _showSuccessDialog(
    BuildContext context,
    int score,
    int total,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Harika!'),
        content: Text('Quiz\'i $score/$total doğru ile tamamladınız!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ana Sayfa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: const Text('Liderlik Tablosu'),
          ),
        ],
      ),
    );
  }

  static void _showImprovementDialog(
    BuildContext context,
    int score,
    int total,
    List<String> wrongCategories,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💪 Gelişim Zamanı!'),
        content: Text(
          'Quiz\'i $score/$total doğru ile tamamladınız.\n'
          'Zayıf olduğunuz konular: ${wrongCategories.join(", ")}\n\n'
          'AI önerilerimizi inceleyelim mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ana Sayfa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: const Text('AI Önerileri'),
          ),
        ],
      ),
    );
  }

  static void _showDuelWinDialog(
    BuildContext context,
    String opponentName,
    int playerScore,
    int opponentScore,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏆 Düello Kazandınız!'),
        content: Text(
          '$opponentName\'i $playerScore-$opponentScore ile yendiniz!\n\n'
          'Bu harika performans için tebrikler! Arkadaşınızı eklemek ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ana Sayfa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: const Text('Arkadaş Ekle'),
          ),
        ],
      ),
    );
  }

  static void _showDuelLoseDialog(
    BuildContext context,
    String opponentName,
    VoidCallback onContinue,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Gelişim Fırsatı!'),
        content: Text(
          '$opponentName\'e kaybettiniz, ama bu öğrenme fırsatı!\n\n'
          'AI analizimiz size özel gelişim önerileri hazırladı.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ana Sayfa'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onContinue();
            },
            child: const Text('AI Önerileri'),
          ),
        ],
      ),
    );
  }

  static void _handleQuickQuizNavigation(
    BuildContext context,
    Map<String, dynamic>? arguments,
  ) {
    final args = arguments ?? {};
    final rememberedCategory = args['rememberedCategory'] as String?;
    final difficulty = args['difficulty'] ?? 'medium';
    final questionCount = args['questionCount'] ?? 10;

    if (rememberedCategory != null && rememberedCategory != 'all') {
      // Hatırlanan kategori varsa direkt başlat
      Navigator.pushNamed(
        context,
        AppRoutes.quiz,
        arguments: {
          'category': rememberedCategory,
          'difficulty': difficulty,
          'questionCount': questionCount,
        },
      );
    } else {
      // Kategori seçimi gerekli
      Navigator.pushNamed(
        context,
        AppRoutes.quiz,
        arguments: {
          'showCategorySelection': true,
          'difficulty': difficulty,
          'questionCount': questionCount,
        },
      );
    }
  }

  static void _handleDuelNavigation(
    BuildContext context,
    Map<String, dynamic>? arguments,
  ) {
    final args = arguments ?? {};
    final hasFriends = args['hasFriends'] as bool? ?? false;

    if (hasFriends) {
      // Arkadaş varsa düello seçenekleri göster
      Navigator.pushNamed(
        context,
        AppRoutes.duel,
        arguments: {'showOptions': true},
      );
    } else {
      // Arkadaş yoksa arkadaş ekleme öner
      Navigator.pushNamed(
        context,
        AppRoutes.friends,
        arguments: {'suggestAddFriends': true},
      );
    }
  }

  static void _handleFriendsNavigation(
    BuildContext context,
    Map<String, dynamic>? arguments,
  ) {
    final args = arguments ?? {};
    final tab = args['tab'] as String? ?? 'friends';

    Navigator.pushNamed(
      context,
      AppRoutes.friends,
      arguments: {'defaultTab': tab},
    );
  }

  static void _handleLeaderboardNavigation(
    BuildContext context,
    Map<String, dynamic>? arguments,
  ) {
    final args = arguments ?? {};
    final showUserPosition = args['showUserPosition'] as bool? ?? true;

    Navigator.pushNamed(
      context,
      AppRoutes.leaderboard,
      arguments: {'highlightUser': showUserPosition},
    );
  }

  static void _handleAchievementsNavigation(
    BuildContext context,
    Map<String, dynamic>? arguments,
  ) {
    final args = arguments ?? {};
    final category = args['category'] as String?;

    Navigator.pushNamed(
      context,
      AppRoutes.achievement,
      arguments: {'filterCategory': category},
    );
  }
}
