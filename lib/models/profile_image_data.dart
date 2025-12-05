// lib/models/profile_image_data.dart

/// Profile image upload status enum
enum ImageUploadStatus {
  idle,
  selecting,
  uploading,
  optimizing,
  processing,
  completed,
  error,
  cancelled
}

/// Supported image formats with compatibility levels
enum ImageFormat {
  jpeg(quality: 0.85, maxSize: 10 * 1024 * 1024), // 10MB
  png(quality: 0.9, maxSize: 10 * 1024 * 1024),   // 10MB
  webp(quality: 0.8, maxSize: 10 * 1024 * 1024),  // 10MB
  gif(quality: 0.9, maxSize: 5 * 1024 * 1024),    // 5MB
  bmp(quality: 0.9, maxSize: 15 * 1024 * 1024),   // 15MB
  heic(quality: 0.85, maxSize: 20 * 1024 * 1024), // 20MB (iOS optimized)
  heif(quality: 0.85, maxSize: 20 * 1024 * 1024); // 20MB

  const ImageFormat({
    required this.quality,
    required this.maxSize,
  });

  final double quality;
  final int maxSize;

  String get mimeType {
    switch (this) {
      case ImageFormat.jpeg:
        return 'image/jpeg';
      case ImageFormat.png:
        return 'image/png';
      case ImageFormat.webp:
        return 'image/webp';
      case ImageFormat.gif:
        return 'image/gif';
      case ImageFormat.bmp:
        return 'image/bmp';
      case ImageFormat.heic:
        return 'image/heic';
      case ImageFormat.heif:
        return 'image/heif';
    }
  }

  bool get isAnimated => this == ImageFormat.gif;
  bool get supportsTransparency => this == ImageFormat.png || this == ImageFormat.webp;
  bool get isLossy => this == ImageFormat.jpeg || this == ImageFormat.webp;
  bool get isLossless => this == ImageFormat.png;
  bool get isModernFormat => this == ImageFormat.webp || this == ImageFormat.heic || this == ImageFormat.heif;
}

/// Image optimization parameters
class ImageOptimizationParams {
  final int maxWidth;
  final int maxHeight;
  final int quality; // 1-100
  final bool enableWebP;
  final bool preserveMetadata;
  final bool enableProgressive;
  final double compressionRatio;
  final String? watermarkText;
  final bool generateThumbnail;
  final int thumbnailSize;

  const ImageOptimizationParams({
    this.maxWidth = 1080,
    this.maxHeight = 1080,
    this.quality = 85,
    this.enableWebP = true,
    this.preserveMetadata = false,
    this.enableProgressive = true,
    this.compressionRatio = 0.8,
    this.watermarkText,
    this.generateThumbnail = true,
    this.thumbnailSize = 150,
  });

  ImageOptimizationParams copyWith({
    int? maxWidth,
    int? maxHeight,
    int? quality,
    bool? enableWebP,
    bool? preserveMetadata,
    bool? enableProgressive,
    double? compressionRatio,
    String? watermarkText,
    bool? generateThumbnail,
    int? thumbnailSize,
  }) {
    return ImageOptimizationParams(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      quality: quality ?? this.quality,
      enableWebP: enableWebP ?? this.enableWebP,
      preserveMetadata: preserveMetadata ?? this.preserveMetadata,
      enableProgressive: enableProgressive ?? this.enableProgressive,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      watermarkText: watermarkText ?? this.watermarkText,
      generateThumbnail: generateThumbnail ?? this.generateThumbnail,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'maxWidth': maxWidth,
    'maxHeight': maxHeight,
    'quality': quality,
    'enableWebP': enableWebP,
    'preserveMetadata': preserveMetadata,
    'enableProgressive': enableProgressive,
    'compressionRatio': compressionRatio,
    'watermarkText': watermarkText,
    'generateThumbnail': generateThumbnail,
    'thumbnailSize': thumbnailSize,
  };

  factory ImageOptimizationParams.fromJson(Map<String, dynamic> json) {
    return ImageOptimizationParams(
      maxWidth: json['maxWidth'] ?? 1080,
      maxHeight: json['maxHeight'] ?? 1080,
      quality: json['quality'] ?? 85,
      enableWebP: json['enableWebP'] ?? true,
      preserveMetadata: json['preserveMetadata'] ?? false,
      enableProgressive: json['enableProgressive'] ?? true,
      compressionRatio: json['compressionRatio'] ?? 0.8,
      watermarkText: json['watermarkText'],
      generateThumbnail: json['generateThumbnail'] ?? true,
      thumbnailSize: json['thumbnailSize'] ?? 150,
    );
  }
}

/// Profile image crop configuration
class ImageCropConfig {
  final double x;
  final double y;
  final double width;
  final double height;
  final double aspectRatio; // width/height

  const ImageCropConfig({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.aspectRatio = 1.0,
  });

  ImageCropConfig copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? aspectRatio,
  }) {
    return ImageCropConfig(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  bool get isValid {
    return x >= 0 && y >= 0 && width > 0 && height > 0;
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'aspectRatio': aspectRatio,
  };

  factory ImageCropConfig.fromJson(Map<String, dynamic> json) {
    return ImageCropConfig(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Upload progress tracking
class UploadProgress {
  final int bytesUploaded;
  final int totalBytes;
  final ImageUploadStatus status;
  final String? errorMessage;
  final double progress; // 0.0 - 1.0
  final DateTime startTime;
  final DateTime? endTime;
  final int? estimatedTimeRemaining; // seconds

  const UploadProgress({
    required this.bytesUploaded,
    required this.totalBytes,
    required this.status,
    this.errorMessage,
    required this.progress,
    required this.startTime,
    this.endTime,
    this.estimatedTimeRemaining,
  });

  double get percentage => (progress * 100).clamp(0, 100);
  bool get isComplete => status == ImageUploadStatus.completed;
  bool get hasError => status == ImageUploadStatus.error;
  bool get isUploading => status == ImageUploadStatus.uploading;

  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  UploadProgress copyWith({
    int? bytesUploaded,
    int? totalBytes,
    ImageUploadStatus? status,
    String? errorMessage,
    double? progress,
    DateTime? endTime,
    int? estimatedTimeRemaining,
  }) {
    return UploadProgress(
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
    );
  }
}

/// Profile image data model
class ProfileImageData {
  final String id;
  final String userId;
  final String originalUrl;
  final String? optimizedUrl;
  final String? thumbnailUrl;
  final String? backupUrl;
  final ImageFormat originalFormat;
  final ImageFormat? optimizedFormat;
  final int originalSize; // bytes
  final int? optimizedSize; // bytes
  final ImageOptimizationParams optimizationParams;
  final ImageCropConfig? cropConfig;
  final UploadProgress uploadProgress;
  final DateTime uploadedAt;
  final DateTime? processedAt;
  final Map<String, dynamic>? metadata;
  final bool isActive;

  const ProfileImageData({
    required this.id,
    required this.userId,
    required this.originalUrl,
    this.optimizedUrl,
    this.thumbnailUrl,
    this.backupUrl,
    required this.originalFormat,
    this.optimizedFormat,
    required this.originalSize,
    this.optimizedSize,
    required this.optimizationParams,
    this.cropConfig,
    required this.uploadProgress,
    required this.uploadedAt,
    this.processedAt,
    this.metadata,
    this.isActive = true,
  });

  ProfileImageData copyWith({
    String? id,
    String? userId,
    String? originalUrl,
    String? optimizedUrl,
    String? thumbnailUrl,
    String? backupUrl,
    ImageFormat? originalFormat,
    ImageFormat? optimizedFormat,
    int? originalSize,
    int? optimizedSize,
    ImageOptimizationParams? optimizationParams,
    ImageCropConfig? cropConfig,
    UploadProgress? uploadProgress,
    DateTime? uploadedAt,
    DateTime? processedAt,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return ProfileImageData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalUrl: originalUrl ?? this.originalUrl,
      optimizedUrl: optimizedUrl ?? this.optimizedUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      backupUrl: backupUrl ?? this.backupUrl,
      originalFormat: originalFormat ?? this.originalFormat,
      optimizedFormat: optimizedFormat ?? this.optimizedFormat,
      originalSize: originalSize ?? this.originalSize,
      optimizedSize: optimizedSize ?? this.optimizedSize,
      optimizationParams: optimizationParams ?? this.optimizationParams,
      cropConfig: cropConfig ?? this.cropConfig,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      processedAt: processedAt ?? this.processedAt,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isOptimized => optimizedUrl != null && optimizedFormat != null;
  bool get hasThumbnail => thumbnailUrl != null;
  bool get hasBackup => backupUrl != null;
  bool get isProcessing => uploadProgress.status == ImageUploadStatus.optimizing || 
                             uploadProgress.status == ImageUploadStatus.processing;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'originalUrl': originalUrl,
    'optimizedUrl': optimizedUrl,
    'thumbnailUrl': thumbnailUrl,
    'backupUrl': backupUrl,
    'originalFormat': originalFormat.name,
    'optimizedFormat': optimizedFormat?.name,
    'originalSize': originalSize,
    'optimizedSize': optimizedSize,
    'optimizationParams': optimizationParams.toJson(),
    'cropConfig': cropConfig?.toJson(),
    'uploadProgress': {
      'bytesUploaded': uploadProgress.bytesUploaded,
      'totalBytes': uploadProgress.totalBytes,
      'status': uploadProgress.status.name,
      'errorMessage': uploadProgress.errorMessage,
      'progress': uploadProgress.progress,
      'startTime': uploadProgress.startTime.toIso8601String(),
      'endTime': uploadProgress.endTime?.toIso8601String(),
      'estimatedTimeRemaining': uploadProgress.estimatedTimeRemaining,
    },
    'uploadedAt': uploadedAt.toIso8601String(),
    'processedAt': processedAt?.toIso8601String(),
    'metadata': metadata,
    'isActive': isActive,
  };

  factory ProfileImageData.fromJson(Map<String, dynamic> json) {
    return ProfileImageData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      originalUrl: json['originalUrl'] ?? '',
      optimizedUrl: json['optimizedUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      backupUrl: json['backupUrl'],
      originalFormat: ImageFormat.values.firstWhere(
        (format) => format.name == json['originalFormat'],
        orElse: () => ImageFormat.jpeg,
      ),
      optimizedFormat: json['optimizedFormat'] != null 
        ? ImageFormat.values.firstWhere(
            (format) => format.name == json['optimizedFormat'],
            orElse: () => ImageFormat.jpeg,
          )
        : null,
      originalSize: json['originalSize'] ?? 0,
      optimizedSize: json['optimizedSize'],
      optimizationParams: ImageOptimizationParams.fromJson(json['optimizationParams'] ?? {}),
      cropConfig: json['cropConfig'] != null 
        ? ImageCropConfig.fromJson(json['cropConfig'])
        : null,
      uploadProgress: UploadProgress(
        bytesUploaded: json['uploadProgress']['bytesUploaded'] ?? 0,
        totalBytes: json['uploadProgress']['totalBytes'] ?? 0,
        status: ImageUploadStatus.values.firstWhere(
          (status) => status.name == json['uploadProgress']['status'],
          orElse: () => ImageUploadStatus.idle,
        ),
        errorMessage: json['uploadProgress']['errorMessage'],
        progress: (json['uploadProgress']['progress'] as num?)?.toDouble() ?? 0.0,
        startTime: DateTime.parse(json['uploadProgress']['startTime']),
        endTime: json['uploadProgress']['endTime'] != null 
          ? DateTime.parse(json['uploadProgress']['endTime'])
          : null,
        estimatedTimeRemaining: json['uploadProgress']['estimatedTimeRemaining'],
      ),
      uploadedAt: DateTime.parse(json['uploadedAt']),
      processedAt: json['processedAt'] != null 
        ? DateTime.parse(json['processedAt'])
        : null,
      metadata: json['metadata'],
      isActive: json['isActive'] ?? true,
    );
  }
}