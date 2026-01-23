// lib/pages/register_page_refactored.dart
// Refactored registration page with improved architecture

import 'package:flutter/material.dart';
import '../services/registration_service.dart';
import '../services/error_feedback_service.dart';
import '../widgets/custom_form_field.dart';
import '../theme/theme_colors.dart';
import '../widgets/page_templates.dart';
import 'login_page.dart';
import 'profile_page.dart';

class RegisterPageRefactored extends StatefulWidget {
  RegisterPageRefactored({super.key});

  @override
  State<RegisterPageRefactored> createState() => _RegisterPageRefactoredState();
}

class _RegisterPageRefactoredState extends State<RegisterPageRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();

  final RegistrationService _registrationService = RegistrationService();
  bool _isLoading = false;
  bool _isRegistrationInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeRandomNickname();
  }

  /// Initialize with a random nickname suggestion
  void _initializeRandomNickname() {
    final randomNickname = _registrationService.getRandomNicknameSuggestion();
    _nicknameController.text = randomNickname;
  }

  /// Suggest a new random nickname
  void _suggestRandomNickname() {
    final suggestions =
        _registrationService.getMultipleNicknameSuggestions(count: 3);
    final newSuggestion = suggestions.first;

    setState(() {
      _nicknameController.text = newSuggestion;
    });

    ErrorFeedbackService.showNicknameSuggestion(
      context: context,
      suggestedNickname: newSuggestion,
    );
  }

  /// Handle form submission
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      _showFormValidationErrors();
      return;
    }

    if (_isLoading || _isRegistrationInProgress) {
      return; // Prevent multiple submissions
    }

    setState(() {
      _isLoading = true;
      _isRegistrationInProgress = true;
    });

    // Clear previous feedback
    ErrorFeedbackService.clearFeedback(context);

    try {
      final result = await _registrationService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nickname: _nicknameController.text.trim(),
        onProgress: () => _updateProgress('Kullanıcı oluşturuluyor...'),
        onSuccess: () => _onRegistrationSuccess(),
        onError: (error) => _onRegistrationError(error),
      );

      if (result.isSuccess && result.user != null) {
        await _onRegistrationSuccess();
      } else if (result.error != null) {
        _onRegistrationError(result.error!);
      }
    } catch (e, stackTrace) {
      final errorMessage =
          ErrorFeedbackService.getDevelopmentErrorInfo(e, stackTrace);
      _onRegistrationError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRegistrationInProgress = false;
        });
      }
    }
  }

  /// Update progress feedback
  void _updateProgress(String message) {
    ErrorFeedbackService.showLoadingProgress(
      context: context,
      message: message,
    );
  }

  /// Handle successful registration
  Future<void> _onRegistrationSuccess() async {
    ErrorFeedbackService.showRegistrationSuccess(
      context: context,
      message: 'Kayıt başarılı! Yönlendiriliyorsunuz...',
    );

    // Navigate to profile page after a short delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  /// Handle registration error
  void _onRegistrationError(String error) {
    ErrorFeedbackService.showRegistrationError(
      context: context,
      error: error,
      onRetry: _isRegistrationInProgress ? null : _handleRegistration,
    );
  }

  /// Show form validation errors
  void _showFormValidationErrors() {
    final errors = <String, String>{};

    // Validate each field
    final emailError = _validateEmailField(_emailController.text);
    if (emailError != null) errors['E-posta'] = emailError;

    final passwordError = _validatePasswordField(_passwordController.text);
    if (passwordError != null) errors['Şifre'] = passwordError;

    final confirmPasswordError = _validateConfirmPasswordField(
      _confirmPasswordController.text,
      _passwordController.text,
    );
    if (confirmPasswordError != null) {
      errors['Şifre Tekrarı'] = confirmPasswordError;
    }

    final nicknameError = _validateNicknameField(_nicknameController.text);
    if (nicknameError != null) errors['Takma Ad'] = nicknameError;

    if (errors.isNotEmpty) {
      ErrorFeedbackService.showFormValidationErrors(
        context: context,
        errors: errors,
      );
    }
  }

  /// Individual field validation methods
  String? _validateEmailField(String value) {
    if (value.isEmpty) return 'E-posta adresi gerekli';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? _validatePasswordField(String value) {
    if (value.isEmpty) return 'Şifre gerekli';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  String? _validateConfirmPasswordField(String value, String password) {
    if (value.isEmpty) return 'Şifre tekrarı gerekli';
    if (value != password) return 'Şifreler eşleşmiyor';
    return null;
  }

  String? _validateNicknameField(String value) {
    if (value.isEmpty) return 'Takma ad gerekli';
    if (value.length < 3) return 'Takma ad en az 3 karakter olmalı';
    if (value.length > 20) return 'Takma ad en fazla 20 karakter olmalı';

    final validChars = RegExp(r'^[a-zA-Z0-9_ğüşöçıĞÜŞÖÇİ]+$');
    if (!validChars.hasMatch(value)) {
      return 'Takma ad sadece harf, rakam ve alt çizgi içerebilir';
    }
    return null;
  }

  /// Handle login navigation
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: Text('Kayıt Ol'),
      ),
      body: PageBody(
        scrollable: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _buildRegistrationCard(),
          ),
        ),
      ),
    );
  }

  /// Build the main registration card
  Widget _buildRegistrationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.getContainerBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getShadow(context),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildForm(),
          const SizedBox(height: 24),
          _buildRegisterButton(),
          const SizedBox(height: 16),
          _buildLoginLink(),
        ],
      ),
    );
  }

  /// Build the header section
  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add,
          size: 60,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        Text(
          'Yeni Hesap Oluştur',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ThemeColors.getTitleText(context),
          ),
        ),
      ],
    );
  }

  /// Build the registration form
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          EmailFormField(
            labelText: 'E-posta Adresi',
            controller: _emailController,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          PasswordFormField(
            labelText: 'Şifre',
            controller: _passwordController,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          PasswordConfirmationFormField(
            labelText: 'Şifre Tekrar',
            passwordToMatch: _passwordController.text,
            controller: _confirmPasswordController,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          NicknameFormField(
            labelText: 'Takma Adınız',
            controller: _nicknameController,
            enabled: !_isLoading,
            onSuggestRandom: _isLoading ? null : _suggestRandomNickname,
          ),
        ],
      ),
    );
  }

  /// Build the register button
  Widget _buildRegisterButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleRegistration,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.person_add),
      label: Text(_isLoading ? 'Kayıt Oluyor...' : 'Kayıt Ol'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Build the login link
  Widget _buildLoginLink() {
    return TextButton(
      onPressed: _isLoading ? null : _navigateToLogin,
      child: Text(
        'Zaten hesabınız var mı? Giriş Yapın',
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
