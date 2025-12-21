import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';
import '../services/biometric_user_service.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';

/// Biyometrik durumunu gösteren ve yöneten kart widget'ı
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
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  String _biometricType = 'Biyometrik';

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    setState(() => _isLoading = true);

    try {
      // Biyometrik desteğini kontrol et
      final isAvailable = await BiometricService.isBiometricAvailable();
      final availableBiometrics =
          await BiometricService.getAvailableBiometrics();

      // Biyometrik türü belirle
      String biometricType = 'Biyometrik';
      if (availableBiometrics.contains(BiometricType.face)) {
        biometricType = 'Yüz Tanıma';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        biometricType = 'Parmak İzi';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        biometricType = 'İris Taraması';
      }

      // Kullanıcının biyometri ayarını kontrol et
      final isEnabled = await BiometricUserService.isUserBiometricEnabled();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isBiometricEnabled = isEnabled;
          _biometricType = biometricType;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometrik durum kontrol hatası: $e');
      }
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBiometric() async {
    if (!_isBiometricAvailable) return;

    setState(() => _isLoading = true);

    try {
      if (_isBiometricEnabled) {
        // Biyometriyi devre dışı bırak
        final success = await BiometricUserService.disableBiometric();
        if (success) {
          setState(() => _isBiometricEnabled = false);
          widget.onBiometricDisabled?.call();
          _showMessage('Biyometrik giriş devre dışı bırakıldı', isError: false);
        } else {
          _showMessage('Biyometrik giriş devre dışı bırakılamadı',
              isError: true);
        }
      } else {
        // Biyometriyi etkinleştir
        final success = await BiometricUserService.saveBiometricSetup();
        if (success) {
          setState(() => _isBiometricEnabled = true);
          widget.onBiometricEnabled?.call();
          _showMessage('Biyometrik giriş etkinleştirildi', isError: false);
        } else {
          _showMessage('Biyometrik giriş etkinleştirilemedi', isError: true);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometrik toggle hatası: $e');
      }
      _showMessage('Biyometrik ayarları değiştirilemedi', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? ThemeColors.getErrorColor(context)
            : ThemeColors.getSuccessColor(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
      decoration: DesignSystem.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  _isBiometricEnabled
                      ? Icons.fingerprint
                      : Icons.fingerprint_outlined,
                  color: _isBiometricEnabled
                      ? ThemeColors.getSuccessColor(context)
                      : ThemeColors.getSecondaryText(context),
                  size: 24,
                ),
                const SizedBox(width: DesignSystem.spacingS),
                Text(
                  'Biyometrik Giriş',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.getText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacingM),

            // Durum açıklaması
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (!_isBiometricAvailable)
              Text(
                'Bu cihazda biyometrik kimlik doğrulama desteklenmiyor.',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: 14,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isBiometricEnabled
                        ? '$_biometricType ile hızlı giriş aktif'
                        : '$_biometricType ile hızlı girişi etkinleştirin',
                    style: TextStyle(
                      color: ThemeColors.getText(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacingS),
                  Text(
                    _isBiometricEnabled
                        ? 'Güvenli ve hızlı giriş için biyometrik kimlik doğrulama kullanılıyor.'
                        : 'Parola girmek yerine $_biometricType kullanarak giriş yapabilirsiniz.',
                    style: TextStyle(
                      color: ThemeColors.getSecondaryText(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: DesignSystem.spacingL),

            // Toggle butonu
            if (_isLoading || !_isBiometricAvailable)
              const SizedBox()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleBiometric,
                  icon: Icon(
                    _isBiometricEnabled ? Icons.lock_open : Icons.lock,
                    size: 20,
                  ),
                  label: Text(
                    _isBiometricEnabled ? 'Devre Dışı Bırak' : 'Etkinleştir',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
