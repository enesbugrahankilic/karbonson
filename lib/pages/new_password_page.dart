// lib/pages/new_password_page.dart
// New Password Page for setting new password after OTP verification
// Supports both profile password reset and forgot password flows

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../theme/theme_colors.dart';
import '../core/navigation/app_router.dart';
import '../widgets/home_button.dart';

/// New Password Page - sets new password after OTP verification
class NewPasswordPage extends StatefulWidget {
  final String email;
  final String purpose; // 'profile_reset' or 'forgot_password'

  const NewPasswordPage({
    super.key,
    required this.email,
    required this.purpose,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _setNewPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Kullanıcı oturumu bulunamadı
        if (mounted) {
          _showErrorDialog(
              'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.');
        }
        return;
      }

      // Şifreyi güncelle
      await user.updatePassword(_passwordController.text);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e.toString().contains('weak-password')) {
          errorMessage = 'Yeni şifre çok zayıf. En az 6 karakter olmalıdır.';
        } else if (e.toString().contains('requires-recent-login')) {
          errorMessage =
              'Şifrenizi değiştirmek için tekrar giriş yapmanız gerekiyor.';
        } else {
          errorMessage = 'Şifre değiştirilirken hata oluştu: ${e.toString()}';
        }

        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                  color: ThemeColors.getPrimaryButtonColor(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Başarılı',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            _getSuccessMessage(),
            style: TextStyle(
              color: ThemeColors.getText(context),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToNextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNextStep() {
    switch (widget.purpose) {
      case 'profile_reset':
        // Profil sayfasına dön
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 'forgot_password':
        // Login sayfasına git
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
        break;
      default:
        // Varsayılan olarak login'e git
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
    }
  }

  String _getPageTitle() {
    switch (widget.purpose) {
      case 'profile_reset':
        return 'Yeni Şifre Belirle';
      case 'forgot_password':
        return 'Şifre Sıfırla';
      default:
        return 'Yeni Şifre';
    }
  }

  String _getSuccessMessage() {
    switch (widget.purpose) {
      case 'profile_reset':
        return 'Şifreniz başarıyla güncellendi. Artık yeni şifrenizle giriş yapabilirsiniz.';
      case 'forgot_password':
        return 'Şifreniz başarıyla sıfırlandı. Artık yeni şifrenizle giriş yapabilirsiniz.';
      default:
        return 'Şifreniz başarıyla güncellendi.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Text(_getPageTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ThemeColors.getText(context),
      ),
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
                            Icons.lock_reset,
                            size: 60,
                            color: ThemeColors.getGreen(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getPageTitle(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.getText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.email.replaceRange(2, widget.email.indexOf('@'), '***')} için yeni şifrenizi belirleyin.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.getSecondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Password Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // New Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Yeni Şifre',
                                    filled: true,
                                    fillColor:
                                        ThemeColors.getInputBackground(context),
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
                                        color:
                                            ThemeColors.getPrimaryButtonColor(
                                                context),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color:
                                          ThemeColors.getSecondaryText(context),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: ThemeColors.getSecondaryText(
                                            context),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword =
                                            !_obscurePassword);
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
                                      return 'Yeni şifre en az 6 karakter olmalı';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Yeni Şifre Tekrar',
                                    filled: true,
                                    fillColor:
                                        ThemeColors.getInputBackground(context),
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
                                        color:
                                            ThemeColors.getPrimaryButtonColor(
                                                context),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color:
                                          ThemeColors.getSecondaryText(context),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: ThemeColors.getSecondaryText(
                                            context),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureConfirmPassword =
                                            !_obscureConfirmPassword);
                                      },
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: ThemeColors.getText(context),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Şifre tekrarı gerekli';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Şifreler eşleşmiyor';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Set Password Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _setNewPassword,
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
                                    label: Text(_isLoading
                                        ? 'Kaydediliyor...'
                                        : 'Şifre Kaydet'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ThemeColors.getPrimaryButtonColor(
                                              context),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Security Tips
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ThemeColors.getDialogContentBackground(
                                  context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ThemeColors.getBorder(context),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Güvenlik İpuçları:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.getText(context),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• En az 6 karakter kullanın\n• Büyük ve küçük harfleri karıştırın\n• Rakam ve özel karakter ekleyin',
                                  style: TextStyle(
                                    color:
                                        ThemeColors.getSecondaryText(context),
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
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
