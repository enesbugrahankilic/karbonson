import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Text-to-Speech Service for Quiz Application
/// Supports multiple languages and voice settings
class TextToSpeechService {
  static const MethodChannel _channel = MethodChannel('text_to_speech');
  
  // Singleton pattern
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  // Settings
  static const String _settingsKey = 'tts_settings';
  static const String _cacheKey = 'tts_cache_enabled';
  
  // Default values
  static const double _defaultRate = 0.5;
  static const double _defaultVolume = 0.8;
  static const double _defaultPitch = 1.0;

  // Current state
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _speechRate = _defaultRate;
  double _volume = _defaultVolume;
  double _pitch = _defaultPitch;
  String _language = 'tr-TR';
  bool _isEnabled = true;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isEnabled => _isEnabled;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get language => _language;

  /// Initialize Text-to-Speech engine
  Future<void> initialize() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final result = await _channel.invokeMethod('initialize');
        _isInitialized = result == true;
        
        if (_isInitialized) {
          await _loadSettings();
          if (kDebugMode) {
            debugPrint('✅ TTS Engine initialized successfully');
          }
        }
      } else {
        // Web or other platforms - mock initialization
        _isInitialized = true;
        await _loadSettings();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TTS initialization failed: $e');
      }
      _isInitialized = false;
    }
  }

  /// Speak text with current settings
  Future<void> speak(String text, {
    double? rate,
    double? volume,
    double? pitch,
    String? language,
  }) async {
    if (!_isEnabled || text.trim().isEmpty) return;

    try {
      // Stop current speech if speaking
      if (_isSpeaking) {
        await stop();
      }

      // Update settings for this speech
      final speechRate = rate ?? _speechRate;
      final speechVolume = volume ?? _volume;
      final speechPitch = pitch ?? _pitch;
      final speechLanguage = language ?? _language;

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final result = await _channel.invokeMethod('speak', {
          'text': text,
          'rate': speechRate,
          'volume': speechVolume,
          'pitch': speechPitch,
          'language': speechLanguage,
        });
        
        _isSpeaking = result == true;
      } else {
        // Web mock - simulate speaking
        _isSpeaking = true;
        await Future.delayed(Duration(seconds: text.length ~/ 10));
        _isSpeaking = false;
      }

      if (kDebugMode) {
        debugPrint('🔊 TTS: Speaking "${text.substring(0, min(50, text.length))}..."');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TTS speak failed: $e');
      }
      _isSpeaking = false;
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (!_isSpeaking) return;

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _channel.invokeMethod('stop');
      }
      _isSpeaking = false;
      
      if (kDebugMode) {
        debugPrint('⏹️ TTS stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TTS stop failed: $e');
      }
      _isSpeaking = false;
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (!_isSpeaking) return;

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _channel.invokeMethod('pause');
      }
      _isSpeaking = false;
      
      if (kDebugMode) {
        debugPrint('⏸️ TTS paused');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TTS pause failed: $e');
      }
    }
  }

  /// Resume paused speech
  Future<void> resume() async {
    if (_isSpeaking) return;

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final result = await _channel.invokeMethod('resume');
        _isSpeaking = result == true;
      } else {
        _isSpeaking = true;
      }
      
      if (kDebugMode) {
        debugPrint('▶️ TTS resumed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TTS resume failed: $e');
      }
      _isSpeaking = false;
    }
  }

  /// Speak question text with quiz-specific settings
  Future<void> speakQuestion(String questionText, String category) async {
    final ttsText = _formatQuestionForSpeech(questionText, category);
    await speak(ttsText);
  }

  /// Speak answer result (correct/incorrect)
  Future<void> speakAnswerResult(bool isCorrect, {String? correctAnswer}) async {
    String text;
    
    if (isCorrect) {
      text = 'Tebrikler! Doğru cevap.';
    } else {
      text = 'Yanlış cevap. ${correctAnswer != null ? 'Doğru cevap: $correctAnswer' : ''}';
    }
    
    await speak(text);
  }

  /// Format question text for speech synthesis
  String _formatQuestionForSpeech(String questionText, String category) {
    // Remove special characters that might cause issues
    String cleanText = questionText
        .replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞIİÖÇ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // Add category context
    if (category.isNotEmpty && category != 'Genel') {
      cleanText = '$category kategorisinden soru: $cleanText';
    }
    
    return cleanText;
  }

  /// Update TTS settings
  Future<void> updateSettings({
    double? rate,
    double? volume,
    double? pitch,
    String? language,
    bool? enabled,
  }) async {
    if (rate != null) _speechRate = rate.clamp(0.1, 2.0);
    if (volume != null) _volume = volume.clamp(0.0, 1.0);
    if (pitch != null) _pitch = pitch.clamp(0.5, 2.0);
    if (language != null) _language = language;
    if (enabled != null) _isEnabled = enabled;

    await _saveSettings();

    if (kDebugMode) {
      debugPrint('🔧 TTS settings updated - Rate: $_speechRate, Volume: $_volume, Pitch: $_pitch, Lang: $_language');
    }
  }

  /// Get available languages
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'tr-TR', 'name': 'Türkçe'},
      {'code': 'en-US', 'name': 'English (US)'},
      {'code': 'en-GB', 'name': 'English (UK)'},
      {'code': 'de-DE', 'name': 'Deutsch'},
      {'code': 'fr-FR', 'name': 'Français'},
      {'code': 'es-ES', 'name': 'Español'},
      {'code': 'it-IT', 'name': 'Italiano'},
      {'code': 'ru-RU', 'name': 'Русский'},
      {'code': 'ar-SA', 'name': 'العربية'},
    ];
  }

  /// Check if TTS is supported on current platform
  bool get isSupported {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _speechRate = prefs.getDouble('${_settingsKey}_rate') ?? _defaultRate;
      _volume = prefs.getDouble('${_settingsKey}_volume') ?? _defaultVolume;
      _pitch = prefs.getDouble('${_settingsKey}_pitch') ?? _defaultPitch;
      _language = prefs.getString('${_settingsKey}_language') ?? 'tr-TR';
      _isEnabled = prefs.getBool('${_settingsKey}_enabled') ?? true;
      
      if (kDebugMode) {
        debugPrint('📱 TTS settings loaded from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load TTS settings: $e');
      }
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setDouble('${_settingsKey}_rate', _speechRate);
      await prefs.setDouble('${_settingsKey}_volume', _volume);
      await prefs.setDouble('${_settingsKey}_pitch', _pitch);
      await prefs.setString('${_settingsKey}_language', _language);
      await prefs.setBool('${_settingsKey}_enabled', _isEnabled);
      
      if (kDebugMode) {
        debugPrint('💾 TTS settings saved to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save TTS settings: $e');
      }
    }
  }

  /// Get TTS settings as map
  Map<String, dynamic> getSettings() {
    return {
      'enabled': _isEnabled,
      'rate': _speechRate,
      'volume': _volume,
      'pitch': _pitch,
      'language': _language,
      'initialized': _isInitialized,
      'speaking': _isSpeaking,
    };
  }

  /// Dispose resources
  void dispose() {
    if (_isSpeaking) {
      stop();
    }
    
    if (kDebugMode) {
      debugPrint('🗑️ TTS service disposed');
    }
  }
}
