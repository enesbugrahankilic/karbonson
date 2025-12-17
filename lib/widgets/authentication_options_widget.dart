import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/biometric_only_login_widget.dart';
import '../widgets/sms_otp_login_widget.dart';
import '../widgets/email_otp_login_widget.dart';
import '../widgets/login_dialog.dart';
import '../services/biometric_user_service.dart';
import '../theme/theme_colors.dart';

/// Kapsamlı giriş seçenekleri widget'ı
/// Tüm giriş yöntemlerini (email/şifre, biyometri, SMS OTP, email OTP) bir arada sunar
class AuthenticationOptionsWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onError;
  final bool showAsDialog;

  const AuthenticationOptionsWidget({
    Key? key,
    this.onLoginSuccess,
    this.onError,
    this.showAsDialog = false,
  }) : super(key: key);

  @override
  State<AuthenticationOptionsWidget> createState() => _AuthenticationOptionsWidgetState();
}

class _AuthenticationOptionsWidgetState extends State<AuthenticationOptionsWidget> {
  AuthMethod _selectedMethod = AuthMethod.emailPassword;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final available = await BiometricUserService.isUserBiometricEnabled();
      if (mounted) {
        setState(() {
          _biometricAvailable = available;
          _biometricEnabled = available;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri durumu kontrol hatası: $e');
      }
    }
  }

  void _onMethodSelected(AuthMethod method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackgroundLight(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.getBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giriş Yöntemi Seçin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeColors.getText(context),
            ),
          ),
          const SizedBox(height: 16),
          _buildMethodOption(
            AuthMethod.emailPassword,
            'Email & Şifre',
            'Kullanıcı adı ve şifre ile giriş',
            Icons.email,
            ThemeColors.getPrimaryButtonColor(context),
          ),
          if (_biometricAvailable) ...[
            const SizedBox(height: 8),
            _buildMethodOption(
              AuthMethod.biometric,
              'Biyometrik Giriş',
              'Parmak izi veya yüz tanıma ile hızlı giriş',
              Icons.fingerprint,
              ThemeColors.getGreen(context),
            ),
          ],
          const SizedBox(height: 8),
          _buildMethodOption(
            AuthMethod.smsOtp,
            'SMS ile Giriş',
            'Telefon numaranıza SMS kodu gönderin',
            Icons.sms,
            ThemeColors.getSecondaryButtonColor(context),
          ),
          const SizedBox(height: 8),
          _buildMethodOption(
            AuthMethod.emailOtp,
            'Email ile Giriş',
            'Email adresinize doğrulama kodu gönderin',
            Icons.alternate_email,
            ThemeColors.getAccentButtonColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(
    AuthMethod method,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () => _onMethodSelected(method),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : ThemeColors.getBorder(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : ThemeColors.getSecondaryText(context),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : ThemeColors.getText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMethodContent() {
    switch (_selectedMethod) {
      case AuthMethod.emailPassword:
        return _buildEmailPasswordLogin();
      case AuthMethod.biometric:
        return BiometricOnlyLoginWidget(
          onLoginSuccess: widget.onLoginSuccess,
          onError: widget.onError,
        );
      case AuthMethod.smsOtp:
        return SmsOtpLoginWidget(
          onLoginSuccess: widget.onLoginSuccess,
          onError: widget.onError,
          showAsDialog: false,
        );
      case AuthMethod.emailOtp:
        return EmailOtpLoginWidget(
          onLoginSuccess: widget.onLoginSuccess,
          onError: widget.onError,
          showAsDialog: false,
        );
    }
  }

  Widget _buildEmailPasswordLogin() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.email, color: ThemeColors.getGreen(context), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Email & Şifre ile Giriş',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.getText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Kayıt olurken kullandığınız email adresi ve şifrenizle giriş yapabilirsiniz.',
              style: TextStyle(
                color: ThemeColors.getSecondaryText(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Login dialog'ını göster
                  showDialog(
                    context: context,
                    builder: (context) => const LoginDialog(),
                  ).then((result) {
                    if (result == true) {
                      widget.onLoginSuccess?.call();
                    }
                  });
                },
                icon: const Icon(Icons.login),
                label: const Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.getGreen(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsDialog) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: ThemeColors.getDialogBackground(context),
        title: Row(
          children: [
            Icon(Icons.security, color: ThemeColors.getGreen(context), size: 28),
            const SizedBox(width: 8),
            Text(
              'Giriş Yöntemi Seçin',
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMethodSelector(),
                const SizedBox(height: 20),
                _buildSelectedMethodContent(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: TextStyle(color: ThemeColors.getSecondaryText(context)),
            ),
          ),
        ],
      );
    }

    // Normal widget görünümü
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş'),
        backgroundColor: ThemeColors.getPrimaryButtonColor(context),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
              ThemeColors.getCardBackground(context),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                'Güvenli Giriş',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.getText(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Size en uygun giriş yöntemini seçin',
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
              const SizedBox(height: 24),

              // Yöntem seçici
              _buildMethodSelector(),
              const SizedBox(height: 24),

              // Seçilen yöntem içeriği
              _buildSelectedMethodContent(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Giriş yöntemleri enum'ı
enum AuthMethod {
  emailPassword,
  biometric,
  smsOtp,
  emailOtp,
}

/// Giriş yöntemleri için extension
extension AuthMethodExtension on AuthMethod {
  String get displayName {
    switch (this) {
      case AuthMethod.emailPassword:
        return 'Email & Şifre';
      case AuthMethod.biometric:
        return 'Biyometrik';
      case AuthMethod.smsOtp:
        return 'SMS OTP';
      case AuthMethod.emailOtp:
        return 'Email OTP';
    }
  }

  String get description {
    switch (this) {
      case AuthMethod.emailPassword:
        return 'Kullanıcı adı ve şifre ile giriş';
      case AuthMethod.biometric:
        return 'Parmak izi veya yüz tanıma ile hızlı giriş';
      case AuthMethod.smsOtp:
        return 'Telefon numaranıza SMS kodu gönderin';
      case AuthMethod.emailOtp:
        return 'Email adresinize doğrulama kodu gönderin';
    }
  }

  IconData get icon {
    switch (this) {
      case AuthMethod.emailPassword:
        return Icons.email;
      case AuthMethod.biometric:
        return Icons.fingerprint;
      case AuthMethod.smsOtp:
        return Icons.sms;
      case AuthMethod.emailOtp:
        return Icons.alternate_email;
    }
  }
}