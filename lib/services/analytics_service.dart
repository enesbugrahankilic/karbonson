// lib/services/analytics_service.dart
// Comprehensive analytics and crash logging service

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  bool _isInitialized = false;

  /// Initialize analytics and crashlytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Setup Crashlytics error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics.recordFlutterFatalError(details);
      };

      // Setup zone error handling
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable analytics collection
      await _analytics.setAnalyticsCollectionEnabled(true);

      // Set user ID (optional, set after login)
      // await _analytics.setUserId(userId);

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ Analytics service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize analytics: $e');
      }
    }
  }

  /// Log user login
  Future<void> logUserLogin(String userId, String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      await _analytics.setUserId(userId);
      if (kDebugMode) debugPrint('📊 Login logged: $userId via $method');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging login: $e');
    }
  }

  /// Log user registration
  Future<void> logUserRegistration(String userId, String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      await _analytics.setUserId(userId);
      if (kDebugMode) debugPrint('📊 Registration logged: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging registration: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      if (kDebugMode) debugPrint('📊 Screen viewed: $screenName');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging screen view: $e');
    }
  }

  /// Log custom event
  Future<void> logCustomEvent(String eventName, Map<String, dynamic>? parameters) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters ?? {},
      );
      if (kDebugMode) debugPrint('📊 Event logged: $eventName');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging event: $e');
    }
  }

  /// Log game start
  Future<void> logGameStart(String gameType, {int? difficulty}) async {
    try {
      await _analytics.logEvent(
        name: 'game_start',
        parameters: {
          'game_type': gameType, // 'quiz', 'duel', 'multiplayer'
          'difficulty': difficulty,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) debugPrint('📊 Game started: $gameType');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging game start: $e');
    }
  }

  /// Log game completion
  Future<void> logGameCompletion(
    String gameType, {
    required int score,
    required int duration,
    required bool isWin,
    int? difficulty,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'game_complete',
        parameters: {
          'game_type': gameType,
          'score': score,
          'duration_seconds': duration,
          'is_win': isWin,
          'difficulty': difficulty,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) {
        debugPrint('📊 Game completed: $gameType - Score: $score - Win: $isWin');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging game completion: $e');
    }
  }

  /// Log user engagement
  Future<void> logUserEngagement(String feature, String action) async {
    try {
      await _analytics.logEvent(
        name: 'user_engagement',
        parameters: {
          'feature': feature, // 'quiz', 'duel', 'friends', 'shop', etc
          'action': action, // 'start', 'complete', 'abandon', 'purchase'
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) debugPrint('📊 Engagement: $feature - $action');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging engagement: $e');
    }
  }

  /// Log purchase/reward
  Future<void> logReward(
    String rewardType, {
    required int amount,
    String? source,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'reward_earned',
        parameters: {
          'reward_type': rewardType, // 'points', 'coins', 'boxes'
          'amount': amount,
          'source': source, // 'quiz', 'duel', 'daily', 'shop'
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) debugPrint('📊 Reward: $rewardType x$amount from $source');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging reward: $e');
    }
  }

  /// Log error (non-fatal)
  Future<void> logError(String errorType, String message, {StackTrace? stackTrace}) async {
    try {
      await _crashlytics.recordError(
        Exception(message),
        stackTrace,
        reason: errorType,
        fatal: false,
      );
      if (kDebugMode) debugPrint('📊 Error logged: $errorType - $message');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging error: $e');
    }
  }

  /// Log fatal crash
  Future<void> logCrash(dynamic error, StackTrace stackTrace, {String? reason}) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: true,
      );
      if (kDebugMode) debugPrint('🚨 CRASH logged: $reason');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging crash: $e');
    }
  }

  /// Log network error
  Future<void> logNetworkError(
    String endpoint, {
    required int statusCode,
    String? errorMessage,
  }) async {
    try {
      await _crashlytics.recordError(
        Exception('Network Error: $statusCode'),
        StackTrace.current,
        reason: 'endpoint: $endpoint',
        fatal: false,
      );
      if (kDebugMode) {
        debugPrint('📊 Network error: $endpoint - $statusCode');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging network error: $e');
    }
  }

  /// Log user drop-off point
  Future<void> logUserDropOff(String fromScreen, String reason) async {
    try {
      await _analytics.logEvent(
        name: 'user_drop_off',
        parameters: {
          'from_screen': fromScreen,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) debugPrint('📊 User drop-off: $fromScreen - $reason');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging drop-off: $e');
    }
  }

  /// Log feature usage
  Future<void> logFeatureUsage(String featureName, {Map<String, dynamic>? details}) async {
    try {
      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: {
          'feature': featureName,
          ...?details,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (kDebugMode) debugPrint('📊 Feature used: $featureName');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging feature usage: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) debugPrint('📊 User property: $name = $value');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error setting user property: $e');
    }
  }

  /// Get unique session ID
  String getSessionId() {
    return _crashlytics.isCrashlyticsCollectionEnabled ? 'session_${DateTime.now().millisecondsSinceEpoch}' : 'offline';
  }

  /// Dispose
  void dispose() {
    _isInitialized = false;
  }
}
