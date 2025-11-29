// lib/pages/password_reset_information_page.dart
// Enhanced password reset information page for unverified email users
// Provides guidance for both password reset and email verification

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/profile_service.dart';
import '../services/deep_linking_service.dart';
import '../theme/theme_colors.dart';

class PasswordResetInformationPage extends StatefulWidget {
  final String? email;

  const PasswordResetInformationPage({
    super.key,
    this.email,
  });

  @override
  State<PasswordResetInformationPage> createState() => _PasswordResetInformationPageState();
}

class _PasswordResetInformationPageState extends State<PasswordResetInformationPage>
    with TickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  bool _isEmailVerified = false;
  String? _currentEmail;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeData();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Check email verification status
        final status = await _profileService.getEmailVerificationStatus();
        
        setState(() {
          _currentEmail = currentUser.email;
          _isEmailVerified = status.isVerified;
        });

        if (kDebugMode) {
          debugPrint('PasswordResetInfoPage: User email verification status: ${status.isVerified}');
        }
      } else {
        // No current user, use provided email or none
        setState(() {
          _currentEmail = widget.email;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PasswordResetInfoPage: Error initializing data: $e');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FirebaseAuthService.sendEmailVerification();
      
      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-posta doğrulama gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        final status = await _profileService.getEmailVerificationStatus();
        
        setState(() {
          _isEmailVerified = status.isVerified;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEmailVerified 
                  ? 'E-posta adresiniz başarıyla doğrulanmış!'
                  : 'E-posta adresiniz henüz doğrulanmamış'),
              backgroundColor: _isEmailVerified ? Colors.green : Colors.orange,
            ),
          );

          if (_isEmailVerified) {
            // Email verified, return to previous screen
            Navigator.of(context).pop(true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama durumu kontrol edilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                            Icons.email_outlined,
                            size: 60,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'E-posta Doğrulama Gerekli',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.getText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Güvenliğiniz için e-posta adresinizi doğrulamanız gerekiyor',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.getSecondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Email Info
                          if (_currentEmail != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ThemeColors.getDialogContentBackground(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'E-posta Adresiniz:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ThemeColors.getText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentEmail!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Status Indicator
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isEmailVerified 
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isEmailVerified 
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _isEmailVerified ? Icons.verified : Icons.pending,
                                  color: _isEmailVerified ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isEmailVerified 
                                      ? 'E-posta Adresiniz Doğrulanmış'
                                      : 'E-posta Adresiniz Doğrulanmamış',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isEmailVerified ? Colors.green : Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isEmailVerified
                                      ? 'Artık şifre sıfırlama e-postanızı güvenle kullanabilirsiniz.'
                                      : 'E-posta adresinizi doğrulamanız gerekiyor. Şifre sıfırlama işlemi için e-posta doğrulama gereklidir.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeColors.getSecondaryText(context),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action Buttons
                          if (!_isEmailVerified) ...[
                            // Send Verification Email Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _sendVerificationEmail,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: Text(
                                  _isLoading ? 'Gönderiliyor...' : 'E-posta Doğrulama Gönder',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Check Status Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _checkVerificationStatus,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.orange,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                                label: Text(
                                  _isLoading ? 'Kontrol Ediliyor...' : 'Doğrulama Durumunu Kontrol Et',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Continue Button for Verified Users
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Devam Et'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Help Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'E-posta gelmedi mi?\n• Spam klasörünüzü kontrol edin\n• Birkaç dakika bekleyin\n• "E-posta Doğrulama Gönder" butonuna tekrar tıklayın',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Navigation Button
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Geri Dön',
                              style: TextStyle(
                                color: ThemeColors.getSecondaryText(context),
                              ),
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