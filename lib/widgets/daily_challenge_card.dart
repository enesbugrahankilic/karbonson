// lib/widgets/daily_challenge_card.dart
// Daily challenge card widget for displaying challenges with animations

import 'package:flutter/material.dart';
import '../models/daily_challenge.dart';

class DailyChallengeCard extends StatefulWidget {
  final DailyChallenge challenge;
  final VoidCallback? onTap;

  const DailyChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
  });

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.challenge.progressPercentage,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(DailyChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.progressPercentage != widget.challenge.progressPercentage) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.challenge.progressPercentage,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.challenge.isCompleted;
    final isExpired = widget.challenge.isExpired;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: isCompleted ? 8 : 4,
            color: _getCardColor(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _getBorderColor(),
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
                          colors: [
                            _getCardColor().withOpacity( 0.8),
                            _getCardColor().withOpacity( 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.challenge.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isExpired && !isCompleted
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                        _buildStatusIcon(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.challenge.description,
                      style: TextStyle(
                        color: isExpired && !isCompleted
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedProgressBar(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.challenge.currentValue}/${widget.challenge.targetValue}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpired && !isCompleted
                                ? Colors.grey
                                : Colors.black54,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.challenge.rewardPoints}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isExpired && !isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Süre doldu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tamamlandı!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon() {
    final isCompleted = widget.challenge.isCompleted;
    final isExpired = widget.challenge.isExpired;

    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity( 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      );
    } else if (isExpired) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity( 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.timer_off,
          color: Colors.red,
          size: 20,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity( 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.access_time,
          color: Colors.orange,
          size: 20,
        ),
      );
    }
  }

  Widget _buildAnimatedProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: _progressAnimation.value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
        ),
      ),
    );
  }

  Color _getCardColor() {
    if (widget.challenge.isCompleted) {
      return Colors.green.shade50;
    } else if (widget.challenge.isExpired) {
      return Colors.red.shade50;
    } else {
      return Colors.white;
    }
  }

  Color _getBorderColor() {
    if (widget.challenge.isCompleted) {
      return Colors.green.shade300;
    } else if (widget.challenge.isExpired) {
      return Colors.red.shade300;
    } else {
      return Colors.blue.shade200;
    }
  }

  Color _getProgressColor() {
    if (widget.challenge.isCompleted) {
      return Colors.green;
    } else if (widget.challenge.isExpired) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
