// lib/services/performance_service.dart

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceService {
  static PerformanceService? _instance;
  static PerformanceService get instance => _instance ??= PerformanceService._();
  
  PerformanceService._();

  // Performance Metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final StreamController<PerformanceReport> _reportController = 
    StreamController<PerformanceReport>.broadcast();
  
  Stream<PerformanceReport> get reportStream => _reportController.stream;

  // Memory Management
  Timer? _memoryCleanupTimer;
  int _maxCacheSize = 50; // Maximum number of cached items
  
  // Image Caching
  final Map<String, CacheEntry> _imageCache = {};
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
    
    final toRemove = sortedEntries.take((_imageCache.length - _maxCacheSize ~/ 2)).toList();
    
    for (final entry in toRemove) {
      _imageCache.remove(entry.key);
      _imageAccessCount.remove(entry.key);
    }
  }

  // Lazy Loading for Images
  Future<ImageInfo?> loadImageWithCache(String url, {int? width, int? height}) async {
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
        _imageCache[cacheKey] = CacheEntry(
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
      
      developer.log('Performance: $operation took ${metric.duration?.inMilliseconds ?? 0}ms');
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
    WidgetsBinding.instance.addPersistentFrameCallback((duration) {
      final fps = 1000 / duration.inMilliseconds;
      
      if (fps < 30) {
        developer.log('Low FPS detected: ${fps.toStringAsFixed(1)}');
      }
      
      frameCallback();
    });
  }

  // Lazy List Building
  Widget buildLazyList<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index) itemBuilder,
    required Widget Function(BuildContext context, int index) placeholderBuilder,
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

class CacheEntry {
  final ImageInfo imageInfo;
  final DateTime createdAt;

  CacheEntry({
    required this.imageInfo,
    required this.createdAt,
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
    if (_buildStopwatch.elapsedMilliseconds > 16) { // 60 FPS threshold
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
    _preloadItems(startIndex - widget.preloadDistance, 
                  endIndex + widget.preloadDistance);
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
    return PerformanceService.instance.optimizeWidget(this, debugName: debugName);
  }
}