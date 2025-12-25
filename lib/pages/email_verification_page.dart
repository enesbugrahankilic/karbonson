// lib/pages/email_verification_page.dart
// Email verification page for users to verify their email address

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_auth_service.dart';
import '../services/profile_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  bool _isVerified = false;
  EmailVerificationStatus? _verificationStatus;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final status = await _profileService.getEmailVerificationStatus();
      setState(() {
        _verificationStatus = status;
        _isVerified = status.isVerified;
      });

      // If email is verified, sync with Firestore and navigate back
      if (status.isVerified) {
        await _profileService.syncEmailVerificationStatus();
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate verified
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking verification status: $e');
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FirebaseAuthService.sendEmailVerification();

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama e-postası gönderilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _checkVerificationStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doğrulama durumu güncellendi'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Durum güncellenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Icon
                  Icon(
                    _isVerified ? Icons.verified : Icons.email,
                    size: 100,
                    color: _isVerified ? Colors.green : Colors.blue,
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isVerified
                        ? 'E-posta Doğrulandı!'
                        : 'E-posta Adresinizi Doğrulayın',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_verificationStatus?.email != null) ...[
                          Text(
                            'E-posta: ${_verificationStatus!.email}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          _isVerified
                              ? 'E-posta adresiniz başarıyla doğrulanmıştır. Artık tüm özelliklerden yararlanabilirsiniz.'
                              : _verificationStatus?.message ??
                                  'E-posta adresinizi doğrulamanız gerekiyor. Lütfen e-posta kutunuzu kontrol edin ve doğrulama linkine tıklayın.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (!_isVerified) ...[
                    // Send verification button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendVerificationEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Doğrulama E-postasını Tekrar Gönder',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Refresh status button
                    OutlinedButton(
                      onPressed: _isLoading ? null : _refreshStatus,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Doğrulama Durumunu Kontrol Et',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Help text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.amber.shade700,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'E-posta gelmedi mi?\n• Spam klasörünüzü kontrol edin\n• Birkaç dakika bekleyin\n• Tekrar "Doğrulama E-postasını Tekrar Gönder" butonuna tıklayın',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Success message and continue button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tebrikler! E-posta adresiniz başarıyla doğrulanmıştır.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Continue button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Devam Et',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Footer
                  const Text(
                    'E-posta doğrulama, hesabınızın güvenliği için önemlidir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
