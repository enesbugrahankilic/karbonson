// lib/theme/accessibility.dart
// WCAG AA compliant accessibility system

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// Accessibility utilities following WCAG AA standards
class AccessibilityHelper {
  // Minimum touch target size (WCAG AA)
  static const double minTouchTargetSize = 48.0;

  // Minimum font sizes for accessibility
  static const double minBodyFontSize = 16.0;
  static const double minLabelFontSize = 14.0;
  static const double minCaptionFontSize = 12.0;

  // Contrast ratio requirements (WCAG AA)
  static const double normalTextContrast = 4.5;
  static const double largeTextContrast = 3.0;

  /// Check if color combination meets WCAG AA contrast requirements
  static bool meetsContrastRequirements(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= normalTextContrast;
  }

  /// Check if color combination meets WCAG AA large text contrast requirements
  static bool meetsLargeTextContrastRequirements(
      Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= largeTextContrast;
  }

  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color foreground, Color background) {
    final fL = getLuminance(foreground);
    final bL = getLuminance(background);

    final lighter = math.max(fL, bL);
    final darker = math.min(fL, bL);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Get luminance of a color
  static double getLuminance(Color color) {
    final rgb = [color.red, color.green, color.blue].map((channel) {
      channel = channel ~/ 255;
      return channel <= 0.03928
          ? channel / 12.92
          : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }).toList();
    return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2];
  }

  /// Get accessible text color for given background
  static Color getAccessibleTextColor(BuildContext context, Color background) {
    final brightness = Theme.of(context).brightness;
    final black = brightness == Brightness.light ? Colors.black : Colors.white;
    final white = brightness == Brightness.light ? Colors.white : Colors.black;

    final blackContrast = calculateContrastRatio(black, background);
    final whiteContrast = calculateContrastRatio(white, background);

    return blackContrast > whiteContrast ? black : white;
  }

  /// Get accessible button size based on screen size
  static Size getAccessibleButtonSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1024) {
      return const Size(160, 56); // Desktop
    } else if (screenWidth > 600) {
      return const Size(140, 52); // Tablet
    } else {
      return const Size(120, 48); // Mobile
    }
  }

  /// Get accessible icon size
  static double getAccessibleIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1024) {
      return 24.0; // Desktop
    } else if (screenWidth > 600) {
      return 22.0; // Tablet
    } else {
      return 20.0; // Mobile
    }
  }

  /// Get accessible font size with scaling
  static double getAccessibleFontSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler.scale(baseSize) / baseSize;

    // Ensure minimum readable size for accessibility
    if (textScaler < 1.0) {
      return baseSize * 1.2;
    } else if (textScaler > 2.0) {
      return baseSize * 0.9;
    }
    return baseSize * textScaler;
  }

  /// Create accessible semantic label
  static String getSemanticLabel({
    required String action,
    required String target,
    String? state,
  }) {
    if (state != null) {
      return '$action $target, $state';
    }
    return '$action $target';
  }

  /// Create accessible hint text
  static String getHintText({
    required String action,
    String? additionalInfo,
  }) {
    if (additionalInfo != null) {
      return '$action. $additionalInfo';
    }
    return 'Use this to $action';
  }

  /// Get accessible padding for touch targets
  static EdgeInsets getAccessiblePadding(BuildContext context) {
    final buttonSize = getAccessibleButtonSize(context);
    final defaultPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    );

    final totalHeight = buttonSize.height;
    final contentHeight = defaultPadding.vertical + 24; // Assume 24px content

    if (totalHeight > contentHeight + 8) {
      final extraPadding = (totalHeight - contentHeight - 8) / 2;
      return EdgeInsets.symmetric(
        horizontal: defaultPadding.horizontal,
        vertical: extraPadding,
      );
    }

    return defaultPadding;
  }

  /// Check if screen reader is enabled
  static bool isScreenReaderEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation;
  }

  /// Create high contrast theme
  static ThemeData getHighContrastTheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.highContrastLight(
          primary: Colors.black,
          secondary: Colors.black,
          error: Colors.red,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onError: Colors.white,
        ),
        // High contrast text styles
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        // High contrast button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(160, 56),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // High contrast input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      );
    } else {
      return ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.highContrastDark(
          primary: Colors.white,
          secondary: Colors.white,
          error: Colors.red,
          surface: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.white,
        ),
        // High contrast dark text styles
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        // High contrast dark button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(160, 56),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // High contrast dark input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          hintStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }
  }

  /// Create accessible widget with semantic properties
  static Widget accessibleWidget({
    required Widget child,
    required String semanticLabel,
    String? hint,
    bool? checked,
    String? value,
    String? description,
    VoidCallback? onTap,
  }) {
    Widget widget = Semantics(
      label: semanticLabel.isNotEmpty ? semanticLabel : null,
      hint: hint?.isNotEmpty == true ? hint : null,
      checked: checked,
      value: value?.isNotEmpty == true ? value : null,
      child: child,
    );

    if (onTap != null) {
      widget = GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  /// Get focus order for accessibility
  static List<FocusNode> getFocusOrder(List<Widget> widgets) {
    return widgets.map((_) => FocusNode()).toList();
  }

  /// Create accessible navigation hints
  static List<String> getNavigationHints(BuildContext context) {
    return [
      'Use Tab to navigate between elements',
      'Use Enter or Space to activate buttons',
      'Use arrow keys to navigate lists',
      'Use Escape to close dialogs',
      'Use screen reader shortcuts for more options',
    ];
  }
}

/// Accessibility-aware button widget
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? semanticLabel;
  final String? hint;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const AccessibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.semanticLabel,
    this.hint,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = AccessibilityHelper.getAccessibleButtonSize(context);
    final accessiblePadding = AccessibilityHelper.getAccessiblePadding(context);

    return AccessibilityHelper.accessibleWidget(
      semanticLabel: semanticLabel ?? text,
      hint: hint,
      onTap: onPressed,
      child: Container(
        width: width ?? buttonSize.width,
        height: height ?? buttonSize.height,
        padding: accessiblePadding,
        decoration: BoxDecoration(
          color: backgroundColor ?? ThemeColors.getPrimaryButtonColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black,
            width: 2, // High contrast border
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AccessibilityHelper.getAccessibleIconSize(context),
                color: foregroundColor ?? Colors.white,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: foregroundColor ?? Colors.white,
                  fontSize:
                      AccessibilityHelper.getAccessibleFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accessibility-aware text widget
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final String? semanticLabel;
  final String? hint;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleText({
    super.key,
    required this.text,
    this.style,
    this.semanticLabel,
    this.hint,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final accessibleFontSize = AccessibilityHelper.getAccessibleFontSize(
      context,
      style?.fontSize ?? 16.0,
    );

    final accessibleStyle = (style ?? const TextStyle()).copyWith(
      fontSize: accessibleFontSize,
      color: style?.color ?? ThemeColors.getText(context),
      height: style?.height ?? 1.5,
    );

    return AccessibilityHelper.accessibleWidget(
      semanticLabel: semanticLabel ?? text,
      hint: hint,
      child: Text(
        text,
        style: accessibleStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
