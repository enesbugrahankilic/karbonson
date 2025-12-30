import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive input validation service for KarbonSon application
/// Provides email, nickname, password validation and content sanitization
class InputValidationService {
  static final InputValidationService _instance = InputValidationService._internal();
  factory InputValidationService() => _instance;
  InputValidationService._internal();

  // Validation constants
  static const int MIN_PASSWORD_LENGTH = 8;
  static const int MAX_PASSWORD_LENGTH = 128;
  static const int MIN_NICKNAME_LENGTH = 3;
  static const int MAX_NICKNAME_LENGTH = 20;
  static const int MAX_INPUT_LENGTH = 1000;

  // Common validation patterns
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  static final RegExp _nicknameRegex = RegExp(
    r'^[a-zA-Z0-9_çğıöşüÇĞIİÖŞÜ]+$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );

  // Security patterns for content sanitization
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>');
  static final RegExp _scriptTagRegex = RegExp(r'<script[^>]*>.*?</script>', 
      caseSensitive: false, multiLine: true);
  static final RegExp _sqlInjectionRegex = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b)',
    caseSensitive: false,
  );

  // Rate limiting storage
  SharedPreferences? _prefs;

  /// Initialize the validation service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Validate email address
  /// Returns ValidationResult with success status and error message
  ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email adresi gereklidir',
        errorCode: ValidationErrorCode.requiredField,
      );
    }

    if (email.length > MAX_INPUT_LENGTH) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email adresi çok uzun',
        errorCode: ValidationErrorCode.tooLong,
      );
    }

    if (!_emailRegex.hasMatch(email)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Geçerli bir email adresi giriniz',
        errorCode: ValidationErrorCode.invalidEmail,
      );
    }

    // Check for suspicious patterns
    if (_containsSuspiciousPatterns(email)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email adresi güvenlik kontrolünden geçemedi',
        errorCode: ValidationErrorCode.suspiciousPattern,
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Validate nickname/username
  /// Returns ValidationResult with success status and error message
  ValidationResult validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Kullanıcı adı gereklidir',
        errorCode: ValidationErrorCode.requiredField,
      );
    }

    if (nickname.length < MIN_NICKNAME_LENGTH) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Kullanıcı adı en az $MIN_NICKNAME_LENGTH karakter olmalıdır',
        errorCode: ValidationErrorCode.tooShort,
      );
    }

    if (nickname.length > MAX_NICKNAME_LENGTH) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Kullanıcı adı en fazla $MAX_NICKNAME_LENGTH karakter olabilir',
        errorCode: ValidationErrorCode.tooLong,
      );
    }

    if (!_nicknameRegex.hasMatch(nickname)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir',
        errorCode: ValidationErrorCode.invalidFormat,
      );
    }

    // Check for reserved names
    if (_isReservedName(nickname)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Bu kullanıcı adı rezerve edilmiştir',
        errorCode: ValidationErrorCode.reservedName,
      );
    }

    // Check for inappropriate content
    if (_containsInappropriateContent(nickname)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Kullanıcı adı uygunsuz içerik içeremez',
        errorCode: ValidationErrorCode.inappropriateContent,
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Validate password strength
  /// Returns ValidationResult with success status and error message
  ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre gereklidir',
        errorCode: ValidationErrorCode.requiredField,
      );
    }

    if (password.length < MIN_PASSWORD_LENGTH) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre en az $MIN_PASSWORD_LENGTH karakter olmalıdır',
        errorCode: ValidationErrorCode.tooShort,
      );
    }

    if (password.length > MAX_PASSWORD_LENGTH) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre en fazla $MAX_PASSWORD_LENGTH karakter olabilir',
        errorCode: ValidationErrorCode.tooLong,
      );
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre en az bir küçük harf içermelidir',
        errorCode: ValidationErrorCode.missingLowercase,
      );
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre en az bir büyük harf içermelidir',
        errorCode: ValidationErrorCode.missingUppercase,
      );
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre en az bir rakam içermelidir',
        errorCode: ValidationErrorCode.missingDigit,
      );
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[@$!%*?&]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifre en az bir özel karakter içermelidir (@\$!%*?&)',
        errorCode: ValidationErrorCode.missingSpecialChar,
      );
    }

    // Check for common weak passwords
    if (_isCommonPassword(password)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Bu şifre çok yaygın kullanılmaktadır. Daha güçlü bir şifre seçiniz',
        errorCode: ValidationErrorCode.commonPassword,
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Validate password confirmation match
  ValidationResult validatePasswordConfirmation(String password, String confirmation) {
    if (password != confirmation) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Şifreler eşleşmiyor',
        errorCode: ValidationErrorCode.passwordMismatch,
      );
    }
    return ValidationResult(isValid: true);
  }

  /// Sanitize input string to prevent XSS and injection attacks
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    String sanitized = input;

    // Remove HTML tags
    sanitized = sanitized.replaceAll(_htmlTagRegex, '');

    // Remove script tags and their content
    sanitized = sanitized.replaceAll(_scriptTagRegex, '');

    // Remove null bytes and control characters except newlines and tabs
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // Trim excessive whitespace
    sanitized = sanitized.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Limit length
    if (sanitized.length > MAX_INPUT_LENGTH) {
      sanitized = sanitized.substring(0, MAX_INPUT_LENGTH);
    }

    return sanitized;
  }

  /// Check if input contains SQL injection patterns
  bool containsSqlInjection(String input) {
    return _sqlInjectionRegex.hasMatch(input);
  }

  /// Generate secure hash for sensitive data
  String generateSecureHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Rate limiting validation
  /// Returns true if operation is allowed, false if rate limited
  Future<bool> checkRateLimit(String operation, String identifier, {
    int maxAttempts = 5,
    Duration timeWindow = const Duration(minutes: 15),
  }) async {
    if (_prefs == null) await initialize();

    final key = 'rate_limit_${operation}_$identifier';
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - timeWindow.inMilliseconds;

    // Get existing attempts
    final attemptsJson = _prefs?.getString(key);
    List<int> attempts = [];
    
    if (attemptsJson != null) {
      try {
        attempts = List<int>.from(json.decode(attemptsJson));
        // Remove old attempts
        attempts = attempts.where((timestamp) => timestamp > cutoff).toList();
      } catch (e) {
        attempts = [];
      }
    }

    // Check if rate limited
    if (attempts.length >= maxAttempts) {
      return false;
    }

    // Add current attempt
    attempts.add(now);
    await _prefs?.setString(key, json.encode(attempts));
    
    return true;
  }

  /// Clear rate limiting for specific operation and identifier
  Future<void> clearRateLimit(String operation, String identifier) async {
    if (_prefs == null) await initialize();
    
    final key = 'rate_limit_${operation}_$identifier';
    await _prefs?.remove(key);
  }

  /// Private helper methods
  bool _containsSuspiciousPatterns(String input) {
    final suspiciousPatterns = [
      'script',
      'javascript:',
      'data:',
      'vbscript:',
      'onload=',
      'onerror=',
      'onclick=',
    ];

    final lowerInput = input.toLowerCase();
    return suspiciousPatterns.any((pattern) => lowerInput.contains(pattern));
  }

  bool _isReservedName(String nickname) {
    final reservedNames = [
      'admin', 'administrator', 'root', 'system', 'null', 'undefined',
      'anonymous', 'guest', 'user', 'test', 'demo', 'karbon', 'karbonson',
      'support', 'help', 'info', 'contact', 'team', 'staff'
    ];

    return reservedNames.contains(nickname.toLowerCase());
  }

  bool _containsInappropriateContent(String input) {
    final inappropriateWords = [
      // Add inappropriate words list here
      // This is a basic example - in production, use a more comprehensive list
    ];

    final lowerInput = input.toLowerCase();
    return inappropriateWords.any((word) => lowerInput.contains(word));
  }

  bool _isCommonPassword(String password) {
    final commonPasswords = [
      '123456', 'password', '123456789', '12345', '12345678',
      'qwerty', '1234567', '111111', '123123', 'abc123',
      'password1', 'admin', 'letmein', 'welcome', 'monkey',
    ];

    return commonPasswords.contains(password.toLowerCase());
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String errorMessage;
  final ValidationErrorCode errorCode;

  ValidationResult({
    required this.isValid,
    this.errorMessage = '',
    this.errorCode = ValidationErrorCode.none,
  });

  /// Get user-friendly error message
  String getLocalizedMessage() {
    return errorMessage;
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errorMessage: $errorMessage, errorCode: $errorCode)';
  }
}

/// Validation error codes
enum ValidationErrorCode {
  none,
  requiredField,
  tooShort,
  tooLong,
  invalidEmail,
  invalidFormat,
  passwordMismatch,
  missingLowercase,
  missingUppercase,
  missingDigit,
  missingSpecialChar,
  commonPassword,
  reservedName,
  inappropriateContent,
  suspiciousPattern,
}

/// Extension for easy validation in UI components
extension InputValidationExtensions on String {
  ValidationResult validateEmail() => InputValidationService().validateEmail(this);
  ValidationResult validateNickname() => InputValidationService().validateNickname(this);
  ValidationResult validatePassword() => InputValidationService().validatePassword(this);
  
  String sanitize() => InputValidationService().sanitizeInput(this);
}