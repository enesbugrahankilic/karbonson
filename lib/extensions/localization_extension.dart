import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../provides/language_provider.dart';
import '../enums/app_language.dart';
import '../l10n/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  LanguageProvider get languageProvider => read<LanguageProvider>();
  AppLanguage get currentLanguage => languageProvider.currentLanguage;
  bool get isTurkish => currentLanguage == AppLanguage.turkish;
  bool get isEnglish => currentLanguage == AppLanguage.english;

  /// Get localized string based on current language
  String t(String turkish, String english) {
    return isTurkish ? turkish : english;
  }

  /// Get AppLocalizations instance for current locale
  AppLocalizations? get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations);
  }

  /// Get localized string with fallback to English if l10n is not available
  String getLocalizedString(String Function(AppLocalizations) getter) {
    final localizations = l10n;
    if (localizations != null) {
      return getter(localizations);
    }
    
    // Fallback to English strings if localization is not loaded yet
    if (getter.toString().contains('loading')) return 'Loading...';
    if (getter.toString().contains('startupError')) return 'Startup Error';
    if (getter.toString().contains('startupErrorDescription')) return 'An error occurred during app startup. Please try again.';
    if (getter.toString().contains('retry')) return 'Retry';
    if (getter.toString().contains('appNameHighContrast')) return 'Eco Game (High Contrast)';
    if (getter.toString().contains('appName')) return 'Eco Game';
    
    return 'Loading...';
  }
}
