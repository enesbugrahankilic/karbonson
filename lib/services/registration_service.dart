// lib/services/registration_service.dart
// Service for handling user registration logic

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import '../services/profile_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/nickname_service.dart';
import '../services/email_usage_service.dart';
import '../widgets/form_field_validator.dart' as form_validator;

/// Result class for registration operations
class RegistrationResult {
  final bool success;
  final String? error;
  final User? user;

  const RegistrationResult({
    required this.success,
    this.error,
    this.user,
  });

  /// Create a successful result
  factory RegistrationResult.success(User user) {
    return RegistrationResult(success: true, user: user);
  }

  /// Create a failed result
  factory RegistrationResult.failure(String error) {
    return RegistrationResult(success: false, error: error);
  }

  /// Check if registration was successful
  bool get isSuccess => success;
}

/// Service for handling user registration operations
class RegistrationService {
  static const Duration _nicknameValidationTimeout = Duration(seconds: 8);
  static const Duration _registrationTimeout = Duration(seconds: 15);

  final ProfileService _profileService = ProfileService();
  final EmailUsageService _emailUsageService = EmailUsageService();

  /// Register a new user with email and password
  Future<RegistrationResult> registerUser({
    required String email,
    required String password,
    required String nickname,
    VoidCallback? onProgress,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Validate input parameters
      final validationError =
          _validateRegistrationInput(email, password, nickname);
      if (validationError != null) {
        return RegistrationResult.failure(validationError);
      }

      // Notify progress
      onProgress?.call();

      if (kDebugMode) {
        debugPrint('Starting registration for: $email');
      }

      // Step 1: Validate email usage (maximum 2 uses)
      final emailUsageValidation = await _validateEmailUsage(email);
      if (!emailUsageValidation.isValid) {
        return RegistrationResult.failure(
            emailUsageValidation.error ?? 'E-posta adresi kullanılamıyor');
      }

      if (kDebugMode) {
        debugPrint(
            'Email usage validation passed: ${emailUsageValidation.emailUsage?.usageCount ?? 0} uses');
      }

      // Notify progress
      onProgress?.call();

      // Step 2: Validate nickname uniqueness
      final nicknameValidation = await _validateNicknameUniqueness(nickname);
      if (!nicknameValidation.isValid) {
        return RegistrationResult.failure(
            nicknameValidation.error ?? 'Takma ad kullanılamıyor');
      }

      if (kDebugMode) {
        debugPrint('Nickname uniqueness confirmed');
      }

      // Notify progress
      onProgress?.call();

      // Step 3: Create user account
      final userCredential = await _createUserAccount(email, password);
      if (userCredential == null || userCredential.user == null) {
        return RegistrationResult.failure(
            'Kullanıcı oluşturulamadı. Lütfen tekrar deneyin.');
      }

      final User user = userCredential.user!;

      if (kDebugMode) {
        debugPrint('Firebase user created: ${user.uid}');
      }

      // Notify progress
      onProgress?.call();

      // Step 4: Initialize user profile
      await _initializeUserProfile(user, nickname);

      if (kDebugMode) {
        debugPrint('User profile initialized successfully');
      }

      // Step 5: Record email usage
      await _emailUsageService.recordEmailUsage(email, user.uid);

      if (kDebugMode) {
        debugPrint('Email usage recorded successfully');
      }

      // Notify progress
      onProgress?.call();

      // Step 6: Send email verification
      await _sendEmailVerification(user);

      if (kDebugMode) {
        debugPrint('Email verification sent successfully');
      }

      // Notify success
      onSuccess?.call();

      return RegistrationResult.success(user);
    } on FirebaseAuthException catch (e) {
      final errorMessage =
          FirebaseAuthService.handleAuthError(e, context: 'email_signup');
      if (kDebugMode) {
        debugPrint(
            'Firebase Auth error during registration: ${e.code} - ${e.message}');
      }
      onError?.call(errorMessage);
      return RegistrationResult.failure(errorMessage);
    } catch (e, stackTrace) {
      final errorMessage = 'Beklenmeyen bir hata oluştu: $e';

      if (kDebugMode) {
        debugPrint('Unexpected registration error: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      onError?.call(errorMessage);
      return RegistrationResult.failure(errorMessage);
    }
  }

  /// Validate registration input parameters
  String? _validateRegistrationInput(
      String email, String password, String nickname) {
    // Validate email
    final emailValidation =
        form_validator.FormFieldValidator.validateEmail(email);
    if (emailValidation != null) return emailValidation;

    // Validate password
    final passwordValidation =
        form_validator.FormFieldValidator.validatePassword(password);
    if (passwordValidation != null) return passwordValidation;

    // Validate nickname
    final nicknameValidation =
        form_validator.FormFieldValidator.validateNickname(nickname);
    if (nicknameValidation != null) return nicknameValidation;

    return null;
  }

  /// Validate nickname uniqueness with timeout and error handling
  Future<NicknameValidationResult> _validateNicknameUniqueness(
      String nickname) async {
    // Check if the nickname is in the suggestion list
    final isSuggestedNickname = NicknameService.isInSuggestionList(nickname);

    // If it's a suggested nickname, skip uniqueness validation
    if (isSuggestedNickname) {
      if (kDebugMode) {
        debugPrint(
            'Nickname "$nickname" is in suggestion list, skipping uniqueness check');
      }
      return NicknameValidationResult(
        isValid: true,
        error: '',
      );
    }

    try {
      return await NicknameValidator.validateWithUniqueness(nickname)
          .timeout(_nicknameValidationTimeout);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking nickname uniqueness: $e');
      }

      // Handle timeout and network errors gracefully
      if (e.toString().contains('timeout') ||
          e.toString().contains('network')) {
        return NicknameValidationResult(
          isValid: true, // Allow registration to proceed
          error: 'Takma ad kontrolü zaman aşımına uğradı, kayıt devam edecek',
        );
      }

      // For other errors, still allow registration but log
      if (kDebugMode) {
        debugPrint(
            'Nickname validation error, allowing registration to proceed: $e');
      }

      return NicknameValidationResult(
        isValid: true,
        error: 'Takma ad kontrolü yapılamadı, kayıt devam edecek',
      );
    }
  }

  /// Validate email usage (maximum 2 uses)
  Future<EmailUsageValidationResult> _validateEmailUsage(String email) async {
    try {
      return await _emailUsageService.canEmailBeUsed(email);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email usage: $e');
      }

      // On error, allow registration to proceed (fail-open approach)
      return EmailUsageValidationResult.success(
        EmailUsage(
          email: email.toLowerCase().trim(),
          usageCount: 0,
        ),
      );
    }
  }

  /// Create user account with retry mechanism
  Future<UserCredential?> _createUserAccount(
      String email, String password) async {
    try {
      return await FirebaseAuthService.createUserWithEmailAndPasswordWithRetry(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase Auth creation failed: $e');
        debugPrint('Exception type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  /// Initialize user profile in the system
  Future<void> _initializeUserProfile(User user, String nickname) async {
    try {
      await _profileService.initializeProfile(
        nickname: nickname,
        user: user,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing user profile: $e');
      }
      // Don't throw here as the user account was created successfully
      // Profile initialization can be retried later
    }
  }

  /// Get random nickname suggestion
  String getRandomNicknameSuggestion() {
    return NicknameService.getRandomSuggestion();
  }

  /// Get multiple nickname suggestions
  List<String> getMultipleNicknameSuggestions({int count = 5}) {
    return NicknameService.getMultipleSuggestions(count: count);
  }

  /// Check if email is already in use (for real-time validation)
  Future<bool> isEmailInUse(String email) async {
    try {
      // This is a heuristic check - Firebase doesn't provide a direct method
      // We try to create a user and catch the email-already-in-use error
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: 'temp_password_123',
      );

      // If we get here, the email is available
      // Sign out the temporary user
      await FirebaseAuth.instance.signOut();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      // For other errors, assume email might be available
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email availability: $e');
      }
      // On error, don't block the registration process
      return false;
    }
  }

  /// Send email verification to newly registered user
  Future<void> _sendEmailVerification(User user) async {
    try {
      await FirebaseAuthService.sendEmailVerification();
    } catch (e) {
      // Log the error but don't fail registration
      if (kDebugMode) {
        debugPrint('Email verification send error (non-critical): $e');
      }
      // Registration can still succeed even if email verification fails
      // User can request verification email later from profile settings
    }
  }
}
