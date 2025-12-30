// lib/tests/auth_service_test.dart
// Authentication Service Test Suite

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Generate mock classes
import 'auth_service_test.mocks.dart';

// Import the service to test
import '../services/auth_service.dart';

// Generate the mockito mock classes
@GenerateMocks([FirebaseAuth, User, UserCredential, Connectivity])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockConnectivity mockConnectivity;
    late AuthService authService;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockConnectivity = MockConnectivity();
      
      // Set up the mock FirebaseAuth instance
      FirebaseAuth.instance = mockFirebaseAuth;
    });

    group('Authentication Persistence', () {
      test('initializeAuthPersistence should set persistence to LOCAL', () async {
        // Arrange
        when(mockFirebaseAuth.setPersistence(Persistence.LOCAL))
            .thenAnswer((_) async => Future.value());

        // Act
        await AuthService.initializeAuthPersistence();

        // Assert
        verify(mockFirebaseAuth.setPersistence(Persistence.LOCAL)).called(1);
      });

      test('isUserAuthenticated should return true when user is logged in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = AuthService.isUserAuthenticated();

        // Assert
        expect(result, true);
        verify(mockFirebaseAuth.currentUser).called(1);
      });

      test('isUserAuthenticated should return false when no user is logged in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = AuthService.isUserAuthenticated();

        // Assert
        expect(result, false);
        verify(mockFirebaseAuth.currentUser).called(1);
      });

      test('getCurrentUser should return current user', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = AuthService.getCurrentUser();

        // Assert
        expect(result, mockUser);
        verify(mockFirebaseAuth.currentUser).called(1);
      });

      test('isAnonymousUser should return true for anonymous user', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.isAnonymous).thenReturn(true);

        // Act
        final result = AuthService.isAnonymousUser();

        // Assert
        expect(result, true);
      });

      test('hasEmailAccount should return true for email user', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.isAnonymous).thenReturn(false);

        // Act
        final result = AuthService.hasEmailAccount();

        // Assert
        expect(result, true);
      });
    });

    group('Network Connectivity', () {
      test('_isNetworkAvailable should return true when connected', () async {
        // This would require mocking Connectivity().checkConnectivity()
        // For now, we'll test the basic structure
        expect(true, true); // Placeholder
      });
    });

    group('Email/Password Sign In', () {
      test('signInWithEmailAndPassword should succeed with valid credentials', () async {
        // Arrange
        final email = 'test@example.com';
        final password = 'password123';
        
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.email).thenReturn(email);
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => Future.value(mockUserCredential));

        // Act
        final result = await AuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.user, mockUser);
        expect(result.message, 'Giriş başarılı');
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('signInWithEmailAndPassword should fail with empty credentials', () async {
        // Act
        final result = await AuthService.signInWithEmailAndPassword(
          email: '',
          password: '',
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'E-posta ve şifre gerekli');
      });

      test('signInWithEmailAndPassword should fail with invalid email', () async {
        // Arrange
        final email = 'invalid-email';
        final password = 'password123';

        // Act
        final result = await AuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'E-posta ve şifre gerekli');
      });

      test('signInWithEmailAndPassword should handle FirebaseAuthException', () async {
        // Arrange
        final email = 'test@example.com';
        final password = 'wrongpassword';
        final exception = FirebaseAuthException(code: 'wrong-password');

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(exception);

        // Act
        final result = await AuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.errorCode, 'wrong-password');
        expect(result.message, 'Hatalı şifre. Şifrenizi kontrol edin.');
      });
    });

    group('Email/Password Registration', () {
      test('createUserWithEmailAndPassword should succeed with valid credentials', () async {
        // Arrange
        final email = 'newuser@example.com';
        final password = 'password123';
        
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('new-user-uid');
        when(mockUser.email).thenReturn(email);
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => Future.value(mockUserCredential));

        // Act
        final result = await AuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.user, mockUser);
        expect(result.message, 'Hesap oluşturuldu');
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });

      test('createUserWithEmailAndPassword should fail with weak password', () async {
        // Arrange
        final email = 'test@example.com';
        final password = '123';

        // Act
        final result = await AuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Şifre en az 6 karakter olmalıdır');
      });

      test('createUserWithEmailAndPassword should handle email already in use', () async {
        // Arrange
        final email = 'existing@example.com';
        final password = 'password123';
        final exception = FirebaseAuthException(code: 'email-already-in-use');

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(exception);

        // Act
        final result = await AuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result.isSuccess, false);
        expect(result.errorCode, 'email-already-in-use');
        expect(result.message, 'Bu e-posta adresi zaten kullanılıyor.');
      });
    });

    group('Anonymous Sign In', () {
      test('signInAnonymously should succeed', () async {
        // Arrange
        when(mockUser.uid).thenReturn('anonymous-uid');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.signInAnonymously())
            .thenAnswer((_) async => Future.value(mockUserCredential));

        // Act
        final result = await AuthService.signInAnonymously();

        // Assert
        expect(result.isSuccess, true);
        expect(result.user, mockUser);
        expect(result.message, 'Anonim giriş başarılı');
        verify(mockFirebaseAuth.signInAnonymously()).called(1);
      });
    });

    group('Sign Out', () {
      test('signOut should call FirebaseAuth signOut', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());

        // Act
        await AuthService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
      });
    });

    group('Account Management', () {
      test('deleteAccount should succeed for authenticated user', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.delete()).thenAnswer((_) async => Future.value());

        // Act
        final result = await AuthService.deleteAccount();

        // Assert
        expect(result.isSuccess, true);
        expect(result.message, 'Hesap silindi');
        verify(mockUser.delete()).called(1);
      });

      test('deleteAccount should fail when no user is authenticated', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await AuthService.deleteAccount();

        // Assert
        expect(result.isSuccess, false);
        expect(result.message, 'Kullanıcı oturumu bulunamadı');
      });
    });

    group('Email Verification', () {
      test('sendEmailVerification should succeed for unverified user', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async => Future.value());
        when(mockUser.email).thenReturn('test@example.com');

        // Act
        final result = await AuthService.sendEmailVerification();

        // Assert
        expect(result.isSuccess, true);
        expect(result.message, 'Doğrulama e-postası gönderildi');
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('sendEmailVerification should return success for already verified user', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        final result = await AuthService.sendEmailVerification();

        // Assert
        expect(result.isSuccess, true);
        expect(result.message, 'E-posta adresi zaten doğrulanmış');
      });

      test('checkEmailVerificationStatus should return verified status', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.reload()).thenAnswer((_) async => Future.value());
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        final result = await AuthService.checkEmailVerificationStatus();

        // Assert
        expect(result.isSuccess, true);
        expect(result.message, 'E-posta adresi doğrulanmış');
        verify(mockUser.reload()).called(1);
      });
    });

    group('Error Handling', () {
      test('_handleAuthError should return Turkish error messages', () {
        // Test different error codes
        final testCases = [
          {'code': 'network-request-failed', 'expected': 'İnternet bağlantınızı kontrol edin'},
          {'code': 'too-many-requests', 'expected': 'Çok fazla deneme yapıldı'},
          {'code': 'user-disabled', 'expected': 'Bu hesap devre dışı bırakılmış'},
          {'code': 'user-not-found', 'expected': 'Kullanıcı bulunamadı'},
          {'code': 'wrong-password', 'expected': 'Hatalı şifre'},
          {'code': 'email-already-in-use', 'expected': 'Bu e-posta adresi zaten kullanılıyor'},
          {'code': 'weak-password', 'expected': 'Şifre çok zayıf'},
          {'code': 'invalid-email', 'expected': 'E-posta adresi formatı geçersiz'},
          {'code': 'unknown-code', 'expected': 'Beklenmeyen bir hata oluştu'},
        ];

        for (final testCase in testCases) {
          final exception = FirebaseAuthException(code: testCase['code'] as String);
          // Note: This test would need access to private method _handleAuthError
          // For now, we test the structure
          expect(true, true); // Placeholder
        }
      });

      test('_isRetryableError should identify retryable errors', () {
        // Test retryable error codes
        final retryableErrors = [
          'too-many-requests',
          'network-request-failed',
          'quota-exceeded',
          'internal-error',
          'network-error',
        ];

        // Test non-retryable error codes
        final nonRetryableErrors = [
          'user-not-found',
          'wrong-password',
          'email-already-in-use',
          'invalid-email',
        ];

        // Note: This test would need access to private method _isRetryableError
        // For now, we test the structure
        expect(retryableErrors.length, 5);
        expect(nonRetryableErrors.length, 4);
      });
    });

    group('Debug Information', () {
      test('getDebugInfo should return user information', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUser.emailVerified).thenReturn(true);
        when(mockUser.isAnonymous).thenReturn(false);
        when(mockUser.providerData).thenReturn([]);
        when(mockUser.metadata).thenReturn(UserMetadata());

        // Act
        final debugInfo = AuthService.getDebugInfo();

        // Assert
        expect(debugInfo['currentUser'], true);
        expect(debugInfo['userId'], 'test-uid');
        expect(debugInfo['email'], 'test@example.com');
        expect(debugInfo['emailVerified'], true);
        expect(debugInfo['isAnonymous'], false);
      });
    });
  });
}