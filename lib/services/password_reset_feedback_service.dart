// lib/services/password_reset_feedback_service.dart
// Comprehensive feedback and error management service for password reset functionality
// Handles localized Turkish messages and logging for all password reset operations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// 📬 Geri Bildirim ve Hata Yönetimi Stratejisi
/// ===========================================
/// Bu servis, şifre sıfırlama işlemleri için kapsamlı geri bildirim ve hata yönetimi sağlar:
/// - Başarı mesajları: Standart ve yerelleştirilmiş format
/// - Hata yerelleştirmesi: FirebaseAuthException kodları için Türkçe mesajlar
/// - Loglama: Tüm işlemler için uygun seviyede loglama (info, warning, error)

class PasswordResetFeedbackService {
  /// ===========================================
  /// 1. 📧 BAŞARI MESAJLARI
  /// ===========================================
  
  /// Standart Türkçe başarı mesajı - şifre sıfırlama bağlantısı gönderildi
  static String getTurkishSuccessMessage() {
    return "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. 📧";
  }
  
  /// Genişletilmiş başarı mesajı - ek bilgiler ile
  static String getDetailedSuccessMessage({
    required String email,
    bool requiresEmailVerification = false,
  }) {
    final baseMessage = getTurkishSuccessMessage();
    final maskedEmail = _maskEmail(email);
    
    if (requiresEmailVerification) {
      return "$baseMessage\n\nNot: E-posta adresinizi doğrulamanız gerekebilir ($maskedEmail).";
    }
    
    return "$baseMessage\n\nHedef: $maskedEmail";
  }
  
  /// ===========================================
  /// 2. 🚨 HATA YERELLEŞTİRME HARİTASI
  /// ===========================================
  
  /// FirebaseAuthException kodları için merkezi Türkçe hata mesajları haritası
  static Map<String, String> getErrorMessageMap() {
    return {
      // Kullanıcı bulunamadı hataları
      'user-not-found': 'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı. E-posta adresinizi kontrol edin.',
      
      // E-posta geçerliliği hataları
      'invalid-email': 'Lütfen geçerli bir e-posta adresi girin. Örnek: kullanici@ornek.com',
      'invalid-continue-uri': 'Geçersiz bağlantı formatı. Lütfen tekrar deneyin.',
      
      // Rate limiting hataları
      'too-many-requests': 'Çok fazla deneme yaptınız. Güvenliğiniz için lütfen bir süre sonra tekrar deneyin.',
      'quota-exceeded': 'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.',
      
      // İnternet bağlantısı hataları
      'network-request-failed': 'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.',
      
      // Operasyon izinleri hataları
      'operation-not-allowed': 'Şifre sıfırlama işlemi şu anda etkinleştirilmemiş. Destek ekibiyle iletişime geçin.',
      'email-send-rate-limit-exceeded': 'E-posta gönderim limiti aşıldı. Lütfen birkaç dakika bekleyin.',
      
      // Hesap durumu hataları
      'user-disabled': 'Bu hesap devre dışı bırakılmış. Destek ekibiyle iletişime geçin.',
      
      // Sunucu hataları
      'internal-error': 'Firebase sunucu hatası. Lütfen birkaç dakika bekleyip tekrar deneyin.',
      'admin-restricted-operation': 'Bu işlem geçici olarak kısıtlanmış. Lütfen daha sonra tekrar deneyin.',
      
      // Doğrulama kodları hataları
      'expired-action-code': 'Bu şifre sıfırlama bağlantısının süresi dolmuş. Lütfen yeni bir bağlantı isteyin.',
      'invalid-action-code': 'Geçersiz veya kullanılmış sıfırlama kodu. Lütfen yeni bir bağlantı isteyin.',
      'weak-password': 'Yeni şifreniz çok zayıf. Daha güçlü bir şifre seçin.',
      'requires-recent-login': 'Bu işlem için tekrar giriş yapmanız gerekiyor.',
      
      // Bilinmeyen hatalar
      'unknown': 'Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.',
    };
  }
  
  /// Context-aware hata mesajı alıcısı
  /// FirebaseAuthException kodunu Türkçe kullanıcı dostu mesaja dönüştürür
  static String getLocalizedErrorMessage(
    FirebaseAuthException exception, {
    String? context,
  }) {
    final errorMap = getErrorMessageMap();
    final errorCode = exception.code;
    
    // Context-aware mesajlar
    if (context != null) {
      switch (context.toLowerCase()) {
        case 'password_reset':
        case 'password_reset_email':
          return _getContextSpecificErrorMessage(errorCode, exception, errorMap);
      }
    }
    
    // Genel hata mesajı
    return errorMap[errorCode] ?? 
           errorMap['unknown'] ?? 
           'Şifre sıfırlama gönderilemedi: ${exception.message ?? errorCode}';
  }
  
  /// Context-specific hata mesajları için yardımcı metod
  static String _getContextSpecificErrorMessage(
    String errorCode, 
    FirebaseAuthException exception, 
    Map<String, String> errorMap
  ) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı. E-posta adresinizi kontrol edin.';
      case 'too-many-requests':
        return 'Çok fazla şifre sıfırlama isteği gönderildi. Güvenliğiniz için lütfen birkaç dakika bekleyin ve tekrar deneyin.';
      case 'invalid-email':
        return 'Lütfen geçerli bir e-posta adresi girin. Örnek: kullanici@ornek.com';
      case 'quota-exceeded':
        return 'Firebase kullanım limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
      default:
        return errorMap[errorCode] ?? errorMap['unknown'] ?? exception.message ?? errorCode;
    }
  }
  
  /// ===========================================
  /// 3. 📝 LOGLAMA SERVİSİ
  /// ===========================================
  
  /// İşlem başlatma logu
  static void logOperationStart({
    required String operation,
    required String email,
    Map<String, dynamic>? parameters,
  }) {
    final maskedEmail = _maskEmail(email);
    const tag = 'PasswordReset';
    final paramsStr = parameters != null ? ', Parametreler: $parameters' : '';
    final message = "[$tag] 🚀 $operation başlatıldı - E-posta: $maskedEmail$paramsStr";
    
    if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  /// Info seviyesinde loglama - başarılı işlemler
  static void logSuccess({
    required String operation,
    required String email,
    bool requiresEmailVerification = false,
  }) {
    final maskedEmail = _maskEmail(email);
    const tag = 'PasswordReset';
    final message = "[$tag] ✅ $operation başarılı - E-posta: $maskedEmail, E-posta doğrulama: ${requiresEmailVerification ? 'Gerekli' : 'Gerekli değil'}";
    
    if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  /// Warning seviyesinde loglama - beklenen hatalar
  static void logWarning({
    required String operation,
    required String email,
    required String warningType,
    String? details,
  }) {
    final maskedEmail = _maskEmail(email);
    const tag = 'PasswordReset';
    final message = "[$tag] ⚠️ $operation uyarısı - E-posta: $maskedEmail, Tür: $warningType${details != null ? ', Detay: $details' : ''}";
    
    if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  /// Error seviyesinde loglama - başarısız işlemler
  static void logError({
    required String operation,
    required String email,
    required String errorCode,
    String? errorMessage,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    final maskedEmail = _maskEmail(email);
    const tag = 'PasswordReset';
    final message = "[$tag] ❌ $operation hatası - E-posta: $maskedEmail, Kod: $errorCode${errorMessage != null ? ', Mesaj: $errorMessage' : ''}${exception != null ? ', Exception: $exception' : ''}";
    
    if (kDebugMode) {
      debugPrint(message);
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
  
  /// ===========================================
  /// 4. 🔍 YARDIMCI METODLAR
  /// ===========================================
  
  /// E-posta adresini maskeler (güvenlik için)
  static String _maskEmail(String email) {
    if (!email.contains('@') || email.length < 5) {
      return '***';
    }
    
    final parts = email.split('@');
    final localPart = parts[0];
    final domain = parts[1];
    
    if (localPart.length <= 2) {
      return '${localPart[0]}***@$domain';
    }
    
    return '${localPart.substring(0, 2)}***@$domain';
  }
  
  /// Hata kodunun kritik olup olmadığını kontrol eder
  static bool isCriticalError(String errorCode) {
    const criticalErrors = {
      'user-disabled',
      'operation-not-allowed',
      'admin-restricted-operation',
    };
    return criticalErrors.contains(errorCode);
  }
  
  /// Hata kodunun geçici olup olmadığını kontrol eder
  static bool isTemporaryError(String errorCode) {
    const temporaryErrors = {
      'too-many-requests',
      'quota-exceeded',
      'network-request-failed',
      'internal-error',
      'email-send-rate-limit-exceeded',
    };
    return temporaryErrors.contains(errorCode);
  }
  
  /// Retry önerisini kontrol eder
  static bool shouldSuggestRetry(String errorCode) {
    const retryErrors = {
      'too-many-requests',
      'quota-exceeded',
      'network-request-failed',
      'internal-error',
      'email-send-rate-limit-exceeded',
    };
    return retryErrors.contains(errorCode);
  }
}

/// ===========================================
/// 5. 🎯 PASSWORD RESET FEEDBACK RESULT
/// ===========================================

/// Password reset işlem sonucu için enhanced feedback sınıfı
class PasswordResetFeedbackResult {
  final bool isSuccess;
  final String message;
  final String? email;
  final bool requiresEmailVerification;
  final bool shouldSuggestRetry;
  final bool isTemporaryError;
  final String? errorCode;
  final String? originalError;
  
  const PasswordResetFeedbackResult({
    required this.isSuccess,
    required this.message,
    this.email,
    this.requiresEmailVerification = false,
    this.shouldSuggestRetry = false,
    this.isTemporaryError = false,
    this.errorCode,
    this.originalError,
  });
  
  /// Başarılı sonuç factory'si
  factory PasswordResetFeedbackResult.success({
    required String email,
    bool requiresEmailVerification = false,
  }) {
    return PasswordResetFeedbackResult(
      isSuccess: true,
      message: PasswordResetFeedbackService.getDetailedSuccessMessage(
        email: email,
        requiresEmailVerification: requiresEmailVerification,
      ),
      email: email,
      requiresEmailVerification: requiresEmailVerification,
    );
  }
  
  /// Başarısız sonuç factory'si
  factory PasswordResetFeedbackResult.failure({
    required String message,
    String? errorCode,
    String? originalError,
  }) {
    final shouldSuggestRetry = errorCode != null && 
        PasswordResetFeedbackService.shouldSuggestRetry(errorCode);
    final isTemporaryError = errorCode != null && 
        PasswordResetFeedbackService.isTemporaryError(errorCode);
    
    return PasswordResetFeedbackResult(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
      originalError: originalError,
      shouldSuggestRetry: shouldSuggestRetry,
      isTemporaryError: isTemporaryError,
    );
  }
  
  /// FirebaseAuthException'dan failure result oluşturur
  factory PasswordResetFeedbackResult.fromException(
    FirebaseAuthException exception, {
    String? context,
    String? email,
  }) {
    final message = PasswordResetFeedbackService.getLocalizedErrorMessage(
      exception,
      context: context,
    );
    
    return PasswordResetFeedbackResult.failure(
      message: message,
      errorCode: exception.code,
      originalError: exception.message,
    );
  }
}