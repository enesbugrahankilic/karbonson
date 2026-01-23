import 'package:flutter/material.dart';
import '../widgets/login_dialog.dart';
import '../theme/theme_colors.dart';

/// Kapsamlı giriş seçenekleri widget'ı
/// Tüm giriş yöntemlerini (email/şifre, biyometri, SMS OTP, email OTP) bir arada sunar
class AuthenticationOptionsWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onError;
  final bool showAsDialog;

  const AuthenticationOptionsWidget({
    super.key,
    this.onLoginSuccess,
    this.onError,
    this.showAsDialog = false,
  });

  @override
  State<AuthenticationOptionsWidget> createState() =>
      _AuthenticationOptionsWidgetState();
}

class _AuthenticationOptionsWidgetState
    extends State<AuthenticationOptionsWidget> {

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
                Icon(Icons.email,
                    color: ThemeColors.getGreen(context), size: 28),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
            Icon(Icons.security,
                color: ThemeColors.getGreen(context), size: 28),
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
                _buildEmailPasswordLogin(),
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
              ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.1),
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

              // Giriş yöntemleri
              _buildEmailPasswordLogin(),
            ],
          ),
        ),
      ),
    );
  }
}
