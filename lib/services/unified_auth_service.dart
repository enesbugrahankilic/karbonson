import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/firebase_auth_service.dart';
import '../services/email_otp_service.dart';
import '../services/biometric_service.dart';
import '../services/biometric_user_service.dart';

/// Birleşik kimlik doğrulama servisi
/// Tüm giriş yöntemlerini (email/şifre, biyometri, SMS OTP, email OTP) tek bir arayüzde yönetir
class UnifiedAuthService {
  static final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Kimlik doğrulama sonucu
  static AuthResult _createSuccess(String message,
      {fb_auth.UserCredential? userCredential}) {
    return AuthResult.success(message, userCredential: userCredential);
  }

  static AuthResult _createFailure(String message, {AuthError? error}) {
    return AuthResult.failure(message, error: error);
  }

  /// Email ve şifre ile giriş
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential =
          await FirebaseAuthService.signInWithEmailAndPasswordWithRetry(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        return _createSuccess('Email ve şifre ile giriş başarılı',
            userCredential: userCredential);
      } else {
        return _createFailure('Giriş bilgileri geçersiz');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      final errorMessage = FirebaseAuthService.handleAuthError(e,
          context: 'email_password_login');
      return _createFailure(errorMessage, error: _mapFirebaseError(e));
    } catch (e) {
      return _createFailure('Beklenmeyen hata: $e');
    }
  }

  /// Biyometrik giriş
  static Future<AuthResult> signInWithBiometric() async {
    try {
      // Biyometri kullanılabilir mi kontrol et
      final isAvailable = await BiometricService.isBiometricAvailable();
      if (!isAvailable) {
        return _createFailure(
            'Bu cihazda biyometrik kimlik doğrulama mevcut değil');
      }

      // Kullanıcı biyometriyi etkinleştirmiş mi kontrol et
      final isEnabled = await BiometricUserService.isUserBiometricEnabled();
      if (!isEnabled) {
        return _createFailure(
            'Biyometrik giriş etkinleştirilmemiş. Lütfen önce biyometri kurulumunu tamamlayın.');
      }

      // Biyometrik kimlik doğrulama
      final success = await BiometricService.authenticateWithBiometrics(
        localizedReason:
            'Uygulamaya giriş yapmak için biyometrik kimlik doğrulamanızı sağlayın',
        useErrorDialogs: true,
      );

      if (!success) {
        return _createFailure('Biyometrik kimlik doğrulama başarısız');
      }

      // Mevcut kullanıcıyı al
      final user = _auth.currentUser;
      if (user == null) {
        return _createFailure('Kullanıcı oturumu bulunamadı');
      }

      // Biyometri giriş zamanını güncelle
      await BiometricUserService.updateLastBiometricLogin();

      return _createSuccess('Biyometrik giriş başarılı');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometrik giriş hatası: $e');
      }
      return _createFailure('Biyometrik giriş sırasında hata oluştu: $e');
    }
  }

  /// SMS OTP ile giriş
  static Future<AuthResult> signInWithSmsOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final result = await EmailOtpService.verifySmsOtpCode(
        phoneNumber: phoneNumber,
        code: otpCode,
      );

      if (result.isValid) {
        return _createSuccess('SMS OTP ile giriş başarılı');
      } else if (result.isExpired) {
        return _createFailure('SMS kodu süresi dolmuş',
            error: AuthError.codeExpired);
      } else {
        return _createFailure('Geçersiz SMS kodu',
            error: AuthError.invalidCode);
      }
    } catch (e) {
      return _createFailure('SMS doğrulama sırasında hata oluştu: $e');
    }
  }

  /// Email OTP ile giriş
  static Future<AuthResult> signInWithEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final result = await EmailOtpService.verifyOtpCode(
        email: email,
        code: otpCode,
      );

      if (result.isValid) {
        return _createSuccess('Email OTP ile giriş başarılı');
      } else if (result.isExpired) {
        return _createFailure('Email kodu süresi dolmuş',
            error: AuthError.codeExpired);
      } else {
        return _createFailure('Geçersiz email kodu',
            error: AuthError.invalidCode);
      }
    } catch (e) {
      return _createFailure('Email doğrulama sırasında hata oluştu: $e');
    }
  }

  /// SMS OTP kodu gönderme
  static Future<AuthResult> sendSmsOtp({
    required String phoneNumber,
    String purpose = 'login_verification',
  }) async {
    try {
      final result = await EmailOtpService.sendSmsOtpCode(
        phoneNumber: phoneNumber,
        purpose: purpose,
      );

      if (result.isSuccess) {
        return _createSuccess('SMS kodu gönderildi: ${result.message}');
      } else {
        return _createFailure(result.message);
      }
    } catch (e) {
      return _createFailure('SMS gönderme sırasında hata oluştu: $e');
    }
  }

  /// Email OTP kodu gönderme
  static Future<AuthResult> sendEmailOtp({
    required String email,
    String purpose = 'login_verification',
  }) async {
    try {
      final result = await EmailOtpService.sendOtpCode(
        email: email,
        purpose: purpose,
      );

      if (result.isSuccess) {
        return _createSuccess('Email kodu gönderildi: ${result.message}');
      } else {
        return _createFailure(result.message);
      }
    } catch (e) {
      return _createFailure('Email gönderme sırasında hata oluştu: $e');
    }
  }

  /// Biyometrik kurulum
  static Future<AuthResult> setupBiometric() async {
    try {
      final success = await BiometricUserService.saveBiometricSetup();
      if (success) {
        return _createSuccess('Biyometrik kimlik doğrulama başarıyla kuruldu');
      } else {
        return _createFailure('Biyometrik kurulum başarısız');
      }
    } catch (e) {
      return _createFailure('Biyometrik kurulum sırasında hata oluştu: $e');
    }
  }

  /// Biyometri devre dışı bırakma
  static Future<AuthResult> disableBiometric() async {
    try {
      final success = await BiometricUserService.disableBiometric();
      if (success) {
        return _createSuccess('Biyometrik giriş devre dışı bırakıldı');
      } else {
        return _createFailure('Biyometri devre dışı bırakma başarısız');
      }
    } catch (e) {
      return _createFailure(
          'Biyometri devre dışı bırakma sırasında hata oluştu: $e');
    }
  }

  /// Biyometri durum kontrolü
  static Future<bool> isBiometricEnabled() async {
    try {
      return await BiometricUserService.isUserBiometricEnabled();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri durum kontrol hatası: $e');
      }
      return false;
    }
  }

  /// Biyometri kullanılabilir mi kontrolü
  static Future<bool> isBiometricAvailable() async {
    try {
      return await BiometricService.isBiometricAvailable();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri kullanılabilirlik kontrol hatası: $e');
      }
      return false;
    }
  }

  /// Firebase hatalarını AuthError'a dönüştür
  static AuthError _mapFirebaseError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthError.userNotFound;
      case 'wrong-password':
        return AuthError.wrongPassword;
      case 'invalid-email':
        return AuthError.invalidEmail;
      case 'user-disabled':
        return AuthError.userDisabled;
      case 'too-many-requests':
        return AuthError.tooManyRequests;
      case 'network-request-failed':
        return AuthError.networkError;
      default:
        return AuthError.unknown;
    }
  }

  /// Mevcut kullanıcıyı al
  static fb_auth.User? get currentUser => _auth.currentUser;

  /// Oturum açık mı kontrol et
  static bool get isSignedIn => _auth.currentUser != null;

  /// Çıkış yap
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}

/// Kimlik doğrulama sonucu
class AuthResult {
  final bool isSuccess;
  final String message;
  final fb_auth.UserCredential? userCredential;
  final AuthError? error;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
    this.userCredential,
    this.error,
  });

  factory AuthResult.success(String message,
      {fb_auth.UserCredential? userCredential}) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      userCredential: userCredential,
    );
  }

  factory AuthResult.failure(String message, {AuthError? error}) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      error: error,
    );
  }
}

/// Kimlik doğrulama hataları
enum AuthError {
  userNotFound,
  wrongPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,
  networkError,
  codeExpired,
  invalidCode,
  biometricNotAvailable,
  biometricNotEnabled,
  unknown,
}

/// AuthError extension'ları
extension AuthErrorExtension on AuthError {
  String get displayMessage {
    switch (this) {
      case AuthError.userNotFound:
        return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı';
      case AuthError.wrongPassword:
        return 'Şifre yanlış';
      case AuthError.invalidEmail:
        return 'Geçersiz email adresi';
      case AuthError.userDisabled:
        return 'Bu hesap devre dışı bırakılmış';
      case AuthError.tooManyRequests:
        return 'Çok fazla giriş denemesi. Lütfen daha sonra tekrar deneyin';
      case AuthError.networkError:
        return 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin';
      case AuthError.codeExpired:
        return 'Doğrulama kodu süresi dolmuş. Yeni kod isteyin';
      case AuthError.invalidCode:
        return 'Geçersiz doğrulama kodu';
      case AuthError.biometricNotAvailable:
        return 'Bu cihazda biyometrik kimlik doğrulama mevcut değil';
      case AuthError.biometricNotEnabled:
        return 'Biyometrik giriş etkinleştirilmemiş';
      case AuthError.unknown:
        return 'Bilinmeyen bir hata oluştu';
    }
  }

  String get recoverySuggestion {
    switch (this) {
      case AuthError.userNotFound:
        return 'Kayıt olmak için "Kayıt Ol" butonuna tıklayın';
      case AuthError.wrongPassword:
        return 'Şifrenizi mi unuttunuz? "Şifremi Unuttum" bağlantısını kullanın';
      case AuthError.codeExpired:
        return 'Yeni bir doğrulama kodu için "Tekrar Gönder" butonuna tıklayın';
      case AuthError.invalidCode:
        return 'Kodu tekrar kontrol edin veya yeni kod isteyin';
      case AuthError.biometricNotEnabled:
        return 'Profil ayarlarından biyometrik girişi etkinleştirin';
      default:
        return 'Lütfen tekrar deneyin veya destek ekibiyle iletişime geçin';
    }
  }
}
