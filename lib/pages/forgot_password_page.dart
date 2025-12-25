// lib/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/connectivity_service.dart';
import '../theme/theme_colors.dart';
import '../services/email_otp_service.dart';
import 'email_otp_verification_page.dart';

/// Forgot Password Page with comprehensive email validation and auto-population
/// Supports automatic email pre-filling from FirebaseAuth.currentUser?.email
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isLoading = false;
  bool _isConnected = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeEmailField();
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

  void _initializeEmailField() {
    // Auto-populate email if available from FirebaseAuth.currentUser?.email
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
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
    super.dispose();
  }

  Future<void> _handleSendPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationMessage();
      return;
    }

    if (!_isConnected) {
      _showConnectivityError();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show ModalProgressHUD loading overlay
    _showLoadingOverlay();

    try {
      final email = _emailController.text.trim();

      if (kDebugMode) {
        debugPrint(
            'ForgotPasswordPage: Sending OTP code to: ${email.replaceRange(2, email.indexOf('@'), '***')}');
      }

      // Send OTP code using email OTP service
      final otpResult = await EmailOtpService.sendOtpCode(
        email: email,
        purpose: 'forgot_password',
      );

      // Hide loading overlay
      _hideLoadingOverlay();

      setState(() {
        _isLoading = false;
      });

      // Handle the result
      if (otpResult.isSuccess) {
        // Navigate to OTP verification page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EmailOtpVerificationPage(
              email: email,
              purpose: 'forgot_password',
            ),
          ),
        );
      } else {
        // Show error message
        _showErrorSnackbar(otpResult.message);
      }
    } catch (e) {
      // Hide loading overlay
      _hideLoadingOverlay();

      setState(() {
        _isLoading = false;
      });

      if (kDebugMode) {
        debugPrint('ForgotPasswordPage: Unexpected error: $e');
      }

      // Enhanced error handling
      String errorMessage;
      if (e.toString().contains('network') ||
          e.toString().contains('Network')) {
        errorMessage =
            'İnternet bağlantınızı kontrol edin. Ağ bağlantısı sorunu var.';
      } else if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
        errorMessage = 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      } else {
        errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
      }

      _showErrorSnackbar(errorMessage);
    }
  }

  void _showValidationMessage() {
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: _handleSendPasswordReset,
        ),
      ),
    );
  }

  void _showConnectivityError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'İnternet bağlantınızı kontrol edin. Çevrimdışı modda şifre sıfırlama işlemi yapılamaz.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Tekrar Dene',
          textColor: Colors.white,
          onPressed: _handleSendPasswordReset,
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ThemeColors.getDialogBackground(context),
          title: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'E-posta Gönderildi',
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to login
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSendPasswordReset(); // Retry
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

  /// Show ModalProgressHUD-style loading overlay
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  /// Hide loading overlay
  void _hideLoadingOverlay() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show email verification info dialog for unverified users
  void _showEmailVerificationInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ThemeColors.getDialogBackground(context),
          title: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'E-posta Doğrulama Gerekli',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Şifre sıfırlama e-postası gönderildi, ancak e-posta adresiniz henüz doğrulanmamış.',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                      'Şifre sıfırlama e-postanızı kontrol edin ve e-posta doğrulama linkine de tıklayın. E-posta adresinizi doğruladığınızda tüm özelliklerden yararlanabilirsiniz.',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to login
              },
              child: Text(
                'Tamam',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to email verification page
                Navigator.of(context).pushNamed('/email-verification');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('E-posta Doğrula'),
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
                            Icons.lock_reset,
                            size: 60,
                            color: ThemeColors.getGreen(context),
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
                            'E-posta adresinizi girin, size 6 haneli doğrulama kodu gönderelim.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.getSecondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Network Status Indicator
                          if (!_isConnected)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3)),
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

                          // Form
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

                                // Send Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: (_isLoading || !_isConnected)
                                        ? null
                                        : _handleSendPasswordReset,
                                    icon: const Icon(Icons.send),
                                    label: const Text('Doğrulama Kodu Gönder'),
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
                              color: ThemeColors.getDialogContentBackground(
                                  context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ThemeColors.getBorder(context),
                              ),
                            ),
                            child: Text(
                              'E-posta adresinize gönderilen 6 haneli kodu girerek yeni şifrenizi belirleyebilirsiniz. E-posta gelmezse spam klasörünü kontrol etmeyi unutmayın.',
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
