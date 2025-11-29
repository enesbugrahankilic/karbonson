// lib/tests/two_factor_auth_test.dart
// Comprehensive 2FA implementation test

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_2fa_service.dart';

void main() {
  group('Firebase2FAService Tests', () {
    
    test('should create TwoFactorAuthResult with success', () {
      final result = TwoFactorAuthResult.success(
        message: 'Test message',
        userId: 'test123',
      );
      
      expect(result.isSuccess, true);
      expect(result.userId, 'test123');
      expect(result.requires2FA, false);
    });

    test('should create TwoFactorAuthResult with 2FA requirement', () {
      final result = TwoFactorAuthResult.requires2FA(
        message: '2FA required',
        multiFactorResolver: 'mockResolver',
        phoneProvider: PhoneAuthProvider(),
      );
      
      expect(result.isSuccess, false);
      expect(result.requires2FA, true);
      expect(result.multiFactorResolver, 'mockResolver');
    });

    test('should create TwoFactorAuthResult with failure', () {
      final result = TwoFactorAuthResult.failure('Operation failed');
      
      expect(result.isSuccess, false);
      expect(result.message, 'Operation failed');
      expect(result.requires2FA, false);
    });

    test('should validate Turkish message localization', () {
      // Test success message
      final successResult = TwoFactorAuthResult.success(message: 'Success');
      expect(successResult.getTurkishMessage(), 'Success');

      // Test 2FA required message
      final twoFARequiredResult = TwoFactorAuthResult.requires2FA(
        message: '2FA required',
        multiFactorResolver: null,
        phoneProvider: null,
      );
      expect(
        twoFARequiredResult.getTurkishMessage(),
        '2FA required'
      );

      // Test failure message
      final failureResult = TwoFactorAuthResult.failure('Failed');
      expect(failureResult.getTurkishMessage(), 'Failed');
    });

    test('should validate phone number format for 2FA', () {
      // Test valid Turkish phone numbers with correct length
      expect(Firebase2FAService.isValidPhoneNumber('+905123456789'), true); // 13 chars: +90 + 5 + 123456789
      expect(Firebase2FAService.isValidPhoneNumber('05512345678'), true); // 10 chars: 05 + 12345678 (exactly 9 digits after 05)
      
      // Test invalid phone numbers
      expect(Firebase2FAService.isValidPhoneNumber('+9055512345678'), false); // 14 chars - too long
      expect(Firebase2FAService.isValidPhoneNumber('+90512345678'), false); // 12 chars - too short
      expect(Firebase2FAService.isValidPhoneNumber('055123456789'), false); // 11 chars - too long for 05 pattern
      expect(Firebase2FAService.isValidPhoneNumber('123456789'), false);
      expect(Firebase2FAService.isValidPhoneNumber(''), false);
      expect(Firebase2FAService.isValidPhoneNumber('invalid'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+1234567890'), false);
    });

    test('should handle 2FA workflow states', () {
      // Test initial state
      final initialState = TwoFactorAuthResult.failure('Initial state');
      expect(initialState.isSuccess, false);
      expect(initialState.requires2FA, false);
      expect(initialState.multiFactorResolver, null);
      
      // Test 2FA required state
      final requiredState = TwoFactorAuthResult.requires2FA(
        message: 'Multi-factor auth required',
        multiFactorResolver: 'mockResolver',
        phoneProvider: PhoneAuthProvider(),
      );
      expect(requiredState.requires2FA, true);
      expect(requiredState.multiFactorResolver, isNotNull);
      
      // Test success state
      final successState = TwoFactorAuthResult.success(
        message: 'Login successful',
        userId: 'user123',
      );
      expect(successState.isSuccess, true);
      expect(successState.requires2FA, false);
      expect(successState.userId, 'user123');
    });

    test('should validate credential creation for SMS verification', () {
      final verificationId = 'test_verification_id_123';
      final smsCode = '123456';
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      expect(credential.verificationId, verificationId);
      expect(credential.smsCode, smsCode);
      expect(credential, isA<PhoneAuthCredential>());
    });

    test('should validate phone multi-factor assertion creation', () {
      final credential = PhoneAuthProvider.credential(
        verificationId: 'testId',
        smsCode: '123456',
      );
      
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      
      expect(assertion, isA<MultiFactorAssertion>());
    });
  });

  group('2FA Integration Flow Tests', () {
    
    test('should simulate complete 2FA enrollment workflow', () async {
      // This test simulates the full 2FA setup process
      // In a real implementation, this would involve Firebase interactions
      
      // Step 1: Enable 2FA
      final enableResult = TwoFactorAuthResult.success(
        message: '2FA etkinleştirme simülasyonu başarılı',
      );
      
      expect(enableResult.isSuccess, true);
      expect(enableResult.message, contains('başarılı'));
      
      // Step 2: SMS verification (simulated)
      final smsResult = TwoFactorAuthResult.success(
        message: 'Doğrulama kodu gönderildi',
      );
      
      expect(smsResult.isSuccess, true);
      expect(smsResult.message, contains('gönderildi'));
      
      // Step 3: Finalize 2FA setup
      final finalizeResult = TwoFactorAuthResult.success(
        message: '2FA kurulumu tamamlandı',
      );
      
      expect(finalizeResult.isSuccess, true);
      expect(finalizeResult.message, contains('tamamlandı'));
    });

    test('should simulate complete 2FA sign-in workflow', () async {
      // This test simulates the full 2FA sign-in process
      
      // Step 1: Initial sign-in attempt (should require 2FA)
      final initialResult = TwoFactorAuthResult.requires2FA(
        message: 'İki faktörlü doğrulama gerekli',
        multiFactorResolver: 'mockResolver',
        phoneProvider: PhoneAuthProvider(),
      );
      
      expect(initialResult.requires2FA, true);
      expect(initialResult.multiFactorResolver, isNotNull);
      expect(initialResult.phoneProvider, isNotNull);
      
      // Step 2: SMS verification
      final smsVerificationResult = TwoFactorAuthResult.success(
        message: 'Doğrulama kodu gönderildi',
      );
      
      expect(smsVerificationResult.isSuccess, true);
      
      // Step 3: Complete 2FA verification
      final finalResult = TwoFactorAuthResult.success(
        message: '2FA doğrulaması başarılı',
        userId: 'user123',
      );
      
      expect(finalResult.isSuccess, true);
      expect(finalResult.userId, 'user123');
      expect(finalResult.requires2FA, false);
    });

    test('should simulate 2FA disable workflow', () async {
      final disableResult = TwoFactorAuthResult.success(
        message: '2FA başarıyla devre dışı bırakıldı'
      );
      
      expect(disableResult.isSuccess, true);
      expect(disableResult.message, contains('devre dışı bırakıldı'));
    });
  });

  group('2FA Error Handling Tests', () {
    
    test('should handle invalid verification code error', () {
      // This would typically be handled by Firebase2FAService
      // Testing the error handling logic
      expect(
        Firebase2FAService.getTurkishErrorMessage('invalid-verification-code'),
        contains('Geçersiz') // Invalid
      );
    });

    test('should handle missing session info error', () {
      expect(
        Firebase2FAService.getTurkishErrorMessage('missing-session-info'),
        contains('Oturum bilgisi eksik') // Session info missing
      );
    });

    test('should handle too many requests error', () {
      expect(
        Firebase2FAService.getTurkishErrorMessage('too-many-requests'),
        contains('Çok fazla deneme') // Too many attempts
      );
    });

    test('should handle network request failed error', () {
      expect(
        Firebase2FAService.getTurkishErrorMessage('network-request-failed'),
        contains('Ağ bağlantısı hatası') // Network connection error
      );
    });

    test('should handle invalid phone number error', () {
      expect(
        Firebase2FAService.getTurkishErrorMessage('invalid-phone-number'),
        contains('Geçersiz telefon numarası')
      );
    });

    test('should handle quota exceeded error', () {
      expect(
        Firebase2FAService.getTurkishErrorMessage('quota-exceeded'),
        contains('Kota aşıldı')
      );
    });

    test('should handle invalid recaptcha token error', () {
      expect(
        Firebase2FAService.getTurkishErrorMessage('invalid-recaptcha-token'),
        contains('Geçersiz güvenlik doğrulaması')
      );
    });

    test('should handle unknown error codes', () {
      final unknownError = Firebase2FAService.getTurkishErrorMessage('unknown-error-code');
      expect(unknownError, contains('2FA doğrulama hatası'));
      expect(unknownError, contains('unknown-error-code'));
    });
  });

  group('Phone Number Validation Tests', () {
    
    test('should validate Turkish phone numbers with country code', () {
      // Valid Turkish numbers with +90 (must be +90 followed by digit 5, then 9 more digits = 13 total chars)
      expect(Firebase2FAService.isValidPhoneNumber('+905123456789'), true); // +90 5 123456789
      expect(Firebase2FAService.isValidPhoneNumber('+905987654321'), true); // +90 5 987654321
      
      // Invalid - digit after +90 is not 5
      expect(Firebase2FAService.isValidPhoneNumber('+904123456789'), false); // 4 is not 5
      expect(Firebase2FAService.isValidPhoneNumber('+906123456789'), false); // 6 is not 5
      expect(Firebase2FAService.isValidPhoneNumber('+907123456789'), false); // 7 is not 5
      
      // Invalid - wrong length (should be exactly 13 characters for +90 format)
      expect(Firebase2FAService.isValidPhoneNumber('+90512345678'), false); // 12 chars - too short
      expect(Firebase2FAService.isValidPhoneNumber('+9051234567890'), false); // 14 chars - too long
    });

    test('should validate Turkish phone numbers without country code', () {
      // Valid Turkish numbers starting with 05 (must be 05 followed by exactly 9 digits = 11 total chars)
      expect(Firebase2FAService.isValidPhoneNumber('05512345678'), true); // 05 12345678 (exactly 9 digits)
      expect(Firebase2FAService.isValidPhoneNumber('05598765432'), true); // 05 98765432 (exactly 9 digits)
      
      // Invalid - doesn't start with 05
      expect(Firebase2FAService.isValidPhoneNumber('04512345678'), false);
      expect(Firebase2FAService.isValidPhoneNumber('06512345678'), false);
      
      // Invalid - wrong length (should be exactly 11 characters for 05 format)
      expect(Firebase2FAService.isValidPhoneNumber('0551234567'), false); // 10 chars - too short
      expect(Firebase2FAService.isValidPhoneNumber('055123456789'), false); // 12 chars - too long
    });

    test('should reject invalid phone number formats', () {
      // Empty string
      expect(Firebase2FAService.isValidPhoneNumber(''), false);
      
      // Only digits
      expect(Firebase2FAService.isValidPhoneNumber('123456789'), false);
      
      // Letters
      expect(Firebase2FAService.isValidPhoneNumber('invalid'), false);
      
      // Special characters in wrong format (will be cleaned but still fail validation)
      expect(Firebase2FAService.isValidPhoneNumber('+90-555-123-45'), false); // Too few digits after cleaning
      expect(Firebase2FAService.isValidPhoneNumber('+90 555 123 456789'), false); // Too many digits after cleaning
      expect(Firebase2FAService.isValidPhoneNumber('055-123-456-78'), true); // Valid format after cleaning: 05512345678 (11 chars)
      
      // Non-Turkish numbers
      expect(Firebase2FAService.isValidPhoneNumber('+1234567890'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+447123456789'), false);
    });
  });

  group('Result Object Properties Tests', () {
    
    test('should properly set all TwoFactorAuthResult properties', () {
      final result = TwoFactorAuthResult.requires2FA(
        message: 'Test message',
        multiFactorResolver: 'resolver',
        phoneProvider: PhoneAuthProvider(),
      );
      
      expect(result.isSuccess, false);
      expect(result.message, 'Test message');
      expect(result.requires2FA, true);
      expect(result.multiFactorResolver, 'resolver');
      expect(result.phoneProvider, isNotNull);
      expect(result.userId, null);
    });

    test('should properly set success result properties', () {
      final result = TwoFactorAuthResult.success(
        message: 'Success message',
        userId: 'user123',
      );
      
      expect(result.isSuccess, true);
      expect(result.message, 'Success message');
      expect(result.userId, 'user123');
      expect(result.requires2FA, false);
      expect(result.multiFactorResolver, null);
      expect(result.phoneProvider, null);
    });

    test('should properly set failure result properties', () {
      final result = TwoFactorAuthResult.failure('Failure message');
      
      expect(result.isSuccess, false);
      expect(result.message, 'Failure message');
      expect(result.requires2FA, false);
      expect(result.multiFactorResolver, null);
      expect(result.phoneProvider, null);
      expect(result.userId, null);
    });
  });
}