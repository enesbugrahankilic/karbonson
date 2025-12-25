// lib/services/performance_service.dart

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance =>
      _instance ??= PerformanceService._();

  PerformanceService._();

  // Performance Metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final StreamController<PerformanceReport> _reportController =
      StreamController<PerformanceReport>.broadcast();

  Stream<PerformanceReport> get reportStream => _reportController.stream;

  // Memory Management
  Timer? _memoryCleanupTimer;
  final int _maxCacheSize = 50; // Maximum number of cached items
  final int _optimizedCacheSize = 100; // Optimized cache size

  // Image Caching
  final Map<String, ImageCacheEntry> _imageCache = {};
  final Map<String, int> _imageAccessCount = {};

  void initialize() {
    _startMemoryMonitoring();
    _startPerformanceReporting();

    developer.log('PerformanceService initialized');
  }

  // Memory Management
  void _startMemoryMonitoring() {
    _memoryCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupMemory();
    });
  }

  void _cleanupMemory() {
    // Clean up expired cache entries
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _imageCache.entries) {
      if (now.difference(entry.value.createdAt).inMinutes > 30) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _imageCache.remove(key);
      _imageAccessCount.remove(key);
    }

    // Enforce cache size limit
    if (_imageCache.length > _maxCacheSize) {
      _evictLeastRecentlyUsed();
    }

    if (expiredKeys.isNotEmpty || _imageCache.length > _maxCacheSize) {
      developer.log('Memory cleanup completed: ${expiredKeys.length} expired, '
          'cache size: ${_imageCache.length}');
    }
  }

  void _evictLeastRecentlyUsed() {
    // Sort by access count and remove least frequently used
    final sortedEntries = _imageAccessCount.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final toRemove =
        sortedEntries.take((_imageCache.length - _maxCacheSize ~/ 2)).toList();

    for (final entry in toRemove) {
      _imageCache.remove(entry.key);
      _imageAccessCount.remove(entry.key);
    }
  }

  // Lazy Loading for Images
  Future<ImageInfo?> loadImageWithCache(String url,
      {int? width, int? height}) async {
    final cacheKey = _generateCacheKey(url, width, height);

    // Check cache first
    final cachedEntry = _imageCache[cacheKey];
    if (cachedEntry != null) {
      _imageAccessCount[cacheKey] = (_imageAccessCount[cacheKey] ?? 0) + 1;
      return cachedEntry.imageInfo;
    }

    try {
      // In a real implementation, you would load the image from network/local storage
      // For now, we'll simulate image loading
      final imageInfo = await _loadImageFromNetwork(url);

      if (imageInfo != null) {
        _imageCache[cacheKey] = ImageCacheEntry(
          imageInfo: imageInfo,
          createdAt: DateTime.now(),
        );
        _imageAccessCount[cacheKey] = 1;
      }

      return imageInfo;
    } catch (e) {
      developer.log('Failed to load image: $url, Error: $e');
      return null;
    }
  }

  Future<ImageInfo?> _loadImageFromNetwork(String url) async {
    // Simulate network image loading
    await Future.delayed(const Duration(milliseconds: 100));
    return null; // Placeholder - would return actual ImageInfo
  }

  String _generateCacheKey(String url, int? width, int? height) {
    return '${url}_${width}x$height';
  }

  // Widget Performance Optimization
  Widget optimizeWidget(Widget widget, {String? debugName}) {
    final optimizedWidget = RepaintBoundary(
      child: widget,
    );

    // Add performance monitoring for complex widgets
    return PerformanceMonitor(
      name: debugName ?? 'Widget',
      child: optimizedWidget,
    );
  }

  // Performance Monitoring
  void startMeasure(String operation) {
    _metrics[operation] = PerformanceMetric(
      name: operation,
      startTime: DateTime.now(),
    );
  }

  void endMeasure(String operation) {
    final metric = _metrics[operation];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      _metrics[operation] = metric;

      developer.log(
          'Performance: $operation took ${metric.duration?.inMilliseconds ?? 0}ms');
    }
  }

  Future<T> measureAsync<T>(String operation, Future<T> Function() fn) async {
    startMeasure(operation);
    try {
      final result = await fn();
      return result;
    } finally {
      endMeasure(operation);
    }
  }

  // Performance Reporting
  void _startPerformanceReporting() {
    Timer.periodic(const Duration(minutes: 2), (_) {
      _generatePerformanceReport();
    });
  }

  void _generatePerformanceReport() {
    if (_metrics.isEmpty) return;

    final report = PerformanceReport(
      timestamp: DateTime.now(),
      metrics: Map.from(_metrics),
      memoryUsage: _getMemoryUsage(),
      cacheSize: _imageCache.length,
    );

    _reportController.add(report);

    // Log significant performance issues
    for (final metric in _metrics.values) {
      if (metric.duration != null && metric.duration!.inMilliseconds > 100) {
        developer.log('Performance Warning: ${metric.name} took '
            '${metric.duration!.inMilliseconds}ms');
      }
    }
  }

  Map<String, dynamic> _getMemoryUsage() {
    // This is a simplified memory usage tracker
    return {
      'cache_entries': _imageCache.length,
      'active_metrics': _metrics.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Frame Rate Monitoring
  void monitorFrameRate(VoidCallback frameCallback) {
    SchedulerBinding.instance.addPersistentFrameCallback((duration) {
      final fps = 1000 / duration.inMilliseconds;

      if (fps < 30) {
        developer.log('Low FPS detected: ${fps.toStringAsFixed(1)}');
      }

      frameCallback();
    });
  }

  // ⚡ HIZLANDIRMA: Async İşlemleri Optimize Et
  Future<T> measureNetworkOperation<T>(
      String operation, Future<T> Function() fn) async {
    startMeasure('network_$operation');
    try {
      // Network timeout ve retry logic
      final result = await fn().timeout(const Duration(seconds: 10));
      return result;
    } catch (e) {
      developer.log('Network operation failed: $operation - $e');
      rethrow;
    } finally {
      endMeasure('network_$operation');
    }
  }

  // ⚡ HIZLANDIRMA: Database İşlemlerini Ölç
  Future<T> measureDatabaseOperation<T>(
      String operation, Future<T> Function() fn) async {
    startMeasure('db_$operation');
    try {
      final result = await fn().timeout(const Duration(seconds: 15));
      return result;
    } catch (e) {
      developer.log('Database operation failed: $operation - $e');
      rethrow;
    } finally {
      endMeasure('db_$operation');
    }
  }

  // ⚡ HIZLANDIRMA: Widget Build Performansı İzleme
  void trackWidgetBuildPerformance(
      String widgetName, VoidCallback buildCallback) {
    final stopwatch = Stopwatch()..start();
    buildCallback();
    stopwatch.stop();

    if (stopwatch.elapsedMilliseconds > 16) {
      // 60 FPS threshold
      developer.log(
          'Slow widget build detected: $widgetName took ${stopwatch.elapsedMilliseconds}ms');
      startMeasure('slow_build_$widgetName');
      endMeasure('slow_build_$widgetName');
    }
  }

  // ⚡ HIZLANDIRMA: Memory Leak Detection
  Timer? _memoryLeakDetector;
  final Map<String, DateTime> _activeObjects = {};

  void registerObject(String objectId) {
    _activeObjects[objectId] = DateTime.now();
  }

  void unregisterObject(String objectId) {
    _activeObjects.remove(objectId);
  }

  void startMemoryLeakDetection() {
    _memoryLeakDetector = Timer.periodic(const Duration(minutes: 10), (_) {
      _detectMemoryLeaks();
    });
  }

  void _detectMemoryLeaks() {
    final now = DateTime.now();
    final suspiciousObjects = <String>[];

    for (final entry in _activeObjects.entries) {
      if (now.difference(entry.value).inMinutes > 60) {
        suspiciousObjects.add(entry.key);
      }
    }

    if (suspiciousObjects.isNotEmpty) {
      developer.log(
          'Potential memory leaks detected: ${suspiciousObjects.join(', ')}');
    }
  }

  // ⚡ HIZLANDIRMA: Optimized Generic Cache Management
  final Map<String, CacheEntry> _optimizedCache = {};
  final Queue<String> _lruQueue = Queue<String>();
  static const int _optimizedMaxCacheSize = 100;

  void putInCache<T>(String key, T data, {Duration? expiry}) {
    if (_optimizedCache.length >= _optimizedMaxCacheSize) {
      _evictOldestCache();
    }

    _optimizedCache[key] = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      expiry: expiry,
    );
    _lruQueue.add(key);
  }

  T? getFromCache<T>(String key) {
    final entry = _optimizedCache[key];
    if (entry == null) return null;

    if (entry.expiry != null &&
        DateTime.now().difference(entry.createdAt) > entry.expiry!) {
      _optimizedCache.remove(key);
      _lruQueue.remove(key);
      return null;
    }

    // Move to end (most recently used)
    _lruQueue.remove(key);
    _lruQueue.add(key);

    return entry.data as T;
  }

  void _evictOldestCache() {
    if (_lruQueue.isNotEmpty) {
      final oldestKey = _lruQueue.removeFirst();
      _optimizedCache.remove(oldestKey);
    }
  }

  // ⚡ HIZLANDIRMA: Batch Operations
  Future<List<T>> processBatch<T, R>(
    List<R> items,
    Future<T> Function(R item) processor, {
    int batchSize = 10,
  }) async {
    final results = <T>[];

    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.sublist(
          i, i + batchSize < items.length ? i + batchSize : items.length);

      final batchResults =
          await Future.wait(batch.map((item) => processor(item)));

      results.addAll(batchResults);
    }

    return results;
  }

  // ⚡ HIZLANDIRMA: Performance Alerts
  void checkPerformanceThresholds() {
    for (final metric in _metrics.values) {
      if (metric.duration != null) {
        final durationMs = metric.duration!.inMilliseconds;

        if (durationMs > 1000) {
          developer.log('⚠️ CRITICAL: ${metric.name} took ${durationMs}ms');
        } else if (durationMs > 500) {
          developer.log('⚠️ WARNING: ${metric.name} took ${durationMs}ms');
        } else if (durationMs > 100) {
          developer.log('ℹ️ INFO: ${metric.name} took ${durationMs}ms');
        }
      }
    }
  }

  // Lazy List Building
  Widget buildLazyList<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index)
        itemBuilder,
    required Widget Function(BuildContext context, int index)
        placeholderBuilder,
    int preloadDistance = 5,
  }) {
    return LazyLoadListView<T>(
      items: items,
      itemBuilder: itemBuilder,
      placeholderBuilder: placeholderBuilder,
      preloadDistance: preloadDistance,
    );
  }

  void dispose() {
    _memoryCleanupTimer?.cancel();
    _reportController.close();
    _imageCache.clear();
    _imageAccessCount.clear();
  }
}

// Supporting Classes

class ImageCacheEntry {
  final ImageInfo imageInfo;
  final DateTime createdAt;

  ImageCacheEntry({
    required this.imageInfo,
    required this.createdAt,
  });
}

class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration? expiry;

  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiry,
  });
}

class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;

  PerformanceMetric({
    required this.name,
    required this.startTime,
  });
}

class PerformanceReport {
  final DateTime timestamp;
  final Map<String, PerformanceMetric> metrics;
  final Map<String, dynamic> memoryUsage;
  final int cacheSize;

  PerformanceReport({
    required this.timestamp,
    required this.metrics,
    required this.memoryUsage,
    required this.cacheSize,
  });
}

class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? name;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.name,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  int _buildCount = 0;
  final Stopwatch _buildStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    PerformanceService.instance.startMeasure('${widget.name}_render');
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    _buildStopwatch.start();

    final result = widget.child;

    _buildStopwatch.stop();
    if (_buildStopwatch.elapsedMilliseconds > 16) {
      // 60 FPS threshold
      PerformanceService.instance.endMeasure('${widget.name}_render');
      developer.log('Slow render detected: ${widget.name} took '
          '${_buildStopwatch.elapsedMilliseconds}ms');
      PerformanceService.instance.startMeasure('${widget.name}_render');
    }

    return result;
  }
}

// Lazy Load List View Implementation
class LazyLoadListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index) placeholderBuilder;
  final int preloadDistance;

  const LazyLoadListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.placeholderBuilder,
    this.preloadDistance = 5,
  });

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _loadedIndices = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initially load first few items
    _preloadItems(0, widget.preloadDistance);
  }

  void _onScroll() {
    final startIndex = _getVisibleStart();
    final endIndex = _getVisibleEnd();
    _preloadItems(
        startIndex - widget.preloadDistance, endIndex + widget.preloadDistance);
  }

  int _getVisibleStart() {
    final scrollPosition = _scrollController.position.pixels;
    final itemHeight = 100.0; // Assume average item height
    final startIndex = (scrollPosition / itemHeight).floor();
    return startIndex.clamp(0, widget.items.length);
  }

  int _getVisibleEnd() {
    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    final itemHeight = 100.0; // Assume average item height
    final endIndex = ((scrollPosition + viewportHeight) / itemHeight).ceil();
    return endIndex.clamp(0, widget.items.length);
  }

  void _preloadItems(int start, int end) {
    for (int i = start; i <= end; i++) {
      if (i >= 0 && i < widget.items.length && !_loadedIndices.contains(i)) {
        _loadedIndices.add(i);
        // Here you would trigger lazy loading for the item at index i
        // e.g., load image, fetch data, etc.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        if (_loadedIndices.contains(index)) {
          return widget.itemBuilder(context, widget.items[index], index);
        } else {
          return widget.placeholderBuilder(context, index);
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Image Info placeholder (would be replaced with actual ImageInfo from flutter/painting)
class ImageInfo {
  final String url;
  final int width;
  final int height;

  ImageInfo({
    required this.url,
    required this.width,
    required this.height,
  });
}

// Performance Optimized Widget Extensions
extension PerformanceExtensions on Widget {
  Widget optimize({String? debugName}) {
    return PerformanceService.instance
        .optimizeWidget(this, debugName: debugName);
  }
}
