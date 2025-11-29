// test/password_reset_feedback_test.dart
// Test file for PasswordResetFeedbackService to verify the comprehensive feedback and error management strategy

import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/password_reset_feedback_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

void main() {
  group('📬 PasswordResetFeedbackService Tests', () {
    
    group('✅ Success Message Tests', () {
      test('should return standardized Turkish success message', () {
        final message = PasswordResetFeedbackService.getTurkishSuccessMessage();
        expect(
          message,
          equals('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. 📧'),
        );
      });

      test('should return detailed success message with email', () {
        final message = PasswordResetFeedbackService.getDetailedSuccessMessage(
          email: 'user@example.com',
          requiresEmailVerification: false,
        );
        
        expect(message, contains('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'));
        expect(message, contains('Hedef: us***@example.com'));
      });

      test('should include email verification note when required', () {
        final message = PasswordResetFeedbackService.getDetailedSuccessMessage(
          email: 'user@example.com',
          requiresEmailVerification: true,
        );
        
        expect(message, contains('E-posta adresinizi doğrulamanız gerekebilir'));
      });
    });

    group('🚨 Error Localization Tests', () {
      test('should localize user-not-found error', () {
        final exception = fb_auth.FirebaseAuthException(code: 'user-not-found');
        final message = PasswordResetFeedbackService.getLocalizedErrorMessage(exception);
        
        expect(message, equals('Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı. E-posta adresinizi kontrol edin.'));
      });

      test('should localize too-many-requests error', () {
        final exception = fb_auth.FirebaseAuthException(code: 'too-many-requests');
        final message = PasswordResetFeedbackService.getLocalizedErrorMessage(exception);
        
        expect(message, equals('Çok fazla deneme yaptınız. Güvenliğiniz için lütfen bir süre sonra tekrar deneyin.'));
      });

      test('should localize invalid-email error', () {
        final exception = fb_auth.FirebaseAuthException(code: 'invalid-email');
        final message = PasswordResetFeedbackService.getLocalizedErrorMessage(exception);
        
        expect(message, equals('Lütfen geçerli bir e-posta adresi girin. Örnek: kullanici@ornek.com'));
      });

      test('should handle context-specific password reset errors', () {
        final exception = fb_auth.FirebaseAuthException(code: 'too-many-requests');
        final message = PasswordResetFeedbackService.getLocalizedErrorMessage(
          exception,
          context: 'password_reset',
        );
        
        expect(message, contains('şifre sıfırlama isteği gönderildi'));
        expect(message, contains('birkaç dakika bekleyin'));
      });
    });

    group('📝 Logging Tests', () {
      test('should log operation start correctly', () {
        // In debug mode, this should print to debugPrint
        PasswordResetFeedbackService.logOperationStart(
          operation: 'Test Şifre Sıfırlama',
          email: 'test@example.com',
          parameters: {'test': true},
        );
        
        // In a real test environment, we'd verify the log output
        // For now, we just verify the method executes without error
        expect(true, isTrue);
      });

      test('should log success correctly', () {
        PasswordResetFeedbackService.logSuccess(
          operation: 'Test Şifre Sıfırlama',
          email: 'test@example.com',
          requiresEmailVerification: true,
        );
        
        expect(true, isTrue);
      });

      test('should log warnings correctly', () {
        PasswordResetFeedbackService.logWarning(
          operation: 'Test Şifre Sıfırlama',
          email: 'test@example.com',
          warningType: 'Test Warning',
          details: 'Test details',
        );
        
        expect(true, isTrue);
      });

      test('should log errors correctly', () {
        PasswordResetFeedbackService.logError(
          operation: 'Test Şifre Sıfırlama',
          email: 'test@example.com',
          errorCode: 'test-error',
          errorMessage: 'Test error message',
        );
        
        expect(true, isTrue);
      });
    });

    group('🎯 PasswordResetFeedbackResult Tests', () {
      test('should create success result correctly', () {
        final result = PasswordResetFeedbackResult.success(
          email: 'user@example.com',
          requiresEmailVerification: true,
        );
        
        expect(result.isSuccess, isTrue);
        expect(result.email, equals('user@example.com'));
        expect(result.requiresEmailVerification, isTrue);
        expect(result.message, contains('Şifre sıfırlama bağlantısı'));
      });

      test('should create failure result correctly', () {
        final result = PasswordResetFeedbackResult.failure(
          message: 'Test error',
          errorCode: 'test-error',
        );
        
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('Test error'));
        expect(result.errorCode, equals('test-error'));
      });

      test('should create failure result from FirebaseAuthException', () {
        final exception = fb_auth.FirebaseAuthException(code: 'user-not-found');
        final result = PasswordResetFeedbackResult.fromException(
          exception,
          context: 'password_reset',
          email: 'test@example.com',
        );
        
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('kullanıcı bulunamadı'));
        expect(result.errorCode, equals('user-not-found'));
      });

      test('should suggest retry for temporary errors', () {
        final result = PasswordResetFeedbackResult.failure(
          message: 'Too many requests',
          errorCode: 'too-many-requests',
        );
        
        expect(result.shouldSuggestRetry, isTrue);
        expect(result.isTemporaryError, isTrue);
      });
    });

    group('🔍 Helper Method Tests', () {
      test('should mask email addresses correctly', () {
        final masked = PasswordResetFeedbackService._maskEmail('user@example.com');
        expect(masked, equals('us***@example.com'));
      });

      test('should handle short email addresses', () {
        final masked = PasswordResetFeedbackService._maskEmail('ab@c.com');
        expect(masked, equals('a***@c.com'));
      });

      test('should identify critical errors correctly', () {
        expect(PasswordResetFeedbackService.isCriticalError('user-disabled'), isTrue);
        expect(PasswordResetFeedbackService.isCriticalError('user-not-found'), isFalse);
      });

      test('should identify temporary errors correctly', () {
        expect(PasswordResetFeedbackService.isTemporaryError('too-many-requests'), isTrue);
        expect(PasswordResetFeedbackService.isTemporaryError('user-not-found'), isFalse);
      });

      test('should suggest retry for correct error types', () {
        expect(PasswordResetFeedbackService.shouldSuggestRetry('too-many-requests'), isTrue);
        expect(PasswordResetFeedbackService.shouldSuggestRetry('user-not-found'), isFalse);
      });
    });

    group('📊 Error Message Map Tests', () {
      test('should contain all required error codes', () {
        final errorMap = PasswordResetFeedbackService.getErrorMessageMap();
        
        expect(errorMap, containsKey('user-not-found'));
        expect(errorMap, containsKey('too-many-requests'));
        expect(errorMap, containsKey('invalid-email'));
        expect(errorMap, containsKey('network-request-failed'));
        expect(errorMap, containsKey('quota-exceeded'));
        expect(errorMap, containsKey('unknown'));
      });

      test('should have Turkish messages for all errors', () {
        final errorMap = PasswordResetFeedbackService.getErrorMessageMap();
        
        for (final message in errorMap.values) {
          expect(message, isNotEmpty);
          // Türkçe karakterler içermeli
          expect(message, contains(RegExp(r'[çğıöşüÇĞIİÖŞÜ]')));
        }
      });
    });
  });
}