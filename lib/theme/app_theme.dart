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
  static const Color _highContrastAccent = Color(0xFF0066CC); // WCAG AA compliant blue
  static const Color _highContrastError = Color(0xFFCC0000); // WCAG AA compliant red
  
  // Custom text styles for LIGHT theme
  static const TextStyle _lightDisplayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: _lightText,
  );
  
  static const TextStyle _lightDisplayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _lightText,
  );
  
  static const TextStyle _lightDisplaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _lightText,
  );
  
  static const TextStyle _lightHeadlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _lightText,
  );
  
  static const TextStyle _lightHeadlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _lightText,
  );
  
  static const TextStyle _lightHeadlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _lightText,
  );
  
  static const TextStyle _lightTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _lightText,
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
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: _lightText,
  );
  
  static const TextStyle _lightBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: _lightText,
  );
  
  static const TextStyle _lightBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: _lightSecondaryText,
  );
  
  static const TextStyle _lightLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _lightText,
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
      background: _highContrastBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _highContrastText,
      onBackground: _highContrastText,
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
    final textScaleFactor = mediaQuery.textScaleFactor;
    
    // Ensure minimum readable size for accessibility
    if (textScaleFactor < 1.0) {
      return baseSize * 1.2;
    } else if (textScaleFactor > 1.5) {
      return baseSize * 0.9;
    }
    return baseSize * textScaleFactor;
  }

  static double getMinimumTouchTargetSize(BuildContext context) {
    return 48.0; // WCAG AA minimum touch target size
  }
}