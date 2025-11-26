// lib/services/error_handling_service.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorHandlingService {
  static ErrorHandlingService? _instance;
  static ErrorHandlingService get instance => _instance ??= ErrorHandlingService._();
  
  ErrorHandlingService._();

  final StreamController<ConnectivityResult> _connectivityController = 
    StreamController<ConnectivityResult>.broadcast();
  
  final StreamController<AppError> _errorController = 
    StreamController<AppError>.broadcast();

  // Connectivity Stream
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;
  Stream<AppError> get errorStream => _errorController.stream;
  
  ConnectivityResult? _lastConnectivityResult;
  Timer? _offlineDetectionTimer;

  void initialize() {
    // Monitor connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result.first);
    });
    
    _startOfflineDetection();
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    _lastConnectivityResult = result;
    
    if (result == ConnectivityResult.none) {
      _errorController.add(AppError(
        type: AppErrorType.network,
        message: 'İnternet bağlantısı bulunamadı',
        severity: ErrorSeverity.warning,
      ));
    } else if (_lastConnectivityResult == ConnectivityResult.none) {
      // Just reconnected
      _errorController.add(AppError(
        type: AppErrorType.network,
        message: 'İnternet bağlantısı yeniden kuruldu',
        severity: ErrorSeverity.info,
      ));
    }
    
    _connectivityController.add(result);
  }

  void _startOfflineDetection() {
    _offlineDetectionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkNetworkConnectivity();
    });
  }

  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      final hasConnection = result.first != ConnectivityResult.none;
      
      if (!hasConnection && _lastConnectivityResult != ConnectivityResult.none) {
        // Network was lost
        _errorController.add(AppError(
          type: AppErrorType.network,
          message: 'Ağ bağlantısı kesildi. Çevrimdışı mod aktif.',
          severity: ErrorSeverity.warning,
        ));
      }
    } catch (e) {
      // Handle connectivity check errors silently
    }
  }

  // Error Handling Methods
  Future<void> handleError(dynamic error, {StackTrace? stackTrace}) async {
    final appError = _convertToAppError(error, stackTrace);
    _errorController.add(appError);
    
    // Log error for debugging
    debugPrint('App Error: ${appError.message}');
    if (stackTrace != null) {
      debugPrint('Stack Trace: $stackTrace');
    }
  }

  AppError _convertToAppError(dynamic error, StackTrace? stackTrace) {
    if (error is AppError) {
      return error;
    }

    if (error is SocketException) {
      return AppError(
        type: AppErrorType.network,
        message: 'Ağ bağlantısı hatası',
        severity: ErrorSeverity.warning,
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        type: AppErrorType.timeout,
        message: 'İstek zaman aşımına uğradı',
        severity: ErrorSeverity.warning,
        originalError: error,
      );
    }

    if (error is HttpException) {
      return AppError(
        type: AppErrorType.http,
        message: 'HTTP hatası oluştu',
        severity: ErrorSeverity.error,
        originalError: error,
      );
    }

    // Generic error
    return AppError(
      type: AppErrorType.unknown,
      message: error.toString(),
      severity: ErrorSeverity.error,
      originalError: error,
    );
  }

  // Retry mechanism with exponential backoff
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;

    while (retryCount <= maxRetries) {
      try {
        return await operation();
      } catch (error) {
        retryCount++;
        
        if (retryCount > maxRetries) {
          await handleError(error);
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(delay);
        
        // Exponential backoff
        delay = Duration(milliseconds: delay.inMilliseconds * 2);
        
        // Add retry error
        _errorController.add(AppError(
          type: AppErrorType.retry,
          message: 'İşlem yeniden deneniyor... ($retryCount/$maxRetries)',
          severity: ErrorSeverity.info,
        ));
      }
    }

    throw Exception('Max retries exceeded');
  }

  // Network-dependent operation with offline fallbacks
  Future<T?> tryNetworkOperation<T>(
    Future<T> Function() operation,
    T Function()? offlineFallback,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.first == ConnectivityResult.none) {
      if (offlineFallback != null) {
        return offlineFallback();
      } else {
        await handleError(AppError(
          type: AppErrorType.network,
          message: 'İnternet bağlantısı yok',
          severity: ErrorSeverity.warning,
        ));
        return null;
      }
    }

    try {
      return await operation();
    } catch (error) {
      // If network operation fails and we have offline fallback, use it
      if (offlineFallback != null) {
        return offlineFallback();
      }
      
      await handleError(error);
      return null;
    }
  }

  void dispose() {
    _connectivityController.close();
    _errorController.close();
    _offlineDetectionTimer?.cancel();
  }
}

// Error Types and Classes
enum AppErrorType {
  network,
  timeout,
  http,
  authentication,
  validation,
  retry,
  unknown,
}

enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

class AppError {
  final AppErrorType type;
  final String message;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final dynamic originalError;

  AppError({
    required this.type,
    required this.message,
    required this.severity,
    this.originalError,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'AppError{type: $type, message: $message, severity: $severity}';
  }
}

// Error Widget for displaying user-friendly error messages
class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (error.severity) {
      case ErrorSeverity.info:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        icon = Icons.info_outline;
        break;
      case ErrorSeverity.warning:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        icon = Icons.warning_outlined;
        break;
      case ErrorSeverity.error:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      case ErrorSeverity.critical:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade900;
        icon = Icons.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue),
              onPressed: onRetry,
              tooltip: 'Tekrar Dene',
            ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: onDismiss,
              tooltip: 'Kapat',
            ),
        ],
      ),
    );
  }
}