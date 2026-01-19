// lib/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/app_language.dart';

/// Callback typedef for language change events
typedef LanguageChangeCallback = void Function(AppLanguage newLanguage);

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.turkish;
  bool _isInitialized = false;
  
  // Callback for app-level rebuild when language changes
  static LanguageChangeCallback? _onLanguageChanged;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;

  LanguageService() {
    _loadLanguage();
  }

  /// Set a callback to be called when language changes
  /// This is used by the app root to force MaterialApp rebuild
  static void setLanguageChangeCallback(LanguageChangeCallback callback) {
    _onLanguageChanged = callback;
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
      
      // Notify all listeners first
      notifyListeners();
      
      // Call the app-level callback to force complete app rebuild
      // This ensures all pages instantly reflect the new language
      _onLanguageChanged?.call(language);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Locale get locale => Locale(_currentLanguage.code);

  String get currentLanguageName => _currentLanguage.displayName;
  String get currentLanguageFlag => _currentLanguage.flag;
}
