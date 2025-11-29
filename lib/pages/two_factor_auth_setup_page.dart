// lib/pages/two_factor_auth_setup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_2fa_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';

class TwoFactorAuthSetupPage extends StatefulWidget {
  const TwoFactorAuthSetupPage({super.key});

  @override
  State<TwoFactorAuthSetupPage> createState() => _TwoFactorAuthSetupPageState();
}

class _TwoFactorAuthSetupPageState extends State<TwoFactorAuthSetupPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _smsFormKey = GlobalKey<FormState>();
  
  final ProfileService _profileService = ProfileService();
  
  bool _is2FAEnabled = false;
  String? _phoneNumber;
  bool _isLoading = true;
  bool _isProcessing = false;
  
  // SMS verification
  bool _waitingForSms = false;
  bool _smsCodeEntered = false;
  String? _verificationId;
  
  @override
  void initState() {
    super.initState();
    _load2FAStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  /// Load current 2FA status
  Future<void> _load2FAStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new Firebase2FAService to check 2FA status
      final isEnabled = await Firebase2FAService.is2FAEnabled();
      final phoneNumbers = await Firebase2FAService.getEnrolledPhoneNumbers();
      
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('2FA durumu yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      
      final result = await Firebase2FAService.enable2FA(phoneNumber);

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.getTurkishMessage()),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.getTurkishMessage()),
              backgroundColor: Colors.red,
            ),
          );
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
        setState(() {
          _isProcessing = false;
          _waitingForSms = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('2FA etkinleştirilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Finalize 2FA setup with SMS verification
  Future<void> _finalize2FASetup() async {
    if (!_smsFormKey.currentState!.validate()) return;
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doğrulama kimliği bulunamadı. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
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
        phoneNumber,
      );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.getTurkishMessage()),
              backgroundColor: Colors.green,
            ),
          );
          
          // Update local state
          setState(() {
            _is2FAEnabled = true;
            _phoneNumber = phoneNumber;
            _waitingForSms = false;
            _smsCodeEntered = false;
            _isProcessing = false;
          });
          
          // Update UserData model
          await Firebase2FAService.updateUserData2FAStatus(true, phoneNumber);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.getTurkishMessage()),
              backgroundColor: Colors.red,
            ),
          );
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
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('2FA sonlandırılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Disable 2FA
  Future<void> _disable2FA() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('2FA\'yı Devre Dışı Bırak'),
          content: const Text(
            'İki faktörlü doğrulamayı devre dışı bırakmak istediğinizden emin misiniz? '
            'Bu işlem hesabınızın güvenliğini azaltır.',
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.getTurkishMessage()),
              backgroundColor: Colors.green,
            ),
          );
          
          // Update local state
          setState(() {
            _is2FAEnabled = false;
            _phoneNumber = null;
            _isProcessing = false;
          });
          
          // Update UserData model
          await Firebase2FAService.updateUserData2FAStatus(false, null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.getTurkishMessage()),
              backgroundColor: Colors.red,
            ),
          );
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
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('2FA devre dışı bırakılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              _is2FAEnabled ? Icons.security : Icons.security_outlined,
                              size: 32,
                              color: _is2FAEnabled 
                                  ? Colors.green 
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'İki Faktörlü Doğrulama',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _is2FAEnabled ? 'Etkin' : 'Devre Dışı',
                                    style: TextStyle(
                                      color: _is2FAEnabled ? Colors.green : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Current status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _is2FAEnabled 
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _is2FAEnabled 
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _is2FAEnabled ? Icons.check_circle : Icons.info,
                                color: _is2FAEnabled ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _is2FAEnabled 
                                          ? 'Hesabınız güvenli'
                                          : 'Hesap güvenliği zayıf',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _is2FAEnabled ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _is2FAEnabled 
                                          ? '2FA etkinleştirilmiş durumda.'
                                          : '2FA etkinleştirilerek hesabınızın güvenliğini artırabilirsiniz.',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (_phoneNumber != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Telefon: $_phoneNumber',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Content based on 2FA status
                        if (_isLoading) ...[
                          const Center(child: CircularProgressIndicator()),
                        ] else if (_is2FAEnabled) ...[
                          // 2FA is enabled - show disable option
                          Column(
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
                              const SizedBox(height: 16),
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
                        ] else if (_waitingForSms) ...[
                          // SMS verification form
                          Form(
                            key: _smsFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Doğrulama Kodunu Girin',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                    fontSize: 18,
                                    letterSpacing: 4,
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
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _isProcessing ? null : _finalize2FASetup,
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('2FA\'yi Etkinleştir'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // 2FA setup form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Telefon Numarasınızı Girin',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                    // Simple validation - you might want to enhance this
                                    if (!value.startsWith('+') || value.length < 10) {
                                      return 'Geçerli bir telefon numarası girin (örn: +90 555 123 45 67)';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bu telefon numarasına SMS doğrulama kodu gönderilecektir.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _isProcessing ? null : _enable2FA,
                                  icon: const Icon(Icons.send),
                                  label: const Text('SMS Kodu Gönder'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Back button
                        if (!_waitingForSms)
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Geri Dön'),
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
    );
  }
}