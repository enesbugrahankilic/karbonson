// lib/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/app_language.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.turkish;
  bool _isInitialized = false;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode =
          prefs.getString(_languageKey) ?? AppLanguage.turkish.code;

      _currentLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => AppLanguage.turkish,
      );

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
      _isInitialized = true;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
      _currentLanguage = language;
      notifyListeners();
      
      // Force MaterialApp rebuild by clearing the app key
      // This will trigger a complete rebuild with the new locale
      _forceAppRebuild();
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  void _forceAppRebuild() {
    // This will be called to force MaterialApp rebuild
    // The actual implementation will be in the widget that uses this service
    notifyListeners();
  }

  Locale get locale => Locale(_currentLanguage.code);

  String get currentLanguageName => _currentLanguage.displayName;
  String get currentLanguageFlag => _currentLanguage.flag;
}
