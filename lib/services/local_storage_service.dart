// lib/services/local_storage_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_data.dart';
import '../models/game_board.dart';
import '../models/profile_data.dart';

/// Cache entry with expiry support
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration? expiry;

  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiry,
  });

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().difference(createdAt) > expiry!;
  }
}

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance =>
      _instance ??= LocalStorageService._();

  LocalStorageService._();

  static const String _userDataKey = 'cached_user_data';
  static const String _profileDataKey = 'cached_profile_data';
  static const String _offlineGameStateKey = 'cached_offline_game';
  static const String _cachedQuestionsKey = 'cached_questions';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _offlineModeKey = 'offline_mode_enabled';

  // ⚡ PERFORMANCE: Cache expiration settings
  static const Duration _defaultCacheExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 50; // Maximum items in cache

  // ⚡ PERFORMANCE: LRU Cache for frequently accessed data
  final LinkedHashMap<String, CacheEntry> _memoryCache = LinkedHashMap();
  final Queue<String> _accessOrder = Queue<String>();

  static SharedPreferences? _prefs;

  // ⚡ PERFORMANCE: Batch operations support
  static final Map<String, dynamic> _pendingWrites = {};
  static Timer? _batchWriteTimer;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _startBatchWriteTimer();
  }

  // ⚡ PERFORMANCE: Batch write operations for better performance
  static void _startBatchWriteTimer() {
    _batchWriteTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _flushPendingWrites();
    });
  }

  static Future<void> _flushPendingWrites() async {
    if (_pendingWrites.isEmpty) return;

    final writes = Map.from(_pendingWrites);
    _pendingWrites.clear();

    try {
      for (final entry in writes.entries) {
        await _prefs?.setString(entry.key, jsonEncode(entry.value));
      }
      if (kDebugMode) {
        debugPrint('Batch write completed: ${writes.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Batch write failed: $e');
      }
      // Re-add failed writes to pending
      _pendingWrites.addAll(writes.cast<String, dynamic>());
    }
  }

  // ⚡ PERFORMANCE: Enhanced caching with memory cache
  static void putInMemoryCache(String key, dynamic data, {Duration? expiry}) {
    final entry = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      expiry: expiry ?? _defaultCacheExpiry,
    );

    // Remove from cache if exists to update access order
    _instance?._memoryCache.remove(key);
    _instance?._accessOrder.remove(key);

    // Add to cache
    _instance?._memoryCache[key] = entry;
    _instance?._accessOrder.add(key);

    // Evict oldest if cache is full
    if (_instance!._memoryCache.length > _maxCacheSize) {
      _evictOldestCache();
    }
  }

  static T? getFromMemoryCache<T>(String key) {
    final entry = _instance?._memoryCache[key];
    if (entry == null) return null;

    // Check expiry
    if (entry.isExpired) {
      _instance?._memoryCache.remove(key);
      _instance?._accessOrder.remove(key);
      return null;
    }

    // Move to end (most recently used)
    _instance?._accessOrder.remove(key);
    _instance?._accessOrder.add(key);

    return entry.data as T;
  }

  static void _evictOldestCache() {
    if (_instance!._accessOrder.isNotEmpty) {
      final oldestKey = _instance!._accessOrder.removeFirst();
      _instance!._memoryCache.remove(oldestKey);
    }
  }

  // User Data Caching with batch support
  static Future<void> cacheUserData(UserData userData) async {
    try {
      final data = userData.toMap();
      _pendingWrites[_userDataKey] = data;

      // Also cache in memory for fast access
      putInMemoryCache(_userDataKey, userData);
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
        final localData =
            LocalStatisticsData.fromMap(combinedData['localData']);

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
  static Future<void> cacheOfflineGameState(
      Map<String, dynamic> gameState) async {
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
  static Future<void> cacheQuestions(
      List<Map<String, dynamic>> questions) async {
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
