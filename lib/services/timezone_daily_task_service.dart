// lib/services/timezone_daily_task_service.dart
// Handle daily tasks with proper timezone support

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:timezone/timezone.dart' as tz;
import 'analytics_service.dart';

class TimezoneDailyTaskService {
  static final TimezoneDailyTaskService _instance = TimezoneDailyTaskService._internal();
  factory TimezoneDailyTaskService() => _instance;
  TimezoneDailyTaskService._internal();

  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  late SharedPreferences _prefs;

  static const String _userTimezoneKey = 'user_timezone';
  static const String _lastResetKey = 'last_daily_reset';

  /// Initialize timezone service
  Future<void> initialize(SharedPreferences prefs) async {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _prefs = prefs;

    // Set user timezone (once)
    await _setUserTimezone();

    if (kDebugMode) {
      debugPrint('✅ Timezone daily task service initialized');
    }
  }

  /// Set user timezone
  Future<void> _setUserTimezone() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final timezone = _prefs.getString(_userTimezoneKey);
      if (timezone == null) {
        // Get device timezone
        final deviceTz = await _getDeviceTimezone();
        await _prefs.setString(_userTimezoneKey, deviceTz);

        if (kDebugMode) {
          debugPrint('🌍 User timezone set: $deviceTz');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error setting timezone: $e');
    }
  }

  /// Get device timezone
  Future<String> _getDeviceTimezone() async {
    try {
      // Get from Firestore user profile if available
      final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

      if (userDoc.exists && userDoc['timezone'] != null) {
        return userDoc['timezone'] as String;
      }

      // Fallback to local timezone
      final localTz = DateTime.now().timeZoneOffset.toString();
      return localTz; // e.g., "+03:00"
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error getting device timezone: $e');
      return '+00:00'; // UTC fallback
    }
  }

  /// Check if daily reset is needed (based on user timezone)
  Future<bool> shouldResetDailyTasks() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final lastResetStr = _prefs.getString(_lastResetKey);
      if (lastResetStr == null) return true; // First time

      final lastReset = DateTime.parse(lastResetStr);
      final userTz = _prefs.getString(_userTimezoneKey) ?? '+00:00';

      // Get current time in user's timezone
      final now = _getNowInUserTz(userTz);
      final lastResetInUserTz = _convertToUserTz(lastReset, userTz);

      // Reset if different day in user's timezone
      final shouldReset = now.year != lastResetInUserTz.year ||
          now.month != lastResetInUserTz.month ||
          now.day != lastResetInUserTz.day;

      if (shouldReset && kDebugMode) {
        debugPrint('✅ Daily reset needed (last: ${lastResetInUserTz.toLocal()}, now: ${now.toLocal()})');
      }

      return shouldReset;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error checking reset: $e');
      return false;
    }
  }

  /// Perform daily reset
  Future<bool> resetDailyTasks() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'daily_tasks_reset_at': FieldValue.serverTimestamp(),
        'daily_tasks_completed_today': 0,
      });

      // Update local cache
      final userTz = _prefs.getString(_userTimezoneKey) ?? '+00:00';
      final now = _getNowInUserTz(userTz);
      await _prefs.setString(_lastResetKey, now.toIso8601String());

      if (kDebugMode) {
        debugPrint('✅ Daily tasks reset for user $userId');
      }

      await AnalyticsService().logCustomEvent('daily_reset', {
        'timezone': userTz,
        'reset_time': now.toIso8601String(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error resetting daily tasks: $e');
      await AnalyticsService().logError('DailyResetError', e.toString());
      return false;
    }
  }

  /// Get time remaining until next daily reset
  Duration? getTimeUntilNextReset() {
    try {
      final userTz = _prefs.getString(_userTimezoneKey) ?? '+00:00';
      final now = _getNowInUserTz(userTz);

      // Calculate next midnight in user's timezone
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      final remaining = nextMidnight.difference(now);

      return remaining;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error calculating reset time: $e');
      return null;
    }
  }

  /// Get current time in user's timezone
  DateTime _getNowInUserTz(String tzOffset) {
    try {
      final now = DateTime.now();
      final parts = tzOffset.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts.length > 1 ? parts[1] : '0');

      final offsetInSeconds = (hours * 3600) + (minutes * 60);
      final utcNow = now.toUtc();

      return utcNow.add(Duration(seconds: offsetInSeconds));
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error getting user timezone time: $e');
      return DateTime.now();
    }
  }

  /// Convert datetime to user's timezone
  DateTime _convertToUserTz(DateTime dateTime, String tzOffset) {
    final parts = tzOffset.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts.length > 1 ? parts[1] : '0');

    final offsetInSeconds = (hours * 3600) + (minutes * 60);
    final utcDateTime = dateTime.toUtc();

    return utcDateTime.add(Duration(seconds: offsetInSeconds));
  }

  /// Set user timezone preference
  Future<void> setUserTimezone(String timezone) async {
    try {
      await _prefs.setString(_userTimezoneKey, timezone);

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'timezone': timezone,
        });
      }

      if (kDebugMode) {
        debugPrint('✅ User timezone updated: $timezone');
      }

      await AnalyticsService().logCustomEvent('timezone_updated', {
        'timezone': timezone,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error updating timezone: $e');
    }
  }

  /// Get user timezone
  String getUserTimezone() {
    return _prefs.getString(_userTimezoneKey) ?? '+00:00';
  }
}
