// lib/services/offline_sync_service.dart
// Handle offline data and sync when connection returns

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:convert';
import 'dart:async';
import 'connectivity_service.dart';
import 'analytics_service.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  late SharedPreferences _prefs;
  late ConnectivityService _connectivity;
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  StreamSubscription? _connectivitySubscription;

  static const String _pendingQuizzesKey = 'pending_quizzes';
  static const String _pendingDuelsKey = 'pending_duels';
  static const String _pendingRewardsKey = 'pending_rewards';
  static const String _lastSyncKey = 'last_sync_time';

  bool _isSyncing = false;

  /// Initialize offline sync
  Future<void> initialize(SharedPreferences prefs, ConnectivityService connectivity) async {
    _prefs = prefs;
    _connectivity = connectivity;
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.connectivityStateStream.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        _syncOfflineData();
      }
    });

    if (kDebugMode) {
      debugPrint('✅ Offline sync service initialized');
    }
  }

  /// Save quiz result for offline
  Future<void> saveOfflineQuizResult(Map<String, dynamic> quizResult) async {
    try {
      final pending = _prefs.getStringList(_pendingQuizzesKey) ?? [];
      pending.add(jsonEncode(quizResult));
      await _prefs.setStringList(_pendingQuizzesKey, pending);

      if (kDebugMode) {
        debugPrint('💾 Quiz result saved offline (pending: ${pending.length})');
      }

      await AnalyticsService().logCustomEvent('offline_quiz_saved', {
        'pending_count': pending.length,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving offline quiz: $e');
    }
  }

  /// Save duel result for offline
  Future<void> saveOfflineDuelResult(Map<String, dynamic> duelResult) async {
    try {
      final pending = _prefs.getStringList(_pendingDuelsKey) ?? [];
      pending.add(jsonEncode(duelResult));
      await _prefs.setStringList(_pendingDuelsKey, pending);

      if (kDebugMode) {
        debugPrint('💾 Duel result saved offline (pending: ${pending.length})');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving offline duel: $e');
    }
  }

  /// Save reward for offline
  Future<void> saveOfflineReward(Map<String, dynamic> reward) async {
    try {
      final pending = _prefs.getStringList(_pendingRewardsKey) ?? [];
      pending.add(jsonEncode(reward));
      await _prefs.setStringList(_pendingRewardsKey, pending);

      if (kDebugMode) {
        debugPrint('💾 Reward saved offline (pending: ${pending.length})');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving offline reward: $e');
    }
  }

  /// Sync offline data when connection returns
  Future<void> _syncOfflineData() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      if (kDebugMode) {
        debugPrint('🔄 Starting offline data sync...');
      }

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        if (kDebugMode) debugPrint('❌ User not authenticated for sync');
        _isSyncing = false;
        return;
      }

      int syncedCount = 0;
      int failedCount = 0;

      // Sync offline quizzes
      final (quizSynced, quizFailed) = await _syncOfflineQuizzes();
      syncedCount += quizSynced;
      failedCount += quizFailed;

      // Sync offline duels
      final (duelSynced, duelFailed) = await _syncOfflineDuels();
      syncedCount += duelSynced;
      failedCount += duelFailed;

      // Sync offline rewards
      final (rewardSynced, rewardFailed) = await _syncOfflineRewards();
      syncedCount += rewardSynced;
      failedCount += rewardFailed;

      // Update last sync time
      await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      if (kDebugMode) {
        debugPrint('✅ Offline sync completed: $syncedCount synced, $failedCount failed');
      }

      await AnalyticsService().logCustomEvent('offline_sync_complete', {
        'synced': syncedCount,
        'failed': failedCount,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Offline sync error: $e');
      await AnalyticsService().logError('OfflineSyncError', e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync offline quizzes
  Future<(int, int)> _syncOfflineQuizzes() async {
    try {
      final pending = _prefs.getStringList(_pendingQuizzesKey) ?? [];
      if (pending.isEmpty) return (0, 0);

      int synced = 0;
      int failed = 0;

      for (final quizJson in pending) {
        try {
          final quiz = jsonDecode(quizJson) as Map<String, dynamic>;

          // Save to Firestore
          await _firestore.collection('quiz_results').add({
            ...quiz,
            'synced_at': FieldValue.serverTimestamp(),
            'was_offline': true,
          });

          synced++;
        } catch (e) {
          if (kDebugMode) debugPrint('❌ Error syncing quiz: $e');
          failed++;
        }
      }

      if (synced > 0) {
        await _prefs.setStringList(_pendingQuizzesKey, []);
      }

      return (synced, failed);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error syncing offline quizzes: $e');
      return (0, 1);
    }
  }

  /// Sync offline duels
  Future<(int, int)> _syncOfflineDuels() async {
    try {
      final pending = _prefs.getStringList(_pendingDuelsKey) ?? [];
      if (pending.isEmpty) return (0, 0);

      int synced = 0;
      int failed = 0;

      for (final duelJson in pending) {
        try {
          final duel = jsonDecode(duelJson) as Map<String, dynamic>;

          // Save to Firestore
          await _firestore.collection('duel_results').add({
            ...duel,
            'synced_at': FieldValue.serverTimestamp(),
            'was_offline': true,
          });

          synced++;
        } catch (e) {
          if (kDebugMode) debugPrint('❌ Error syncing duel: $e');
          failed++;
        }
      }

      if (synced > 0) {
        await _prefs.setStringList(_pendingDuelsKey, []);
      }

      return (synced, failed);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error syncing offline duels: $e');
      return (0, 1);
    }
  }

  /// Sync offline rewards
  Future<(int, int)> _syncOfflineRewards() async {
    try {
      final pending = _prefs.getStringList(_pendingRewardsKey) ?? [];
      if (pending.isEmpty) return (0, 0);

      int synced = 0;
      int failed = 0;

      for (final rewardJson in pending) {
        try {
          final reward = jsonDecode(rewardJson) as Map<String, dynamic>;

          // Save to Firestore
          await _firestore.collection('reward_history').add({
            ...reward,
            'synced_at': FieldValue.serverTimestamp(),
            'was_offline': true,
          });

          synced++;
        } catch (e) {
          if (kDebugMode) debugPrint('❌ Error syncing reward: $e');
          failed++;
        }
      }

      if (synced > 0) {
        await _prefs.setStringList(_pendingRewardsKey, []);
      }

      return (synced, failed);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error syncing offline rewards: $e');
      return (0, 1);
    }
  }

  /// Get pending sync count
  int getPendingSyncCount() {
    int total = 0;
    total += _prefs.getStringList(_pendingQuizzesKey)?.length ?? 0;
    total += _prefs.getStringList(_pendingDuelsKey)?.length ?? 0;
    total += _prefs.getStringList(_pendingRewardsKey)?.length ?? 0;
    return total;
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString(_lastSyncKey);
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  /// Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
