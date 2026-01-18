// lib/provides/profile_image_bloc.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_image_data.dart';
import '../services/profile_image_service.dart';

// Events
abstract class ProfileImageEvent extends Equatable {
  const ProfileImageEvent();

  @override
  List<Object> get props => [];
}

class InitializeProfileImage extends ProfileImageEvent {
  final String userId;
  final String? existingImageUrl;

  const InitializeProfileImage({
    required this.userId,
    this.existingImageUrl,
  });

  @override
  List<Object> get props => [userId, existingImageUrl ?? ''];
}

class UploadProfileImage extends ProfileImageEvent {
  final Uint8List imageData;
  final String userId;
  final ImageFormat format;
  final ImageOptimizationParams? optimizationParams;
  final ImageCropConfig? cropConfig;
  final String? watermarkText;

  const UploadProfileImage({
    required this.imageData,
    required this.userId,
    this.format = ImageFormat.jpeg,
    this.optimizationParams,
    this.cropConfig,
    this.watermarkText,
  });

  @override
  List<Object> get props => [
        imageData,
        userId,
        format,
        optimizationParams?.toString() ?? '',
        cropConfig?.toString() ?? '',
        watermarkText ?? '',
      ];
}

class DeleteProfileImage extends ProfileImageEvent {
  final String userId;
  final String imageId;
  final String? originalUrl;
  final String? optimizedUrl;
  final String? thumbnailUrl;

  const DeleteProfileImage({
    required this.userId,
    required this.imageId,
    this.originalUrl,
    this.optimizedUrl,
    this.thumbnailUrl,
  });

  @override
  List<Object> get props => [
        userId,
        imageId,
        originalUrl ?? '',
        optimizedUrl ?? '',
        thumbnailUrl ?? '',
      ];
}

class UpdateOptimizationParams extends ProfileImageEvent {
  final ImageOptimizationParams newParams;

  const UpdateOptimizationParams(this.newParams);

  @override
  List<Object> get props => [newParams];
}

class RetryUpload extends ProfileImageEvent {
  final ProfileImageData? previousImageData;

  const RetryUpload([this.previousImageData]);

  @override
  List<Object> get props => [previousImageData?.toString() ?? ''];
}

class ClearError extends ProfileImageEvent {}

class LoadPerformanceMetrics extends ProfileImageEvent {}

class UploadProgressChanged extends ProfileImageEvent {
  final UploadProgress uploadProgress;
  final Map<String, dynamic>? optimizationParams;

  const UploadProgressChanged({
    required this.uploadProgress,
    this.optimizationParams,
  });

  @override
  List<Object> get props => [uploadProgress, optimizationParams ?? {}];
}

class ImageDataUpdated extends ProfileImageEvent {
  final ProfileImageData? imageData;
  final Map<String, dynamic>? optimizationParams;

  const ImageDataUpdated({
    this.imageData,
    this.optimizationParams,
  });

  @override
  List<Object> get props => [imageData?.toString() ?? '', optimizationParams ?? {}];
}

// States
abstract class ProfileImageState extends Equatable {
  const ProfileImageState();

  @override
  List<Object> get props => [];
}

class ProfileImageInitial extends ProfileImageState {}

class ProfileImageLoading extends ProfileImageState {}

class ProfileImageLoaded extends ProfileImageState {
  final ProfileImageData? currentImage;
  final ImageOptimizationParams optimizationParams;
  final Map<String, dynamic> performanceMetrics;
  final bool hasExistingImage;

  const ProfileImageLoaded({
    this.currentImage,
    required this.optimizationParams,
    required this.performanceMetrics,
    this.hasExistingImage = false,
  });

  @override
  List<Object> get props => [
        currentImage ?? '',
        optimizationParams,
        performanceMetrics,
        hasExistingImage,
      ];

  ProfileImageLoaded copyWith({
    ProfileImageData? currentImage,
    ImageOptimizationParams? optimizationParams,
    Map<String, dynamic>? performanceMetrics,
    bool? hasExistingImage,
  }) {
    return ProfileImageLoaded(
      currentImage: currentImage ?? this.currentImage,
      optimizationParams: optimizationParams ?? this.optimizationParams,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      hasExistingImage: hasExistingImage ?? this.hasExistingImage,
    );
  }
}

class ProfileImageUploading extends ProfileImageState {
  final UploadProgress uploadProgress;
  final ImageOptimizationParams optimizationParams;
  final Map<String, dynamic> performanceMetrics;

  const ProfileImageUploading({
    required this.uploadProgress,
    required this.optimizationParams,
    required this.performanceMetrics,
  });

  @override
  List<Object> get props => [
        uploadProgress,
        optimizationParams,
        performanceMetrics,
      ];
}

class ProfileImageOptimizing extends ProfileImageState {
  final double progress;
  final String currentStep;
  final ImageOptimizationParams optimizationParams;
  final Map<String, dynamic> performanceMetrics;

  const ProfileImageOptimizing({
    required this.progress,
    required this.currentStep,
    required this.optimizationParams,
    required this.performanceMetrics,
  });

  @override
  List<Object> get props => [
        progress,
        currentStep,
        optimizationParams,
        performanceMetrics,
      ];
}

class ProfileImageError extends ProfileImageState {
  final String message;
  final String? suggestion;
  final UploadProgress? uploadProgress;
  final ImageOptimizationParams optimizationParams;
  final Map<String, dynamic> performanceMetrics;
  final bool canRetry;

  const ProfileImageError({
    required this.message,
    required this.suggestion,
    this.uploadProgress,
    required this.optimizationParams,
    required this.performanceMetrics,
    this.canRetry = true,
  });

  @override
  List<Object> get props => [
        message,
        suggestion ?? '',
        uploadProgress ?? '',
        optimizationParams,
        performanceMetrics,
        canRetry,
      ];
}

class ProfileImageDeleting extends ProfileImageState {
  final String imageId;
  final double progress;
  final ImageOptimizationParams optimizationParams;
  final Map<String, dynamic> performanceMetrics;

  const ProfileImageDeleting({
    required this.imageId,
    required this.progress,
    required this.optimizationParams,
    required this.performanceMetrics,
  });

  @override
  List<Object> get props => [
        imageId,
        progress,
        optimizationParams,
        performanceMetrics,
      ];
}

// Bloc
class ProfileImageBloc extends Bloc<ProfileImageEvent, ProfileImageState> {
  final ProfileImageService _imageService = ProfileImageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ImageOptimizationParams _currentOptimizationParams =
      const ImageOptimizationParams();
  Map<String, dynamic> _performanceMetrics = {};
  ProfileImageData? _currentImage;
  StreamSubscription<UploadProgress>? _progressSubscription;
  StreamSubscription<ProfileImageData>? _imageDataSubscription;

  ProfileImageBloc() : super(ProfileImageInitial()) {
    on<InitializeProfileImage>(_onInitializeProfileImage);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<DeleteProfileImage>(_onDeleteProfileImage);
    on<UpdateOptimizationParams>(_onUpdateOptimizationParams);
    on<RetryUpload>(_onRetryUpload);
    on<ClearError>(_onClearError);
    on<LoadPerformanceMetrics>(_onLoadPerformanceMetrics);
    on<UploadProgressChanged>(_onUploadProgressChanged);
    on<ImageDataUpdated>(_onImageDataUpdated);

    // Initialize service listeners asynchronously
    _initializeServiceListeners();
  }

  void _initializeServiceListeners() {
    // Listen to service streams
    _imageService.uploadProgressStream.listen((progress) {
      if (state is ProfileImageUploading) {
        final currentState = state as ProfileImageUploading;
        // Update state through event instead of direct emit
        add(UploadProgressChanged(
          uploadProgress: progress,
          optimizationParams: _convertOptimizationParamsToMap(currentState.optimizationParams),
        ));
      }
    });

    _imageService.imageDataStream.listen((imageData) {
      _currentImage = imageData;
      if (state is ProfileImageUploading || state is ProfileImageOptimizing) {
        // Update state through event instead of direct emit
        add(ImageDataUpdated(
          imageData: _currentImage,
          optimizationParams: _convertOptimizationParamsToMap(_currentOptimizationParams),
        ));
      }
    });
  }

  /// Convert ImageOptimizationParams to Map<String, dynamic>
  Map<String, dynamic>? _convertOptimizationParamsToMap(ImageOptimizationParams params) {
    return {
      'maxWidth': params.maxWidth,
      'maxHeight': params.maxHeight,
      'quality': params.quality,
      'format': params.format.toString(),
    };
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    _imageDataSubscription?.cancel();
    _imageService.dispose();
    return super.close();
  }

  Future<void> _onInitializeProfileImage(
    InitializeProfileImage event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageLoading());

    try {
      // Validate user authentication
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != event.userId) {
        emit(ProfileImageError(
          message: 'Kullanıcı kimlik doğrulaması başarısız',
          suggestion: 'Lütfen tekrar giriş yapın',
          optimizationParams: _currentOptimizationParams,
          performanceMetrics: _performanceMetrics,
        ));
        return;
      }

      // Load performance metrics
      _performanceMetrics = _imageService.getPerformanceMetrics();

      // Check for existing image
      final hasExistingImage = event.existingImageUrl != null;

      if (hasExistingImage) {
        _currentImage = ProfileImageData(
          id: 'existing_${DateTime.now().millisecondsSinceEpoch}',
          userId: event.userId,
          originalUrl: event.existingImageUrl!,
          originalFormat: ImageFormat.jpeg,
          uploadProgress: UploadProgress(
            bytesUploaded: 0,
            totalBytes: 0,
            status: ImageUploadStatus.completed,
            progress: 1.0,
            startTime: DateTime.now(),
            estimatedTimeRemaining: 0,
          ),
          originalSize: 0,
          uploadedAt: DateTime.now(),
          optimizationParams: _currentOptimizationParams,
        );
      }

      emit(ProfileImageLoaded(
        currentImage: _currentImage,
        optimizationParams: _currentOptimizationParams,
        performanceMetrics: _performanceMetrics,
        hasExistingImage: hasExistingImage,
      ));
    } catch (e) {
      emit(ProfileImageError(
        message: 'Profil fotoğrafı başlatılamadı: $e',
        suggestion: 'İnternet bağlantınızı kontrol edin',
        optimizationParams: _currentOptimizationParams,
        performanceMetrics: _performanceMetrics,
      ));
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImage event,
    Emitter<ProfileImageState> emit,
  ) async {
    try {
      // Update optimization parameters
      _currentOptimizationParams =
          event.optimizationParams ?? _currentOptimizationParams;

      emit(ProfileImageUploading(
        uploadProgress: UploadProgress(
          bytesUploaded: 0,
          totalBytes: 0,
          status: ImageUploadStatus.selecting,
          progress: 0.0,
          startTime: DateTime.now(),
          estimatedTimeRemaining: 0,
        ),
        optimizationParams: _currentOptimizationParams,
        performanceMetrics: _performanceMetrics,
      ));

      // Validate image before upload
      final validation = _imageService.validateImageFile(
        event.imageData,
        event.format,
      );

      if (!validation.isValid) {
        emit(ProfileImageError(
          message: validation.errorMessage ?? 'Geçersiz görüntü dosyası',
          suggestion: validation.suggestions.isNotEmpty
              ? validation.suggestions.first
              : null,
          optimizationParams: _currentOptimizationParams,
          performanceMetrics: _performanceMetrics,
        ));
        return;
      }

      // Start upload process
      _currentImage = await _imageService.uploadProfileImage(
        imageData: event.imageData,
        userId: event.userId,
        format: event.format,
        optimizationParams: _currentOptimizationParams,
        cropConfig: event.cropConfig,
        watermarkText: event.watermarkText,
      );

      if (_currentImage != null) {
        emit(ProfileImageLoaded(
          currentImage: _currentImage,
          optimizationParams: _currentOptimizationParams,
          performanceMetrics: _imageService.getPerformanceMetrics(),
          hasExistingImage: true,
        ));
      } else {
        emit(ProfileImageError(
          message: 'Profil fotoğrafı yüklenemedi',
          suggestion: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin',
          optimizationParams: _currentOptimizationParams,
          performanceMetrics: _imageService.getPerformanceMetrics(),
        ));
      }
    } catch (e) {
      emit(ProfileImageError(
        message: 'Yükleme sırasında hata oluştu: $e',
        suggestion: 'Lütfen tekrar deneyin',
        optimizationParams: _currentOptimizationParams,
        performanceMetrics: _imageService.getPerformanceMetrics(),
      ));
    }
  }

  Future<void> _onDeleteProfileImage(
    DeleteProfileImage event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageDeleting(
      imageId: event.imageId,
      progress: 0.0,
      optimizationParams: _currentOptimizationParams,
      performanceMetrics: _performanceMetrics,
    ));

    try {
      final success = await _imageService.deleteProfileImage(
        userId: event.userId,
        imageId: event.imageId,
        originalUrl: event.originalUrl,
        optimizedUrl: event.optimizedUrl,
        thumbnailUrl: event.thumbnailUrl,
      );

      if (success) {
        _currentImage = null;
        emit(ProfileImageLoaded(
          currentImage: null,
          optimizationParams: _currentOptimizationParams,
          performanceMetrics: _imageService.getPerformanceMetrics(),
          hasExistingImage: false,
        ));
      } else {
        emit(ProfileImageError(
          message: 'Profil fotoğrafı silinemedi',
          suggestion: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin',
          uploadProgress: UploadProgress(
            bytesUploaded: 0,
            totalBytes: 0,
            status: ImageUploadStatus.error,
            progress: 0.0,
            startTime: DateTime.now(),
            estimatedTimeRemaining: 0,
          ),
          optimizationParams: _currentOptimizationParams,
          performanceMetrics: _imageService.getPerformanceMetrics(),
        ));
      }
    } catch (e) {
      emit(ProfileImageError(
        message: 'Silme işlemi sırasında hata oluştu: $e',
        suggestion: 'Lütfen tekrar deneyin',
        optimizationParams: _currentOptimizationParams,
        performanceMetrics: _imageService.getPerformanceMetrics(),
      ));
    }
  }

  void _onUpdateOptimizationParams(
    UpdateOptimizationParams event,
    Emitter<ProfileImageState> emit,
  ) {
    _currentOptimizationParams = event.newParams;

    if (state is ProfileImageLoaded) {
      emit((state as ProfileImageLoaded).copyWith(
        optimizationParams: _currentOptimizationParams,
      ));
    }
  }

  Future<void> _onRetryUpload(
    RetryUpload event,
    Emitter<ProfileImageState> emit,
  ) async {
    if (event.previousImageData != null) {
      emit(ProfileImageLoaded(
        currentImage: event.previousImageData,
        optimizationParams: _currentOptimizationParams,
        performanceMetrics: _performanceMetrics,
        hasExistingImage: true,
      ));
    } else {
      emit(ProfileImageInitial());
    }
  }

  void _onClearError(
    ClearError event,
    Emitter<ProfileImageState> emit,
  ) {
    if (state is ProfileImageError) {
      final errorState = state as ProfileImageError;
      if (errorState.uploadProgress != null) {
        emit(ProfileImageUploading(
          uploadProgress: errorState.uploadProgress!,
          optimizationParams: errorState.optimizationParams,
          performanceMetrics: errorState.performanceMetrics,
        ));
      } else {
        emit(ProfileImageLoaded(
          currentImage: _currentImage,
          optimizationParams: errorState.optimizationParams,
          performanceMetrics: errorState.performanceMetrics,
          hasExistingImage: _currentImage != null,
        ));
      }
    }
  }

  void _onLoadPerformanceMetrics(
    LoadPerformanceMetrics event,
    Emitter<ProfileImageState> emit,
  ) {
    _performanceMetrics = _imageService.getPerformanceMetrics();

    if (state is ProfileImageLoaded) {
      emit((state as ProfileImageLoaded).copyWith(
        performanceMetrics: _performanceMetrics,
      ));
    }
  }

  Future<void> _onUploadProgressChanged(
    UploadProgressChanged event,
    Emitter<ProfileImageState> emit,
  ) async {
    if (state is ProfileImageUploading) {
      final currentState = state as ProfileImageUploading;
      emit(ProfileImageUploading(
        uploadProgress: event.uploadProgress,
        optimizationParams: event.optimizationParams ?? currentState.optimizationParams,
        performanceMetrics: _performanceMetrics,
      ));
    }
  }

  Future<void> _onImageDataUpdated(
    ImageDataUpdated event,
    Emitter<ProfileImageState> emit,
  ) async {
    if (state is ProfileImageUploading || state is ProfileImageOptimizing) {
      final imageData = event.imageData;
      if (imageData != null) {
        _currentImage = imageData;
      }
      emit(ProfileImageLoaded(
        currentImage: _currentImage,
        optimizationParams: event.optimizationParams ?? _currentOptimizationParams,
        performanceMetrics: _performanceMetrics,
        hasExistingImage: true,
      ));
    }
  }
}
