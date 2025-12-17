import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/biometric_service.dart';
import '../services/biometric_user_service.dart';
import '../theme/theme_colors.dart';

/// Biyometrik giriş widget'ı - sadece biyometri ile giriş
class BiometricOnlyLoginWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onError;

  const BiometricOnlyLoginWidget({
    Key? key,
    this.onLoginSuccess,
    this.onError,
  }) : super(key: key);

  @override
  State<BiometricOnlyLoginWidget> createState() => _BiometricOnlyLoginWidgetState();
}

class _BiometricOnlyLoginWidgetState extends State<BiometricOnlyLoginWidget> {
  bool _isAvailable = false;
  bool _isLoading = false;
  String _biometricType = '';
  String _statusMessage = '';

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
          _statusMessage = available ? '$_biometricType ile hızlı giriş' : 'Biyometrik giriş mevcut değil';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri kontrol hatası: $e');
      }
      if (mounted) {
        setState(() {
          _statusMessage = 'Biyometrik kontrol edilemedi';
        });
      }
    }
  }

  Future<void> _performBiometricLogin() async {
    if (!_isAvailable) {
      _showError('Bu cihazda biyometrik kimlik doğrulama mevcut değil.');
      widget.onError?.call();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Kimlik doğrulanıyor...';
    });

    try {
      // Biyometrik kimlik doğrulama
      final biometricSuccess = await BiometricService.authenticateWithBiometrics(
        localizedReason: '$_biometricType ile hızlı giriş yapmak için kimlik bilgilerinizi doğrulayın',
        useErrorDialogs: true,
      );

      if (!biometricSuccess) {
        _showError('Biyometrik kimlik doğrulama başarısız. Lütfen email/şifre ile giriş yapmayı deneyin.');
        widget.onError?.call();
        return;
      }

      // Biyometrik başarılı, kayıtlı kullanıcı bilgilerini al
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('Kullanıcı oturumu bulunamadı. Lütfen email/şifre ile giriş yapın.');
        widget.onError?.call();
        return;
      }

      // Biyometri giriş zamanını güncelle
      await BiometricUserService.updateLastBiometricLogin();

      if (kDebugMode) {
        debugPrint('✅ Biyometrik giriş başarılı: ${user.uid}');
      }

      _showSuccess('Başarıyla giriş yapıldı! 🎉');
      widget.onLoginSuccess?.call();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometrik giriş hatası: $e');
      }
      _showError('Kimlik doğrulama sırasında hata oluştu. Lütfen tekrar deneyin.');
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = _isAvailable ? '$_biometricType ile hızlı giriş' : 'Biyometrik giriş mevcut değil';
        });
      }
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Icon _getBiometricIcon() {
    if (_biometricType.toLowerCase().contains('face') || _biometricType.toLowerCase().contains('yüz')) {
      return Icon(Icons.face, color: ThemeColors.getGreen(context), size: 28);
    } else if (_biometricType.toLowerCase().contains('parmak') || _biometricType.toLowerCase().contains('fingerprint')) {
      return Icon(Icons.fingerprint, color: ThemeColors.getGreen(context), size: 28);
    } else {
      return Icon(Icons.security, color: ThemeColors.getGreen(context), size: 28);
    }
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
        onPressed: _isLoading ? null : _performBiometricLogin,
        icon: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _getBiometricIcon(),
        label: Text(
          _isLoading ? 'Kimlik Doğrulanıyor...' : _statusMessage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.getGreen(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: ThemeColors.getGreen(context).withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

/// Gelişmiş biyometrik durum widget'ı
class BiometricStatusCard extends StatefulWidget {
  final VoidCallback? onBiometricEnabled;
  final VoidCallback? onBiometricDisabled;

  const BiometricStatusCard({
    Key? key,
    this.onBiometricEnabled,
    this.onBiometricDisabled,
  }) : super(key: key);

  @override
  State<BiometricStatusCard> createState() => _BiometricStatusCardState();
}

class _BiometricStatusCardState extends State<BiometricStatusCard> {
  bool _isEnabled = false;
  bool _isAvailable = false;
  bool _isLoading = true;
  String _biometricType = '';
  String _statusText = 'Kontrol ediliyor...';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    setState(() => _isLoading = true);

    try {
      // Cihazda biyometri mevcut mu kontrol et
      _isAvailable = await BiometricService.isBiometricAvailable();

      if (_isAvailable) {
        _biometricType = await BiometricService.getBiometricTypeName();

        // Kullanıcı biyometriyi etkinleştirmiş mi kontrol et
        _isEnabled = await BiometricUserService.isUserBiometricEnabled();

        _statusText = _isEnabled
            ? '$_biometricType etkin - Hızlı giriş kullanılabilir'
            : '$_biometricType mevcut - Kurulum gerekli';
      } else {
        _statusText = 'Bu cihazda biyometrik kimlik doğrulama mevcut değil';
      }
    } catch (e) {
      _statusText = 'Biyometrik durum kontrol edilemedi';
      if (kDebugMode) {
        debugPrint('Biyometrik durum kontrol hatası: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleBiometric() async {
    if (!_isAvailable) return;

    setState(() => _isLoading = true);

    try {
      if (_isEnabled) {
        // Biyometriyi devre dışı bırak
        final success = await BiometricUserService.disableBiometric();
        if (success) {
          setState(() => _isEnabled = false);
          _statusText = '$_biometricType devre dışı bırakıldı';
          widget.onBiometricDisabled?.call();
          _showMessage('Biyometrik giriş devre dışı bırakıldı', Colors.orange);
        } else {
          _showMessage('Biyometri devre dışı bırakılırken hata oluştu', Colors.red);
        }
      } else {
        // Biyometriyi etkinleştir
        final success = await BiometricUserService.saveBiometricSetup();
        if (success) {
          setState(() => _isEnabled = true);
          _statusText = '$_biometricType etkin - Hızlı giriş kullanılabilir';
          widget.onBiometricEnabled?.call();
          _showMessage('Biyometrik giriş başarıyla etkinleştirildi! 🎉', Colors.green);
        } else {
          _showMessage('Biyometri kurulurken hata oluştu', Colors.red);
        }
      }
    } catch (e) {
      _showMessage('İşlem sırasında hata oluştu', Colors.red);
      if (kDebugMode) {
        debugPrint('Biyometri toggle hatası: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isEnabled ? Icons.security : Icons.security_outlined,
                  color: _isEnabled ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biyometrik Giriş',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.getText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.getSecondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_isAvailable)
                  Switch(
                    value: _isEnabled,
                    onChanged: (_) => _toggleBiometric(),
                    activeColor: ThemeColors.getGreen(context),
                  ),
              ],
            ),
            if (_isEnabled && !_isLoading) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Biyometrik giriş aktif! Artık $_biometricType ile hızlı giriş yapabilirsiniz.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
}