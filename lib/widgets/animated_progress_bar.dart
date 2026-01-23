// lib/widgets/animated_progress_bar.dart
// Animated progress bar with smooth transitions and visual effects

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/theme_colors.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final double minHeight;
  final Duration animationDuration;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final bool enablePulse;
  final Curve curve;
  final BorderRadius? borderRadius;
  final bool shimmerEnabled;
  final Color? shimmerColor;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.animationDuration = const Duration(milliseconds: 500),
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
    this.enablePulse = true,
    this.curve = Curves.easeOutCubic,
    this.borderRadius,
    this.shimmerEnabled = false,
    this.shimmerColor,
  }) : assert(value >= 0 && value <= 1, 'Value must be between 0 and 1');

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _pulseTimer;
  int _pulseCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curve,
    ));

    // Pulse animation for when progress changes significantly
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_animationController);

    // Start initial animation
    _animationController.forward();

    // Start pulse timer for progress updates
    if (widget.enablePulse) {
      _startPulseTimer();
    }
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation when value changes
    if (oldWidget.value != widget.value) {
      _animationController.reset();
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ));
      _animationController.forward();

      // Reset pulse count for new progress
      _pulseCount = 0;
    }
  }

  void _startPulseTimer() {
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && widget.enablePulse) {
        setState(() {
          _pulseCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = theme.colorScheme.surfaceVariant;
    final defaultProgressColor = _getProgressColor(theme);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final pulseScale = _pulseAnimation.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showPercentage)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: defaultProgressColor,
                  ),
                ),
              ),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final progressWidth = maxWidth * progress;

                return Container(
                  height: widget.minHeight * pulseScale,
                  width: maxWidth,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? defaultBackgroundColor,
                    borderRadius: widget.borderRadius ??
                        BorderRadius.circular(widget.minHeight / 2),
                  ),
                  child: ClipRRect(
                    borderRadius: widget.borderRadius ??
                        BorderRadius.circular(widget.minHeight / 2),
                    child: Stack(
                      children: [
                        // Main progress bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: widget.animationDuration,
                            curve: widget.curve,
                            width: progressWidth.clamp(0, maxWidth),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: _getGradientColors(
                                  defaultProgressColor,
                                  progress,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: defaultProgressColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Shimmer effect
                        if (widget.shimmerEnabled)
                          _ShimmerEffect(
                            progress: progress,
                            color: widget.shimmerColor ??
                                defaultProgressColor.withValues(alpha: 0.3),
                            animationController: _animationController,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Color _getProgressColor(ThemeData theme) {
    if (widget.progressColor != null) {
      return widget.progressColor!;
    }

    // Color based on progress value
    if (widget.value < 0.3) {
      return Colors.red;
    } else if (widget.value < 0.6) {
      return Colors.orange;
    } else if (widget.value < 0.9) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  List<Color> _getGradientColors(Color baseColor, double progress) {
    // Create gradient based on progress
    final lightenFactor = (1 - progress) * 0.3;
    final darkerColor = baseColor;
    final lighterColor = Color.lerp(
      baseColor,
      Colors.white,
      lightenFactor,
    )!;

    return [
      darkerColor,
      lighterColor,
    ];
  }
}

/// Shimmer effect for animated progress bar
class _ShimmerEffect extends StatefulWidget {
  final double progress;
  final Color color;
  final AnimationController animationController;

  const _ShimmerEffect({
    required this.progress,
    required this.color,
    required this.animationController,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> {
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerAnimation = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.linear,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned(
          left: widget.progress * MediaQuery.of(context).size.width +
              _shimmerAnimation.value * 200 -
              100,
          top: 0,
          bottom: 0,
          width: 100,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color.withValues(alpha: 0),
                    widget.color.withValues(alpha: 0.5),
                    widget.color.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Achievement progress widget with real-time updates
class AchievementProgressWidget extends StatefulWidget {
  final String title;
  final String description;
  final String icon;
  final int currentValue;
  final int targetValue;
  final Color color;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementProgressWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentValue,
    required this.targetValue,
    this.color = Colors.blue,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  State<AchievementProgressWidget> createState() =>
      _AchievementProgressWidgetState();
}

class _AchievementProgressWidgetState extends State<AchievementProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.currentValue;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_scaleController);

    _progressAnimation = Tween<double>(
      begin: 0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AchievementProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentValue != widget.currentValue) {
      // Trigger scale animation when progress changes
      _scaleController.reset();
      _scaleController.forward();

      // Animate progress bar
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getProgressValue(),
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutCubic,
      ));
    }
  }

  double _getProgressValue() {
    if (widget.targetValue == 0) return 0;
    return (widget.currentValue / widget.targetValue).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgressValue();
    final isCompleted = progress >= 1.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _progressAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Card(
        elevation: isCompleted ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCompleted ? widget.color : Colors.grey.shade300,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isCompleted
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon with glow effect
                    _buildIcon(isCompleted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted
                                          ? widget.color
                                          : Colors.grey[700],
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Status indicator
                    _buildStatusIndicator(isCompleted),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                AnimatedProgressBar(
                  value: progress,
                  minHeight: 10,
                  animationDuration: const Duration(milliseconds: 500),
                  showPercentage: true,
                  enablePulse: !isCompleted,
                  progressColor: isCompleted ? widget.color : null,
                  shimmerEnabled: !isCompleted,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                // Progress text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.currentValue} / ${widget.targetValue}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (isCompleted)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: widget.color,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tamamlandı!',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: widget.color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
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

  Widget _buildIcon(bool isCompleted) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? widget.color.withValues(alpha: 0.2)
            : Colors.grey.shade200,
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          widget.icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'TAMAM',
          style: TextStyle(
            color: ThemeColors.getTextOnColoredBackground(context),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Icon(
      Icons.lock_outline,
      color: Colors.grey.shade400,
      size: 20,
    );
  }
}

/// Real-time progress panel for achievements during gameplay
class RealTimeProgressPanel extends StatelessWidget {
  final Map<String, int> currentProgress;
  final Map<String, int> targetValues;
  final Color color;
  final VoidCallback? onAchievementTap;
  final VoidCallback? onViewAllTap;

  const RealTimeProgressPanel({
    super.key,
    required this.currentProgress,
    required this.targetValues,
    this.color = Colors.blue,
    this.onAchievementTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeAchievements = _getActiveAchievements();

    if (activeAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Başarım İlerlemesi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
                if (onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: Text(
                      'Tümünü Gör',
                      style: TextStyle(color: color),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ...activeAchievements.map((achievement) {
              final progress = currentProgress[achievement] ?? 0;
              final target = targetValues[achievement] ?? 1;
              final percentage = (progress / target).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildProgressItem(
                  context,
                  achievement,
                  progress,
                  target,
                  percentage,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<String> _getActiveAchievements() {
    return currentProgress.entries
        .where((e) => e.value < (targetValues[e.key] ?? 1))
        .map((e) => e.key)
        .toList();
  }

  Widget _buildProgressItem(
    BuildContext context,
    String achievement,
    int current,
    int target,
    double percentage,
  ) {
    final title = _getAchievementTitle(achievement);
    final icon = _getAchievementIcon(achievement);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              AnimatedProgressBar(
                value: percentage,
                minHeight: 6,
                animationDuration: const Duration(milliseconds: 300),
                progressColor: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$target',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  String _getAchievementTitle(String key) {
    final titles = {
      'completedQuizzes': 'Quiz',
      'duelWins': 'Düello',
      'multiplayerWins': 'Çok Oyunculu',
      'friendsCount': 'Arkadaşlar',
      'loginStreak': 'Seri',
    };
    return titles[key] ?? key;
  }

  String _getAchievementIcon(String key) {
    final icons = {
      'completedQuizzes': '🧠',
      'duelWins': '⚔️',
      'multiplayerWins': '🤝',
      'friendsCount': '👥',
      'loginStreak': '🔥',
    };
    return icons[key] ?? '🏆';
  }
}

