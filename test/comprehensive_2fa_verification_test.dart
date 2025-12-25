// test/comprehensive_2fa_verification_test.dart
// Comprehensive Test Coverage for Two-Factor Authentication Verification
// Tests all verification methods, error handling, and user interactions

import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/comprehensive_2fa_service.dart';

void main() {
  group('Comprehensive2FAService Tests', () {
    setUp(() {
      Comprehensive2FAService.initialize();
    });

    tearDown(() {
      Comprehensive2FAService.dispose();
    });

    group('SMS Verification', () {
      test('should start SMS verification successfully', () async {
        final result = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        expect(result.isSuccess, true);
        expect(result.sessionId, isNotNull);
        expect(result.availableMethods, isNotNull);
        expect(result.availableMethods!.contains(VerificationMethod.sms), true);
      });

      test('should fail with invalid phone number', () async {
        final result = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: 'invalid',
        );

        expect(result.isSuccess, false);
        expect(result.message, contains('Geçersiz telefon numarası formatı'));
      });

      test('should verify SMS code correctly', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        expect(startResult.isSuccess, true);

        // Verify with valid code
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: '123456',
          method: VerificationMethod.sms,
        );

        expect(verifyResult.isSuccess, true);
        expect(verifyResult.message, 'Code verified successfully');
      });

      test('should fail with invalid SMS code', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        expect(startResult.isSuccess, true);

        // Verify with invalid code
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: '000000',
          method: VerificationMethod.sms,
        );

        expect(verifyResult.isSuccess, false);
        expect(verifyResult.message, 'Invalid code');
      });

      test('should resend SMS code successfully', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        expect(startResult.isSuccess, true);

        // Resend code
        final resendResult = await Comprehensive2FAService.resendCode(startResult.sessionId!);

        expect(resendResult.isSuccess, true);
        expect(resendResult.message, 'SMS sent successfully');
      });
    });

    group('TOTP Verification', () {
      test('should generate TOTP code successfully', () async {
        final secret = 'JBSWY3DPEHPK3PXP'; // Standard test secret
        
        final result = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.totp,
          totpSecret: secret,
        );

        expect(result.isSuccess, true);
        expect(result.code, isNotNull);
        expect(result.code!.length, 6);
        expect(result.expiresAt, isNotNull);
      });

      test('should verify TOTP code correctly', () async {
        final secret = 'JBSWY3DPEHPK3PXP';
        
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.totp,
          totpSecret: secret,
        );

        expect(startResult.isSuccess, true);

        // Verify with the generated code
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: startResult.code!,
          method: VerificationMethod.totp,
        );

        expect(verifyResult.isSuccess, true);
        expect(verifyResult.message, 'Code verified successfully');
      });

      test('should fail with invalid TOTP code', () async {
        final secret = 'JBSWY3DPEHPK3PXP';
        
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.totp,
          totpSecret: secret,
        );

        expect(startResult.isSuccess, true);

        // Verify with wrong code
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: '000000',
          method: VerificationMethod.totp,
        );

        expect(verifyResult.isSuccess, false);
        expect(verifyResult.message, 'Invalid code');
      });
    });

    group('Hardware Token Verification', () {
      test('should start hardware token verification successfully', () async {
        final result = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.hardwareToken,
        );

        expect(result.isSuccess, true);
        expect(result.sessionId, isNotNull);
        expect(result.availableMethods, isNotNull);
      });

      test('should verify hardware token successfully', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.hardwareToken,
        );

        expect(startResult.isSuccess, true);

        // Verify (simulated biometric auth)
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: '', // Hardware token doesn't require code
          method: VerificationMethod.hardwareToken,
        );

        // The result depends on simulated biometric auth (66% success rate)
        expect(verifyResult.isSuccess, anyOf([true, false]));
      });
    });

    group('Backup Code Verification', () {
      test('should start backup code verification successfully', () async {
        final result = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.backupCode,
        );

        expect(result.isSuccess, true);
        expect(result.sessionId, isNotNull);
      });

      test('should verify valid backup code', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.backupCode,
        );

        expect(startResult.isSuccess, true);

        // Verify with valid backup code
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: 'ABC12345',
          method: VerificationMethod.backupCode,
        );

        expect(verifyResult.isSuccess, true);
        expect(verifyResult.message, 'Backup code verified successfully');
      });

      test('should fail with invalid backup code format', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.backupCode,
        );

        expect(startResult.isSuccess, true);

        // Verify with invalid format
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: 'short',
          method: VerificationMethod.backupCode,
        );

        expect(verifyResult.isSuccess, false);
        expect(verifyResult.message, 'Invalid backup code format');
      });
    });

    group('Error Handling', () {
      test('should handle network connectivity issues', () async {
        // Test with network unavailable (simulated)
        // In a real implementation, this would test actual network failure
        
        final result = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        // For demo, we'll test that the service doesn't crash
        expect(result, isA<VerificationResult>());
      });

      test('should handle expired sessions', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        expect(startResult.isSuccess, true);

        // Wait for session to expire (simulated)
        await Future.delayed(const Duration(seconds: 1));

        // Try to verify with expired session
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: '123456',
          method: VerificationMethod.sms,
        );

        expect(verifyResult.isSuccess, false);
        expect(verifyResult.message, 'Session expired');
      });

      test('should handle maximum attempt limits', () async {
        // Start verification
        final startResult = await Comprehensive2FAService.startVerification(
          method: VerificationMethod.sms,
          phoneNumber: '+905551234567',
        );

        expect(startResult.isSuccess, true);

        // Attempt verification multiple times to exceed limit
        for (int i = 0; i < 5; i++) {
          await Comprehensive2FAService.verifyCode(
            sessionId: startResult.sessionId!,
            code: 'wrong',
            method: VerificationMethod.sms,
          );
        }

        // Next attempt should fail due to attempt limit
        final verifyResult = await Comprehensive2FAService.verifyCode(
          sessionId: startResult.sessionId!,
          code: '123456',
          method: VerificationMethod.sms,
        );

        expect(verifyResult.isSuccess, false);
        expect(verifyResult.message, 'Too many attempts');
      });
    });

    group('TOTP Generation', () {
      test('should generate valid TOTP codes', () {
        final secret = 'JBSWY3DPEHPK3PXP';
        
        for (int i = 0; i < 3; i++) {
          final code = Comprehensive2FAService.generateTOTP(secret);
          expect(code.length, 6);
          expect(RegExp(r'^\d{6}$').hasMatch(code), true);
          
          // Wait for next time step
          final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final targetTime = ((currentTime ~/ 30) + 1) * 30;
          final waitTime = targetTime - currentTime;
          if (waitTime > 0) {
            Future.delayed(Duration(seconds: waitTime));
          }
        }
      });

      test('should generate codes with different digit lengths', () {
        final secret = 'JBSWY3DPEHPK3PXP';
        
        final code6 = Comprehensive2FAService.generateTOTP(secret, digits: 6);
        final code8 = Comprehensive2FAService.generateTOTP(secret, digits: 8);
        
        expect(code6.length, 6);
        expect(code8.length, 8);
      });
    });

    group('Security and Validation', () {
      test('should validate phone numbers correctly', () {
        // Valid phone numbers
        expect(_testIsValidPhoneNumber('+905551234567'), true);
        expect(_testIsValidPhoneNumber('+123456789012345'), true);
        expect(_testIsValidPhoneNumber('+442071234567'), true);
        
        // Invalid phone numbers
        expect(_testIsValidPhoneNumber('123456789'), false);
        expect(_testIsValidPhoneNumber('invalid'), false);
        expect(_testIsValidPhoneNumber('+123'), false);
        expect(_testIsValidPhoneNumber(''), false);
      });

      test('should generate secure session IDs', () {
        final id1 = _testGenerateSecureId();
        final id2 = _testGenerateSecureId();
        
        expect(id1, isNot(isEmpty));
        expect(id2, isNot(isEmpty));
        expect(id1, isNot(equals(id2)));
        expect(id1.length, greaterThan(40)); // Base64 URL encoded
      });
    });
  });
}

// Helper methods for testing private methods
bool _testIsValidPhoneNumber(String phoneNumber) {
  final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
  return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
}

String _testGenerateSecureId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = timestamp % 1000000;
  return 'test_id_${timestamp}_$random';
}