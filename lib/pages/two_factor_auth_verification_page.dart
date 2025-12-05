// lib/pages/two_factor_auth_verification_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_2fa_service.dart';
import '../theme/theme_colors.dart';

class TwoFactorAuthVerificationPage extends StatefulWidget {
  final TwoFactorAuthResult authResult;
  
  const TwoFactorAuthVerificationPage({
    super.key,
    required this.authResult,
  });

  @override
  State<TwoFactorAuthVerificationPage> createState() => _TwoFactorAuthVerificationPageState();
}

class _TwoFactorAuthVerificationPageState extends State<TwoFactorAuthVerificationPage> {
  final TextEditingController _smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isVerifying = false;
  String? _verificationId;
  bool _codeSent = false;
  
  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  @override
  void dispose() {
    _smsCodeController.dispose();
    super.dispose();
  }

  /// Start SMS verification process
  Future<void> _startVerification() async {
    if (!widget.authResult.requires2FA || 
        widget.authResult.phoneProvider == null ||
        widget.authResult.multiFactorResolver == null) {
      if (kDebugMode) {
        debugPrint('Invalid 2FA result - missing required fields');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('2FA doğrulama başlatılamadı. Lütfen tekrar giriş yapmayı deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Get phone number from multi-factor resolver
      String? phoneNumber;
      
      // First try to get phone number from metadata if available
      if (widget.authResult.metadata != null && widget.authResult.metadata!['phoneNumber'] != null) {
        phoneNumber = widget.authResult.metadata!['phoneNumber'] as String;
      }
      
      // If not found in metadata, try to get from resolver hints
      if (phoneNumber == null && widget.authResult.multiFactorResolver != null) {
        final hints = widget.authResult.multiFactorResolver!.hints;
        for (final hint in hints) {
          if (hint is MultiFactorInfo && hint.factorId.contains('phone')) {
            // For MultiFactorInfo, phone number might be in displayName or we need to get it differently
            if (hint is PhoneMultiFactorInfo) {
              phoneNumber = (hint as PhoneMultiFactorInfo).phoneNumber;
              break;
            }
          }
        }
      }
      
      // If still no phone number, prompt user to enter it
      if (phoneNumber == null) {
        final enteredNumber = await _promptUserForPhoneNumber();
        if (enteredNumber == null || enteredNumber.isEmpty) {
          Navigator.of(context).pop();
          return;
        }
        phoneNumber = enteredNumber;
      }

      // Start phone verification with the correct phone number
      final verificationResult = await Firebase2FAService.startPhoneVerification(
        phoneNumber: phoneNumber!,
      );

      if (mounted) {
        setState(() {
          _isVerifying = false;
          _codeSent = verificationResult.isSuccess;
          // Simulate verification ID for now - in real implementation this would come from Firebase
          _verificationId = 'mock_verification_id_12345';
        });

        if (verificationResult.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verificationResult.getTurkishMessage()),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verificationResult.getTurkishMessage()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting 2FA verification: $e');
      }
      
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama başlatılamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        Navigator.of(context).pop();
      }
    }
  }

  /// Verify SMS code and complete 2FA
  Future<void> _verifySmsCode() async {
    if (!_formKey.currentState!.validate()) return;
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
      _isVerifying = true;
    });

    try {
      final result = await Firebase2FAService.resolve2FAChallenge(
        _verificationId!,
        _smsCodeController.text.trim(),
        multiFactorResolver: widget.authResult.multiFactorResolver,
        phoneIndex: 0, // Assuming first phone factor
      );

      if (mounted) {
        if (result.isSuccess) {
          // 2FA verification successful - user is now logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('2FA doğrulama başarılı! Yönlendiriliyor...'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Update UserData model with 2FA status
          await Firebase2FAService.updateUserData2FAStatus(true, 'Phone Number');
          
          // Navigate to profile page
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/profile',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying SMS code: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama kodu doğrulanamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Resend SMS code
  Future<void> _resendSmsCode() async {
    await _startVerification();
  }

  /// Prompt user for phone number
  Future<String?> _promptUserForPhoneNumber() async {
    final controller = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Telefon Numarası Girin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Telefon numaranızı girin (örn: 0555 555 55 55):'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  hintText: '0555 555 55 55',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
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
              onPressed: () {
                final phoneNumber = controller.text.trim();
                if (phoneNumber.isNotEmpty) {
                  Navigator.of(context).pop(phoneNumber);
                }
              },
              child: const Text('Devam Et'),
            ),
          ],
        );
      },
    );
  }

  /// Cancel 2FA and go back to login
  void _cancelVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Doğrulamayı İptal Et'),
          content: const Text('2FA doğrulamayı iptal etmek istediğinizden emin misiniz? Giriş işlemi tamamlanamaz.'),
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
                constraints: const BoxConstraints(maxWidth: 400),
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
                        // Security icon
                        Container(
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
                        const SizedBox(height: 24),
                        
                        // Title
                        Text(
                          'SMS Doğrulama',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.getText(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          'Telefonunuza gelen doğrulama kodunu girin',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ThemeColors.getSecondaryText(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Loading state
                        if (_isVerifying) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text('Doğrulama işlemi yapılıyor...'),
                          const SizedBox(height: 16),
                        ],
                        
                        // SMS Code input form
                        if (!_isVerifying && _codeSent) ...[
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
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
                                  onChanged: (value) {
                                    // Auto-submit when 6 digits are entered
                                    if (value.length == 6) {
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
                                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                                  label: const Text('Tekrar Gönder'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Verification needed message
                        if (!_isVerifying && !_codeSent) ...[
                          const Text(
                            'SMS doğrulama kodu gönderiliyor...',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Cancel button
                        TextButton(
                          onPressed: _isVerifying ? null : _cancelVerification,
                          child: Text(
                            'Doğrulamayı İptal Et',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 14,
                            ),
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