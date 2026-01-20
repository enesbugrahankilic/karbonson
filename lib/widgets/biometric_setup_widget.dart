import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/biometric_service.dart';
import '../services/biometric_user_service.dart';

/// Biyometri kurulum widget'ı
/// Kayıt işleminden sonra biyometri kurulumunu sunar
class BiometricSetupWidget extends StatefulWidget {
  final VoidCallback? onSetupCompleted;
  final VoidCallback? onSetupSkipped;

  const BiometricSetupWidget({
    super.key,
    this.onSetupCompleted,
    this.onSetupSkipped,
  });

  @override
  State<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends State<BiometricSetupWidget> {
  bool _isAvailable = false;
  bool _isLoading = false;
  String _biometricType = '';
  bool _isSetup = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final available = await BiometricService.isBiometricAvailable();
      if (available) {
        _biometricType = await BiometricService.getBiometricTypeName();
      }

      if (mounted) {
        setState(() {
          _isAvailable = available;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri kontrol hatası: $e');
      }
    }
  }

  Future<void> _setupBiometric() async {
    if (!_isAvailable) {
      _showMessage('Bu cihazda biyometrik kimlik doğrulama mevcut değil.',
          Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show overlay
    _showBiometricOverlay();

    try {
      // Biyometrik kimlik doğrulama iste
      final success = await BiometricService.authenticate(
        localizedReason:
            'Biyometrik kimlik doğrulama kurulumu için $_biometricType kullanımına izin verin',
        useErrorDialogs: true,
      );

      // Hide overlay
      if (mounted) {
        Navigator.of(context).pop(); // Close overlay
      }

      if (success) {
        // Biyometri kurulum bilgilerini Firestore'a kaydet
        final saveSuccess = await BiometricUserService.saveBiometricSetup();

        if (saveSuccess) {
          if (mounted) {
            setState(() {
              _isSetup = true;
            });
            _showMessage('Biyometrik kimlik doğrulama başarıyla kuruldu! 🎉',
                Colors.green);
            widget.onSetupCompleted?.call();
          }
        } else {
          // Kullanıcı oturumu yoksa daha anlaşılır bir hata mesajı göster
          final user = fb_auth.FirebaseAuth.instance.currentUser;
          if (mounted) {
            if (user == null) {
              _showMessage(
                  'Biyometri bilgileri kaydedilemedi. Lütfen oturum açın ve tekrar deneyin.',
                  Colors.red);
            } else {
              _showMessage(
                  'Biyometri bilgileri kaydedilemedi. Lütfen daha sonra tekrar deneyin.',
                  Colors.red);
            }
          }
        }
      } else {
        _showMessage(
            'Biyometrik kimlik doğrulama iptal edildi.', Colors.orange);
      }
    } catch (e) {
      // Hide overlay
      if (mounted) {
        Navigator.of(context).pop(); // Close overlay
      }

      // Daha spesifik hata mesajları için hata türünü kontrol et
      if (mounted) {
        if (e.toString().contains('user-not-found') ||
            e.toString().contains('null')) {
          _showMessage(
              'Kullanıcı oturumu bulunamadı. Lütfen giriş yapın.', Colors.red);
        } else if (e.toString().contains('network') ||
            e.toString().contains('timeout')) {
          _showMessage(
              'Ağ bağlantı hatası. İnternet bağlantınızı kontrol edin.',
              Colors.red);
        } else if (e.toString().contains('biometric')) {
          _showMessage(
              'Biyometrik cihaz desteği bulunamadı. Cihazınızı kontrol edin.',
              Colors.red);
        } else if (e.toString().contains('Firestore') ||
            e.toString().contains('Firebase')) {
          _showMessage(
              'Veritabanı bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.',
              Colors.red);
        } else if (e.toString().contains('version') ||
            e.toString().contains('update')) {
          _showMessage(
              'Yazılım güncellemesi gerekiyor. Lütfen uygulamanızı güncelleyin.',
              Colors.red);
        } else if (e.toString().contains('reset') ||
            e.toString().contains('clear')) {
          _showMessage(
              'Biyometrik veriler sıfırlandı. Lütfen yeniden kaydedin.',
              Colors.orange);
        } else if (e.toString().contains('cache') ||
            e.toString().contains('storage')) {
          _showMessage(
              'Önbellek temizleme işlemi gerekiyor. Lütfen uygulama önbelleğini temizleyin.',
              Colors.orange);
        } else if (e.toString().contains('security') ||
            e.toString().contains('antivirus')) {
          _showMessage(
              'Güvenlik yazılımı engellemesi tespit edildi. Lütfen güvenlik yazılımınızı kontrol edin.',
              Colors.orange);
        } else if (e.toString().contains('factory') ||
            e.toString().contains('reset')) {
          _showMessage(
              'Fabrika ayarlarına sıfırlama gerekebilir. Lütfen yedek alın ve sıfırlayın.',
              Colors.red);
        } else if (e.toString().contains('support') ||
            e.toString().contains('contact')) {
          _showMessage(
              'Teknik destek gerekiyor. Lütfen destek ekibiyle iletişime geçin.',
              Colors.red);
        } else {
          _showMessage(
              'Kurulum sırasında hata oluştu: ${e.toString()}', Colors.red);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showBiometricOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.7),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _biometricType.toLowerCase().contains('face')
                    ? Icons.face
                    : Icons.fingerprint,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                '$_biometricType Doğrulama',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lütfen kimliğinizi doğrulayın...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipSetup() {
    widget.onSetupSkipped?.call();
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox
          .shrink(); // Biyometri mevcut değilse widget gösterme
    }

    if (_isSetup) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Biyometrik kimlik doğrulama kuruldu',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _biometricType.toLowerCase().contains('face')
                    ? Icons.face
                    : Icons.fingerprint,
                color: Colors.blue.shade700,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_biometricType ile Hızlı Giriş',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hesabınıza $_biometricType ile hızlı ve güvenli giriş yapabilirsiniz. Bu özellik cihazınızda güvenli bir şekilde saklanır.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _setupBiometric,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.security),
                  label: Text(
                    _isLoading ? 'Kuruluyor...' : '$_biometricType Kur',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _isLoading ? null : _skipSetup,
                child: const Text(
                  'Daha Sonra',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Biyometri kurulum durumu göstergecisi
class BiometricSetupStatus extends StatelessWidget {
  const BiometricSetupStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: BiometricUserService.isUserBiometricEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled ? Colors.green.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isEnabled ? Icons.security : Icons.security_outlined,
                color: isEnabled ? Colors.green.shade700 : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEnabled
                      ? 'Biyometrik giriş etkin'
                      : 'Biyometrik giriş devre dışı',
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sadece biyometri ile giriş widget'ı
class BiometricOnlyLoginWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onError;

  const BiometricOnlyLoginWidget({
    super.key,
    this.onLoginSuccess,
    this.onError,
  });

  @override
  State<BiometricOnlyLoginWidget> createState() =>
      _BiometricOnlyLoginWidgetState();
}

class _BiometricOnlyLoginWidgetState extends State<BiometricOnlyLoginWidget> {
  bool _isAvailable = false;
  bool _isLoading = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final available = await BiometricService.isBiometricAvailable();
      if (available) {
        _biometricType = await BiometricService.getBiometricTypeName();
      }

      if (mounted) {
        setState(() {
          _isAvailable = available;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri kontrol hatası: $e');
      }
    }
  }

  Future<void> _biometricLogin() async {
    if (!_isAvailable) {
      _showMessage('Bu cihazda biyometrik kimlik doğrulama mevcut değil.',
          Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BiometricService.authenticate(
        localizedReason:
            '$_biometricType ile giriş yapmak için kimlik bilgilerinizi doğrulayın',
        useErrorDialogs: true,
      );

      if (success) {
        // Son giriş zamanını güncelle
        await BiometricUserService.updateLastBiometricLogin();

        widget.onLoginSuccess?.call();
        _showMessage('Başarıyla giriş yapıldı! 🎉', Colors.green);
      } else {
        _showMessage('Kimlik doğrulama başarısız.', Colors.red);
        widget.onError?.call();
      }
    } catch (e) {
      _showMessage('Giriş sırasında hata oluştu: ${e.toString()}', Colors.red);
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _biometricLogin,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                _biometricType.toLowerCase().contains('face')
                    ? Icons.face
                    : Icons.fingerprint,
                color: Colors.white,
              ),
        label: Text(
          _isLoading
              ? 'Kimlik doğrulanıyor...'
              : 'Sadece $_biometricType ile Giriş Yap',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
