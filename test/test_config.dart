// test/test_config.dart
// Test configuration for Firebase and Flutter testing setup

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

/// Test Configuration for KarbonSon Application
/// 
/// Bu dosya test ortamı için gerekli yapılandırmaları sağlar:
/// - Firebase test configuration
/// - Widget testing setup
/// - Mock services
class TestConfig {
  /// Initialize Firebase for testing
  static Future<void> initializeFirebase() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    
    try {
      // Initialize Firebase with test configuration
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key-for-unit-tests',
          appId: '1:test-app-id:for-unit-tests',
          messagingSenderId: '123456789',
          projectId: 'karbonson-test-project',
          storageBucket: 'karbonson-test.appspot.com',
        ),
      );
    } catch (e) {
      // If initialization fails, continue without Firebase
      print('Firebase initialization skipped for tests: $e');
    }
  }
  
  /// Initialize widget testing environment
  static Future<void> initializeWidgetTesting() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  }
  
  /// Initialize complete test environment
  static Future<void> initialize() async {
    await initializeWidgetTesting();
    await initializeFirebase();
  }
  
  /// Mock Firebase Auth for testing
  static void setupFirebaseAuthMocks() {
    // This would contain mock implementations for Firebase Auth
    // Currently stubbed for future implementation
  }
  
  /// Mock Firestore for testing
  static void setupFirestoreMocks() {
    // This would contain mock implementations for Firestore
    // Currently stubbed for future implementation
  }
}

/// Test helper functions for common test operations
class TestHelpers {
  /// Wait for async operations in tests
  static Future<void> waitFor(Future<void> Function() action) async {
    await action();
  }
  
  /// Pump widget with timeout
  static Future<void> pumpWithTimeout(
    WidgetTester tester, 
    Duration timeout,
  ) async {
    await tester.pumpAndSettle(timeout);
  }
  
  /// Create mock user data for testing
  static Map<String, dynamic> createMockUserData({
    String? uid,
    String? nickname,
  }) {
    return {
      'uid': uid ?? 'test_uid_${DateTime.now().millisecondsSinceEpoch}',
      'nickname': nickname ?? 'TestUser',
      'createdAt': DateTime.now(),
    };
  }
  
  /// Create mock friend request data
  static Map<String, dynamic> createMockFriendRequest({
    String? fromUserId,
    String? toUserId,
  }) {
    return {
      'fromUserId': fromUserId ?? 'test_from_user',
      'toUserId': toUserId ?? 'test_to_user',
      'status': 'pending',
      'createdAt': DateTime.now(),
    };
  }
}

/// Extension for easier test writing
extension TestExtensions on WidgetTester {
  /// Pump with custom timeout
  Future<void> pumpWithTimeout(Duration timeout) async {
    await pumpAndSettle(timeout);
  }
  
  /// Wait for a specific widget to appear
  Future<void> waitForWidget(Finder finder, {Duration? timeout}) async {
    final duration = timeout ?? const Duration(seconds: 5);
    // Use default pumpAndSettle instead of custom waitFor
    await pumpAndSettle(duration);
  }
}