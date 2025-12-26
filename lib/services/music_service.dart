import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background Music Service for Quiz Application
/// Handles ambient background music and thematic soundscapes
class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  // Settings
  static const String _settingsKey = 'music_settings';
  static const String _currentTrackKey = 'music_current_track';
  
  // Default values
  static const double _defaultVolume = 0.4;
  static const bool _defaultEnabled = true;
  static const String _defaultCategory = 'ambient';

  // Music categories
  static const List<Map<String, String>> _musicCategories = [
    {'id': 'ambient', 'name': 'Ambient', 'description': 'Huzur verici doğa sesleri'},
    {'id': 'focus', 'name': 'Fokus', 'description': 'Konsantrasyon artırıcı müzik'},
    {'id': 'energetic', 'name': 'Enerjik', 'description': 'Motivasyonel ritimler'},
    {'id': 'classical', 'name': 'Klasik', 'description': 'Sakinleştirici klasik eserler'},
    {'id': 'electronic', 'name': 'Elektronik', 'description': 'Modern elektronik melodiler'},
  ];

  // Random number generator
  final Random _random = Random();
  
  // Current state
  bool _isInitialized = false;
  bool _isEnabled = _defaultEnabled;
  double _volume = _defaultVolume;
  String _currentCategory = _defaultCategory;
  bool _isPlaying = false;
  String? _currentTrack;
  bool _isLooping = true;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  double get volume => _volume;
  String get currentCategory => _currentCategory;
  bool get isPlaying => _isPlaying;
  String? get currentTrack => _currentTrack;
  bool get isLooping => _isLooping;

  /// Initialize music service
  Future<void> initialize() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _loadSettings();
        _isInitialized = true;
        
        if (kDebugMode) {
          debugPrint('✅ Music Service initialized');
        }
      } else {
        // Web or other platforms - mock initialization
        _isInitialized = true;
        await _loadSettings();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Music Service initialization failed: $e');
      }
      _isInitialized = false;
    }
  }

  /// Start playing background music for current category
  Future<void> playBackgroundMusic() async {
    if (!_isEnabled) return;

    try {
      if (_isPlaying) {
        await stopMusic();
      }

      _currentTrack = _generateTrackName(_currentCategory);
      _isPlaying = true;

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Simulate playing music with a timed loop
        await _simulateMusicPlayback();
      } else {
        // Web fallback - just set playing state
        if (kDebugMode) {
          debugPrint('🎵 Web mode: Simulating music playback');
        }
      }

      await _saveCurrentTrack();

      if (kDebugMode) {
        debugPrint('🎵 Background music started: $_currentTrack');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to start background music: $e');
      }
      _isPlaying = false;
    }
  }

  /// Stop current music
  Future<void> stopMusic() async {
    if (!_isPlaying) return;

    try {
      _isPlaying = false;
      _currentTrack = null;

      if (kDebugMode) {
        debugPrint('⏹️ Background music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to stop music: $e');
      }
    }
  }

  /// Pause music playback
  Future<void> pauseMusic() async {
    if (!_isPlaying) return;

    try {
      _isPlaying = false;
      
      if (kDebugMode) {
        debugPrint('⏸️ Background music paused');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to pause music: $e');
      }
    }
  }

  /// Resume music playback
  Future<void> resumeMusic() async {
    if (_isPlaying || !_isEnabled) return;

    try {
      _isPlaying = true;
      
      if (kDebugMode) {
        debugPrint('▶️ Background music resumed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to resume music: $e');
      }
    }
  }

  /// Change music category and restart playback
  Future<void> changeCategory(String categoryId) async {
    if (_currentCategory == categoryId) return;

    try {
      final wasPlaying = _isPlaying;
      
      // Stop current music
      await stopMusic();
      
      // Update category
      _currentCategory = categoryId;
      
      // Save settings
      await _saveSettings();
      
      // Restart if it was playing
      if (wasPlaying) {
        await playBackgroundMusic();
      }

      if (kDebugMode) {
        debugPrint('🎵 Music category changed to: $categoryId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to change music category: $e');
      }
    }
  }

  /// Simulate music playback for non-native platforms
  Future<void> _simulateMusicPlayback() async {
    // This would typically initialize audio playback
    // For now, we'll simulate with periodic updates
    
    if (_isLooping) {
      // Simulate continuous playback
      while (_isPlaying && _isEnabled) {
        await Future.delayed(const Duration(seconds: 30));
        if (kDebugMode && _isPlaying) {
          debugPrint('🎵 Music playing: $_currentTrack');
        }
      }
    }
  }

  /// Generate track name based on category
  String _generateTrackName(String category) {
    final random = Random();
    final trackNumbers = {
      'ambient': ['Breeze', 'Forest', 'Ocean', 'Rain', 'Mountain'],
      'focus': ['Flow State', 'Deep Work', 'Concentration', 'Focus Mode', 'Clarity'],
      'energetic': ['Power Up', 'Motivation', 'Energy Boost', 'Drive', 'Momentum'],
      'classical': ['Serenade', 'Nocturne', 'Prelude', 'Sonata', 'Meditation'],
      'electronic': ['Synth Wave', 'Digital Dreams', 'Cyber Space', 'Neon Lights', 'Virtual Reality'],
    };

    final tracks = trackNumbers[category] ?? ['Default Track'];
    final trackName = tracks[random.nextInt(tracks.length)];
    final trackNumber = random.nextInt(20) + 1;
    
    return '$trackName $trackNumber';
  }

  /// Update music settings
  Future<void> updateSettings({
    bool? enabled,
    double? volume,
    String? category,
    bool? loop,
  }) async {
    final wasPlaying = _isPlaying;
    final oldCategory = _currentCategory;

    if (enabled != null) _isEnabled = enabled;
    if (volume != null) _volume = volume.clamp(0.0, 1.0);
    if (category != null && _musicCategories.any((cat) => cat['id'] == category)) {
      _currentCategory = category;
    }
    if (loop != null) _isLooping = loop;

    await _saveSettings();

    // Restart music if category changed and was playing
    if (wasPlaying && _isEnabled && category != null && category != oldCategory) {
      await playBackgroundMusic();
    }

    if (kDebugMode) {
      debugPrint('🔧 Music settings updated - Enabled: $_isEnabled, Volume: $_volume, Category: $_currentCategory');
    }
  }

  /// Get available music categories
  List<Map<String, String>> getMusicCategories() {
    return _musicCategories;
  }

  /// Get current playlist for category
  List<Map<String, String>> getPlaylistForCategory(String categoryId) {
    final tracks = <Map<String, String>>[];
    
    for (int i = 1; i <= 10; i++) {
      tracks.add({
        'id': '${categoryId}_track_$i',
        'title': _generateTrackName(categoryId),
        'duration': '${_random.nextInt(3) + 2}:${_random.nextInt(60).toString().padLeft(2, '0')}',
        'category': categoryId,
      });
    }
    
    return tracks;
  }

  /// Get current playback info
  Map<String, dynamic> getPlaybackInfo() {
    return {
      'isPlaying': _isPlaying,
      'currentTrack': _currentTrack,
      'currentCategory': _currentCategory,
      'volume': _volume,
      'isLooping': _isLooping,
      'enabled': _isEnabled,
    };
  }

  /// Check if music service is supported on current platform
  bool get isSupported {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isEnabled = prefs.getBool('${_settingsKey}_enabled') ?? _defaultEnabled;
      _volume = prefs.getDouble('${_settingsKey}_volume') ?? _defaultVolume;
      _currentCategory = prefs.getString('${_settingsKey}_category') ?? _defaultCategory;
      _isLooping = prefs.getBool('${_settingsKey}_loop') ?? true;
      
      // Load current track if exists
      _currentTrack = prefs.getString(_currentTrackKey);
      
      if (kDebugMode) {
        debugPrint('📱 Music settings loaded');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load music settings: $e');
      }
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('${_settingsKey}_enabled', _isEnabled);
      await prefs.setDouble('${_settingsKey}_volume', _volume);
      await prefs.setString('${_settingsKey}_category', _currentCategory);
      await prefs.setBool('${_settingsKey}_loop', _isLooping);
      
      if (kDebugMode) {
        debugPrint('💾 Music settings saved');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save music settings: $e');
      }
    }
  }

  /// Save current track to SharedPreferences
  Future<void> _saveCurrentTrack() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentTrackKey, _currentTrack ?? '');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save current track: $e');
      }
    }
  }

  /// Get current settings as map
  Map<String, dynamic> getSettings() {
    return {
      'enabled': _isEnabled,
      'volume': _volume,
      'category': _currentCategory,
      'loop': _isLooping,
      'initialized': _isInitialized,
      'playing': _isPlaying,
      'currentTrack': _currentTrack,
    };
  }

  /// Dispose resources
  void dispose() {
    _isPlaying = false;
    _currentTrack = null;
    
    if (kDebugMode) {
      debugPrint('🗑️ Music Service disposed');
    }
  }
}
