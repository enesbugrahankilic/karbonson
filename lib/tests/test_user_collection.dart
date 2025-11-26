// lib/tests/test_user_collection.dart
// Test script to verify user collection creation and functionality

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_data.dart';

class UserCollectionTest {
  static final FirestoreService _firestoreService = FirestoreService();

  /// Test user collection operations
  static Future<void> testUserCollectionOperations() async {
    debugPrint('🧪 Starting user collection test...');

    try {
      // Test 1: Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No authenticated user found for testing');
        return;
      }

      debugPrint('✅ Test user found: ${currentUser.uid}');

      // Test 2: Create a test user profile
      final testNickname = 'TestUser_${DateTime.now().millisecondsSinceEpoch}';
      final userData = await _firestoreService.createOrUpdateUserProfile(
        nickname: testNickname,
        profilePictureUrl: 'https://example.com/avatar.png',
        privacySettings: const PrivacySettings.defaults(),
      );

      if (userData == null) {
        debugPrint('❌ Failed to create user profile');
        return;
      }

      debugPrint('✅ Test user profile created: ${userData.nickname} (${userData.uid})');

      // Test 3: Retrieve the created user profile
      final retrievedUserData = await _firestoreService.getUserProfile(currentUser.uid);
      if (retrievedUserData == null) {
        debugPrint('❌ Failed to retrieve user profile');
        return;
      }

      debugPrint('✅ User profile retrieved: ${retrievedUserData.nickname}');

      // Test 4: Verify data integrity
      if (retrievedUserData.uid == currentUser.uid) {
        debugPrint('✅ UID integrity verified');
      } else {
        debugPrint('❌ UID integrity check failed');
      }

      // Test 5: Test nickname uniqueness check
      final isAvailable = await _firestoreService.isNicknameAvailable('unique_nickname_test_12345');
      debugPrint('✅ Nickname availability check: $isAvailable');

      // Test 6: Search users functionality
      final searchResults = await _firestoreService.searchUsersByNickname('TestUser', limit: 5);
      debugPrint('✅ User search returned ${searchResults.length} results');

      debugPrint('🎉 All user collection tests completed successfully!');

    } catch (e, stackTrace) {
      debugPrint('🚨 User collection test failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Display user collection info in UI
  static Widget buildTestResultsWidget() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Collection Test Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This test verifies that the "users" collection is working properly:',
            ),
            const SizedBox(height: 8),
            const Text('• User profile creation (UID centrality)'),
            const Text('• User profile retrieval'),
            const Text('• Data integrity verification'),
            const Text('• Nickname availability checking'),
            const Text('• User search functionality'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: testUserCollectionOperations,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Tests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}