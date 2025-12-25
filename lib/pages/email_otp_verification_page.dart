// lib/pages/email_otp_verification_page.dart
// Email OTP Verification Page for password reset code verification
// Supports both profile password reset and forgot password flows

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/email_otp_service.dart';
import '../theme/theme_colors.dart';
import 'new_password_page.dart';

/// Email OTP Verification Page
class EmailOtpVerificationPage extends StatefulWidget {
  final String email;
  final String purpose; // 'profile_reset' or 'forgot_password'

  const EmailOtpVerificationPage({
    super.key,
    required this.email,
    required this.purpose,
  });

  @override
  State<EmailOtpVerificationPage> createState() =>
      _EmailOtpVerificationPageState();
}

class _EmailOtpVerificationPageState extends State<EmailOtpVerificationPage>
    with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isVerifying = false;
  String? _countdownText;
  late DateTime _codeSentTime;

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

    _codeSentTime = DateTime.now();
    _startCountdown();

    // Auto-focus on code field
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_codeFocusNode);
    });
  }

  late final FocusNode _codeFocusNode = FocusNode();

  void _startCountdown() {
    const duration = Duration(minutes: 5);
    final endTime = _codeSentTime.add(duration);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        setState(() {
          _countdownText = 'Süre doldu';
        });
      } else {
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        setState(() {
          _countdownText =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animationController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await EmailOtpService.verifyOtpCode(
        email: widget.email,
        code: _codeController.text.trim(),
      );

      setState(() {
        _isVerifying = false;
      });

      if (result.isValid) {
        if (mounted) {
          // Başarılı - yeni şifre sayfasına yönlendir
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => NewPasswordPage(
                email: widget.email,
                purpose: widget.purpose,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorMessage(result.message);
        }
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        _showErrorMessage('Doğrulama sırasında hata oluştu: ${e.toString()}');
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EmailOtpService.sendOtpCode(
        email: widget.email,
        purpose: widget.purpose,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessMessage(result.message);
          setState(() {
            _codeSentTime = DateTime.now();
            _codeController.clear();
          });
          _startCountdown();
        } else {
          _showErrorMessage(result.message);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorMessage('Kod gönderilemedi: ${e.toString()}');
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getPageTitle() {
    switch (widget.purpose) {
      case 'profile_reset':
        return 'Şifre Sıfırla';
      case 'forgot_password':
        return 'Şifremi Unuttum';
      default:
        return 'Doğrulama';
    }
  }

  String _getDescription() {
    switch (widget.purpose) {
      case 'profile_reset':
        return '${widget.email.replaceRange(2, widget.email.indexOf('@'), '***')} adresine 6 haneli kod gönderildi.';
      case 'forgot_password':
        return '${widget.email.replaceRange(2, widget.email.indexOf('@'), '***')} adresine 6 haneli kod gönderildi.';
      default:
        return 'E-posta adresinize gönderilen kodu girin.';
    }
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
                            _getDescription(),
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.getSecondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Countdown
                          if (_countdownText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeColors.getDialogContentBackground(
                                    context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ThemeColors.getBorder(context),
                                ),
                              ),
                              child: Text(
                                'Süre: $_countdownText',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeColors.getSecondaryText(context),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Code Input Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _codeController,
                                  focusNode: _codeFocusNode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                    color: ThemeColors.getText(context),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '000000',
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
                                    counterText: '',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Kod gerekli';
                                    }
                                    if (value.length != 6) {
                                      return 'Kod 6 haneli olmalıdır';
                                    }
                                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                                      return 'Kod sadece rakam içermelidir';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Verify Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: (_isLoading || _isVerifying)
                                        ? null
                                        : _verifyCode,
                                    icon: _isVerifying
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.verified),
                                    label: Text(_isVerifying
                                        ? 'Doğrulanıyor...'
                                        : 'Doğrula'),
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
                                const SizedBox(height: 16),

                                // Resend Code Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: TextButton.icon(
                                    onPressed: (_isLoading ||
                                            _isVerifying ||
                                            _countdownText == 'Süre doldu')
                                        ? null
                                        : _resendCode,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.refresh),
                                    label: Text(_isLoading
                                        ? 'Gönderiliyor...'
                                        : 'Yeni Kod Gönder'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          ThemeColors.getPrimaryButtonColor(
                                              context),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

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
                              'Gelen kutunuzda "Şifre Sıfırlama" konulu e-postayı arayın. Kod gelmezse spam klasörünü kontrol etmeyi unutmayın.',
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
