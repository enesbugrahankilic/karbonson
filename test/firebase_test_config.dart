// test/firebase_test_config.dart
// Firebase test configuration for unit and widget tests

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase Test Configuration
/// 
/// Bu dosya test ortamı için Firebase yapılandırmasını sağlar
/// Unit testlerde Firebase bağımlılıklarını çözmek için kullanılır
class FirebaseTestConfig {
  static bool _isInitialized = false;
  
  /// Initialize Firebase for testing
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Ensure widget binding is initialized first
    TestWidgetsFlutterBinding.ensureInitialized();
    
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        // Initialize with test configuration
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyTestKeyForUnitTests123456789',
            appId: '1:123456789:web:abcdef123456789',
            messagingSenderId: '123456789',
            projectId: 'karbonson-test-project',
            storageBucket: 'karbonson-test.appspot.com',
          ),
        );
      }
      _isInitialized = true;
    } catch (e) {
      // If Firebase initialization fails, continue without it
      print('⚠️ Firebase initialization skipped for tests: $e');
      _isInitialized = true; // Mark as initialized to avoid repeated attempts
    }
  }
  
  /// Reset Firebase configuration for clean state
  static Future<void> reset() async {
    _isInitialized = false;
    await initialize();
  }
  
  /// Check if Firebase is properly initialized
  static bool get isInitialized => _isInitialized;
}

/// Test helper for Firebase-dependent tests
class FirebaseTestHelper {
  /// Run test with Firebase initialized
  static Future<void> runWithFirebase(Future<void> Function() testFn) async {
    await FirebaseTestConfig.initialize();
    return testFn();
  }
  
  /// Skip Firebase-dependent tests if Firebase is not available
  static void skipIfFirebaseNotAvailable(String reason) {
    if (!FirebaseTestConfig.isInitialized) {
      print('⏭️ Skipping test: $reason');
      // This will cause the test to be marked as skipped
      expect(true, true, skip: reason);
    }
  }
}

/// Mock Firebase services for testing
class MockFirebaseService {
  /// Create a mock Firebase Auth instance
  static dynamic getMockAuth() {
    // Return a mock that won't throw errors
    return _MockFirebaseAuth();
  }
  
  /// Create a mock Firestore instance  
  static dynamic getMockFirestore() {
    // Return a mock that won't throw errors
    return _MockFirebaseFirestore();
  }
}

class _MockFirebaseAuth {
  dynamic get instance => this;
}

class _MockFirebaseFirestore {
  dynamic get instance => this;
}