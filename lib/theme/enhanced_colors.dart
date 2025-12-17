// lib/theme/enhanced_colors.dart
// Enhanced color palette and typography system

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Enhanced color system with semantic naming and modern palettes
class EnhancedColors {
  // Primary Color Palette - Modern Green Theme
  static const Color primary50 = Color(0xFFF1F8E9);
  static const Color primary100 = Color(0xFFDCEDC8);
  static const Color primary200 = Color(0xFFC5E1A5);
  static const Color primary300 = Color(0xFFAED581);
  static const Color primary400 = Color(0xFF9CCC65);
  static const Color primary500 = Color(0xFF8BC34A);
  static const Color primary600 = Color(0xFF7CB342);
  static const Color primary700 = Color(0xFF689F38);
  static const Color primary800 = Color(0xFF558B2F);
  static const Color primary900 = Color(0xFF33691E);

  // Secondary Color Palette - Modern Blue Theme
  static const Color secondary50 = Color(0xFFE3F2FD);
  static const Color secondary100 = Color(0xFFBBDEFB);
  static const Color secondary200 = Color(0xFF90CAF9);
  static const Color secondary300 = Color(0xFF64B5F6);
  static const Color secondary400 = Color(0xFF42A5F5);
  static const Color secondary500 = Color(0xFF2196F3);
  static const Color secondary600 = Color(0xFF1E88E5);
  static const Color secondary700 = Color(0xFF1976D2);
  static const Color secondary800 = Color(0xFF1565C0);
  static const Color secondary900 = Color(0xFF0D47A1);

  // Accent Color Palette - Modern Purple Theme
  static const Color accent50 = Color(0xFFF3E5F5);
  static const Color accent100 = Color(0xFFE1BEE7);
  static const Color accent200 = Color(0xFFCE93D8);
  static const Color accent300 = Color(0xFFBA68C8);
  static const Color accent400 = Color(0xFFAB47BC);
  static const Color accent500 = Color(0xFF9C27B0);
  static const Color accent600 = Color(0xFF8E24AA);
  static const Color accent700 = Color(0xFF7B1FA2);
  static const Color accent800 = Color(0xFF6A1B9A);
  static const Color accent900 = Color(0xFF4A148C);

  // Neutral Color Palette - Modern Grays
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Surface Colors
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color outline = Color(0xFFE0E0E0);

  /// Get primary color by intensity (50-900)
  static Color getPrimaryColorByIntensity(BuildContext context, int intensity) {
    final brightness = Theme.of(context).brightness;
    
    switch (intensity) {
      case 50:
        return brightness == Brightness.light ? primary50 : primary900;
      case 100:
        return brightness == Brightness.light ? primary100 : primary800;
      case 200:
        return brightness == Brightness.light ? primary200 : primary700;
      case 300:
        return brightness == Brightness.light ? primary300 : primary600;
      case 400:
        return brightness == Brightness.light ? primary400 : primary500;
      case 500:
        return primary500;
      case 600:
        return brightness == Brightness.light ? primary600 : primary400;
      case 700:
        return brightness == Brightness.light ? primary700 : primary300;
      case 800:
        return brightness == Brightness.light ? primary800 : primary200;
      case 900:
        return brightness == Brightness.light ? primary900 : primary100;
      default:
        return primary500;
    }
  }

  /// Get semantic color for different contexts
  static Color getSemanticColor(BuildContext context, SemanticColorType type) {
    final brightness = Theme.of(context).brightness;
    
    switch (type) {
      case SemanticColorType.success:
        return brightness == Brightness.light ? success : success.lighten(0.2);
      case SemanticColorType.warning:
        return brightness == Brightness.light ? warning : warning.lighten(0.2);
      case SemanticColorType.error:
        return brightness == Brightness.light ? error : error.lighten(0.2);
      case SemanticColorType.info:
        return brightness == Brightness.light ? info : info.lighten(0.2);
      case SemanticColorType.surface:
        return brightness == Brightness.light ? surface : neutral800;
      case SemanticColorType.surfaceVariant:
        return brightness == Brightness.light ? surfaceVariant : neutral700;
      case SemanticColorType.outline:
        return brightness == Brightness.light ? outline : neutral600;
    }
  }

  /// Get gradient by semantic type
  static List<Color> getSemanticGradient(BuildContext context, SemanticColorType type) {
    switch (type) {
      case SemanticColorType.success:
        return [success, success.lighten(0.2)];
      case SemanticColorType.warning:
        return [warning, warning.lighten(0.2)];
      case SemanticColorType.error:
        return [error, error.lighten(0.2)];
      case SemanticColorType.info:
        return [info, info.lighten(0.2)];
      case SemanticColorType.surface:
        final brightness = Theme.of(context).brightness;
        return brightness == Brightness.light 
            ? [surface, surfaceVariant]
            : [neutral800, neutral700];
      default:
        return [primary500, primary400];
    }
  }

  /// Create color palette from base color
  static List<Color> createColorPalette(Color baseColor) {
    return [
      baseColor.lighten(0.4), // 50
      baseColor.lighten(0.3), // 100
      baseColor.lighten(0.2), // 200
      baseColor.lighten(0.1), // 300
      baseColor.lighten(0.05), // 400
      baseColor, // 500
      baseColor.darken(0.05), // 600
      baseColor.darken(0.1), // 700
      baseColor.darken(0.2), // 800
      baseColor.darken(0.3), // 900
    ];
  }

  /// Check if color meets WCAG AA contrast requirements
  static bool meetsContrastRequirement(Color foreground, Color background) {
    final contrast = calculateContrastRatio(foreground, background);
    return contrast >= 4.5;
  }

  /// Calculate contrast ratio between two colors
  static double calculateContrastRatio(Color foreground, Color background) {
    final fL = foreground.getLuminance();
    final bL = background.getLuminance();
    
    final lighter = math.max(fL, bL);
    final darker = math.min(fL, bL);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Get appropriate text color for given background
  static Color getTextColorForBackground(Color background) {
    final blackContrast = calculateContrastRatio(Colors.black, background);
    final whiteContrast = calculateContrastRatio(Colors.white, background);
    
    return blackContrast > whiteContrast ? Colors.black : Colors.white;
  }
}

/// Enhanced typography system
class EnhancedTypography {
  // Font families
  static const String primaryFontFamily = 'Montserrat';
  static const String secondaryFontFamily = 'Roboto';
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  // Display styles (64px - 96px)
  static TextStyle displayLarge({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 96,
      fontWeight: light,
      color: color,
      letterSpacing: letterSpacing ?? -1.5,
      height: height ?? 1.1,
      fontFamily: primaryFontFamily,
    );
  }

  static TextStyle displayMedium({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 64,
      fontWeight: light,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.15,
      fontFamily: primaryFontFamily,
    );
  }

  static TextStyle displaySmall({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 48,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.2,
      fontFamily: primaryFontFamily,
    );
  }

  // Headline styles (32px - 56px)
  static TextStyle headlineLarge({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 56,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.25,
      fontFamily: primaryFontFamily,
    );
  }

  static TextStyle headlineMedium({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 45,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.3,
      fontFamily: primaryFontFamily,
    );
  }

  static TextStyle headlineSmall({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 36,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.35,
      fontFamily: primaryFontFamily,
    );
  }

  // Title styles (22px - 32px)
  static TextStyle titleLarge({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 32,
      fontWeight: semibold,
      color: color,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.4,
      fontFamily: primaryFontFamily,
    );
  }

  static TextStyle titleMedium({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 28,
      fontWeight: semibold,
      color: color,
      letterSpacing: letterSpacing ?? 0.15,
      height: height ?? 1.4,
      fontFamily: primaryFontFamily,
    );
  }

  static TextStyle titleSmall({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 22,
      fontWeight: semibold,
      color: color,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.4,
      fontFamily: primaryFontFamily,
    );
  }

  // Body styles (14px - 20px)
  static TextStyle bodyLarge({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 20,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.5,
      fontFamily: secondaryFontFamily,
    );
  }

  static TextStyle bodyMedium({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.5,
      fontFamily: secondaryFontFamily,
    );
  }

  static TextStyle bodySmall({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0.25,
      height: height ?? 1.4,
      fontFamily: secondaryFontFamily,
    );
  }

  // Label styles (11px - 16px)
  static TextStyle labelLarge({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: semibold,
      color: color,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.4,
      fontFamily: secondaryFontFamily,
    );
  }

  static TextStyle labelMedium({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 14,
      fontWeight: semibold,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.4,
      fontFamily: secondaryFontFamily,
    );
  }

  static TextStyle labelSmall({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 11,
      fontWeight: semibold,
      color: color,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.4,
      fontFamily: secondaryFontFamily,
    );
  }

  // Caption style (12px)
  static TextStyle caption({
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: regular,
      color: color,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.3,
      fontFamily: secondaryFontFamily,
    );
  }
}

/// Color utilities extension
extension ColorExtensions on Color {
  /// Lighten color by percentage (0.0 to 1.0)
  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Darken color by percentage (0.0 to 1.0)
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Calculate relative luminance
  double getLuminance() {
    final rgb = [red, green, blue].map((channel) {
      channel = channel ~/ 255;
      return channel <= 0.03928 
          ? channel / 12.92 
          : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }).toList();
    return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2];
  }
}

// Enums
enum SemanticColorType { success, warning, error, info, surface, surfaceVariant, outline }