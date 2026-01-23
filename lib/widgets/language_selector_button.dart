import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../theme/theme_colors.dart';
import '../provides/language_provider.dart';
import '../enums/app_language.dart';

class LanguageSelectorButton extends StatelessWidget {
  LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isTurkish = languageProvider.currentLanguage == AppLanguage.turkish;
        final flag = isTurkish ? '🇹🇷' : '🇺🇸';
        final languageCode = isTurkish ? 'TR' : 'EN';

        return GestureDetector(
          onTap: () => _showLanguageDialog(context, languageProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  languageCode,
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: ThemeColors.getSecondaryText(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    final isTurkishCurrent = languageProvider.currentLanguage == AppLanguage.turkish;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getCardBackground(context),
                ThemeColors.getCardBackground(context).withValues(alpha: 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dil Seçin',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Türkçe'),
                subtitle: const Text('Türkiye'),
                trailing: isTurkishCurrent 
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: isTurkishCurrent
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await languageProvider.setLanguage(AppLanguage.turkish);
                        if (kDebugMode) {
                          debugPrint('Language changed to Turkish');
                        }
                      },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                subtitle: const Text('United States'),
                trailing: !isTurkishCurrent 
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: !isTurkishCurrent
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await languageProvider.setLanguage(AppLanguage.english);
                        if (kDebugMode) {
                          debugPrint('Language changed to English');
                        }
                      },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
