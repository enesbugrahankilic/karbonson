import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provides/language_provider.dart';
import '../services/language_service.dart';
import '../theme/theme_colors.dart';

class LanguageSelectorButton extends StatelessWidget {
  final bool isInAppBar;

  const LanguageSelectorButton({
    super.key,
    this.isInAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (isInAppBar) {
          return PopupMenuButton<AppLanguage>(
            onSelected: (AppLanguage language) {
              languageProvider.setLanguage(language);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<AppLanguage>>[
              PopupMenuItem<AppLanguage>(
                value: AppLanguage.turkish,
                child: Row(
                  children: [
                    const Text('🇹🇷 ', style: TextStyle(fontSize: 18)),
                    const Text('Türkçe'),
                    if (languageProvider.currentLanguage == AppLanguage.turkish)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          Icons.check,
                          color: ThemeColors.getGreen(context),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuItem<AppLanguage>(
                value: AppLanguage.english,
                child: Row(
                  children: [
                    const Text('🇬🇧 ', style: TextStyle(fontSize: 18)),
                    const Text('English'),
                    if (languageProvider.currentLanguage == AppLanguage.english)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          Icons.check,
                          color: ThemeColors.getGreen(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      languageProvider.currentLanguageFlag,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Compact button for inline usage
          return IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showLanguageDialog(context, languageProvider);
            },
            tooltip: 'Dil Seçin / Select Language',
          );
        }
      },
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dil Seçin / Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('🇹🇷 Türkçe'),
                onTap: () {
                  languageProvider.setLanguage(AppLanguage.turkish);
                  Navigator.pop(context);
                },
                selected:
                    languageProvider.currentLanguage == AppLanguage.turkish,
                trailing: languageProvider.currentLanguage ==
                        AppLanguage.turkish
                    ? Icon(Icons.check, color: ThemeColors.getGreen(context))
                    : null,
              ),
              ListTile(
                title: const Text('🇬🇧 English'),
                onTap: () {
                  languageProvider.setLanguage(AppLanguage.english);
                  Navigator.pop(context);
                },
                selected:
                    languageProvider.currentLanguage == AppLanguage.english,
                trailing:
                    languageProvider.currentLanguage == AppLanguage.english
                        ? Icon(Icons.check, color: ThemeColors.getGreen(context))
                        : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
