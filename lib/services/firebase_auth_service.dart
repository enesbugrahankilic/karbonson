// lib/services/firebase_auth_service.dart
// Enhanced Firebase Authentication Service with comprehensive error handling

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 3;

  /// Comprehensive authentication error handler
  static String handleAuthError(FirebaseAuthException e, {String? context}) {
    if (kDebugMode) {
      debugPrint('Auth Error [${context ?? 'Unknown'}]: ${e.code} - ${e.message}');
    }

    switch (e.code) {
      case 'internal-error':
        return _handleInternalError(e, context);
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen birkaç dakika bekleyin ve tekrar deneyin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Destek ekibiyle iletişime geçin.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı. E-posta adresinizi kontrol edin.';
      case 'wrong-password':
        return 'Hatalı şifre. Şifrenizi kontrol edin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu anda etkinleştirilmemiş. Yöneticinizle iletişime geçin.';
      case 'requires-recent-login':
        return 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      case 'invalid-credential':
        return 'Kimlik bilgileri geçersiz. Tekrar deneyin.';
      case 'user-mismatch':
        return 'Kullanıcı eşleşmedi. Tekrar deneyin.';
      case 'invalid-verification-code':
        return 'Doğrulama kodu geçersiz.';
      case 'invalid-verification-id':
        return 'Doğrulama kimliği geçersiz.';
      case 'quota-exceeded':
        return 'Kota aşıldı. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Beklenmeyen bir hata oluştu: ${e.message ?? e.code}';
    }
  }

  static String _handleInternalError(FirebaseAuthException e, String? context) {
    // Internal error can have various causes, provide specific guidance
    final message = e.message?.toLowerCase() ?? '';
    
    if (message.contains('configuration') || message.contains('setup')) {
      return 'Firebase yapılandırma hatası. Email/Şifre girişi Firebase Console\'da etkinleştirilmemiş olabilir.';
    } else if (message.contains('network') || message.contains('connection')) {
      return 'Bağlantı sorunu. İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
    } else if (message.contains('quota') || message.contains('limit')) {
      return 'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
    } else if (context == 'anonymous_signin') {
      return 'Anonim giriş yapılamıyor. Firebase Authentication ayarlarını kontrol edin.';
    } else if (context == 'email_signup') {
      return 'Kayıt işlemi gerçekleştirilemedi. Email/Şifre girişi etkinleştirildiğinden emin olun.';
    } else if (context == 'email_signin') {
      return 'Giriş yapılamıyor. Firebase Authentication ayarlarını kontrol edin.';
    } else {
      return 'Firebase sunucu hatası. Lütfen birkaç dakika bekleyip tekrar deneyin.';
    }
  }

  /// Check if network is available before making auth requests
  static Future<bool> _isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Network check failed: $e');
      }
      return true; // Assume network is available if check fails
    }
  }

  /// Enhanced anonymous sign-in with proper error handling and retries
  static Future<User?> signInAnonymouslyWithRetry({int maxRetries = _maxRetries}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Check network connectivity
        if (!(await _isNetworkAvailable())) {
          throw FirebaseAuthException(
            code: 'network-request-failed',
            message: 'No internet connection',
          );
        }

        if (kDebugMode) {
          debugPrint('Anonymous sign-in attempt $attempt of $maxRetries');
        }

        final result = await _auth.signInAnonymously().timeout(_defaultTimeout);
        
        if (kDebugMode) {
          debugPrint('Anonymous sign-in successful: ${result.user?.uid}');
        }
        
        return result.user;

      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Anonymous sign-in attempt $attempt failed: ${e.code} - ${e.message}');
        }

        // If it's the last attempt, throw the error
        if (attempt == maxRetries) {
          rethrow;
        }

        // For certain errors, don't retry
        if (e.code == 'operation-not-allowed' || e.code == 'user-disabled') {
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(_retryDelay * attempt);

      } catch (e) {
        if (kDebugMode) {
          debugPrint('Anonymous sign-in attempt $attempt failed with unexpected error: $e');
        }

        if (attempt == maxRetries) {
          // Wrap unexpected errors in FirebaseAuthException for consistent handling
          throw FirebaseAuthException(
            code: 'internal-error',
            message: 'Unexpected error during anonymous sign-in: $e',
          );
        }

        await Future.delayed(_retryDelay * attempt);
      }
    }
    
    return null; // This should never be reached
  }

  /// Enhanced email/password sign-up with retry mechanism
  static Future<UserCredential?> createUserWithEmailAndPasswordWithRetry({
    required String email,
    required String password,
    int maxRetries = _maxRetries,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Check network connectivity
        if (!(await _isNetworkAvailable())) {
          throw FirebaseAuthException(
            code: 'network-request-failed',
            message: 'No internet connection',
          );
        }

        if (kDebugMode) {
          debugPrint('Email sign-up attempt $attempt of $maxRetries for: $email');
        }

        final result = await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .timeout(_defaultTimeout);

        if (kDebugMode) {
          debugPrint('Email sign-up successful: ${result.user?.uid}');
        }

        return result;

      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Email sign-up attempt $attempt failed: ${e.code} - ${e.message}');
        }

        // If it's the last attempt, throw the error
        if (attempt == maxRetries) {
          rethrow;
        }

        // For certain errors, don't retry
        if (e.code == 'email-already-in-use' || 
            e.code == 'invalid-email' || 
            e.code == 'weak-password' ||
            e.code == 'operation-not-allowed' ||
            e.code == 'user-disabled') {
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(_retryDelay * attempt);

      } catch (e) {
        if (kDebugMode) {
          debugPrint('Email sign-up attempt $attempt failed with unexpected error: $e');
        }

        if (attempt == maxRetries) {
          throw FirebaseAuthException(
            code: 'internal-error',
            message: 'Unexpected error during email sign-up: $e',
          );
        }

        await Future.delayed(_retryDelay * attempt);
      }
    }
    
    return null; // This should never be reached
  }

  /// Enhanced email/password sign-in with retry mechanism
  static Future<UserCredential?> signInWithEmailAndPasswordWithRetry({
    required String email,
    required String password,
    int maxRetries = _maxRetries,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Check network connectivity
        if (!(await _isNetworkAvailable())) {
          throw FirebaseAuthException(
            code: 'network-request-failed',
            message: 'No internet connection',
          );
        }

        if (kDebugMode) {
          debugPrint('Email sign-in attempt $attempt of $maxRetries for: $email');
        }

        final result = await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .timeout(_defaultTimeout);

        if (kDebugMode) {
          debugPrint('Email sign-in successful: ${result.user?.uid}');
        }

        return result;

      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Email sign-in attempt $attempt failed: ${e.code} - ${e.message}');
        }

        // If it's the last attempt, throw the error
        if (attempt == maxRetries) {
          rethrow;
        }

        // For certain errors, don't retry
        if (e.code == 'user-disabled' || 
            e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-email' ||
            e.code == 'operation-not-allowed') {
          rethrow;
        }

        // Wait before retrying
        await Future.delayed(_retryDelay * attempt);

      } catch (e) {
        if (kDebugMode) {
          debugPrint('Email sign-in attempt $attempt failed with unexpected error: $e');
        }

        if (attempt == maxRetries) {
          throw FirebaseAuthException(
            code: 'internal-error',
            message: 'Unexpected error during email sign-in: $e',
          );
        }

        await Future.delayed(_retryDelay * attempt);
      }
    }
    
    return null; // This should never be reached
  }

  /// Check Firebase Auth configuration status
  static Future<Map<String, dynamic>> checkAuthConfiguration() async {
    final results = <String, dynamic>{};

    try {
      // Check if Firebase app is initialized
      results['firebase_initialized'] = _auth.app != null;
      
      // Check if current user is available (indicates auth is working)
      results['current_user_available'] = _auth.currentUser != null;
      
      // Test anonymous sign-in capability
      try {
        await _auth.signInAnonymously().timeout(const Duration(seconds: 5));
        results['anonymous_signin_enabled'] = true;
        
        // Sign out immediately after test
        await _auth.signOut();
      } catch (e) {
        results['anonymous_signin_enabled'] = false;
        results['anonymous_signin_error'] = e.toString();
      }

    } catch (e) {
      results['error'] = e.toString();
    }

    return results;
  }

  /// Validate Firebase project configuration
  static Future<bool> validateFirebaseConfig() async {
    try {
      final config = await checkAuthConfiguration();
      
      if (kDebugMode) {
        debugPrint('Firebase Auth Configuration Check: $config');
      }

      // Check if essential services are working
      return config['firebase_initialized'] == true &&
             config['anonymous_signin_enabled'] == true;
             
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase config validation failed: $e');
      }
      return false;
    }
  }
}