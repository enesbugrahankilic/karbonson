// lib/widgets/form_field_validator.dart
// Reusable form field validator for consistent validation logic

class FormFieldValidator {
  /// Email validation regex pattern
  static const String _emailPattern = r'^[^@]+@[^@]+\.[^@]+';

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(_emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  /// Validate nickname
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Takma ad gerekli';
    }
    
    if (value.length < 3) {
      return 'Takma ad en az 3 karakter olmalı';
    }
    
    if (value.length > 20) {
      return 'Takma ad en fazla 20 karakter olmalı';
    }
    
    // Check for valid characters (letters, numbers, underscore)
    final validChars = RegExp(r'^[a-zA-Z0-9_ğüşöçıĞÜŞÖÇİ]+$');
    if (!validChars.hasMatch(value)) {
      return 'Takma ad sadece harf, rakam ve alt çizgi içerebilir';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    
    if (value.length < minLength) {
      return '$fieldName en az $minLength karakter olmalı';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olmalı';
    }
    
    return null;
  }

  /// Custom validation function
  static String? customValidate(
    String? value, 
    bool Function(String) validator, 
    String errorMessage
  ) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty fields unless explicitly required
    }
    
    if (!validator(value)) {
      return errorMessage;
    }
    
    return null;
  }
}