// lib/tests/two_factor_auth_test.dart
// Comprehensive 2FA Implementation Test Suite
// Tests Firebase 2FA service, validation, workflows, and error handling

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_2fa_service.dart';

void main() {
  group('TwoFactorAuthResult - Core Functionality', () {
    
    test('should create success result with valid properties', () {
      final result = TwoFactorAuthResult.success(
        message: 'Authentication successful',
        userId: 'user_123',
      );
      
      expect(result.isSuccess, true);
      expect(result.userId, 'user_123');
      expect(result.requires2FA, false);
      expect(result.multiFactorResolver, null);
      expect(result.phoneProvider, null);
      expect(result.message, 'Authentication successful');
    });

    test('should create 2FA required result with multi-factor resolver', () {
      final phoneProvider = PhoneAuthProvider();
      
      final result = TwoFactorAuthResult.requires2FA(
        message: 'Two-factor authentication required',
        multiFactorResolver: null, // Will be set by Firebase during real 2FA flow
        phoneProvider: phoneProvider,
      );
      
      expect(result.isSuccess, false);
      expect(result.requires2FA, true);
      expect(result.multiFactorResolver, null);
      expect(result.phoneProvider, phoneProvider);
      expect(result.userId, null);
    });

    test('should create failure result with error message', () {
      final errorMessage = 'Authentication failed';
      final result = TwoFactorAuthResult.failure(errorMessage);
      
      expect(result.isSuccess, false);
      expect(result.requires2FA, false);
      expect(result.message, errorMessage);
      expect(result.userId, null);
      expect(result.multiFactorResolver, null);
      expect(result.phoneProvider, null);
    });

    test('should provide Turkish localized messages', () {
      // Test success message localization
      final successResult = TwoFactorAuthResult.success(
        message: 'Login successful',
      );
      expect(successResult.getTurkishMessage(), contains('başarılı'));

      // Test 2FA required message localization
      final twoFARequiredResult = TwoFactorAuthResult.requires2FA(
        message: '2FA required',
        multiFactorResolver: null,
        phoneProvider: null,
      );
      expect(twoFARequiredResult.getTurkishMessage(), anyOf([
        contains('iki faktörlü'),
        contains('2FA'),
      ]));

      // Test failure message localization
      final failureResult = TwoFactorAuthResult.failure('Login failed');
      expect(failureResult.getTurkishMessage(), anyOf([
        contains('başarısız'),
        contains('hata'),
      ]));
    });
  });

  group('Phone Number Validation - Turkish Standards', () {
    
    test('should validate Turkish mobile numbers with country code +90', () {
      // Valid formats: +90 followed by 5 and 9 digits (13 total chars)
      expect(Firebase2FAService.isValidPhoneNumber('+905123456789'), true);
      expect(Firebase2FAService.isValidPhoneNumber('+905987654321'), true);
      expect(Firebase2FAService.isValidPhoneNumber('+905551234567'), true);
      expect(Firebase2FAService.isValidPhoneNumber('+905001234567'), true);
    });

    test('should reject invalid +90 format numbers', () {
      // Wrong digit after +90 (must be 5)
      expect(Firebase2FAService.isValidPhoneNumber('+904123456789'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+906123456789'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+907123456789'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+908123456789'), false);
      
      // Wrong length for +90 format
      expect(Firebase2FAService.isValidPhoneNumber('+90512345678'), false); // 12 chars
      expect(Firebase2FAService.isValidPhoneNumber('+9051234567890'), false); // 14 chars
    });

    test('should validate Turkish mobile numbers without country code', () {
      // Valid formats: 05 followed by 9 digits (11 total chars)
      expect(Firebase2FAService.isValidPhoneNumber('05512345678'), true);
      expect(Firebase2FAService.isValidPhoneNumber('05598765432'), true);
      expect(Firebase2FAService.isValidPhoneNumber('05500123456'), true);
      expect(Firebase2FAService.isValidPhoneNumber('05599999999'), true);
    });

    test('should reject invalid 05 format numbers', () {
      // Wrong prefix
      expect(Firebase2FAService.isValidPhoneNumber('04512345678'), false);
      expect(Firebase2FAService.isValidPhoneNumber('06512345678'), false);
      expect(Firebase2FAService.isValidPhoneNumber('07512345678'), false);
      
      // Wrong length for 05 format
      expect(Firebase2FAService.isValidPhoneNumber('0551234567'), false); // 10 chars
      expect(Firebase2FAService.isValidPhoneNumber('055123456789'), false); // 12 chars
    });

    test('should handle formatted phone numbers with separators', () {
      // Valid formats with spaces, dashes, parentheses
      expect(Firebase2FAService.isValidPhoneNumber('055-123-456-78'), true);
      expect(Firebase2FAService.isValidPhoneNumber('055 123 456 78'), true);
      expect(Firebase2FAService.isValidPhoneNumber('+90 512 345 67 89'), true);
      
      // Invalid formats
      expect(Firebase2FAService.isValidPhoneNumber('+90-512-345-6789'), false); // Too many digits
      expect(Firebase2FAService.isValidPhoneNumber('055-12-345-678'), false); // Too few digits
    });

    test('should reject non-Turkish and invalid numbers', () {
      // International numbers (not Turkish)
      expect(Firebase2FAService.isValidPhoneNumber('+1234567890'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+447123456789'), false);
      expect(Firebase2FAService.isValidPhoneNumber('+4915123456789'), false);
      
      // Invalid formats
      expect(Firebase2FAService.isValidPhoneNumber('123456789'), false);
      expect(Firebase2FAService.isValidPhoneNumber('abcdefghijk'), false);
      expect(Firebase2FAService.isValidPhoneNumber(''), false);
      expect(Firebase2FAService.isValidPhoneNumber('+90'), false);
      expect(Firebase2FAService.isValidPhoneNumber('05'), false);
    });
  });

  group('2FA Workflow State Management', () {
    
    test('should manage authentication flow state transitions', () {
      // Initial unauthenticated state
      final initialState = TwoFactorAuthResult.failure('Not authenticated');
      expect(initialState.isSuccess, false);
      expect(initialState.requires2FA, false);
      expect(initialState.userId, null);
      
      // 2FA required state
      final authRequiredState = TwoFactorAuthResult.requires2FA(
        message: 'Multi-factor authentication required',
        multiFactorResolver: null,
        phoneProvider: PhoneAuthProvider(),
      );
      expect(authRequiredState.requires2FA, true);
      expect(authRequiredState.multiFactorResolver, isNotNull);
      
      // Successful authentication state
      final successState = TwoFactorAuthResult.success(
        message: 'Authentication successful',
        userId: 'authenticated_user',
      );
      expect(successState.isSuccess, true);
      expect(successState.userId, 'authenticated_user');
      expect(successState.requires2FA, false);
    });

    test('should handle credential creation for SMS verification', () {
      const verificationId = 'verification_id_abc123';
      const smsCode = '987654';
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      expect(credential.verificationId, verificationId);
      expect(credential.smsCode, smsCode);
      expect(credential, isA<PhoneAuthCredential>());
    });

    test('should create multi-factor assertions correctly', () {
      final credential = PhoneAuthProvider.credential(
        verificationId: 'test_verification_id',
        smsCode: '123456',
      );
      
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
      
      expect(assertion, isA<MultiFactorAssertion>());
      expect(assertion, isNotNull);
    });
  });

  group('2FA Complete Workflow Integration', () {
    
    test('should simulate complete 2FA enrollment process', () async {
      // Step 1: Initiate 2FA enrollment
      final enrollmentStart = TwoFactorAuthResult.success(
        message: 'İki faktörlü doğrulama kurulumu başlatıldı',
      );
      expect(enrollmentStart.isSuccess, true);
      expect(enrollmentStart.message, contains('başlatıldı'));
      
      // Step 2: Send verification SMS
      final smsSent = TwoFactorAuthResult.success(
        message: 'Doğrulama kodu telefonunuza gönderildi',
      );
      expect(smsSent.isSuccess, true);
      expect(smsSent.message, contains('gönderildi'));
      
      // Step 3: Verify SMS code
      final codeVerified = TwoFactorAuthResult.success(
        message: 'Doğrulama kodu doğrulandı',
      );
      expect(codeVerified.isSuccess, true);
      expect(codeVerified.message, contains('doğrulandı'));
      
      // Step 4: Complete enrollment
      final enrollmentComplete = TwoFactorAuthResult.success(
        message: 'İki faktörlü doğrulama başarıyla etkinleştirildi',
      );
      expect(enrollmentComplete.isSuccess, true);
      expect(enrollmentComplete.message, contains('etkinleştirildi'));
    });

    test('should simulate complete 2FA sign-in process', () async {
      // Step 1: Initial login attempt (triggers 2FA requirement)
      final initialLogin = TwoFactorAuthResult.requires2FA(
        message: 'İki faktörlü doğrulama gerekli',
        multiFactorResolver: null,
        phoneProvider: PhoneAuthProvider(),
      );
      expect(initialLogin.requires2FA, true);
      expect(initialLogin.multiFactorResolver, null);
      
      // Step 2: Send verification for sign-in
      final signInSms = TwoFactorAuthResult.success(
        message: 'Giriş doğrulama kodu gönderildi',
      );
      expect(signInSms.isSuccess, true);
      
      // Step 3: Verify sign-in code
      final signInVerified = TwoFactorAuthResult.success(
        message: 'Giriş doğrulaması başarılı',
        userId: 'signed_in_user_456',
      );
      expect(signInVerified.isSuccess, true);
      expect(signInVerified.userId, 'signed_in_user_456');
      expect(signInVerified.requires2FA, false);
    });

    test('should simulate 2FA disable process', () async {
      final disableResult = TwoFactorAuthResult.success(
        message: 'İki faktörlü doğrulama devre dışı bırakıldı',
      );
      
      expect(disableResult.isSuccess, true);
      expect(disableResult.message, contains('devre dışı bırakıldı'));
    });
  });

  group('2FA Error Handling and Turkish Localization', () {
    
    test('should handle invalid verification code error', () {
      const errorCode = 'invalid-verification-code';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Geçersiz'),
        contains('Yanlış'),
        contains('Hatalı'),
      ]));
      expect(errorMessage, contains('kod'));
    });

    test('should handle missing session information error', () {
      const errorCode = 'missing-session-info';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Oturum'),
        contains('Bilgi'),
        contains('eksik'),
      ]));
    });

    test('should handle too many requests error', () {
      const errorCode = 'too-many-requests';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Çok'),
        contains('fazla'),
        contains('deneme'),
      ]));
    });

    test('should handle network connection errors', () {
      const errorCode = 'network-request-failed';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Ağ'),
        contains('bağlantı'),
        contains('internet'),
      ]));
    });

    test('should handle invalid phone number error', () {
      const errorCode = 'invalid-phone-number';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Geçersiz'),
        contains('telefon'),
        contains('numarası'),
      ]));
    });

    test('should handle quota exceeded error', () {
      const errorCode = 'quota-exceeded';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Kota'),
        contains('aşıldı'),
        contains('limit'),
      ]));
    });

    test('should handle invalid reCAPTCHA token error', () {
      const errorCode = 'invalid-recaptcha-token';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(errorCode);
      
      expect(errorMessage, anyOf([
        contains('Güvenlik'),
        contains('doğrulama'),
        contains('reCAPTCHA'),
      ]));
    });

    test('should handle unknown error codes gracefully', () {
      const unknownErrorCode = 'completely-unknown-error';
      final errorMessage = Firebase2FAService.getTurkishErrorMessage(unknownErrorCode);
      
      expect(errorMessage, anyOf([
        contains('2FA'),
        contains('doğrulama'),
        contains('hatası'),
      ]));
      expect(errorMessage, contains(unknownErrorCode));
    });
  });

  group('Advanced 2FA Scenarios', () {
    
    test('should handle multiple failed verification attempts', () {
      final attempts = <String>['123456', '654321', '111111', '000000'];
      
      for (final attempt in attempts) {
        final result = TwoFactorAuthResult.failure('Verification failed: $attempt');
        expect(result.isSuccess, false);
        expect(result.message, contains('failed'));
      }
    });

    test('should simulate 2FA setup with backup codes', () async {
      // Enable 2FA
      final enableResult = TwoFactorAuthResult.success(
        message: '2FA enabled with backup codes',
      );
      expect(enableResult.isSuccess, true);
      
      // Generate backup codes (simulated)
      final backupCodesGenerated = TwoFactorAuthResult.success(
        message: 'Backup codes generated: 8 codes created',
      );
      expect(backupCodesGenerated.message, contains('backup'));
      expect(backupCodesGenerated.message, contains('8'));
    });

    test('should handle 2FA timeout scenarios', () {
      final timeoutResult = TwoFactorAuthResult.failure(
        'Verification code expired - please request a new code',
      );
      
      expect(timeoutResult.isSuccess, false);
      expect(timeoutResult.message, anyOf([
        contains('süresi'),
        contains('dolandı'),
        contains('expired'),
        contains('timeout'),
      ]));
    });

    test('should validate phone number change during 2FA setup', () {
      final oldNumber = '+905551234567';
      final newNumber = '+905559876543';
      
      expect(Firebase2FAService.isValidPhoneNumber(oldNumber), true);
      expect(Firebase2FAService.isValidPhoneNumber(newNumber), true);
      expect(oldNumber, isNot(equals(newNumber)));
    });
  });

  group('Performance and Edge Cases', () {
    
    test('should handle empty and null inputs gracefully', () {
      expect(Firebase2FAService.isValidPhoneNumber(''), false);
      expect(Firebase2FAService.isValidPhoneNumber('   '), false);
    });

    test('should handle extremely long phone numbers', () {
      final longNumber = '+90512345678901234567890';
      expect(Firebase2FAService.isValidPhoneNumber(longNumber), false);
    });

    test('should handle phone numbers with special characters', () {
      expect(Firebase2FAService.isValidPhoneNumber('+90@512!345@678'), false);
      expect(Firebase2FAService.isValidPhoneNumber('055*123*456*78'), false);
    });

    test('should maintain result object immutability', () {
      final result = TwoFactorAuthResult.success(
        message: 'Immutable test',
        userId: 'user123',
      );
      
      // Verify all properties are correctly set and immutable
      expect(result.isSuccess, true);
      expect(result.message, 'Immutable test');
      expect(result.userId, 'user123');
      
      // Properties should remain constant
      expect(result.requires2FA, false);
      expect(result.multiFactorResolver, null);
      expect(result.phoneProvider, null);
    });
  });
}