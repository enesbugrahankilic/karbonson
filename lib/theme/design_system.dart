// lib/theme/design_system.dart
// Comprehensive design system with consistent styling utilities

import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// Comprehensive design system for consistent UI across the app
class DesignSystem {
  // Standard spacing values for consistent layout
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Standard border radius values
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;

  // Standard elevation values
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  /// Modern card decoration with enhanced shadows and styling
  static BoxDecoration getCardDecoration(
    BuildContext context, {
    double? borderRadius,
    Color? backgroundColor,
    double? elevation,
    bool isElevated = false,
    bool hasGradient = false,
  }) {
    final bgColor = backgroundColor ?? ThemeColors.getCardBackground(context);

    if (hasGradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
        boxShadow:
            ThemeColors.getModernShadow(context, elevation: elevation ?? 1.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      );
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
      boxShadow:
          ThemeColors.getModernShadow(context, elevation: elevation ?? 1.0),
      border: isElevated
          ? Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1,
            )
          : null,
    );
  }

  /// Modern primary button style with enhanced states
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    final primaryColor = ThemeColors.getPrimaryButtonColor(context);

    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: 2,
      shadowColor: primaryColor.withValues(alpha: 0.3),
      minimumSize: const Size.fromHeight(48), // Accessibility touch target
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300;
        }
        if (states.contains(WidgetState.pressed)) {
          return Color.alphaBlend(
              Colors.black.withValues(alpha: 0.1), primaryColor);
        }
        if (states.contains(WidgetState.hovered)) {
          return Color.alphaBlend(
              Colors.white.withValues(alpha: 0.1), primaryColor);
        }
        return primaryColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade400
              : Colors.grey.shade600;
        }
        return Colors.white;
      }),
      elevation: WidgetStateProperty.resolveWith<double>((states) {
        if (states.contains(WidgetState.disabled)) {
          return 0;
        }
        if (states.contains(WidgetState.pressed)) {
          return 1;
        }
        return 2;
      }),
    );
  }

  /// Standard button style for secondary actions
  static ButtonStyle getSecondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: ThemeColors.getSecondaryButtonColor(context),
      foregroundColor: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: elevationS,
      minimumSize: const Size.fromHeight(48),
    );
  }

  /// Standard button style for accent actions
  static ButtonStyle getAccentButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: ThemeColors.getAccentButtonColor(context),
      foregroundColor: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: spacingXl, vertical: spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: elevationS,
      minimumSize: const Size.fromHeight(48),
    );
  }

  /// Standard button style for text buttons
  static ButtonStyle getTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      padding:
          const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      minimumSize: const Size.fromHeight(48),
    );
  }

  /// Standard input decoration with consistent styling
  static InputDecoration getInputDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: ThemeColors.getInputBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(
            color: ThemeColors.getPrimaryButtonColor(context), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide:
            BorderSide(color: ThemeColors.getErrorColor(context), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide:
            BorderSide(color: ThemeColors.getErrorColor(context), width: 2),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      hintStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      errorStyle:
          TextStyle(color: ThemeColors.getErrorColor(context), fontSize: 12),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM),
    );
  }

  /// Standard text styles for consistent typography
  static TextStyle getTitleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
              color: ThemeColors.getTitleColor(context),
              fontWeight: FontWeight.bold,
            ) ??
        const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        );
  }

  static TextStyle getTitleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
  }

  static TextStyle getBodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: ThemeColors.getText(context),
            ) ??
        const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        );
  }

  static TextStyle getBodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ThemeColors.getText(context),
            ) ??
        const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        );
  }

  static TextStyle getLabelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
  }

  static TextStyle getHeadlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w600,
            ) ??
        const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        );
  }

  static TextStyle getDisplaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall?.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w400,
            ) ??
        const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        );
  }

  static TextStyle getBodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w400,
            ) ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        );
  }

  /// Standard container decoration for pages
  static BoxDecoration getPageContainerDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: ThemeColors.getGradientColors(context),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Standard dialog decoration
  static BoxDecoration getDialogDecoration(BuildContext context) {
    return BoxDecoration(
      color: ThemeColors.getDialogBackground(context),
      borderRadius: BorderRadius.circular(radiusXl),
      boxShadow: [
        BoxShadow(
          color: ThemeColors.getShadow(context),
          blurRadius: elevationL,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Standard app bar theme
  static AppBarTheme getAppBarTheme(BuildContext context) {
    return AppBarTheme(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: ThemeColors.getAppBarText(context),
      elevation: elevationS,
      iconTheme: IconThemeData(color: ThemeColors.getAppBarIcon(context)),
      titleTextStyle: getTitleMedium(context).copyWith(
        color: ThemeColors.getAppBarText(context),
      ),
    );
  }

  /// Standard icon button style
  static IconButtonThemeData getIconButtonTheme(BuildContext context) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48), // Accessibility touch target
        iconSize: 24,
      ),
    );
  }

  /// Standard list tile theme
  static ListTileThemeData getListTileTheme(BuildContext context) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      titleTextStyle: getBodyLarge(context),
      subtitleTextStyle: getBodyMedium(context).copyWith(
        color: ThemeColors.getSecondaryText(context),
      ),
    );
  }

  /// Create a semantic widget wrapper for accessibility
  static Widget semantic(
    BuildContext context, {
    required String label,
    String? hint,
    String? semanticLabel,
    required Widget child,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      hint: hint,
      child: child,
    );
  }

  /// Create a responsive container based on screen size
  static Widget responsiveContainer(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    double? maxWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget child;
    if (screenWidth > 1024 && desktop != null) {
      child = desktop;
    } else if (screenWidth > 768 && tablet != null) {
      child = tablet;
    } else {
      child = mobile;
    }

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    }

    return child;
  }

  /// Create a consistent card widget
  static Widget card(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    final cardWidget = Container(
      margin: margin ?? const EdgeInsets.all(spacingM),
      padding: padding ?? const EdgeInsets.all(spacingL),
      decoration: getCardDecoration(
        context,
        backgroundColor: backgroundColor,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusL),
        child: cardWidget,
      );
    }

    return cardWidget;
  }

  /// Create a loading indicator with consistent styling
  static Widget loadingIndicator(
    BuildContext context, {
    String? message,
    double size = 32.0,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColors.getPrimaryButtonColor(context),
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: spacingM),
          Text(
            message,
            style: getBodyMedium(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Create an error state widget with consistent styling
  static Widget errorState(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: ThemeColors.getErrorColor(context),
            ),
            const SizedBox(height: spacingM),
            Text(
              message,
              style: getBodyLarge(context).copyWith(
                color: ThemeColors.getErrorColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: spacingL),
              ElevatedButton(
                onPressed: onRetry,
                style: getPrimaryButtonStyle(context),
                child: Text(retryText ?? 'Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Create an empty state widget with consistent styling
  static Widget emptyState(
    BuildContext context, {
    required String message,
    IconData icon = Icons.inbox,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: ThemeColors.getSecondaryText(context),
            ),
            const SizedBox(height: spacingM),
            Text(
              message,
              style: getBodyLarge(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: spacingL),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // Modern UI Components

  /// Create a skeleton loader for loading states
  static Widget skeletonLoader(
    BuildContext context, {
    double? width,
    double? height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ThemeColors.getNeumorphismLight(context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Create a skeleton text line
  static Widget skeletonText(
    BuildContext context, {
    double? width,
    int lines = 1,
    double lineHeight = 16,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: skeletonLoader(
            context,
            width: width ?? (isLast && lines > 1 ? width ?? 60 : null),
            height: lineHeight,
            borderRadius: 4,
          ),
        );
      }),
    );
  }

  /// Create a skeleton card
  static Widget skeletonCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(spacingM),
      padding: const EdgeInsets.all(spacingL),
      decoration: getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeletonText(context, width: 120, lines: 1, lineHeight: 20),
          const SizedBox(height: spacingM),
          skeletonText(context, lines: 3),
          const SizedBox(height: spacingM),
          Row(
            children: [
              skeletonLoader(context, width: 80, height: 32, borderRadius: 16),
              const SizedBox(width: spacingM),
              skeletonLoader(context, width: 60, height: 32, borderRadius: 16),
            ],
          ),
        ],
      ),
    );
  }

  /// Create a modern glass card with backdrop filter
  static Widget glassCard(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
  }) {
    final glassWidget = Container(
      margin: margin ?? const EdgeInsets.all(spacingM),
      padding: padding ?? const EdgeInsets.all(spacingL),
      decoration: BoxDecoration(
        color: ThemeColors.getGlassBackground(context),
        borderRadius: BorderRadius.circular(radiusL),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: ThemeColors.getModernShadow(context, elevation: 0.5),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusL),
        child: glassWidget,
      );
    }

    return glassWidget;
  }

  /// Create a modern floating action button
  static Widget modernFAB(
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

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(fabSize / 2),
        color: bgColor,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(fabSize / 2),
          child: Container(
            width: fabSize,
            height: fabSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(fabSize / 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: fabSize * 0.4,
            ),
          ),
        ),
      ),
    );
  }

  /// Create a modern progress indicator
  static Widget modernProgressIndicator(
    BuildContext context, {
    double? value,
    Color? color,
    double strokeWidth = 4,
  }) {
    final progressColor = color ?? ThemeColors.getPrimaryButtonColor(context);

    if (value != null) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      );
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      ),
    );
  }

  /// Create a modern chip component
  static Widget modernChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    Color? backgroundColor,
    bool isSelected = false,
  }) {
    final bgColor = backgroundColor ??
        (isSelected
            ? ThemeColors.getPrimaryButtonColor(context)
            : ThemeColors.getCardBackgroundLight(context));

    final fgColor = isSelected ? Colors.white : ThemeColors.getText(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? bgColor : ThemeColors.getBorder(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: fgColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create a modern divider with spacing
  static Widget modernDivider(
    BuildContext context, {
    double? width,
    double thickness = 1,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: spacingM),
      width: width,
      child: Divider(
        thickness: thickness,
        color: ThemeColors.getBorder(context),
        height: thickness,
      ),
    );
  }
}

// Shimmer effect for skeleton loaders
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? Colors.grey.shade300,
                widget.highlightColor ?? Colors.grey.shade100,
                widget.baseColor ?? Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
