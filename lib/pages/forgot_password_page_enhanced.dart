// lib/pages/forgot_password_page_enhanced.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/error_feedback_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/page_templates.dart';
import 'email_verification_redirect_page.dart';

/// Enhanced Forgot Password Page with optimized UX and comprehensive error handling
/// Meets all specified requirements:
/// 1. Ön Doldurma (Pre-filling): Auto-populates email from FirebaseAuth.currentUser?.email
/// 2. Servis Çağrısı (Service Call): Uses FirebaseAuth.sendPasswordResetEmail
/// 3. Ön Kontroller (Pre-checks): Email validation + connectivity check
/// 4. Geri Bildirim (Feedback): Loading overlay + Snackbar/Toast feedback
class ForgotPasswordPageEnhanced extends StatefulWidget {
  ForgotPasswordPageEnhanced({super.key});

  @override
  State<ForgotPasswordPageEnhanced> createState() =>
      _ForgotPasswordPageEnhancedState();
}

class _ForgotPasswordPageEnhancedState extends State<ForgotPasswordPageEnhanced>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isLoading = false;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeEmailField();
    _checkConnectivity();
  }

  void _initializeAnimations() {
    // Fade animation for page entrance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();

    // Loading animation for progress indicator
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
    _loadingController.repeat();
  }

  void _initializeEmailField() {
    // ✅ ÖN DOLDURMA (Pre-filling): Auto-populate email if Firebase user is authenticated
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null && userEmail.isNotEmpty) {
      _emailController.text = userEmail;
      if (kDebugMode) {
        debugPrint(
            'ForgotPasswordPage: Auto-populated email: ${userEmail.replaceRange(2, userEmail.indexOf('@'), '***')}');
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    setState(() {
      _isConnected = isConnected;
    });

    if (kDebugMode) {
      debugPrint('ForgotPasswordPage: Network connectivity: $_isConnected');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _handleSendPasswordReset() async {
    // ✅ ÖN KONTROLLER (Pre-checks): Form validation
    if (!_formKey.currentState!.validate()) {
      _showValidationMessage();
      return;
    }

    // ✅ ÖN KONTROLLER (Pre-checks): Network connectivity check
    if (!_isConnected) {
      _showConnectivityError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // ✅ GERİ BİLDİRİM (Feedback): Show enhanced loading overlay
    _showEnhancedLoadingOverlay();

    try {
      final email = _emailController.text.trim();

      if (kDebugMode) {
        debugPrint(
            'ForgotPasswordPage: Sending password reset to: ${email.replaceRange(2, email.indexOf('@'), '***')}');
      }

      // ✅ SERVİS ÇAĞRISI (Service Call): Trigger FirebaseAuth.sendPasswordResetEmail
      await FirebaseAuthService.sendPasswordReset(email);

      // Check email verification status for redirection logic
      final currentUser = FirebaseAuth.instance.currentUser;
      bool shouldRedirectToEmailInfo = false;

      if (currentUser != null && !currentUser.emailVerified) {
        shouldRedirectToEmailInfo = true;
        if (kDebugMode) {
          debugPrint(
              'ForgotPasswordPage: User has unverified email, will show email verification info');
        }
      }

      // ✅ GERİ BİLDİRİM (Feedback): Hide loading and show success
      _hideLoadingOverlay();

      setState(() {
        _isLoading = false;
      });

      // Show appropriate feedback based on user state
      if (shouldRedirectToEmailInfo) {
        // Navigate to email verification redirect page for unverified users
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmailVerificationRedirectPage(),
          ),
        );
      } else {
        _showEnhancedSuccessSnackbar(
            FirebaseAuthService.getPasswordResetSuccessMessage());

        // Auto-navigate back to login after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pop(); // Return to login
          }
        });
      }
    } catch (e) {
      // ✅ GERİ BİLDİRİM (Feedback): Hide loading and show error
      _hideLoadingOverlay();

      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('ForgotPasswordPage: Unexpected error: $e');
      }

      // Enhanced error handling with proper FirebaseAuthException handling
      String errorMessage;
      if (e is FirebaseAuthException) {
        errorMessage = FirebaseAuthService.getPasswordResetErrorMessage(e);
      } else if (e.toString().contains('network') ||
          e.toString().contains('Network')) {
        errorMessage =
            'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.';
      } else if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
        errorMessage = 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      } else {
        errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
      }

      _showEnhancedErrorSnackbar(errorMessage);
    }
  }

  void _showValidationMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lütfen geçerli bir e-posta adresi girin'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showEnhancedSuccessSnackbar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).pop(); // Return to login
          },
        ),
      ),
    );
  }

  void _showEnhancedErrorSnackbar(String message) {
    ErrorFeedbackService.showRegistrationError(
      context: context,
      error: message,
      onRetry: _handleSendPasswordReset,
    );
  }

  void _showConnectivityError() {
    ErrorFeedbackService.showNetworkError(
      context: context,
      onRetry: () {
        _checkConnectivity();
        _handleSendPasswordReset();
      },
    );
  }

  /// ✅ GERİ BİLDİRİM (Feedback): Enhanced loading overlay with animation
  void _showEnhancedLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeColors.getDialogBackground(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _loadingAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.email_outlined,
                          size: 48,
                          color: ThemeColors.getGreen(context),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Şifre sıfırlama e-postası gönderiliyor...',
                    style: TextStyle(
                      color: ThemeColors.getText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey.withValues(alpha:  0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeColors.getGreen(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hide loading overlay
  void _hideLoadingOverlay() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: Text('Şifre Sıfırla'),
      ),
      body: PageBody(
        scrollable: true,
        child: FadeTransition(
          opacity: _fadeAnimation,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                          // Header with enhanced animation
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(0, (1 - _fadeAnimation.value) * 30),
                                child: Icon(
                                  Icons.lock_reset,
                                  size: 60,
                                  color: ThemeColors.getGreen(context),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Şifremi Unuttum',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.getText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.getSecondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Enhanced Network Status Indicator
                          if (!_isConnected)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha:  0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha:  0.3)),
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
                                  TextButton(
                                    onPressed: () {
                                      _checkConnectivity();
                                      _handleSendPasswordReset();
                                    },
                                    child: Text(
                                      'Tekrar Dene',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!_isConnected) const SizedBox(height: 16),

                          // Form with enhanced validation
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !_isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'E-posta Adresi',
                                    filled: true,
                                    fillColor:
                                        ThemeColors.getInputBackground(context),
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
                                      Icons.email,
                                      color:
                                          ThemeColors.getSecondaryText(context),
                                    ),
                                    suffixIcon: _emailController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color:
                                                  ThemeColors.getSecondaryText(
                                                      context),
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                                    _emailController.clear();
                                                    setState(() {});
                                                  },
                                          )
                                        : null,
                                  ),
                                  style: TextStyle(
                                    color: ThemeColors.getText(context),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'E-posta adresi gerekli';
                                    }
                                    if (value.trim().isEmpty) {
                                      return 'E-posta adresi boş olamaz';
                                    }
                                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                        .hasMatch(value.trim())) {
                                      return 'Geçerli bir e-posta adresi girin';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(
                                        () {}); // Rebuild to update clear button
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Enhanced Send Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: (_isLoading || !_isConnected)
                                        ? null
                                        : _handleSendPasswordReset,
                                    icon: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.send),
                                    label: Text(_isLoading
                                        ? 'Gönderiliyor...'
                                        : 'Şifre Sıfırlama E-postası Gönder'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isConnected
                                          ? ThemeColors.getPrimaryButtonColor(
                                              context)
                                          : Colors.grey,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: _isConnected ? 2 : 0,
                                      disabledBackgroundColor: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Enhanced Help Text
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
                            child: Text(
                              'E-posta adresinize gönderilen bağlantıya tıklayarak yeni şifrenizi belirleyebilirsiniz. E-posta gelmezse spam klasörünü kontrol etmeyi unutmayın.',
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
    );
  }
}
