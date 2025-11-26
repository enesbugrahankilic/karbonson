// lib/services/local_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../models/game_board.dart';
import '../models/profile_data.dart';

class LocalStorageService {
  static const String _userDataKey = 'cached_user_data';
  static const String _profileDataKey = 'cached_profile_data';
  static const String _offlineGameStateKey = 'cached_offline_game';
  static const String _cachedQuestionsKey = 'cached_questions';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _offlineModeKey = 'offline_mode_enabled';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Data Caching
  static Future<void> cacheUserData(UserData userData) async {
    try {
      await _prefs?.setString(_userDataKey, jsonEncode(userData.toMap()));
    } catch (e) {
      throw Exception('Failed to cache user data: $e');
    }
  }

  static UserData? getCachedUserData() {
    try {
      final userDataString = _prefs?.getString(_userDataKey);
      if (userDataString != null) {
        final userDataMap = jsonDecode(userDataString);
        return UserData.fromMap(userDataMap, userDataMap['uid']);
      }
    } catch (e) {
      // Handle corruption gracefully
      clearUserDataCache();
    }
    return null;
  }

  static Future<void> clearUserDataCache() async {
    await _prefs?.remove(_userDataKey);
  }

  // Profile Data Caching (ServerProfileData and LocalStatisticsData)
  static Future<void> cacheProfileData(ProfileData profileData) async {
    try {
      final Map<String, dynamic> combinedData = {
        'serverData': profileData.serverData?.toMap(),
        'localData': profileData.localData.toMap(),
      };
      await _prefs?.setString(_profileDataKey, jsonEncode(combinedData));
    } catch (e) {
      throw Exception('Failed to cache profile data: $e');
    }
  }

  static ProfileData? getCachedProfileData() {
    try {
      final profileDataString = _prefs?.getString(_profileDataKey);
      if (profileDataString != null) {
        final combinedData = jsonDecode(profileDataString);
        final serverData = combinedData['serverData'] != null 
          ? ServerProfileData.fromMap(combinedData['serverData'])
          : null;
        final localData = LocalStatisticsData.fromMap(combinedData['localData']);
        
        return ProfileData(
          serverData: serverData,
          localData: localData,
        );
      }
    } catch (e) {
      clearProfileDataCache();
    }
    return null;
  }

  static Future<void> clearProfileDataCache() async {
    await _prefs?.remove(_profileDataKey);
  }

  // Offline Game State Caching
  static Future<void> cacheOfflineGameState(Map<String, dynamic> gameState) async {
    try {
      await _prefs?.setString(_offlineGameStateKey, jsonEncode(gameState));
    } catch (e) {
      throw Exception('Failed to cache offline game state: $e');
    }
  }

  static Map<String, dynamic>? getCachedOfflineGameState() {
    try {
      final gameStateString = _prefs?.getString(_offlineGameStateKey);
      if (gameStateString != null) {
        return jsonDecode(gameStateString);
      }
    } catch (e) {
      clearOfflineGameStateCache();
    }
    return null;
  }

  static Future<void> clearOfflineGameStateCache() async {
    await _prefs?.remove(_offlineGameStateKey);
  }

  // Questions Caching for Offline Use
  static Future<void> cacheQuestions(List<Map<String, dynamic>> questions) async {
    try {
      await _prefs?.setString(_cachedQuestionsKey, jsonEncode(questions));
    } catch (e) {
      throw Exception('Failed to cache questions: $e');
    }
  }

  static List<Map<String, dynamic>>? getCachedQuestions() {
    try {
      final questionsString = _prefs?.getString(_cachedQuestionsKey);
      if (questionsString != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(questionsString));
      }
    } catch (e) {
      clearQuestionsCache();
    }
    return null;
  }

  static Future<void> clearQuestionsCache() async {
    await _prefs?.remove(_cachedQuestionsKey);
  }

  // Sync Time Tracking
  static Future<void> setLastSyncTime(DateTime timestamp) async {
    await _prefs?.setString(_lastSyncTimeKey, timestamp.toIso8601String());
  }

  static DateTime? getLastSyncTime() {
    final syncTimeString = _prefs?.getString(_lastSyncTimeKey);
    if (syncTimeString != null) {
      return DateTime.parse(syncTimeString);
    }
    return null;
  }

  // Offline Mode Management
  static Future<void> setOfflineModeEnabled(bool enabled) async {
    await _prefs?.setBool(_offlineModeKey, enabled);
  }

  static bool isOfflineModeEnabled() {
    return _prefs?.getBool(_offlineModeKey) ?? false;
  }

  // Utility Methods
  static Future<bool> hasCachedData() async {
    final hasUserData = _prefs?.getString(_userDataKey) != null;
    final hasProfileData = _prefs?.getString(_profileDataKey) != null;
    final hasQuestions = _prefs?.getString(_cachedQuestionsKey) != null;
    
    return hasUserData || hasProfileData || hasQuestions;
  }

  static Future<void> clearAllCache() async {
    await clearUserDataCache();
    await clearProfileDataCache();
    await clearOfflineGameStateCache();
    await clearQuestionsCache();
    await _prefs?.remove(_lastSyncTimeKey);
    await _prefs?.remove(_offlineModeKey);
  }

  // Cache Size Management
  static Future<int> getCacheSize() async {
    int size = 0;
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        final value = _prefs!.getString(key);
        if (value != null) {
          size += value.length;
        }
      }
    }
    return size;
  }

  // Method to handle cache expiration (older than 7 days)
  static Future<void> cleanExpiredCache() async {
    final lastSync = getLastSyncTime();
    if (lastSync != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSync).inDays;
      
      if (difference > 7) {
        await clearAllCache();
      }
    }
  }
}