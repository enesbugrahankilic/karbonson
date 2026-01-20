// Loot Box Opening Dialog - Ödül Kutusu Açılma Dialog'u

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/loot_box.dart';
import '../models/loot_box_reward.dart';
import '../utils/loot_box_animations.dart';

/// Ödül kutusu açılma dialog'u
class LootBoxOpeningDialog extends StatefulWidget {
  final UserLootBox lootBox;
  final OpenedReward reward;
  final VoidCallback onClose;

  const LootBoxOpeningDialog({
    super.key,
    required this.lootBox,
    required this.reward,
    required this.onClose,
  });

  @override
  State<LootBoxOpeningDialog> createState() => _LootBoxOpeningDialogState();
}

class _LootBoxOpeningDialogState extends State<LootBoxOpeningDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _boxShakeController;
  late AnimationController _boxOpenController;
  late AnimationController _rewardRevealController;
  late AnimationController _particleController;
  
  late Animation<double> _boxScaleAnimation;
  late Animation<double> _boxOpacityAnimation;
  late Animation<double> _rewardScaleAnimation;
  late Animation<double> _rewardOpacityAnimation;
  late Animation<Offset> _rewardPositionAnimation;
  
  bool _showReward = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startOpeningSequence();
  }

  void _initializeAnimations() {
    final params = LootBoxAnimationParams.forRarity(widget.lootBox.rarity);

    // Main controller for overall animation timing
    _mainController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: params.openDuration.inMilliseconds + 1500),
    );

    // Box shake controller
    _boxShakeController = AnimationController(
      vsync: this,
      duration: params.shakeDuration,
    );

    // Box open controller (scale down and fade)
    _boxOpenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Reward reveal controller
    _rewardRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: params.particleDuration,
    );

    // Box scale animation (pulse during shake)
    _boxScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.15).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_mainController);

    // Box opacity animation
    _boxOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
    ));

    // Reward scale animation (bounce in)
    _rewardScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
    ]).animate(_rewardRevealController);

    // Reward opacity animation
    _rewardOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardRevealController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    // Reward position animation (slide up from bottom)
    _rewardPositionAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _rewardRevealController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _startOpeningSequence() async {
    // Start shake animation
    await _boxShakeController.forward();
    _boxShakeController.reset();
    
    // Continue main animation
    _mainController.forward();
    
    // Start particle emission
    _particleController.forward();

    // Wait for box to open, then show reward
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() => _showReward = true);
      _rewardRevealController.forward();
    }

    // Wait for reveal to complete
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() => _animationComplete = true);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _boxShakeController.dispose();
    _boxOpenController.dispose();
    _rewardRevealController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Color get _rarityColor => LootBoxColors.getRarityColor(widget.lootBox.rarity);
  LootBoxAnimationParams get _params => LootBoxAnimationParams.forRarity(widget.lootBox.rarity);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _rarityColor.withOpacity(0.15),
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _rarityColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            Positioned.fill(
              child: ParticleWidget(
                rarity: widget.lootBox.rarity,
                particleCount: _params.particleCount,
                duration: _params.particleDuration,
                isEmitting: !_showReward,
              ),
            ),

            // Confetti for high rarity
            if (widget.lootBox.rarity == LootBoxRarity.legendary ||
                widget.lootBox.rarity == LootBoxRarity.mythic)
              Positioned.fill(
                child: ConfettiWidget(
                  rarity: widget.lootBox.rarity,
                  particleCount: _params.confettiCount,
                  duration: const Duration(milliseconds: 3000),
                ),
              ),

            // Ring burst effect
            Positioned.fill(
              child: RingBurstWidget(
                rarity: widget.lootBox.rarity,
                duration: const Duration(milliseconds: 800),
                maxRadius: 200,
                ringCount: 3,
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Box opening animation
                  _buildBoxAnimation(),

                  const SizedBox(height: 40),

                  // Reward reveal animation
                  if (_showReward) _buildRewardReveal(),
                ],
              ),
            ),

            // Close button (appears after animation)
            if (_animationComplete)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildCloseButton(),
                ),
              ),

            // Top close button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white70),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _boxShakeController,
      ]),
      builder: (context, child) {
        final shakeValue = _boxShakeController.value;
        final scaleValue = _boxScaleAnimation.value;
        final opacityValue = _boxOpacityAnimation.value;

        // Calculate shake offset
        final shakeOffset = _calculateShakeOffset(shakeValue);

        return Transform.translate(
          offset: shakeOffset,
          child: Transform.scale(
            scale: scaleValue,
            child: Opacity(
              opacity: opacityValue,
              child: GlowWidget(
                glowColor: _rarityColor,
                glowIntensity: _params.glowIntensity,
                blurRadius: 30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _rarityColor.withOpacity(0.4),
                        _rarityColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _rarityColor,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _rarityColor.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    size: 70,
                    color: _rarityColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _calculateShakeOffset(double progress) {
    if (progress == 0) return Offset.zero;

    final intensity = _params.shakeIntensity;
    final frequency = 20.0;
    final decay = 1 - progress;

    final x = math.sin(progress * frequency * 2 * math.pi) * intensity * decay;
    final y = math.cos(progress * frequency * 2 * math.pi) * intensity * 0.5 * decay;

    return Offset(x, y);
  }

  Widget _buildRewardReveal() {
    final rewardColor = LootBoxColors.getRarityColor(widget.reward.reward.rarity);
    final isHighRarity = widget.reward.reward.rarity == LootBoxRarity.legendary ||
        widget.reward.reward.rarity == LootBoxRarity.mythic;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _rewardRevealController,
        _rewardScaleAnimation,
        _rewardOpacityAnimation,
        _rewardPositionAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _rewardPositionAnimation,
          child: FadeTransition(
            opacity: _rewardOpacityAnimation,
            child: ScaleTransition(
              scale: _rewardScaleAnimation,
              child: Column(
                children: [
                  // Reward icon with glow
                  GlowWidget(
                    glowColor: rewardColor,
                    glowIntensity: 1.5,
                    blurRadius: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            rewardColor.withOpacity(0.3),
                            rewardColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rewardColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        _getRewardIcon(),
                        size: 60,
                        color: rewardColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reward name
                  Text(
                    widget.reward.reward.rewardText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: rewardColor,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Rarity badge
                  RarityBadge(
                    rarity: widget.reward.reward.rarity,
                    text: widget.reward.reward.rarityName,
                    fontSize: 14,
                  ),

                  const SizedBox(height: 16),

                  // New/Duplicate indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.reward.isNew
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: widget.reward.isNew ? Colors.green : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.reward.isNew ? 'Yeni Ödül!' : 'Tekrar Kazanıldı',
                      style: TextStyle(
                        color: widget.reward.isNew ? Colors.green : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Shimmer effect for high rarity
                  if (isHighRarity) ...[
                    const SizedBox(height: 20),
                    ShimmerWidget(
                      shimmerColor: rewardColor,
                      intensity: 0.7,
                      child: Text(
                        _getRarityCelebration(),
                        style: TextStyle(
                          color: rewardColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return ElevatedButton(
      onPressed: widget.onClose,
      style: ElevatedButton.styleFrom(
        backgroundColor: _rarityColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: const Text(
        'Devam Et',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getRewardIcon() {
    switch (widget.reward.reward.contentType) {
      case LootBoxContentType.points:
        return Icons.monetization_on;
      case LootBoxContentType.avatar:
        return Icons.person;
      case LootBoxContentType.theme:
        return Icons.palette;
      case LootBoxContentType.feature:
        return Icons.star;
      case LootBoxContentType.badge:
        return Icons.verified;
      case LootBoxContentType.title:
        return Icons.title;
      case LootBoxContentType.item:
        return Icons.inventory;
    }
  }

  String _getRarityCelebration() {
    switch (widget.reward.reward.rarity) {
      case LootBoxRarity.legendary:
        return 'EFSANEVİ!';
      case LootBoxRarity.mythic:
        return 'MİTOLOJİK!';
      default:
        return '';
    }
  }
}

/// Show loot box opening dialog
void showLootBoxOpeningDialog({
  required BuildContext context,
  required UserLootBox lootBox,
  required OpenedReward reward,
  required VoidCallback onClose,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return LootBoxOpeningDialog(
        lootBox: lootBox,
        reward: reward,
        onClose: onClose,
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
        child: child,
      );
    },
  );
}
</parameter>
<parameter name="path">/Users/omer/karbonson/lib/widgets/loot_box_opening_dialog.dart</parameter>
