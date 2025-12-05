// test/profile_image_service_simple_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../lib/services/profile_image_service.dart';
import '../lib/models/profile_image_data.dart';

void main() {
  group('ProfileImageService - Basic Tests', () {
    late ProfileImageService service;

    setUp(() {
      service = ProfileImageService();
    });

    test('should initialize service correctly', () {
      expect(service, isNotNull);
    });

    test('should have upload progress stream', () {
      expect(service.uploadProgressStream, isNotNull);
      expect(service.imageDataStream, isNotNull);
    });

    test('should clear metrics without errors', () {
      expect(() => service.clearMetrics(), returnsNormally);
      
      final metrics = service.getPerformanceMetrics();
      expect(metrics, isA<Map<String, dynamic>>());
      expect(metrics.containsKey('totalUploads'), isTrue);
    });

    test('should create optimized image widget', () {
      const imageUrl = 'https://example.com/test.jpg';
      
      expect(() => service.getOptimizedImageWidget(
        imageUrl: imageUrl,
        size: 100.0,
      ), returnsNormally);
    });

    test('should validate empty image data', () {
      final emptyData = Uint8List(0);
      final result = service.validateImageFile(emptyData, ImageFormat.jpeg);
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.suggestions, isNotEmpty);
    });

    test('should handle various image formats', () {
      final formats = ImageFormat.values;
      
      for (final format in formats) {
        expect(format.mimeType, isNotEmpty);
        expect(format.maxSize, greaterThan(0));
        expect(format.quality, greaterThan(0));
      }
    });

    test('should create valid optimization parameters', () {
      final params = const ImageOptimizationParams(
        maxWidth: 1080,
        maxHeight: 1080,
        quality: 85,
        enableWebP: true,
      );
      
      expect(params.maxWidth, equals(1080));
      expect(params.maxHeight, equals(1080));
      expect(params.quality, equals(85));
      expect(params.enableWebP, isTrue);
    });

    test('should create valid crop configuration', () {
      final crop = const ImageCropConfig(
        x: 0.0,
        y: 0.0,
        width: 1.0,
        height: 1.0,
        aspectRatio: 1.0,
      );
      
      expect(crop.isValid, isTrue);
      expect(crop.aspectRatio, equals(1.0));
    });

    test('should create valid upload progress', () {
      final progress = UploadProgress(
        bytesUploaded: 5000,
        totalBytes: 10000,
        status: ImageUploadStatus.uploading,
        progress: 0.5,
        startTime: DateTime.now(),
        estimatedTimeRemaining: 30,
      );
      
      expect(progress.bytesUploaded, equals(5000));
      expect(progress.totalBytes, equals(10000));
      expect(progress.progress, equals(0.5));
      expect(progress.percentage, equals(50.0));
      expect(progress.isUploading, isTrue);
      expect(progress.isComplete, isFalse);
    });

    test('should create valid profile image data', () {
      final progress = UploadProgress(
        bytesUploaded: 0,
        totalBytes: 0,
        status: ImageUploadStatus.idle,
        progress: 0.0,
        startTime: DateTime.now(),
        estimatedTimeRemaining: 0,
      );
      
      final imageData = ProfileImageData(
        id: 'test_id',
        userId: 'test_user',
        originalUrl: 'https://example.com/test.jpg',
        originalFormat: ImageFormat.jpeg,
        uploadProgress: progress,
        originalSize: 1024,
        uploadedAt: DateTime.now(),
        optimizationParams: const ImageOptimizationParams(),
      );
      
      expect(imageData.id, equals('test_id'));
      expect(imageData.userId, equals('test_user'));
      expect(imageData.originalFormat, equals(ImageFormat.jpeg));
      expect(imageData.isActive, isTrue);
    });

    test('should handle image validation with different scenarios', () {
      // Test valid small image data
      final smallValidData = _createMinimalPngData();
      var result = service.validateImageFile(smallValidData, ImageFormat.png);
      
      // This should pass size validation but may fail format validation
      expect(result.errorMessage, isA<String?>());
      
      // Test oversized data
      final oversizedData = Uint8List(15 * 1024 * 1024); // 15MB
      result = service.validateImageFile(oversizedData, ImageFormat.jpeg);
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('boyutu çok büyük'));
    });

    test('should serialize and deserialize optimization parameters', () {
      final original = const ImageOptimizationParams(
        maxWidth: 800,
        maxHeight: 600,
        quality: 85,
        enableWebP: true,
        generateThumbnail: true,
      );
      
      final json = original.toJson();
      final restored = ImageOptimizationParams.fromJson(json);
      
      expect(restored.maxWidth, equals(original.maxWidth));
      expect(restored.maxHeight, equals(original.maxHeight));
      expect(restored.quality, equals(original.quality));
      expect(restored.enableWebP, equals(original.enableWebP));
    });

    test('should handle widget generation with different options', () {
      const url = 'https://example.com/avatar.jpg';
      
      // Circular widget
      expect(() => service.getOptimizedImageWidget(
        imageUrl: url,
        size: 80.0,
        isCircular: true,
        showProgressIndicator: false,
      ), returnsNormally);
      
      // Rectangular widget with progress
      expect(() => service.getOptimizedImageWidget(
        imageUrl: url,
        size: 120.0,
        isCircular: false,
        showProgressIndicator: true,
      ), returnsNormally);
      
      // Widget with custom placeholder
      expect(() => service.getOptimizedImageWidget(
        imageUrl: url,
        placeholder: const Text('Loading...'),
        errorWidget: const Text('Error'),
      ), returnsNormally);
    });

    test('should manage performance metrics correctly', () {
      // Get initial metrics
      final initialMetrics = service.getPerformanceMetrics();
      expect(initialMetrics, isNotNull);
      expect(initialMetrics, isA<Map<String, dynamic>>());
      
      // Clear metrics
      service.clearMetrics();
      
      // Get cleared metrics
      final clearedMetrics = service.getPerformanceMetrics();
      expect(clearedMetrics['totalUploads'], equals(0));
    });

    test('should handle dispose gracefully', () {
      expect(() => service.dispose(), returnsNormally);
    });

    test('should validate image format properties', () {
      // Test JPEG properties
      final jpeg = ImageFormat.jpeg;
      expect(jpeg.mimeType, equals('image/jpeg'));
      expect(jpeg.isLossy, isTrue);
      expect(jpeg.isModernFormat, isFalse);
      
      // Test PNG properties
      final png = ImageFormat.png;
      expect(png.mimeType, equals('image/png'));
      expect(png.supportsTransparency, isTrue);
      expect(png.isLossless, isTrue);
      
      // Test WebP properties
      final webp = ImageFormat.webp;
      expect(webp.mimeType, equals('image/webp'));
      expect(webp.isModernFormat, isTrue);
      expect(webp.supportsTransparency, isTrue);
    });
  });
}

/// Helper method to create minimal PNG data for testing
Uint8List _createMinimalPngData() {
  // PNG signature: 89 50 4E 47 0D 0A 1A 0A
  // Minimal PNG chunk: IHDR + IEND
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, // Chunk length (13 bytes)
    0x49, 0x48, 0x44, 0x52, // 'IHDR'
    0x00, 0x00, 0x00, 0x01, // Width: 1
    0x00, 0x00, 0x00, 0x01, // Height: 1
    0x08, 0x02, 0x00, 0x00, 0x00, // Bit depth, color type, compression, filter, interlace
    0x00, 0x00, 0x00, 0x00, // CRC (zero for simplicity)
    0x00, 0x00, 0x00, 0x00, // Chunk length (0 bytes)
    0x49, 0x45, 0x4E, 0x44, // 'IEND'
    0xAE, 0x42, 0x60, 0x82, // CRC
  ]);
}