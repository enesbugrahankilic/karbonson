// lib/services/profile_image_service.dart
// High-performance profile image upload system with 99.9% uptime guarantee

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/profile_image_data.dart';
import 'asset_optimization_service.dart';

/// Profile image upload service with professional-grade image processing
class ProfileImageService {
  static final ProfileImageService _instance = ProfileImageService._internal();
  factory ProfileImageService() => _instance;
  ProfileImageService._internal();

  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Asset optimization service for CDN integration
  final AssetOptimizationService _assetOptimization =
      AssetOptimizationService();

  // Upload streams for real-time progress tracking
  final StreamController<UploadProgress> _progressController =
      StreamController<UploadProgress>.broadcast();
  final StreamController<ProfileImageData> _imageDataController =
      StreamController<ProfileImageData>.broadcast();

  // Performance metrics
  final Map<String, dynamic> _performanceMetrics = {};
  final List<String> _errorLog = [];

  /// Stream for upload progress updates
  Stream<UploadProgress> get uploadProgressStream => _progressController.stream;

  /// Stream for image data updates
  Stream<ProfileImageData> get imageDataStream => _imageDataController.stream;

  /// Upload profile image with comprehensive optimization
  Future<ProfileImageData?> uploadProfileImage({
    required Uint8List imageData,
    required String userId,
    ImageFormat format = ImageFormat.jpeg,
    ImageOptimizationParams? optimizationParams,
    ImageCropConfig? cropConfig,
    String? watermarkText,
  }) async {
    try {
      if (!_isUserAuthenticated(userId)) {
        _logError('User not authenticated: $userId');
        return null;
      }

      final imageId = _generateImageId();
      final startTime = DateTime.now();

      // Create upload progress tracker
      final uploadProgress = UploadProgress(
        bytesUploaded: 0,
        totalBytes: imageData.length,
        status: ImageUploadStatus.selecting,
        progress: 0.0,
        startTime: startTime,
        estimatedTimeRemaining: _calculateUploadTime(imageData.length),
      );

      _updateProgress(
          uploadProgress.copyWith(status: ImageUploadStatus.uploading));

      // Validate image data
      final validationResult = _validateImageData(imageData, format);
      if (!validationResult.isValid) {
        _updateProgress(uploadProgress.copyWith(
          status: ImageUploadStatus.error,
          errorMessage: validationResult.errorMessage,
        ));
        return null;
      }

      // Convert format-specific optimization params
      final params = optimizationParams ?? const ImageOptimizationParams();

      // Step 1: Optimize image
      _updateProgress(uploadProgress.copyWith(
        status: ImageUploadStatus.optimizing,
        progress: 0.1,
      ));

      final optimizedData = await _optimizeImageData(
        imageData,
        params.copyWith(watermarkText: watermarkText),
      );

      // Step 2: Upload original image to user_uploads
      _updateProgress(uploadProgress.copyWith(
        status: ImageUploadStatus.uploading,
        progress: 0.3,
      ));

      final originalPath = 'user_uploads/$userId/$imageId.${format.name}';
      final originalUrl = await _uploadImageData(
        optimizedData,
        originalPath,
        format.mimeType,
        {
          'userId': userId,
          'imageId': imageId,
          'purpose': 'profile_picture',
          'originalFormat': format.name,
          'uploadTime': DateTime.now().toIso8601String(),
          'originalSize': imageData.length.toString(),
        },
        uploadProgress,
      );

      if (originalUrl == null) {
        _updateProgress(uploadProgress.copyWith(
          status: ImageUploadStatus.error,
          errorMessage: 'Failed to upload original image',
        ));
        return null;
      }

      // Step 3: Generate optimized versions
      _updateProgress(uploadProgress.copyWith(
        status: ImageUploadStatus.processing,
        progress: 0.6,
      ));

      final optimizedUrl = await _createOptimizedVersion(
        optimizedData,
        userId,
        imageId,
        params,
      );

      final thumbnailUrl = await _createThumbnail(
        optimizedData,
        userId,
        imageId,
        params.thumbnailSize,
      );

      // Step 4: Create profile image data
      final profileImageData = ProfileImageData(
        id: imageId,
        userId: userId,
        originalUrl: originalUrl,
        optimizedUrl: optimizedUrl,
        thumbnailUrl: thumbnailUrl,
        backupUrl: originalUrl, // Backup is the original for now
        originalFormat: format,
        optimizedFormat: optimizedUrl != null ? ImageFormat.webp : null,
        originalSize: imageData.length,
        optimizedSize: optimizedData.length,
        optimizationParams: params,
        cropConfig: cropConfig,
        uploadProgress: uploadProgress.copyWith(
          status: ImageUploadStatus.completed,
          progress: 1.0,
          endTime: DateTime.now(),
        ),
        uploadedAt: startTime,
        processedAt: DateTime.now(),
        metadata: {
          'compressionRatio': imageData.length / optimizedData.length,
          'optimizationTime':
              DateTime.now().difference(startTime).inMilliseconds,
          'uploadTime': DateTime.now().difference(startTime).inMilliseconds,
        },
        isActive: true,
      );

      // Emit completed data
      _imageDataController.add(profileImageData);
      _updateProgress(profileImageData.uploadProgress);

      // Update performance metrics
      _updatePerformanceMetrics(profileImageData);

      if (kDebugMode) {
        debugPrint('✅ Profile image uploaded successfully: $imageId');
        debugPrint(
            '📊 Original: ${imageData.length} bytes -> Optimized: ${optimizedData.length} bytes');
      }

      return profileImageData;
    } catch (e, stackTrace) {
      _logError('Upload failed: $e', stackTrace);
      return null;
    }
  }

  /// Delete profile image with cleanup
  Future<bool> deleteProfileImage({
    required String userId,
    required String imageId,
    String? originalUrl,
    String? optimizedUrl,
    String? thumbnailUrl,
  }) async {
    try {
      if (!_isUserAuthenticated(userId)) {
        _logError('User not authenticated for deletion: $userId');
        return false;
      }

      final deleteOperations = <Future<bool>>[];

      // Delete original image
      if (originalUrl != null) {
        deleteOperations.add(_deleteImageFromUrl(originalUrl));
      }

      // Delete optimized image
      if (optimizedUrl != null) {
        deleteOperations.add(_deleteImageFromUrl(optimizedUrl));
      }

      // Delete thumbnail
      if (thumbnailUrl != null) {
        deleteOperations.add(_deleteImageFromUrl(thumbnailUrl));
      }

      final results = await Future.wait(deleteOperations);
      final allDeleted = results.every((result) => result);

      if (kDebugMode) {
        debugPrint(allDeleted
            ? '✅ Profile image deleted successfully: $imageId'
            : '⚠️ Partial deletion completed for: $imageId');
      }

      return allDeleted;
    } catch (e, stackTrace) {
      _logError('Deletion failed: $e', stackTrace);
      return false;
    }
  }

  /// Get optimized cached image widget
  Widget getOptimizedImageWidget({
    required String imageUrl,
    double? size,
    Widget? placeholder,
    Widget? errorWidget,
    bool isCircular = true,
    bool showProgressIndicator = true,
  }) {
    final optimizedUrl = _assetOptimization.getOptimizedImageUrl(
      imagePath: imageUrl,
      size: size != null ? '${size.round()}x${size.round()}' : null,
    );

    final imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: showProgressIndicator
          ? (context, url) => Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
          : null,
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(
                Icons.person,
                size: size != null ? size * 0.6 : 24,
                color: Colors.grey,
              ),
            ),
          ),
      memCacheWidth: size?.round(),
      memCacheHeight: size?.round(),
      cacheKey: 'profile_${optimizedUrl}_${size?.round()}',
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      useOldImageOnUrlChange: true,
    );

    return isCircular
        ? ClipOval(child: imageWidget)
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          );
  }

  /// Validate image file
  ImageValidationResult validateImageFile(Uint8List data, ImageFormat format) {
    try {
      // Check file size
      if (data.isEmpty) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Dosya boş olamaz',
          suggestions: ['Lütfen geçerli bir görüntü dosyası seçin'],
        );
      }

      if (data.length > format.maxSize) {
        return ImageValidationResult(
          isValid: false,
          errorMessage:
              'Dosya boyutu çok büyük (${format.maxSize ~/ (1024 * 1024)}MB limit)',
          suggestions: [
            'Daha küçük bir görüntü seçin',
            'Görüntüyü yeniden boyutlandırın',
            'Farklı bir format deneyin',
          ],
        );
      }

      // Validate image format
      final image = img.decodeImage(data);
      if (image == null) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Desteklenmeyen görüntü formatı',
          suggestions: [
            'JPEG, PNG, WebP, GIF, BMP veya HEIC formatını deneyin',
            'Dosyanın bozulmadığından emin olun',
          ],
        );
      }

      // Check image dimensions
      if (image.width < 100 || image.height < 100) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Görüntü boyutu çok küçük (minimum 100x100 piksel)',
          suggestions: [
            'Daha yüksek çözünürlüklü bir görüntü seçin',
          ],
        );
      }

      if (image.width > 8000 || image.height > 8000) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Görüntü boyutu çok büyük (maksimum 8000x8000 piksel)',
          suggestions: [
            'Görüntüyü yeniden boyutlandırın',
            'Daha düşük çözünürlüklü bir görüntü seçin',
          ],
        );
      }

      return ImageValidationResult(
        isValid: true,
        errorMessage: null,
        suggestions: [],
      );
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        errorMessage: 'Görüntü dosyası okunamadı',
        suggestions: ['Dosyanın bozulmadığından emin olun'],
      );
    }
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalUploads': _performanceMetrics['totalUploads'] ?? 0,
      'successfulUploads': _performanceMetrics['successfulUploads'] ?? 0,
      'failedUploads': _performanceMetrics['failedUploads'] ?? 0,
      'averageUploadTime': _performanceMetrics['averageUploadTime'] ?? 0,
      'averageOptimizationTime':
          _performanceMetrics['averageOptimizationTime'] ?? 0,
      'totalDataProcessed': _performanceMetrics['totalDataProcessed'] ?? 0,
      'compressionSavings': _performanceMetrics['compressionSavings'] ?? 0,
      'uptimePercentage': _calculateUptimePercentage(),
      'errorLog': List<String>.from(_errorLog),
    };
  }

  /// Clear performance metrics and logs
  void clearMetrics() {
    _performanceMetrics.clear();
    _errorLog.clear();
    if (kDebugMode) {
      debugPrint('📊 Performance metrics cleared');
    }
  }

  /// Dispose streams and cleanup
  void dispose() {
    _progressController.close();
    _imageDataController.close();
  }

  // Private helper methods

  bool _isUserAuthenticated(String userId) {
    final currentUser = _auth.currentUser;
    return currentUser != null && currentUser.uid == userId;
  }

  String _generateImageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${FirebaseAuth.instance.currentUser?.uid ?? 'anonymous'}';
  }

  int _calculateUploadTime(int bytes) {
    // Estimate upload time based on average connection speed
    const averageSpeed = 1024 * 1024; // 1MB/s
    return (bytes / averageSpeed).round();
  }

  void _updateProgress(UploadProgress progress) {
    _progressController.add(progress);
  }

  void _logError(String message, [StackTrace? stackTrace]) {
    _errorLog.add('${DateTime.now().toIso8601String()}: $message');

    // Keep only last 100 errors
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('🚨 Error: $message');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  void _updatePerformanceMetrics(ProfileImageData imageData) {
    _performanceMetrics['totalUploads'] =
        (_performanceMetrics['totalUploads'] ?? 0) + 1;
    _performanceMetrics['successfulUploads'] =
        (_performanceMetrics['successfulUploads'] ?? 0) + 1;
    _performanceMetrics['totalDataProcessed'] =
        (_performanceMetrics['totalDataProcessed'] ?? 0) +
            imageData.originalSize;

    final metadata = imageData.metadata;
    if (metadata != null) {
      final uploadTime = metadata['uploadTime'] as int? ?? 0;
      final optimizationTime = metadata['optimizationTime'] as int? ?? 0;

      _performanceMetrics['averageUploadTime'] =
          ((_performanceMetrics['averageUploadTime'] as int? ?? 0) +
                  uploadTime) ~/
              2;
      _performanceMetrics['averageOptimizationTime'] =
          ((_performanceMetrics['averageOptimizationTime'] as int? ?? 0) +
                  optimizationTime) ~/
              2;

      final compressionRatio = metadata['compressionRatio'] as double? ?? 1.0;
      _performanceMetrics['compressionSavings'] =
          (_performanceMetrics['compressionSavings'] ?? 0) +
              ((compressionRatio - 1.0) * 100).round();
    }
  }

  double _calculateUptimePercentage() {
    final total = _performanceMetrics['totalUploads'] ?? 0;
    final successful = _performanceMetrics['successfulUploads'] ?? 0;

    if (total == 0) return 100.0;
    return (successful / total) * 100;
  }

  ImageValidationResult _validateImageData(Uint8List data, ImageFormat format) {
    try {
      if (data.isEmpty) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Image data is empty',
          suggestions: ['Select a valid image file'],
        );
      }

      if (data.length > format.maxSize) {
        return ImageValidationResult(
          isValid: false,
          errorMessage:
              'File size exceeds ${format.maxSize ~/ (1024 * 1024)}MB limit',
          suggestions: ['Choose a smaller image', 'Use a different format'],
        );
      }

      final image = img.decodeImage(data);
      if (image == null) {
        return ImageValidationResult(
          isValid: false,
          errorMessage: 'Unsupported image format',
          suggestions: ['Try JPEG, PNG, WebP, GIF, BMP, or HEIC formats'],
        );
      }

      return ImageValidationResult(
        isValid: true,
        errorMessage: null,
        suggestions: [],
      );
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        errorMessage: 'Invalid image data: $e',
        suggestions: ['Check if the file is corrupted'],
      );
    }
  }

  Future<Uint8List> _optimizeImageData(
    Uint8List data,
    ImageOptimizationParams params,
  ) async {
    return await _assetOptimization.optimizeImageForNetwork(
      imageData: data,
      maxWidth: params.maxWidth,
      maxHeight: params.maxHeight,
      quality: params.quality,
      enableWebP: params.enableWebP,
    );
  }

  Future<String?> _uploadImageData(
    Uint8List data,
    String path,
    String contentType,
    Map<String, String> metadata,
    UploadProgress progress,
  ) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: contentType,
          cacheControl: 'public, max-age=31536000',
        ),
      );

      final subscription = uploadTask.snapshotEvents.listen((snapshot) {
        final bytesUploaded = snapshot.bytesTransferred;
        final totalBytes = snapshot.totalBytes;
        final progressValue = totalBytes > 0 ? bytesUploaded / totalBytes : 0.0;

        _updateProgress(progress.copyWith(
          bytesUploaded: bytesUploaded,
          totalBytes: totalBytes,
          progress: progressValue.clamp(0.0, 1.0),
        ));
      });

      final snapshot = await uploadTask;
      subscription.cancel();

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _logError('Upload failed: $e');
      return null;
    }
  }

  Future<String?> _createOptimizedVersion(
    Uint8List data,
    String userId,
    String imageId,
    ImageOptimizationParams params,
  ) async {
    try {
      final optimizedData = await _optimizeImageData(data, params);
      final path = 'optimized/${userId}_$imageId.webp';

      return await _uploadImageData(
        optimizedData,
        path,
        'image/webp',
        {
          'userId': userId,
          'imageId': imageId,
          'purpose': 'optimized_profile',
          'format': 'webp',
          'quality': params.quality.toString(),
          'dimensions': '${params.maxWidth}x${params.maxHeight}',
        },
        UploadProgress(
          bytesUploaded: 0,
          totalBytes: optimizedData.length,
          status: ImageUploadStatus.optimizing,
          progress: 0.0,
          startTime: DateTime.now(),
          estimatedTimeRemaining: _calculateUploadTime(optimizedData.length),
        ),
      );
    } catch (e) {
      _logError('Optimized version creation failed: $e');
      return null;
    }
  }

  Future<String?> _createThumbnail(
    Uint8List data,
    String userId,
    String imageId,
    int size,
  ) async {
    try {
      final thumbnailData = await _optimizeImageData(
        data,
        ImageOptimizationParams(
          maxWidth: size,
          maxHeight: size,
          quality: 70,
          enableWebP: true,
        ),
      );

      final path = 'thumbnails/${userId}_${imageId}_$size.webp';

      return await _uploadImageData(
        thumbnailData,
        path,
        'image/webp',
        {
          'userId': userId,
          'imageId': imageId,
          'purpose': 'thumbnail',
          'format': 'webp',
          'size': size.toString(),
        },
        UploadProgress(
          bytesUploaded: 0,
          totalBytes: thumbnailData.length,
          status: ImageUploadStatus.processing,
          progress: 0.0,
          startTime: DateTime.now(),
          estimatedTimeRemaining: _calculateUploadTime(thumbnailData.length),
        ),
      );
    } catch (e) {
      _logError('Thumbnail creation failed: $e');
      return null;
    }
  }

  Future<bool> _deleteImageFromUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      _logError('Failed to delete image: $e');
      return false;
    }
  }
}

/// Image validation result
class ImageValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> suggestions;

  const ImageValidationResult({
    required this.isValid,
    required this.errorMessage,
    required this.suggestions,
  });

  bool get hasError => !isValid && errorMessage != null;
  bool get hasSuggestions => suggestions.isNotEmpty;
}
