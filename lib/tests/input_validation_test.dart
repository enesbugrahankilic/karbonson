import 'package:flutter_test/flutter_test.dart';
import '../services/input_validation_service.dart';

void main() {
  group('InputValidationService Tests', () {
    late InputValidationService validationService;

    setUp(() {
      validationService = InputValidationService();
    });

    group('Email Validation Tests', () {
      test('Should validate correct email addresses', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'firstname.lastname@company.com',
          'user+tag@example.org',
        ];

        for (final email in validEmails) {
          final result = validationService.validateEmail(email);
          expect(result.isValid, true, reason: 'Email "$email" should be valid');
        }
      });

      test('Should reject invalid email addresses', () {
        final invalidEmails = [
          '',
          'invalid',
          '@example.com',
          'test@',
          'test..test@example.com',
          'test @example.com',
          'test@example',
          'test@example..com',
        ];

        for (final email in invalidEmails) {
          final result = validationService.validateEmail(email);
          expect(result.isValid, false, reason: 'Email "$email" should be invalid');
        }
      });
    });

    group('Nickname Validation Tests', () {
      test('Should validate correct nicknames', () {
        final validNicknames = [
          'user123',
          'TestUser',
          'john_doe',
          'çğüşıö',
          'USER_NAME_123',
        ];

        for (final nickname in validNicknames) {
          final result = validationService.validateNickname(nickname);
          expect(result.isValid, true, reason: 'Nickname "$nickname" should be valid');
        }
      });

      test('Should reject invalid nicknames', () {
        final invalidNicknames = [
          '',
          'ab', // Too short
          'a' * 21, // Too long
          'user@name', // Contains special characters
          'user name', // Contains spaces
          'admin', // Reserved name
          'test<script>', // Contains HTML
        ];

        for (final nickname in invalidNicknames) {
          final result = validationService.validateNickname(nickname);
          expect(result.isValid, false, reason: 'Nickname "$nickname" should be invalid');
        }
      });
    });

    group('Password Validation Tests', () {
      test('Should validate strong passwords', () {
        final strongPasswords = [
          'Password123!',
          'MyStr0ng#Pass',
          'C0mpl3x@Pwd',
          'SeCuRe!2024',
        ];

        for (final password in strongPasswords) {
          final result = validationService.validatePassword(password);
          expect(result.isValid, true, reason: 'Password "$password" should be valid');
        }
      });

      test('Should reject weak passwords', () {
        final weakPasswords = [
          '',
          '123456', // Too short, only numbers
          'password', // Only lowercase
          'PASSWORD', // Only uppercase
          '12345678', // Only numbers
          'password1', // Missing uppercase and special char
          'PASSWORD1', // Missing lowercase and special char
          'Password', // Missing numbers and special char
          'Pass1!', // Too short
          'a' * 129, // Too long
        ];

        for (final password in weakPasswords) {
          final result = validationService.validatePassword(password);
          expect(result.isValid, false, reason: 'Password "$password" should be invalid');
        }
      });

      test('Should detect common passwords', () {
        final commonPasswords = [
          '123456',
          'password',
          '123456789',
          'qwerty',
          'admin',
        ];

        for (final password in commonPasswords) {
          final result = validationService.validatePassword(password);
          expect(result.isValid, false, reason: 'Common password "$password" should be rejected');
          expect(result.errorCode, ValidationErrorCode.commonPassword);
        }
      });
    });

    group('Password Confirmation Tests', () {
      test('Should validate matching passwords', () {
        const password = 'Password123!';
        const confirmation = 'Password123!';

        final result = validationService.validatePasswordConfirmation(password, confirmation);
        expect(result.isValid, true);
      });

      test('Should reject non-matching passwords', () {
        const password = 'Password123!';
        const confirmation = 'Different123!';

        final result = validationService.validatePasswordConfirmation(password, confirmation);
        expect(result.isValid, false);
        expect(result.errorCode, ValidationErrorCode.passwordMismatch);
      });
    });

    group('Content Sanitization Tests', () {
      test('Should sanitize HTML tags', () {
        final input = '<script>alert("xss")</script>Hello';
        final sanitized = validationService.sanitizeInput(input);
        
        expect(sanitized.contains('<script>'), false);
        expect(sanitized.contains('Hello'), true);
      });

      test('Should sanitize control characters', () {
        final input = 'Hello\x00World\x01Test';
        final sanitized = validationService.sanitizeInput(input);
        
        expect(sanitized.contains('\x00'), false);
        expect(sanitized.contains('\x01'), false);
        expect(sanitized.contains('Hello'), true);
        expect(sanitized.contains('World'), true);
      });

      test('Should limit input length', () {
        final input = 'a' * 1500;
        final sanitized = validationService.sanitizeInput(input);
        
        expect(sanitized.length, lessThanOrEqualTo(1000));
      });
    });

    group('Security Tests', () {
      test('Should detect SQL injection attempts', () {
        final sqlInputs = [
          "'; DROP TABLE users; --",
          "1' OR '1'='1",
          "UNION SELECT password FROM users",
          "admin'--",
        ];

        for (final input in sqlInputs) {
          final hasSqlInjection = validationService.containsSqlInjection(input);
          expect(hasSqlInjection, true, reason: 'Input "$input" should be detected as SQL injection');
        }
      });

      test('Should generate secure hashes', () {
        const input = 'test password';
        final hash = validationService.generateSecureHash(input);
        
        expect(hash.length, 64); // SHA-256 produces 64 character hex string
        expect(hash, isNot(equals(input)));
        expect(hash, equals(validationService.generateSecureHash(input))); // Should be deterministic
      });
    });

    group('Error Code Tests', () {
      test('Should return correct error codes for email validation', () {
        final emptyResult = validationService.validateEmail('');
        expect(emptyResult.errorCode, ValidationErrorCode.requiredField);

        final invalidResult = validationService.validateEmail('invalid');
        expect(invalidResult.errorCode, ValidationErrorCode.invalidEmail);
      });

      test('Should return correct error codes for password validation', () {
        final shortResult = validationService.validatePassword('123');
        expect(shortResult.errorCode, ValidationErrorCode.tooShort);

        final missingLowercase = validationService.validatePassword('PASSWORD123!');
        expect(missingLowercase.errorCode, ValidationErrorCode.missingLowercase);

        final missingUppercase = validationService.validatePassword('password123!');
        expect(missingUppercase.errorCode, ValidationErrorCode.missingUppercase);

        final missingDigit = validationService.validatePassword('Password!');
        expect(missingDigit.errorCode, ValidationErrorCode.missingDigit);

        final missingSpecialChar = validationService.validatePassword('Password123');
        expect(missingSpecialChar.errorCode, ValidationErrorCode.missingSpecialChar);
      });
    });
  });

  group('String Extension Tests', () {
    test('Should provide validation extensions', () {
      const email = 'test@example.com';
      const invalidEmail = 'invalid';
      
      expect(email.validateEmail().isValid, true);
      expect(invalidEmail.validateEmail().isValid, false);
    });

    test('Should provide sanitization extension', () {
      const dirtyInput = '<script>alert("test")</script>Clean text';
      final sanitized = dirtyInput.sanitize();
      
      expect(sanitized.contains('<script>'), false);
      expect(sanitized.contains('Clean text'), true);
    });
  });
}