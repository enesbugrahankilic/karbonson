import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color _lightText = Colors.black87;
  static const Color _lightSecondaryText = Colors.black54;

  // Dark theme colors
  static const Color _darkText = Colors.white;
  static const Color _darkSecondaryText = Colors.white70;

  // High contrast colors for accessibility
  static const Color _highContrastText = Colors.black;
  static const Color _highContrastBackground = Colors.white;
  static const Color _highContrastAccent =
      Color(0xFF0066CC); // WCAG AA compliant blue
  static const Color _highContrastError =
      Color(0xFFCC0000); // WCAG AA compliant red

  // Enhanced text styles for LIGHT theme with improved hierarchy
  static const TextStyle _lightDisplayLarge = TextStyle(
    fontSize: 64, // Increased from 57
    fontWeight: FontWeight.w300, // Lighter weight for modern look
    letterSpacing: -0.5, // Tighter tracking for large display text
    color: _lightText,
    height: 1.1, // Tighter line height
  );

  static const TextStyle _lightDisplayMedium = TextStyle(
    fontSize: 48, // Increased from 45
    fontWeight: FontWeight.w300,
    letterSpacing: -0.25,
    color: _lightText,
    height: 1.15,
  );

  static const TextStyle _lightDisplaySmall = TextStyle(
    fontSize: 40, // Increased from 36
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _lightText,
    height: 1.2,
  );

  static const TextStyle _lightHeadlineLarge = TextStyle(
    fontSize: 36, // Increased from 32
    fontWeight: FontWeight.w500, // Reduced weight for modern look
    letterSpacing: 0,
    color: _lightText,
    height: 1.25,
  );

  static const TextStyle _lightHeadlineMedium = TextStyle(
    fontSize: 30, // Increased from 28
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: _lightText,
    height: 1.3,
  );

  static const TextStyle _lightHeadlineSmall = TextStyle(
    fontSize: 26, // Increased from 24
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: _lightText,
    height: 1.35,
  );

  static const TextStyle _lightTitleLarge = TextStyle(
    fontSize: 24, // Increased from 22
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _lightText,
    height: 1.4,
  );

  static const TextStyle _lightTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: _lightSecondaryText,
  );

  static const TextStyle _lightTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _lightSecondaryText,
  );

  static const TextStyle _lightBodyLarge = TextStyle(
    fontSize: 17, // Increased from 16 for better readability
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15, // Reduced from 0.5 for better readability
    color: _lightText,
    height: 1.5, // Improved line height
  );

  static const TextStyle _lightBodyMedium = TextStyle(
    fontSize: 15, // Increased from 14
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1, // Reduced from 0.25
    color: _lightText,
    height: 1.5,
  );

  static const TextStyle _lightBodySmall = TextStyle(
    fontSize: 13, // Increased from 12
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1, // Reduced from 0.4
    color: _lightSecondaryText,
    height: 1.4,
  );

  static const TextStyle _lightLabelLarge = TextStyle(
    fontSize: 15, // Increased from 14
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05, // Reduced from 0.1
    color: _lightText,
    height: 1.4,
  );

  static const TextStyle _lightLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _lightText,
  );

  static const TextStyle _lightLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _lightSecondaryText,
  );

  // Custom text styles for DARK theme
  static const TextStyle _darkDisplayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: _darkText,
  );

  static const TextStyle _darkDisplayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _darkText,
  );

  static const TextStyle _darkDisplaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _darkText,
  );

  static const TextStyle _darkHeadlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkText,
  );

  static const TextStyle _darkHeadlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkText,
  );

  static const TextStyle _darkHeadlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkText,
  );

  static const TextStyle _darkTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkText,
  );

  static const TextStyle _darkTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: _darkSecondaryText,
  );

  static const TextStyle _darkTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _darkSecondaryText,
  );

  static const TextStyle _darkBodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: _darkText,
  );

  static const TextStyle _darkBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: _darkText,
  );

  static const TextStyle _darkBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: _darkSecondaryText,
  );

  static const TextStyle _darkLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _darkText,
  );

  static const TextStyle _darkLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _darkText,
  );

  static const TextStyle _darkLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _darkSecondaryText,
  );

  // High contrast text styles for accessibility
  static const TextStyle _highContrastDisplayLarge = TextStyle(
    fontSize: 61,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: _highContrastText,
  );

  static const TextStyle _highContrastDisplayMedium = TextStyle(
    fontSize: 49,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: _highContrastText,
  );

  static const TextStyle _highContrastDisplaySmall = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: _highContrastText,
  );

  static const TextStyle _highContrastHeadlineLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: _highContrastText,
  );

  static const TextStyle _highContrastHeadlineMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: _highContrastText,
  );

  static const TextStyle _highContrastHeadlineSmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: _highContrastText,
  );

  static const TextStyle _highContrastTitleLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: _highContrastText,
  );

  static const TextStyle _highContrastTitleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.15,
    color: _highContrastText,
  );

  static const TextStyle _highContrastTitleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.1,
    color: _highContrastText,
  );

  static const TextStyle _highContrastBodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _highContrastText,
  );

  static const TextStyle _highContrastBodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    color: _highContrastText,
  );

  static const TextStyle _highContrastBodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: _highContrastText,
  );

  static const TextStyle _highContrastLabelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.1,
    color: _highContrastText,
  );

  static const TextStyle _highContrastLabelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: _highContrastText,
  );

  static const TextStyle _highContrastLabelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: _highContrastText,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: _lightDisplayLarge,
      displayMedium: _lightDisplayMedium,
      displaySmall: _lightDisplaySmall,
      headlineLarge: _lightHeadlineLarge,
      headlineMedium: _lightHeadlineMedium,
      headlineSmall: _lightHeadlineSmall,
      titleLarge: _lightTitleLarge,
      titleMedium: _lightTitleMedium,
      titleSmall: _lightTitleSmall,
      bodyLarge: _lightBodyLarge,
      bodyMedium: _lightBodyMedium,
      bodySmall: _lightBodySmall,
      labelLarge: _lightLabelLarge,
      labelMedium: _lightLabelMedium,
      labelSmall: _lightLabelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      displayLarge: _darkDisplayLarge,
      displayMedium: _darkDisplayMedium,
      displaySmall: _darkDisplaySmall,
      headlineLarge: _darkHeadlineLarge,
      headlineMedium: _darkHeadlineMedium,
      headlineSmall: _darkHeadlineSmall,
      titleLarge: _darkTitleLarge,
      titleMedium: _darkTitleMedium,
      titleSmall: _darkTitleSmall,
      bodyLarge: _darkBodyLarge,
      bodyMedium: _darkBodyMedium,
      bodySmall: _darkBodySmall,
      labelLarge: _darkLabelLarge,
      labelMedium: _darkLabelMedium,
      labelSmall: _darkLabelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // High contrast theme for accessibility
  static ThemeData highContrastTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.highContrastLight(
      primary: _highContrastAccent,
      secondary: _highContrastAccent,
      error: _highContrastError,
      surface: _highContrastBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _highContrastText,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: _highContrastDisplayLarge,
      displayMedium: _highContrastDisplayMedium,
      displaySmall: _highContrastDisplaySmall,
      headlineLarge: _highContrastHeadlineLarge,
      headlineMedium: _highContrastHeadlineMedium,
      headlineSmall: _highContrastHeadlineSmall,
      titleLarge: _highContrastTitleLarge,
      titleMedium: _highContrastTitleMedium,
      titleSmall: _highContrastTitleSmall,
      bodyLarge: _highContrastBodyLarge,
      bodyMedium: _highContrastBodyMedium,
      bodySmall: _highContrastBodySmall,
      labelLarge: _highContrastLabelLarge,
      labelMedium: _highContrastLabelMedium,
      labelSmall: _highContrastLabelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _highContrastAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: _highContrastBackground,
      elevation: 6,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    iconTheme: const IconThemeData(
      color: _highContrastText,
      size: 24,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _highContrastAccent,
      foregroundColor: Colors.white,
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _highContrastBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: _highContrastText,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: _highContrastText,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: _highContrastAccent,
          width: 3,
        ),
      ),
      labelStyle: const TextStyle(
        color: _highContrastText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        color: _highContrastText,
        fontSize: 16,
      ),
    ),
  );

  // Accessibility helper methods
  static double getAccessibleFontSize(BuildContext context, double baseSize) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler.scale(baseSize) / baseSize;

    // Ensure minimum readable size for accessibility
    if (textScaler < 1.0) {
      return baseSize * 1.2;
    } else if (textScaler > 1.5) {
      return baseSize * 0.9;
    }
    return baseSize * textScaler;
  }

  static double getMinimumTouchTargetSize(BuildContext context) {
    return 48.0; // WCAG AA minimum touch target size
  }

  // Enhanced Typography Utilities

  /// Get responsive text size based on screen width and base size
  static double getResponsiveTextSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = 1.0;

    if (screenWidth > 600) {
      scaleFactor = 1.1; // Tablet
    } else if (screenWidth > 1024) {
      scaleFactor = 1.2; // Desktop
    }

    return baseSize * scaleFactor;
  }

  /// Get semantic text style for different content types
  static TextStyle getSemanticTextStyle(
      BuildContext context, String semanticType) {
    final textTheme = Theme.of(context).textTheme;

    switch (semanticType) {
      case 'heading':
        return textTheme.headlineMedium ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case 'subheading':
        return textTheme.titleLarge ??
            const TextStyle(fontSize: 20, fontWeight: FontWeight.w500);
      case 'body':
        return textTheme.bodyLarge ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
      case 'caption':
        return textTheme.bodySmall ??
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
      case 'button':
        return textTheme.labelLarge ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      default:
        return textTheme.bodyMedium ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    }
  }

  /// Create text style with enhanced readability features
  static TextStyle createReadableTextStyle(
    BuildContext context, {
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? lineHeight,
    double? letterSpacing,
  }) {
    final baseStyle = getSemanticTextStyle(context, 'body');

    return baseStyle.copyWith(
      fontSize: getAccessibleFontSize(context, fontSize),
      fontWeight: fontWeight,
      color: color ?? _lightText,
      height: lineHeight ?? 1.5,
      letterSpacing: letterSpacing,
    );
  }

  /// Get game-specific text styles
  static TextStyle getGameTitleStyle(BuildContext context) {
    return getSemanticTextStyle(context, 'heading').copyWith(
      fontSize: getAccessibleFontSize(context, 32),
      fontWeight: FontWeight.w700,
      color: const Color(0xFF4CAF50),
      height: 1.2,
    );
  }

  static TextStyle getGameScoreStyle(BuildContext context) {
    return getSemanticTextStyle(context, 'heading').copyWith(
      fontSize: getAccessibleFontSize(context, 28),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2E7D32),
      height: 1.1,
    );
  }

  static TextStyle getGameQuestionStyle(BuildContext context) {
    return getSemanticTextStyle(context, 'subheading').copyWith(
      fontSize: getAccessibleFontSize(context, 20),
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }

  static TextStyle getGameOptionStyle(BuildContext context) {
    return getSemanticTextStyle(context, 'body').copyWith(
      fontSize: getAccessibleFontSize(context, 16),
      fontWeight: FontWeight.w500,
      height: 1.3,
    );
  }

  /// Create gradient text style for special elements
  static TextStyle getGradientTextStyle(
      BuildContext context, List<Color> colors) {
    return getSemanticTextStyle(context, 'heading').copyWith(
      fontSize: getAccessibleFontSize(context, 24),
      fontWeight: FontWeight.w600,
      foreground: Paint()
        ..shader = LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
      height: 1.2,
    );
  }

  /// Get emphasis text style for important content
  static TextStyle getEmphasisTextStyle(BuildContext context) {
    return getSemanticTextStyle(context, 'body').copyWith(
      fontWeight: FontWeight.w600,
      color: const Color(0xFF4CAF50),
      backgroundColor: Colors.transparent,
    );
  }

  /// Get disabled text style for inactive content
  static TextStyle getDisabledTextStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return getSemanticTextStyle(context, 'body').copyWith(
      color: brightness == Brightness.dark
          ? Colors.white.withOpacity(0.38)
          : Colors.black.withOpacity(0.38),
    );
  }
}
