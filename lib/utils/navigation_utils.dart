// lib/utils/navigation_utils.dart
// Enhanced navigation utilities with smooth transitions and accessibility

import 'package:flutter/material.dart';

/// Enhanced navigation utilities for better user experience
class NavigationUtils {
  /// Default transition duration for page changes
  static const Duration _defaultTransitionDuration =
      Duration(milliseconds: 300);

  /// Default curve for animations
  static const Curve _defaultCurve = Curves.easeInOut;

  /// Navigate to a new page with smooth slide transition
  static Future<T?> pushWithSlideTransition<T>(
    BuildContext context,
    Widget page, {
    bool isSlideFromRight = true,
    Duration? duration,
    Curve? curve,
  }) {
    return Navigator.push<T>(
      context,
      _createSlideRoute(
        context,
        page,
        isFromRight: isSlideFromRight,
        duration: duration,
        curve: curve,
      ),
    );
  }

  /// Navigate to a new page with fade transition
  static Future<T?> pushWithFadeTransition<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
    Curve? curve,
  }) {
    return Navigator.push<T>(
      context,
      _createFadeRoute(
        context,
        page,
        duration: duration,
        curve: curve,
      ),
    );
  }

  /// Navigate to a new page with scale transition
  static Future<T?> pushWithScaleTransition<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
    Curve? curve,
  }) {
    return Navigator.push<T>(
      context,
      _createScaleRoute(
        context,
        page,
        duration: duration,
        curve: curve,
      ),
    );
  }

  /// Navigate with custom page route
  static Future<T?> pushWithCustomRoute<T>(
    BuildContext context,
    Widget page, {
    required PageRouteBuilder<T> routeBuilder,
  }) {
    return Navigator.push<T>(context, routeBuilder);
  }

  /// Push replacement with slide transition
  static Future<T?> pushReplacementWithSlideTransition<T, TO>(
    BuildContext context,
    Widget page, {
    TO? result,
    bool isSlideFromRight = true,
    Duration? duration,
    Curve? curve,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      _createSlideRoute(
        context,
        page,
        isFromRight: isSlideFromRight,
        duration: duration,
        curve: curve,
      ),
      result: result,
    );
  }

  /// Push and remove until with slide transition
  static Future<T?> pushAndRemoveUntilWithSlideTransition<T>(
    BuildContext context,
    Widget page,
    RoutePredicate predicate, {
    bool isSlideFromRight = true,
    Duration? duration,
    Curve? curve,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      _createSlideRoute(
        context,
        page,
        isFromRight: isSlideFromRight,
        duration: duration,
        curve: curve,
      ),
      predicate,
    );
  }

  /// Show enhanced modal dialog with accessibility
  static Future<T?> showEnhancedDialog<T>(
    BuildContext context, {
    required Widget dialog,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      builder: (context) => dialog,
    );
  }

  /// Show bottom sheet with enhanced styling
  static PersistentBottomSheetController showEnhancedBottomSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool enableDrag = true,
  }) {
    return showBottomSheet(
      context: context,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      enableDrag: enableDrag,
    );
  }

  /// Show modern bottom modal sheet
  static Future<T?> showModernBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    double? maxHeight,
    EdgeInsets? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            // Children
            ...children,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Handle system back button with custom behavior
  static Future<bool> handleSystemBackButton(
    BuildContext context, {
    VoidCallback? onBackPressed,
    bool showConfirmation = false,
    String? confirmationMessage,
  }) async {
    if (onBackPressed != null) {
      if (showConfirmation && confirmationMessage != null) {
        final shouldBack = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Çıkış'),
            content: Text(confirmationMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Çık'),
              ),
            ],
          ),
        );

        if (shouldBack == true) {
          onBackPressed();
          return true;
        }
        return false;
      } else {
        onBackPressed();
        return true;
      }
    }

    // Default behavior - pop the route
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
      return true;
    }

    return false;
  }

  /// Create breadcrumbs for navigation hierarchy
  static Widget createBreadcrumbs(
    BuildContext context, {
    required List<BreadcrumbItem> items,
    String? separator,
  }) {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index > 0)
              Text(
                separator ?? '›',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            if (item.onTap != null)
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    item.label,
                    style: item.isActive
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            )
                        : Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                  ),
                ),
              )
            else
              Text(
                item.label,
                style: item.isActive
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
              ),
          ],
        );
      }).toList(),
    );
  }

  // Private helper methods

  static PageRoute<T> _createSlideRoute<T>(
    BuildContext context,
    Widget page, {
    required bool isFromRight,
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? _defaultTransitionDuration,
      reverseTransitionDuration: duration ?? _defaultTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: Offset(isFromRight ? 1.0 : -1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve ?? _defaultCurve,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve ?? _defaultCurve,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static PageRoute<T> _createFadeRoute<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? _defaultTransitionDuration,
      reverseTransitionDuration: duration ?? _defaultTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static PageRoute<T> _createScaleRoute<T>(
    BuildContext context,
    Widget page, {
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? _defaultTransitionDuration,
      reverseTransitionDuration: duration ?? _defaultTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Breadcrumb item for navigation hierarchy
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const BreadcrumbItem({
    required this.label,
    this.onTap,
    this.isActive = false,
  });
}
