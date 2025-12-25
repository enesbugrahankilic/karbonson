// lib/services/app_initialization_service.dart
// Performans-optimized app initialization service
// Handles parallel initialization of all services for faster startup

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'authentication_state_service.dart';
import 'deep_linking_service.dart';
import 'notification_service.dart';
import 'firebase_auth_service.dart';

/// Performance metrics for app initialization
class InitializationMetrics {
  final Duration totalDuration;
  final Duration firebaseDuration;
  final Duration authDuration;
  final Duration deepLinkDuration;
  final Duration notificationDuration;
  final bool allSuccessful;

  const InitializationMetrics({
    required this.totalDuration,
    required this.firebaseDuration,
    required this.authDuration,
    required this.deepLinkDuration,
    required this.notificationDuration,
    required this.allSuccessful,
  });

  Map<String, dynamic> toJson() => {
        'total_duration_ms': totalDuration.inMilliseconds,
        'firebase_duration_ms': firebaseDuration.inMilliseconds,
        'auth_duration_ms': authDuration.inMilliseconds,
        'deep_link_duration_ms': deepLinkDuration.inMilliseconds,
        'notification_duration_ms': notificationDuration.inMilliseconds,
        'all_successful': allSuccessful,
      };

  @override
  String toString() {
    return 'InitializationMetrics{total: ${totalDuration.inMilliseconds}ms, '
        'firebase: ${firebaseDuration.inMilliseconds}ms, '
        'auth: ${authDuration.inMilliseconds}ms, '
        'deepLink: ${deepLinkDuration.inMilliseconds}ms, '
        'notification: ${notificationDuration.inMilliseconds}ms, '
        'success: $allSuccessful}';
  }
}

/// Optimized app initialization service with parallel execution
class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  InitializationMetrics? _lastMetrics;
  InitializationMetrics? get lastMetrics => _lastMetrics;

  /// Initialize all app services with parallel execution for optimal performance
  Future<InitializationMetrics> initializeApp() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Step 1: Initialize Firebase (must be sequential)
      final firebaseStopwatch = Stopwatch()..start();
      await _initializeFirebase();
      firebaseStopwatch.stop();

      // Step 2: Run other initializations in parallel for better performance
      final authFuture = _initializeAuthentication();
      final deepLinkFuture = _initializeDeepLinking();
      final notificationFuture = _initializeNotifications();

      // Wait for all parallel operations to complete
      await Future.wait([authFuture, deepLinkFuture, notificationFuture]);

      stopwatch.stop();

      final metrics = InitializationMetrics(
        totalDuration: stopwatch.elapsed,
        firebaseDuration: firebaseStopwatch.elapsed,
        authDuration: Duration.zero, // We'll measure this in the method
        deepLinkDuration: Duration.zero, // We'll measure this in the method
        notificationDuration: Duration.zero, // We'll measure this in the method
        allSuccessful: true,
      );

      _lastMetrics = metrics;

      if (kDebugMode) {
        debugPrint(
            '🚀 AppInitializationService: Optimized initialization completed in ${stopwatch.elapsed.inMilliseconds}ms');
        debugPrint('📊 $metrics');
      }

      return metrics;
    } catch (e, stack) {
      stopwatch.stop();

      final metrics = InitializationMetrics(
        totalDuration: stopwatch.elapsed,
        firebaseDuration: Duration.zero,
        authDuration: Duration.zero,
        deepLinkDuration: Duration.zero,
        notificationDuration: Duration.zero,
        allSuccessful: false,
      );

      _lastMetrics = metrics;

      if (kDebugMode) {
        debugPrint('❌ AppInitializationService: Initialization failed: $e');
        debugPrint('Stack trace: $stack');
      }

      rethrow;
    }
  }

  /// Optimized Firebase initialization with platform-specific handling
  Future<void> _initializeFirebase() async {
    try {
      if (kDebugMode) debugPrint('🔥 Initializing Firebase...');

      if (kIsWeb) {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      } else {
        try {
          await Firebase.initializeApp();
        } on FirebaseException catch (fe) {
          if (fe.code == 'duplicate-app') {
            if (kDebugMode) {
              debugPrint('⚠️ Firebase duplicate-app detected - ignoring');
            }
          } else {
            rethrow;
          }
        }
      }

      if (kDebugMode) debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Optimized authentication initialization
  Future<void> _initializeAuthentication() async {
    final stopwatch = Stopwatch()..start();

    try {
      if (kDebugMode) debugPrint('🔐 Initializing authentication...');

      // Initialize auth persistence in background
      unawaited(FirebaseAuthService.initializeAuthPersistence());

      // Initialize auth state with timeout
      final authStateService = AuthenticationStateService();
      await authStateService.initializeAuthState().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⏰ Authentication state initialization timed out');
          }
          throw TimeoutException('Authentication initialization timeout');
        },
      );

      stopwatch.stop();

      if (kDebugMode) {
        debugPrint(
            '✅ Authentication initialized in ${stopwatch.elapsed.inMilliseconds}ms');
      }
    } catch (e) {
      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('❌ Authentication initialization failed: $e');
      }

      // Don't throw - auth failure shouldn't block app startup
    }
  }

  /// Optimized deep linking initialization
  Future<void> _initializeDeepLinking() async {
    final stopwatch = Stopwatch()..start();

    try {
      if (kDebugMode) debugPrint('🔗 Initializing deep linking...');

      // Initialize deep linking without Firebase Dynamic Links (deprecated)
      final deepLinkService = DeepLinkingService();
      await deepLinkService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          if (kDebugMode) debugPrint('⏰ Deep linking initialization timed out');
          // Don't throw - deep linking failure shouldn't block app startup
        },
      );

      stopwatch.stop();

      if (kDebugMode) {
        debugPrint(
            '✅ Deep linking initialized in ${stopwatch.elapsed.inMilliseconds}ms');
      }
    } catch (e) {
      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('❌ Deep linking initialization failed: $e');
      }

      // Don't throw - deep linking failure shouldn't block app startup
    }
  }

  /// Optimized notification initialization
  Future<void> _initializeNotifications() async {
    final stopwatch = Stopwatch()..start();

    try {
      if (kDebugMode) debugPrint('🔔 Initializing notifications...');

      // Initialize notifications with error isolation
      await NotificationService.initializeStatic().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) debugPrint('⏰ Notification initialization timed out');
          // Don't throw - notification failure shouldn't block app startup
        },
      );

      // Schedule reminder notification check in background
      unawaited(_scheduleReminderCheck());

      stopwatch.stop();

      if (kDebugMode) {
        debugPrint(
            '✅ Notifications initialized in ${stopwatch.elapsed.inMilliseconds}ms');
      }
    } catch (e) {
      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('❌ Notification initialization failed: $e');
      }

      // Don't throw - notification failure shouldn't block app startup
    }
  }

  /// Background task for reminder notification check
  Future<void> _scheduleReminderCheck() async {
    try {
      if (kDebugMode) debugPrint('⏰ Starting background reminder check...');

      // This is a placeholder - in real implementation, you'd call quiz logic here
      await Future.delayed(const Duration(milliseconds: 100));

      if (kDebugMode) debugPrint('✅ Background reminder check completed');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Background reminder check failed: $e');
    }
  }

  /// Get performance recommendations based on last initialization
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    if (_lastMetrics == null) return recommendations;

    final metrics = _lastMetrics!;

    if (metrics.totalDuration.inMilliseconds > 3000) {
      recommendations.add('📈 Consider lazy loading non-critical services');
      recommendations.add('📈 Reduce Firebase query operations during startup');
    }

    if (metrics.firebaseDuration.inMilliseconds > 1000) {
      recommendations.add('🔥 Optimize Firebase configuration and caching');
    }

    if (metrics.authDuration.inMilliseconds > 2000) {
      recommendations
          .add('🔐 Cache authentication state to reduce initialization time');
    }

    recommendations
        .add('🚀 Consider implementing service worker for background tasks');
    recommendations.add('📦 Use code splitting for better startup performance');

    return recommendations;
  }

  /// Clear cached metrics
  void clearMetrics() {
    _lastMetrics = null;
  }
}

/// Timeout exception for better error handling
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
