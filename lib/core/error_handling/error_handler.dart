// lib/core/error_handling/error_handler.dart
// Comprehensive error handling system with UI-friendly messages

import 'package:flutter/material.dart';
import '../../widgets/ui_friendly_dialogs.dart';

/// Error types for categorization
enum ErrorType {
  network,
  authentication,
  validation,
  notFound,
  permission,
  timeout,
  server,
  unknown,
}

/// App error with user-friendly messages
class AppError implements Exception {
  final String code;
  final String message;
  final String? userMessage;
  final ErrorType type;
  final StackTrace? stackTrace;
  final dynamic originalError;
  final Map<String, dynamic>? details;

  AppError({
    required this.code,
    required this.message,
    this.userMessage,
    this.type = ErrorType.unknown,
    this.stackTrace,
    this.originalError,
    this.details,
  });

  /// Get user-friendly message (Türkçe)
  String getUserMessage() {
    return userMessage ?? _getDefaultMessage();
  }

  String _getDefaultMessage() {
    return switch (type) {
      ErrorType.network => 'İnternet bağlantısını kontrol edin lütfen',
      ErrorType.authentication => 'Lütfen tekrar giriş yapın',
      ErrorType.validation => 'Lütfen girişlerinizi kontrol edin',
      ErrorType.notFound => 'İstenen kaynak bulunamadı',
      ErrorType.permission => 'Bu işlem için izniniz yok',
      ErrorType.timeout => 'İşlem zaman aşımına uğradı, lütfen tekrar deneyin',
      ErrorType.server => 'Sunucu hatası, lütfen daha sonra tekrar deneyin',
      ErrorType.unknown => 'Beklenmedik bir hata oluştu, lütfen tekrar deneyin',
    };
  }

  @override
  String toString() => 'AppError($code): $message';
}

/// Error handler service
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  factory ErrorHandler() {
    return _instance;
  }

  ErrorHandler._internal();

  final List<void Function(AppError)> _listeners = [];

  /// Add error listener for logging/analytics
  void addListener(void Function(AppError) listener) {
    _listeners.add(listener);
  }

  /// Remove error listener
  void removeListener(void Function(AppError) listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners
  void _notifyListeners(AppError error) {
    for (final listener in _listeners) {
      try {
        listener(error);
      } catch (e) {
        debugPrint('Error in error listener: $e');
      }
    }
  }

  /// Handle error and show UI
  Future<void> handleError(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) async {
    _notifyListeners(error);

    if (!context.mounted) return;

    await FriendlyAlertDialog.show(
      context: context,
      title: 'Hata',
      message: error.getUserMessage(),
      icon: Icons.error,
      positiveButtonText: onRetry != null ? 'Tekrar Dene' : 'Tamam',
      negativeButtonText: onRetry != null ? 'İptal' : null,
      onPositivePressed: onRetry ?? onDismiss,
      onNegativePressed: onDismiss,
    );
  }

  /// Create network error
  static AppError networkError({
    String code = 'NETWORK_ERROR',
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Network error occurred',
      userMessage: userMessage ?? 'İnternet bağlantısını kontrol edin',
      type: ErrorType.network,
    );
  }

  /// Create authentication error
  static AppError authError({
    String code = 'AUTH_ERROR',
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Authentication failed',
      userMessage: userMessage ?? 'Kimlik doğrulama başarısız',
      type: ErrorType.authentication,
    );
  }

  /// Create validation error
  static AppError validationError({
    String code = 'VALIDATION_ERROR',
    required String field,
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Validation failed for field: $field',
      userMessage: userMessage ?? '$field alanında hata',
      type: ErrorType.validation,
      details: {'field': field},
    );
  }

  /// Create not found error
  static AppError notFoundError({
    String code = 'NOT_FOUND',
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Resource not found',
      userMessage: userMessage ?? 'Kaynak bulunamadı',
      type: ErrorType.notFound,
    );
  }

  /// Create permission error
  static AppError permissionError({
    String code = 'PERMISSION_DENIED',
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Permission denied',
      userMessage: userMessage ?? 'Bu işlem için izniniz yok',
      type: ErrorType.permission,
    );
  }

  /// Create timeout error
  static AppError timeoutError({
    String code = 'TIMEOUT',
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Request timeout',
      userMessage: userMessage ?? 'İşlem zaman aşımına uğradı',
      type: ErrorType.timeout,
    );
  }

  /// Create server error
  static AppError serverError({
    String code = 'SERVER_ERROR',
    int? statusCode,
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: 'Server error (Status: ${statusCode ?? 'unknown'})',
      userMessage: userMessage ?? 'Sunucu hatası',
      type: ErrorType.server,
      details: statusCode != null ? {'statusCode': statusCode} : null,
    );
  }

  /// Create unknown error
  static AppError unknownError({
    String code = 'UNKNOWN_ERROR',
    required dynamic error,
    String? userMessage,
  }) {
    return AppError(
      code: code,
      message: error.toString(),
      userMessage: userMessage ?? 'Beklenmedik bir hata oluştu',
      type: ErrorType.unknown,
      originalError: error,
    );
  }
}

/// Safe async operation wrapper
Future<T> safeAsync<T>(
  Future<T> Function() operation, {
  required ErrorHandler errorHandler,
  required BuildContext context,
  String loadingMessage = 'İşlem gerçekleştiriliyor...',
  bool showLoading = true,
}) async {
  try {
    if (showLoading && context.mounted) {
      LoadingDialog.show(context, message: loadingMessage);
    }

    final result = await operation();

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    return result;
  } on AppError catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      await errorHandler.handleError(context, e);
    }
    rethrow;
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      final error = ErrorHandler.unknownError(error: e);
      await errorHandler.handleError(context, error);
    }
    rethrow;
  }
}

/// Input validation error handler
class ValidationErrorHandler {
  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş olamaz';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermelidir';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermelidir';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim boş olamaz';
    }

    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }

    if (value.length > 50) {
      return 'İsim en fazla 50 karakter olmalıdır';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası boş olamaz';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Geçerli bir telefon numarası girin';
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı boş olamaz';
    }

    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalıdır';
    }

    if (value.length > 20) {
      return 'Kullanıcı adı en fazla 20 karakter olmalıdır';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';
    }

    return null;
  }
}

/// Error recovery strategies
class ErrorRecoveryStrategy {
  /// Retry with exponential backoff
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retries = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          rethrow;
        }

        final delay = initialDelay * (1 << (retries - 1)); // Exponential backoff
        await Future.delayed(delay);
      }
    }
  }

  /// Fallback to cached value on error
  static Future<T> withFallback<T>(
    Future<T> Function() operation,
    T Function() fallback,
  ) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('Operation failed, using fallback: $e');
      return fallback();
    }
  }

  /// Timeout wrapper
  static Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return operation().timeout(
      timeout,
      onTimeout: () => throw ErrorHandler.timeoutError(),
    );
  }
}
