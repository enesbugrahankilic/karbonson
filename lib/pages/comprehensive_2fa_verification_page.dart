// lib/pages/comprehensive_2fa_verification_page.dart
// Comprehensive Two-Factor Authentication Verification Page with multi-method support
// Implements robust error handling, real-time validation, and responsive design

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../services/comprehensive_2fa_service.dart';
import '../theme/theme_colors.dart';

/// Comprehensive 2FA verification page supporting multiple verification methods
class Comprehensive2FAVerificationPage extends StatefulWidget {
  final VerificationMethod initialMethod;
  final String? phoneNumber;
  final String? totpSecret;
  final List<VerificationMethod> availableMethods;
  final VoidCallback? onVerificationSuccess;
  final VoidCallback? onCancel;

  const Comprehensive2FAVerificationPage({
    super.key,
    required this.initialMethod,
    required this.availableMethods,
    this.phoneNumber,
    this.totpSecret,
    this.onVerificationSuccess,
    this.onCancel,
  });

  @override
  State<Comprehensive2FAVerificationPage> createState() =>
      _Comprehensive2FAVerificationPageState();
}

class _Comprehensive2FAVerificationPageState
    extends State<Comprehensive2FAVerificationPage>
    with TickerProviderStateMixin {
  // Form controllers and keys
  final Map<VerificationMethod, TextEditingController> _controllers = {};
  final Map<VerificationMethod, GlobalKey<FormState>> _formKeys = {};

  // State management
  VerificationMethod _currentMethod;
  VerificationResult? _verificationResult;
  bool _isVerifying = false;
  bool _codeSent = false;
  String? _currentSessionId;
  int _timeLeft = 0;
  Timer? _countdownTimer;
  Timer? _autoSubmitTimer;

  // UI state
  bool _showAdvancedOptions = false;
  String? _lastErrorMessage;
  bool _showPassword = false;
  FocusNode? _currentFocusNode;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  _Comprehensive2FAVerificationPageState()
      : _currentMethod = VerificationMethod.sms;

  @override
  void initState() {
    super.initState();
    _currentMethod = widget.initialMethod;
    _initializeControllers();
    _initializeAnimations();
    _startVerification();

    // Initialize service
    Comprehensive2FAService.initialize();
  }

  void _initializeControllers() {
    for (final method in VerificationMethod.values) {
      _controllers[method] = TextEditingController();
      _formKeys[method] = GlobalKey<FormState>();
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // Cleanup controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    // Cleanup timers
    _countdownTimer?.cancel();
    _autoSubmitTimer?.cancel();

    // Cleanup animations
    _fadeController.dispose();
    _pulseController.dispose();
    _slideController.dispose();

    super.dispose();
  }

  /// Announce message for screen readers (accessibility)
  void _announceForAccessibility(String message) {
    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  /// Start verification process for current method
  Future<void> _startVerification() async {
    if (!widget.availableMethods.contains(_currentMethod)) {
      _showError('Bu doğrulama yöntemi mevcut değil');
      return;
    }

    setState(() {
      _isVerifying = true;
      _codeSent = false;
      _lastErrorMessage = null;
    });

    try {
      _announceForAccessibility(
          '${_currentMethod.displayName} doğrulaması başlatılıyor');

      final result = await Comprehensive2FAService.startVerification(
        method: _currentMethod,
        phoneNumber: widget.phoneNumber,
        totpSecret: widget.totpSecret,
      );

      if (mounted) {
        setState(() {
          _verificationResult = result;
          _isVerifying = false;
          _codeSent = result.isSuccess;
          _currentSessionId = result.sessionId;
        });

        if (result.isSuccess) {
          _announceForAccessibility(result.TurkishMessage);
          _showSuccess(result.TurkishMessage);
          _startCountdown();
          _setupAutoSubmit();
        } else {
          _announceForAccessibility('Hata: ${result.TurkishMessage}');
          _showError(result.TurkishMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _lastErrorMessage = 'Doğrulama başlatılamadı: $e';
        });
        _announceForAccessibility('Hata: Doğrulama başlatılamadı');
      }
    }
  }

  /// Verify code for current method
  Future<void> _verifyCode() async {
    if (_currentSessionId == null || !_codeSent) {
      _showError('Doğrulama oturumu bulunamadı');
      return;
    }

    if (!_formKeys[_currentMethod]!.currentState!.validate()) {
      _announceForAccessibility('Lütfen geçerli bir kod girin');
      return;
    }

    setState(() {
      _isVerifying = true;
      _lastErrorMessage = null;
    });

    _announceForAccessibility('Kod doğrulanıyor');

    try {
      final code = _controllers[_currentMethod]!.text.trim();

      final result = await Comprehensive2FAService.verifyCode(
        sessionId: _currentSessionId!,
        code: code,
        method: _currentMethod,
      );

      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verificationResult = result;
        });

        if (result.isSuccess) {
          _announceForAccessibility('Doğrulama başarılı');
          _showSuccess('Doğrulama başarılı');
          await Future.delayed(const Duration(milliseconds: 1500));
          widget.onVerificationSuccess?.call();
        } else {
          _announceForAccessibility('Hata: ${result.TurkishMessage}');
          _showError(result.TurkishMessage);

          // Clear input on error
          _controllers[_currentMethod]!.clear();
          _currentFocusNode?.requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _lastErrorMessage = 'Doğrulama hatası: $e';
        });
        _announceForAccessibility('Hata: Doğrulama hatası');
      }
    }
  }

  /// Resend verification code
  Future<void> _resendCode() async {
    if (_currentSessionId == null) {
      _showError('Oturum bulunamadı');
      return;
    }

    setState(() {
      _isVerifying = true;
      _lastErrorMessage = null;
    });

    _announceForAccessibility('Kod yeniden gönderiliyor');

    try {
      final result =
          await Comprehensive2FAService.resendCode(_currentSessionId!);

      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verificationResult = result;
        });

        if (result.isSuccess) {
          _announceForAccessibility(result.TurkishMessage);
          _showSuccess(result.TurkishMessage);
          _startCountdown();
        } else {
          _announceForAccessibility('Hata: ${result.TurkishMessage}');
          _showError(result.TurkishMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _lastErrorMessage = 'Kod yeniden gönderilemedi: $e';
        });
        _announceForAccessibility('Hata: Kod yeniden gönderilemedi');
      }
    }
  }

  /// Switch verification method
  Future<void> _switchMethod(VerificationMethod method) async {
    if (method == _currentMethod || !widget.availableMethods.contains(method)) {
      return;
    }

    // Clear current inputs
    _controllers[_currentMethod]?.clear();

    setState(() {
      _currentMethod = method;
      _codeSent = false;
      _verificationResult = null;
      _currentSessionId = null;
      _lastErrorMessage = null;
    });

    _announceForAccessibility('${method.displayName} yöntemine geçildi');
    _slideController.reset();
    _slideController.forward();

    // Start new verification
    await _startVerification();
  }

  /// Start countdown timer for code expiration
  void _startCountdown() {
    _countdownTimer?.cancel();

    if (_verificationResult?.expiresAt == null) {
      // For methods without expiration (like hardware token)
      return;
    }

    _timeLeft = ((_verificationResult!.expiresAt! -
                DateTime.now().millisecondsSinceEpoch) /
            1000)
        .ceil();

    if (_timeLeft <= 0) {
      _showError('Kod süresi doldu');
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft--;
        });

        if (_timeLeft <= 0) {
          timer.cancel();
          _announceForAccessibility('Kodun süresi doldu');
          _showError('Kodun süresi doldu. Lütfen yeni bir kod isteyin.');
          _codeSent = false;
        } else if (_timeLeft <= 30) {
          // Announce when less than 30 seconds remain
          _announceForAccessibility(
              'Kod ${_timeLeft} saniye sonra süresi dolacak');
        }
      }
    });
  }

  /// Setup auto-submit for SMS codes
  void _setupAutoSubmit() {
    _autoSubmitTimer?.cancel();

    if (_currentMethod != VerificationMethod.sms) return;

    _autoSubmitTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _codeSent) {
        final controller = _controllers[_currentMethod]!;
        if (controller.text.length == 6) {
          timer.cancel();
          _verifyCode();
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Cancel verification process
  void _cancelVerification() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  /// Show success message with animation
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message with accessibility
  void _showError(String message) {
    setState(() {
      _lastErrorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Format time remaining
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _cancelVerification,
          tooltip: 'Geri',
        ),
        title: const Text(
          'İki Faktörlü Doğrulama',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
            tooltip: 'Yardım',
          ),
        ],
      ),
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
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_slideController),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 20),
                      _buildMethodSelector(),
                      if (widget.availableMethods.length > 1) ...[
                        const SizedBox(height: 16),
                        _buildMethodSwitcher(),
                      ],
                      const SizedBox(height: 20),
                      _buildVerificationCard(),
                      const SizedBox(height: 16),
                      _buildProgressIndicator(),
                      const SizedBox(height: 16),
                      _buildSecurityInfo(),
                      const SizedBox(height: 16),
                      _buildCancelButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseController.value * 0.05 + 0.95,
                  child: Icon(
                    _getMethodIcon(_currentMethod),
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              '${_currentMethod.displayName} Doğrulama',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getMethodDescription(_currentMethod),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doğrulama Yöntemi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...widget.availableMethods
                .map((method) => RadioListTile<VerificationMethod>(
                      value: method,
                      groupValue: _currentMethod,
                      onChanged: method != _currentMethod
                          ? (value) => _switchMethod(value!)
                          : null,
                      title: Text(method.displayName),
                      subtitle: Text(_getMethodDescription(method)),
                      secondary: Icon(_getMethodIcon(method)),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.trailing,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSwitcher() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text('Diğer Yöntemler'),
        leading: const Icon(Icons.more_horiz),
        onExpansionChanged: (expanded) {
          setState(() {
            _showAdvancedOptions = expanded;
          });
        },
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: widget.availableMethods
                  .where((method) => method != _currentMethod)
                  .map((method) {
                return ListTile(
                  leading: Icon(_getMethodIcon(method)),
                  title: Text(method.displayName),
                  subtitle: Text(_getMethodDescription(method)),
                  trailing: ElevatedButton(
                    onPressed: () => _switchMethod(method),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Kullan'),
                  ),
                  onTap: () => _switchMethod(method),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading state
            if (_isVerifying) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('İşlem yapılıyor...'),
                  ],
                ),
              ),
            ]

            // Code input form
            else if (_codeSent) ...[
              _buildCodeInput(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 16),
              _buildResendOptions(),
            ]

            // Verification needed message
            else ...[
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Doğrulama bekleniyor...',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ],

            // Error message
            if (_lastErrorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastErrorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    final method = _currentMethod;
    final controller = _controllers[method]!;
    final focusNode = FocusNode();
    _currentFocusNode = focusNode;

    return Form(
      key: _formKeys[method],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input field
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: _getInputLabel(method),
              hintText: _getInputHint(method),
              prefixIcon: Icon(_getMethodIcon(method)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentMethod == VerificationMethod.backupCode) ...[
                    IconButton(
                      icon: Icon(_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ],
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clear(),
                    ),
                ],
              ),
              filled: true,
              fillColor: ThemeColors.getInputBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorMaxLines: 2,
            ),
            keyboardType: _getKeyboardType(method),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getFontSize(method),
              letterSpacing: method == VerificationMethod.totp ? 2 : 1,
              fontWeight: FontWeight.bold,
            ),
            maxLength: _getMaxLength(method),
            obscureText:
                method == VerificationMethod.backupCode && !_showPassword,
            inputFormatters: _getInputFormatters(method),
            validator: (value) => _validateInput(method, value),
            onChanged: (value) {
              setState(() {
                // Trigger UI updates for real-time validation
              });

              // Auto-submit for SMS after 6 digits
              if (method == VerificationMethod.sms && value.length == 6) {
                _verifyCode();
              }
            },
            onFieldSubmitted: (value) {
              if (method == VerificationMethod.sms && value.length == 6) {
                _verifyCode();
              }
            },
          ),

          // Character counter and validation
          if (method == VerificationMethod.totp) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kalan süre: ${_formatTime(_timeLeft)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _timeLeft <= 30 ? Colors.orange : Colors.grey,
                    fontWeight:
                        _timeLeft <= 30 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (controller.text.length == 6)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isVerifying ? null : _verifyCode,
            icon: _isVerifying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
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
      ],
    );
  }

  Widget _buildResendOptions() {
    final canResend = _currentMethod == VerificationMethod.sms && _timeLeft > 0;

    return Column(
      children: [
        if (_currentMethod == VerificationMethod.totp) ...[
          Text(
            'Bu kod 30 saniye sonra değişecek',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ] else if (canResend) ...[
          Text(
            'Yeni kod istemek için ${_formatTime(_timeLeft)} bekleyin',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ] else if (_currentMethod == VerificationMethod.sms) ...[
          Center(
            child: TextButton.icon(
              onPressed: _isVerifying ? null : _resendCode,
              icon: const Icon(Icons.refresh),
              label: const Text('Kodu Yeniden Gönder'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator() {
    if (_verificationResult?.expiresAt == null) {
      return const SizedBox.shrink();
    }

    final progress = (_timeLeft /
            ((_verificationResult!.expiresAt! -
                    (DateTime.now().millisecondsSinceEpoch -
                        (_timeLeft * 1000))) /
                1000))
        .clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _timeLeft <= 30 ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Süre: ${_formatTime(_timeLeft)}',
              style: TextStyle(
                fontSize: 12,
                color: _timeLeft <= 30 ? Colors.orange : Colors.grey[700],
                fontWeight:
                    _timeLeft <= 30 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Güvenlik Bilgisi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getSecurityInfo(_currentMethod),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: _isVerifying ? null : _cancelVerification,
      child: Text(
        'Doğrulamayı İptal Et',
        style: TextStyle(
          color: Colors.red[600],
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper methods

  IconData _getMethodIcon(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
        return Icons.sms;
      case VerificationMethod.totp:
        return Icons.security; // Use security icon instead of totp
      case VerificationMethod.hardwareToken:
        return Icons.fingerprint;
      case VerificationMethod.backupCode:
        return Icons.backup;
    }
  }

  String _getMethodDescription(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
        return 'Telefonunuza SMS kodu gönderilir';
      case VerificationMethod.totp:
        return 'Authenticator uygulamasından 6 haneli kod';
      case VerificationMethod.hardwareToken:
        return 'Biometric doğrulama (parmak izi/yüz)';
      case VerificationMethod.backupCode:
        return 'Daha önce oluşturulan yedek kodlar';
    }
  }

  String _getInputLabel(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
        return 'SMS Kodu';
      case VerificationMethod.totp:
        return 'Authenticator Kodu';
      case VerificationMethod.hardwareToken:
        return 'Biometric Doğrulama';
      case VerificationMethod.backupCode:
        return 'Yedek Kod';
    }
  }

  String _getInputHint(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
        return '123456';
      case VerificationMethod.totp:
        return '123456';
      case VerificationMethod.hardwareToken:
        return 'Doğrulama gerekli';
      case VerificationMethod.backupCode:
        return 'ABC12345';
    }
  }

  TextInputType _getKeyboardType(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.hardwareToken:
        return TextInputType.none;
      default:
        return TextInputType.number;
    }
  }

  int _getMaxLength(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
      case VerificationMethod.totp:
        return 6;
      case VerificationMethod.backupCode:
        return 8;
      case VerificationMethod.hardwareToken:
        return 0;
    }
  }

  double _getFontSize(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
      case VerificationMethod.totp:
        return 24;
      case VerificationMethod.backupCode:
        return 18;
      case VerificationMethod.hardwareToken:
        return 16;
    }
  }

  List<TextInputFormatter>? _getInputFormatters(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
      case VerificationMethod.totp:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ];
      case VerificationMethod.backupCode:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(8),
        ];
      case VerificationMethod.hardwareToken:
        return null;
    }
  }

  String? _validateInput(VerificationMethod method, String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan gereklidir';
    }

    switch (method) {
      case VerificationMethod.sms:
      case VerificationMethod.totp:
        if (value.length != 6) {
          return 'Kod 6 haneli olmalıdır';
        }
        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
          return 'Sadece rakam kullanın';
        }
        break;
      case VerificationMethod.backupCode:
        if (value.length != 8) {
          return 'Yedek kod 8 haneli olmalıdır';
        }
        if (!RegExp(r'^[A-Za-z0-9]{8}$').hasMatch(value)) {
          return 'Sadece harf ve rakam kullanın';
        }
        break;
      case VerificationMethod.hardwareToken:
        // Hardware token doesn't require input validation
        break;
    }

    return null;
  }

  String _getSecurityInfo(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.sms:
        return '• SMS kodlarınız 5 dakika süresince geçerlidir\n• Kodunuzu kimseyle paylaşmayın\n• İnternet bağlantısı gereklidir';
      case VerificationMethod.totp:
        return '• Authenticator kodları her 30 saniyede değişir\n• Offline çalışır, internet gerekmez\n• Uygulama kaybı durumunda yedek kodlarınızı kullanın';
      case VerificationMethod.hardwareToken:
        return '• Biometric doğrulama cihazınıza kaydedilir\n• En güvenli doğrulama yöntemidir\n• Offline çalışır, internet gerekmez';
      case VerificationMethod.backupCode:
        return '• Yedek kodlar bir kez kullanılabilir\n• Güvenli bir yerde saklayın\n• Sadece acil durumlarda kullanın';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('2FA Doğrulama Yardım'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doğrulama Yöntemleri:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('SMS: Telefonunuza 6 haneli kod gönderilir'),
              Text('TOTP: Authenticator uygulamasından kod alın'),
              Text('Hardware Token: Biometric doğrulama kullan'),
              Text('Backup Code: Daha önce oluşturulan kodları kullan'),
              SizedBox(height: 16),
              Text(
                'Sorun Giderme:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Kod gelmediyse spam klasörünü kontrol edin'),
              Text('• Yanlış kod hatası alıyorsanız tekrar deneyin'),
              Text('• Kodun süresi dolmuşsa yeni kod isteyin'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
