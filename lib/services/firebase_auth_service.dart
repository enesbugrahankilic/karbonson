// lib/services/firebase_auth_service.dart
// Simplified Firebase Authentication Service with essential functionality

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/password_reset_data.dart';
import '../services/profile_service.dart';
import '../services/password_reset_feedback_service.dart';

/// Result class for email verification operations
class EmailVerificationResult {
  final bool isSuccess;
  final String message;
  final String? email;

  const EmailVerificationResult({
    required this.isSuccess,
    required this.message,
    this.email,
  });

  factory EmailVerificationResult.success(String message, String email) {
    return EmailVerificationResult(
      isSuccess: true,
      message: message,
      email: email,
    );
  }

  factory EmailVerificationResult.failure(String message) {
    return EmailVerificationResult(
      isSuccess: false,
      message: message,
    );
  }
}

/// Result class for password reset operations with enhanced feedback
class PasswordResetResult {
  final bool isSuccess;
  final String message;
  final String? email;
  final bool requiresEmailVerification;
  final bool shouldShowSuccessDialog;

  const PasswordResetResult({
    required this.isSuccess,
    required this.message,
    this.email,
    this.requiresEmailVerification = false,
    this.shouldShowSuccessDialog = false,
  });

  factory PasswordResetResult.success({
    required String message,
    required String email,
    bool requiresEmailVerification = false,
    bool shouldShowSuccessDialog = true,
  }) {
    return PasswordResetResult(
      isSuccess: true,
      message: message,
      email: email,
      requiresEmailVerification: requiresEmailVerification,
      shouldShowSuccessDialog: shouldShowSuccessDialog,
    );
  }

  factory PasswordResetResult.failure(String message) {
    return PasswordResetResult(
      isSuccess: false,
      message: message,
    );
  }

  /// Get localized Turkish success message for password reset
  String getTurkishSuccessMessage() {
    if (isSuccess) {
      return 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. 📧';
    }
    return message;
  }
}

/// Email verification status information
class EmailVerificationStatus {
  final bool isVerified;
  final bool hasEmail;
  final String? email;
  final String message;

  const EmailVerificationStatus({
    required this.isVerified,
    required this.hasEmail,
    this.email,
    required this.message,
  });
}

/// Result class for 2FA verification operations
class TwoFactorVerificationResult {
  final bool isSuccess;
  final String message;
  final String? userId;
  final fb_auth.PhoneAuthCredential? credential;
  final bool isExpired;

  const TwoFactorVerificationResult({
    required this.isSuccess,
    required this.message,
    this.userId,
    this.credential,
    this.isExpired = false,
  });

  factory TwoFactorVerificationResult.success({
    required String message,
    String? userId,
    fb_auth.PhoneAuthCredential? credential,
  }) {
    return TwoFactorVerificationResult(
      isSuccess: true,
      message: message,
      userId: userId,
      credential: credential,
    );
  }

  factory TwoFactorVerificationResult.failure(String message) {
    return TwoFactorVerificationResult(
      isSuccess: false,
      message: message,
    );
  }

  factory TwoFactorVerificationResult.expired(String message) {
    return TwoFactorVerificationResult(
      isSuccess: false,
      message: message,
      isExpired: true,
    );
  }

  /// Get localized Turkish success message for 2FA verification
  String getTurkishMessage() {
    if (isSuccess) {
      return message;
    } else if (isExpired) {
      return 'Doğrulama kodu süresi dolmuş. Yeni bir kod isteyin.';
    }
    return message;
  }
}

/// Result class for 2FA setup and management operations
class TwoFactorManagementResult {
  final bool isSuccess;
  final String message;
  final String? phoneNumber;
  final bool wasEnabled;
  final bool wasDisabled;

  const TwoFactorManagementResult({
    required this.isSuccess,
    required this.message,
    this.phoneNumber,
    this.wasEnabled = false,
    this.wasDisabled = false,
  });

  factory TwoFactorManagementResult.success({
    required String message,
    String? phoneNumber,
    bool wasEnabled = false,
  }) {
    return TwoFactorManagementResult(
      isSuccess: true,
      message: message,
      phoneNumber: phoneNumber,
      wasEnabled: wasEnabled,
    );
  }

  factory TwoFactorManagementResult.disabled(String message) {
    return TwoFactorManagementResult(
      isSuccess: true,
      message: message,
      wasDisabled: true,
    );
  }

  factory TwoFactorManagementResult.failure(String message) {
    return TwoFactorManagementResult(
      isSuccess: false,
      message: message,
    );
  }

  /// Get localized Turkish success message for 2FA management
  String getTurkishMessage() {
    if (isSuccess) {
      if (wasEnabled) {
        return 'İki faktörlü doğrulama başarıyla etkinleştirildi.';
      } else if (wasDisabled) {
        return 'İki faktörlü doğrulama başarıyla devre dışı bırakıldı.';
      }
      return message;
    }
    return message;
  }
}

class FirebaseAuthService {
  static final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  // ⚡ TIMEOUT SÜRESİ 15 SANİYEDEN 5 SANİYEYE DÜŞÜRÜLDÜ
  static const Duration _defaultTimeout = Duration(seconds: 5);

  // ⚡ RETRY DELAY 2 SANİYEDEN 0.5 SANİYEYE DÜŞÜRÜLDÜ
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // ⚡ MAX RETRY 3'TEN 2'YE DÜŞÜRÜLDÜ
  static const int _maxRetries = 2;

  /// Initialize authentication persistence
  /// This ensures users stay logged in even when the app closes
  static Future<void> initializeAuthPersistence() async {
    try {
      // Set persistence to LOCAL (default) to maintain sessions across app restarts
      await _auth.setPersistence(fb_auth.Persistence.LOCAL);

      if (kDebugMode) {
        debugPrint('Firebase Auth persistence initialized to LOCAL');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize auth persistence: $e');
      }
    }
  }

  /// Check if user is currently authenticated with a persistent session
  static bool isUserAuthenticated() {
    final user = _auth.currentUser;
    return user != null;
  }

  /// Get the current authenticated user with persistent session
  static fb_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// ============================================
  /// 1. 📬 GERI BİLDİRİM VE HATA YÖNETİMİ
  /// Enhanced Turkish Localized Error Handler
  /// ============================================

  /// Enhanced authentication error handler with Turkish localization and context awareness
  static String handleAuthError(fb_auth.FirebaseAuthException e,
      {String? context}) {
    if (kDebugMode) {
      debugPrint(
          'Auth Error [${context ?? 'Unknown'}]: ${e.code} - ${e.message}');
      debugPrint('Full error details: ${e.toString()}');
    }

    // Enhanced password reset specific error mapping
    if (context == 'password_reset' || context == 'password_reset_email') {
      return _handlePasswordResetSpecificError(e);
    }

    switch (e.code) {
      case 'internal-error':
        return _handleInternalError(e, context);
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.';
      case 'too-many-requests':
        return _handleTooManyRequestsError(e, context);
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Destek ekibiyle iletişime geçin.';
      case 'user-not-found':
        return _handleUserNotFoundError(e, context);
      case 'wrong-password':
        return 'Hatalı şifre. Şifrenizi kontrol edin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
      case 'invalid-email':
        return _handleInvalidEmailError(e, context);
      case 'operation-not-allowed':
        return 'Bu işlem şu anda etkinleştirilmemiş. Firebase Authentication ayarlarını kontrol edin.';
      case 'requires-recent-login':
        return 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      case 'invalid-credential':
        return 'Kimlik bilgileri geçersiz. Tekrar deneyin.';
      case 'user-mismatch':
        return 'Kullanıcı eşleşmedi. Tekrar deneyin.';
      case 'invalid-verification-code':
        return 'Doğrulama kodu geçersiz. Kodu tekrar kontrol edin.';
      case 'invalid-verification-id':
        return 'Doğrulama kimliği geçersiz. Yeni bir kod isteyin.';
      case 'custom-token-mismatch':
        return 'Token uyuşmazlığı. Tekrar deneyin.';
      case 'invalid-custom-token':
        return 'Geçersiz özel token. Tekrar deneyin.';
      case 'quota-exceeded':
        return 'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
      case 'email-needs-verification':
        return 'E-posta adresinizi doğrulamanız gerekiyor.';
      case 'provider-already-linked':
        return 'Bu kimlik sağlayıcı zaten hesaba bağlı.';
      case 'requires-recent-login':
        return 'Bu işlem için son giriş yapmanız gerekiyor. Tekrar giriş yapın.';
      case 'credential-already-in-use':
        return 'Bu kimlik bilgileri zaten başka bir hesapta kullanılıyor.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir kimlik bilgisiyle kayıtlı.';
      case 'missing-verification-code':
        return 'Doğrulama kodu eksik. Lütfen kodu girin.';
      case 'missing-verification-id':
        return 'Doğrulama kimliği eksik. Yeni bir doğrulama başlatın.';
      case 'invalid-phone-number':
        return 'Telefon numarası geçersiz. Formatı kontrol edin.';
      case 'invalid-phone-number-format':
        return 'Telefon numarası formatı geçersiz.';
      case 'missing-phone-number':
        return 'Telefon numarası eksik.';
      case 'phone-number-format':
        return 'Telefon numarası formatı geçersiz.';
      case 'phone-number-verification-failed':
        return 'Telefon numarası doğrulaması başarısız.';
      case 'session-expired':
        return 'Oturum süresi dolmuş. Tekrar giriş yapın.';
      case 'app-not-authorized':
        return 'Uygulama yetkili değil. Firebase ayarlarını kontrol edin.';
      case 'keychain-error':
        return 'Anahtar zinciri hatası. Cihaz ayarlarını kontrol edin.';
      case 'network-error':
        return 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
      default:
        if (kDebugMode) {
          debugPrint('Unhandled auth error code: ${e.code}');
        }
        return 'Beklenmeyen bir hata oluştu: ${e.message ?? e.code}';
    }
  }

  /// Handle password reset specific errors
  static String _handlePasswordResetSpecificError(
      fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı bir hesap bulunamadı. E-posta adresinizi kontrol edin veya yeni hesap oluşturun.';
      case 'invalid-email':
        return 'E-posta adresi geçersiz. Lütfen doğru bir e-posta adresi girin.';
      case 'too-many-requests':
        return 'Çok fazla şifre sıfırlama isteği gönderildi. Lütfen birkaç dakika bekleyin ve tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.';
      case 'operation-not-allowed':
        return 'Şifre sıfırlama işlemi şu anda etkinleştirilmemiş. Destek ekibiyle iletişime geçin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış. Destek ekibiyle iletişime geçin.';
      case 'quota-exceeded':
        return 'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
      case 'internal-error':
        return 'Firebase sunucu hatası. Lütfen birkaç dakika bekleyip tekrar deneyin.';
      default:
        return 'Şifre sıfırlama gönderilemedi: ${e.code}';
    }
  }

  /// Handle too many requests error with context
  static String _handleTooManyRequestsError(
      fb_auth.FirebaseAuthException e, String? context) {
    final waitTime = context == 'login' ? '15 dakika' : '5 dakika';
    return 'Çok fazla deneme yapıldı. Lütfen $waitTime bekleyin ve tekrar deneyin.';
  }

  /// Handle user not found error with context
  static String _handleUserNotFoundError(
      fb_auth.FirebaseAuthException e, String? context) {
    if (context == 'password_reset') {
      return 'Bu e-posta adresi ile kayıtlı bir hesap bulunamadı. E-posta adresinizi kontrol edin veya yeni hesap oluşturun.';
    }
    return 'Bu kullanıcı bulunamadı. Hesabınızı kontrol edin.';
  }

  /// Handle invalid email error with context
  static String _handleInvalidEmailError(
      fb_auth.FirebaseAuthException e, String? context) {
    if (context == 'password_reset') {
      return 'E-posta adresi geçersiz. Lütfen doğru bir e-posta adresi girin.';
    }
    return 'E-posta adresi formatı geçersiz.';
  }

  /// Handle internal error with context
  static String _handleInternalError(
      fb_auth.FirebaseAuthException e, String? context) {
    return 'Firebase sunucu hatası. Lütfen birkaç dakika bekleyip tekrar deneyin.';
  }

  /// ============================================
  /// 2. 🔐 PASSWORD RESET FUNCTIONALITY
  /// Enhanced password reset methods
  /// ============================================

  /// Enhanced password reset with comprehensive error handling
  static Future<PasswordResetResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      // Validate email format first
      if (!_isValidEmail(email)) {
        return PasswordResetResult.failure('Geçerli bir e-posta adresi girin');
      }

      // Check network connectivity
      if (!(await _isNetworkAvailable())) {
        return PasswordResetResult.failure(
            'İnternet bağlantınızı kontrol edin. Çevrimdışı modda şifre sıfırlama işlemi yapılamaz.');
      }

      if (kDebugMode) {
        debugPrint(
            'Starting password reset for email: ${email.replaceRange(2, email.indexOf('@'), '***')}');
      }

      // Enhanced Firebase password reset with retry logic
      await _auth.sendPasswordResetEmail(email: email);

      // Show success feedback
      return PasswordResetResult.success(
        message: 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
        email: email,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      // Convert Firebase error to localized message
      final localizedError =
          handleAuthError(e, context: 'password_reset_email');

      return PasswordResetResult.failure(localizedError);
    } catch (e) {
      return PasswordResetResult.failure(
          "Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.");
    }
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && email.isNotEmpty;
  }

  /// Check network connectivity
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

  /// ============================================
  /// 3. 🔒 CORE AUTHENTICATION METHODS
  /// Enhanced sign in/up with retry logic
  /// ============================================

  /// Enhanced anonymous sign in with retry logic
  static Future<fb_auth.User?> signInAnonymouslyWithRetry(
      {int maxRetries = _maxRetries}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;

        if (kDebugMode) {
          debugPrint('Anonymous sign in attempt $attempts/$maxRetries');
        }

        final userCredential = await _auth.signInAnonymously();
        final user = userCredential.user;

        if (user != null) {
          if (kDebugMode) {
            debugPrint('Anonymous sign in successful for user: ${user.uid}');
          }
          return user;
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint('Anonymous sign in attempt $attempts failed: ${e.code}');
        }

        // If it's the last attempt, throw the error
        if (attempts >= maxRetries) {
          throw e;
        }

        // Wait before retrying
        await Future.delayed(_retryDelay);
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Anonymous sign in attempt $attempts failed with unexpected error: $e');
        }

        if (attempts >= maxRetries) {
          rethrow;
        }

        await Future.delayed(_retryDelay);
      }
    }

    return null;
  }

  /// Enhanced email/password registration with retry logic
  static Future<fb_auth.UserCredential?>
      createUserWithEmailAndPasswordWithRetry({
    required String email,
    required String password,
    int maxRetries = _maxRetries,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;

        if (kDebugMode) {
          debugPrint(
              'Email/password registration attempt $attempts/$maxRetries for email: ${email.replaceRange(2, email.indexOf('@'), '***')}');
        }

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (kDebugMode) {
          debugPrint(
              'Email/password registration successful for user: ${userCredential.user?.uid}');
        }

        return userCredential;
      } on fb_auth.FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Email/password registration attempt $attempts failed: ${e.code}');
        }

        // If it's the last attempt, throw the error
        if (attempts >= maxRetries) {
          rethrow;
        }

        // Check if it's a retryable error
        if (_isRetryableError(e.code)) {
          await Future.delayed(_retryDelay);
        } else {
          rethrow;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Email/password registration attempt $attempts failed with unexpected error: $e');
        }

        if (attempts >= maxRetries) {
          rethrow;
        }

        await Future.delayed(_retryDelay);
      }
    }

    return null;
  }

  /// Enhanced email/password sign in with retry logic
  static Future<fb_auth.UserCredential?> signInWithEmailAndPasswordWithRetry({
    required String email,
    required String password,
    int maxRetries = _maxRetries,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;

        if (kDebugMode) {
          debugPrint(
              'Email/password sign in attempt $attempts/$maxRetries for email: ${email.replaceRange(2, email.indexOf('@'), '***')}');
        }

        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (kDebugMode) {
          debugPrint(
              'Email/password sign in successful for user: ${userCredential.user?.uid}');
        }

        return userCredential;
      } on fb_auth.FirebaseAuthException catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Email/password sign in attempt $attempts failed: ${e.code}');
        }

        // If it's the last attempt, throw the error
        if (attempts >= maxRetries) {
          rethrow;
        }

        // Check if it's a retryable error
        if (_isRetryableError(e.code)) {
          await Future.delayed(_retryDelay);
        } else {
          rethrow;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'Email/password sign in attempt $attempts failed with unexpected error: $e');
        }

        if (attempts >= maxRetries) {
          rethrow;
        }

        await Future.delayed(_retryDelay);
      }
    }

    return null;
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

  /// ============================================
  /// 4. 📧 EMAIL VERIFICATION METHODS
  /// Enhanced email verification functionality
  /// ============================================

  /// Send email verification link with enhanced feedback
  static Future<EmailVerificationResult> sendEmailVerification({
    fb_auth.ActionCodeSettings? actionCodeSettings,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return EmailVerificationResult.failure(
            'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
      }

      if (user.emailVerified) {
        return EmailVerificationResult.success(
          'E-posta adresiniz zaten doğrulanmış.',
          user.email!,
        );
      }

      // Send verification email
      await user.sendEmailVerification(actionCodeSettings);

      return EmailVerificationResult.success(
        'Doğrulama e-postası e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin.',
        user.email!,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      final errorMessage = handleAuthError(e, context: 'email_verification');
      return EmailVerificationResult.failure(errorMessage);
    } catch (e) {
      return EmailVerificationResult.failure(
          'Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  /// Check if email is verified with enhanced status
  static Future<EmailVerificationStatus> checkEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return const EmailVerificationStatus(
          isVerified: false,
          hasEmail: false,
          email: null,
          message: 'Kullanıcı oturumu bulunamadı',
        );
      }

      // Force refresh user data to get latest verification status
      await user.reload();
      final refreshedUser = _auth.currentUser!;

      final hasEmail =
          refreshedUser.email != null && refreshedUser.email!.isNotEmpty;
      final isVerified = refreshedUser.emailVerified;

      return EmailVerificationStatus(
        isVerified: isVerified,
        hasEmail: hasEmail,
        email: refreshedUser.email,
        message: isVerified
            ? 'E-posta adresi doğrulanmış'
            : 'E-posta adresinizi doğrulamanız gerekiyor',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to check email verification status: $e');
      }
      return const EmailVerificationStatus(
        isVerified: false,
        hasEmail: false,
        email: null,
        message: 'Doğrulama durumu kontrol edilemedi',
      );
    }
  }

  /// Check and validate Firebase authentication configuration
  static Future<bool> checkAuthConfiguration() async {
    try {
      final user = _auth.currentUser;
      // Basic check - if we can access currentUser, auth is configured
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auth configuration check failed: $e');
      }
      return false;
    }
  }

  /// Validate Firebase configuration
  static Future<bool> validateFirebaseConfig() async {
    try {
      await _auth.authStateChanges().first.timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase config validation failed: $e');
      }
      return false;
    }
  }

  /// Check if anonymous authentication is enabled
  static Future<bool> checkAnonymousAuthEnabled() async {
    try {
      // Try to sign in anonymously - if it works, anonymous auth is enabled
      await _auth.signInAnonymously();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Anonymous auth check failed: $e');
      }
      return false;
    }
  }

  /// Get debug information about Firebase Auth state
  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final user = _auth.currentUser;
      return {
        'currentUser': user != null,
        'userId': user?.uid,
        'email': user?.email,
        'emailVerified': user?.emailVerified,
        'isAnonymous': user?.isAnonymous,
        'providerData':
            user?.providerData.map((data) => data.providerId).toList(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get debug info: $e');
      }
      return {'error': e.toString()};
    }
  }

  /// Enhanced password reset method (legacy compatibility)
  static Future<void> sendPasswordReset(String email) async {
    final result = await sendPasswordResetEmail(email: email);
    if (!result.isSuccess) {
      throw Exception(result.message);
    }
  }

  /// Get password reset success message (legacy compatibility)
  static String getPasswordResetSuccessMessage() {
    return 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. 📧';
  }

  /// Get password reset error message (legacy compatibility)
  static String getPasswordResetErrorMessage(fb_auth.FirebaseAuthException e) {
    return handleAuthError(e, context: 'password_reset_email');
  }

  /// Confirm password reset with new password
  static Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }
}
