// lib/services/asset_optimization_service.dart
// Performance-optimized asset loading with CDN integration and caching

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

/// Asset performance metrics
class AssetMetrics {
  final int totalAssetsLoaded;
  final int cacheHits;
  final int cacheMisses;
  final int averageLoadTimeMs;
  final int totalBytesCached;
  final List<String> slowLoads;

  const AssetMetrics({
    required this.totalAssetsLoaded,
    required this.cacheHits,
    required this.cacheMisses,
    required this.averageLoadTimeMs,
    required this.totalBytesCached,
    required this.slowLoads,
  });

  double get cacheHitRate =>
      totalAssetsLoaded > 0 ? (cacheHits / totalAssetsLoaded) * 100 : 0.0;

  Map<String, dynamic> toJson() => {
        'total_assets_loaded': totalAssetsLoaded,
        'cache_hits': cacheHits,
        'cache_misses': cacheMisses,
        'cache_hit_rate_percent': cacheHitRate,
        'average_load_time_ms': averageLoadTimeMs,
        'total_bytes_cached': totalBytesCached,
        'slow_loads_count': slowLoads.length,
        'slow_loads': slowLoads,
      };
}

/// CDN configuration for optimal delivery
class CDNConfig {
  final String baseUrl;
  final List<String> regions;
  final bool enableWebP;
  final bool enableCompression;
  final int maxCacheAge;
  final String fallbackUrl;

  const CDNConfig({
    required this.baseUrl,
    this.regions = const [],
    this.enableWebP = true,
    this.enableCompression = true,
    this.maxCacheAge = 86400, // 24 hours
    required this.fallbackUrl,
  });
}

/// Asset optimization service with CDN support
class AssetOptimizationService {
  static final AssetOptimizationService _instance =
      AssetOptimizationService._internal();
  factory AssetOptimizationService() => _instance;
  AssetOptimizationService._internal();

  // CDN Configuration for multiple regions
  final CDNConfig _cdnConfig = const CDNConfig(
    baseUrl: 'https://cdn.yourapp.com',
    fallbackUrl: 'https://fallback.yourapp.com',
    regions: ['us-east-1', 'eu-west-1', 'asia-southeast-1'],
    enableWebP: true,
    enableCompression: true,
    maxCacheAge: 86400,
  );

  // Asset caching
  static const Duration _assetCacheTTL = Duration(hours: 24);
  static const int _maxCacheEntries = 500;
  static const int _maxCacheSizeBytes = 100 * 1024 * 1024; // 100MB

  final Map<String, CacheEntry> _assetCache = {};
  int _currentCacheSize = 0;

  // Performance tracking
  AssetMetrics? _lastMetrics;
  int _totalAssetsLoaded = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalLoadTimeMs = 0;
  int _totalBytesCached = 0;
  final List<String> _slowLoads = [];
  static const int _maxSlowLoads = 10; // Limit slow loads list

  // Firebase Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get optimized image URL with CDN and format selection
  String getOptimizedImageUrl({
    required String imagePath,
    String? size,
    String? quality,
    bool enableWebP = true,
  }) {
    try {
      final uri = Uri.parse(_cdnConfig.baseUrl);
      final pathSegments = <String>['assets', 'images', imagePath];

      final queryParameters = <String, String>{};

      // Add size parameter if specified
      if (size != null) {
        queryParameters['size'] = size;
      }

      // Add quality parameter if specified
      if (quality != null) {
        queryParameters['q'] = quality;
      }

      // Add WebP support if enabled
      if (enableWebP && _cdnConfig.enableWebP) {
        final hasWebPSupport = kIsWeb ? _detectWebPSupport() : true;
        if (hasWebPSupport) {
          queryParameters['format'] = 'webp';
        }
      }

      final optimizedPath = pathSegments.join('/');
      final optimizedUrl = Uri(
        scheme: uri.scheme,
        host: uri.host,
        path: optimizedPath,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      ).toString();

      if (kDebugMode) {
        debugPrint('🖼️ Optimized URL: $optimizedUrl');
      }

      return optimizedUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to create optimized URL: $e');
      }
      return _cdnConfig.fallbackUrl;
    }
  }

  /// Load image with caching and optimization
  Future<Image> loadOptimizedImage({
    required String imagePath,
    int? width,
    int? height,
    BoxFit fit = BoxFit.cover,
    String? cacheKey,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      _totalAssetsLoaded++;

      // Check cache first
      final key = cacheKey ?? imagePath;
      final cached = _assetCache[key];
      if (cached != null && !cached.isExpired) {
        _cacheHits++;
        return cached.data as Image;
      }

      _cacheMisses++;

      // Get optimized URL
      final optimizedUrl = getOptimizedImageUrl(
        imagePath: imagePath,
        size: width != null && height != null ? '${width}x$height' : null,
      );

      // Load image with timeout
      final image = await _loadImageWithTimeout(optimizedUrl).timeout(
        const Duration(seconds: 10),
      );

      // Cache the result
      _cacheAsset(key, image);

      stopwatch.stop();
      _updateMetrics(stopwatch.elapsed);

      return image;
    } catch (e) {
      stopwatch.stop();
      _updateMetrics(stopwatch.elapsed);

      if (kDebugMode) {
        debugPrint('❌ Failed to load optimized image: $e');
      }

      // Return fallback image for SVG and regular images
      // Check if it's an SVG file and handle accordingly
      if (imagePath.toLowerCase().endsWith('.svg')) {
        // For SVG files, try to load as asset first, then fallback to PNG
        try {
          return Image.asset(
            'assets/icon/karbon2.png', // Use PNG fallback for SVG
            width: width?.toDouble() ?? 200,
            height: height?.toDouble() ?? 200,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/avatars/default_avatar_1.png',
                width: width?.toDouble() ?? 200,
                height: height?.toDouble() ?? 200,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return const Image(
                    image: NetworkImage(
                        'https://via.placeholder.com/200x200?text=Avatar'),
                    fit: BoxFit.cover,
                  );
                },
              );
            },
          );
        } catch (e) {
          // Final fallback
          return const Image(
            image:
                NetworkImage('https://via.placeholder.com/200x200?text=Avatar'),
            fit: BoxFit.cover,
          );
        }
      } else {
        // For regular images, try multiple fallback sources
        try {
          return Image.asset(
            'assets/avatars/default_avatar_1.png',
            width: width?.toDouble() ?? 200,
            height: height?.toDouble() ?? 200,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/icon/karbon2.png',
                width: width?.toDouble() ?? 200,
                height: height?.toDouble() ?? 200,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return const Image(
                    image: NetworkImage(
                        'https://via.placeholder.com/200x200?text=Avatar'),
                    fit: BoxFit.cover,
                  );
                },
              );
            },
          );
        } catch (e) {
          // Final fallback
          return const Image(
            image:
                NetworkImage('https://via.placeholder.com/200x200?text=Avatar'),
            fit: BoxFit.cover,
          );
        }
      }
    }
  }

  /// Get optimized CachedNetworkImage widget
  Widget getOptimizedCachedImage({
    required String imageUrl,
    int? width,
    int? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final optimizedUrl = getOptimizedImageUrl(
      imagePath: imageUrl,
      size: width != null && height != null ? '${width}x$height' : null,
    );

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width?.toDouble(),
      height: height?.toDouble(),
      fit: fit,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder,
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget,
      memCacheWidth: width,
      memCacheHeight: height,
      cacheKey: 'optimized_${optimizedUrl}_${width}x$height',
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      maxWidthDiskCache: width,
      maxHeightDiskCache: height,
      useOldImageOnUrlChange: false,
    );
  }

  /// Preload frequently used images
  Future<void> preloadImages(List<String> imagePaths) async {
    try {
      if (kDebugMode) {
        debugPrint('⏳ Preloading ${imagePaths.length} images...');
      }

      final futures = imagePaths.map((path) async {
        try {
          await loadOptimizedImage(imagePath: path);
          if (kDebugMode) {
            debugPrint('✅ Preloaded: $path');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to preload: $path - $e');
          }
        }
      }).toList();

      await Future.wait(futures);

      if (kDebugMode) {
        debugPrint('🚀 Image preloading completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Image preloading failed: $e');
      }
    }
  }

  /// Optimize image size for network transmission
  Future<Uint8List> optimizeImageForNetwork({
    required Uint8List imageData,
    int maxWidth = 800,
    int maxHeight = 600,
    int quality = 85,
    bool enableWebP = true,
  }) async {
    try {
      // Validate input parameters
      if (imageData.isEmpty) return imageData;
      if (maxWidth <= 0 || maxHeight <= 0) return imageData;
      if (quality < 0 || quality > 100) quality = 85;

      // Decode image
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      // Ensure valid dimensions
      if (image.width <= 0 || image.height <= 0) return imageData;

      // Calculate new dimensions
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth || image.height > maxHeight) {
        final aspectRatio = image.width / image.height;

        if (aspectRatio > 0) {
          if (image.width > image.height) {
            newWidth = maxWidth;
            newHeight = (maxWidth / aspectRatio).round();
          } else {
            newHeight = maxHeight;
            newWidth = (maxHeight * aspectRatio).round();
          }
        } else {
          newWidth = maxWidth;
          newHeight = maxHeight;
        }
      }

      // Ensure positive dimensions
      newWidth = newWidth.clamp(1, maxWidth);
      newHeight = newHeight.clamp(1, maxHeight);

      // Resize image
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Encode with optimal format
      Uint8List optimizedData;
      if (enableWebP && _cdnConfig.enableWebP) {
        optimizedData = Uint8List.fromList(img.encodePng(resized));
      } else {
        optimizedData =
            Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      }

      if (kDebugMode) {
        final originalSize = imageData.length;
        final newSize = optimizedData.length;
        final compressionRatio = originalSize > 0
            ? ((originalSize - newSize) / originalSize * 100).toStringAsFixed(1)
            : '0.0';
        debugPrint(
            '🗜️ Image optimized: $originalSize -> $newSize bytes ($compressionRatio% smaller)');
      }

      return optimizedData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Image optimization failed: $e');
      }
      return imageData;
    }
  }

  /// Upload image to Firebase Storage with optimization
  Future<String> uploadOptimizedImage({
    required Uint8List imageData,
    required String path,
    int maxWidth = 800,
    int maxHeight = 600,
    int quality = 85,
    bool enableWebP = true,
  }) async {
    try {
      // Optimize image first
      final optimizedData = await optimizeImageForNetwork(
        imageData: imageData,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
        enableWebP: enableWebP,
      );

      // Determine content type based on optimization
      final contentType =
          enableWebP && _cdnConfig.enableWebP ? 'image/webp' : 'image/jpeg';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        optimizedData,
        SettableMetadata(
          contentType: contentType,
          cacheControl: 'public, max-age=${_cdnConfig.maxCacheAge}',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        debugPrint('📤 Uploaded optimized image to: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to upload optimized image: $e');
      }
      rethrow;
    }
  }

  /// Get avatar with multiple fallback options
  Widget getOptimizedAvatar({
    required String imagePath,
    double size = 50.0,
    String? fallback1,
    String? fallback2,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: getOptimizedImageUrl(imagePath: imagePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _defaultAvatarPlaceholder,
          errorWidget: (context, url, error) {
            if (fallback1 != null) {
              return CachedNetworkImage(
                imageUrl: getOptimizedImageUrl(imagePath: fallback1),
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _defaultAvatarPlaceholder,
                errorWidget: (context, url, error) {
                  return fallback2 != null
                      ? CachedNetworkImage(
                          imageUrl: getOptimizedImageUrl(imagePath: fallback2),
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _defaultAvatarPlaceholder,
                          errorWidget: (context, url, error) =>
                              _defaultAvatarWidget,
                        )
                      : _defaultAvatarWidget;
                },
              );
            }
            return _defaultAvatarWidget;
          },
        ),
      ),
    );
  }

  /// Load image with timeout and error handling
  Future<Image> _loadImageWithTimeout(String url) async {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ Image load error: $error');
        }
        throw error;
      },
    );
  }

  /// Cache asset with size management
  void _cacheAsset(String key, Image image) {
    try {
      final imageBytes = _calculateImageSize(image);
      final entry = CacheEntry(
        data: image,
        expiresAt: DateTime.now().add(_assetCacheTTL),
        size: imageBytes,
      );

      // Remove existing entry if present
      final existing = _assetCache[key];
      if (existing != null) {
        _currentCacheSize -= existing.size;
      }

      // Add new entry
      _assetCache[key] = entry;
      _currentCacheSize += imageBytes;
      _totalBytesCached += imageBytes;

      // Evict oldest entries if cache is full
      _evictCacheIfNeeded();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cache asset: $e');
      }
    }
  }

  /// Calculate approximate size of image
  int _calculateImageSize(Image image) {
    try {
      // This is a rough estimate based on image dimensions
      // In a real implementation, you might want to calculate actual memory usage
      final imageInfo = image.toString();

      // Try to extract dimensions from the image string representation
      // This is a heuristic approach
      int estimatedSize = 100 * 1024; // Base 100KB estimate

      // If we can parse image info, adjust the estimate
      // This is a simplified approach - in production you might want
      // to use more sophisticated memory tracking
      return estimatedSize;
    } catch (e) {
      return 50 * 1024; // 50KB default
    }
  }

  /// Evict cache entries if over limits
  void _evictCacheIfNeeded() {
    // Remove expired entries first
    final expiredKeys = _assetCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      final entry = _assetCache[key]!;
      _currentCacheSize -= entry.size;
      _assetCache.remove(key);
    }

    // If still over size limit, remove oldest entries
    if (_currentCacheSize > _maxCacheSizeBytes ||
        _assetCache.length > _maxCacheEntries) {
      final sortedEntries = _assetCache.entries.toList()
        ..sort((a, b) => a.value.expiresAt.compareTo(b.value.expiresAt));

      while ((_currentCacheSize > _maxCacheSizeBytes ||
              _assetCache.length > _maxCacheEntries) &&
          sortedEntries.isNotEmpty) {
        final entry = sortedEntries.removeAt(0);
        _currentCacheSize -= entry.value.size;
        _assetCache.remove(entry.key);
      }
    }
  }

  /// Update performance metrics
  void _updateMetrics(Duration loadTime) {
    final loadTimeMs = loadTime.inMilliseconds;
    _totalLoadTimeMs += loadTimeMs;

    // Track slow loads
    if (loadTimeMs > 1000) {
      final slowLoadInfo = 'Load took ${loadTimeMs}ms';
      _slowLoads.add(slowLoadInfo);

      // Keep only the latest slow loads
      if (_slowLoads.length > _maxSlowLoads) {
        _slowLoads.removeAt(0);
      }

      if (kDebugMode) {
        debugPrint('🐌 Slow asset load detected: ${loadTimeMs}ms');
      }
    }
  }

  /// Detect WebP support for web
  bool _detectWebPSupport() {
    try {
      // Check browser support for WebP
      // Most modern browsers support WebP, but we can add more sophisticated detection
      if (kIsWeb) {
        // In a real implementation, you might use window.document or other web APIs
        // For now, return true as most modern browsers support it
        return true;
      }
      // On mobile platforms, WebP is generally supported
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get performance metrics
  AssetMetrics? get metrics {
    if (_totalAssetsLoaded == 0) return null;

    return AssetMetrics(
      totalAssetsLoaded: _totalAssetsLoaded,
      cacheHits: _cacheHits,
      cacheMisses: _cacheMisses,
      averageLoadTimeMs: _totalAssetsLoaded > 0
          ? (_totalLoadTimeMs / _totalAssetsLoaded).round()
          : 0,
      totalBytesCached: _totalBytesCached,
      slowLoads: List.from(_slowLoads),
    );
  }

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];

    if (metrics == null) return recommendations;

    final assetMetrics = metrics!;

    if (assetMetrics.cacheHitRate < 70) {
      recommendations.add(
          '🧠 Low cache hit rate - consider increasing cache TTL or preloading');
      recommendations.add(
          '📈 Implement better caching strategies for frequently accessed assets');
    }

    if (assetMetrics.slowLoads.isNotEmpty) {
      recommendations.add(
          '🐌 Slow asset loads detected - check network conditions or CDN configuration');
      recommendations.add(
          '🌐 Consider using a closer CDN region or optimizing image compression');
    }

    if (_currentCacheSize > _maxCacheSizeBytes * 0.8) {
      recommendations.add(
          '💾 Cache approaching size limit - consider reducing cache size or TTL');
    }

    recommendations
        .add('🖼️ Consider using WebP format for better compression');
    recommendations
        .add('📱 Implement responsive images for different screen densities');

    return recommendations;
  }

  /// Clear all metrics and cache
  void clearMetrics() {
    _lastMetrics = null;
    _totalAssetsLoaded = 0;
    _cacheHits = 0;
    _cacheMisses = 0;
    _totalLoadTimeMs = 0;
    _totalBytesCached = 0;
    _slowLoads.clear();
    _assetCache.clear();
    _currentCacheSize = 0;
  }

  // Default widgets
  Widget get _defaultPlaceholder => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );

  Widget get _defaultErrorWidget => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.error, color: Colors.grey),
        ),
      );

  Widget get _defaultAvatarPlaceholder => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.person, color: Colors.grey),
        ),
      );

  Widget get _defaultAvatarWidget => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.person, color: Colors.grey),
        ),
      );
}

/// Cache entry for assets
class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;
  final int size;

  CacheEntry({
    required this.data,
    required this.expiresAt,
    required this.size,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
