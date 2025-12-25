// lib/provides/language_provider.dart
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart' as AL;
import '../enums/app_language.dart';

class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();

  LanguageService get languageService => _languageService;

  // Proxy methods for easier access
  AppLanguage get currentLanguage => _languageService.currentLanguage;
  Locale get locale => _languageService.locale;
  String get currentLanguageName => _languageService.currentLanguageName;
  String get currentLanguageFlag => _languageService.currentLanguageFlag;

  Future<void> setLanguage(AppLanguage language) async {
    if (_languageService.currentLanguage == language) return;
    await _languageService.setLanguage(language);
    // Update AppLocalizations too (convert enum from enums/app_language.dart to the one used by AppLocalizations)
    final alLanguage = AL.AppLanguage.values.firstWhere(
      (e) => e.toString().split('.').last == language.toString().split('.').last,
    );
    AL.AppLocalizations.setLanguage(alLanguage);
    notifyListeners();
  }

}
