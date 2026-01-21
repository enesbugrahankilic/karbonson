// lib/services/duel_crash_handler.dart
// Handle duel disconnections, crashes, and recovery

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'analytics_service.dart';
import 'backend_validation_service.dart';

class DuelCrashHandler {
  static final DuelCrashHandler _instance = DuelCrashHandler._internal();
  factory DuelCrashHandler() => _instance;
  DuelCrashHandler._internal();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late SharedPreferences _prefs;

  static const String _activeDuelKey = 'active_duel';
  static const String _duelStartTimeKey = 'duel_start_time';
  static const Duration _duelTimeout = Duration(minutes: 10);

  /// Initialize handler
  Future<void> initialize(SharedPreferences prefs) async {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _prefs = prefs;

    // Check for abandoned duel on startup
    await _checkAbandonedDuel();
  }

  /// Start tracking active duel
  Future<void> trackDuelStart(String duelId, String opponentId) async {
    try {
      final duelData = {
        'duel_id': duelId,
        'opponent_id': opponentId,
        'start_time': DateTime.now().toIso8601String(),
      };

      await _prefs.setString(_activeDuelKey, jsonEncode(duelData));
      await _prefs.setString(_duelStartTimeKey, DateTime.now().toIso8601String());

      if (kDebugMode) {
        debugPrint('📱 Duel tracking started: $duelId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error tracking duel: $e');
    }
  }

  /// Mark duel as completed
  Future<void> markDuelCompleted(String duelId) async {
    try {
      await _prefs.remove(_activeDuelKey);
      await _prefs.remove(_duelStartTimeKey);

      if (kDebugMode) {
        debugPrint('✅ Duel marked as completed: $duelId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error marking duel complete: $e');
    }
  }

  /// Check for abandoned duel on app startup
  Future<void> _checkAbandonedDuel() async {
    try {
      final duelJson = _prefs.getString(_activeDuelKey);
      if (duelJson == null) return;

      final duelData = jsonDecode(duelJson) as Map<String, dynamic>;
      final duelId = duelData['duel_id'] as String;
      final startTimeStr = _prefs.getString(_duelStartTimeKey);

      if (startTimeStr == null) {
        // Malformed data, clean up
        await _prefs.remove(_activeDuelKey);
        return;
      }

      final startTime = DateTime.parse(startTimeStr);
      final elapsed = DateTime.now().difference(startTime);

      // If duel timed out, handle abandonment
      if (elapsed > _duelTimeout) {
        await _handleDuelAbandonement(duelId);
        return;
      }

      if (kDebugMode) {
        debugPrint('⚠️ Abandoned duel detected: $duelId (elapsed: ${elapsed.inSeconds}s)');
      }

      // Log to analytics
      await AnalyticsService().logCustomEvent('duel_abandoned', {
        'duel_id': duelId,
        'elapsed_seconds': elapsed.inSeconds,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error checking abandoned duel: $e');
    }
  }

  /// Handle duel abandonment (give opponent win)
  Future<void> _handleDuelAbandonement(String duelId) async {
    try {
      final duelDoc = await _firestore.collection('duels').doc(duelId).get();

      if (!duelDoc.exists) {
        if (kDebugMode) debugPrint('❌ Duel not found: $duelId');
        return;
      }

      final duelData = duelDoc.data()!;
      final player1Id = duelData['player1_id'] as String;
      final player2Id = duelData['player2_id'] as String;
      final currentUserId = _auth.currentUser?.uid;

      // Determine winner (the one who didn't abandon)
      final winnerId = currentUserId == player1Id ? player2Id : player1Id;
      final loserId = currentUserId;

      // Give opponent automatic win
      final result = await BackendValidationService().validateDuelResult(
        winnerId: winnerId,
        loserId: loserId,
        winnerScore: 100,
        loserScore: 0,
        duration: DateTime.now().difference(DateTime.parse(duelData['start_time'])).inSeconds,
      );

      if (result) {
        // Update duel status
        await _firestore.collection('duels').doc(duelId).update({
          'status': 'abandoned',
          'winner_id': winnerId,
          'completed_at': FieldValue.serverTimestamp(),
          'reason': 'opponent_abandoned',
        });

        await AnalyticsService().logCustomEvent('duel_completed', {
          'duel_id': duelId,
          'reason': 'opponent_abandoned',
          'winner_id': winnerId,
        });

        if (kDebugMode) {
          debugPrint('✅ Duel abandonment handled: $winnerId wins');
        }
      }

      // Clean up
      await _prefs.remove(_activeDuelKey);
      await _prefs.remove(_duelStartTimeKey);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error handling duel abandonment: $e');
      await AnalyticsService().logError('DuelAbandonmentError', e.toString());
    }
  }

  /// Handle network disconnection during duel
  Future<void> handleNetworkDisconnect(String duelId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔴 Network disconnected during duel: $duelId');
      }

      // Save duel state locally
      final duelJson = _prefs.getString(_activeDuelKey);
      if (duelJson != null) {
        final duelData = jsonDecode(duelJson) as Map<String, dynamic>;
        duelData['last_disconnect_time'] = DateTime.now().toIso8601String();
        await _prefs.setString(_activeDuelKey, jsonEncode(duelData));
      }

      await AnalyticsService().logCustomEvent('duel_network_disconnect', {
        'duel_id': duelId,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error handling network disconnect: $e');
    }
  }

  /// Handle network reconnection during duel
  Future<void> handleNetworkReconnect(String duelId) async {
    try {
      if (kDebugMode) {
        debugPrint('🟢 Network reconnected during duel: $duelId');
      }

      // Sync duel state
      final duelDoc = await _firestore.collection('duels').doc(duelId).get();
      if (duelDoc.exists && duelDoc['status'] != 'active') {
        // Duel already completed
        if (kDebugMode) {
          debugPrint('ℹ️ Duel already completed: ${duelDoc['status']}');
        }
      }

      await AnalyticsService().logCustomEvent('duel_network_reconnect', {
        'duel_id': duelId,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error handling network reconnect: $e');
    }
  }

  /// Get abandoned duel info
  Map<String, dynamic>? getAbandonedDuelInfo() {
    try {
      final duelJson = _prefs.getString(_activeDuelKey);
      if (duelJson == null) return null;

      return jsonDecode(duelJson) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error getting abandoned duel: $e');
      return null;
    }
  }
}
