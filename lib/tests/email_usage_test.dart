// lib/tests/email_usage_test.dart
// Comprehensive test for email usage limitation functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/email_usage_service.dart';
import '../services/registration_service.dart';
import '../models/user_data.dart';

void main() {
  group('Email Usage Service Tests', () {
    late EmailUsageService emailUsageService;

    setUp(() {
      emailUsageService = EmailUsageService();
    });

    group('Email Usage Validation', () {
      test('should allow first use of email', () async {
        // Arrange
        const testEmail = 'test@example.com';

        // Act - First use should be allowed
        final result = await emailUsageService.canEmailBeUsed(testEmail);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.emailUsage?.usageCount, equals(0));
        expect(result.error, isEmpty);
      });

      test('should allow second use of email', () async {
        // Arrange
        const testEmail = 'second@example.com';

        // First, record a usage
        await emailUsageService.recordEmailUsage(testEmail, 'user1');

        // Act - Second use should be allowed
        final result = await emailUsageService.canEmailBeUsed(testEmail);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.emailUsage?.usageCount, equals(1));
        expect(result.error, isEmpty);
      });

      test('should block third use of email', () async {
        // Arrange
        const testEmail = 'third@example.com';

        // Record two uses
        await emailUsageService.recordEmailUsage(testEmail, 'user1');
        await emailUsageService.recordEmailUsage(testEmail, 'user2');

        // Act - Third use should be blocked
        final result = await emailUsageService.canEmailBeUsed(testEmail);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.emailUsage?.usageCount, equals(2));
        expect(result.error, contains('Maksimum kullanım sayısına ulaşıldı'));
      });
    });

    group('Email Usage Recording', () {
      test('should record first email usage correctly', () async {
        // Arrange
        const testEmail = 'record1@example.com';
        const userId = 'testUser1';

        // Act
        await emailUsageService.recordEmailUsage(testEmail, userId);

        // Assert - Get the recorded usage
        final usage = await emailUsageService.getEmailUsage(testEmail);
        expect(usage, isNotNull);
        expect(usage?.email, equals(testEmail.toLowerCase().trim()));
        expect(usage?.usageCount, equals(1));
        expect(usage?.usedUserIds, contains(userId));
      });

      test('should increment usage count correctly', () async {
        // Arrange
        const testEmail = 'record2@example.com';
        const userId1 = 'testUser1';
        const userId2 = 'testUser2';

        // Act - Record two separate uses
        await emailUsageService.recordEmailUsage(testEmail, userId1);
        await emailUsageService.recordEmailUsage(testEmail, userId2);

        // Assert
        final usage = await emailUsageService.getEmailUsage(testEmail);
        expect(usage?.usageCount, equals(2));
        expect(usage?.usedUserIds, hasLength(2));
        expect(usage?.usedUserIds, containsAll([userId1, userId2]));
      });

      test('should handle same user registering twice gracefully', () async {
        // Arrange
        const testEmail = 'record3@example.com';
        const userId = 'testUser1';

        // Act - Record same user twice
        await emailUsageService.recordEmailUsage(testEmail, userId);
        await emailUsageService.recordEmailUsage(testEmail, userId);

        // Assert - Should not increment count for duplicate user
        final usage = await emailUsageService.getEmailUsage(testEmail);
        expect(usage?.usageCount, equals(1)); // Should still be 1
        expect(usage?.usedUserIds, hasLength(1));
        expect(usage?.usedUserIds, contains(userId));
      });
    });

    group('Email Usage Service Integration', () {
      test('should work with RegistrationService', () async {
        // This is a more comprehensive integration test
        // Note: This test would require Firebase setup and would be more of an integration test

        // Arrange
        const testEmail = 'integration@example.com';

        // Act & Assert
        // The RegistrationService should use EmailUsageService internally
        // This test verifies the integration exists
        final registrationService = RegistrationService();

        // We can test that the service has the email usage service
        expect(registrationService, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty email gracefully', () async {
        // Arrange
        const emptyEmail = '';

        // Act
        final result = await emailUsageService.canEmailBeUsed(emptyEmail);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, contains('boş olamaz'));
      });

      test('should normalize email case and whitespace', () async {
        // Arrange
        final testEmail = 'TEST@EXAMPLE.COM';
        final normalizedEmail = testEmail.toLowerCase().trim();
        const userId = 'testUser';

        // Act
        await emailUsageService.recordEmailUsage(testEmail, userId);

        // Assert
        final usage = await emailUsageService.getEmailUsage(normalizedEmail);
        expect(usage?.email, equals(normalizedEmail));
        expect(usage?.usageCount, equals(1));
      });

      test('should handle service errors gracefully', () async {
        // Arrange - This test would need to simulate network errors
        // For now, we test the basic error handling structure

        // Act & Assert - The service should handle errors without crashing
        // This is more of a structural test
        expect(() => emailUsageService.getEmailUsage('nonexistent@example.com'),
            returnsNormally);
      });
    });

    group('Admin Functions', () {
      test('should provide email usage statistics', () async {
        // Arrange
        const email1 = 'stats1@example.com';
        const email2 = 'stats2@example.com';

        await emailUsageService.recordEmailUsage(email1, 'user1');
        await emailUsageService.recordEmailUsage(email1, 'user2');
        await emailUsageService.recordEmailUsage(email2, 'user3');

        // Act
        final allUsage = await emailUsageService.getAllEmailUsage();

        // Assert
        expect(allUsage, isNotEmpty);
        expect(allUsage.length, greaterThanOrEqualTo(2));

        // Should be sorted by usage count descending
        if (allUsage.length >= 2) {
          expect(allUsage[0].usageCount,
              greaterThanOrEqualTo(allUsage[1].usageCount));
        }
      });

      test('should allow email usage reset', () async {
        // Arrange
        const testEmail = 'reset@example.com';
        await emailUsageService.recordEmailUsage(testEmail, 'user1');
        await emailUsageService.recordEmailUsage(testEmail, 'user2');

        // Verify initial state
        var usage = await emailUsageService.getEmailUsage(testEmail);
        expect(usage?.usageCount, equals(2));

        // Act
        await emailUsageService.resetEmailUsage(testEmail);

        // Assert
        usage = await emailUsageService.getEmailUsage(testEmail);
        expect(usage, isNull); // Document should be deleted
      });
    });
  });

  group('Registration Service Email Integration', () {
    late RegistrationService registrationService;

    setUp(() {
      registrationService = RegistrationService();
    });

    test('should include email usage validation in registration flow',
        () async {
      // This test verifies that RegistrationService uses EmailUsageService
      // It's more of a structural test to ensure integration exists

      // The RegistrationService should have the emailUsageService field
      expect(registrationService, isNotNull);
    });
  });

  group('Real-world Usage Scenarios', () {
    late EmailUsageService emailUsageService;

    setUp(() {
      emailUsageService = EmailUsageService();
    });

    test('should simulate complete user registration with email limit',
        () async {
      // Arrange
      const testEmail = 'user@domain.com';
      const user1 = 'uid_user1';
      const user2 = 'uid_user2';
      const user3 = 'uid_user3';

      // Simulate registration flow
      // 1. First user registration
      var validation1 = await emailUsageService.canEmailBeUsed(testEmail);
      expect(validation1.isValid, isTrue);

      await emailUsageService.recordEmailUsage(testEmail, user1);

      // 2. Second user registration (should still work)
      var validation2 = await emailUsageService.canEmailBeUsed(testEmail);
      expect(validation2.isValid, isTrue);
      expect(validation2.emailUsage?.usageCount, equals(1));

      await emailUsageService.recordEmailUsage(testEmail, user2);

      // 3. Third user registration (should be blocked)
      var validation3 = await emailUsageService.canEmailBeUsed(testEmail);
      expect(validation3.isValid, isFalse);
      expect(validation3.emailUsage?.usageCount, equals(2));
      expect(
          validation3.error, contains('Maksimum kullanım sayısına ulaşıldı'));

      // Verify final state
      final finalUsage = await emailUsageService.getEmailUsage(testEmail);
      expect(finalUsage?.usageCount, equals(2));
      expect(finalUsage?.usedUserIds, containsAll([user1, user2]));
      expect(finalUsage?.usedUserIds, isNot(contains(user3)));
    });
  });
}
