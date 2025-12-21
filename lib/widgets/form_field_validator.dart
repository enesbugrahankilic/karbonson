// lib/widgets/form_field_validator.dart
// Reusable form field validator for consistent validation logic

class FormFieldValidator {
  /// Email validation regex pattern as specified in requirements
  static const String _emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  /// Validate email address according to requirements
  ///
  /// Checks:
  /// 1. Empty/blank control: String.trim().isEmpty
  /// 2. Format control: Required regex pattern
  static String? validateEmail(String? value) {
    // Boşluk/Boş Kontrolü: String.trim().isEmpty ile sadece boşluklardan mı oluşuyor veya tamamen mi boş kontrolü
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen geçerli bir e-posta adresi girin.';
    }

    // Biçim Kontrolü: Required regex pattern
    final emailRegex = RegExp(_emailPattern);
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Girdiğiniz e-posta adresi biçimi geçersiz.';
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
  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }

    if (value.length < minLength) {
      return '$fieldName en az $minLength karakter olmalı';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olmalı';
    }

    return null;
  }

  /// Custom validation function
  static String? customValidate(
      String? value, bool Function(String) validator, String errorMessage) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty fields unless explicitly required
    }

    if (!validator(value)) {
      return errorMessage;
    }

    return null;
  }
}
