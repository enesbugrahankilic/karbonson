// lib/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  turkish('tr', 'Türkçe', '🇹🇷'),
  english('en', 'English', '🇺🇸');

  const AppLanguage(this.code, this.displayName, this.flag);
  final String code;
  final String displayName;
  final String flag;
}

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.turkish;

  AppLanguage get currentLanguage => _currentLanguage;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? AppLanguage.turkish.code;
      
      _currentLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => AppLanguage.turkish,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
      _currentLanguage = language;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Locale get locale => Locale(_currentLanguage.code);
  
  String get currentLanguageName => _currentLanguage.displayName;
  String get currentLanguageFlag => _currentLanguage.flag;
}