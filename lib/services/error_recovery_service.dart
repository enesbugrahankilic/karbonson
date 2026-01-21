// lib/services/error_recovery_service.dart
// Comprehensive error recovery and state restoration

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'analytics_service.dart';

class ErrorRecoveryService {
  static final ErrorRecoveryService _instance = ErrorRecoveryService._internal();
  factory ErrorRecoveryService() => _instance;
  ErrorRecoveryService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Recovery cache keys
  static const String _lastValidStateKey = 'last_valid_state';
  static const String _crashCountKey = 'crash_count';
  static const String _lastCrashTimeKey = 'last_crash_time';
  static const String _errorLogKey = 'error_log';

  /// Initialize error recovery
  Future<void> initialize(SharedPreferences prefs) async {
    if (_isInitialized) return;

    try {
      _prefs = prefs;
      _isInitialized = true;

      // Check for previous crashes
      await _checkPreviousCrashes();

      if (kDebugMode) {
        debugPrint('✅ Error recovery service initialized');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error recovery init error: $e');
    }
  }

  /// Check and handle previous crashes
  Future<void> _checkPreviousCrashes() async {
    try {
      final crashCount = _prefs.getInt(_crashCountKey) ?? 0;
      final lastCrashTime = _prefs.getString(_lastCrashTimeKey);

      if (crashCount > 0) {
        if (kDebugMode) {
          debugPrint('⚠️ Previous crash detected (count: $crashCount)');
        }

        await AnalyticsService().logError(
          'PreviousCrash',
          'App crashed $crashCount times. Last crash: $lastCrashTime',
        );

        // If crash count > 3 in 1 hour, trigger safe mode
        if (crashCount > 3) {
          await _triggerSafeMode();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error checking previous crashes: $e');
    }
  }

  /// Trigger safe mode (disable heavy features)
  Future<void> _triggerSafeMode() async {
    try {
      await _prefs.setBool('safe_mode_enabled', true);

      if (kDebugMode) {
        debugPrint('🚨 SAFE MODE ENABLED - Disabling heavy features');
      }

      await AnalyticsService().logError(
        'SafeModeActivated',
        'App entered safe mode due to repeated crashes',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error enabling safe mode: $e');
    }
  }

  /// Record crash
  Future<void> recordCrash(String errorType, String message) async {
    try {
      // Increment crash count
      final crashCount = _prefs.getInt(_crashCountKey) ?? 0;
      await _prefs.setInt(_crashCountKey, crashCount + 1);

      // Record crash time
      await _prefs.setString(_lastCrashTimeKey, DateTime.now().toIso8601String());

      // Log error details
      final errorLog = _prefs.getStringList(_errorLogKey) ?? [];
      errorLog.add(jsonEncode({
        'type': errorType,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      }));

      // Keep last 50 errors
      if (errorLog.length > 50) {
        errorLog.removeAt(0);
      }

      await _prefs.setStringList(_errorLogKey, errorLog);

      if (kDebugMode) {
        debugPrint('💾 Crash recorded: $errorType - $message');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error recording crash: $e');
    }
  }

  /// Save valid state (for recovery)
  Future<void> saveValidState(Map<String, dynamic> state) async {
    try {
      await _prefs.setString(_lastValidStateKey, jsonEncode(state));

      if (kDebugMode) {
        debugPrint('💾 Valid state saved for recovery');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving valid state: $e');
    }
  }

  /// Restore last valid state
  Future<Map<String, dynamic>?> restoreLastValidState() async {
    try {
      final stateJson = _prefs.getString(_lastValidStateKey);
      if (stateJson == null) return null;

      final state = jsonDecode(stateJson) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint('✅ State restored from recovery cache');
      }

      await AnalyticsService().logCustomEvent('state_restored', {
        'timestamp': DateTime.now().toIso8601String(),
      });

      return state;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error restoring state: $e');
      return null;
    }
  }

  /// Get error log
  List<Map<String, dynamic>> getErrorLog() {
    try {
      final errorLog = _prefs.getStringList(_errorLogKey) ?? [];
      return errorLog
          .map((log) => jsonDecode(log) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList(); // Newest first
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error reading error log: $e');
      return [];
    }
  }

  /// Clear error log
  Future<void> clearErrorLog() async {
    try {
      await _prefs.remove(_errorLogKey);
      await _prefs.setInt(_crashCountKey, 0);

      if (kDebugMode) {
        debugPrint('🗑️ Error log cleared');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing error log: $e');
    }
  }

  /// Check if safe mode is enabled
  bool isSafeModeEnabled() {
    return _prefs.getBool('safe_mode_enabled') ?? false;
  }

  /// Disable safe mode
  Future<void> disableSafeMode() async {
    try {
      await _prefs.setBool('safe_mode_enabled', false);
      await _prefs.setInt(_crashCountKey, 0);

      if (kDebugMode) {
        debugPrint('✅ Safe mode disabled');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error disabling safe mode: $e');
    }
  }

  /// Get recovery info
  Map<String, dynamic> getRecoveryInfo() {
    return {
      'crash_count': _prefs.getInt(_crashCountKey) ?? 0,
      'last_crash_time': _prefs.getString(_lastCrashTimeKey),
      'safe_mode_enabled': isSafeModeEnabled(),
      'error_log_count': _prefs.getStringList(_errorLogKey)?.length ?? 0,
    };
  }

  /// Dispose
  void dispose() {
    _isInitialized = false;
  }
}
