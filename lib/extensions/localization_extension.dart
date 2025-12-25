import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../provides/language_provider.dart';
import '../enums/app_language.dart';

extension LocalizedBuildContext on BuildContext {
  LanguageProvider get languageProvider => read<LanguageProvider>();
  AppLanguage get currentLanguage => languageProvider.currentLanguage;
  bool get isTurkish => currentLanguage == AppLanguage.turkish;
  bool get isEnglish => currentLanguage == AppLanguage.english;

  /// Get localized string based on current language
  String t(String turkish, String english) {
    return isTurkish ? turkish : english;
  }
}
