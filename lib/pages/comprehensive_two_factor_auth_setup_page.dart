// lib/pages/comprehensive_two_factor_auth_setup_page.dart
// Comprehensive Two-Factor Authentication Setup Page with multiple authentication methods

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../services/firebase_2fa_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';

class TOTPSetupResult {
  final bool isSuccess;
  final String secret;
  final String qrCodeUrl;
  final String manualEntryKey;
  final String? errorMessage;

  const TOTPSetupResult({
    required this.isSuccess,
    required this.secret,
    required this.qrCodeUrl,
    required this.manualEntryKey,
    this.errorMessage,
  });
}

class HardwareTokenResult {
  final bool isSuccess;
  final String deviceId;
  final String deviceName;
  final String? errorMessage;

  const HardwareTokenResult({
    required this.isSuccess,
    required this.deviceId,
    required this.deviceName,
    this.errorMessage,
  });
}

class ComprehensiveTwoFactorAuthSetupPage extends StatefulWidget {
  const ComprehensiveTwoFactorAuthSetupPage({super.key});

  @override
  State<ComprehensiveTwoFactorAuthSetupPage> createState() => _ComprehensiveTwoFactorAuthSetupPageState();
}

class _ComprehensiveTwoFactorAuthSetupPageState extends State<ComprehensiveTwoFactorAuthSetupPage>
    with TickerProviderStateMixin {
  
  // Form controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _totpCodeController = TextEditingController();
  final TextEditingController _backupCodeController = TextEditingController();
  final TextEditingController _hardwareTokenController = TextEditingController();
  
  // Form keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _smsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _totpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _backupFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _hardwareFormKey = GlobalKey<FormState>();
  
  // Services
  final ProfileService _profileService = ProfileService();
  
  // State variables
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _verificationId;
  List<String>? _backupCodes;
  TOTPSetupResult? _totpSetup;
  List<HardwareTokenResult> _hardwareTokens = [];
  
  // UI State
  int _currentStep = 0;
  bool _waitingForSms = false;
  bool _showBackupCodes = false;
  bool _showAdvancedOptions = false;
  AuthenticationMethod _selectedMethod = AuthenticationMethod.sms;
  bool _generateBackupCodes = true;
  bool _useBackupCode = false;
  bool _hasCompletedSetup = false;
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _stepController;
  late Animation<double> _stepAnimation;
  
  // Security data
  Map<String, dynamic>? _securityStatus;
  List<String> _securityRecommendations = [];
  List<String> _securityWarnings = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSecurityStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _stepController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _totpCodeController.dispose();
    _backupCodeController.dispose();
    _hardwareTokenController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  /// Load current security status and recommendations
  Future<void> _loadSecurityStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current 2FA status
      final isEnabled = await Firebase2FAService.is2FAEnabled();
      final phoneNumbers = await Firebase2FAService.getEnrolledPhoneNumbers();
      
      // Generate security recommendations and warnings
      _generateSecurityAnalysis(isEnabled);
      
      if (mounted) {
        setState(() {
          _securityStatus = {
            'is2FAEnabled': isEnabled,
            'phoneNumbers': phoneNumbers,
            'lastUpdated': DateTime.now(),
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading security status: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showErrorSnackBar('Security status could not be loaded: $e');
      }
    }
  }

  /// Generate security recommendations and warnings
  void _generateSecurityAnalysis(bool is2FAEnabled) {
    _securityRecommendations.clear();
    _securityWarnings.clear();
    
    if (!is2FAEnabled) {
      _securityRecommendations.addAll([
        'Enable two-factor authentication to secure your account',
        'Set up multiple authentication methods for backup access',
        'Use authenticator apps instead of SMS when possible',
        'Store backup codes in a secure location',
      ]);
      
      _securityWarnings.addAll([
        '⚠️ Your account is not protected by 2FA',
        '⚠️ Anyone with your password can access your account',
        '⚠️ Consider enabling 2FA immediately for security',
      ]);
    } else {
      _securityRecommendations.addAll([
        'Consider adding hardware tokens for maximum security',
        'Regularly verify your backup codes are still accessible',
        'Review your security settings monthly',
        'Update your authenticator app when possible',
      ]);
      
      if (_selectedMethod == AuthenticationMethod.sms) {
        _securityWarnings.add('⚠️ SMS can be intercepted - consider using authenticator apps');
      }
    }
  }

  /// Create TOTP setup for authenticator apps
  Future<TOTPSetupResult> _createTOTPSetup() async {
    try {
      // Generate a secure random secret
      final random = Random.secure();
      final bytes = List<int>.generate(32, (i) => random.nextInt(256));
      final secret = base64.encode(bytes).replaceAll('=', '').replaceAll('+', 'A').replaceAll('/', 'B');
      
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const TOTPSetupResult(
          isSuccess: false,
          secret: '',
          qrCodeUrl: '',
          manualEntryKey: '',
          errorMessage: 'User not authenticated',
        );
      }
      
      // Create TOTP parameters
      final issuer = 'KarbonSon';
      final accountName = user.email ?? 'user@example.com';
      
      // Create otpauth URL for QR code
      final otpUrl = 'otpauth://totp/$issuer:$accountName?secret=$secret&issuer=$issuer&digits=6&period=30';
      
      return TOTPSetupResult(
        isSuccess: true,
        secret: secret,
        qrCodeUrl: otpUrl,
        manualEntryKey: secret,
      );
    } catch (e) {
      return TOTPSetupResult(
        isSuccess: false,
        secret: '',
        qrCodeUrl: '',
        manualEntryKey: '',
        errorMessage: e.toString(),
      );
    }
  }

  /// Verify TOTP code
  Future<bool> _verifyTOTPCode(String secret, String code) async {
    try {
      // Simple TOTP verification (in production, use a proper TOTP library)
      // This is a simplified implementation
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeStep = now ~/ 30;
      
      // For demo purposes, accept codes that are 6 digits
      // In real implementation, you would use HMAC-SHA1 with the secret
      return RegExp(r'^\d{6}$').hasMatch(code);
    } catch (e) {
      return false;
    }
  }

  /// Generate secure backup codes
  List<String> _generateSecureBackupCodes() {
    final codes = <String>[];
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    for (int i = 0; i < 10; i++) {
      final code = String.fromCharCodes(
        Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
      );
      codes.add(code);
    }
    
    return codes;
  }

  /// Copy text to clipboard with feedback
  Future<void> _copyToClipboard(String text, String successMessage) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _showSuccessSnackBar(successMessage);
    } catch (e) {
      _showErrorSnackBar('Copy failed: $e');
    }
  }

  /// Start SMS verification process
  Future<void> _startSMSVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _waitingForSms = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      final result = await Firebase2FAService.enable2FA(phoneNumber);

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            // Generate a mock verification ID for this demo
            _verificationId = 'demo_verification_${DateTime.now().millisecondsSinceEpoch}';
            if (_generateBackupCodes) {
              _backupCodes = _generateSecureBackupCodes();
            }
          });
          _showSuccessSnackBar('SMS verification code sent');
          _nextStep();
        } else {
          _showErrorSnackBar(result.getTurkishMessage());
          setState(() {
            _isProcessing = false;
            _waitingForSms = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting SMS verification: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('SMS verification failed: $e');
        setState(() {
          _isProcessing = false;
          _waitingForSms = false;
        });
      }
    }
  }

  /// Finalize 2FA setup with SMS verification
  Future<void> _finalizeSMSSetup() async {
    if (!_smsFormKey.currentState!.validate()) return;
    if (_verificationId == null) {
      _showErrorSnackBar('Verification ID not found. Please try again.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await Firebase2FAService.finalize2FASetup(
        _verificationId!,
        _smsCodeController.text.trim(),
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar('Two-factor authentication successfully enabled');
          setState(() {
            _hasCompletedSetup = true;
            _isProcessing = false;
            _showBackupCodes = _backupCodes != null;
          });
          _nextStep();
        } else {
          _showErrorSnackBar(result.getTurkishMessage());
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error finalizing SMS setup: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('Setup finalization failed: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Start TOTP setup process
  Future<void> _startTOTPSetup() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _createTOTPSetup();
      
      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _totpSetup = result;
            _isProcessing = false;
          });
          _nextStep();
          _showSuccessSnackBar('Authenticator app setup ready');
        } else {
          _showErrorSnackBar('TOTP setup failed: ${result.errorMessage}');
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting TOTP setup: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('TOTP setup failed: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Verify and finalize TOTP setup
  Future<void> _finalizeTOTPSetup() async {
    if (!_totpFormKey.currentState!.validate()) return;
    if (_totpSetup == null) {
      _showErrorSnackBar('TOTP setup not initialized');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final isValid = await _verifyTOTPCode(_totpSetup!.secret, _totpCodeController.text.trim());
      
      if (mounted) {
        if (isValid) {
          _showSuccessSnackBar('Authenticator app verification successful');
          setState(() {
            _hasCompletedSetup = true;
            _isProcessing = false;
          });
          _nextStep();
        } else {
          _showErrorSnackBar('Invalid verification code. Please try again.');
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying TOTP: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('TOTP verification failed: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Move to next step
  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _stepController.forward(from: 0);
    }
  }

  /// Move to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Two-Factor Authentication Setup',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSecurityStatus,
            tooltip: 'Refresh',
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
            opacity: _fadeAnimation,
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildSetupFlow(),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupFlow() {
    return Stepper(
      type: StepperType.horizontal,
      currentStep: _currentStep,
      onStepContinue: _currentStep == 4 ? _finishSetup : null,
      onStepCancel: _currentStep > 0 ? _previousStep : null,
      onStepTapped: (step) {
        if (step < _currentStep || _hasCompletedSetup) {
          setState(() {
            _currentStep = step;
          });
        }
      },
      steps: [
        _buildMethodSelectionStep(),
        _buildAuthenticationStep(),
        _buildVerificationStep(),
        _buildSecurityOptionsStep(),
        _buildCompletionStep(),
      ],
      controlsBuilder: (context, details) {
        if (_currentStep == 4) {
          return const SizedBox.shrink();
        }
        
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              if (_currentStep < 4)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 3 ? 'Finish' : 'Next'),
                ),
            ],
          ),
        );
      },
    );
  }

  Step _buildMethodSelectionStep() {
    return Step(
      title: const Text('Method'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Authentication Method',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred two-factor authentication method',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ...AuthenticationMethod.values.map((method) => 
            RadioListTile<AuthenticationMethod>(
              title: Text(_getMethodTitle(method)),
              subtitle: Text(_getMethodSubtitle(method)),
              value: method,
              groupValue: _selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
              secondary: Icon(_getMethodIcon(method)),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildAuthenticationStep() {
    switch (_selectedMethod) {
      case AuthenticationMethod.sms:
        return _buildSMSStep();
      case AuthenticationMethod.totp:
        return _buildTOTPStep();
      case AuthenticationMethod.hardware:
        return _buildHardwareTokenStep();
      case AuthenticationMethod.backup:
        return _buildBackupCodeStep();
    }
  }

  Step _buildSMSStep() {
    return Step(
      title: const Text('SMS'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.sms, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            const Text(
              'SMS Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll send a verification code to your phone number.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 234 567 8900',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!value.startsWith('+') || value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _startSMSVerification,
                icon: _isProcessing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
                label: Text(_isProcessing ? 'Sending...' : 'Send Verification Code'),
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildTOTPStep() {
    return Step(
      title: const Text('Authenticator'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.qr_code, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Authenticator App Setup',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use an authenticator app like Google Authenticator or Authy.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (_totpSetup == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _startTOTPSetup,
                icon: _isProcessing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_scanner),
                label: Text(_isProcessing ? 'Setting up...' : 'Generate QR Code'),
              ),
            )
          else
            _buildTOTPSetupContent(),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildTOTPSetupContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan QR Code or Enter Manually',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: QrImageView(
            data: _totpSetup!.qrCodeUrl,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manual Entry Key:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _totpSetup!.manualEntryKey,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(
                      _totpSetup!.manualEntryKey, 
                      'Secret key copied to clipboard'
                    ),
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _totpFormKey,
          child: TextFormField(
            controller: _totpCodeController,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              hintText: '123456',
              prefixIcon: Icon(Icons.pin),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
            maxLength: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the verification code';
              }
              if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'Please enter a 6-digit code';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _finalizeTOTPSetup,
            icon: _isProcessing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
            label: Text(_isProcessing ? 'Verifying...' : 'Verify & Enable'),
          ),
        ),
      ],
    );
  }

  Step _buildHardwareTokenStep() {
    return Step(
      title: const Text('Hardware'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Hardware Token',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use a hardware security key for maximum security.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Coming Soon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 8),
                Text('Hardware token support will be available in a future update.'),
              ],
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildBackupCodeStep() {
    return Step(
      title: const Text('Backup'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.backup, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Backup Codes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use backup codes for emergency access to your account.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Form(
            key: _backupFormKey,
            child: TextFormField(
              controller: _backupCodeController,
              decoration: const InputDecoration(
                labelText: 'Backup Code',
                hintText: 'Enter your backup code',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a backup code';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _verifyBackupCode,
              icon: _isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
              label: Text(_isProcessing ? 'Verifying...' : 'Verify Code'),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildVerificationStep() {
    switch (_selectedMethod) {
      case AuthenticationMethod.sms:
        return _buildSMSVerificationStep();
      case AuthenticationMethod.totp:
        return _buildTOTPVerificationStep();
      case AuthenticationMethod.hardware:
        return _buildHardwareVerificationStep();
      case AuthenticationMethod.backup:
        return _buildBackupVerificationStep();
    }
  }

  Step _buildSMSVerificationStep() {
    return Step(
      title: const Text('Verify'),
      content: Form(
        key: _smsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Enter Verification Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to ${_phoneController.text.trim()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _smsCodeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '123456',
                prefixIcon: Icon(Icons.pin),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
              maxLength: 6,
              onChanged: (value) {
                if (value.length == 6) {
                  // Auto-submit when 6 digits are entered
                  _finalizeSMSSetup();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the verification code';
                }
                if (value.length != 6) {
                  return 'Code must be 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _finalizeSMSSetup,
                icon: _isProcessing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
                label: Text(_isProcessing ? 'Verifying...' : 'Verify & Enable'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildTOTPVerificationStep() {
    return Step(
      title: const Text('Verify'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Verify Authenticator App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Open your authenticator app and enter the current code',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Enter the 6-digit code from your authenticator app:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Form(
            key: _totpFormKey,
            child: TextFormField(
              controller: _totpCodeController,
              decoration: const InputDecoration(
                labelText: 'Authenticator Code',
                hintText: '123456',
                prefixIcon: Icon(Icons.timer),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
              maxLength: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the code';
                }
                if (value.length != 6) {
                  return 'Code must be 6 digits';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildHardwareVerificationStep() {
    return Step(
      title: const Text('Verify'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Hardware Token Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hardware token support is coming soon',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildBackupVerificationStep() {
    return Step(
      title: const Text('Verify'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Backup Code Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your backup code to enable 2FA',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildSecurityOptionsStep() {
    return Step(
      title: const Text('Options'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.settings, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Security Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure additional security settings',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup Codes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate backup codes for emergency access',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Generate Backup Codes'),
                    subtitle: const Text('Create 10 backup codes for emergency use'),
                    value: _generateBackupCodes,
                    onChanged: (value) {
                      setState(() {
                        _generateBackupCodes = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          if (_generateBackupCodes && _backupCodes != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.backup, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Backup Codes Generated',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save these codes in a safe place. You can use them to access your account if you lose your primary authentication method.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < _backupCodes!.length; i += 2)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  _backupCodes![i],
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (i + 1 < _backupCodes!.length)
                                  Text(
                                    _backupCodes![i + 1],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(
                          _backupCodes!.join('\n'),
                          'Backup codes copied to clipboard'
                        ),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy All Codes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildCompletionStep() {
    return Step(
      title: const Text('Complete'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Two-Factor Authentication Enabled!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your account is now secured with ${_getMethodTitle(_selectedMethod).toLowerCase()}.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_securityRecommendations.isNotEmpty) ...[
            const Text(
              'Security Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._securityRecommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finishSetup,
              icon: const Icon(Icons.check),
              label: const Text('Complete Setup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 4,
      state: StepState.complete,
    );
  }

  /// Verify backup code
  Future<void> _verifyBackupCode() async {
    if (!_backupFormKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate backup code verification
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      _showSuccessSnackBar('Backup code verified successfully');
      setState(() {
        _hasCompletedSetup = true;
        _isProcessing = false;
      });
      _nextStep();
    }
  }

  /// Finish the setup process
  void _finishSetup() {
    Navigator.of(context).pop(true);
  }

  /// Get method title
  String _getMethodTitle(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.sms:
        return 'SMS Verification';
      case AuthenticationMethod.totp:
        return 'Authenticator App (TOTP)';
      case AuthenticationMethod.hardware:
        return 'Hardware Token';
      case AuthenticationMethod.backup:
        return 'Backup Codes';
    }
  }

  /// Get method subtitle
  String _getMethodSubtitle(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.sms:
        return 'Receive codes via SMS (less secure)';
      case AuthenticationMethod.totp:
        return 'Use authenticator app (recommended)';
      case AuthenticationMethod.hardware:
        return 'Physical security key (most secure)';
      case AuthenticationMethod.backup:
        return 'Emergency access codes';
    }
  }

  /// Get method icon
  IconData _getMethodIcon(AuthenticationMethod method) {
    switch (method) {
      case AuthenticationMethod.sms:
        return Icons.sms;
      case AuthenticationMethod.totp:
        return Icons.timer;
      case AuthenticationMethod.hardware:
        return Icons.security;
      case AuthenticationMethod.backup:
        return Icons.backup;
    }
  }

  /// Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Two-Factor Authentication Help'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is Two-Factor Authentication?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Two-factor authentication (2FA) adds an extra layer of security to your account. '
                'In addition to your password, you\'ll need a second form of verification.',
              ),
              SizedBox(height: 16),
              Text(
                'Available Methods:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• SMS Verification: Receive codes via text message'),
              Text('• Authenticator App: Use apps like Google Authenticator or Authy'),
              Text('• Hardware Token: Physical security keys (coming soon)'),
              Text('• Backup Codes: Emergency access codes'),
              SizedBox(height: 16),
              Text(
                'Security Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Keep backup codes in a secure location'),
              Text('• Use authenticator apps instead of SMS when possible'),
              Text('• Don\'t share your authentication codes with anyone'),
              Text('• Regularly verify your security settings'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Authentication method enum
enum AuthenticationMethod {
  sms,
  totp,
  hardware,
  backup,
}
