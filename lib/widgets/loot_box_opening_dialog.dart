// lib/widgets/loot_box_opening_dialog.dart
// Loot Box Opening Dialog - Kutu Açma Diyalog Widget'ı

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/loot_box.dart';
import '../models/loot_box_reward.dart';
import '../utils/loot_box_animations.dart';

/// Loot box opening dialog widget
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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late AudioPlayer _audioPlayer;

  bool _showReward = false;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
    ]).animate(_animationController);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    // Play opening sound
    _playOpeningSound();

    // Start animation sequence
    _animationController.forward().then((_) {
      setState(() {
        _showReward = true;
      });
      // Play reveal sound
      _playRevealSound();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playOpeningSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/lootbox_open.mp3'));
    } catch (e) {
      // Sound file may not exist, ignore
    }
  }

  Future<void> _playRevealSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/reward_reveal.mp3'));
    } catch (e) {
      // Sound file may not exist, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = LootBoxAnimationParams.forRarity(widget.lootBox.rarity);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LootBoxColors.getRarityColor(widget.lootBox.rarity).withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Background effects
            Positioned.fill(
              child: ParticleWidget(
                rarity: widget.lootBox.rarity,
                particleCount: params.particleCount,
                duration: Duration(milliseconds: params.particleDuration.inMilliseconds),
                particleType: ParticleType.sparkle,
                isEmitting: !_showReward,
              ),
            ),

            // Confetti for high rarity
            if (widget.lootBox.rarity == LootBoxRarity.legendary ||
                widget.lootBox.rarity == LootBoxRarity.mythic)
              Positioned.fill(
                child: ConfettiWidget(
                  rarity: widget.lootBox.rarity,
                  particleCount: params.confettiCount,
                  duration: const Duration(milliseconds: 3000),
                ),
              ),

            // Ring burst effect
            Positioned.fill(
              child: RingBurstWidget(
                rarity: widget.lootBox.rarity,
                duration: const Duration(milliseconds: 800),
                maxRadius: 150,
                ringCount: 3,
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Loot box icon with animation
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: GlowWidget(
                          glowColor: LootBoxColors.getRarityColor(widget.lootBox.rarity),
                          glowIntensity: params.glowIntensity,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: LootBoxColors.getRarityColor(widget.lootBox.rarity).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: LootBoxColors.getRarityColor(widget.lootBox.rarity),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              size: 60,
                              color: LootBoxColors.getRarityColor(widget.lootBox.rarity),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Reward reveal
                  if (_showReward)
                    AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: Column(
                            children: [
                              // Reward icon with effects
                              GlowWidget(
                                glowColor: LootBoxColors.getRarityColor(widget.reward.reward.rarity),
                                glowIntensity: 1.5,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: LootBoxColors.getRarityColor(widget.reward.reward.rarity).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: LootBoxColors.getRarityColor(widget.reward.reward.rarity),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _getRewardIcon(widget.reward.reward.contentType),
                                    size: 50,
                                    color: LootBoxColors.getRarityColor(widget.reward.reward.rarity),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Reward text
                              Text(
                                widget.reward.reward.rewardText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: LootBoxColors.getRarityColor(widget.reward.reward.rarity),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 10),

                              // Rarity badge
                              RarityBadge(
                                rarity: widget.reward.reward.rarity,
                                text: widget.reward.reward.rarityName,
                                fontSize: 16,
                              ),

                              const SizedBox(height: 20),

                              // New/Duplicate indicator
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: widget.reward.isNew
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
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
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40),

                  // Close button
                  if (_showReward)
                    ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LootBoxColors.getRarityColor(widget.lootBox.rarity),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Devam Et',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            // Close button in top right
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRewardIcon(LootBoxContentType contentType) {
    switch (contentType) {
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
      default:
        return Icons.help;
      }
  }
}

/// Show loot box opening dialog
void showLootBoxOpeningDialog(
  BuildContext context, {
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