// lib/pages/email_verification_and_password_reset_info_page.dart
// Email verification and password reset information page
// Shows when user has unverified email after password reset operation
// Implements the conditional redirection and verification actions as specified

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/email_verification_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/home_button.dart';

class EmailVerificationAndPasswordResetInfoPage extends StatefulWidget {
  final String? passwordResetEmail;

  const EmailVerificationAndPasswordResetInfoPage({
    super.key,
    this.passwordResetEmail,
  });

  @override
  State<EmailVerificationAndPasswordResetInfoPage> createState() => _EmailVerificationAndPasswordResetInfoPageState();
}

class _EmailVerificationAndPasswordResetInfoPageState extends State<EmailVerificationAndPasswordResetInfoPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isEmailVerified = false;
  String? _currentEmail;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          _currentEmail = currentUser.email;
        });

        // Check current email verification status
        await _checkEmailVerificationStatus();
      } else {
        // No current user, use provided email
        setState(() {
          _currentEmail = widget.passwordResetEmail;
        });
      }

      if (kDebugMode) {
        debugPrint('EmailVerificationAndPasswordResetInfoPage: Initialized for email: ${_currentEmail?.replaceRange(2, _currentEmail!.indexOf('@'), '***')}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmailVerificationAndPasswordResetInfoPage: Error initializing data: $e');
      }
    }
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      final isVerified = await EmailVerificationService.checkEmailVerificationStatus();
      setState(() {
        _isEmailVerified = isVerified;
      });

      if (_isEmailVerified && mounted) {
        // Email is now verified, show success and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta adresiniz başarıyla doğrulanmış! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Auto-navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmailVerificationAndPasswordResetInfoPage: Error checking verification status: $e');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EmailVerificationService.sendEmailVerification();
      
      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Kontrol Et',
                textColor: Colors.white,
                onPressed: _checkEmailVerificationStatus,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Tekrar Dene',
                textColor: Colors.white,
                onPressed: _sendVerificationEmail,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-posta gönderilemedi: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: _sendVerificationEmail,
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateBackToMain() {
    // Navigate back using pop - let HomeButton handle going to login
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: const Text('E-posta Doğrulama'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ThemeColors.getText(context),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: ThemeColors.getContainerBackground(context),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                size: 64,
                                color: Colors.blue,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              'Şifre Sıfırlama Başarılı!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getText(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Password Reset Information
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Şifre Sıfırlama Bilgisi',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Şifre sıfırlama bağlantısı e-postanıza gönderildi. Lütfen gelen kutunuzu ve spam klasörünüzü kontrol edin.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeColors.getSecondaryText(context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Email Verification Information
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: Colors.orange,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'E-posta Doğrulama Durumu',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Hesabınızın güvenliği için e-posta adresinizin doğrulanmamış olduğunu görüyoruz. Lütfen e-posta adresinizi doğrulayın.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeColors.getSecondaryText(context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // User Email Display
                            if (_currentEmail != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ThemeColors.getDialogContentBackground(context),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _currentEmail!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ThemeColors.getText(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // Action Buttons
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
                                  _isLoading ? 'Gönderiliyor...' : 'Doğrulama E-postasını Tekrar Gönder',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Check Status Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _checkEmailVerificationStatus,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Doğrulama Durumunu Kontrol Et'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ThemeColors.getSecondaryText(context),
                                  side: BorderSide(
                                    color: ThemeColors.getBorder(context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Later Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _navigateBackToMain,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Daha Sonra Yap'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ThemeColors.getSecondaryText(context),
                                  side: BorderSide(
                                    color: ThemeColors.getBorder(context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Help Information
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bu işlem ile aynı anda hem şifre sıfırlama hem de hesap doğrulama işlemlerini tamamlayabilirsiniz. E-posta adresinizi doğruladığınızda tüm özelliklerden yararlanabilirsiniz.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Back Navigation
                            TextButton(
                              onPressed: _isLoading ? null : () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Geri Dön',
                                style: TextStyle(
                                  color: ThemeColors.getSecondaryText(context),
                                  fontSize: 14,
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
      ),
    );
  }
}