// test/registration_refactored_test.dart
// Unit tests for the refactored registration system

import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/nickname_service.dart';
import 'package:karbonson/widgets/form_field_validator.dart' as form_validator;
import 'package:karbonson/services/registration_service.dart';
import 'package:karbonson/services/error_feedback_service.dart';

void main() {
  group('NicknameService Tests', () {
    test('should return a random nickname suggestion', () {
      final suggestion = NicknameService.getRandomSuggestion();
      
      expect(suggestion, isNotNull);
      expect(suggestion, isA<String>());
      expect(suggestion.length, greaterThan(0));
    });

    test('should return multiple unique nickname suggestions', () {
      final suggestions = NicknameService.getMultipleSuggestions(count: 5);
      
      expect(suggestions.length, equals(5));
      expect(suggestions.toSet().length, equals(5)); // All should be unique
      expect(suggestions.every((name) => name.isNotEmpty), isTrue);
    });

    test('should filter suggestions by starting letter', () {
      final aSuggestions = NicknameService.getSuggestionsByLetter('A');
      final bSuggestions = NicknameService.getSuggestionsByLetter('B');
      
      expect(aSuggestions, isNotEmpty);
      expect(bSuggestions, isNotEmpty);
      expect(aSuggestions.every((name) => name.startsWith('A')), isTrue);
      expect(bSuggestions.every((name) => name.startsWith('B')), isTrue);
    });

    test('should return all available names', () {
      final allNames = NicknameService.getAllAvailableNames();
      
      expect(allNames, isNotEmpty);
      expect(allNames.length, greaterThan(100)); // Should have many names
    });

    test('should check if nickname is in suggestion list', () {
      final isInList = NicknameService.isInSuggestionList('AtıkAzaltıcı');
      final isNotInList = NicknameService.isInSuggestionList('NonExistentName');
      
      expect(isInList, isTrue);
      expect(isNotInList, isFalse);
    });
  });

  group('FormFieldValidator Tests', () {
    test('should validate correct email addresses', () {
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
      ];

      for (final email in validEmails) {
        final result = form_validator.FormFieldValidator.validateEmail(email);
        expect(result, isNull, reason: 'Email $email should be valid');
      }
    });

    test('should reject invalid email addresses', () {
      final invalidEmails = [
        '',
        'invalid-email',
        '@example.com',
        'user@',
        'user@.com',
      ];

      for (final email in invalidEmails) {
        final result = form_validator.FormFieldValidator.validateEmail(email);
        expect(result, isNotNull, reason: 'Email $email should be invalid');
      }
    });

    test('should validate correct passwords', () {
      final validPasswords = [
        'password123',
        'strongpass',
        'abc123456',
      ];

      for (final password in validPasswords) {
        final result = form_validator.FormFieldValidator.validatePassword(password);
        expect(result, isNull, reason: 'Password should be valid');
      }
    });

    test('should reject weak passwords', () {
      final weakPasswords = [
        '',
        '12345',
        'pass',
        'abc12', // Less than 6 characters
      ];

      for (final password in weakPasswords) {
        final result = form_validator.FormFieldValidator.validatePassword(password);
        expect(result, isNotNull, reason: 'Password should be invalid');
      }
    });

    test('should validate password confirmation', () {
      const password = 'password123';
      
      // Correct confirmation
      final correctResult = form_validator.FormFieldValidator.validatePasswordConfirmation(
        'password123', password,
      );
      expect(correctResult, isNull);

      // Incorrect confirmation
      final incorrectResult = form_validator.FormFieldValidator.validatePasswordConfirmation(
        'different', password,
      );
      expect(incorrectResult, isNotNull);
    });

    test('should validate nicknames', () {
      final validNicknames = [
        'AtıkAzaltıcı',
        'user123',
        'Test_User',
        'EcoWarrior',
      ];

      for (final nickname in validNicknames) {
        final result = form_validator.FormFieldValidator.validateNickname(nickname);
        expect(result, isNull, reason: 'Nickname $nickname should be valid');
      }
    });

    test('should reject invalid nicknames', () {
      final invalidNicknames = [
        '', // Empty
        'ab', // Too short
        'a' * 21, // Too long (21 characters)
        'user@email', // Contains special characters
        'user name', // Contains space
      ];

      for (final nickname in invalidNicknames) {
        final result = form_validator.FormFieldValidator.validateNickname(nickname);
        expect(result, isNotNull, reason: 'Nickname should be invalid');
      }
    });
  });

  group('RegistrationService Tests', () {
    late RegistrationService registrationService;

    setUp(() {
      registrationService = RegistrationService();
    });

    test('should generate random nickname suggestions', () {
      final suggestion = registrationService.getRandomNicknameSuggestion();
      
      expect(suggestion, isNotNull);
      expect(suggestion, isA<String>());
      expect(suggestion.length, greaterThan(0));
    });

    test('should return multiple nickname suggestions', () {
      final suggestions = registrationService.getMultipleNicknameSuggestions(count: 3);
      
      expect(suggestions.length, equals(3));
      expect(suggestions.every((name) => name.isNotEmpty), isTrue);
    });

    test('should validate input parameters', () {
      // Test with valid inputs
      expect(
        () => registrationService.registerUser(
          email: 'test@example.com',
          password: 'password123',
          nickname: 'ValidNickname',
        ),
        returnsNormally,
      );
    });
  });

  group('ErrorFeedbackService Tests', () {
    // Note: ErrorFeedbackService methods are mostly UI-focused
    // and would require widget testing for full validation
    // Here we test the development error info generation
    
    test('should generate development error info', () {
      const testError = 'Test error message';
      const testStackTrace = StackTrace.empty;
      
      final errorInfo = ErrorFeedbackService.getDevelopmentErrorInfo(
        testError, 
        testStackTrace,
      );
      
      expect(errorInfo, isNotNull);
      expect(errorInfo, isA<String>());
    });
  });

  group('Integration Tests', () {
    test('should validate complete registration workflow', () {
      // This would be a more complex test in a real scenario
      // For now, we test that the components work together
      
      // 1. Generate nickname
      final nickname = NicknameService.getRandomSuggestion();
      expect(nickname, isNotNull);

      // 2. Validate nickname
      final nicknameValidation = form_validator.FormFieldValidator.validateNickname(nickname);
      // May be null or contain validation message

      // 3. Test email validation
      final emailValidation = form_validator.FormFieldValidator.validateEmail('test@example.com');
      expect(emailValidation, isNull);

      // 4. Test password validation
      final passwordValidation = form_validator.FormFieldValidator.validatePassword('password123');
      expect(passwordValidation, isNull);
    });
  });
}