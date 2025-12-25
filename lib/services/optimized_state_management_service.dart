// lib/services/optimized_state_management_service.dart
// Performance-optimized state management with caching, debouncing, and lazy loading

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

/// State management performance metrics
class StateMetrics {
  final int stateChanges;
  final int totalUpdateTimeMs;
  final int averageUpdateTimeMs;
  final List<String> slowStateChanges;
  final int memoryUsage;
  final int activeBlocs;

  const StateMetrics({
    required this.stateChanges,
    required this.totalUpdateTimeMs,
    required this.averageUpdateTimeMs,
    required this.slowStateChanges,
    required this.memoryUsage,
    required this.activeBlocs,
  });

  Map<String, dynamic> toJson() => {
        'state_changes': stateChanges,
        'total_update_time_ms': totalUpdateTimeMs,
        'average_update_time_ms': averageUpdateTimeMs,
        'slow_state_changes_count': slowStateChanges.length,
        'slow_state_changes': slowStateChanges,
        'memory_usage_kb': memoryUsage ~/ 1024,
        'active_blocs': activeBlocs,
      };
}

/// Cache entry for state data
class StateCacheEntry<T> {
  final T data;
  final DateTime expiresAt;
  int accessCount;
  DateTime lastAccessed;

  StateCacheEntry({
    required this.data,
    required this.expiresAt,
    this.accessCount = 0,
    DateTime? lastAccessed,
  }) : lastAccessed = lastAccessed ?? DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  void incrementAccess() {
    accessCount++;
    lastAccessed = DateTime.now();
  }

  int get ageInSeconds =>
      DateTime.now().difference(lastAccessed).inSeconds.abs();
}

/// Performance-optimized event base class
abstract class OptimizedEvent extends Equatable {
  final DateTime timestamp;

  OptimizedEvent() : timestamp = DateTime.now();

  @override
  List<Object?> get props => [timestamp];
}

/// Debounced event wrapper for performance optimization
class DebouncedEvent<T extends OptimizedEvent> extends OptimizedEvent {
  final T originalEvent;
  final StreamController<T> _controller = StreamController<T>.broadcast();
  final Duration debounceDuration;
  Timer? _debounceTimer;

  DebouncedEvent({
    required this.originalEvent,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  Stream<T> get stream => _controller.stream;

  void addEvent(T event) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      _controller.add(event);
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
    _controller.close();
  }
}

/// Performance-optimized BLoC base class
abstract class OptimizedBloc<E extends OptimizedEvent, S extends Equatable>
    extends Bloc<E, S> {
  final Duration _stateCacheTTL = const Duration(minutes: 5);
  static const int _maxStateCacheEntries = 100;

  final Map<String, StateCacheEntry> _stateCache = {};
  int _stateChangeCount = 0;
  int _totalUpdateTimeMs = 0;
  final List<String> _slowStateChanges = [];

  // Performance tracking
  bool _isPerformanceMonitoringEnabled = true;

  OptimizedBloc(super.initialState) {
    // Enable performance monitoring in debug mode
    _isPerformanceMonitoringEnabled = kDebugMode;
  }

  /// Cache state with automatic cleanup
  void _cacheState(String cacheKey, Equatable state) {
    try {
      final entry = StateCacheEntry(
        data: state,
        expiresAt: DateTime.now().add(_stateCacheTTL),
      );

      // Remove existing entry if present
      final existing = _stateCache[cacheKey];
      if (existing != null && !existing.isExpired) {
        entry.incrementAccess();
      }

      // Add new entry
      _stateCache[cacheKey] = entry;

      // Clean up old entries if cache is full
      if (_stateCache.length > _maxStateCacheEntries) {
        _cleanupStateCache();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cache state: $e');
      }
    }
  }

  /// Get cached state if available
  Equatable? _getCachedState(String cacheKey) {
    try {
      final entry = _stateCache[cacheKey];
      if (entry != null && !entry.isExpired) {
        entry.incrementAccess();
        return entry.data;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to get cached state: $e');
      }
    }
    return null;
  }

  /// Clean up expired or least accessed state cache entries
  void _cleanupStateCache() {
    try {
      final expiredKeys = <String>[];
      final leastAccessedEntries = <MapEntry<String, StateCacheEntry>>[];

      for (final entry in _stateCache.entries) {
        if (entry.value.isExpired) {
          expiredKeys.add(entry.key);
        } else {
          leastAccessedEntries.add(entry);
        }
      }

      // Remove expired entries
      for (final key in expiredKeys) {
        _stateCache.remove(key);
      }

      // If still over limit, remove least accessed entries
      if (_stateCache.length > _maxStateCacheEntries) {
        leastAccessedEntries
            .sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));

        final entriesToRemove = leastAccessedEntries
            .take(_stateCache.length - _maxStateCacheEntries)
            .toList();

        for (final entry in entriesToRemove) {
          _stateCache.remove(entry.key);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ State cache cleanup failed: $e');
      }
    }
  }

  /// Optimized emit with performance tracking
  @override
  void emit(S state) {
    if (!_isPerformanceMonitoringEnabled) {
      super.emit(state);
      return;
    }

    final stopwatch = Stopwatch()..start();

    super.emit(state);

    stopwatch.stop();

    _stateChangeCount++;
    _totalUpdateTimeMs += stopwatch.elapsedMilliseconds;

    // Track slow state changes
    if (stopwatch.elapsedMilliseconds > 16) {
      // > 16ms (60fps)
      _slowStateChanges
          .add('State change took ${stopwatch.elapsedMilliseconds}ms');
      if (kDebugMode) {
        debugPrint('🐌 Slow state change: ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  /// Get current performance metrics
  StateMetrics get metrics => StateMetrics(
        stateChanges: _stateChangeCount,
        totalUpdateTimeMs: _totalUpdateTimeMs,
        averageUpdateTimeMs: _stateChangeCount > 0
            ? (_totalUpdateTimeMs / _stateChangeCount).round()
            : 0,
        slowStateChanges: List.from(_slowStateChanges),
        memoryUsage: _estimateMemoryUsage(),
        activeBlocs: _getActiveBlocCount(),
      );

  /// Estimate memory usage for state management
  int _estimateMemoryUsage() {
    try {
      // Rough estimation based on cache entries
      return _stateCache.length * 1024; // 1KB per entry estimate
    } catch (e) {
      return 0;
    }
  }

  /// Get count of active BLoCs (this is a simplified version)
  int _getActiveBlocCount() {
    // In a real implementation, you'd track all active BLoCs globally
    return 1; // This BLoC
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    final currentMetrics = metrics;

    if (currentMetrics.slowStateChanges.isNotEmpty) {
      recommendations.add(
          '🐌 Slow state changes detected - consider optimizing event handlers');
      recommendations.add('📈 Implement debouncing for rapid state changes');
    }

    if (currentMetrics.averageUpdateTimeMs > 16) {
      recommendations
          .add('⚡ High average state update time - reduce state complexity');
    }

    if (_stateCache.length > 50) {
      recommendations.add(
          '🧠 Large state cache detected - consider reducing TTL or cache size');
    }

    recommendations.add('🔄 Use const constructors for immutable states');
    recommendations
        .add('📦 Implement selective state updates to minimize rebuilds');

    return recommendations;
  }

  /// Clear all metrics and cache
  void clearMetrics() {
    _stateChangeCount = 0;
    _totalUpdateTimeMs = 0;
    _slowStateChanges.clear();
    _stateCache.clear();
  }

  /// Enable/disable performance monitoring
  void setPerformanceMonitoring(bool enabled) {
    _isPerformanceMonitoringEnabled = enabled;
  }
}

/// Widget performance optimization helpers
class WidgetOptimization {
  /// Create a performance-optimized builder with caching
  static Widget cachedBuilder({
    required String cacheKey,
    required Widget Function(BuildContext context) builder,
    Duration cacheDuration = const Duration(minutes: 5),
    bool enableCache = true,
  }) {
    if (!enableCache) {
      return Builder(builder: builder);
    }

    return _CachedBuilder(
      cacheKey: cacheKey,
      builder: builder,
      cacheDuration: cacheDuration,
    );
  }

  /// Create a lazy-loaded widget that only builds when needed
  static Widget lazyBuilder({
    required Widget Function(BuildContext context) builder,
    Key? key,
  }) {
    return _LazyBuilder(
      builder: builder,
      key: key,
    );
  }

  /// Create a const-optimized container
  static Container optimizedContainer({
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    Alignment? alignment,
    Decoration? decoration,
    Key? key,
  }) {
    return Container(
      key: key,
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      color: color,
      alignment: alignment,
      decoration: decoration,
      child: child,
    );
  }

  /// Create a const-optimized padding widget
  static Padding optimizedPadding({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Key? key,
  }) {
    return Padding(
      key: key,
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }

  /// Create a const-optimized sized box
  static SizedBox optimizedSizedBox({
    double? width,
    double? height,
    Widget? child,
    Key? key,
  }) {
    return SizedBox(
      key: key,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Create a const-optimized center widget
  static Center optimizedCenter({
    Widget? child,
    Key? key,
  }) {
    return Center(
      key: key,
      child: child,
    );
  }

  /// Create a performance-optimized list view
  static ListView optimizedListView({
    required List<Widget> children,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    double? itemExtent,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    int? semanticChildCount,
    Key? key,
  }) {
    return ListView(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      children: children,
    );
  }

  /// Create a performance-optimized column
  static Column optimizedColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Key? key,
  }) {
    return Column(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }

  /// Create a performance-optimized row
  static Row optimizedRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Key? key,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}

/// Cached builder widget for performance optimization
class _CachedBuilder extends StatefulWidget {
  final String cacheKey;
  final Widget Function(BuildContext context) builder;
  final Duration cacheDuration;

  const _CachedBuilder({
    required this.cacheKey,
    required this.builder,
    required this.cacheDuration,
  });

  @override
  State<_CachedBuilder> createState() => _CachedBuilderState();
}

class _CachedBuilderState extends State<_CachedBuilder> {
  Widget? _cachedWidget;
  DateTime? _lastBuildTime;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Check if we can use cached widget
    if (_cachedWidget != null &&
        _lastBuildTime != null &&
        now.difference(_lastBuildTime!) < widget.cacheDuration) {
      return _cachedWidget!;
    }

    // Build new widget and cache it
    _cachedWidget = widget.builder(context);
    _lastBuildTime = now;

    return _cachedWidget!;
  }
}

/// Lazy builder widget that only builds when needed
class _LazyBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const _LazyBuilder({
    required this.builder,
    super.key,
  });

  @override
  State<_LazyBuilder> createState() => _LazyBuilderState();
}

class _LazyBuilderState extends State<_LazyBuilder> {
  bool _isBuilt = false;
  Widget? _cachedWidget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Build on first access
    if (!_isBuilt) {
      _cachedWidget = widget.builder(context);
      _isBuilt = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget ?? const SizedBox.shrink();
  }
}

/// Global state management performance tracker
class GlobalStateTracker {
  static final GlobalStateTracker _instance = GlobalStateTracker._internal();
  factory GlobalStateTracker() => _instance;
  GlobalStateTracker._internal();

  final List<StateMetrics> _blocMetrics = [];
  final List<String> _performanceEvents = [];

  /// Register a BLoC's metrics
  void registerBlocMetrics(StateMetrics metrics) {
    _blocMetrics.add(metrics);

    // Keep only last 100 metrics
    if (_blocMetrics.length > 100) {
      _blocMetrics.removeAt(0);
    }
  }

  /// Get global performance summary
  Map<String, dynamic> getGlobalPerformanceSummary() {
    final totalStateChanges =
        _blocMetrics.fold<int>(0, (sum, m) => sum + m.stateChanges);
    final averageUpdateTime = _blocMetrics.isNotEmpty
        ? _blocMetrics.fold<int>(0, (sum, m) => sum + m.averageUpdateTimeMs) /
            _blocMetrics.length
        : 0;
    final slowChangesCount =
        _blocMetrics.fold<int>(0, (sum, m) => sum + m.slowStateChanges.length);

    return {
      'total_blocs': _blocMetrics.length,
      'total_state_changes': totalStateChanges,
      'average_update_time_ms': averageUpdateTime.round(),
      'total_slow_changes': slowChangesCount,
      'performance_events': List.from(_performanceEvents),
      'recommendations': _getGlobalRecommendations(),
    };
  }

  /// Get global performance recommendations
  List<String> _getGlobalRecommendations() {
    final recommendations = <String>[];

    final summary = getGlobalPerformanceSummary();

    if (summary['total_state_changes'] > 1000) {
      recommendations
          .add('📊 High state change frequency - consider batching updates');
    }

    if (summary['average_update_time_ms'] > 20) {
      recommendations
          .add('⚡ High average state update time - optimize event handlers');
    }

    if (summary['total_slow_changes'] > 10) {
      recommendations.add(
          '🐌 Multiple slow state changes - investigate performance bottlenecks');
    }

    recommendations.add(
        '🎯 Implement selective state subscriptions to reduce unnecessary rebuilds');
    recommendations
        .add('📦 Use const constructors and static widgets where possible');

    return recommendations;
  }

  /// Clear all tracked metrics
  void clearMetrics() {
    _blocMetrics.clear();
    _performanceEvents.clear();
  }
}
