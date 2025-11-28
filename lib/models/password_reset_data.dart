// lib/models/password_reset_data.dart

/// Result class for password reset operations
class PasswordResetResult {
  final bool isSuccess;
  final String message;
  final String? email;

  const PasswordResetResult({
    required this.isSuccess,
    required this.message,
    this.email,
  });

  factory PasswordResetResult.success(String message, String email) {
    return PasswordResetResult(
      isSuccess: true,
      message: message,
      email: email,
    );
  }

  factory PasswordResetResult.failure(String message) {
    return PasswordResetResult(
      isSuccess: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'PasswordResetResult{isSuccess: $isSuccess, message: $message, email: $email}';
  }
}

/// Password change result class
class PasswordChangeResult {
  final bool isSuccess;
  final String message;

  const PasswordChangeResult({
    required this.isSuccess,
    required this.message,
  });

  factory PasswordChangeResult.success(String message) {
    return PasswordChangeResult(
      isSuccess: true,
      message: message,
    );
  }

  factory PasswordChangeResult.failure(String message) {
    return PasswordChangeResult(
      isSuccess: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'PasswordChangeResult{isSuccess: $isSuccess, message: $message}';
  }
}