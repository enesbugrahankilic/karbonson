// lib/widgets/profile_image_upload_widget.dart

import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_image_data.dart';
import '../services/profile_image_service.dart';
import 'drawing_canvas.dart';
import 'default_avatar_selector.dart';

/// Profile image upload widget with real-time preview and crop tools
class ProfileImageUploadWidget extends StatefulWidget {
  final String userId;
  final double? avatarSize;
  final VoidCallback? onUploadComplete;
  final ImageFormat preferredFormat;
  final ImageOptimizationParams? optimizationParams;
  final bool showCropTools;
  final bool showPreview;
  final Widget? customPlaceholder;
  final EdgeInsetsGeometry? padding;

  const ProfileImageUploadWidget({
    Key? key,
    required this.userId,
    this.avatarSize = 120.0,
    this.onUploadComplete,
    this.preferredFormat = ImageFormat.jpeg,
    this.optimizationParams,
    this.showCropTools = true,
    this.showPreview = true,
    this.customPlaceholder,
    this.padding,
  }) : super(key: key);

  @override
  State<ProfileImageUploadWidget> createState() =>
      _ProfileImageUploadWidgetState();
}

class _ProfileImageUploadWidgetState extends State<ProfileImageUploadWidget>
    with TickerProviderStateMixin {
  final ProfileImageService _imageService = ProfileImageService();

  ImageUploadStatus _uploadStatus = ImageUploadStatus.idle;
  UploadProgress? _uploadProgress;
  ProfileImageData? _currentImage;
  Uint8List? _selectedImage;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to upload progress
    _imageService.uploadProgressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _uploadProgress = progress;
          _uploadStatus = progress.status;
          if (progress.hasError) {
            _errorMessage = progress.errorMessage;
          }
        });
      }
    });

    // Listen to image data updates
    _imageService.imageDataStream.listen((imageData) {
      if (mounted) {
        setState(() {
          _currentImage = imageData;
          _selectedImage = null;
          _errorMessage = null;
        });
        widget.onUploadComplete?.call();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _uploadStatus = ImageUploadStatus.selecting;
        _errorMessage = null;
      });

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        maxHeight: 4000,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });

        if (widget.showPreview) {
          _showImagePreview(bytes);
        } else {
          _uploadImage(bytes);
        }
      } else {
        setState(() {
          _uploadStatus = ImageUploadStatus.idle;
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = ImageUploadStatus.error;
        _errorMessage = 'Resim seçilirken hata oluştu: $e';
      });
    }
  }

  void _showImagePreview(Uint8List imageData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImagePreviewSheet(
        imageData: imageData,
        userId: widget.userId,
        avatarSize: widget.avatarSize,
        preferredFormat: widget.preferredFormat,
        optimizationParams: widget.optimizationParams,
        showCropTools: widget.showCropTools,
        onConfirm: _uploadImage,
        onCancel: () {
          Navigator.of(context).pop();
          setState(() {
            _selectedImage = null;
            _uploadStatus = ImageUploadStatus.idle;
          });
        },
      ),
    );
  }

  void _openDefaultAvatarSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Varsayılan Avatar Seç',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Seç ve Çık'),
                    ),
                  ],
                ),
              ),
              // Avatar Selector
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DefaultAvatarSelector(
                      selectedAvatarPath: _currentImage?.originalUrl,
                      onAvatarSelected: (avatarPath) async {
                        // Load SVG as image data
                        try {
                          final svgString = await DefaultAssetBundle.of(context)
                              .loadString(avatarPath);
                          // For now, we'll use a placeholder approach
                          // In a real implementation, you'd convert SVG to PNG
                          Navigator.of(context).pop();

                          // Show a message that this feature is coming soon
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('SVG avatar seçimi yakında eklenecek'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Avatar yüklenirken hata: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImage(Uint8List imageData) async {
    try {
      Navigator.of(context).pop(); // Close preview sheet

      setState(() {
        _uploadStatus = ImageUploadStatus.uploading;
      });

      final result = await _imageService.uploadProfileImage(
        imageData: imageData,
        userId: widget.userId,
        format: widget.preferredFormat,
        optimizationParams: widget.optimizationParams,
      );

      if (result == null) {
        setState(() {
          _uploadStatus = ImageUploadStatus.error;
          _errorMessage = 'Resim yüklenirken hata oluştu';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = ImageUploadStatus.error;
        _errorMessage = 'Resim yüklenirken hata oluştu: $e';
      });
    }
  }

  Future<void> _deleteCurrentImage() async {
    if (_currentImage == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resmi Sil'),
        content: const Text(
            'Profil fotoğrafınızı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _imageService.deleteProfileImage(
        userId: _currentImage!.userId,
        imageId: _currentImage!.id,
        originalUrl: _currentImage!.originalUrl,
        optimizedUrl: _currentImage!.optimizedUrl,
        thumbnailUrl: _currentImage!.thumbnailUrl,
      );

      if (success) {
        setState(() {
          _currentImage = null;
          _selectedImage = null;
          _uploadStatus = ImageUploadStatus.idle;
        });
      } else {
        setState(() {
          _uploadStatus = ImageUploadStatus.error;
          _errorMessage = 'Resim silinirken hata oluştu';
        });
      }
    }
  }

  void _openDrawingCanvas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Profil Fotoğrafı Çiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kaydet ve Çık'),
                    ),
                  ],
                ),
              ),
              // Drawing Canvas
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DrawingCanvas(
                      onSave: (image) async {
                        // Convert ui.Image to Uint8List
                        final byteData = await image.toByteData(
                            format: ui.ImageByteFormat.png);
                        if (byteData != null) {
                          final bytes = byteData.buffer.asUint8List();
                          Navigator.of(context).pop();
                          _uploadImage(bytes);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatarWidget(),
                  const SizedBox(height: 16),
                  _buildUploadControls(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    _buildErrorMessage(),
                  ],
                  if (_uploadStatus == ImageUploadStatus.uploading) ...[
                    const SizedBox(height: 8),
                    _buildProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget() {
    final size = widget.avatarSize!;

    Widget avatarWidget;

    if (_uploadStatus == ImageUploadStatus.selecting ||
        _uploadStatus == ImageUploadStatus.uploading ||
        _uploadStatus == ImageUploadStatus.optimizing ||
        _uploadStatus == ImageUploadStatus.processing) {
      // Show loading or selection state
      avatarWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: _buildLoadingWidget(),
        ),
      );
    } else if (_selectedImage != null) {
      // Show selected image preview
      avatarWidget = ClipOval(
        child: Image.memory(
          _selectedImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else if (_currentImage?.optimizedUrl != null) {
      // Show current optimized image
      avatarWidget = _imageService.getOptimizedImageWidget(
        imageUrl: _currentImage!.optimizedUrl!,
        size: size,
        showProgressIndicator: false,
      );
    } else if (_currentImage?.thumbnailUrl != null) {
      // Show thumbnail
      avatarWidget = _imageService.getOptimizedImageWidget(
        imageUrl: _currentImage!.thumbnailUrl!,
        size: size,
        showProgressIndicator: false,
      );
    } else if (_currentImage?.originalUrl != null) {
      // Show original image
      avatarWidget = _imageService.getOptimizedImageWidget(
        imageUrl: _currentImage!.originalUrl,
        size: size,
        showProgressIndicator: false,
      );
    } else {
      // Show placeholder
      avatarWidget = widget.customPlaceholder ??
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.grey.shade600,
            ),
          );
    }

    return Stack(
      children: [
        avatarWidget,
        if (_uploadStatus == ImageUploadStatus.uploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: _uploadProgress?.progress,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        if (_uploadStatus == ImageUploadStatus.idle ||
            _uploadStatus == ImageUploadStatus.completed)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _currentImage != null ? Icons.edit : Icons.camera_alt,
                  color: Colors.white,
                  size: size * 0.15,
                ),
              ),
            ),
          ),
        if (_currentImage != null)
          Positioned(
            left: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _deleteCurrentImage,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    switch (_uploadStatus) {
      case ImageUploadStatus.selecting:
        return const Icon(Icons.photo_library, color: Colors.grey, size: 32);
      case ImageUploadStatus.uploading:
        return const CircularProgressIndicator(strokeWidth: 2);
      case ImageUploadStatus.optimizing:
        return const Icon(Icons.tune, color: Colors.orange, size: 32);
      case ImageUploadStatus.processing:
        return const Icon(Icons.speed, color: Colors.blue, size: 32);
      default:
        return const Icon(Icons.person, color: Colors.grey, size: 32);
    }
  }

  Widget _buildUploadControls() {
    if (_uploadStatus == ImageUploadStatus.error) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      );
    }

    if (_selectedImage != null && widget.showPreview) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _uploadStatus = ImageUploadStatus.idle;
              });
            },
            icon: const Icon(Icons.cancel),
            label: const Text('İptal'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _uploadStatus == ImageUploadStatus.idle
                ? () => _uploadImage(_selectedImage!)
                : null,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Yükle'),
          ),
        ],
      );
    }

    if (_uploadStatus == ImageUploadStatus.idle) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('Fotoğraf Seç'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openDrawingCanvas,
            icon: const Icon(Icons.brush),
            label: const Text('Çizim Yap'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _openDefaultAvatarSelector,
            icon: const Icon(Icons.face),
            label: const Text('Varsayılan Avatar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProgressIndicator() {
    final progress = _uploadProgress;
    if (progress == null) return const SizedBox.shrink();

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress.progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress.percentage).toStringAsFixed(0)}% tamamlandı',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Image preview sheet with crop tools
class _ImagePreviewSheet extends StatefulWidget {
  final Uint8List imageData;
  final String userId;
  final double? avatarSize;
  final ImageFormat preferredFormat;
  final ImageOptimizationParams? optimizationParams;
  final bool showCropTools;
  final Function(Uint8List) onConfirm;
  final VoidCallback onCancel;

  const _ImagePreviewSheet({
    required this.imageData,
    required this.userId,
    this.avatarSize,
    required this.preferredFormat,
    this.optimizationParams,
    required this.showCropTools,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_ImagePreviewSheet> createState() => _ImagePreviewSheetState();
}

class _ImagePreviewSheetState extends State<_ImagePreviewSheet> {
  ImageCropConfig? _cropConfig;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildImagePreview(),
          ),
          if (widget.showCropTools) _buildCropControls(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
          ),
          const Expanded(
            child: Text(
              'Profil Fotoğrafını Düzenle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => widget.onConfirm(widget.imageData),
            icon: const Icon(Icons.check, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        width: widget.avatarSize,
        height: widget.avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: ClipOval(
          child: Image.memory(
            widget.imageData,
            fit: BoxFit.cover,
            width: widget.avatarSize,
            height: widget.avatarSize,
          ),
        ),
      ),
    );
  }

  Widget _buildCropControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const Text(
            'Kırpma Seçenekleri',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCropButton('Daire', 1.0),
              _buildCropButton('Kare', 1.0),
              _buildCropButton('Geniş', 16.0 / 9.0),
              _buildCropButton('Uzun', 9.0 / 16.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropButton(String label, double aspectRatio) {
    final isSelected = _cropConfig?.aspectRatio == aspectRatio;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _cropConfig = ImageCropConfig(
            x: 0,
            y: 0,
            width: 1.0,
            height: 1.0,
            aspectRatio: aspectRatio,
          );
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        minimumSize: const Size(60, 36),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onConfirm(widget.imageData),
              child: const Text('Onayla'),
            ),
          ),
        ],
      ),
    );
  }
}
