// lib/widgets/firebase_config_validator.dart
// Firebase Configuration Validation Widget

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_auth_service.dart';
import '../theme/theme_colors.dart';

class FirebaseConfigValidator extends StatefulWidget {
  final Widget child;
  final bool showOnlyOnError;

  const FirebaseConfigValidator({
    super.key,
    required this.child,
    this.showOnlyOnError = false,
  });

  @override
  State<FirebaseConfigValidator> createState() =>
      _FirebaseConfigValidatorState();
}

class _FirebaseConfigValidatorState extends State<FirebaseConfigValidator> {
  bool _isValidating = true;
  bool _isConfigValid = false;
  Map<String, dynamic>? _validationResults;

  @override
  void initState() {
    super.initState();
    _validateFirebaseConfig();
  }

  Future<void> _validateFirebaseConfig() async {
    try {
      final isValid = await FirebaseAuthService.validateFirebaseConfig();
      final configCheck = await FirebaseAuthService.checkAuthConfiguration();

      setState(() {
        _isConfigValid = isValid;
        _validationResults = {
          'isValid': configCheck,
          'checkedAt': DateTime.now().toIso8601String()
        };
        _isValidating = false;
      });

      // Show warning if configuration is invalid and not showing only on error
      if (!isValid && !widget.showOnlyOnError) {
        _showConfigWarningDialog();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase config validation error: $e');
      }
      setState(() {
        _isConfigValid = false;
        _validationResults = {'error': e.toString()};
        _isValidating = false;
      });

      if (!widget.showOnlyOnError) {
        _showConfigErrorDialog(e.toString());
      }
    }
  }

  void _showConfigWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600], size: 28),
              const SizedBox(width: 8),
              const Text('Firebase Yapılandırma Uyarısı'),
            ],
          ),
          content: const Text(
            'Firebase Authentication yapılandırmasında sorun tespit edildi. '
            'Bu, giriş ve kayıt işlemlerinde hatalara neden olabilir.\n\n'
            'Lütfen Firebase Console\'da Authentication servisinin etkinleştirildiğinden emin olun.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Devam Et'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDetailedConfigDialog();
              },
              child: const Text('Detaylar'),
            ),
          ],
        );
      },
    );
  }

  void _showConfigErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red[600], size: 28),
              const SizedBox(width: 8),
              const Text('Firebase Yapılandırma Hatası'),
            ],
          ),
          content: Text(
            'Firebase yapılandırması doğrulanamadı:\n\n$error\n\n'
            'Lütfen Firebase projenizin doğru şekilde yapılandırıldığından emin olun.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _validateFirebaseConfig(); // Retry
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        );
      },
    );
  }

  void _showDetailedConfigDialog() {
    if (_validationResults == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Firebase Yapılandırma Detayları'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfigRow('Firebase İlklendi',
                    _validationResults!['firebase_initialized']),
                _buildConfigRow('Mevcut Kullanıcı',
                    _validationResults!['current_user_available']),
                _buildConfigRow('Anonim Giriş Aktif',
                    _validationResults!['anonymous_signin_enabled']),
                if (_validationResults!.containsKey('anonymous_signin_error'))
                  _buildConfigRow('Anonim Giriş Hatası',
                      _validationResults!['anonymous_signin_error'],
                      isError: true),
                if (_validationResults!.containsKey('error'))
                  _buildConfigRow('Genel Hata', _validationResults!['error'],
                      isError: true),
                const SizedBox(height: 16),
                const Text(
                  'Çözüm Önerileri:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Firebase Console\'da Authentication > Sign-in method\'da Email/Password\'ı etkinleştirin\n'
                  '2. Anonymous sign-in\'in etkinleştirildiğinden emin olun\n'
                  '3. google-services.json ve GoogleService-Info.plist dosyalarının güncel olduğunu kontrol edin',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _validateFirebaseConfig(); // Retry validation
              },
              child: const Text('Yeniden Kontrol Et'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfigRow(String label, dynamic value, {bool isError = false}) {
    final bool isTrue = value is bool ? value : false;
    final Color color =
        isError ? Colors.red : (isTrue ? Colors.green : Colors.orange);
    final IconData icon =
        isError ? Icons.error : (isTrue ? Icons.check_circle : Icons.warning);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator during validation
    if (_isValidating) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Firebase yapılandırması kontrol ediliyor...',
                style: TextStyle(fontSize: 16, color: ThemeColors.getTextOnColoredBackground(context)),
              ),
            ],
          ),
        ),
      );
    }

    // Show child widget regardless of validation result
    return widget.child;
  }
}

/// Standalone widget for checking Firebase configuration
class FirebaseConfigCheck extends StatelessWidget {
  final VoidCallback? onValidConfig;
  final VoidCallback? onInvalidConfig;

  const FirebaseConfigCheck({
    super.key,
    this.onValidConfig,
    this.onInvalidConfig,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: FirebaseAuthService.validateFirebaseConfig(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isValid = snapshot.data ?? false;

        if (isValid) {
          if (onValidConfig != null) {
            onValidConfig!();
          }
          return const SizedBox.shrink();
        } else {
          if (onInvalidConfig != null) {
            onInvalidConfig!();
          }

          return Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange[600],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase Yapılandırma Sorunu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Firebase Authentication düzgün yapılandırılmamış. '
                      'Bazı özellikler çalışmayabilir.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showHelpDialog(context),
                      child: const Text('Yardım Al'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Firebase Yapılandırma Yardımı'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Firebase Authentication sorunlarını çözmek için:'),
                SizedBox(height: 12),
                Text(
                  '1. Firebase Console\'a gidin\n'
                  '2. Authentication > Sign-in method seçin\n'
                  '3. Email/Password\'ı etkinleştirin\n'
                  '4. Anonymous sign-in\'i etkinleştirin\n'
                  '5. Değişiklikleri kaydedin\n\n'
                  'Daha fazla yardım için documentation\'a bakın.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
