// lib/theme/modern_ui_components.dart
// Modern UI bileşenleri ve animasyon efektleri

import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'design_system.dart';

/// Modern UI bileşenleri ve animasyon efektleri
class ModernUI {
  /// Modern animated button with hover effects
  static Widget animatedButton(
    BuildContext context, {
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    double? width,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: 48,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? ThemeColors.getPrimaryButtonColor(context),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
          elevation: isLoading ? 0 : 2,
          shadowColor:
              (backgroundColor ?? ThemeColors.getPrimaryButtonColor(context))
                  .withValues(alpha:  0.3),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return Color.alphaBlend(
                  Colors.white.withValues(alpha:  0.1),
                  backgroundColor ??
                      ThemeColors.getPrimaryButtonColor(context));
            }
            if (states.contains(WidgetState.pressed)) {
              return Color.alphaBlend(
                  Colors.black.withValues(alpha:  0.1),
                  backgroundColor ??
                      ThemeColors.getPrimaryButtonColor(context));
            }
            return backgroundColor ??
                ThemeColors.getPrimaryButtonColor(context);
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Modern card with slide-in animation
  static Widget animatedCard(
    BuildContext context, {
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    Animation<double>? animation,
    Duration delay = Duration.zero,
  }) {
    final cardWidget = Container(
      margin: margin ?? const EdgeInsets.all(DesignSystem.spacingM),
      padding: padding ?? const EdgeInsets.all(DesignSystem.spacingL),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        boxShadow: ThemeColors.getModernShadow(context, elevation: 1.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha:  0.05)
              : Colors.black.withValues(alpha:  0.05),
          width: 1,
        ),
      ),
      child: child,
    );

    Widget finalWidget = cardWidget;

    if (onTap != null) {
      finalWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        child: cardWidget,
      );
    }

    // Add slide-in animation
    if (animation != null) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - animation.value) * 20),
            child: Opacity(
              opacity: animation.value,
              child: finalWidget,
            ),
          );
        },
      );
    }

    return finalWidget;
  }

  /// Modern loading shimmer effect
  static Widget shimmerCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        boxShadow: ThemeColors.getModernShadow(context, elevation: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer title
          Shimmer(
            child: Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: ThemeColors.getNeumorphismLight(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          // Shimmer content lines
          for (int i = 0; i < 3; i++) ...[
            Shimmer(
              child: Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: ThemeColors.getNeumorphismLight(context),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (i < 2) const SizedBox(height: 8),
          ],
          const SizedBox(height: DesignSystem.spacingM),
          // Shimmer buttons
          Row(
            children: [
              Shimmer(
                child: Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeColors.getNeumorphismLight(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spacingM),
              Shimmer(
                child: Container(
                  width: 60,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ThemeColors.getNeumorphismLight(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Modern toast notification
  static void showModernToast(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _getToastColor(context, type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getToastIcon(type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
        margin: const EdgeInsets.all(DesignSystem.spacingM),
        duration: duration,
      ),
    );
  }

  /// Modern floating action button with pulse animation
  static Widget pulseFAB(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? backgroundColor,
    double? size,
  }) {
    final fabSize = size ?? 56.0;
    final bgColor =
        backgroundColor ?? ThemeColors.getAccentButtonColor(context);

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            // Pulse animation
            setState(() {
              _isAnimating = true;
            });
            onPressed();
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                _isAnimating = false;
              });
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: fabSize,
            height: fabSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(fabSize / 2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha:  0.3),
                  blurRadius: _isAnimating ? 20 : 8,
                  offset: Offset(0, _isAnimating ? 4 : 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: fabSize * 0.4,
            ),
          ),
        );
      },
    );
  }

  /// Modern progress bar with gradient
  static Widget modernProgressBar(
    BuildContext context, {
    required double progress,
    Color? backgroundColor,
    Color? progressColor,
    double height = 8,
    Duration? animationDuration,
  }) {
    final bgColor = backgroundColor ?? ThemeColors.getNeumorphismLight(context);
    final progColor =
        progressColor ?? ThemeColors.getPrimaryButtonColor(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(progColor),
          minHeight: height,
        ),
      ),
    );
  }

  /// Modern status indicator (online, offline, busy, etc.)
  static Widget statusIndicator(
    BuildContext context, {
    required StatusType status,
    double size = 12,
  }) {
    final color = _getStatusColor(context, status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeColors.getCardBackground(context),
          width: 2,
        ),
      ),
    );
  }

  /// Modern tooltip with modern styling
  static Widget modernTooltip(
    BuildContext context, {
    required String message,
    required Widget child,
  }) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: ThemeColors.getText(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: TextStyle(
        color: ThemeColors.getCardBackground(context),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: child,
    );
  }

  // Private helper methods
  static bool _isAnimating = false;

  static Color _getToastColor(BuildContext context, ToastType type) {
    switch (type) {
      case ToastType.success:
        return ThemeColors.getSuccessColor(context);
      case ToastType.error:
        return ThemeColors.getErrorColor(context);
      case ToastType.warning:
        return ThemeColors.getWarningColor(context);
      case ToastType.info:
        return ThemeColors.getInfoColor(context);
    }
  }

  static IconData _getToastIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  static Color _getStatusColor(BuildContext context, StatusType status) {
    switch (status) {
      case StatusType.online:
        return ThemeColors.getSuccessColor(context);
      case StatusType.offline:
        return ThemeColors.getSecondaryText(context);
      case StatusType.busy:
        return ThemeColors.getErrorColor(context);
      case StatusType.away:
        return ThemeColors.getWarningColor(context);
    }
  }
}

// Enums
enum ToastType { success, error, warning, info }

enum StatusType { online, offline, busy, away }
