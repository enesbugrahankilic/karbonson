// lib/services/auth_service.dart
// Core Authentication Service - Focused on authentication logic only

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;
  final String? errorCode;

  const AuthResult({
    required this.isSuccess,
    required this.message,
    this.user,
    this.errorCode,
  });

  factory AuthResult.success(User user, String message) {
    return AuthResult(
      isSuccess: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.failure(String message, [String? errorCode]) {
    return AuthResult(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 3;

  /// Initialize authentication persistence
  static Future<void> initializeAuthPersistence() async {
    try {
      // Set persistence to LOCAL (default) to maintain sessions across app restarts
      await _auth.setPersistence(Persistence.LOCAL);
      
      if (kDebugMode) {
        debugPrint('✅ Firebase Auth persistence initialized to LOCAL');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize auth persistence: $e');
      }
    }
  }

  /// Check if user is currently authenticated with a persistent session
  static bool isUserAuthenticated() {
    final user = _auth.currentUser;
    return user != null;
  }

  /// Get the current authenticated user with persistent session
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user has anonymous account
  static bool isAnonymousUser() {
    final user = _auth.currentUser;
    return user?.isAnonymous ?? false;
  }

  /// Check if user has email account (not anonymous)
  static bool hasEmailAccount() {
    final user = _auth.currentUser;
    return user != null && 
           user.email != null && 
           user.email!.isNotEmpty && 
           !user.isAnonymous;
  }

  /// Check network connectivity before making auth requests
  static Future<bool> _isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Network check failed: $e');
      }
      return false;
    }
  }

  /// Enhanced email/password sign in with retry logic
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Pre-flight checks
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('E-posta ve şifre gerekli');
    }

    if (!(await _isNetworkAvailable())) {
      return AuthResult.failure('İnternet bağlantınızı kontrol edin');
    }

    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        attempts++;
        
        if (kDebugMode) {
          debugPrint('Email/password sign in attempt $attempts/$_maxRetries');
        }

        final userCredential = await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .timeout(_defaultTimeout);
        
        if (kDebugMode) {
          debugPrint('Email/password sign in successful: ${userCredential.user?.uid}');
        }
        
        return AuthResult.success(
          userCredential.user!,
          'Giriş başarılı',
        );
        
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Email/password sign in attempt $attempts failed: ${e.code}');
        }
        
        // If it's the last attempt, throw the error
        if (attempts >= _maxRetries) {
          return AuthResult.failure(
            _handleAuthError(e),
            e.code,
          );
        }
        
        // Check if it's a retryable error
        if (_isRetryableError(e.code)) {
          await Future.delayed(_retryDelay);
        } else {
          return AuthResult.failure(
            _handleAuthError(e),
            e.code,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Email/password sign in attempt $attempts failed: $e');
        }
        
        if (attempts >= _maxRetries) {
          return AuthResult.failure('Beklenmeyen bir hata oluştu: $e');
        }
        
        await Future.delayed(_retryDelay);
      }
    }
    
    return AuthResult.failure('Giriş başarısız');
  }

  /// Enhanced email/password registration with retry logic
  static Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Pre-flight checks
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('E-posta ve şifre gerekli');
    }

    if (password.length < 6) {
      return AuthResult.failure('Şifre en az 6 karakter olmalıdır');
    }

    if (!(await _isNetworkAvailable())) {
      return AuthResult.failure('İnternet bağlantınızı kontrol edin');
    }

    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        attempts++;
        
        if (kDebugMode) {
          debugPrint('Email/password registration attempt $attempts/$_maxRetries');
        }

        final userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .timeout(_defaultTimeout);
        
        if (kDebugMode) {
          debugPrint('Email/password registration successful: ${userCredential.user?.uid}');
        }
        
        return AuthResult.success(
          userCredential.user!,
          'Hesap oluşturuldu',
        );
        
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Email/password registration attempt $attempts failed: ${e.code}');
        }
        
        // If it's the last attempt, throw the error
        if (attempts >= _maxRetries) {
          return AuthResult.failure(
            _handleAuthError(e),
            e.code,
          );
        }
        
        // Check if it's a retryable error
        if (_isRetryableError(e.code)) {
          await Future.delayed(_retryDelay);
        } else {
          return AuthResult.failure(
            _handleAuthError(e),
            e.code,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Email/password registration attempt $attempts failed: $e');
        }
        
        if (attempts >= _maxRetries) {
          return AuthResult.failure('Beklenmeyen bir hata oluştu: $e');
        }
        
        await Future.delayed(_retryDelay);
      }
    }
    
    return AuthResult.failure('Hesap oluşturulamadı');
  }

  /// Enhanced anonymous sign in with retry logic
  static Future<AuthResult> signInAnonymously() async {
    if (!(await _isNetworkAvailable())) {
      return AuthResult.failure('İnternet bağlantınızı kontrol edin');
    }

    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        attempts++;
        
        if (kDebugMode) {
          debugPrint('Anonymous sign in attempt $attempts/$_maxRetries');
        }

        final userCredential = await _auth.signInAnonymously().timeout(_defaultTimeout);
        final user = userCredential.user;
        
        if (user != null) {
          if (kDebugMode) {
            debugPrint('Anonymous sign in successful: ${user.uid}');
          }
          return AuthResult.success(
            user,
            'Anonim giriş başarılı',
          );
        }
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Anonymous sign in attempt $attempts failed: ${e.code}');
        }
        
        // If it's the last attempt, throw the error
        if (attempts >= _maxRetries) {
          return AuthResult.failure(
            _handleAuthError(e),
            e.code,
          );
        }
        
        // Check if it's a retryable error
        if (_isRetryableError(e.code)) {
          await Future.delayed(_retryDelay);
        } else {
          return AuthResult.failure(
            _handleAuthError(e),
            e.code,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Anonymous sign in attempt $attempts failed: $e');
        }
        
        if (attempts >= _maxRetries) {
          return AuthResult.failure('Beklenmeyen bir hata oluştu: $e');
        }
        
        await Future.delayed(_retryDelay);
      }
    }
    
    return AuthResult.failure('Anonim giriş başarısız');
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        debugPrint('✅ User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Sign out failed: $e');
      }
    }
  }

  /// Delete current user account
  static Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Kullanıcı oturumu bulunamadı');
      }

      await user.delete();
      
      if (kDebugMode) {
        debugPrint('✅ User account deleted: ${user.uid}');
      }

      return AuthResult.success(user, 'Hesap silindi');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        _handleAuthError(e),
        e.code,
      );
    } catch (e) {
      return AuthResult.failure('Beklenmeyen bir hata oluştu: $e');
    }
  }

  /// Send email verification to current user
  static Future<AuthResult> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Kullanıcı oturumu bulunamadı');
      }

      if (user.emailVerified) {
        return AuthResult.success(user, 'E-posta adresi zaten doğrulanmış');
      }

      await user.sendEmailVerification();
      
      if (kDebugMode) {
        debugPrint('Email verification sent to: ${user.email}');
      }
      
      return AuthResult.success(
        user,
        'Doğrulama e-postası gönderildi',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        _handleAuthError(e),
        e.code,
      );
    } catch (e) {
      return AuthResult.failure('Beklenmeyen bir hata oluştu: $e');
    }
  }

  /// Check if current user's email is verified
  static Future<AuthResult> checkEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('Kullanıcı oturumu bulunamadı');
      }

      // Reload user to get latest email verification status
      await user.reload();
      final currentUser = _auth.currentUser!;
      
      final hasEmail = currentUser.email != null && currentUser.email!.isNotEmpty;
      final isVerified = currentUser.emailVerified;
      
      return AuthResult.success(
        currentUser,
        isVerified 
            ? 'E-posta adresi doğrulanmış' 
            : 'E-posta adresi doğrulanmamış',
      );
    } catch (e) {
      return AuthResult.failure('Doğrulama durumu kontrol edilemedi: $e');
    }
  }

  /// Get debug information about Firebase Auth state
  static Map<String, dynamic> getDebugInfo() {
    try {
      final user = _auth.currentUser;
      return {
        'currentUser': user != null,
        'userId': user?.uid,
        'email': user?.email,
        'emailVerified': user?.emailVerified,
        'isAnonymous': user?.isAnonymous,
        'providerData': user?.providerData.map((data) => data.providerId).toList(),
        'lastSignInTime': user?.metadata.lastSignInTime?.toIso8601String(),
        'creationTime': user?.metadata.creationTime?.toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get debug info: $e');
      }
      return {'error': e.toString()};
    }
  }

  /// Handle authentication errors with Turkish localization
  static String _handleAuthError(FirebaseAuthException e) {
    if (kDebugMode) {
      debugPrint('Auth Error: ${e.code} - ${e.message}');
    }

    switch (e.code) {
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
        return 'E-posta adresi formatı geçersiz.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu anda etkinleştirilmemiş. Firebase Authentication ayarlarını kontrol edin.';
      case 'requires-recent-login':
        return 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      case 'invalid-credential':
        return 'Kimlik bilgileri geçersiz. Tekrar deneyin.';
      case 'quota-exceeded':
        return 'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Beklenmeyen bir hata oluştu: ${e.message ?? e.code}';
    }
  }

  /// Check if error is retryable
  static bool _isRetryableError(String errorCode) {
    final retryableErrors = [
      'too-many-requests',
      'network-request-failed',
      'quota-exceeded',
      'internal-error',
      'network-error',
    ];
    return retryableErrors.contains(errorCode);
  }
}