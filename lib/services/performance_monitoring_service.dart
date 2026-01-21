// lib/services/performance_monitoring_service.dart
// Monitor app performance metrics (FPS, memory, startup time)

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:developer' as developer;
import 'analytics_service.dart';

class PerformanceMonitoringService {
  static final PerformanceMonitoringService _instance = PerformanceMonitoringService._internal();
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();

  bool _isInitialized = false;
  Timer? _fpsTimer;
  int _frameCount = 0;
  double _averageFps = 60.0;
  DateTime? _appStartTime;
  final List<double> _fpsSamples = [];

  /// Initialize performance monitoring
  void initialize() {
    if (_isInitialized) return;

    _appStartTime = DateTime.now();
    _startFpsMonitoring();

    if (kDebugMode) {
      debugPrint('✅ Performance monitoring initialized');
    }

    _isInitialized = true;
  }

  /// Start FPS monitoring (60 FPS standard)
  void _startFpsMonitoring() {
    _fpsTimer?.cancel();

    _fpsTimer = Timer.periodic(Duration(seconds: 1), (_) {
      // Calculate FPS based on frame count in the last second
      final fps = _frameCount.toDouble();
      _frameCount = 0;

      _fpsSamples.add(fps);
      if (_fpsSamples.length > 60) {
        _fpsSamples.removeAt(0); // Keep last 60 seconds
      }

      _averageFps = _fpsSamples.isEmpty ? 60.0 : _fpsSamples.reduce((a, b) => a + b) / _fpsSamples.length;

      if (kDebugMode && _averageFps < 55) {
        debugPrint('⚠️ LOW FPS WARNING: ${_averageFps.toStringAsFixed(1)} FPS');
      }
    });
  }

  /// Record frame render
  void recordFrameRender() {
    _frameCount++;
  }

  /// Get current FPS
  double getCurrentFps() => _averageFps;

  /// Get app startup time
  Duration? getStartupTime() {
    if (_appStartTime == null) return null;
    return DateTime.now().difference(_appStartTime!);
  }

  /// Log startup metrics
  Future<void> logStartupMetrics() async {
    final startupTime = getStartupTime();

    if (startupTime != null) {
      if (kDebugMode) {
        debugPrint('📊 App startup time: ${startupTime.inMilliseconds}ms');
      }

      await AnalyticsService().logCustomEvent('app_startup', {
        'startup_time_ms': startupTime.inMilliseconds,
        'startup_time_seconds': startupTime.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Flag if startup is slow (> 3 seconds)
      if (startupTime.inSeconds > 3) {
        await AnalyticsService().logError('SlowStartup', 'App startup took ${startupTime.inSeconds}s');
      }
    }
  }

  /// Measure operation duration
  Future<T> measureDuration<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('⏱️ $operationName completed in ${stopwatch.elapsedMilliseconds}ms');
      }

      await AnalyticsService().logCustomEvent('operation_duration', {
        'operation': operationName,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return result;
    } catch (e) {
      stopwatch.stop();

      await AnalyticsService().logError(
        'OperationError',
        '$operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
      );

      rethrow;
    }
  }

  /// Log performance snapshot
  Future<void> logPerformanceSnapshot(String screenName) async {
    final fps = getCurrentFps();
    final startupTime = getStartupTime();

    if (kDebugMode) {
      debugPrint('📊 Performance snapshot for $screenName:');
      debugPrint('   FPS: ${fps.toStringAsFixed(1)}');
      debugPrint('   Uptime: ${startupTime?.inSeconds}s');
    }

    await AnalyticsService().logCustomEvent('performance_snapshot', {
      'screen': screenName,
      'fps': fps.toStringAsFixed(1),
      'uptime_seconds': startupTime?.inSeconds ?? 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Detect performance degradation
  bool hasPerformanceDegradation() {
    // Flag if FPS drops below 50
    return _averageFps < 50;
  }

  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    return {
      'current_fps': _averageFps.toStringAsFixed(1),
      'app_uptime_seconds': getStartupTime()?.inSeconds,
      'fps_samples': _fpsSamples.length,
      'performance_degraded': hasPerformanceDegradation(),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose
  void dispose() {
    _fpsTimer?.cancel();
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🗑️ Performance monitoring disposed');
    }
  }
}
