// lib/services/form_validation_service.dart
// Comprehensive form validation and submission service with network checking

import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/form_field_validator.dart' as form_validator;
import '../services/connectivity_service.dart';

/// Comprehensive form validation and submission service
///
/// Features:
/// - Email validation using FormFieldValidator
/// - Network connectivity checking before submission
/// - Form validation via _formKey.currentState!.validate()
/// - Offline/online state management
/// - Turkish error messages for network issues
class FormValidationService {
  final ConnectivityService _connectivityService;

  FormValidationService({
    required ConnectivityService connectivityService,
  }) : _connectivityService = connectivityService;

  /// Comprehensive form validation and submission handler
  ///
  /// Steps:
  /// 1. Check form validation via _formKey.currentState!.validate()
  /// 2. Check network connectivity
  /// 3. Execute submission if both pass
  Future<FormValidationResult> validateAndSubmit({
    required GlobalKey<FormState> formKey,
    required Future<void> Function() submissionFunction,
    VoidCallback? onValidationFailure,
    VoidCallback? onNetworkFailure,
    VoidCallback? onSubmissionSuccess,
    void Function(dynamic)? onSubmissionError,
  }) async {
    try {
      // Step 1: Form Validation
      if (!formKey.currentState!.validate()) {
        if (onValidationFailure != null) {
          onValidationFailure();
        }
        return FormValidationResult.validationFailure(
          'Lütfen form alanlarını doğru şekilde doldurun.',
        );
      }

      // Step 2: Network Connectivity Check
      if (!_connectivityService.isConnected) {
        if (onNetworkFailure != null) {
          onNetworkFailure();
        }
        return FormValidationResult.networkFailure(
          'Çevrimdışı durumdasınız. Lütfen internet bağlantınızı kontrol edin.',
        );
      }

      // Step 3: Execute submission
      try {
        await submissionFunction();
        if (onSubmissionSuccess != null) {
          onSubmissionSuccess();
        }
        return FormValidationResult.success(
          'İşlem başarıyla tamamlandı.',
        );
      } catch (error) {
        if (onSubmissionError != null) {
          onSubmissionError(error);
        }
        return FormValidationResult.submissionError(
          'İşlem sırasında bir hata oluştu.',
          error: error,
        );
      }
    } catch (error) {
      return FormValidationResult.unexpectedError(
        'Beklenmeyen bir hata oluştu.',
        error: error,
      );
    }
  }

  /// Enhanced email validation using FormFieldValidator
  String? validateEmailForForm(String? value) {
    return form_validator.FormFieldValidator.validateEmail(value);
  }

  /// Check if currently connected to network
  bool get isConnected => _connectivityService.isConnected;

  /// Get connectivity stream for reactive UI
  Stream<bool> get connectivityStream =>
      _connectivityService.connectivityStateStream;

  /// Show offline snackbar message
  void showOfflineMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Çevrimdışı durumdasınız. Lütfen internet bağlantınızı kontrol edin.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: () {
            if (_connectivityService.isConnected) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Çevrimiçi oldunuz! Akışı yeniden deneyebilirsiniz.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// Show validation error snackbar
  void showValidationError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lütfen geçerli bir e-posta adresi girin.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show success message
  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show error message
  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // The calling widget should handle retry logic
          },
        ),
      ),
    );
  }
}

/// Result class for form validation operations
class FormValidationResult {
  final bool isSuccess;
  final String message;
  final dynamic error;
  final FormValidationType type;

  const FormValidationResult._({
    required this.isSuccess,
    required this.message,
    this.error,
    required this.type,
  });

  factory FormValidationResult.success(String message) {
    return FormValidationResult._(
      isSuccess: true,
      message: message,
      type: FormValidationType.success,
    );
  }

  factory FormValidationResult.validationFailure(String message) {
    return FormValidationResult._(
      isSuccess: false,
      message: message,
      type: FormValidationType.validationFailure,
    );
  }

  factory FormValidationResult.networkFailure(String message) {
    return FormValidationResult._(
      isSuccess: false,
      message: message,
      type: FormValidationType.networkFailure,
    );
  }

  factory FormValidationResult.submissionError(String message,
      {required dynamic error}) {
    return FormValidationResult._(
      isSuccess: false,
      message: message,
      error: error,
      type: FormValidationType.submissionError,
    );
  }

  factory FormValidationResult.unexpectedError(String message,
      {required dynamic error}) {
    return FormValidationResult._(
      isSuccess: false,
      message: message,
      error: error,
      type: FormValidationType.unexpectedError,
    );
  }
}

/// Types of form validation results
enum FormValidationType {
  success,
  validationFailure,
  networkFailure,
  submissionError,
  unexpectedError,
}
