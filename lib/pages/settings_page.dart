import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provides/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Tema Ayarları'),
                  subtitle: Text(
                    themeProvider.isDarkMode ? 'Karanlık Mod Aktif' : 'Aydınlık Mod Aktif',
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
                        Icons.info,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: const Text('Uygulama Bilgisi'),
                      subtitle: const Text('Karbon Son v1.0'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      title: const Text('Tema Önizleme'),
                      subtitle: const Text('Mevcut tema renklerini görüntüle'),
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
                      title: const Text('Erişilebilirlik'),
                      subtitle: const Text('Görme ve işitme ayarları'),
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
                      title: const Text('Bildirimler'),
                      subtitle: const Text('Oyun bildirimlerini yönet'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showNotificationSettings(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemePreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Önizlemesi'),
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
                  'Ana Renk',
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
                  'İkincil Renk',
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
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Center(
                child: Text(
                  'Yüzey Rengi',
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
            child: const Text('Kapat'),
          ),
        ],
      ),
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
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
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
}