// lib/theme/apple_design_system.dart
// Apple Quality Design System - Premium UI Components

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_system.dart';
import 'theme_colors.dart';

/// Apple Quality Design System - Premium iOS-inspired components
class AppleDesignSystem {
  // TYPOGRAPHY - San Francisco inspired
  static TextStyle get headline1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static TextStyle get headline2 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle get headline3 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get title1 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.4,
  );

  static TextStyle get title2 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36,
    height: 1.4,
  );

  static TextStyle get body1 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.5,
  );

  static TextStyle get body2 => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.5,
  );

  static TextStyle get caption1 => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.4,
  );

  static TextStyle get caption2 => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  // SPACING (8pt baseline)
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;

  // CORNER RADIUS - Subtle & Apple-like
  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radiusCircle = 9999;

  // SHADOWS - Subtle depth
  static List<BoxShadow> shadowSoft(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowBase(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge(BuildContext context) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  // PREMIUM BUTTON
  static ButtonStyle premiumButtonStyle(
    BuildContext context, {
    Color? backgroundColor,
    double height = 52,
  }) =>
      ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        padding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
        minimumSize: Size(double.infinity, height),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return 0;
          }
          return 0;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            final pressedColor = backgroundColor?.withValues(alpha: 0.9) ?? 
                   Theme.of(context).primaryColor.withValues(alpha: 0.9);
            return pressedColor;
          }
          return backgroundColor ?? Theme.of(context).primaryColor;
        }),
      );

  // SECONDARY BUTTON
  static ButtonStyle secondaryButtonStyle(BuildContext context) =>
      OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        side: BorderSide(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        padding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
        minimumSize: const Size(double.infinity, 52),
      );

  // TERTIARY BUTTON
  static ButtonStyle tertiaryButtonStyle(BuildContext context) =>
      TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        padding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
      );

  // PREMIUM CARD
  static Widget premiumCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(spacing16),
    double cornerRadius = radius12,
    List<BoxShadow>? shadows,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: shadows ?? shadowBase(context),
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: card,
      );
    }

    return card;
  }

  // GLASS MORPHISM
  static Widget glassmorphism({
    required Widget child,
    Color? color,
    double blur = 10,
    double opacity = 0.1,
  }) =>
      BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      );

  // SMOOTH DIVIDER
  static Widget smoothDivider({
    Color? color,
    double height = 0.5,
  }) =>
      Divider(
        color: color?.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1),
        height: height,
        thickness: height,
      );

  // PREMIUM SWITCH
  static Widget premiumSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) =>
      Switch.adaptive(
        value: value,
        onChanged: (val) {
          HapticFeedback.lightImpact();
          onChanged(val);
        },
        activeThumbColor: activeColor,
      );

  // BADGE
  static Widget badge({
    required String label,
    Color? backgroundColor,
    Color? textColor,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing8,
          vertical: spacing4,
        ),
        child: Text(
          label,
          style: caption2.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}
