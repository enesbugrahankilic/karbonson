// lib/widgets/ui_friendly_dialogs.dart
// UI-friendly dialogs and modals with consistent styling

import 'package:flutter/material.dart';

/// Dialog result with success/error status
class DialogResult<T> {
  final bool success;
  final T? data;
  final String? error;

  DialogResult({
    required this.success,
    this.data,
    this.error,
  });

  factory DialogResult.success(T data) => DialogResult(success: true, data: data);
  factory DialogResult.error(String error) => DialogResult(success: false, error: error);
}

/// Button configuration for dialogs
class DialogButton {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final IconData? icon;

  DialogButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.icon,
  });
}

/// Friendly alert dialog
class FriendlyAlertDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? positiveButtonText,
    String? negativeButtonText,
    VoidCallback? onPositivePressed,
    VoidCallback? onNegativePressed,
    IconData? icon,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon != null ? Icon(icon, size: 48, color: Colors.blue) : null,
        title: Text(title),
        content: Text(message),
        actions: [
          if (negativeButtonText != null)
            TextButton(
              onPressed: () {
                onNegativePressed?.call();
                Navigator.pop(context, false);
              },
              child: Text(negativeButtonText),
            ),
          if (positiveButtonText != null)
            ElevatedButton(
              onPressed: () {
                onPositivePressed?.call();
                Navigator.pop(context, true);
              },
              child: Text(positiveButtonText),
            ),
        ],
      ),
    );
  }
}

/// Custom dialog with flexible content
class FriendlyCustomDialog extends StatefulWidget {
  final String title;
  final Widget content;
  final List<DialogButton> buttons;
  final EdgeInsets? contentPadding;
  final double? maxWidth;

  const FriendlyCustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.buttons,
    this.contentPadding,
    this.maxWidth,
  }) : super(key: key);

  @override
  State<FriendlyCustomDialog> createState() => _FriendlyCustomDialogState();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<DialogButton> buttons,
    EdgeInsets? contentPadding,
    double? maxWidth,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => FriendlyCustomDialog(
        title: title,
        content: content,
        buttons: buttons,
        contentPadding: contentPadding,
        maxWidth: maxWidth,
      ),
    );
  }
}

class _FriendlyCustomDialogState extends State<FriendlyCustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Content
            Padding(
              padding: widget.contentPadding ?? const EdgeInsets.all(24),
              child: widget.content,
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...widget.buttons.map((button) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: button.isPrimary
                          ? ElevatedButton(
                              onPressed: button.onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: button.isDestructive
                                    ? Colors.red
                                    : Theme.of(context).primaryColor,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (button.icon != null) ...[
                                    Icon(button.icon),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(button.label),
                                ],
                              ),
                            )
                          : TextButton(
                              onPressed: button.onPressed,
                              child: Text(button.label),
                            ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading dialog
class LoadingDialog extends StatelessWidget {
  final String message;
  final Color? color;

  const LoadingDialog({
    Key? key,
    required this.message,
    this.color,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String message,
    Color? color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        message: message,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with UI friendly design
class FriendlyBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<DialogButton>? buttons,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight ?? 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              ),
            ),
            // Buttons
            if (buttons != null && buttons.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: buttons.map((button) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: button.onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: button.isPrimary
                                ? Theme.of(context).primaryColor
                                : (button.isDestructive ? Colors.red : Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (button.icon != null) ...[
                                Icon(button.icon),
                                const SizedBox(width: 8),
                              ],
                              Text(button.label),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Snackbar helper with better UI
class FriendlySnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) =>
      show(context, message: message, type: SnackBarType.success, duration: duration);

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(context, message: message, type: SnackBarType.error, duration: duration);

  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(context, message: message, type: SnackBarType.warning, duration: duration);

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) =>
      show(context, message: message, type: SnackBarType.info, duration: duration);

  static Color _getColorForType(SnackBarType type) {
    return switch (type) {
      SnackBarType.success => Colors.green,
      SnackBarType.error => Colors.red,
      SnackBarType.warning => Colors.orange,
      SnackBarType.info => Colors.blue,
    };
  }

  static IconData _getIconForType(SnackBarType type) {
    return switch (type) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.error => Icons.error,
      SnackBarType.warning => Icons.warning,
      SnackBarType.info => Icons.info,
    };
  }
}

enum SnackBarType { success, error, warning, info }

/// Confirmation dialog
class ConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String positiveButtonText = 'Evet',
    String negativeButtonText = 'Hayır',
    bool isDestructive = false,
  }) async {
    final result = await FriendlyCustomDialog.show(
      context: context,
      title: title,
      content: Text(message),
      buttons: [
        DialogButton(
          label: negativeButtonText,
          onPressed: () => Navigator.pop(context, false),
        ),
        DialogButton(
          label: positiveButtonText,
          onPressed: () => Navigator.pop(context, true),
          isPrimary: true,
          isDestructive: isDestructive,
        ),
      ],
    );

    return result ?? false;
  }
}
