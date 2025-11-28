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

  /// Standard card decoration with consistent styling
  static BoxDecoration getCardDecoration(BuildContext context, {
    double? borderRadius,
    Color? backgroundColor,
    double? elevation,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? ThemeColors.getCardBackground(context),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
      boxShadow: [
        BoxShadow(
          color: ThemeColors.getShadow(context),
          blurRadius: elevation ?? elevationM,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Standard button style for primary actions
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: ThemeColors.getPrimaryButtonColor(context),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingXl, 
        vertical: spacingM
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: elevationS,
      minimumSize: const Size.fromHeight(48), // Accessibility touch target
    );
  }

  /// Standard button style for secondary actions
  static ButtonStyle getSecondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: ThemeColors.getSecondaryButtonColor(context),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingXl, 
        vertical: spacingM
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: spacingXl, 
        vertical: spacingM
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: spacingL, 
        vertical: spacingM
      ),
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
          color: ThemeColors.getPrimaryButtonColor(context), 
          width: 2
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(
          color: ThemeColors.getErrorColor(context), 
          width: 2
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide(
          color: ThemeColors.getErrorColor(context), 
          width: 2
        ),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      hintStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      errorStyle: TextStyle(
        color: ThemeColors.getErrorColor(context), 
        fontSize: 12
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM, 
        vertical: spacingM
      ),
    );
  }

  /// Standard text styles for consistent typography
  static TextStyle getTitleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
      color: ThemeColors.getTitleColor(context),
      fontWeight: FontWeight.bold,
    ) ?? const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2E7D32),
    );
  }

  static TextStyle getTitleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      color: ThemeColors.getText(context),
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
  }

  static TextStyle getBodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: ThemeColors.getText(context),
    ) ?? const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    );
  }

  static TextStyle getBodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: ThemeColors.getText(context),
    ) ?? const TextStyle(
      fontSize: 14,
      color: Colors.black87,
    );
  }

  static TextStyle getLabelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
      color: ThemeColors.getText(context),
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
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
  static Widget loadingIndicator(BuildContext context, {
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
}