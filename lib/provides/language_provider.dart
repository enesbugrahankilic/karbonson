// lib/provides/language_provider.dart
import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();

  LanguageService get languageService => _languageService;

  // Proxy methods for easier access
  AppLanguage get currentLanguage => _languageService.currentLanguage;
  Locale get locale => _languageService.locale;
  String get currentLanguageName => _languageService.currentLanguageName;
  String get currentLanguageFlag => _languageService.currentLanguageFlag;

  Future<void> setLanguage(AppLanguage language) async {
    await _languageService.setLanguage(language);
    notifyListeners();
  }

  @override
  void dispose() {
    _languageService.dispose();
    super.dispose();
  }
}