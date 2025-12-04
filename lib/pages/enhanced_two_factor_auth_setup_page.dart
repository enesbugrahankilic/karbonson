// lib/pages/enhanced_two_factor_auth_setup_page.dart
// Enhanced 2FA Setup Page with improved UX, security features, and backup codes

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/enhanced_firebase_2fa_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/phone_input_widget.dart';

class EnhancedTwoFactorAuthSetupPage extends StatefulWidget {
  const EnhancedTwoFactorAuthSetupPage({super.key});

  @override
  State<EnhancedTwoFactorAuthSetupPage> createState() => _EnhancedTwoFactorAuthSetupPageState();
}

class _EnhancedTwoFactorAuthSetupPageState extends State<EnhancedTwoFactorAuthSetupPage> 
    with TickerProviderStateMixin {
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _smsFormKey = GlobalKey<FormState>();
  
  final ProfileService _profileService = ProfileService();
  
  // State management
  bool _is2FAEnabled = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _phoneNumber;
  String? _verificationId;
  List<String>? _backupCodes;
  
  // UI State
  bool _waitingForSms = false;
  bool _showBackupCodes = false;
  bool _enableBiometric = false;
  bool _generateBackupCodes = true;
  
  // Security data
  TwoFactorSecurityResult? _securityStatus;
  Map<String, dynamic>? _healthCheck;
  
  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSecurityData();
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
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Load comprehensive security data
  Future<void> _loadSecurityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load 2FA status
      final isEnabled = await EnhancedFirebase2FAService.is2FAEnabled();
      final phoneNumbers = await EnhancedFirebase2FAService.getEnrolledPhoneNumbers();
      
      // Load security status
      final securityStatus = await EnhancedFirebase2FAService.getSecurityStatus();
      
      // Perform health check
      final healthCheck = await EnhancedFirebase2FAService.performSecurityHealthCheck();

      if (mounted) {
        setState(() {
          _is2FAEnabled = isEnabled;
          _phoneNumber = phoneNumbers.isNotEmpty ? phoneNumbers.first : null;
          _securityStatus = securityStatus;
          _healthCheck = healthCheck;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading security data: $e');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showErrorSnackBar('Güvenlik verileri yüklenemedi: $e');
      }
    }
  }

  /// Start 2FA setup process
  Future<void> _start2FASetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _waitingForSms = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      
      final result = await EnhancedFirebase2FAService.setup2FA(
        phoneNumber: phoneNumber,
        enableBiometric: _enableBiometric,
        generateBackupCodes: _generateBackupCodes,
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _verificationId = result.verificationId;
            _backupCodes = result.backupCodes;
          });
          
          _showSuccessSnackBar(result.message);
        } else {
          _showErrorSnackBar(result.message);
          setState(() {
            _isProcessing = false;
            _waitingForSms = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting 2FA setup: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('2FA kurulumu başlatılamadı: $e');
        setState(() {
          _isProcessing = false;
          _waitingForSms = false;
        });
      }
    }
  }

  /// Complete 2FA enrollment
  Future<void> _complete2FAEnrollment() async {
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
      
      final result = await EnhancedFirebase2FAService.complete2FAEnrollment(
        verificationId: _verificationId!,
        smsCode: _smsCodeController.text.trim(),
        phoneNumber: phoneNumber,
        enableBiometric: _enableBiometric,
      );

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar(result.message);
          
          // Reset form and update state
          setState(() {
            _is2FAEnabled = true;
            _phoneNumber = phoneNumber;
            _waitingForSms = false;
            _isProcessing = false;
            _showBackupCodes = true;
          });
          
          // Reload security data
          await _loadSecurityData();
        } else {
          _showErrorSnackBar(result.message);
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error completing 2FA enrollment: $e');
      }
      
      if (mounted) {
        _showErrorSnackBar('2FA kaydı tamamlanamadı: $e');
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Disable 2FA with confirmation
  Future<void> _disable2FA() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('2FA\'yı Devre Dışı Bırak'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İki faktörlü doğrulamayı devre dışı bırakmak istediğinizden emin misiniz?',
              ),
              SizedBox(height: 8),
              Text(
                '⚠️ Bu işlem:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Hesabınızın güvenliğini azaltır'),
              Text('• Yedek kodlarınızı geçersiz kılar'),
              Text('• Giriş yapmak için sadece e-posta ve şifre kullanmanız gerekir'),
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
      final result = await EnhancedFirebase2FAService.disable2FA();

      if (mounted) {
        if (result.isSuccess) {
          _showSuccessSnackBar(result.message);
          
          setState(() {
            _is2FAEnabled = false;
            _phoneNumber = null;
            _backupCodes = null;
            _showBackupCodes = false;
            _isProcessing = false;
          });
          
          // Reload security data
          await _loadSecurityData();
        } else {
          _showErrorSnackBar(result.message);
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

  /// Download backup codes as text file
  Future<void> _downloadBackupCodes() async {
    if (_backupCodes == null) return;

    final codesText = _backupCodes!.join('\n');
    
    try {
      // In a real app, you would use a file system or share plugin
      // For now, show a dialog with the codes
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Yedek Kodlar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bu kodları güvenli bir yerde saklayın:'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _backupCodes!.map((code) => Text(
                      code,
                      style: const TextStyle(fontFamily: 'monospace'),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _copyBackupCodes();
              },
              child: const Text('Kopyala'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Yedek kodlar indirilemedi: $e');
    }
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
        title: const Text(
          'Güvenlik Merkezi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadSecurityData,
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
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSecurityStatus(),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_waitingForSms)
                      _buildSMSVerificationForm()
                    else if (_is2FAEnabled)
                      _build2FAEnabledView()
                    else
                      _build2FASetupForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
              _is2FAEnabled ? 'Güvenli Hesap' : 'Hesabınızı Güvenceye Alın',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _is2FAEnabled 
                  ? '2FA etkinleştirilmiş durumda'
                  : 'İki faktörlü doğrulama ile hesabınızı koruyun',
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

  Widget _buildSecurityStatus() {
    if (_healthCheck == null) return const SizedBox.shrink();

    final status = _healthCheck!['status'] as String;
    final issues = _healthCheck!['issues'] as List<String>;
    final recommendations = _healthCheck!['recommendations'] as List<String>;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status == 'healthy' ? Icons.check_circle : Icons.warning,
                  color: status == 'healthy' ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Güvenlik Durumu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (issues.isNotEmpty) ...[
              Text(
                'Tespit Edilen Sorunlar:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...issues.map((issue) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.error, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(issue)),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ],
            if (recommendations.isNotEmpty) ...[
              Text(
                'Öneriler:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSMSVerificationForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _smsFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SMS Doğrulama',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_phoneController.text.trim()} numarasına gönderilen 6 haneli kodu girin.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _smsCodeController,
                decoration: InputDecoration(
                  labelText: 'Doğrulama Kodu',
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
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _complete2FAEnrollment,
                  icon: const Icon(Icons.check_circle),
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
                child: TextButton(
                  onPressed: _isProcessing ? null : () {
                    setState(() {
                      _waitingForSms = false;
                    });
                  },
                  child: const Text('Geri Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build2FAEnabledView() {
    return Column(
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '2FA Etkin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_phoneNumber != null) ...[
                  Text(
                    'Telefon: $_phoneNumber',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'Hesabınız SMS tabanlı iki faktörlü doğrulama ile korunuyor.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_showBackupCodes && _backupCodes != null) ...[
          Card(
            elevation: 4,
            color: Colors.amber[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.backup, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Yedek Kodlar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acil durumlarda kullanabileceğiniz yedek kodlar. Bunları güvenli bir yerde saklayın.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _backupCodes!.take(5).map((code) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    )).toList(),
                  ),
                  if (_backupCodes!.length > 5)
                    Text(
                      '... ve ${_backupCodes!.length - 5} kod daha',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _copyBackupCodes,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Kopyala'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadBackupCodes,
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('İndir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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

  Widget _build2FASetupForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2FA Kurulumu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Telefon numaranıza SMS doğrulama kodu gönderilecek.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              PhoneInputWidget(
                controller: _phoneController,
                labelText: 'Telefon Numarası',
                hintText: '0555 555 55 55',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Telefon numarası girin';
                  }
                  return null; // PhoneInputWidget kendi validasyonunu yapacak
                },
              ),
              const SizedBox(height: 24),
              // Security options
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
                    Text(
                      'Güvenlik Seçenekleri',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Yedek Kodlar Oluştur'),
                      subtitle: const Text('Acil durumlar için yedek kodlar oluştur'),
                      value: _generateBackupCodes,
                      onChanged: (value) {
                        setState(() {
                          _generateBackupCodes = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Biyometrik Doğrulama (Gelecek)'),
                      subtitle: const Text('Parmak izi/yüz tanıma ile hızlı giriş'),
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
                  onPressed: _isProcessing ? null : _start2FASetup,
                  icon: const Icon(Icons.send),
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
}