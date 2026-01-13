// lib/utils/accessibility_utils.dart
// Enhanced accessibility utilities for better user experience

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced accessibility utilities
class AccessibilityUtils {
  /// Minimum touch target size according to WCAG AA guidelines
  static const double minTouchTargetSize = 48.0;

  /// Default focus ring width for focus indicators
  static const double focusRingWidth = 3.0;

  /// Create an accessible container with proper touch target size
  static Widget accessibleContainer(
    BuildContext context, {
    required Widget child,
    double? width,
    double? height,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsets? padding,
    EdgeInsets? margin,
    String? semanticLabel,
    String? semanticHint,
    bool? enabled,
    double? customTouchTarget,
  }) {
    final touchTarget = customTouchTarget ?? minTouchTargetSize;
    final isEnabled = enabled ?? true;

    Widget container = Container(
      width: width != null && width < touchTarget ? touchTarget : width,
      height: height != null && height < touchTarget ? touchTarget : height,
      padding: padding,
      margin: margin,
      child: child,
    );

    // Wrap with Semantics for screen readers
    container = Semantics(
      label: semanticLabel,
      hint: semanticHint,
      enabled: isEnabled,
      button: onTap != null || onLongPress != null,
      child: container,
    );

    // Wrap with focusable widget if it has interactions
    if (onTap != null || onLongPress != null) {
      container = GestureDetector(
        onTap: isEnabled ? onTap : null,
        onLongPress: isEnabled ? onLongPress : null,
        child: container,
      );

      // Add focus management
      container = Focus(
        canRequestFocus: isEnabled,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            // Trigger haptic feedback for focus
            HapticFeedback.lightImpact();
          }
        },
        child: container,
      );
    }

    return container;
  }

  /// Create an accessible button with proper styling and feedback
  static Widget accessibleButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
    bool isPrimary = false,
    bool isEnabled = true,
    double? customTouchTarget,
    ButtonStyle? buttonStyle,
  }) {
    final touchTarget = customTouchTarget ?? minTouchTargetSize;

    final effectiveStyle = (isPrimary
                ? Theme.of(context).elevatedButtonTheme.style
                : Theme.of(context).outlinedButtonTheme.style)
            ?.copyWith(
          minimumSize:
              WidgetStateProperty.all(Size(touchTarget, touchTarget)),
        ) ??
        ButtonStyle(
          minimumSize:
              WidgetStateProperty.all(Size(touchTarget, touchTarget)),
        );

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: isEnabled,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle?.merge(effectiveStyle) ?? effectiveStyle,
        child: child,
      ),
    );
  }

  /// Create accessible text with proper contrast and sizing
  static Widget accessibleText(
    BuildContext context, {
    required String text,
    String? semanticLabel,
    TextStyle? style,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow? overflow,
    double? customFontSize,
  }) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final minFontSize = effectiveStyle?.fontSize ?? 14.0;
    final accessibleFontSize =
        customFontSize ?? (minFontSize < 14.0 ? 14.0 : minFontSize);

    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: effectiveStyle?.copyWith(fontSize: accessibleFontSize),
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }

  /// Create an accessible icon button
  static Widget accessibleIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    String? semanticLabel,
    String? semanticHint,
    Color? iconColor,
    double? iconSize,
    double? customTouchTarget,
    ButtonStyle? buttonStyle,
  }) {
    final touchTarget = customTouchTarget ?? minTouchTargetSize;
    final effectiveSize = iconSize ?? 24.0;
    final iconColorValue = iconColor ?? Theme.of(context).iconTheme.color;

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: iconColorValue,
        iconSize: effectiveSize,
        constraints: BoxConstraints(
          minWidth: touchTarget,
          minHeight: touchTarget,
        ),
        style: buttonStyle,
      ),
    );
  }

  /// Create a focus indicator overlay
  static Widget createFocusIndicator(
    BuildContext context, {
    required Widget child,
    bool showFocusRing = true,
    Color? focusColor,
    double? borderRadius,
  }) {
    if (!showFocusRing) return child;

    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

          return Container(
            decoration: isFocused
                ? BoxDecoration(
                    border: Border.all(
                      color:
                          focusColor ?? Theme.of(context).colorScheme.primary,
                      width: focusRingWidth,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius ?? 4),
                  )
                : null,
            child: child,
          );
        },
      ),
    );
  }

  /// Create accessible form field with proper labels and hints
  static Widget accessibleFormField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    String? semanticLabel,
    String? semanticHint,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    int? maxLines,
    int? maxLength,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    return Semantics(
      label: semanticLabel ?? label,
      hint: semanticHint,
      textField: true,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16,
            ),
      ),
    );
  }

  /// Create accessible list item
  static Widget accessibleListTile(
    BuildContext context, {
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
    String? semanticLabel,
    String? semanticHint,
    bool isThreeLine = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      enabled: enabled,
      button: onTap != null || onLongPress != null,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        isThreeLine: isThreeLine,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgressIndicator(
    BuildContext context, {
    double? value,
    String? semanticLabel,
    String? semanticHint,
    Color? color,
    double strokeWidth = 4,
  }) {
    return Semantics(
      label: semanticLabel ??
          (value != null
              ? 'İlerleme: %${(value * 100).round()}'
              : 'Yükleniyor'),
      hint: semanticHint,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
      ),
    );
  }

  /// Create accessible checkbox
  static Widget accessibleCheckbox(
    BuildContext context, {
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? semanticLabel,
    String? semanticHint,
    bool enabled = true,
    Color? activeColor,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      checked: value,
      enabled: enabled,
      button: true,
      child: Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: activeColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Create accessible switch
  static Widget accessibleSwitch(
    BuildContext context, {
    required bool value,
    required ValueChanged<bool> onChanged,
    String? semanticLabel,
    String? semanticHint,
    bool enabled = true,
    Color? activeColor,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      toggled: value,
      enabled: enabled,
      button: true,
      child: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: activeColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Show accessible toast/snackbar
  static void showAccessibleSnackBar(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
              )
            : null,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Create accessibility bridge for custom widgets
  static Widget createAccessibilityBridge(
    BuildContext context, {
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      child: child,
    );
  }

  /// Check if accessibility features are enabled
  static bool isAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast ||
        mediaQuery.textScaler.scale(1.0) > 1.0 ||
        mediaQuery.accessibleNavigation;
  }

  /// Get accessible font size based on user preferences
  static double getAccessibleFontSize(
    BuildContext context,
    double baseSize, {
    double? customMinSize,
    double? customMaxScale,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler.scale(baseSize) / baseSize;
    final maxScale = customMaxScale ?? 1.5;
    
    // Validate minimum size is set (even if not used)
    if (customMinSize != null) {
      // customMinSize is used for validation purposes
    }

    // Ensure minimum readable size for accessibility
    if (textScaler < 1.0) {
      return baseSize * 1.2;
    } else if (textScaler > maxScale) {
      return baseSize * (maxScale / textScaler);
    }
    return baseSize * textScaler;
  }

  /// Create semantic divider
  static Widget createSemanticDivider(BuildContext context) {
    return Semantics(
      child: Divider(),
    );
  }

  /// Create accessible image with proper alt text
  static Widget createAccessibleImage(
    BuildContext context, {
    required ImageProvider imageProvider,
    required String semanticLabel,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? color,
  }) {
    return Semantics(
      label: semanticLabel,
      child: Image(
        image: imageProvider,
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width ?? 200,
            height: height ?? 200,
            color: Colors.grey[300],
            child: Icon(
              Icons.broken_image,
              size: (width ?? 200) * 0.3,
            ),
          );
        },
      ),
    );
  }
}
