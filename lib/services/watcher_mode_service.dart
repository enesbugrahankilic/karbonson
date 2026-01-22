/// Watcher Mode Service - Advanced Monitoring and Debugging
/// 
/// Özellikleri:
/// - Real-time event tracking
/// - Performance monitoring
/// - Error tracking
/// - User behavior tracking
/// - Data change monitoring
/// - Network activity logging
/// - Custom analytics

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:collection';

/// Event type enumeration
enum WatcherEventType {
  // Firebase events
  firebaseConnect,
  firebaseDisconnect,
  authStateChange,
  dataFetched,
  dataSaved,
  
  // UI events
  navigationChange,
  userInteraction,
  formSubmit,
  
  // Performance events
  performanceIssue,
  slowOperation,
  
  // Error events
  error,
  warning,
  
  // Custom events
  custom,
}

/// Watcher Event
class WatcherEvent {
  final WatcherEventType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final StackTrace? stackTrace;
  final String? category;
  final int? durationMs;

  WatcherEvent({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.metadata,
    this.stackTrace,
    this.category,
    this.durationMs,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'category': category,
    'duration_ms': durationMs,
    'metadata': metadata,
    if (stackTrace != null) 'stack_trace': stackTrace.toString(),
  };

  @override
  String toString() => '[${type.name}] $message at ${timestamp.toIso8601String()}';
}

/// Watcher Session
class WatcherSession {
  final String sessionId;
  final DateTime startTime;
  DateTime? endTime;
  final Queue<WatcherEvent> events = Queue();
  final int maxEventsBuffer = 1000;

  WatcherSession({
    required this.sessionId,
  }) : startTime = DateTime.now();

  void addEvent(WatcherEvent event) {
    events.addLast(event);
    // Keep buffer size limited
    while (events.length > maxEventsBuffer) {
      events.removeFirst();
    }
  }

  int get eventCount => events.length;
  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  
  bool get isActive => endTime == null;

  void end() {
    endTime = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'duration_ms': duration.inMilliseconds,
    'event_count': events.length,
    'events': events.map((e) => e.toJson()).toList(),
  };
}

/// Watcher Mode Service
class WatcherModeService {
  static final WatcherModeService _instance = WatcherModeService._internal();
  factory WatcherModeService() => _instance;
  WatcherModeService._internal();

  bool _isEnabled = false;
  WatcherSession? _currentSession;
  final List<WatcherSession> _sessionHistory = [];
  final StreamController<WatcherEvent> _eventController = 
    StreamController<WatcherEvent>.broadcast();

  // Statistics
  final Map<WatcherEventType, int> _eventCounts = {};
  final Map<String, int> _categoryCounts = {};
  final List<int> _operationDurations = [];

  bool get isEnabled => _isEnabled;
  Stream<WatcherEvent> get eventStream => _eventController.stream;
  WatcherSession? get currentSession => _currentSession;
  int get totalSessions => _sessionHistory.length;

  /// Enable watcher mode
  Future<void> enable({
    String? sessionName,
  }) async {
    if (_isEnabled) return;

    _isEnabled = true;
    _currentSession = WatcherSession(
      sessionId: sessionName ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (kDebugMode) {
      debugPrint('👁️ Watcher Mode ENABLED - Session: ${_currentSession!.sessionId}');
    }

    // Start system monitoring
    _startSystemMonitoring();
  }

  /// Disable watcher mode
  Future<void> disable() async {
    if (!_isEnabled) return;

    _isEnabled = false;
    _currentSession?.end();

    if (_currentSession != null) {
      _sessionHistory.add(_currentSession!);
    }

    if (kDebugMode) {
      debugPrint('👁️ Watcher Mode DISABLED - Total Events: ${_currentSession?.eventCount ?? 0}');
    }
  }

  /// Track custom event
  void trackEvent(
    WatcherEventType type,
    String message, {
    Map<String, dynamic>? metadata,
    String? category,
    int? durationMs,
    StackTrace? stackTrace,
  }) {
    if (!_isEnabled) return;

    final event = WatcherEvent(
      type: type,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
      stackTrace: stackTrace,
      category: category,
      durationMs: durationMs,
    );

    _currentSession?.addEvent(event);
    _eventController.add(event);

    // Update statistics
    _eventCounts[type] = (_eventCounts[type] ?? 0) + 1;
    if (category != null) {
      _categoryCounts[category] = (_categoryCounts[category] ?? 0) + 1;
    }
    if (durationMs != null) {
      _operationDurations.add(durationMs);
    }

    if (kDebugMode) {
      debugPrint('📝 ${event.type.name}: $message');
    }
  }

  /// Track Firebase event
  void trackFirebaseEvent(
    String event, {
    Map<String, dynamic>? data,
  }) {
    trackEvent(
      WatcherEventType.custom,
      'Firebase: $event',
      metadata: data ?? {},
      category: 'firebase',
    );
  }

  /// Track navigation
  void trackNavigation(String from, String to) {
    trackEvent(
      WatcherEventType.navigationChange,
      'Navigated from $from to $to',
      metadata: {
        'from': from,
        'to': to,
      },
      category: 'navigation',
    );
  }

  /// Track user interaction
  void trackUserInteraction(String action, {Map<String, dynamic>? details}) {
    trackEvent(
      WatcherEventType.userInteraction,
      'User: $action',
      metadata: details ?? {},
      category: 'user_interaction',
    );
  }

  /// Track performance issue
  void trackPerformanceIssue(String issue, int durationMs) {
    trackEvent(
      WatcherEventType.performanceIssue,
      issue,
      durationMs: durationMs,
      category: 'performance',
    );
  }

  /// Track error
  void trackError(
    String error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    trackEvent(
      WatcherEventType.error,
      error,
      stackTrace: stackTrace,
      metadata: context ?? {},
      category: 'error',
    );
  }

  /// Get session statistics
  Map<String, dynamic> getStatistics() {
    final avgDuration = _operationDurations.isEmpty
        ? 0
        : _operationDurations.reduce((a, b) => a + b) ~/ _operationDurations.length;

    final maxDuration = _operationDurations.isEmpty
        ? 0
        : _operationDurations.reduce((a, b) => a > b ? a : b);

    return {
      'total_events': _currentSession?.eventCount ?? 0,
      'event_types': _eventCounts,
      'categories': _categoryCounts,
      'total_sessions': _sessionHistory.length,
      'session_duration_ms': _currentSession?.duration.inMilliseconds ?? 0,
      'performance_stats': {
        'avg_operation_ms': avgDuration,
        'max_operation_ms': maxDuration,
        'operations_tracked': _operationDurations.length,
      },
    };
  }

  /// Get current session events
  List<WatcherEvent> getCurrentSessionEvents({
    WatcherEventType? filterByType,
    String? filterByCategory,
  }) {
    if (_currentSession == null) return [];

    return _currentSession!.events
        .where((event) {
          if (filterByType != null && event.type != filterByType) return false;
          if (filterByCategory != null && event.category != filterByCategory) {
            return false;
          }
          return true;
        })
        .toList();
  }

  /// Get session history
  List<Map<String, dynamic>> getSessionHistory() {
    return _sessionHistory.map((session) => session.toJson()).toList();
  }

  /// Export current session as JSON
  Map<String, dynamic> exportCurrentSession() {
    if (_currentSession == null) {
      return {'error': 'No active session'};
    }

    return _currentSession!.toJson();
  }

  /// Clear all sessions
  void clearSessions() {
    _sessionHistory.clear();
    _eventCounts.clear();
    _categoryCounts.clear();
    _operationDurations.clear();
    if (kDebugMode) {
      debugPrint('👁️ Watcher Mode: All sessions cleared');
    }
  }

  /// Start system monitoring
  void _startSystemMonitoring() {
    // Track authentication state changes
    // Track data sync events
    // Monitor network connectivity
  }

  /// Get detailed report
  Future<Map<String, dynamic>> generateDetailedReport() async {
    return {
      'is_enabled': _isEnabled,
      'current_session': _currentSession?.toJson(),
      'statistics': getStatistics(),
      'session_history': getSessionHistory(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() => 'WatcherModeService(enabled: $_isEnabled, '
    'session: ${_currentSession?.sessionId}, '
    'events: ${_currentSession?.eventCount ?? 0})';
}

/// Performance tracker helper
class PerformanceTracker {
  final String operationName;
  final Stopwatch _stopwatch = Stopwatch();
  final WatcherModeService _watcher = WatcherModeService();

  PerformanceTracker(this.operationName);

  void start() {
    _stopwatch.start();
  }

  void end({bool trackIfSlow = true, int slowThresholdMs = 1000}) {
    _stopwatch.stop();

    if (trackIfSlow && _stopwatch.elapsedMilliseconds > slowThresholdMs) {
      _watcher.trackPerformanceIssue(
        'Slow operation: $operationName',
        _stopwatch.elapsedMilliseconds,
      );
    }

    _watcher.trackEvent(
      WatcherEventType.custom,
      '$operationName completed',
      durationMs: _stopwatch.elapsedMilliseconds,
      category: 'performance',
    );
  }

  int get elapsedMs => _stopwatch.elapsedMilliseconds;
}
