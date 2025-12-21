// lib/services/error_feedback_service.dart
// Service for improved error handling and user feedback in registration

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/theme_colors.dart';

/// Error feedback service for registration-related operations
class ErrorFeedbackService {
  /// Show error snackbar with retry functionality
  static void showRegistrationError({
    required BuildContext context,
    required String error,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Tekrar Dene',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show success feedback
  static void showRegistrationSuccess({
    required BuildContext context,
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Kayıt başarılı! Hoş geldiniz!'),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Show loading progress feedback
  static void showLoadingProgress({
    required BuildContext context,
    String message = 'İşlem yapılıyor...',
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 30),
      ),
    );
  }

  /// Show network error with specific guidance
  static void showNetworkError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    showRegistrationError(
      context: context,
      error: 'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.',
      onRetry: onRetry,
    );
  }

  /// Show timeout error with retry option
  static void showTimeoutError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    showRegistrationError(
      context: context,
      error: 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.',
      onRetry: onRetry,
    );
  }

  /// Show nickname validation error
  static void showNicknameError({
    required BuildContext context,
    required String error,
    VoidCallback? onRetry,
  }) {
    showRegistrationError(
      context: context,
      error: 'Takma ad hatası: $error',
      onRetry: onRetry,
      duration: const Duration(seconds: 6),
    );
  }

  /// Show email already in use error
  static void showEmailInUseError({
    required BuildContext context,
  }) {
    showRegistrationError(
      context: context,
      error:
          'Bu e-posta adresi zaten kullanılıyor. Farklı bir e-posta deneyin.',
    );
  }

  /// Show password too weak error
  static void showPasswordWeakError({
    required BuildContext context,
  }) {
    showRegistrationError(
      context: context,
      error:
          'Şifre çok zayıf. En az 6 karakter kullanın ve güçlü bir şifre seçin.',
    );
  }

  /// Show server error with guidance
  static void showServerError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    showRegistrationError(
      context: context,
      error:
          'Sunucu hatası oluştu. Lütfen birkaç dakika bekleyip tekrar deneyin.',
      onRetry: onRetry,
    );
  }

  /// Show generic unexpected error
  static void showUnexpectedError({
    required BuildContext context,
    required String error,
    VoidCallback? onRetry,
  }) {
    showRegistrationError(
      context: context,
      error: 'Beklenmeyen bir hata oluştu: $error',
      onRetry: onRetry,
      duration: const Duration(seconds: 8),
    );
  }

  /// Show Firebase configuration error
  static void showConfigurationError({
    required BuildContext context,
  }) {
    showRegistrationError(
      context: context,
      error: 'Uygulama yapılandırma hatası. Lütfen daha sonra tekrar deneyin.',
    );
  }

  /// Show nickname suggestion success feedback
  static void showNicknameSuggestion({
    required BuildContext context,
    required String suggestedNickname,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Yeni isim önerisi: $suggestedNickname'),
        backgroundColor: ThemeColors.getGreen(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show form validation errors for multiple fields
  static void showFormValidationErrors({
    required BuildContext context,
    required Map<String, String> errors,
  }) {
    if (!context.mounted) return;

    final errorMessages = errors.values.join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lütfen aşağıdaki hataları düzeltin:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(errorMessages),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  /// Show connection status feedback
  static void showConnectionStatus({
    required BuildContext context,
    required bool isConnected,
  }) {
    if (!context.mounted) return;

    final message = isConnected
        ? 'İnternet bağlantısı yeniden kuruldu'
        : 'İnternet bağlantısı kesildi';

    final backgroundColor = isConnected ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Clear all current SnackBars
  static void clearFeedback(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Get user-friendly error message for development
  static String getDevelopmentErrorInfo(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      final errorInfo = '''
Error Type: ${error.runtimeType}
Error Message: ${error.toString()}
Stack Trace: ${stackTrace.toString()}
''';
      debugPrint('Registration Error Details:\n$errorInfo');
      return 'Geliştirici Bilgisi: ${error.runtimeType} - ${error.toString()}';
    }
    return 'Beklenmeyen bir hata oluştu';
  }
}
