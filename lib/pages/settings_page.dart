import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provides/theme_provider.dart';
import '../provides/language_provider.dart';
import '../enums/app_language.dart';
import '../l10n/app_localizations.dart';
import '../pages/two_factor_auth_setup_page.dart';
import '../widgets/page_templates.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: 'Ayarlar',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Consumer2<ThemeProvider, LanguageProvider>(
          builder: (context, themeProvider, languageProvider, child) {
            final l10n = AppLocalizations.of(context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Tema'),
                StandardListItem(
                  leading: Icon(
                    themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(l10n?.theme ?? 'Theme Settings'),
                    subtitle: Text(
                      themeProvider.isDarkMode
                          ? (l10n?.darkMode ?? 'Dark Mode Active')
                          : (l10n?.lightMode ?? 'Light Mode Active'),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.language,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(l10n?.language ?? 'Language Settings'),
                        subtitle: Text(
                          '${languageProvider.currentLanguageFlag} ${languageProvider.currentLanguageName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showLanguageSelection(context, languageProvider);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(l10n?.about ?? 'About'),
                        subtitle: Text(l10n?.version ?? 'Version'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.palette,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        title: Text(l10n?.theme ?? 'Theme Preview'),
                        subtitle: Text(l10n?.settings ?? 'View current theme colors'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showThemePreview(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.accessibility,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(l10n?.settings ?? 'Accessibility'),
                        subtitle: Text(l10n?.settings ?? 'Visual and audio settings'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showAccessibilitySettings(context);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.notifications,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(l10n?.notifications ?? 'Notifications'),
                        subtitle: Text(l10n?.settings ?? 'Manage game notifications'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showNotificationSettings(context);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(l10n?.settings ?? 'Security Settings'),
                        subtitle: Text(l10n?.twoFactorAuth ?? 'Two-factor authentication and other security options'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showSecuritySettings(context);
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Developer/Debug Section (only show in debug mode)
                if (kDebugMode)
                  Card(
                    color: Colors.orange.shade50,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.developer_mode,
                            color: Colors.orange,
                          ),
                          title: const Text('Geliştirici Araçları'),
                          subtitle: const Text('Debug ve test araçları'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.security,
                            color: Colors.red,
                          ),
                          title: const Text('UID Debug & Cleanup'),
                          subtitle: const Text(
                              'UID tutarsızlıklarını kontrol et ve temizle'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // UID Debug page removed during cleanup
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UID Debug page is no longer available')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showThemePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.theme ?? 'Theme Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  l10n?.settings ?? 'Primary Color',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  l10n?.settings ?? 'Secondary Color',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Center(
                child: Text(
                  l10n?.settings ?? 'Surface Color',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      );
      },
    );
  }

  void _showAccessibilitySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erişilebilirlik Ayarları'),
        content: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.highlight,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Yüksek Kontrast',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                themeProvider.isHighContrast
                                    ? 'Aktif - WCAG AA uyumlu renkler'
                                    : 'Kapalı - Standart renkler',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity( 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: themeProvider.isHighContrast,
                          onChanged: (value) {
                            setState(() {
                              themeProvider.toggleHighContrast();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Metin Ölçekleme',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Sistem ayarlarını takip et',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity( 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.info_outline, size: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dokunma Hedefleri',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '48dp minimum dokunma alanı',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity( 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirim Ayarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Oyun başlangıcı'),
            Text('• Sıra bildirimleri'),
            Text('• Arkadaş istekleri'),
            Text('• Günlük hatırlatmalar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection(
      BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.language ?? 'Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
                return RadioListTile<AppLanguage>(
                  title: Text('${language.flag} ${language.displayName}'),
                  value: language,
                  groupValue: languageProvider.currentLanguage,
                  onChanged: languageProvider.currentLanguage == language
                      ? null
                      : (AppLanguage? value) async {
                          if (value != null) {
                            Navigator.of(context).pop();
                            await languageProvider.setLanguage(value);
                          }
                        },
                );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      );
      },
    );
  }

  void _showSecuritySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güvenlik Ayarları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('İki Faktörlü Doğrulama'),
              subtitle: const Text('Hesabınıza ek güvenlik katmanı ekleyin'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TwoFactorAuthSetupPage(),
                  ),
                );
              },
            ),
            const Divider(),
            const Text(
              'Güvenlik ipuçları:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Güçlü şifreler kullanın'),
            const Text('• Düzenli olarak şifrenizi güncelleyin'),
            const Text('• İki faktörlü doğrulamayı etkinleştirin'),
            const Text('• Şüpheli aktiviteleri bildirin'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }


}
