// lib/utils/loot_box_animations.dart
// Loot Box Animation Utilities - Particle Effects, Confetti, Glow Effects

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/loot_box.dart';
import '../models/loot_box_reward.dart';

// ==================== RARITY COLORS ====================

/// Rarity color helpers
class LootBoxColors {
  // Rarity colors
  static const Color common = Color(0xFF8B8B8B);      // Gri
  static const Color rare = Color(0xFF4A90E2);         // Mavi
  static const Color epic = Color(0xFF9B59B6);         // Mor
  static const Color legendary = Color(0xFFF39C12);    // Altın
  static const Color mythic = Color(0xFFE74C3C);       // Kırmızı

  // Glow colors
  static const Color commonGlow = Color(0x668B8B8B);
  static const Color rareGlow = Color(0x664A90E2);
  static const Color epicGlow = Color(0x669B59B6);
  static const Color legendaryGlow = Color(0x66F39C12);
  static const Color mythicGlow = Color(0x66E74C3C);

  static Color getRarityColor(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common: return common;
      case LootBoxRarity.rare: return rare;
      case LootBoxRarity.epic: return epic;
      case LootBoxRarity.legendary: return legendary;
      case LootBoxRarity.mythic: return mythic;
    }
  }

  static Color getRarityGlowColor(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common: return commonGlow;
      case LootBoxRarity.rare: return rareGlow;
      case LootBoxRarity.epic: return epicGlow;
      case LootBoxRarity.legendary: return legendaryGlow;
      case LootBoxRarity.mythic: return mythicGlow;
    }
  }

  static Color getRewardRarityColor(LootBoxRarity rarity) {
    return getRarityColor(rarity);
  }

  static List<Color> getRarityGradient(LootBoxRarity rarity) {
    final baseColor = getRarityColor(rarity);
    final glowColor = getRarityGlowColor(rarity);
    return [baseColor.withOpacity(0.3), baseColor, glowColor];
  }
}

// ==================== ANIMATION PARAMETERS ====================

/// Animation parameters based on rarity
class LootBoxAnimationParams {
  final double shakeIntensity;
  final Duration shakeDuration;
  final Duration openDuration;
  final int particleCount;
  final Duration particleDuration;
  final double glowIntensity;
  final int confettiCount;
  final Color particleColor;

  const LootBoxAnimationParams({
    required this.shakeIntensity,
    required this.shakeDuration,
    required this.openDuration,
    required this.particleCount,
    required this.particleDuration,
    required this.glowIntensity,
    required this.confettiCount,
    required this.particleColor,
  });

  factory LootBoxAnimationParams.forRarity(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common:
        return const LootBoxAnimationParams(
          shakeIntensity: 3.0,
          shakeDuration: Duration(milliseconds: 300),
          openDuration: Duration(milliseconds: 500),
          particleCount: 15,
          particleDuration: Duration(milliseconds: 800),
          glowIntensity: 0.5,
          confettiCount: 20,
          particleColor: LootBoxColors.common,
        );
      case LootBoxRarity.rare:
        return const LootBoxAnimationParams(
          shakeIntensity: 5.0,
          shakeDuration: Duration(milliseconds: 400),
          openDuration: Duration(milliseconds: 600),
          particleCount: 25,
          particleDuration: Duration(milliseconds: 1000),
          glowIntensity: 0.7,
          confettiCount: 35,
          particleColor: LootBoxColors.rare,
        );
      case LootBoxRarity.epic:
        return const LootBoxAnimationParams(
          shakeIntensity: 7.0,
          shakeDuration: Duration(milliseconds: 500),
          openDuration: Duration(milliseconds: 700),
          particleCount: 40,
          particleDuration: Duration(milliseconds: 1200),
          glowIntensity: 0.85,
          confettiCount: 50,
          particleColor: LootBoxColors.epic,
        );
      case LootBoxRarity.legendary:
        return const LootBoxAnimationParams(
          shakeIntensity: 10.0,
          shakeDuration: Duration(milliseconds: 600),
          openDuration: Duration(milliseconds: 800),
          particleCount: 60,
          particleDuration: Duration(milliseconds: 1500),
          glowIntensity: 1.0,
          confettiCount: 80,
          particleColor: LootBoxColors.legendary,
        );
      case LootBoxRarity.mythic:
        return const LootBoxAnimationParams(
          shakeIntensity: 15.0,
          shakeDuration: Duration(milliseconds: 700),
          openDuration: Duration(milliseconds: 1000),
          particleCount: 100,
          particleDuration: Duration(milliseconds: 2000),
          glowIntensity: 1.2,
          confettiCount: 120,
          particleColor: LootBoxColors.mythic,
        );
    }
  }
}

// ==================== PARTICLE SYSTEM ====================

/// A single particle for effects
class Particle {
  final Offset position;
  final Offset velocity;
  final Color color;
  final double size;
  final double opacity;
  final double rotation;
  final double rotationSpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
  });

  Particle copyWith({
    Offset? position,
    Offset? velocity,
    Color? color,
    double? size,
    double? opacity,
    double? rotation,
    double? rotationSpeed,
  }) {
    return Particle(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      color: color ?? this.color,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
    );
  }
}

/// Particle system widget
class ParticleWidget extends StatefulWidget {
  final LootBoxRarity rarity;
  final Offset? center;
  final Duration duration;
  final int particleCount;
  final ParticleType particleType;
  final bool isEmitting;

  const ParticleWidget({
    super.key,
    required this.rarity,
    this.center,
    this.duration = const Duration(milliseconds: 1500),
    this.particleCount = 30,
    this.particleType = ParticleType.sparkle,
    this.isEmitting = true,
  });

  @override
  State<ParticleWidget> createState() => _ParticleWidgetState();
}

enum ParticleType { sparkle, confetti, star, flame }

class _ParticleWidgetState extends State<ParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Size _layoutSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {});
      });

    if (widget.isEmitting) {
      _controller.forward();
      _generateParticles();
    }
  }

  @override
  void didUpdateWidget(ParticleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEmitting != widget.isEmitting) {
      if (widget.isEmitting) {
        _controller.reset();
        _controller.forward();
        _generateParticles();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _layoutSize = MediaQuery.of(context).size;
  }

  void _generateParticles() {
    final color = LootBoxColors.getRarityColor(widget.rarity);
    final center = widget.center ?? Offset(_layoutSize.width / 2, _layoutSize.height / 2);

    for (int i = 0; i < widget.particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 3 + 1;
      
      _particles.add(Particle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        color: color.withOpacity(_random.nextDouble() * 0.5 + 0.5),
        size: _random.nextDouble() * 8 + 4,
        opacity: 1.0,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: _random.nextDouble() * 0.2 - 0.1,
      ));
    }
  }

  void _updateParticles() {
    final progress = _controller.value;
    final decay = 1 - progress;

    for (int i = _particles.length - 1; i >= 0; i--) {
      final particle = _particles[i];
      
      // Update position with some gravity and friction
      final newVelocity = Offset(
        particle.velocity.dx * 0.98,
        particle.velocity.dy * 0.98 + 0.05, // Slight gravity
      );
      
      final newPosition = Offset(
        particle.position.dx + newVelocity.dx,
        particle.position.dy + newVelocity.dy,
      );
      
      final newOpacity = decay * decay; // Fade out faster at the end
      
      _particles[i] = particle.copyWith(
        position: newPosition,
        velocity: newVelocity,
        opacity: newOpacity,
        rotation: particle.rotation + particle.rotationSpeed,
      );

      // Remove particles that are too faded
      if (newOpacity < 0.01) {
        _particles.removeAt(i);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _layoutSize = MediaQuery.of(context).size;
    
    if (_controller.isAnimating) {
      _updateParticles();
    }

    return CustomPaint(
      painter: ParticlePainter(
        particles: _particles,
        particleType: widget.particleType,
      ),
      size: Size.infinite,
    );
  }
}

/// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final ParticleType particleType;

  ParticlePainter({required this.particles, required this.particleType});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      switch (particleType) {
        case ParticleType.sparkle:
          _drawSparkle(canvas, particle, paint);
          break;
        case ParticleType.confetti:
          _drawConfetti(canvas, particle, paint);
          break;
        case ParticleType.star:
          _drawStar(canvas, particle, paint);
          break;
        case ParticleType.flame:
          _drawFlame(canvas, particle, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawSparkle(Canvas canvas, Particle particle, Paint paint) {
    // Draw a 4-pointed star sparkle
    final path = Path();
    final size = particle.size;
    
    path.moveTo(0, -size);
    path.lineTo(size * 0.3, -size * 0.3);
    path.lineTo(size, 0);
    path.lineTo(size * 0.3, size * 0.3);
    path.lineTo(0, size);
    path.lineTo(-size * 0.3, size * 0.3);
    path.lineTo(-size, 0);
    path.lineTo(-size * 0.3, -size * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawConfetti(Canvas canvas, Particle particle, Paint paint) {
    // Draw rectangle confetti
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
      Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);
  }

  void _drawStar(Canvas canvas, Particle particle, Paint paint) {
    // Draw 5-pointed star
    final path = Path();
    final outerRadius = particle.size;
    final innerRadius = particle.size * 0.4;
    
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * pi / 180;
      
      final outerX = cos(outerAngle) * outerRadius;
      final outerY = sin(outerAngle) * outerRadius;
      final innerX = cos(innerAngle) * innerRadius;
      final innerY = sin(innerAngle) * innerRadius;
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawFlame(Canvas canvas, Particle particle, Paint paint) {
    // Draw tear-drop flame shape
    final path = Path();
    final size = particle.size;
    
    path.moveTo(0, -size);
    path.quadraticBezierTo(size * 0.8, -size * 0.3, size * 0.5, size * 0.5);
    path.quadraticBezierTo(size * 0.2, size * 0.8, 0, size);
    path.quadraticBezierTo(-size * 0.2, size * 0.8, -size * 0.5, size * 0.5);
    path.quadraticBezierTo(-size * 0.8, -size * 0.3, 0, -size);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

// ==================== GLOW EFFECT ====================

/// Glow effect widget with animated pulsing
class GlowWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final double blurRadius;
  final BorderRadius? borderRadius;
  final bool enablePulse;

  const GlowWidget({
    super.key,
    required this.child,
    this.glowColor = Colors.white,
    this.glowIntensity = 1.0,
    this.blurRadius = 20,
    this.borderRadius,
    this.enablePulse = true,
  });

  @override
  State<GlowWidget> createState() => _GlowWidgetState();
}

class _GlowWidgetState extends State<GlowWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.enablePulse) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
      
      _pulseAnimation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.8).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
      ]).animate(_pulseController);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final intensity = widget.glowIntensity * _pulseAnimation.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.6 * intensity),
                blurRadius: widget.blurRadius,
                spreadRadius: 2 * intensity,
              ),
              BoxShadow(
                color: widget.glowColor.withOpacity(0.3 * intensity),
                blurRadius: widget.blurRadius * 2,
                spreadRadius: 4 * intensity,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ==================== SHIMMER EFFECT ====================

/// Shimmer effect widget for legendary+ items
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color shimmerColor;
  final Duration duration;
  final double intensity;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.shimmerColor = Colors.white,
    this.duration = const Duration(milliseconds: 2000),
    this.intensity = 0.5,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.transparent,
                widget.shimmerColor.withOpacity(widget.intensity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _ShimmerGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ShimmerGradientTransform extends GradientTransform {
  final double progress;
  
  const _ShimmerGradientTransform(this.progress);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.left + bounds.width * progress - bounds.width,
      bounds.top,
      0,
    );
  }
}

// ==================== RARITY BADGE ====================

/// Rarity badge widget
class RarityBadge extends StatelessWidget {
  final LootBoxRarity rarity;
  final String text;
  final double fontSize;
  final bool showIcon;

  const RarityBadge({
    super.key,
    required this.rarity,
    this.text = '',
    this.fontSize = 12,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = LootBoxColors.getRarityColor(rarity);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getRarityIcon(rarity),
              color: color,
              size: fontSize + 4,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text.isNotEmpty ? text : _getRarityName(rarity),
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRarityIcon(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common: return Icons.circle;
      case LootBoxRarity.rare: return Icons.diamond;
      case LootBoxRarity.epic: return Icons.star;
      case LootBoxRarity.legendary: return Icons.workspace_premium;
      case LootBoxRarity.mythic: return Icons.auto_awesome;
    }
  }

  String _getRarityName(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common: return 'Sıradan';
      case LootBoxRarity.rare: return 'Nadir';
      case LootBoxRarity.epic: return 'Destansı';
      case LootBoxRarity.legendary: return 'Efsanevi';
      case LootBoxRarity.mythic: return 'Mitolojik';
    }
  }
}

// ==================== PULSE ANIMATION ====================

/// Pulse animation for rare items
class PulseWidget extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseWidget({
    super.key,
    required this.child,
    this.pulseColor = Colors.white,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.98,
    this.maxScale = 1.02,
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.maxScale).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.maxScale, end: widget.minScale).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ==================== CONFETTI WIDGET ====================

/// Confetti celebration widget
class ConfettiWidget extends StatefulWidget {
  final LootBoxRarity rarity;
  final Duration duration;
  final int particleCount;
  final Offset? center;

  const ConfettiWidget({
    super.key,
    required this.rarity,
    this.duration = const Duration(milliseconds: 3000),
    this.particleCount = 50,
    this.center,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();
  Size _layoutSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {});
        }
      });

    _controller.forward();
    _generateConfetti();
  }

  void _generateConfetti() {
    final baseColor = LootBoxColors.getRarityColor(widget.rarity);
    final center = widget.center ?? Offset(_layoutSize.width / 2, _layoutSize.height * 0.3);

    for (int i = 0; i < widget.particleCount; i++) {
      final colors = [
        baseColor,
        baseColor.withOpacity(0.7),
        baseColor.withOpacity(0.5),
        Colors.white,
        LootBoxColors.legendary, // Gold accents
      ];

      _particles.add(_ConfettiParticle(
        startPosition: center,
        color: colors[_random.nextInt(colors.length)],
        size: _random.nextDouble() * 10 + 6,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 8,
          _random.nextDouble() * 5 + 2,
        ),
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: _random.nextDouble() * 0.2 - 0.1,
        shape: _random.nextInt(3), // 0: rect, 1: circle, 2: star
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _layoutSize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    _layoutSize = MediaQuery.of(context).size;
    _updateParticles();

    return CustomPaint(
      painter: _ConfettiPainter(particles: _particles),
      size: Size.infinite,
    );
  }

  void _updateParticles() {
    final progress = _controller.value;
    final gravity = 0.15;

    for (final particle in _particles) {
      particle.position = Offset(
        particle.position.dx + particle.velocity.dx,
        particle.position.dy + particle.velocity.dy,
      );
      particle.velocity = Offset(
        particle.velocity.dx * 0.99,
        particle.velocity.dy + gravity,
      );
      particle.rotation += particle.rotationSpeed;
      particle.opacity = 1.0 - pow(progress, 2).toDouble();
    }
  }
}

class _ConfettiParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  double opacity = 1.0;
  int shape;

  _ConfettiParticle({
    required Offset startPosition,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  }) : position = startPosition;
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.opacity <= 0) continue;

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      switch (particle.shape) {
        case 0: // Rectangle
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
            paint,
          );
          break;
        case 1: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 2: // Star
          _drawStar(canvas, particle.size / 2, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * pi / 180;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== RING BURST EFFECT ====================

/// Ring burst animation for opening
class RingBurstWidget extends StatefulWidget {
  final LootBoxRarity rarity;
  final Duration duration;
  final double maxRadius;
  final int ringCount;

  const RingBurstWidget({
    super.key,
    required this.rarity,
    this.duration = const Duration(milliseconds: 800),
    this.maxRadius = 200,
    this.ringCount = 3,
  });

  @override
  State<RingBurstWidget> createState() => _RingBurstWidgetState();
}

class _RingBurstWidgetState extends State<RingBurstWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RingBurstPainter(
            progress: _controller.value,
            rarity: widget.rarity,
            maxRadius: widget.maxRadius,
            ringCount: widget.ringCount,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RingBurstPainter extends CustomPainter {
  final double progress;
  final LootBoxRarity rarity;
  final double maxRadius;
  final int ringCount;

  _RingBurstPainter({
    required this.progress,
    required this.rarity,
    required this.maxRadius,
    required this.ringCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final color = LootBoxColors.getRarityColor(rarity);

    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (progress - i * 0.1).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final radius = maxRadius * ringProgress;
      final strokeWidth = 4 * (1 - ringProgress) + 1;

      final paint = Paint()
        ..color = color.withOpacity((1 - ringProgress) * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== LOOT BOX OPENING DIALOG ====================

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

  bool _showReward = false;

  @override
  void initState() {
    super.initState();

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

    // Start animation sequence
    _animationController.forward().then((_) {
      setState(() {
        _showReward = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    }
  }
}

// ==================== EXPORT FUNCTIONS ====================

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

