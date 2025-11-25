import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _darkBlack = Colors.black87;
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.montserratTextTheme().copyWith(
      displayLarge: GoogleFonts.montserratTextTheme().displayLarge,
      displayMedium: GoogleFonts.montserratTextTheme().displayMedium,
      displaySmall: GoogleFonts.montserratTextTheme().displaySmall,
      headlineLarge: GoogleFonts.montserratTextTheme().headlineLarge,
      headlineMedium: GoogleFonts.montserratTextTheme().headlineMedium,
      headlineSmall: GoogleFonts.montserratTextTheme().headlineSmall,
      titleLarge: GoogleFonts.montserratTextTheme().titleLarge,
      titleMedium: GoogleFonts.montserratTextTheme().titleMedium,
      titleSmall: GoogleFonts.montserratTextTheme().titleSmall,
      bodyLarge: GoogleFonts.montserratTextTheme().bodyLarge,
      bodyMedium: GoogleFonts.montserratTextTheme().bodyMedium,
      bodySmall: GoogleFonts.montserratTextTheme().bodySmall,
      labelLarge: GoogleFonts.montserratTextTheme().labelLarge,
      labelMedium: GoogleFonts.montserratTextTheme().labelMedium,
      labelSmall: GoogleFonts.montserratTextTheme().labelSmall,
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
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).displayLarge,
      displayMedium: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).displayMedium,
      displaySmall: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).displaySmall,
      headlineLarge: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).headlineLarge,
      headlineMedium: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).headlineMedium,
      headlineSmall: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).headlineSmall,
      titleLarge: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).titleLarge,
      titleMedium: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).titleMedium,
      titleSmall: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).titleSmall,
      bodyLarge: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).bodyLarge,
      bodyMedium: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).bodyMedium,
      bodySmall: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).bodySmall,
      labelLarge: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).labelLarge,
      labelMedium: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).labelMedium,
      labelSmall: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).labelSmall,
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