// lib/services/quiz_settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../enums/app_language.dart';
import 'dart:convert';

/// Quiz ayarlarını temsil eden model
class QuizSettings {
  final String? category;
  final DifficultyLevel? difficulty;
  final AppLanguage language;
  final String? backgroundColor; // Arka plan rengi (future için)
  final String? mode; // 'normal', 'quick-duel', vb (future için)
  final DateTime savedAt;

  QuizSettings({
    this.category,
    this.difficulty,
    required this.language,
    this.backgroundColor,
    this.mode,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'difficulty': difficulty?.toString(),
      'language': language.code,
      'backgroundColor': backgroundColor,
      'mode': mode,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  static QuizSettings fromJson(Map<String, dynamic> json) {
    DifficultyLevel? difficulty;
    if (json['difficulty'] != null) {
      try {
        difficulty = DifficultyLevel.values.firstWhere(
          (e) => e.toString() == json['difficulty'],
          orElse: () => DifficultyLevel.medium,
        );
      } catch (e) {
        difficulty = DifficultyLevel.medium;
      }
    }

    AppLanguage language;
    try {
      language = AppLanguage.values.firstWhere(
        (e) => e.code == json['language'],
        orElse: () => AppLanguage.turkish,
      );
    } catch (e) {
      language = AppLanguage.turkish;
    }

    return QuizSettings(
      category: json['category'] as String?,
      difficulty: difficulty,
      language: language,
      backgroundColor: json['backgroundColor'] as String?,
      mode: json['mode'] as String?,
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Service for persisting and managing quiz settings across sessions
/// Çözüm: Ayarlar birinci oturumda saklanır, tekrar sorulmaz
class QuizSettingsService {
  static const String _settingsKey = 'quiz_settings';
  static const String _hasSettingsKey = 'quiz_has_settings';

  static final QuizSettingsService _instance = QuizSettingsService._internal();

  factory QuizSettingsService() => _instance;
  QuizSettingsService._internal();

  /// Quiz ayarlarını kaydet
  Future<void> saveQuizSettings(QuizSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
      await prefs.setBool(_hasSettingsKey, true);
    } catch (e) {
      print('Error saving quiz settings: $e');
    }
  }

  /// Kaydedilmiş quiz ayarlarını getir
  Future<QuizSettings?> getQuizSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSettings = prefs.getBool(_hasSettingsKey) ?? false;
      
      if (!hasSettings) return null;

      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson == null) return null;

      return QuizSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      print('Error loading quiz settings: $e');
      return null;
    }
  }

  /// Quiz ayarlarının mevcut olup olmadığını kontrol et
  Future<bool> hasQuizSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasSettingsKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Quiz ayarlarını temizle
  Future<void> clearQuizSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      await prefs.setBool(_hasSettingsKey, false);
    } catch (e) {
      print('Error clearing quiz settings: $e');
    }
  }

  /// Ayarlar tarafından önceden belirlenmiş ve şimdiye kadar kaynağı değişmemiş olup olmadığını kontrol et
  Future<bool> shouldUseStoredSettings() async {
    try {
      final settings = await getQuizSettings();
      if (settings == null) return false;

      // 7 gün önceki ayarları temizle (opsiyonel)
      final now = DateTime.now();
      final difference = now.difference(settings.savedAt);
      
      if (difference.inDays > 7) {
        await clearQuizSettings();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
