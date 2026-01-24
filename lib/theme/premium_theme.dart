// lib/theme/premium_theme.dart
// 🚀 Premium Design System - Luxurious Dark/Light Theme
// Complete unified theme with premium aesthetics

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// PREMIUM COLOR PALETTE - DARK THEME
// ============================================================================
class PremiumColors {
  // Primary Brand Colors - Rich Emerald Green (Nature/Carbon focus)
  static const Color darkPrimary = Color(0xFF00D084);
  static const Color darkPrimaryVariant = Color(0xFF00A86B);
  static const Color darkPrimaryLight = Color(0xFF4CEAA6);
  static const Color darkOnPrimary = Color(0xFF00331F);

  // Secondary Accent - Warm Gold
  static const Color darkSecondary = Color(0xFFFFC107);
  static const Color darkSecondaryVariant = Color(0xFFFFB300);
  static const Color darkOnSecondary = Color(0xFF1A1A00);

  // Tertiary - Soft Purple
  static const Color darkTertiary = Color(0xFF9C8AE6);
  static const Color darkOnTertiary = Color(0xFF1E1048);

  // Background & Surface - Deep Luxury
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF12121A);
  static const Color darkSurfaceVariant = Color(0xFF1A1A24);
  static const Color darkSurfaceElevated = Color(0xFF1E1E2E);
  static const Color darkOnBackground = Color(0xFFE8E8EC);
  static const Color darkOnSurface = Color(0xFFF0F0F5);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0BC);

  // Error Colors
  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkErrorContainer = Color(0xFF3D1A1A);
  static const Color darkOnError = Color(0xFF1A0000);

  // Success Colors
  static const Color darkSuccess = Color(0xFF00D084);
  static const Color darkSuccessContainer = Color(0xFF1A3D2A);
  static const Color darkOnSuccess = Color(0xFF00331F);

  // Warning Colors
  static const Color darkWarning = Color(0xFFFFB74D);
  static const Color darkWarningContainer = Color(0xFF3D2A1A);
  static const Color darkOnWarning = Color(0xFF1A1100);

  // Info Colors
  static const Color darkInfo = Color(0xFF64B5F6);
  static const Color darkInfoContainer = Color(0xFF1A2A3D);
  static const Color darkOnInfo = Color(0xFF001A2E);

  // Outline & Borders
  static const Color darkOutline = Color(0xFF3A3A4A);
  static const Color darkOutlineVariant = Color(0xFF2A2A3A);
  static const Color darkOutlineHighContrast = Color(0xFF5A5A6A);

  // Shadows
  static const Color darkShadowColor = Color(0x40000000);

  // Gradient Colors
  static const List<Color> darkPrimaryGradient = [
    Color(0xFF00D084),
    Color(0xFF00A86B),
    Color(0xFF007A50),
  ];

  static const List<Color> darkSecondaryGradient = [
    Color(0xFFFFC107),
    Color(0xFFFFB300),
    Color(0xFFFF9500),
  ];

  static const List<Color> darkLuxuryGradient = [
    Color(0xFF0A0A0F),
    Color(0xFF12121A),
    Color(0xFF1A1A24),
  ];

  // Card & Surface Gradients
  static const List<Color> darkCardGradient = [
    Color(0xFF1A1A24),
    Color(0xFF12121A),
  ];

  static const List<Color> darkElevatedCardGradient = [
    Color(0xFF1E1E2E),
    Color(0xFF16161F),
  ];

  // Accent Colors for gamification
  static const Color darkGold = Color(0xFFFFD700);
  static const Color darkSilver = Color(0xFFC0C0C0);
  static const Color darkBronze = Color(0xFFCD7F32);

  // Quiz/Score Colors
  static const Color darkScoreExcellent = Color(0xFF00D084);
  static const Color darkScoreGood = Color(0xFF64B5F6);
  static const Color darkScoreAverage = Color(0xFFFFB74D);
  static const Color darkScorePoor = Color(0xFFFF6B6B);

  // Streak & Achievement
  static const Color darkStreak = Color(0xFFFF6B35);
  static const Color darkAchievement = Color(0xFFFFD700);
  static const Color darkRankDiamond = Color(0xFFB9F2FF);
  static const Color darkRankGold = Color(0xFFFFD700);
  static const Color darkRankSilver = Color(0xFFC0C0C0);
  static const Color darkRankBronze = Color(0xFFCD7F32);

  // Premium Effects
  static const Color darkGlowPrimary = Color(0x4000D084);
  static const Color darkGlowSecondary = Color(0x40FFC107);
  static const Color darkGlowSuccess = Color(0x4000D084);
  static const Color darkGlowError = Color(0x40FF6B6B);

  // ============================================================================
  // PREMIUM COLOR PALETTE - LIGHT THEME
  // ============================================================================
  
  // Primary Brand Colors
  static const Color lightPrimary = Color(0xFF008A5C);
  static const Color lightPrimaryVariant = Color(0xFF00A86B);
  static const Color lightPrimaryLight = Color(0xFF4CEAA6);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  // Secondary Accent
  static const Color lightSecondary = Color(0xFFFF9500);
  static const Color lightSecondaryVariant = Color(0xFFFFB300);
  static const Color lightOnSecondary = Color(0xFF1A1A00);

  // Tertiary
  static const Color lightTertiary = Color(0xFF7C4DFF);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);

  // Background & Surface
  static const Color lightBackground = Color(0xFFF8F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F0F5);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1A1A24);
  static const Color lightOnSurface = Color(0xFF1A1A24);
  static const Color lightOnSurfaceVariant = Color(0xFF5A5A66);

  // Error Colors
  static const Color lightError = Color(0xFFE53935);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // Success Colors
  static const Color lightSuccess = Color(0xFF00A86B);
  static const Color lightSuccessContainer = Color(0xFFB8F5D4);
  static const Color lightOnSuccess = Color(0xFF002211);

  // Warning Colors
  static const Color lightWarning = Color(0xFFFF9800);
  static const Color lightWarningContainer = Color(0xFFFFE0B2);
  static const Color lightOnWarning = Color(0xFF1A1100);

  // Info Colors
  static const Color lightInfo = Color(0xFF2196F3);
  static const Color lightInfoContainer = Color(0xFFBBDEFB);
  static const Color lightOnInfo = Color(0xFF001A2E);

  // Outline & Borders
  static const Color lightOutline = Color(0xFFD0D0D8);
  static const Color lightOutlineVariant = Color(0xFFE0E0E8);
  static const Color lightOutlineHighContrast = Color(0xFF909098);

  // Shadows
  static const Color lightShadowColor = Color(0x20000000);

  // Gradient Colors
  static const List<Color> lightPrimaryGradient = [
    Color(0xFF008A5C),
    Color(0xFF00A86B),
    Color(0xFF4CEAA6),
  ];

  static const List<Color> lightSecondaryGradient = [
    Color(0xFFFF9500),
    Color(0xFFFFB300),
    Color(0xFFFFC107),
  ];

  static const List<Color> lightLuxuryGradient = [
    Color(0xFFF8F8FC),
    Color(0xFFFFFFFF),
    Color(0xFFF0F0F5),
  ];

  // Card & Surface Gradients
  static const List<Color> lightCardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8F8FC),
  ];

  static const List<Color> lightElevatedCardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF5F5FA),
  ];

  // Accent Colors for gamification
  static const Color lightGold = Color(0xFFFFD700);
  static const Color lightSilver = Color(0xFFE0E0E0);
  static const Color lightBronze = Color(0xFFCD7F32);

  // Quiz/Score Colors
  static const Color lightScoreExcellent = Color(0xFF008A5C);
  static const Color lightScoreGood = Color(0xFF1976D2);
  static const Color lightScoreAverage = Color(0xFFFF9800);
  static const Color lightScorePoor = Color(0xFFE53935);

  // Streak & Achievement
  static const Color lightStreak = Color(0xFFFF5722);
  static const Color lightAchievement = Color(0xFFFFD700);
  static const Color lightRankDiamond = Color(0xFF00BFFF);
  static const Color lightRankGold = Color(0xFFFFD700);
  static const Color lightRankSilver = Color(0xFFC0C0C0);
  static const Color lightRankBronze = Color(0xFFCD7F32);

  // Premium Effects
  static const Color lightGlowPrimary = Color(0x40008A5C);
  static const Color lightGlowSecondary = Color(0x40FF9500);
  static const Color lightGlowSuccess = Color(0x4000A86B);
  static const Color lightGlowError = Color(0x40E53935);

  // Utility method to get colors based on brightness
  static Color primary(bool isDark) => isDark ? darkPrimary : lightPrimary;
  static Color primaryVariant(bool isDark) => isDark ? darkPrimaryVariant : lightPrimaryVariant;
  static Color secondary(bool isDark) => isDark ? darkSecondary : lightSecondary;
  static Color background(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color onPrimary(bool isDark) => isDark ? darkOnPrimary : lightOnPrimary;
  static Color onBackground(bool isDark) => isDark ? darkOnBackground : lightOnBackground;
  static Color onSurface(bool isDark) => isDark ? darkOnSurface : lightOnSurface;
  static Color error(bool isDark) => isDark ? darkError : lightError;
  static Color outline(bool isDark) => isDark ? darkOutline : lightOutline;
}

// ============================================================================
// PREMIUM TYPOGRAPHY
// ============================================================================
class PremiumTypography {
  static const String fontFamily = 'SF Pro Display';
  static const String fontFamilyFallback = 'Arial';

  static TextStyle displayLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
    color: _textPrimary(isDark),
  );

  static TextStyle displayMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
    letterSpacing: 0,
    color: _textPrimary(isDark),
  );

  static TextStyle displaySmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: 0,
    color: _textPrimary(isDark),
  );

  static TextStyle headlineLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
    color: _textPrimary(isDark),
  );

  static TextStyle headlineMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: 0,
    color: _textPrimary(isDark),
  );

  static TextStyle headlineSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
    color: _textPrimary(isDark),
  );

  static TextStyle titleLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: 0,
    color: _textPrimary(isDark),
  );

  static TextStyle titleMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
    color: _textPrimary(isDark),
  );

  static TextStyle titleSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: _textPrimary(isDark),
  );

  static TextStyle bodyLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
    color: _textSecondary(isDark),
  );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: _textSecondary(isDark),
  );

  static TextStyle bodySmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: _textSecondary(isDark),
  );

  static TextStyle labelLarge(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: _textPrimary(isDark),
  );

  static TextStyle labelMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
    color: _textSecondary(isDark),
  );

  static TextStyle labelSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
    color: _textSecondary(isDark),
  );

  static Color _textPrimary(bool isDark) => isDark 
    ? PremiumColors.darkOnBackground 
    : PremiumColors.lightOnBackground;

  static Color _textSecondary(bool isDark) => isDark 
    ? PremiumColors.darkOnSurfaceVariant 
    : PremiumColors.lightOnSurfaceVariant;
}

// ============================================================================
// PREMIUM SPACING & RADIUS
// ============================================================================
class PremiumSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 56;
  static const double massive = 72;
}

class PremiumRadius {
  static const double none = 0;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 9999;
}

// ============================================================================
// PREMIUM SHADOWS
// ============================================================================
class PremiumShadows {
  static BoxShadow subtle(bool isDark) => BoxShadow(
    color: (isDark ? PremiumColors.darkShadowColor : PremiumColors.lightShadowColor),
    blurRadius: 8,
    offset: const Offset(0, 2),
    spreadRadius: 0,
  );

  static BoxShadow medium(bool isDark) => BoxShadow(
    color: (isDark ? PremiumColors.darkShadowColor : PremiumColors.lightShadowColor),
    blurRadius: 16,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  static BoxShadow large(bool isDark) => BoxShadow(
    color: (isDark ? PremiumColors.darkShadowColor : PremiumColors.lightShadowColor),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );

  static List<BoxShadow> glowPrimary(bool isDark, [double opacity = 0.4]) => [
    BoxShadow(
      color: (isDark ? PremiumColors.darkGlowPrimary : PremiumColors.lightGlowPrimary).withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 0),
      spreadRadius: 4,
    ),
  ];

  static List<BoxShadow> glowSuccess(bool isDark, [double opacity = 0.4]) => [
    BoxShadow(
      color: (isDark ? PremiumColors.darkGlowSuccess : PremiumColors.lightGlowSuccess).withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 0),
      spreadRadius: 4,
    ),
  ];
}

// ============================================================================
// PREMIUM ANIMATIONS
// ============================================================================
class PremiumAnimations {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Curve defaultCurve = Curves.easeInOutCubic;
}

// ============================================================================
// PREMIUM THEME DATA
// ============================================================================
ThemeData createPremiumTheme(bool isDark) {
  final primary = isDark ? PremiumColors.darkPrimary : PremiumColors.lightPrimary;
  final secondary = isDark ? PremiumColors.darkSecondary : PremiumColors.lightSecondary;
  final background = isDark ? PremiumColors.darkBackground : PremiumColors.lightBackground;
  final surface = isDark ? PremiumColors.darkSurface : PremiumColors.lightSurface;
  final surfaceElevated = isDark ? PremiumColors.darkSurfaceElevated : PremiumColors.lightSurfaceElevated;
  final onPrimary = isDark ? PremiumColors.darkOnPrimary : PremiumColors.lightOnPrimary;
  final onBackground = isDark ? PremiumColors.darkOnBackground : PremiumColors.lightOnBackground;
  final onSurface = isDark ? PremiumColors.darkOnSurface : PremiumColors.lightOnSurface;
  final onSurfaceVariant = isDark ? PremiumColors.darkOnSurfaceVariant : PremiumColors.lightOnSurfaceVariant;
  final error = isDark ? PremiumColors.darkError : PremiumColors.lightError;
  final outline = isDark ? PremiumColors.darkOutline : PremiumColors.lightOutline;
  
  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    cardColor: surfaceElevated,
    colorScheme: isDark 
      ? const ColorScheme.dark(
          primary: PremiumColors.darkPrimary,
          onPrimary: PremiumColors.darkOnPrimary,
          secondary: PremiumColors.darkSecondary,
          onSecondary: PremiumColors.darkOnSecondary,
          background: PremiumColors.darkBackground,
          onBackground: PremiumColors.darkOnBackground,
          surface: PremiumColors.darkSurface,
          onSurface: PremiumColors.darkOnSurface,
          surfaceVariant: PremiumColors.darkSurfaceVariant,
          onSurfaceVariant: PremiumColors.darkOnSurfaceVariant,
          error: PremiumColors.darkError,
          onError: PremiumColors.darkOnError,
          outline: PremiumColors.darkOutline,
        )
      : const ColorScheme.light(
          primary: PremiumColors.lightPrimary,
          onPrimary: PremiumColors.lightOnPrimary,
          secondary: PremiumColors.lightSecondary,
          onSecondary: PremiumColors.lightOnSecondary,
          background: PremiumColors.lightBackground,
          onBackground: PremiumColors.lightOnBackground,
          surface: PremiumColors.lightSurface,
          onSurface: PremiumColors.lightOnSurface,
          surfaceVariant: PremiumColors.lightSurfaceVariant,
          onSurfaceVariant: PremiumColors.lightOnSurfaceVariant,
          error: PremiumColors.lightError,
          onError: PremiumColors.lightOnError,
          outline: PremiumColors.lightOutline,
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumRadius.lg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumSpacing.xl,
          vertical: PremiumSpacing.md,
        ),
        textStyle: PremiumTypography.labelLarge(isDark),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: PremiumTypography.titleLarge(isDark),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: background,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: PremiumTypography.displayLarge(isDark),
      displayMedium: PremiumTypography.displayMedium(isDark),
      displaySmall: PremiumTypography.displaySmall(isDark),
      headlineLarge: PremiumTypography.headlineLarge(isDark),
      headlineMedium: PremiumTypography.headlineMedium(isDark),
      headlineSmall: PremiumTypography.headlineSmall(isDark),
      titleLarge: PremiumTypography.titleLarge(isDark),
      titleMedium: PremiumTypography.titleMedium(isDark),
      titleSmall: PremiumTypography.titleSmall(isDark),
      bodyLarge: PremiumTypography.bodyLarge(isDark),
      bodyMedium: PremiumTypography.bodyMedium(isDark),
      bodySmall: PremiumTypography.bodySmall(isDark),
      labelLarge: PremiumTypography.labelLarge(isDark),
      labelMedium: PremiumTypography.labelMedium(isDark),
      labelSmall: PremiumTypography.labelSmall(isDark),
    ),
    useMaterial3: true,
    fontFamily: PremiumTypography.fontFamily,
  );
}

// ============================================================================
// PREMIUM RANK TYPE ENUM
// ============================================================================

enum PremiumRankType { diamond, gold, silver, bronze }

// ============================================================================
// PREMIUM WIDGET HELPERS
// ============================================================================

/// Premium gradient container
class PremiumGradientContainer extends StatelessWidget {
  final List<Color> gradient;
  final Widget? child;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const PremiumGradientContainer({
    super.key,
    required this.gradient,
    this.child,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.shadows,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        shape: shape,
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

/// Premium card with elevation
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.shadows,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(PremiumRadius.lg),
        boxShadow: shadows ?? [PremiumShadows.subtle(false)],
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(PremiumRadius.lg),
        child: card,
      );
    }

    return card;
  }
}

/// Premium score badge
class PremiumScoreBadge extends StatelessWidget {
  final int score;
  final bool isDark;
  final double size;

  const PremiumScoreBadge({
    super.key,
    required this.score,
    required this.isDark,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isDark 
      ? PremiumColors.darkPrimaryGradient 
      : PremiumColors.lightPrimaryGradient;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        boxShadow: PremiumShadows.glowPrimary(isDark),
      ),
      child: Center(
        child: Text(
          score.toString(),
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: isDark ? PremiumColors.darkOnBackground : PremiumColors.lightOnPrimary,
          ),
        ),
      ),
    );
  }
}

/// Premium streak counter
class PremiumStreakCounter extends StatelessWidget {
  final int streak;
  final bool isDark;

  const PremiumStreakCounter({
    super.key,
    required this.streak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? PremiumColors.darkStreak : PremiumColors.lightStreak;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: PremiumSpacing.xs),
          Text(
            streak.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium rank indicator
class PremiumRankIndicator extends StatelessWidget {
  final String rank;
  final bool isDark;
  final PremiumRankType rankType;

  const PremiumRankIndicator({
    super.key,
    required this.rank,
    required this.isDark,
    required this.rankType,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRankColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(PremiumRadius.full),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRankIcon(), color: color, size: 18),
          const SizedBox(width: PremiumSpacing.xs),
          Text(
            rank,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor() {
    switch (rankType) {
      case PremiumRankType.diamond:
        return isDark ? PremiumColors.darkRankDiamond : PremiumColors.lightRankDiamond;
      case PremiumRankType.gold:
        return isDark ? PremiumColors.darkRankGold : PremiumColors.lightRankGold;
      case PremiumRankType.silver:
        return isDark ? PremiumColors.darkRankSilver : PremiumColors.lightRankSilver;
      case PremiumRankType.bronze:
        return isDark ? PremiumColors.darkRankBronze : PremiumColors.lightRankBronze;
    }
  }

  IconData _getRankIcon() {
    switch (rankType) {
      case PremiumRankType.diamond: return Icons.diamond;
      case PremiumRankType.gold: return Icons.emoji_events;
      case PremiumRankType.silver: return Icons.military_tech;
      case PremiumRankType.bronze: return Icons.workspace_premium;
    }
  }
}
