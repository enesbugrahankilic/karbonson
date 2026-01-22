import 'package:flutter/material.dart';
import '../widgets/page_templates.dart';

class ComprehensiveTwoFactorAuthSetupPage extends StatefulWidget {
  const ComprehensiveTwoFactorAuthSetupPage({super.key});

  @override
  State<ComprehensiveTwoFactorAuthSetupPage> createState() =>
      _ComprehensiveTwoFactorAuthSetupPageState();
}

class _ComprehensiveTwoFactorAuthSetupPageState
    extends State<ComprehensiveTwoFactorAuthSetupPage> {
  late final int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('İki Faktörlü Kimlik Doğrulama'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesabınızı Koruyun',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildMethodCard(
                title: 'SMS ile Doğrulama',
                description: 'Telefon numaranıza gelen kodları kullanın',
                icon: Icons.sms,
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                title: 'Authenticator Uygulaması',
                description: 'Google Authenticator gibi uygulamalar kullanın',
                icon: Icons.security,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Geri Dön'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}
