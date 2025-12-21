// lib/services/email_verification_service.dart
// Email Verification Service for handling conditional redirection after password reset
// Implements the core functionality for email verification status checking and redirection

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Result class for email verification operations
class EmailVerificationResult {
  final bool isSuccess;
  final String message;
  final String? email;
  final bool requiresRedirection;

  const EmailVerificationResult({
    required this.isSuccess,
    required this.message,
    this.email,
    this.requiresRedirection = false,
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

  factory EmailVerificationResult.redirectRequired(
      String message, String email) {
    return EmailVerificationResult(
      isSuccess: true,
      message: message,
      email: email,
      requiresRedirection: true,
    );
  }
}

/// Email verification service for handling password reset and email verification workflow
class EmailVerificationService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if current user needs email verification after password reset
  /// Returns true if user is logged in and email is not verified
  static bool shouldCheckEmailVerification() {
    try {
      final currentUser = _auth.currentUser;
      return currentUser != null && !currentUser.emailVerified;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email verification status: $e');
      }
      return false;
    }
  }

  /// Enhanced password reset service with email verification checking
  /// Returns EmailVerificationResult with redirection information
  static Future<EmailVerificationResult>
      sendPasswordResetWithEmailVerificationCheck({
    required String email,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
            'Starting password reset with email verification check for: ${email.replaceRange(2, email.indexOf('@'), '***')}');
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      // Check if current user needs email verification
      bool shouldRedirect = false;
      final currentUser = _auth.currentUser;

      if (currentUser != null &&
          currentUser.email == email &&
          !currentUser.emailVerified) {
        shouldRedirect = true;
        if (kDebugMode) {
          debugPrint('User has unverified email - redirection required');
        }
      }

      if (shouldRedirect) {
        return EmailVerificationResult.redirectRequired(
          'Şifre sıfırlama bağlantısı gönderildi. E-posta adresinizin doğrulanmamış olduğunu görüyoruz.',
          email,
        );
      } else {
        return EmailVerificationResult.success(
          'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. 📧',
          email,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Password reset error: ${e.code} - ${e.message}');
      }

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage =
              'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.';
          break;
        case 'invalid-email':
          errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Çok fazla deneme yaptınız. Güvenliğiniz için lütfen bir süre sonra tekrar deneyin.';
          break;
        case 'network-request-failed':
          errorMessage =
              'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Şifre sıfırlama işlemi şu anda etkinleştirilmemiş. Destek ekibiyle iletişime geçin.';
          break;
        case 'user-disabled':
          errorMessage =
              'Bu hesap devre dışı bırakılmış. Destek ekibiyle iletişime geçin.';
          break;
        case 'quota-exceeded':
          errorMessage =
              'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
          break;
        case 'internal-error':
          errorMessage =
              'Firebase sunucu hatası. Lütfen birkaç dakika bekleyip tekrar deneyin.';
          break;
        default:
          errorMessage =
              'Şifre sıfırlama gönderilemedi: ${e.message ?? e.code}';
      }

      return EmailVerificationResult.failure(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected password reset error: $e');
      }
      return EmailVerificationResult.failure(
          'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  /// Send verification email to current user
  /// Returns EmailVerificationResult with success/failure information
  static Future<EmailVerificationResult> sendEmailVerification() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return EmailVerificationResult.failure('Kullanıcı oturumu bulunamadı');
      }

      // Check if email is already verified
      if (currentUser.emailVerified) {
        return EmailVerificationResult.failure(
            'E-posta adresi zaten doğrulanmış');
      }

      await currentUser.sendEmailVerification();

      if (kDebugMode) {
        debugPrint('Email verification sent to: ${currentUser.email}');
      }

      return EmailVerificationResult.success(
        'Doğrulama e-postası başarıyla gönderildi! Lütfen e-posta adresinizi kontrol edin. 📧',
        currentUser.email!,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email verification send error: $e');
      }
      return EmailVerificationResult.failure(
          'E-posta doğrulama gönderilemedi: $e');
    }
  }

  /// Check current user's email verification status
  static Future<bool> checkEmailVerificationStatus() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // Force reload to get latest status
      await currentUser.reload();
      final updatedUser = _auth.currentUser!;

      return updatedUser.emailVerified;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email verification status: $e');
      }
      return false;
    }
  }

  /// Get current user email
  static String? getCurrentUserEmail() {
    try {
      return _auth.currentUser?.email;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting current user email: $e');
      }
      return null;
    }
  }

  /// Check if user should be redirected to email verification page
  static bool shouldRedirectToEmailVerificationPage(
      EmailVerificationResult result) {
    return result.isSuccess && result.requiresRedirection;
  }
}
