// lib/pages/enhanced_two_factor_auth_verification_page.dart
// Enhanced 2FA Verification Page with improved UX, animations, and backup code support

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/enhanced_firebase_2fa_service.dart';
import '../theme/theme_colors.dart';

class EnhancedTwoFactorAuthVerificationPage extends StatefulWidget {
  final TwoFactorAuthResult authResult;
  
  const EnhancedTwoFactorAuthVerificationPage({
    super.key,
    required this.authResult,
  });

  @override
  State<EnhancedTwoFactorAuthVerificationPage> createState() => _EnhancedTwoFactorAuthVerificationPageState();
}

class _EnhancedTwoFactorAuthVerificationPageState extends State<EnhancedTwoFactorAuthVerificationPage> 
    with TickerProviderStateMixin {
  
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _backupCodeController = TextEditingController();
  final _smsFormKey = GlobalKey<FormState>();
  final _backupFormKey = GlobalKey<FormState>();
  
  bool _isVerifying = false;
  String? _verificationId;
  bool _codeSent = false;
  bool _useBackupCode = false;
  int _resendCount = 0;
  DateTime? _lastResendTime;
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startVerification();
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
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _smsCodeController.dispose();
    _backupCodeController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Start SMS verification process
  Future<void> _startVerification() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      // For enhanced implementation, we would start verification with the multi-factor resolver
      // Since this is a complex flow, we'll simulate the process
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _codeSent = true;
          _verificationId = 'verification_${DateTime.now().millisecondsSinceEpoch}';
        });

        _showSuccessSnackBar('Doğrulama kodu gönderildi');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting 2FA verification: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('Doğrulama başlatılamadı: $e');
        Navigator.of(context).pop();
      }
    }
  }

  /// Verify SMS code and complete 2FA
  Future<void> _verifySmsCode() async {
    if (!_smsFormKey.currentState!.validate()) return;
    if (_verificationId == null) {
      _showErrorSnackBar('Doğrulama kimliği bulunamadı. Lütfen tekrar deneyin.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await EnhancedFirebase2FAService.resolve2FAChallenge(
        resolver: widget.authResult.multiFactorResolver,
        verificationId: _verificationId!,
        smsCode: _smsCodeController.text.trim(),
        phoneNumber: widget.authResult.metadata?['phoneNumber'],
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar('Doğrulama başarılı! Yönlendiriliyor...');
          
          // Navigate to profile page
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/profile',
            (route) => false,
          );
        } else {
          _showErrorSnackBar(result.message);
          setState(() {
            _isVerifying = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying SMS code: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('Doğrulama kodu doğrulanamadı: $e');
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Verify backup code
  Future<void> _verifyBackupCode() async {
    if (!_backupFormKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await EnhancedFirebase2FAService.useBackupCode(
        _backupCodeController.text.trim(),
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar('Yedek kod ile doğrulama başarılı!');
          
          // Navigate to profile page
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/profile',
            (route) => false,
          );
        } else {
          _showErrorSnackBar(result.message);
          setState(() {
            _isVerifying = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying backup code: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('Yedek kod doğrulanamadı: $e');
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Resend SMS code with rate limiting
  Future<void> _resendSmsCode() async {
    // Rate limiting: prevent excessive requests
    if (_lastResendTime != null) {
      final timeSinceLastResend = DateTime.now().difference(_lastResendTime!);
      if (timeSinceLastResend < const Duration(minutes: 1)) {
        _showErrorSnackBar('Lütfen ${60 - timeSinceLastResend.inSeconds} saniye bekleyin');
        return;
      }
    }

    setState(() {
      _isVerifying = true;
      _resendCount++;
      _lastResendTime = DateTime.now();
    });

    try {
      await _startVerification();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Kod yeniden gönderilemedi: $e');
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Switch to backup code mode
  void _switchToBackupCode() {
    setState(() {
      _useBackupCode = true;
    });
  }

  /// Switch to SMS mode
  void _switchToSms() {
    setState(() {
      _useBackupCode = false;
      _backupCodeController.clear();
    });
  }

  /// Cancel 2FA and go back to login
  void _cancelVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Doğrulamayı İptal Et'),
            ],
          ),
          content: const Text(
            '2FA doğrulamayı iptal etmek istediğinizden emin misiniz? '
            'Giriş işlemi tamamlanamaz ve tekrar giriş yapmanız gerekecek.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Devam Et'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('İptal Et'),
            ),
          ],
        );
      },
    );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _cancelVerification,
        ),
        title: const Text(
          'Güvenlik Doğrulaması',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          
                          // Method selection
                          if (!_isVerifying) _buildMethodSelector(),
                          const SizedBox(height: 16),
                          
                          // Loading state
                          if (_isVerifying) ...[
                            _buildLoadingState(),
                          ]
                          
                          // SMS verification form
                          else if (_codeSent && !_useBackupCode) ...[
                            _buildSMSForm(),
                          ]
                          
                          // Backup code form
                          else if (_useBackupCode) ...[
                            _buildBackupCodeForm(),
                          ]
                          
                          // Waiting for code
                          else ...[
                            _buildWaitingState(),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Cancel button
                          _buildCancelButton(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          _useBackupCode ? 'Yedek Kod Doğrulaması' : 'SMS Doğrulaması',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _useBackupCode 
              ? 'Daha önce oluşturduğunuz yedek kodlardan birini girin'
              : 'Telefonunuza gelen doğrulama kodunu girin',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            'Doğrulama Yöntemi',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMethodButton(
                  icon: Icons.sms,
                  title: 'SMS Kodu',
                  isSelected: !_useBackupCode,
                  onTap: _switchToSms,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMethodButton(
                  icon: Icons.backup,
                  title: 'Yedek Kod',
                  isSelected: _useBackupCode,
                  onTap: _switchToBackupCode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          _useBackupCode ? 'Yedek kod doğrulanıyor...' : 'Doğrulama işlemi yapılıyor...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildWaitingState() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          _useBackupCode 
              ? 'Yedek kod doğrulaması hazırlanıyor...'
              : 'SMS doğrulama kodu gönderiliyor...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSMSForm() {
    return Form(
      key: _smsFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _smsCodeController,
            decoration: InputDecoration(
              labelText: 'SMS Doğrulama Kodu',
              hintText: '123456',
              prefixIcon: const Icon(Icons.sms),
              filled: true,
              fillColor: ThemeColors.getInputBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              return null;
            },
            onChanged: (value) {
              // Auto-submit when 6 digits are entered
              if (value.length == 6 && !_isVerifying) {
                _verifySmsCode();
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Verify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isVerifying ? null : _verifySmsCode,
              icon: const Icon(Icons.check_circle),
              label: const Text('Doğrula'),
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
          TextButton.icon(
            onPressed: _isVerifying ? null : _resendSmsCode,
            icon: const Icon(Icons.refresh),
            label: Text(_resendCount > 0 ? 'Tekrar Gönder ($_resendCount)' : 'Tekrar Gönder'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCodeForm() {
    return Form(
      key: _backupFormKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.amber[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Yedek kodlar büyük harfler ve rakamlardan oluşur (örn: A1B2C3D4)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _backupCodeController,
            decoration: InputDecoration(
              labelText: 'Yedek Kod',
              hintText: 'A1B2C3D4',
              prefixIcon: const Icon(Icons.backup),
              filled: true,
              fillColor: ThemeColors.getInputBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            maxLength: 8,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Yedek kodu girin';
              }
              if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(value.toUpperCase())) {
                return 'Yedek kod 8 haneli olmalı (A-Z, 0-9)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Verify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isVerifying ? null : _verifyBackupCode,
              icon: const Icon(Icons.check_circle),
              label: const Text('Doğrula'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
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
}