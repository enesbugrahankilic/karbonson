import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/biometric_service.dart';
import '../services/firebase_auth_service.dart';

/// Biometric Authentication Result
class BiometricAuthResult {
  final bool isSuccess;
  final String message;
  final fb_auth.UserCredential? userCredential;

  const BiometricAuthResult({
    required this.isSuccess,
    required this.message,
    this.userCredential,
  });

  factory BiometricAuthResult.success(
      String message, fb_auth.UserCredential? userCredential) {
    return BiometricAuthResult(
      isSuccess: true,
      message: message,
      userCredential: userCredential,
    );
  }

  factory BiometricAuthResult.failure(String message) {
    return BiometricAuthResult(
      isSuccess: false,
      message: message,
    );
  }
}

/// Biometric Authentication Widget
/// Provides a button for biometric login with Firebase Auth integration
class BiometricLoginButton extends StatefulWidget {
  final String email;
  final String password;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const BiometricLoginButton({
    Key? key,
    required this.email,
    required this.password,
    this.onSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends State<BiometricLoginButton> {
  bool _isAvailable = false;
  bool _isLoading = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final available = await BiometricService.isBiometricAvailable();
      if (available) {
        _biometricType = await BiometricService.getBiometricTypeName();
      }

      if (mounted) {
        setState(() {
          _isAvailable = available;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri kontrol hatası: $e');
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_isAvailable) {
      _showErrorSnackBar(
          'Biyometrik kimlik doğrulama bu cihazda mevcut değil.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First try biometric authentication
      final biometricSuccess =
          await BiometricService.authenticateWithBiometrics(
        localizedReason:
            '$_biometricType ile hızlı giriş yapmak için kimlik bilgilerinizi doğrulayın',
        useErrorDialogs: true,
      );

      if (!biometricSuccess) {
        _showErrorSnackBar(
            'Biyometrik kimlik doğrulama başarısız. Şifre ile giriş yapmayı deneyin.');
        return;
      }

      // If biometric success, try to sign in with stored credentials
      final result = await _signInWithCredentials();

      if (result.isSuccess) {
        widget.onSuccess?.call();
        _showSuccessSnackBar('Başarıyla giriş yapıldı! 🎉');
      } else {
        _showErrorSnackBar(result.message);
        widget.onError?.call();
      }
    } catch (e) {
      _showErrorSnackBar('Kimlik doğrulama hatası: ${e.toString()}');
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<BiometricAuthResult> _signInWithCredentials() async {
    try {
      final userCredential =
          await FirebaseAuthService.signInWithEmailAndPasswordWithRetry(
        email: widget.email,
        password: widget.password,
      );

      if (userCredential != null) {
        return BiometricAuthResult.success(
          'Başarıyla giriş yapıldı!',
          userCredential,
        );
      } else {
        return BiometricAuthResult.failure(
            'Giriş bilgileri geçersiz veya süresi dolmuş.');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      final errorMessage =
          FirebaseAuthService.handleAuthError(e, context: 'login');
      return BiometricAuthResult.failure(errorMessage);
    } catch (e) {
      return BiometricAuthResult.failure(
          'Beklenmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Icon _getBiometricIcon() {
    if (_biometricType.toLowerCase().contains('face')) {
      return const Icon(Icons.face, color: Colors.white);
    } else if (_biometricType.toLowerCase().contains('parmak')) {
      return const Icon(Icons.fingerprint, color: Colors.white);
    } else {
      return const Icon(Icons.security, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox
          .shrink(); // Don't show button if biometric is not available
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _authenticateWithBiometrics,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _getBiometricIcon(),
        label: Text(
          _isLoading
              ? 'Kimlik doğrulanıyor...'
              : '$_biometricType ile Giriş Yap',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

/// Standalone Biometric Login Widget
/// For use in login forms
class BiometricLoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onLoginError;

  const BiometricLoginForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    this.onLoginSuccess,
    this.onLoginError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BiometricLoginButton(
      email: emailController.text.trim(),
      password: passwordController.text,
      onSuccess: onLoginSuccess,
      onError: onLoginError,
    );
  }
}

/// Biometric Status Widget
/// Shows current biometric availability status
class BiometricStatusWidget extends StatefulWidget {
  final VoidCallback? onStatusChanged;

  const BiometricStatusWidget({
    Key? key,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<BiometricStatusWidget> createState() => _BiometricStatusWidgetState();
}

class _BiometricStatusWidgetState extends State<BiometricStatusWidget> {
  bool _isAvailable = false;
  String _status = 'Kontrol ediliyor...';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final available = await BiometricService.isBiometricAvailable();
      String statusMessage;

      if (available) {
        final biometricType = await BiometricService.getBiometricTypeName();
        statusMessage = '$biometricType mevcut ✅';
      } else {
        statusMessage = 'Biyometrik kimlik doğrulama mevcut değil ❌';
      }

      if (mounted) {
        setState(() {
          _isAvailable = available;
          _status = statusMessage;
        });
      }

      widget.onStatusChanged?.call();
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Durum kontrol edilemedi ⚠️';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isAvailable ? Icons.security : Icons.security_outlined,
              color: _isAvailable ? Colors.green : Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _status,
                style: TextStyle(
                  fontSize: 14,
                  color: _isAvailable
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isAvailable)
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _checkBiometricStatus,
                tooltip: 'Yenile',
              ),
          ],
        ),
      ),
    );
  }
}
