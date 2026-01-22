// lib/pages/email_verification_page.dart
// Email verification page for users to verify their email address

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_auth_service.dart' as auth_service;
import '../services/profile_service.dart';
import '../theme/design_system.dart';
import '../widgets/page_templates.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  bool _isVerified = false;
  ProfileEmailVerificationStatus? _verificationStatus;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    // Automatically send verification email when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmailOnPageOpen();
    });
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final status = await _profileService.getProfileEmailVerificationStatus();
      setState(() {
        _verificationStatus = status;
        _isVerified = status.emailVerified;
      });

      // If email is verified, navigate back
      if (status.emailVerified) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate verified
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking verification status: $e');
    }
  }

  Future<void> _sendVerificationEmailOnPageOpen() async {
    // Only send if email is not verified
    if (_isVerified) return;

    try {
      final result = await auth_service.FirebaseAuthService.sendEmailVerification();

      if (mounted) {
        if (result.isSuccess) {
          // Show success message but don't make it intrusive since it's automatic
          if (kDebugMode) {
            debugPrint('Verification email sent automatically on page open');
          }
        } else {
          // Show error only in debug mode for automatic sending
          if (kDebugMode) {
            debugPrint('Failed to send automatic verification email: ${result.message}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending automatic verification email: $e');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await auth_service.FirebaseAuthService.sendEmailVerification();

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
      appBar: StandardAppBar(
        title: const Text('E-posta Doğrulama'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Icon
            Icon(
              _isVerified ? Icons.verified : Icons.email,
              size: 80,
              color: _isVerified ? Colors.green : Theme.of(context).primaryColor,
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              _isVerified
                  ? 'E-posta Doğrulandı!'
                  : 'E-posta Adresinizi Doğrulayın',
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  if (_verificationStatus?.email != null) ...[
                    Text(
                      'E-posta: ${_verificationStatus!.email}',
                      style: DesignSystem.getBodyMedium(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _isVerified
                        ? 'E-posta adresiniz başarıyla doğrulanmıştır. Artık tüm özelliklerden yararlanabilirsiniz.'
                        : _verificationStatus?.message ??
                            'E-posta adresinizi doğrulamanız gerekiyor. Lütfen e-posta kutunuzu kontrol edin ve doğrulama linkine tıklayın.',
                    style: DesignSystem.getBodySmall(context).copyWith(
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            if (!_isVerified) ...[
              // Send verification button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendVerificationEmail,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.email),
                label: Text(
                  _isLoading ? 'Gönderiliyor...' : 'Doğrulama E-postasını Gönder',
                ),
                style: DesignSystem.getPrimaryButtonStyle(context),
              ),

              const SizedBox(height: 12),

              // Refresh status button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _refreshStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Doğrulama Durumunu Kontrol Et'),
              ),

              const SizedBox(height: 20),

              // Help text
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: Colors.amber[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'E-posta gelmedi mi? Spam klasörünüzü kontrol edin veya tekrar gönderin.',
                        style: DesignSystem.getBodySmall(context).copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Success message container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tebrikler! E-posta adresiniz başarıyla doğrulanmıştır.',
                      style: DesignSystem.getBodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.check),
                label: const Text('Devam Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
