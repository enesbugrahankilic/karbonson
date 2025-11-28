// lib/pages/password_change_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/login_dialog.dart';

/// Password Change Page for setting new password after email reset link
/// Handles deep linking from password reset emails
class PasswordChangePage extends StatefulWidget {
  final String? resetCode;
  final String? email;

  const PasswordChangePage({
    super.key,
    this.resetCode,
    this.email,
  });

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage>
    with TickerProviderStateMixin {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ConnectivityService _connectivityService = ConnectivityService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool _isConnected = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _receivedEmail;
  String? _receivedCode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeFromParameters();
    _checkConnectivity();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }

  void _initializeFromParameters() {
    _receivedCode = widget.resetCode;
    _receivedEmail = widget.email;

    // If no parameters provided, we can try to extract from Firebase Auth
    if (_receivedCode == null || _receivedEmail == null) {
      // This would typically be handled by deep linking
      if (kDebugMode) {
        debugPrint('PasswordChangePage: No reset code or email provided via parameters');
        debugPrint('Expected to receive reset code and email from email link');
      }
    } else {
      if (kDebugMode) {
        debugPrint('PasswordChangePage: Received reset code and email for: ${_receivedEmail!.replaceRange(2, _receivedEmail!.indexOf('@'), '***')}');
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    setState(() {
      _isConnected = isConnected;
    });
    
    if (kDebugMode) {
      debugPrint('PasswordChangePage: Network connectivity: $_isConnected');
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationMessage();
      return;
    }

    if (!_isConnected) {
      _showConnectivityError();
      return;
    }

    if (_receivedCode == null) {
      _showErrorDialog('Geçersiz veya eksik sıfırlama kodu. Lütfen e-postadaki bağlantıyı tekrar kullanın.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newPassword = _newPasswordController.text;
      
      if (kDebugMode) {
        debugPrint('PasswordChangePage: Changing password for email: ${_receivedEmail?.replaceRange(2, _receivedEmail!.indexOf('@'), '***')}');
      }

      // Confirm password reset using FirebaseAuthService
      await FirebaseAuthService.confirmPasswordReset(
        code: _receivedCode!,
        newPassword: newPassword,
      );

      // Update email verification status if needed
      try {
        await _profileService.syncEmailVerificationStatus();
        if (kDebugMode) {
          debugPrint('PasswordChangePage: Email verification status synced');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('PasswordChangePage: Failed to sync email verification status: $e');
        }
        // Don't fail the entire process for this
      }

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog();

    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('PasswordChangePage: Firebase Auth error: ${e.code} - ${e.message}');
      }

      final errorMessage = FirebaseAuthService.handleAuthError(e, context: 'password_reset');
      _showErrorDialog(errorMessage);

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('PasswordChangePage: Unexpected error: $e');
      }

      _showErrorDialog('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  void _showValidationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lütfen tüm alanları doğru şekilde doldurun'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showConnectivityError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('İnternet bağlantınızı kontrol edin. Çevrimdışı modda şifre değiştirilemez.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: _handlePasswordChange,
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ThemeColors.getDialogBackground(context),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Şifre Başarıyla Değiştirildi',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Yeni şifreniz başarıyla ayarlandı. Şimdi yeni şifrenizle giriş yapabilirsiniz.',
            style: TextStyle(
              color: ThemeColors.getText(context),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst); // Return to login
                // Show login dialog
                Future.delayed(const Duration(milliseconds: 500), () {
                  showDialog(
                    context: context,
                    builder: (context) => const LoginDialog(),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Giriş Yap'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ThemeColors.getDialogBackground(context),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Hata',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              color: ThemeColors.getText(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
            ),
            if (_receivedCode != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handlePasswordChange(); // Retry
                },
                child: Text(
                  'Tekrar Dene',
                  style: TextStyle(
                    color: ThemeColors.getPrimaryButtonColor(context),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: ThemeColors.getContainerBackground(context),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Icon(
                            Icons.lock_person_outlined,
                            size: 60,
                            color: ThemeColors.getGreen(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Yeni Şifre Belirle',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.getText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_receivedEmail != null)
                            Text(
                              '${_receivedEmail!.replaceRange(2, _receivedEmail!.indexOf('@'), '***')} için yeni şifrenizi belirleyin',
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.getSecondaryText(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          if (_receivedCode == null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Geçersiz veya süresi dolmuş bağlantı. Lütfen e-postadaki bağlantıyı tekrar kullanın.',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Network Status Indicator
                          if (!_isConnected)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.wifi_off,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'İnternet bağlantısı yok',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!_isConnected) const SizedBox(height: 16),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // New Password Field
                                TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  enabled: !_isLoading && _receivedCode != null,
                                  decoration: InputDecoration(
                                    labelText: 'Yeni Şifre',
                                    filled: true,
                                    fillColor: ThemeColors.getInputBackground(context),
                                    labelStyle: TextStyle(
                                      color: ThemeColors.getGreen(context),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: ThemeColors.getBorder(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: ThemeColors.getBorder(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: ThemeColors.getPrimaryButtonColor(context),
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: ThemeColors.getSecondaryText(context),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                                        color: ThemeColors.getSecondaryText(context),
                                      ),
                                      onPressed: _isLoading || _receivedCode == null
                                          ? null
                                          : () {
                                              setState(() {
                                                _obscureNewPassword = !_obscureNewPassword;
                                              });
                                            },
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: ThemeColors.getText(context),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Yeni şifre gerekli';
                                    }
                                    if (value.length < 6) {
                                      return 'Şifre en az 6 karakter olmalı';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  enabled: !_isLoading && _receivedCode != null,
                                  decoration: InputDecoration(
                                    labelText: 'Şifre Onayı',
                                    filled: true,
                                    fillColor: ThemeColors.getInputBackground(context),
                                    labelStyle: TextStyle(
                                      color: ThemeColors.getGreen(context),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: ThemeColors.getBorder(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: ThemeColors.getBorder(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: ThemeColors.getPrimaryButtonColor(context),
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: ThemeColors.getSecondaryText(context),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                        color: ThemeColors.getSecondaryText(context),
                                      ),
                                      onPressed: _isLoading || _receivedCode == null
                                          ? null
                                          : () {
                                              setState(() {
                                                _obscureConfirmPassword = !_obscureConfirmPassword;
                                              });
                                            },
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: ThemeColors.getText(context),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Şifre onayı gerekli';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Şifreler eşleşmiyor';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Change Password Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: (_isLoading || !_isConnected || _receivedCode == null) ? null : _handlePasswordChange,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.save),
                                    label: Text(
                                      _isLoading ? 'Şifre Değiştiriliyor...' : 'Şifreyi Değiştir',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (_isConnected && _receivedCode != null)
                                          ? ThemeColors.getPrimaryButtonColor(context)
                                          : Colors.grey,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: (_isConnected && _receivedCode != null) ? 2 : 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Help Text
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ThemeColors.getDialogContentBackground(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ThemeColors.getBorder(context),
                              ),
                            ),
                            child: Text(
                              'Yeni şifreniz en az 6 karakter olmalıdır. Güvenli bir şifre seçtiğinizden emin olun.',
                              style: TextStyle(
                                color: ThemeColors.getSecondaryText(context),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}