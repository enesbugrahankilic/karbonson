// lib/pages/quiz_results_page.dart
// Quiz Results Screen - Displays quiz completion results with animations, rewards, and navigation
//
// Features:
// - Animated score display with counting animation
// - Carbon footprint calculation based on quiz performance
// - Reward boxes with opening animations
// - Daily tasks update notification
// - Navigation to home or replay quiz

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/loot_box.dart';
import '../models/daily_challenge.dart';
import '../services/loot_box_service.dart';
import '../services/daily_task_event_service.dart';
import '../services/enhanced_reward_service.dart';
import '../services/firestore_service.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../widgets/loot_box_widget.dart';
import '../utils/loot_box_animations.dart';
import '../core/navigation/app_router.dart';
import '../widgets/page_templates.dart';

/// Class to handle all animations for QuizResultsPage
class QuizAnimations {
  late AnimationController scoreAnimationController;
  late AnimationController boxesAnimationController;
  late AnimationController celebrationController;
  late Animation<double> scoreScaleAnimation;
  late Animation<double> boxesFadeAnimation;
  late Animation<double> celebrationOpacityAnimation;

  int displayedScore = 0;

  QuizAnimations(TickerProvider vsync) {
    scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    boxesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    scoreScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: scoreAnimationController,
      curve: Curves.elasticOut,
    ));

    boxesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: boxesAnimationController,
      curve: Curves.easeInOut,
    ));

    celebrationOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: celebrationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
  }

  void startAnimations(VoidCallback onScoreComplete) {
    scoreAnimationController.forward().then((_) {
      _startScoreCounting(onScoreComplete);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      celebrationController.forward();
    });
  }

  void _startScoreCounting(VoidCallback onScoreComplete) {
    const steps = 60;
    final stepValue = displayedScore / steps; // This will be set later
    var currentStep = 0;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      currentStep++;
      if (currentStep >= steps) {
        displayedScore = displayedScore; // Already set
        timer.cancel();
        onScoreComplete();
      } else {
        displayedScore = (stepValue * currentStep).round();
      }
    });
  }

  void dispose() {
    scoreAnimationController.dispose();
    boxesAnimationController.dispose();
    celebrationController.dispose();
  }
}

class QuizResultsPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String category;
  final String difficulty;
  final int correctAnswers;

  const QuizResultsPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
    required this.correctAnswers,
  });

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> with TickerProviderStateMixin {
  final LootBoxService _lootBoxService = LootBoxService();
  final DailyTaskEventService _dailyTaskService = DailyTaskEventService();
  final EnhancedRewardService _rewardService = EnhancedRewardService();

  List<UserLootBox> _rewardBoxes = [];
  bool _isLoading = true;
  bool _dailyTasksUpdated = false;
  bool _rewardsGranted = false;
  String? _errorMessage;

  // Carbon footprint calculation
  double _carbonFootprint = 0.0;
  String _carbonFootprintCategory = '';

  // Animation controllers and animations
  late final QuizAnimations _animations;

  @override
  void initState() {
    super.initState();
    // Initialize animations
    _animations = QuizAnimations(this);
    _animations.displayedScore = widget.score;
    _animations.startAnimations(() {
      setState(() {});
      // Start boxes animation after score counting completes
      Future.delayed(const Duration(milliseconds: 300), () {
        _animations.boxesAnimationController.forward();
      });
    });

    // Initialize services and update data
    _initializeServices();
    _grantRewards();
    _updateDailyTasks();
    _calculateCarbonFootprint();
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      await Future.wait([
        _lootBoxService.initializeForUser(),
        _dailyTaskService.initialize(),
        _saveQuizScore(), // Skor kaydetme eklendi
      ]);
    } catch (e) {
      debugPrint('Error initializing services: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Servisler başlatılamadı: $e';
        });
      }
    }
  }

  Future<void> _saveQuizScore() async {
    try {
      // FirestoreService kullanarak skoru kaydet
      final firestoreService = FirestoreService();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final nickname = user.displayName ?? user.email?.split('@')[0] ?? 'Oyuncu';
        final result = await firestoreService.saveUserScore(nickname, widget.score);

        if (result != 'Skor kaydedildi!') {
          debugPrint('Skor kaydetme uyarısı: $result');
        } else {
          debugPrint('Skor başarıyla kaydedildi: ${widget.score}');
        }
      }
    } catch (e) {
      debugPrint('Skor kaydetme hatası: $e');
    }
  }

  Future<void> _grantRewards() async {
    if (_rewardsGranted) return;

    try {
      // Grant loot box based on quiz completion
      await _lootBoxService.onQuizCompleted(
        score: widget.score,
        isPerfect: widget.correctAnswers == widget.totalQuestions,
      );

      // Load the newly granted boxes
      final boxes = await _lootBoxService.getUnopenedBoxes();
      if (mounted) {
        setState(() {
          _rewardBoxes = boxes.where((box) =>
            box.boxType == LootBoxType.quiz &&
            box.obtainedAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1)))
          ).toList();
          _rewardsGranted = true;
        });
      }
    } catch (e) {
      debugPrint('Error granting rewards: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Ödüller verilemedi: $e';
        });
      }
    }
  }

  Future<void> _updateDailyTasks() async {
    if (_dailyTasksUpdated) return;

    try {
      await _dailyTaskService.onQuizCompleted(
        category: widget.category,
        score: widget.score,
        correctAnswers: widget.correctAnswers,
        difficulty: widget.difficulty,
      );
      if (mounted) {
        setState(() {
          _dailyTasksUpdated = true;
        });
      }
    } catch (e) {
      debugPrint('Error updating daily tasks: $e');
    }
  }

  void _calculateCarbonFootprint() {
    // Calculate carbon footprint based on quiz score
    // Assuming higher score means better environmental awareness (lower footprint)
    final percentage = widget.totalQuestions > 0 ? (widget.correctAnswers / widget.totalQuestions) : 0.0;
    _carbonFootprint = (100 - (percentage * 100)) * 0.1; // Example calculation

    if (_carbonFootprint < 2.0) {
      _carbonFootprintCategory = 'Çok Düşük';
    } else if (_carbonFootprint < 5.0) {
      _carbonFootprintCategory = 'Düşük';
    } else if (_carbonFootprint < 8.0) {
      _carbonFootprintCategory = 'Orta';
    } else {
      _carbonFootprintCategory = 'Yüksek';
    }
  }

  Future<void> _openRewardBox(UserLootBox box) async {
    try {
      final result = await _lootBoxService.openLootBox(box.id);

      if (result.success && result.rewards.isNotEmpty) {
        if (mounted) {
          showLootBoxOpeningDialog(
            context,
            lootBox: box,
            reward: result.rewards.first,
            onClose: () {
              Navigator.of(context).pop();
              // Refresh boxes list
              _refreshBoxes();
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Kutu açılamadı'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshBoxes() async {
    try {
      final boxes = await _lootBoxService.getUnopenedBoxes();
      if (mounted) {
        setState(() {
          _rewardBoxes = boxes.where((box) =>
            box.boxType == LootBoxType.quiz &&
            box.obtainedAt.isAfter(DateTime.now().subtract(const Duration(minutes: 5)))
          ).toList();
        });
      }
    } catch (e) {
      debugPrint('Error refreshing boxes: $e');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Quiz Sonuçları'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToHome,
            tooltip: 'Ana Sayfaya Dön',
          ),
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCelebrationOverlay(),
            const SizedBox(height: DesignSystem.spacingXl),
            _buildScoreDisplay(),
            const SizedBox(height: DesignSystem.spacingXl),
            _buildCarbonFootprintDisplay(),
            const SizedBox(height: DesignSystem.spacingXl),
            _buildRewardBoxesSection(),
            const SizedBox(height: DesignSystem.spacingXl),
            _buildDailyTasksIndicator(),
            const SizedBox(height: DesignSystem.spacingXl),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _animations.celebrationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animations.celebrationOpacityAnimation.value,
          child: const Center(
            child: Icon(
              Icons.celebration,
              size: 100,
              color: Colors.yellow,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreDisplay() {
    final percentage = widget.totalQuestions > 0 ? (widget.correctAnswers / widget.totalQuestions * 100) : 0.0;

    return AnimatedBuilder(
      animation: _animations.scoreAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _animations.scoreScaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacingXl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getSuccessColor(context).withOpacity(0.2),
                  ThemeColors.getSuccessColor(context).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              border: Border.all(
                color: ThemeColors.getSuccessColor(context).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Tebrikler!',
                  style: AppTheme.getGameQuestionStyle(context).copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spacingL),
                Text(
                  '${_animations.displayedScore} / ${widget.totalQuestions}',
                  style: AppTheme.getGameScoreStyle(context).copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spacingM),
                Text(
                  '${percentage.toStringAsFixed(1)}% Başarı',
                  style: DesignSystem.getTitleMedium(context).copyWith(
                    color: ThemeColors.getTitleColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spacingS),
                Text(
                  '${widget.correctAnswers} doğru, ${widget.totalQuestions - widget.correctAnswers} yanlış',
                  style: DesignSystem.getBodyMedium(context).copyWith(
                    color: ThemeColors.getSecondaryText(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarbonFootprintDisplay() {
    return FadeTransition(
      opacity: _animations.celebrationController,
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacingXl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.2),
              Colors.green.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.eco,
                  color: Colors.green,
                  size: 32,
                ),
                const SizedBox(width: DesignSystem.spacingM),
                Text(
                  'Karbon Ayak İzi',
                  style: AppTheme.getGameQuestionStyle(context).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacingL),
            Text(
              '${_carbonFootprint.toStringAsFixed(1)} ton CO₂/ yıl',
              style: AppTheme.getGameScoreStyle(context).copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingM,
                vertical: DesignSystem.spacingS,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: Text(
                _carbonFootprintCategory,
                style: DesignSystem.getTitleMedium(context).copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DesignSystem.spacingM),
            Text(
              'Çevre bilinciniz arttıkça karbon ayak iziniz azalır!',
              style: DesignSystem.getBodyMedium(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardBoxesSection() {
    return AnimatedBuilder(
      animation: _animations.boxesAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animations.boxesFadeAnimation.value,
          child: Column(
            children: [
              Text(
                'Kazanılan Ödüller',
                style: DesignSystem.getHeadlineSmall(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingL),

              if (_rewardBoxes.isNotEmpty) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: DesignSystem.spacingM,
                    mainAxisSpacing: DesignSystem.spacingM,
                  ),
                  itemCount: _rewardBoxes.length,
                  itemBuilder: (context, index) {
                    final box = _rewardBoxes[index];
                    return _buildRewardBoxItem(box, index);
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spacingXl),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardBackground(context).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: ThemeColors.getSecondaryText(context),
                      ),
                      const SizedBox(height: DesignSystem.spacingM),
                      Text(
                        'Ödül kutuları yükleniyor...',
                        style: DesignSystem.getBodyMedium(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyTasksIndicator() {
    if (!_dailyTasksUpdated) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.task_alt,
            color: Colors.blue,
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Text(
              'Günlük görevleriniz güncellendi!',
              style: DesignSystem.getBodyMedium(context).copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _navigateToHome,
            icon: const Icon(Icons.home, color: Colors.white),
            label: const Text('Ana Sayfa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getPrimaryButtonColor(context),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingM,
                vertical: DesignSystem.spacingM,
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignSystem.spacingM),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.quiz);
            },
            icon: const Icon(Icons.replay),
            label: const Text('Tekrar Oyna'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: ThemeColors.getPrimaryButtonColor(context),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingM,
                vertical: DesignSystem.spacingM,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardBoxItem(UserLootBox box, int index) {
    return AnimatedBuilder(
      animation: _animations.boxesAnimationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animations.boxesAnimationController,
          curve: Interval(delay, delay + 0.5, curve: Curves.elasticOut),
        ));

        return Transform.scale(
          scale: animation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              side: BorderSide(
                color: LootBoxColors.getRarityColor(box.rarity).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: InkWell(
              onTap: () => _openRewardBox(box),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LootBoxWidget(
                    lootBox: box,
                    size: 60,
                    onTap: () => _openRewardBox(box),
                    showRarityBadge: true,
                  ),
                  const SizedBox(height: DesignSystem.spacingS),
                  Text(
                    box.rarityName,
                    style: DesignSystem.getBodySmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: LootBoxColors.getRarityColor(box.rarity),
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacingXs),
                  Text(
                    'Açmak için dokun',
                    style: DesignSystem.getBodySmall(context).copyWith(
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}