// lib/widgets/loot_box_widget.dart
// Loot Box Widget - Tıklanabilir Ödül Kutusu Widget'ı

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/loot_box.dart';
import '../utils/loot_box_animations.dart';

/// Tıklanabilir loot box widget'ı
class LootBoxWidget extends StatefulWidget {
  final UserLootBox lootBox;
  final double size;
  final VoidCallback onTap;
  final bool isLoading;
  final bool showRarityBadge;
  final String? customIcon;

  const LootBoxWidget({
    super.key,
    required this.lootBox,
    this.size = 100,
    required this.onTap,
    this.isLoading = false,
    this.showRarityBadge = true,
    this.customIcon,
  });

  @override
  State<LootBoxWidget> createState() => _LootBoxWidgetState();
}

class _LootBoxWidgetState extends State<LootBoxWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late AnimationController _hoverController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Shake animation controller
    _shakeController = AnimationController(
      vsync: this,
      duration: LootBoxAnimationParams.forRarity(widget.lootBox.rarity).shakeDuration,
    );

    // Glow pulse controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Hover scale controller
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading) return;

    // Play shake animation
    await _shakeController.forward();
    _shakeController.reset();

    // Trigger callback
    widget.onTap();
  }

  Color get _rarityColor => LootBoxColors.getRarityColor(widget.lootBox.rarity);
  Color get _rarityGlowColor => LootBoxColors.getRarityGlowColor(widget.lootBox.rarity);
  LootBoxAnimationParams get _params => LootBoxAnimationParams.forRarity(widget.lootBox.rarity);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_shakeController, _glowController, _hoverController]),
          builder: (context, child) {
            final shakeValue = _shakeController.value;
            final glowValue = _glowController.value;
            final hoverValue = _hoverController.value;

            // Calculate shake offset
            final shakeOffset = _calculateShakeOffset(shakeValue);
            
            // Calculate scale
            final scale = 1.0 + (hoverValue * 0.05) - (_isPressed ? 0.05 : 0.0);
            
            // Calculate glow intensity
            final glowIntensity = _params.glowIntensity * (0.8 + glowValue * 0.4);

            return Transform.translate(
              offset: shakeOffset,
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Glow effect
                    _buildGlowEffect(glowIntensity),
                    
                    // Box container
                    _buildBoxContainer(glowIntensity),
                    
                    // Rarity badge
                    if (widget.showRarityBadge) _buildRarityBadge(),
                    
                    // Loading indicator
                    if (widget.isLoading) _buildLoadingIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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

  Widget _buildGlowEffect(double glowIntensity) {
    return Center(
      child: Container(
        width: widget.size + 20 * glowIntensity,
        height: widget.size + 20 * glowIntensity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _rarityGlowColor.withOpacity(0.6 * glowIntensity),
              blurRadius: 30 * glowIntensity,
              spreadRadius: 5 * glowIntensity,
            ),
            BoxShadow(
              color: _rarityGlowColor.withOpacity(0.3 * glowIntensity),
              blurRadius: 50 * glowIntensity,
              spreadRadius: 10 * glowIntensity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxContainer(double glowIntensity) {
    final isHighRarity = widget.lootBox.rarity == LootBoxRarity.legendary ||
        widget.lootBox.rarity == LootBoxRarity.mythic;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _rarityColor.withOpacity(0.3),
            _rarityColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _rarityColor.withOpacity(0.8),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Box content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  _getBoxIcon(),
                  size: widget.size * 0.45,
                  color: _rarityColor,
                ),
                const SizedBox(height: 8),
                // Type text
                Text(
                  widget.lootBox.boxTypeName.split(' ').first,
                  style: TextStyle(
                    color: _rarityColor.withOpacity(0.8),
                    fontSize: widget.size * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Shimmer effect for high rarity
          if (isHighRarity)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildShimmerEffect(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ShimmerPainter(
            progress: _glowController.value,
            color: _rarityColor,
          ),
        );
      },
    );
  }

  Widget _buildRarityBadge() {
    return Positioned(
      top: -8,
      right: -8,
      child: RarityBadge(
        rarity: widget.lootBox.rarity,
        fontSize: 10,
        showIcon: true,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getBoxIcon() {
    if (widget.customIcon != null) {
      // Return custom icon if provided
      return Icons.inbox;
    }

    switch (widget.lootBox.boxType) {
      case LootBoxType.quiz:
        return Icons.quiz;
      case LootBoxType.daily:
        return Icons.calendar_today;
      case LootBoxType.achievement:
        return Icons.emoji_events;
      case LootBoxType.challenge:
        return Icons.workspace_premium;
      case LootBoxType.returnReward:
        return Icons.replay;
      case LootBoxType.seasonal:
        Icons.ac_unit; // Seasonal icon
      case LootBoxType.login:
        return Icons.login;
      case LootBoxType.special:
        return Icons.star;
      case LootBoxType.premium:
        return Icons.diamond;
    }
    return Icons.inbox;
  }
}

/// Shimmer effect painter for high rarity boxes
class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (0.5 + progress * 0.5))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw diagonal shimmer line
    final startX = -size.width * progress;
    final endX = size.width * (1 + progress);
    
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    for (double i = -size.height; i < size.height * 2; i += 20) {
      canvas.drawLine(
        Offset(startX, i),
        Offset(endX, i + size.height),
        paint,
      );
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== LOOT BOX OPEN BUTTON ====================

/// Loot box açma butonu - animasyonlu buton
class LootBoxOpenButton extends StatefulWidget {
  final UserLootBox lootBox;
  final double size;
  final Future<void> Function() onOpen;
  final Widget? child;
  final String? label;

  const LootBoxOpenButton({
    super.key,
    required this.lootBox,
    this.size = 120,
    required this.onOpen,
    this.child,
    this.label,
  });

  @override
  State<LootBoxOpenButton> createState() => _LootBoxOpenButtonState();
}

class _LootBoxOpenButtonState extends State<LootBoxOpenButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isLoading = false;
  bool _isOpened = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading || _isOpened) return;

    setState(() => _isLoading = true);

    try {
      // Play opening animation
      await _controller.forward();
      
      // Open the box
      await widget.onOpen();

      if (mounted) {
        setState(() {
          _isOpened = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = LootBoxColors.getRarityColor(widget.lootBox.rarity);
    final params = LootBoxAnimationParams.forRarity(widget.lootBox.rarity);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final glow = _glowAnimation.value;

        return GestureDetector(
          onTap: _handleTap,
          child: Transform.scale(
            scale: scale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Glow background
                if (scale > 0.5)
                  Container(
                    width: widget.size + 30 * glow,
                    height: widget.size + 30 * glow,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withOpacity(0.5 * glow),
                          blurRadius: 30 * glow,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                
                // Main button
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        rarityColor.withOpacity(0.4),
                        rarityColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: rarityColor,
                      width: 4,
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : _isOpened
                          ? const Center(
                              child: Icon(
                                Icons.check_circle,
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: widget.size * 0.4,
                                  color: rarityColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.label ?? 'Aç',
                                  style: TextStyle(
                                    color: rarityColor,
                                    fontSize: widget.size * 0.12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),

                // Particles during opening
                if (_controller.value > 0 && _controller.value < 0.5)
                  Positioned.fill(
                    child: ParticleWidget(
                      rarity: widget.lootBox.rarity,
                      particleCount: params.particleCount,
                      duration: params.particleDuration,
                      isEmitting: true,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== COMPACT LOOT BOX ITEM ====================

/// Kompakt loot box list item
class LootBoxListItem extends StatelessWidget {
  final UserLootBox lootBox;
  final VoidCallback onTap;
  final bool showActions;

  const LootBoxListItem({
    super.key,
    required this.lootBox,
    required this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = LootBoxColors.getRarityColor(lootBox.rarity);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rarityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Box icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      rarityColor.withOpacity(0.3),
                      rarityColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rarityColor, width: 2),
                ),
                child: Icon(
                  _getBoxIcon(),
                  size: 30,
                  color: rarityColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lootBox.rarityName,
                      style: TextStyle(
                        color: rarityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lootBox.sourceDescription ?? lootBox.typeName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (lootBox.expiresAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Süre: ${_formatExpiry(lootBox.expiresAt!)}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Rarity badge
              RarityBadge(
                rarity: lootBox.rarity,
                fontSize: 10,
              ),
              
              if (showActions) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBoxIcon() {
    switch (lootBox.boxType) {
      case LootBoxType.quiz: return Icons.quiz;
      case LootBoxType.daily: return Icons.calendar_today;
      case LootBoxType.achievement: return Icons.emoji_events;
      case LootBoxType.challenge: return Icons.workspace_premium;
      case LootBoxType.returnReward: return Icons.replay;
      case LootBoxType.seasonal: return Icons.ac_unit;
      case LootBoxType.login: return Icons.login;
      case LootBoxType.special: return Icons.star;
      case LootBoxType.premium: return Icons.diamond;
    }
  }

  String _formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    final diff = expiry.difference(now);

    if (diff.inDays > 0) {
      return '${diff.inDays} gün';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} saat';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika';
    }
    return 'Süresi dolmak üzere';
  }
}

