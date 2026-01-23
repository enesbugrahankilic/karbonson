// lib/pages/two_factor_auth_page.dart
// SMS-based Two-Factor Authentication Page
// Provides complete 2FA verification flow with phone number validation

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/email_otp_service.dart';
import '../widgets/phone_number_validation_dialog.dart';
import '../services/phone_number_validator.dart';
import '../theme/theme_colors.dart';
import '../widgets/page_templates.dart';

class TwoFactorAuthPage extends StatefulWidget {
  final String userId;
  final String? initialPhoneNumber;
  final VoidCallback? onVerificationSuccess;
  final VoidCallback? onCancel;

  const TwoFactorAuthPage({
    super.key,
    required this.userId,
    this.initialPhoneNumber,
    this.onVerificationSuccess,
    this.onCancel,
  });

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables
  String? _currentPhoneNumber;
  String? _e164PhoneNumber;
  bool _isLoading = false;
  bool _codeSent = false;
  bool _isVerifying = false;
  int _resendCount = 0;
  int _remainingSeconds = 300; // 5 minutes
  Timer? _countdownTimer;
  DateTime? _lastResendTime;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _currentPhoneNumber = widget.initialPhoneNumber;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
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

  /// Start countdown timer for code expiration
  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = 300; // Reset to 5 minutes

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  /// Format remaining time as MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Show phone number selection dialog
  Future<void> _showPhoneNumberDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => PhoneNumberValidationDialog(
        initialPhoneNumber: _currentPhoneNumber,
        onValidPhone: (e164) {
          // Dialog will pop automatically
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentPhoneNumber = result;
        _e164PhoneNumber = result;
        _codeSent = false;
        _codeController.clear();
        _resendCount = 0;
        _countdownTimer?.cancel();
      });
    }
  }

  /// Send SMS verification code
  Future<void> _sendVerificationCode() async {
    if (_e164PhoneNumber == null) {
      await _showPhoneNumberDialog();
      if (_e164PhoneNumber == null) return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await EmailOtpService.sendSmsOtpCode(
        phoneNumber: _e164PhoneNumber!,
        purpose: 'two_factor',
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _codeSent = true;
            _resendCount++;
            _lastResendTime = DateTime.now();
          });
          _startCountdown();
          _showSuccessSnackBar('Doğrulama kodu gönderildi');
        } else {
          _showErrorSnackBar(result.message);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SMS gönderme hatası: $e');
      }
      if (mounted) {
        _showErrorSnackBar('SMS gönderilemedi. Lütfen tekrar deneyin.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Verify entered code
  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_e164PhoneNumber == null) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await EmailOtpService.verifySmsOtpCode(
        phoneNumber: _e164PhoneNumber!,
        code: _codeController.text.trim(),
      );

      if (mounted) {
        if (result.isValid) {
          _showSuccessSnackBar('Doğrulama başarılı!');
          widget.onVerificationSuccess?.call();
        } else {
          _showErrorSnackBar(result.message);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Kod doğrulama hatası: $e');
      }
      if (mounted) {
        _showErrorSnackBar('Doğrulama işlemi başarısız oldu');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Resend verification code with rate limiting
  Future<void> _resendCode() async {
    // Rate limiting: prevent excessive requests
    if (_lastResendTime != null) {
      final timeSinceLastResend = DateTime.now().difference(_lastResendTime!);
      if (timeSinceLastResend < const Duration(minutes: 1)) {
        _showErrorSnackBar(
            'Lütfen ${60 - timeSinceLastResend.inSeconds} saniye bekleyin');
        return;
      }
    }

    if (_resendCount >= 3) {
      _showErrorSnackBar('Maksimum yeniden gönderme sayısına ulaştınız');
      return;
    }

    await _sendVerificationCode();
  }

  /// Cancel 2FA verification
  void _cancelVerification() {
    _countdownTimer?.cancel();
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: Text('SMS Doğrulama'),
        onBackPressed: _cancelVerification,
      ),
      body: PageBody(
        scrollable: true,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                    // Header
                    const Icon(
                      Icons.security,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'İki Adımlı Doğrulama',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.getTextOnColoredBackground(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hesabınızı güvence altına almak için SMS ile doğrulama yapın',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeColors.getTextOnColoredBackground(context).withValues(alpha:  0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Phone number selection
                    if (!_codeSent) ...[
                      _buildPhoneSelectionSection(),
                    ] else ...[
                      _buildCodeVerificationSection(),
                    ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSelectionSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telefon Numarası',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SMS doğrulama kodu göndereceğimiz telefon numarasını seçin',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Current phone number display
            if (_currentPhoneNumber != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seçili Numara',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            PhoneNumberValidator.format(_currentPhoneNumber!),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _showPhoneNumberDialog,
                      child: const Text('Değiştir'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showPhoneNumberDialog,
                  icon: const Icon(Icons.phone),
                  label: const Text('Telefon Numarası Seç'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Send code button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendVerificationCode,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Gönderiliyor...' : 'Kod Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeVerificationSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doğrulama Kodu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${PhoneNumberValidator.format(_currentPhoneNumber!)} numarasına gönderilen 6 haneli kodu girin',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Code input field
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Doğrulama Kodu',
                hintText: '123456',
                prefixIcon: const Icon(Icons.pin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: ThemeColors.getInputBackground(context),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              maxLength: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Doğrulama kodunu girin';
                }
                if (value.length != 6) {
                  return 'Kod 6 haneli olmalıdır';
                }
                if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  return 'Sadece rakam girin';
                }
                return null;
              },
              onChanged: (value) {
                // Auto-submit when 6 digits are entered
                if (value.length == 6 && !_isVerifying) {
                  _verifyCode();
                }
              },
            ),
            const SizedBox(height: 16),

            // Countdown timer
            if (_remainingSeconds > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Kod geçerlilik süresi: ${_formatTime(_remainingSeconds)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Doğrulama kodunun süresi doldu',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isVerifying || _remainingSeconds == 0)
                    ? null
                    : _verifyCode,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isVerifying ? 'Doğrulanıyor...' : 'Doğrula'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Resend button
            Center(
              child: TextButton.icon(
                onPressed: (_isLoading || _resendCount >= 3)
                    ? null
                    : _resendCode,
                icon: const Icon(Icons.refresh),
                label: Text(
                  _resendCount > 0
                      ? 'Tekrar Gönder ($_resendCount/3)'
                      : 'Tekrar Gönder',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

            // Change phone number
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _showPhoneNumberDialog,
                child: const Text('Telefon Numarasını Değiştir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}