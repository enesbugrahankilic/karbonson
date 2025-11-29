// lib/pages/two_factor_auth_setup_page.dart
// Modern 2FA Setup Page with improved UX, animations, and security features

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_2fa_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';

/// Result class for 2FA operations
class TwoFactorAuthResult {
  final bool isSuccess;
  final String message;
  final String? verificationId;
  final List<String>? backupCodes;

  const TwoFactorAuthResult({
    required this.isSuccess,
    required this.message,
    this.verificationId,
    this.backupCodes,
  });

  String getTurkishMessage() {
    // Add Turkish translations for common messages
    if (message.contains('SMS sent')) {
      return 'SMS kodu gönderildi';
    }
    if (message.contains('Verification completed')) {
      return 'Doğrulama tamamlandı';
    }
    if (message.contains('2FA enabled')) {
      return '2FA başarıyla etkinleştirildi';
    }
    if (message.contains('2FA disabled')) {
      return '2FA devre dışı bırakıldı';
    }
    return message;
  }
}

class TwoFactorAuthSetupPage extends StatefulWidget {
  const TwoFactorAuthSetupPage({super.key});

  @override
  State<TwoFactorAuthSetupPage> createState() => _TwoFactorAuthSetupPageState();
}

class _TwoFactorAuthSetupPageState extends State<TwoFactorAuthSetupPage>
    with TickerProviderStateMixin {
  
  // Form controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _backupCodeController = TextEditingController();
  
  // Form keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _smsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _backupFormKey = GlobalKey<FormState>();
  
  // Services
  final ProfileService _profileService = ProfileService();
  
  // State variables
  bool _is2FAEnabled = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _phoneNumber;
  String? _verificationId;
  List<String>? _backupCodes;
  
  // UI State
  bool _waitingForSms = false;
  bool _showBackupCodes = false;
  bool _showAdvancedOptions = false;
  bool _enableBiometric = false;
  bool _generateBackupCodes = true;
  bool _useBackupCode = false;
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Security data
  Map<String, dynamic>? _securityStatus;
  List<String> _securityRecommendations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _load2FAStatus();
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

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _backupCodeController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Load current 2FA status and security information
  Future<void> _load2FAStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load 2FA status
      final isEnabled = await Firebase2FAService.is2FAEnabled();
      final phoneNumbers = await Firebase2FAService.getEnrolledPhoneNumbers();
      
      // Load security recommendations
      _securityRecommendations = _generateSecurityRecommendations();
      
      if (mounted) {
        setState(() {
          _is2FAEnabled = isEnabled;
          _phoneNumber = phoneNumbers.isNotEmpty ? phoneNumbers.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading 2FA status: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showErrorSnackBar('2FA durumu yüklenemedi: $e');
      }
    }
  }

  /// Generate security recommendations based on current state
  List<String> _generateSecurityRecommendations() {
    final recommendations = <String>[];
    
    if (!_is2FAEnabled) {
      recommendations.add('2FA etkinleştirerek hesabınızı güçlendirin');
      recommendations.add('Güçlü ve benzersiz şifreler kullanın');
    }
    
    if (_generateBackupCodes) {
      recommendations.add('Yedek kodları güvenli bir yerde saklayın');
    }
    
    recommendations.add('Düzenli olarak güvenlik ayarlarınızı kontrol edin');
    
    return recommendations;
  }

  /// Start enabling 2FA process
  Future<void> _enable2FA() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _waitingForSms = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      
      final result = await Firebase2FAService.sendVerificationCode(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            // For this simplified implementation, we'll simulate verification
            _verificationId = 'simulated_verification_id';
            if (_generateBackupCodes) {
              _backupCodes = _generateBackupCodesList();
            }
          });
          _showSuccessSnackBar('SMS kodu gönderildi');
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
        debugPrint('Error enabling 2FA: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('2FA etkinleştirilemedi: $e');
        setState(() {
          _isProcessing = false;
          _waitingForSms = false;
        });
      }
    }
  }

  /// Finalize 2FA setup with SMS verification
  Future<void> _finalize2FASetup() async {
    if (!_smsFormKey.currentState!.validate()) return;
    if (_verificationId == null) {
      _showErrorSnackBar('Doğrulama kimliği bulunamadı. Lütfen tekrar deneyin.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      
      final result = await Firebase2FAService.finalize2FASetup(
        _verificationId!,
        _smsCodeController.text.trim(),
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar('2FA başarıyla etkinleştirildi');
          
          // Update local state
          setState(() {
            _is2FAEnabled = true;
            _phoneNumber = phoneNumber;
            _waitingForSms = false;
            _isProcessing = false;
            _showBackupCodes = _backupCodes != null;
          });
          
          // Update UserData model
          await Firebase2FAService.updateUserData2FAStatus(true, phoneNumber);
          
          // Update recommendations
          _securityRecommendations = _generateSecurityRecommendations();
        } else {
          _showErrorSnackBar(result.getTurkishMessage());
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error finalizing 2FA setup: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('2FA sonlandırılamadı: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Verify using backup code
  Future<void> _verifyWithBackupCode() async {
    if (!_backupFormKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate backup code verification (replace with actual implementation)
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      _showSuccessSnackBar('Yedek kod ile giriş başarılı');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Disable 2FA with enhanced confirmation
  Future<void> _disable2FA() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '2FA\'yı Devre Dışı Bırak',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'İki faktörlü doğrulamayı devre dışı bırakmak istediğinizden emin misiniz?',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Bu işlem:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    SizedBox(height: 4),
                    Text('• Hesabınızın güvenliğini azaltır'),
                    Text('• Yedek kodlarınızı geçersiz kılar'),
                    Text('• Sadece e-posta/şifre ile giriş yapmanız gerekir'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDisable2FA();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Devre Dışı Bırak'),
            ),
          ],
        );
      },
    );
  }

  /// Perform 2FA disable
  Future<void> _performDisable2FA() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await Firebase2FAService.disable2FA();

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar('2FA başarıyla devre dışı bırakıldı');
          
          // Update local state
          setState(() {
            _is2FAEnabled = false;
            _phoneNumber = null;
            _backupCodes = null;
            _showBackupCodes = false;
            _isProcessing = false;
          });
          
          // Update UserData model
          await Firebase2FAService.updateUserData2FAStatus(false, null);
          
          // Update recommendations
          _securityRecommendations = _generateSecurityRecommendations();
        } else {
          _showErrorSnackBar(result.getTurkishMessage());
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error disabling 2FA: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('2FA devre dışı bırakılamadı: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Copy backup codes to clipboard
  Future<void> _copyBackupCodes() async {
    if (_backupCodes == null) return;

    final codesText = _backupCodes!.join('\n');
    
    try {
      await Clipboard.setData(ClipboardData(text: codesText));
      _showSuccessSnackBar('Yedek kodlar panoya kopyalandı');
    } catch (e) {
      _showErrorSnackBar('Kopyalama başarısız: $e');
    }
  }

  /// Generate backup codes list
  List<String> _generateBackupCodesList() {
    final codes = <String>[];
    final random = DateTime.now().microsecondsSinceEpoch % 1000000;
    
    for (int i = 0; i < 8; i++) {
      final code = (random + i * 12345).toString().padLeft(6, '0');
      codes.add(code);
    }
    
    return codes;
  }

  /// SMS code validation
  bool get _smsCodeEntered => _smsCodeController.text.length == 6;

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
        title: const Text(
          'İki Faktörlü Doğrulama',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _load2FAStatus,
          ),
          if (!_isLoading)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'help':
                    _showHelpDialog();
                    break;
                  case 'advanced':
                    setState(() {
                      _showAdvancedOptions = !_showAdvancedOptions;
                    });
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Yardım'),
                  ),
                ),
                PopupMenuItem(
                  value: 'advanced',
                  child: ListTile(
                    leading: Icon(_showAdvancedOptions ? Icons.expand_less : Icons.expand_more),
                    title: Text(_showAdvancedOptions ? 'Gelişmiş Seçenekleri Gizle' : 'Gelişmiş Seçenekleri Göster'),
                  ),
                ),
              ],
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildSecurityStatusCard(),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_waitingForSms)
                      _buildSMSVerificationCard()
                    else if (_is2FAEnabled)
                      _build2FAEnabledCard()
                    else
                      _build2FASetupCard(),
                    if (_showAdvancedOptions && !_isLoading) ...[
                      const SizedBox(height: 20),
                      _buildAdvancedOptionsCard(),
                    ],
                  ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    _is2FAEnabled ? Icons.security : Icons.security_outlined,
                    size: 48,
                    color: _is2FAEnabled ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _is2FAEnabled ? 'Güvenli Hesap' : 'Hesabınızı Koruyun',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _is2FAEnabled 
                  ? '2FA etkinleştirilmiş durumda'
                  : 'İki faktörlü doğrulama ile hesabınızı güçlendirin',
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

  Widget _buildSecurityStatusCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _is2FAEnabled ? Icons.check_circle : Icons.info,
                  color: _is2FAEnabled ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Güvenlik Durumu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _is2FAEnabled 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _is2FAEnabled 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _is2FAEnabled 
                        ? '✅ Hesabınız güvende'
                        : '⚠️ Hesap güvenliği geliştirilebilir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _is2FAEnabled ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _is2FAEnabled 
                        ? '2FA etkinleştirilmiş durumda. Hesabınız ek güvenlik katmanı ile korunuyor.'
                        : '2FA etkinleştirerek hesabınızın güvenliğini önemli ölçüde artırabilirsiniz.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  if (_phoneNumber != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '📱 Telefon: $_phoneNumber',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_securityRecommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '💡 Güvenlik Önerileri:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              ..._securityRecommendations.map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(recommendation)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSMSVerificationCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _smsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sms, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'SMS Doğrulama',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${_phoneController.text.trim()} numarasına 6 haneli doğrulama kodu gönderildi.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _smsCodeController,
                decoration: InputDecoration(
                  labelText: 'Doğrulama Kodu',
                  hintText: '123456',
                  prefixIcon: const Icon(Icons.pin),
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
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Doğrulama kodunu girin';
                  }
                  if (value.length != 6) {
                    return 'Kod 6 haneli olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isProcessing || !_smsCodeEntered) ? null : _finalize2FASetup,
                  icon: _isProcessing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(_isProcessing ? 'Doğrulanıyor...' : '2FA\'yi Etkinleştir'),
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
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: _isProcessing ? null : () {
                    setState(() {
                      _waitingForSms = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build2FAEnabledCard() {
    return Column(
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '2FA Aktif',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Hesabınız güvenli',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SMS tabanlı iki faktörlü doğrulama ile korunuyor.',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      if (_phoneNumber != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '📱 Telefon: $_phoneNumber',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_showBackupCodes && _backupCodes != null) ...[
          Card(
            elevation: 6,
            color: Colors.amber[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.backup, color: Colors.amber[700], size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Yedek Kodlar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Acil durumlarda kullanabileceğiniz yedek kodlar. Bunları güvenli bir yerde saklayın.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _backupCodes!.take(6).map((code) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.amber[400]!),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'monospace', 
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  if (_backupCodes!.length > 6)
                    Text(
                      '... ve ${_backupCodes!.length - 6} kod daha',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyBackupCodes,
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Kopyala'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _disable2FA,
                  icon: const Icon(Icons.remove_circle),
                  label: const Text('2FA\'yı Devre Dışı Bırak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ 2FA\'yı devre dışı bırakmak hesabınızın güvenliğini azaltır.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _build2FASetupCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_android, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    '2FA Kurulumu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Telefon numaranıza SMS doğrulama kodu gönderilecek.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon Numarası',
                  hintText: '+90 555 123 45 67',
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: ThemeColors.getInputBackground(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefon numarasını girin';
                  }
                  if (!value.startsWith('+') || value.length < 10) {
                    return 'Geçerli bir telefon numarası girin (örn: +90 555 123 45 67)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Güvenlik Seçenekleri',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Yedek Kodlar Oluştur'),
                      subtitle: const Text('Acil durumlar için 8 adet yedek kod oluştur'),
                      value: _generateBackupCodes,
                      onChanged: (value) {
                        setState(() {
                          _generateBackupCodes = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Biyometrik Doğrulama'),
                      subtitle: const Text('Parmak izi/yüz tanıma ile hızlı giriş (Yakında)'),
                      value: _enableBiometric,
                      onChanged: null, // Disabled for now
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _enable2FA,
                  icon: _isProcessing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isProcessing ? 'Gönderiliyor...' : 'SMS Kodu Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }

  Widget _buildAdvancedOptionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gelişmiş Seçenekler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Yedek Kod ile Giriş Yap'),
              subtitle: const Text('8 haneli yedek kodunuz varsa buradan giriş yapabilirsiniz'),
              onTap: () {
                setState(() {
                  _useBackupCode = true;
                });
              },
            ),
            if (_useBackupCode) ...[
              const SizedBox(height: 16),
              Form(
                key: _backupFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _backupCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Yedek Kod',
                        hintText: '12345678',
                        prefixIcon: Icon(Icons.key),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yedek kodu girin';
                        }
                        if (value.length != 8) {
                          return 'Yedek kod 8 haneli olmalıdır';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _verifyWithBackupCode,
                            child: Text(_isProcessing ? 'Doğrulanıyor...' : 'Doğrula'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _useBackupCode = false;
                              _backupCodeController.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('İptal'),
                        ),
                      ],
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('2FA Hakkında'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İki Faktörlü Doğrulama (2FA) Nedir?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '2FA, hesabınıza ek bir güvenlik katmanı ekler. Şifrenize ek olarak, telefonunuza gönderilen kodu da girmeniz gerekir.',
              ),
              SizedBox(height: 16),
              Text(
                'Avantajları:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Hesabınız %99 daha güvenli hale gelir'),
              Text('• Şifreniz çalınsa bile hesabınız korunur'),
              Text('• SMS tabanlı kolay kurulum'),
              Text('• Yedek kodlar ile acil durum desteği'),
              SizedBox(height: 16),
              Text(
                'Güvenlik İpuçları:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Yedek kodları güvenli bir yerde saklayın'),
              Text('• Telefon numaranızı güncel tutun'),
              Text('• Düzenli olarak 2FA durumunuzu kontrol edin'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}