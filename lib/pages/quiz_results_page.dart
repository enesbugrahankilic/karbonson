// lib/pages/quiz_results_page.dart
// Quiz Results Screen - Displays score, reward boxes, updates daily tasks, and navigation

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/loot_box.dart';
import '../models/daily_challenge.dart';
import '../services/loot_box_service.dart';
import '../services/daily_task_event_service.dart';
import '../services/enhanced_reward_service.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../widgets/loot_box_widget.dart';
import '../utils/loot_box_animations.dart';
import '../core/navigation/app_router.dart';

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

  // Animation controllers
  late AnimationController _scoreAnimationController;
  late AnimationController _boxesAnimationController;
  late AnimationController _celebrationController;
  late Animation<double> _scoreScaleAnimation;
  late Animation<double> _boxesFadeAnimation;
  late Animation<double> _celebrationOpacityAnimation;

  // Animation values
  double _scoreDisplay = 0;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
    _grantRewards();
    _updateDailyTasks();
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _boxesAnimationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _boxesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scoreScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.elasticOut,
    ));

    _boxesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _boxesAnimationController,
      curve: Curves.easeInOut,
    ));

    _celebrationOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    // Start score animation
    _scoreAnimationController.forward().then((_) {
      _startScoreCounting();
    });

    // Start celebration animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _celebrationController.forward();
    });
  }

  void _startScoreCounting() {
    const duration = Duration(milliseconds: 1000);
    const steps = 60;
    final stepValue = widget.score / steps;
    var currentStep = 0;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      currentStep++;
      if (currentStep >= steps) {
        setState(() {
          _displayedScore = widget.score;
        });
        timer.cancel();
        // Start boxes animation after score counting
        Future.delayed(const Duration(milliseconds: 300), () {
          _boxesAnimationController.forward();
        });
      } else {
        setState(() {
          _displayedScore = (stepValue * currentStep).round();
        });
      }
    });
  }

  Future<void> _initializeServices() async {
    try {
      await _lootBoxService.initializeForUser();
      await _dailyTaskService.initialize();
    } catch (e) {
      debugPrint('Error initializing services: $e');
      setState(() {
        _errorMessage = 'Servisler başlatılamadı: $e';
      });
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
      setState(() {
        _rewardBoxes = boxes.where((box) =>
          box.boxType == LootBoxType.quiz &&
          box.obtainedAt.isAfter(DateTime.now().subtract(const Duration(minutes: 1)))
        ).toList();
        _rewardsGranted = true;
      });
    } catch (e) {
      debugPrint('Error granting rewards: $e');
      setState(() {
        _errorMessage = 'Ödüller verilemedi: $e';
      });
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
      setState(() {
        _dailyTasksUpdated = true;
      });
    } catch (e) {
      debugPrint('Error updating daily tasks: $e');
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
    final percentage = widget.totalQuestions > 0 ? (widget.correctAnswers / widget.totalQuestions * 100) : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Quiz Sonuçları',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: DesignSystem.spacingS),
            decoration: BoxDecoration(
              color: ThemeColors.getSuccessColor(context).withOpacity(0.8),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: _navigateToHome,
              tooltip: 'Ana Sayfaya Dön',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Celebration animation overlay
                AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _celebrationOpacityAnimation.value,
                      child: const Center(
                        child: Icon(
                          Icons.celebration,
                          size: 100,
                          color: Colors.yellow,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: DesignSystem.spacingXl),

                // Score display with animation
                AnimatedBuilder(
                  animation: _scoreAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scoreScaleAnimation.value,
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
                              '$_displayedScore / ${widget.totalQuestions}',
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
                ),

                const SizedBox(height: DesignSystem.spacingXl),

                // Reward boxes section
                AnimatedBuilder(
                  animation: _boxesAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _boxesFadeAnimation.value,
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
                ),

                const SizedBox(height: DesignSystem.spacingXl),

                // Daily tasks update indicator
                if (_dailyTasksUpdated)
                  Container(
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
                  ),

                const SizedBox(height: DesignSystem.spacingXl),

                // Navigation buttons
                Row(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardBoxItem(UserLootBox box, int index) {
    return AnimatedBuilder(
      animation: _boxesAnimationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _boxesAnimationController,
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