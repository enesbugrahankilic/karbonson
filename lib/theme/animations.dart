// lib/theme/animations.dart
// Advanced animations and micro-interactions

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'theme_colors.dart';

/// Advanced animation system with pre-built animations and micro-interactions
class AppAnimations {
  
  // Standard animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Standard animation curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve linear = Curves.linear;
  
  /// Create a fade-in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Duration? delay,
    Curve curve = easeOut,
    double? fromOpacity,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fromOpacity ?? 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Create a slide-up animation
  static Widget slideUp({
    required Widget child,
    Duration duration = normal,
    Duration? delay,
    Curve curve = easeOut,
    double fromOffset = 50.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(0, fromOffset), end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Create a scale animation
  static Widget scale({
    required Widget child,
    Duration duration = normal,
    Duration? delay,
    Curve curve = elasticOut,
    double fromScale = 0.0,
    double toScale = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fromScale, end: toScale),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Create a combined fade and slide animation
  static Widget fadeSlideUp({
    required Widget child,
    Duration duration = normal,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
    double fromOffset = 30.0,
    double fromOpacity = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * fromOffset),
          child: Opacity(
            opacity: fromOpacity + (value * (1 - fromOpacity)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  /// Create a staggered animation for lists
  static Widget staggered({
    required List<Widget> children,
    Duration duration = normal,
    Duration? delay,
    Curve curve = easeOut,
    double staggerOffset = 0.1,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final startDelay = delay ?? Duration.zero;
        final childDelay = Duration(milliseconds: (index * staggerOffset * 1000).round());
        
        return fadeSlideUp(
          child: child,
          duration: duration,
          delay: startDelay + childDelay,
          curve: curve,
        );
      }).toList(),
    );
  }
  
  /// Create a bounce animation
  static Widget bounce({
    required Widget child,
    Duration duration = normal,
    Curve curve = bounceOut,
    double bounceHeight = 0.2,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final bounceValue = (1 - (value - 0.5).abs() * 2) * bounceHeight;
        final scale = 1 + bounceValue;
        
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }
  
  /// Create a ripple effect
  static Widget ripple({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    Duration duration = fast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: rippleColor ?? ThemeColors.getPrimaryButtonColor(Colors.black as BuildContext).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
  
  /// Create a hover effect
  static Widget hover({
    required Widget child,
    required VoidCallback onTap,
    double hoverScale = 1.05,
    Color? hoverColor,
  }) {
    return MouseRegion(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: fast,
          curve: easeOut,
          child: child,
        ),
      ),
    );
  }
  
  /// Create a loading spinner
  static Widget loadingSpinner({
    Color? color,
    double size = 40.0,
    double strokeWidth = 4.0,
  }) {
    final spinnerColor = color ?? ThemeColors.getPrimaryButtonColor(Colors.black as BuildContext);
    
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        backgroundColor: Colors.transparent,
      ),
    );
  }
  
  /// Create a pulsing loading indicator
  static Widget pulsingIndicator({
    Color? color,
    double size = 40.0,
  }) {
    final indicatorColor = color ?? ThemeColors.getPrimaryButtonColor(Colors.black as BuildContext);
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.3),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
  
  /// Create a typing indicator
  static Widget typingIndicator({
    Color? color,
    double size = 8.0,
    Duration duration = normal,
  }) {
    final dotColor = color ?? ThemeColors.getSecondaryText(Colors.black as BuildContext);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _typingController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: dotColor.withOpacity(
                  0.3 + (_typingController.value * 0.7),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
  
  /// Create a progress bar animation
  static Widget animatedProgressBar({
    required double progress,
    Color? backgroundColor,
    Color? progressColor,
    double height = 8.0,
    Duration duration = normal,
    Duration? delay,
  }) {
    final bgColor = backgroundColor ?? ThemeColors.getNeumorphismLight(Colors.black as BuildContext);
    final progColor = progressColor ?? ThemeColors.getPrimaryButtonColor(Colors.black as BuildContext);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: duration,
      curve: easeOut,
      builder: (context, value, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progColor),
              minHeight: height,
            ),
          ),
        );
      },
    );
  }
  
  /// Create a slide transition between widgets
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.left,
  }) {
    final offset = _getSlideOffset(direction, animation.value);
    
    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: animation.value,
        child: child,
      ),
    );
  }
  
  /// Create a scale transition with spring effect
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
  
  /// Create a rotation animation
  static Widget rotation({
    required Widget child,
    Duration duration = normal,
    Curve curve = linear,
    double fromRotation = 0.0,
    double toRotation = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fromRotation, end: toRotation),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Private animation controllers
  static final AnimationController _pulseController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: _pulseTickerProvider,
  )..repeat();
  
  static final AnimationController _typingController = AnimationController(
    duration: const Duration(milliseconds: 1200),
    vsync: _typingTickerProvider,
  )..repeat();
  
  // Private ticker providers
  static final TickerProvider _pulseTickerProvider = _PulseTickerProvider();
  static final TickerProvider _typingTickerProvider = _TypingTickerProvider();
  
  // Private helper methods
  static Offset _getSlideOffset(SlideDirection direction, double animationValue) {
    switch (direction) {
      case SlideDirection.left:
        return Offset(-(1 - animationValue), 0);
      case SlideDirection.right:
        return Offset((1 - animationValue), 0);
      case SlideDirection.up:
        return Offset(0, -(1 - animationValue));
      case SlideDirection.down:
        return Offset(0, (1 - animationValue));
    }
  }
  
  /// Dispose all animation controllers
  static void dispose() {
    _pulseController.dispose();
    _typingController.dispose();
  }
}

/// Micro-interaction patterns
class MicroInteractions {
  
  /// Create a button press effect
  static Widget buttonPress({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 100),
    double scaleDown = 0.95,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: _buttonTickerProvider,
    );
    
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => controller.forward(),
      onTapUp: (_) => controller.reverse(),
      onTapCancel: () => controller.reverse(),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final scale = 1.0 - (controller.value * (1 - scaleDown));
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
  
  /// Create a like button with heart animation
  static Widget likeButton({
    required bool isLiked,
    required VoidCallback onTap,
    Color? activeColor,
    Color? inactiveColor,
    double size = 24.0,
  }) {
    final color = isLiked 
        ? (activeColor ?? Colors.red)
        : (inactiveColor ?? Colors.grey);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: color,
          size: size,
        ),
      ),
    );
  }
  
  /// Create a checkbox with smooth animation
  static Widget animatedCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    Color? inactiveColor,
    double size = 24.0,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value 
              ? (activeColor ?? ThemeColors.getSuccessColor(Colors.black as BuildContext))
              : Colors.transparent,
          border: Border.all(
            color: value 
                ? (activeColor ?? ThemeColors.getSuccessColor(Colors.black as BuildContext))
                : (inactiveColor ?? Colors.grey),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: value 
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
  
  /// Create a toggle switch
  static Widget toggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    Color? inactiveColor,
    double width = 50.0,
    double height = 30.0,
  }) {
    final active = activeColor ?? ThemeColors.getPrimaryButtonColor(Colors.black as BuildContext);
    final inactive = inactiveColor ?? Colors.grey.shade300;
    
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: value ? active : inactive,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? width - height : 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: height,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  static final TickerProvider _buttonTickerProvider = _ButtonTickerProvider();
}

// Enums
enum SlideDirection { left, right, up, down }

// Private ticker provider classes
class _PulseTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'pulse');
  }
}

class _TypingTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'typing');
  }
}

class _ButtonTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'button');
  }
}