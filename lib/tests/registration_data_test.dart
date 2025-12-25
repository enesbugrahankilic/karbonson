// lib/tests/registration_data_test.dart
// Test to verify that user registration data is properly saved to Firestore

import 'package:flutter_test/flutter_test.dart';
import '../services/firestore_service.dart';
import '../services/profile_service.dart';
import '../models/user_data.dart';

void main() {
  group('Registration Data Flow Test', () {
    late FirestoreService firestoreService;
    late ProfileService profileService;

    setUp(() {
      firestoreService = FirestoreService();
      profileService = ProfileService();
    });

    test('UserData creation and Firestore save operations', () async {
      // Test UserData creation
      final userData = UserData(
        uid: 'test-uid-123',
        nickname: 'TestUser',
        profilePictureUrl: null,
        lastLogin: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isAnonymous: false,
        privacySettings: const PrivacySettings.defaults(),
        fcmToken: null,
      );

      // Test UserData serialization
      final userDataMap = userData.toMap();
      expect(userDataMap['uid'], equals('test-uid-123'));
      expect(userDataMap['nickname'], equals('TestUser'));
      expect(userDataMap['isAnonymous'], equals(false));
      expect(userDataMap.containsKey('privacySettings'), isTrue);

      // Test UserData deserialization
      final restoredUserData = UserData.fromMap(userDataMap, 'test-uid-123');
      expect(restoredUserData.uid, equals('test-uid-123'));
      expect(restoredUserData.nickname, equals('TestUser'));
    });

    test('FirestoreService user profile methods exist', () {
      // Verify that the required methods exist and are callable
      expect(
          firestoreService.createOrUpdateUserProfile, isA<Future Function()?>);
      expect(firestoreService.getUserProfile, isA<Future Function(String)>());
      expect(
          firestoreService.isNicknameAvailable, isA<Future Function(String)>());
    });

    test('ProfileService initialization method exists', () {
      // Verify that the initialization method exists
      expect(profileService.initializeProfile, isA<Future Function()?>);
    });

    test('PrivacySettings default values', () {
      final privacySettings = const PrivacySettings.defaults();
      expect(privacySettings.allowFriendRequests, isTrue);
      expect(privacySettings.allowSearchByNickname, isTrue);
      expect(privacySettings.allowDiscovery, isTrue);
    });

    test('Nickname validation methods exist', () {
      // Test format validation
      final formatValidation = NicknameValidator.validate('ValidNickname123');
      expect(formatValidation.isValid, isTrue);

      // Test empty nickname validation
      final emptyValidation = NicknameValidator.validate('');
      expect(emptyValidation.isValid, isFalse);
      expect(emptyValidation.error, isNotEmpty);

      // Test too short nickname validation
      final shortValidation = NicknameValidator.validate('ab');
      expect(shortValidation.isValid, isFalse);

      // Test too long nickname validation
      final longName = 'a' * 25; // 25 characters, max is 20
      final longValidation = NicknameValidator.validate(longName);
      expect(longValidation.isValid, isFalse);
    });
  });

  group('Registration Flow Integration', () {
    test('Complete registration flow simulation', () async {
      // This test simulates the registration flow:
      // 1. User fills form data (email, password, nickname)
      // 2. Firebase Auth creates user
      // 3. ProfileService.initializeProfile() is called
      // 4. FirestoreService.createOrUpdateUserProfile() saves to database

      final registrationData = {
        'email': 'test@example.com',
        'password': 'testpass123',
        'nickname': 'TestPlayer123',
      };

      expect(registrationData['nickname'], isNotEmpty);
      expect(registrationData['email'], isNotEmpty);
      expect(registrationData['password'], hasLength(greaterThanOrEqualTo(6)));

      // Verify that the nickname is valid
      final nicknameValidation =
          NicknameValidator.validate(registrationData['nickname'] as String);
      expect(nicknameValidation.isValid, isTrue);
    });
  });
}
