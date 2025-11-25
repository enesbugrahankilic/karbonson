import 'package:flutter/material.dart';

class AppTheme {
  static const Color _darkBlack = Colors.black87;
  
  // Custom text styles manually defined
  static const TextStyle _customDisplayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: _darkBlack,
  );
  
  static const TextStyle _customDisplayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _darkBlack,
  );
  
  static const TextStyle _customDisplaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: _darkBlack,
  );
  
  static const TextStyle _customHeadlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkBlack,
  );
  
  static const TextStyle _customHeadlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkBlack,
  );
  
  static const TextStyle _customHeadlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkBlack,
  );
  
  static const TextStyle _customTitleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: _darkBlack,
  );
  
  static const TextStyle _customTitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: _darkBlack,
  );
  
  static const TextStyle _customTitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _darkBlack,
  );
  
  static const TextStyle _customBodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: _darkBlack,
  );
  
  static const TextStyle _customBodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: _darkBlack,
  );
  
  static const TextStyle _customBodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: _darkBlack,
  );
  
  static const TextStyle _customLabelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: _darkBlack,
  );
  
  static const TextStyle _customLabelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _darkBlack,
  );
  
  static const TextStyle _customLabelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: _darkBlack,
  );
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: _customDisplayLarge,
      displayMedium: _customDisplayMedium,
      displaySmall: _customDisplaySmall,
      headlineLarge: _customHeadlineLarge,
      headlineMedium: _customHeadlineMedium,
      headlineSmall: _customHeadlineSmall,
      titleLarge: _customTitleLarge,
      titleMedium: _customTitleMedium,
      titleSmall: _customTitleSmall,
      bodyLarge: _customBodyLarge,
      bodyMedium: _customBodyMedium,
      bodySmall: _customBodySmall,
      labelLarge: _customLabelLarge,
      labelMedium: _customLabelMedium,
      labelSmall: _customLabelSmall,
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
      displayLarge: _customDisplayLarge,
      displayMedium: _customDisplayMedium,
      displaySmall: _customDisplaySmall,
      headlineLarge: _customHeadlineLarge,
      headlineMedium: _customHeadlineMedium,
      headlineSmall: _customHeadlineSmall,
      titleLarge: _customTitleLarge,
      titleMedium: _customTitleMedium,
      titleSmall: _customTitleSmall,
      bodyLarge: _customBodyLarge,
      bodyMedium: _customBodyMedium,
      bodySmall: _customBodySmall,
      labelLarge: _customLabelLarge,
      labelMedium: _customLabelMedium,
      labelSmall: _customLabelSmall,
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
}