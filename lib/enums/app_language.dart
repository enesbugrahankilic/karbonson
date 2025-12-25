// lib/enums/app_language.dart

/// Uygulama dilleri enum'u
enum AppLanguage {
  turkish('tr', 'Türkçe', '🇹🇷'),
  english('en', 'English', '🇺🇸');

  const AppLanguage(this.code, this.displayName, this.flag);
  final String code;
  final String displayName;
  final String flag;
}
