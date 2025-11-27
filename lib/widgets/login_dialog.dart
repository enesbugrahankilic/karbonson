// lib/widgets/login_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    // Pre-fill email if user has cached data
    _initializeFormData();
  }

  void _initializeFormData() {
    // Initialize with empty form - user will enter their email
    // Future enhancement: could add auto-complete for cached emails
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Use proper email and password authentication
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // Use enhanced Firebase Auth Service with retry mechanism
      final credential = await FirebaseAuthService.signInWithEmailAndPasswordWithRetry(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        final user = credential!.user!;
        if (kDebugMode) {
          debugPrint('Login successful for user: ${user.uid}');
        }
        
        // Update nickname in profile if provided
        if (_nicknameController.text.isNotEmpty) {
          await _profileService.updateNickname(_nicknameController.text.trim());
        }
        
        if (mounted) {
          Navigator.of(context).pop(true); // Return true for successful login
        }
      } else {
        throw FirebaseAuthException(
          code: 'internal-error',
          message: 'Failed to sign in after multiple attempts',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Use enhanced error handling from FirebaseAuthService
      final errorMessage = FirebaseAuthService.handleAuthError(e, context: 'email_signin');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected login error: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: ThemeColors.getDialogBackground(context),
      title: Row(
        children: [
          Icon(
            Icons.person,
            color: ThemeColors.getGreen(context),
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'Giriş Yap',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta Adresi',
                  filled: true,
                  fillColor: ThemeColors.getInputBackground(context),
                  labelStyle: TextStyle(color: ThemeColors.getGreen(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.getGreen(context), width: 2),
                  ),
                  prefixIcon: Icon(Icons.email, color: ThemeColors.getSecondaryText(context)),
                ),
                style: TextStyle(
                  color: ThemeColors.getText(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta adresi gerekli';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  filled: true,
                  fillColor: ThemeColors.getInputBackground(context),
                  labelStyle: TextStyle(color: ThemeColors.getGreen(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ThemeColors.getGreen(context), width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: ThemeColors.getSecondaryText(context)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                style: TextStyle(
                  color: ThemeColors.getText(context),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre gerekli';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Help Text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColors.getDialogContentBackground(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ThemeColors.getBorder(context)),
                ),
                child: Text(
                  'Kayıt olurken kullandığınız e-posta adresi ve şifrenizle giriş yapabilirsiniz.',
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'İptal',
            style: TextStyle(color: ThemeColors.getSecondaryText(context)),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.getGreen(context),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Giriş Yap'),
        ),
      ],
    );
  }
}