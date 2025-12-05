// lib/widgets/home_button.dart
// Reusable Home button widget for consistent navigation across all pages

import 'package:flutter/material.dart';
import '../core/navigation/app_router.dart';

/// A prominent Home button/icon widget that navigates back to the main Dashboard.
/// Should be placed in the top-left corner of all pages (AppBar leading).
class HomeButton extends StatelessWidget {
  /// Optional callback when home is pressed (before navigation)
  final VoidCallback? onPressed;
  
  /// Whether to use a house icon (true) or back arrow (false)
  final bool useHouseIcon;
  
  /// Custom icon color (defaults to theme primary color)
  final Color? iconColor;
  
  /// Custom icon size
  final double iconSize;
  
  /// Whether to show a tooltip
  final bool showTooltip;
  
  /// Custom tooltip text
  final String tooltipText;

  const HomeButton({
    super.key,
    this.onPressed,
    this.useHouseIcon = true,
    this.iconColor,
    this.iconSize = 24.0,
    this.showTooltip = true,
    this.tooltipText = 'Ana Sayfa',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = iconColor ?? theme.colorScheme.primary;
    
    Widget button = IconButton(
      icon: Icon(
        useHouseIcon ? Icons.home_rounded : Icons.arrow_back_ios_new_rounded,
        color: effectiveColor,
        size: iconSize,
      ),
      onPressed: () {
        // Execute optional callback first
        onPressed?.call();
        
        // Navigate to login page (main dashboard)
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      },
      splashRadius: 24,
      padding: const EdgeInsets.all(8),
    );
    
    if (showTooltip) {
      button = Tooltip(
        message: tooltipText,
        child: button,
      );
    }
    
    return button;
  }
}

/// A more prominent Home button with background container
class HomeButtonWithBackground extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String tooltipText;

  const HomeButtonWithBackground({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40.0,
    this.tooltipText = 'Ana Sayfa',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final effectiveIconColor = iconColor ?? theme.colorScheme.onPrimaryContainer;
    
    return Tooltip(
      message: tooltipText,
      child: Material(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onPressed?.call();
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              Icons.home_rounded,
              color: effectiveIconColor,
              size: size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension method to easily add HomeButton to AppBar
extension AppBarHomeExtension on AppBar {
  /// Creates a copy of this AppBar with HomeButton as leading widget
  static AppBar withHomeButton({
    required String title,
    List<Widget>? actions,
    Color? backgroundColor,
    double? elevation,
    bool centerTitle = false,
    PreferredSizeWidget? bottom,
    bool useHouseIcon = true,
  }) {
    return AppBar(
      leading: HomeButton(useHouseIcon: useHouseIcon),
      title: Text(title),
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }
}
