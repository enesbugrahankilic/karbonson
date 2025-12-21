// lib/pages/enhanced_email_verification_redirect_page.dart
// Enhanced email verification redirect page for comprehensive user experience
// Implements the 4-step workflow plan for Firebase password reset and email verification

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/home_button.dart';

class EnhancedEmailVerificationRedirectPage extends StatefulWidget {
  final String? passwordResetEmail;
  final bool fromPasswordReset;

  const EnhancedEmailVerificationRedirectPage({
    super.key,
    this.passwordResetEmail,
    this.fromPasswordReset = false,
  });

  @override
  State<EnhancedEmailVerificationRedirectPage> createState() =>
      _EnhancedEmailVerificationRedirectPageState();
}

class _EnhancedEmailVerificationRedirectPageState
    extends State<EnhancedEmailVerificationRedirectPage>
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
      duration: const Duration(milliseconds: 1000),
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
      begin: 100.0,
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
        debugPrint(
            'EnhancedEmailVerificationPage: Initialized for email: ${_currentEmail?.replaceRange(2, _currentEmail!.indexOf('@'), '***')}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'EnhancedEmailVerificationPage: Error initializing data: $e');
      }
    }
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Force reload to get latest status
        await currentUser.reload();
        final updatedUser = FirebaseAuth.instance.currentUser!;

        setState(() {
          _isEmailVerified = updatedUser.emailVerified;
          _currentEmail = updatedUser.email;
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
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'EnhancedEmailVerificationPage: Error checking verification status: $e');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && !currentUser.emailVerified) {
        await currentUser.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Doğrulama e-postası başarıyla gönderildi! 📧'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Kontrol Et',
                textColor: Colors.white,
                onPressed: _checkEmailVerificationStatus,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Kullanıcı oturumu bulunamadı veya e-posta zaten doğrulanmış'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = FirebaseAuthService.handleAuthError(
          e is FirebaseAuthException
              ? e
              : FirebaseAuthException(code: 'unknown'),
          context: 'email_verification',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-posta gönderilemedi: $errorMessage'),
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
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color: ThemeColors.getContainerBackground(context),
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Enhanced Header with Password Reset Info
                            if (widget.fromPasswordReset) ...[
                              // Password Reset Success Indicator
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock_reset,
                                  size: 48,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Şifre Sıfırlama Başarılı!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Şifre sıfırlama bağlantısı e-postanıza gönderildi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Email Verification Status
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _isEmailVerified
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isEmailVerified
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.orange.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _isEmailVerified
                                        ? Icons.verified
                                        : Icons.security,
                                    color: _isEmailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _isEmailVerified
                                        ? 'E-posta Doğrulama Tamamlandı!'
                                        : 'E-posta Doğrulama Gerekli',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _isEmailVerified
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isEmailVerified
                                        ? 'E-posta adresiniz başarıyla doğrulanmış. Artık tüm özelliklerden yararlanabilirsiniz.'
                                        : 'Hesabınızın güvenliği için e-posta adresinizin doğrulanmamış olduğunu görüyoruz.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          ThemeColors.getSecondaryText(context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // User Email Display
                            if (_currentEmail != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: ThemeColors.getDialogContentBackground(
                                      context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'E-posta Adresi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  ThemeColors.getSecondaryText(
                                                      context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _currentEmail!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  ThemeColors.getText(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Action Buttons
                            if (!_isEmailVerified) ...[
                              // Enhanced Send Verification Email Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _sendVerificationEmail,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send, size: 20),
                                  label: Text(
                                    _isLoading
                                        ? 'Gönderiliyor...'
                                        : 'Doğrulama E-postasını Tekrar Gönder',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 3,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Check Status Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _checkEmailVerificationStatus,
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text(
                                    'Doğrulama Durumunu Kontrol Et',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(
                                        color: Colors.blue, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Success Continue Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  icon:
                                      const Icon(Icons.check_circle, size: 20),
                                  label: const Text(
                                    'Devam Et',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 3,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Later Button (only show if not verified)
                            if (!_isEmailVerified)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _isLoading ? null : _navigateBackToMain,
                                  icon:
                                      const Icon(Icons.arrow_forward, size: 20),
                                  label: const Text(
                                    'Daha Sonra Yap',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        ThemeColors.getSecondaryText(context),
                                    side: BorderSide(
                                      color: ThemeColors.getBorder(context),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Enhanced Help Information
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.fromPasswordReset
                                        ? 'Bu işlem ile aynı anda hem şifre sıfırlama hem de hesap doğrulama işlemlerini tamamlayabilirsiniz. E-posta adresinizi doğruladığınızda tüm özelliklerden yararlanabilirsiniz.'
                                        : 'E-posta adresinizi doğruladığınızda tüm özelliklerden yararlanabilirsiniz.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Help Tips
                            if (!_isEmailVerified) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.tips_and_updates,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'E-posta gelmedi mi?\n• Spam klasörünüzü kontrol edin\n• Birkaç dakika bekleyin\n• "Doğrulama E-postasını Tekrar Gönder" butonuna tıklayın',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Back Navigation
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
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
