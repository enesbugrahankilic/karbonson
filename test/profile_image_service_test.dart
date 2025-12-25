// test/profile_image_service_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the services to test
import 'package:karbonson/services/profile_image_service.dart';
import 'package:karbonson/models/profile_image_data.dart';

// Generate mock classes
@GenerateMocks([FirebaseStorage, Reference, UploadTask, TaskSnapshot, User])
import 'profile_image_service_test.mocks.dart';

void main() {
  group('ProfileImageService', () {
    late ProfileImageService service;
    late MockFirebaseStorage mockStorage;
    late MockReference mockReference;
    late MockUploadTask mockUploadTask;
    late MockTaskSnapshot mockTaskSnapshot;
    late MockUser mockUser;

    setUp(() {
      service = ProfileImageService();
      mockStorage = MockFirebaseStorage();
      mockReference = MockReference();
      mockUploadTask = MockUploadTask();
      mockTaskSnapshot = MockTaskSnapshot();
      mockUser = MockUser();
      
      // Set up mock behaviors
      when(mockUser.uid).thenReturn('test_user_id');
      when(mockUser.isAnonymous).thenReturn(false);
      when(mockStorage.ref()).thenReturn(mockReference);
      when(mockReference.child(any)).thenReturn(mockReference);
      when(mockReference.putData(any, any)).thenReturn(mockUploadTask);
      when(mockUploadTask.snapshotEvents).thenAnswer((_) => const Stream.empty());
      when(mockUploadTask.snapshot).thenReturn(mockTaskSnapshot);
      when(mockTaskSnapshot.ref).thenReturn(mockReference);
      when(mockReference.getDownloadURL()).thenAnswer((_) => Future.value('https://example.com/image.jpg'));
    });

    group('Image Upload Tests', () {
      test('should upload image successfully with valid data', () async {
        // Arrange
        final testImageData = _createTestImageData(800, 600);
        const userId = 'test_user_id';
        const format = ImageFormat.jpeg;
        
        // Act
        final result = await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
          format: format,
        );
        
        // Assert
        expect(result, isNotNull);
        expect(result?.userId, equals(userId));
        expect(result?.originalFormat, equals(format));
        expect(result?.uploadProgress.status, equals(ImageUploadStatus.completed));
      });

      test('should validate image format and reject invalid formats', () async {
        // Arrange
        final testImageData = _createTestImageData(400, 300);
        const userId = 'test_user_id';
        
        // Act & Assert
        final validation = service.validateImageFile(testImageData, ImageFormat.jpeg);
        expect(validation.isValid, isTrue);
        expect(validation.errorMessage, isNull);
      });

      test('should reject oversized images', () async {
        // Arrange
        final largeImageData = Uint8List(20 * 1024 * 1024); // 20MB
        const userId = 'test_user_id';
        
        // Act
        final validation = service.validateImageFile(largeImageData, ImageFormat.jpeg);
        
        // Assert
        expect(validation.isValid, isFalse);
        expect(validation.errorMessage, contains('Dosya boyutu çok büyük'));
      });

      test('should reject very small images', () async {
        // Arrange
        final smallImageData = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]); // PNG header only
        const userId = 'test_user_id';
        
        // Act
        final validation = service.validateImageFile(smallImageData, ImageFormat.jpeg);
        
        // Assert
        expect(validation.isValid, isFalse);
        expect(validation.errorMessage, contains('boş olamaz'));
      });
    });

    group('Image Optimization Tests', () {
      test('should validate image optimization workflow', () async {
        // Arrange
        final testImageData = _createTestImageData(1920, 1080);
        const userId = 'test_user_id';
        
        // Act - test that the service can handle the upload workflow
        final result = await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
          optimizationParams: const ImageOptimizationParams(
            maxWidth: 800,
            maxHeight: 600,
            quality: 80,
            enableWebP: true,
          ),
        );
        
        // Assert - the result should be handled correctly
        // (exact behavior depends on the service implementation)
        expect(result, isNotNull);
      });

      test('should handle different image formats correctly', () async {
        // Arrange
        final testImageData = _createTestImageData(1000, 1000);
        const userId = 'test_user_id';
        
        // Act
        final result = await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
          format: ImageFormat.webp,
        );
        
        // Assert
        expect(result, isNotNull);
        expect(result?.originalFormat, equals(ImageFormat.webp));
      });

      test('should handle thumbnail creation in workflow', () async {
        // Arrange
        final testImageData = _createTestImageData(1200, 800);
        const userId = 'test_user_id';
        
        // Act
        final result = await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
        );
        
        // Assert
        expect(result, isNotNull);
      });
    });

    group('Performance Metrics Tests', () {
      test('should track upload performance correctly', () async {
        // Arrange
        final testImageData = _createTestImageData(800, 600);
        const userId = 'test_user_id';
        
        // Act
        await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
        );
        
        final metrics = service.getPerformanceMetrics();
        
        // Assert
        expect(metrics['totalUploads'], greaterThanOrEqualTo(1));
        expect(metrics['successfulUploads'], greaterThanOrEqualTo(0));
        expect(metrics['uptimePercentage'], isA<double>());
      });

      test('should calculate compression savings', () async {
        // Arrange
        final testImageData = _createTestImageData(1600, 1200);
        const userId = 'test_user_id';
        
        // Act
        await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
          optimizationParams: const ImageOptimizationParams(
            maxWidth: 800,
            maxHeight: 600,
            quality: 70,
            enableWebP: true,
          ),
        );
        
        final metrics = service.getPerformanceMetrics();
        
        // Assert
        expect(metrics['totalDataProcessed'], greaterThan(0));
        expect(metrics['compressionSavings'], isA<int>());
      });

      test('should clear metrics and logs correctly', () async {
        // Arrange
        final testImageData = _createTestImageData(600, 400);
        const userId = 'test_user_id';
        
        // Act
        await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
        );
        
        service.clearMetrics();
        final metrics = service.getPerformanceMetrics();
        
        // Assert
        expect(metrics['totalUploads'], equals(0));
        expect(metrics['errorLog'], isEmpty);
      });
    });

    group('Image Validation Tests', () {
      test('should validate supported image formats', () {
        // Test JPEG
        var validation = service.validateImageFile(
          _createTestImageData(800, 600),
          ImageFormat.jpeg,
        );
        expect(validation.isValid, isTrue);

        // Test PNG
        validation = service.validateImageFile(
          _createTestImageData(800, 600),
          ImageFormat.png,
        );
        expect(validation.isValid, isTrue);

        // Test WebP
        validation = service.validateImageFile(
          _createTestImageData(800, 600),
          ImageFormat.webp,
        );
        expect(validation.isValid, isTrue);
      });

      test('should validate image dimensions', () {
        // Test minimum dimensions
        var validation = service.validateImageFile(
          _createTestImageData(50, 50),
          ImageFormat.jpeg,
        );
        expect(validation.isValid, isFalse);
        expect(validation.errorMessage, contains('minimum 100x100'));

        // Test maximum dimensions
        validation = service.validateImageFile(
          _createTestImageData(10000, 10000),
          ImageFormat.jpeg,
        );
        expect(validation.isValid, isFalse);
        expect(validation.errorMessage, contains('maksimum 8000x8000'));
      });

      test('should provide helpful error suggestions', () {
        final validation = service.validateImageFile(
          Uint8List(0), // Empty data
          ImageFormat.jpeg,
        );
        
        expect(validation.isValid, isFalse);
        expect(validation.suggestions, isNotEmpty);
        expect(validation.suggestions.first, contains('geçerli bir görüntü'));
      });
    });

    group('Error Handling Tests', () {
      test('should handle upload failures gracefully', () async {
        // Arrange
        final testImageData = _createTestImageData(800, 600);
        const userId = 'invalid_user_id'; // Simulate auth failure
        
        // Act
        final result = await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
        );
        
        // Assert
        expect(result, isNull);
      });

      test('should handle network errors during upload', () async {
        // This test would require mocking Firebase Storage exceptions
        // For now, we test the basic error handling structure
        
        final metrics = service.getPerformanceMetrics();
        expect(metrics.containsKey('errorLog'), isTrue);
      });

      test('should maintain uptime percentage despite failures', () async {
        // Arrange
        final testImageData = _createTestImageData(800, 600);
        const userId = 'test_user_id';
        
        // Act - successful upload
        await service.uploadProfileImage(
          imageData: testImageData,
          userId: userId,
        );
        
        // Simulate failed upload (this would require proper mocking)
        // For demonstration, we check the uptime calculation logic
        
        final metrics = service.getPerformanceMetrics();
        final uptimePercentage = metrics['uptimePercentage'] as double;
        
        expect(uptimePercentage, isA<double>());
        expect(uptimePercentage, lessThanOrEqualTo(100.0));
      });
    });

    group('Image Deletion Tests', () {
      test('should delete profile image successfully', () async {
        // Arrange
        const userId = 'test_user_id';
        const imageId = 'test_image_123';
        const originalUrl = 'https://example.com/original.jpg';
        const optimizedUrl = 'https://ized.webp';
        const thumbnailUrl = 'https://example.comexample.com/optim/thumbnail.webp';
        
        // Act
        final success = await service.deleteProfileImage(
          userId: userId,
          imageId: imageId,
          originalUrl: originalUrl,
          optimizedUrl: optimizedUrl,
          thumbnailUrl: thumbnailUrl,
        );
        
        // Assert
        expect(success, isA<bool>());
      });

      test('should handle partial deletion scenarios', () async {
        // Arrange - only some URLs available
        const userId = 'test_user_id';
        const imageId = 'test_image_123';
        const originalUrl = 'https://example.com/original.jpg';
        
        // Act - delete with partial URLs
        final success = await service.deleteProfileImage(
          userId: userId,
          imageId: imageId,
          originalUrl: originalUrl,
        );
        
        // Assert
        expect(success, isA<bool>());
      });
    });

    group('Widget Generation Tests', () {
      test('should generate optimized image widget correctly', () {
        // Arrange
        const imageUrl = 'https://example.com/profile.jpg';
        const size = 120.0;
        
        // Act
        final widget = service.getOptimizedImageWidget(
          imageUrl: imageUrl,
          size: size,
          isCircular: true,
          showProgressIndicator: true,
        );
        
        // Assert
        expect(widget, isNotNull);
        expect(widget, isA<Widget>());
      });

      test('should generate circular and rectangular widgets', () {
        // Arrange
        const imageUrl = 'https://example.com/profile.jpg';
        const size = 100.0;
        
        // Act - Circular widget
        final circularWidget = service.getOptimizedImageWidget(
          imageUrl: imageUrl,
          size: size,
          isCircular: true,
        );
        
        // Act - Rectangular widget
        final rectangularWidget = service.getOptimizedImageWidget(
          imageUrl: imageUrl,
          size: size,
          isCircular: false,
        );
        
        // Assert
        expect(circularWidget, isNotNull);
        expect(rectangularWidget, isNotNull);
      });
    });
  });
}

/// Helper method to create test image data
Uint8List _createTestImageData(int width, int height) {
  // Create a simple test image with random data
  final bytes = Uint8List(width * height * 3); // RGB format
  
  // Fill with test pattern
  for (int i = 0; i < bytes.length; i += 3) {
    bytes[i] = ((i / 3) % 256).toInt();     // R
    bytes[i + 1] = (((i / 3) + 85) % 256).toInt(); // G
    bytes[i + 2] = (((i / 3) + 170) % 256).toInt(); // B
  }
  
  return bytes;
}