import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isHighContrast = false;

  bool get isDarkMode => _isDarkMode;
  bool get isHighContrast => _isHighContrast;

  ThemeMode get themeMode {
    if (_isHighContrast)
      return ThemeMode.light; // High contrast is always light
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isHighContrast = prefs.getBool('isHighContrast') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _isHighContrast =
        false; // Disable high contrast when toggling dark/light mode
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isHighContrast', false);
    notifyListeners();
  }

  Future<void> toggleHighContrast() async {
    _isHighContrast = !_isHighContrast;
    if (_isHighContrast) {
      _isDarkMode = false; // High contrast implies light mode
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isHighContrast', _isHighContrast);
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Accessibility helpers
  String getCurrentThemeDescription() {
    if (_isHighContrast) {
      return 'Yüksek Kontrast';
    }
    return _isDarkMode ? 'Koyu Tema' : 'Açık Tema';
  }

  bool isAccessibilityModeEnabled() {
    return _isHighContrast;
  }
}
