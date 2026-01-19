// lib/widgets/profile_picture_change_dialog.dart
// Profil fotoğrafı değiştirme dialogu - İyileştirilmiş kullanıcı deneyimi

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/profile_picture_service.dart';
import '../services/profile_service.dart';
import 'avatar_selection_widget.dart';

enum UploadStep {
  idle,
  selecting,
  uploading,
  processing,
  complete,
  error
}

enum UploadError {
  none,
  selectionFailed,
  uploadFailed,
  storageError,
  networkError,
  unknown
}

class ProfilePictureChangeDialog extends StatefulWidget {
  final String? currentProfilePictureUrl;
  final Function(String)? onProfilePictureUpdated;

  const ProfilePictureChangeDialog({
    super.key,
    this.currentProfilePictureUrl,
    this.onProfilePictureUpdated,
  });

  @override
  State<ProfilePictureChangeDialog> createState() =>
      _ProfilePictureChangeDialogState();
}

class _ProfilePictureChangeDialogState
    extends State<ProfilePictureChangeDialog> {
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  final ProfileService _profileService = ProfileService();

  // Durum yönetimi
  UploadStep _currentStep = UploadStep.idle;
  UploadError _currentError = UploadError.none;
  String _statusMessage = '';
  String _errorDetails = '';
  double _uploadProgress = 0.0;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // Geçerli adımlar
  bool get _isProcessing =>
      _currentStep == UploadStep.selecting ||
      _currentStep == UploadStep.uploading ||
      _currentStep == UploadStep.processing;

  bool get _hasError => _currentError != UploadError.none;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case UploadStep.selecting:
      case UploadStep.uploading:
      case UploadStep.processing:
        return _buildProcessingState();
      
      case UploadStep.error:
        return _buildErrorState();
      
      case UploadStep.complete:
        return _buildCompleteState();
      
      case UploadStep.idle:
      default:
        return _buildIdleState();
    }
  }

  /// Boşta bekleme durumu
  Widget _buildIdleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        const Row(
          children: [
            Icon(Icons.person_add_alt_1, size: 24, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Profil Fotoğrafı Değiştir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Mevcut profil fotoğrafı önizleme
        _buildCurrentPicturePreview(),
        const SizedBox(height: 20),

        // İşlem butonları
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.photo_library,
                  title: 'Galeriden Seç',
                  subtitle: 'Cihazınızdan fotoğraf seçin',
                  color: Colors.blue,
                  onTap: _pickImageFromGallery,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.camera_alt,
                  title: 'Kamera ile Çek',
                  subtitle: 'Yeni bir fotoğraf çekin',
                  color: Colors.green,
                  onTap: _pickImageFromCamera,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.emoji_emotions,
                  title: 'Avatar Seç',
                  subtitle: 'Hazır avatar veya emoji seçin',
                  color: Colors.orange,
                  onTap: _showAvatarSelection,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// İşlem durumu (loading + progress)
  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasyonlu progress indicator
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _currentStep == UploadStep.uploading ? _uploadProgress : null,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                Center(
                  child: _getProcessingIcon(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Durum mesajı
          Text(
            _getStepTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Detaylı durum mesajı
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          // İlerleme çubuğu (yükleme sırasında)
          if (_currentStep == UploadStep.uploading) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '%${(_uploadProgress * 100).toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // İptal butonu
          TextButton(
            onPressed: _cancelOperation,
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProcessingIcon() {
    switch (_currentStep) {
      case UploadStep.selecting:
        return const Icon(Icons.image, size: 32, color: Colors.blue);
      case UploadStep.uploading:
        return const Icon(Icons.cloud_upload, size: 32, color: Colors.blue);
      case UploadStep.processing:
        return const Icon(Icons.save, size: 32, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case UploadStep.selecting:
        return 'Fotoğraf Seçiliyor';
      case UploadStep.uploading:
        return 'Fotoğraf Yükleniyor';
      case UploadStep.processing:
        return 'Profil Güncelleniyor';
      default:
        return 'İşleniyor';
    }
  }

  /// Hata durumu
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hata ikonu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getErrorIcon(),
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          
          // Hata başlığı
          Text(
            _getErrorTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Hata detayı
          if (_errorDetails.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorDetails,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Hata açıklaması
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _getErrorDescription(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // İşlem butonları
          if (_retryCount < _maxRetries) ...[
            ElevatedButton.icon(
              onPressed: _retryOperation,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          TextButton(
            onPressed: () {
              setState(() {
                _currentError = UploadError.none;
                _currentStep = UploadStep.idle;
              });
            },
            child: Text(
              'Vazgeç',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (_currentError) {
      case UploadError.selectionFailed:
        return Icons.image_not_supported;
      case UploadError.uploadFailed:
        return Icons.cloud_off;
      case UploadError.storageError:
        return Icons.storage;
      case UploadError.networkError:
        return Icons.wifi_off;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    switch (_currentError) {
      case UploadError.selectionFailed:
        return 'Fotoğraf Seçilemedi';
      case UploadError.uploadFailed:
        return 'Yükleme Başarısız';
      case UploadError.storageError:
        return 'Depolama Hatası';
      case UploadError.networkError:
        return 'Ağ Bağlantısı Yok';
      default:
        return 'Beklenmeyen Hata';
    }
  }

  String _getErrorDescription() {
    switch (_currentError) {
      case UploadError.selectionFailed:
        return 'Galeri veya kamera erişiminde bir sorun oluştu.';
      case UploadError.uploadFailed:
        return 'Fotoğraf Firebase\'e yüklenemedi. Lütfen tekrar deneyin.';
      case UploadError.storageError:
        return 'Depolama sisteminde bir hata oluştu.';
      case UploadError.networkError:
        return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
      default:
        return 'Bir sorun oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Tamamlanma durumu
  Widget _buildCompleteState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Başarı ikonu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Başarılı!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Mevcut profil fotoğrafı önizleme
  Widget _buildCurrentPicturePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[200],
            backgroundImage: widget.currentProfilePictureUrl != null &&
                    widget.currentProfilePictureUrl!.isNotEmpty
                ? NetworkImage(widget.currentProfilePictureUrl!)
                : null,
            onBackgroundImageError: widget.currentProfilePictureUrl != null
                ? (exception, stackTrace) {
                    // Hata durumunda varsayılan ikon göster
                  }
                : null,
            child: (widget.currentProfilePictureUrl == null ||
                    widget.currentProfilePictureUrl!.isEmpty)
                ? Icon(Icons.person, size: 35, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mevcut Profil Fotoğrafı',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.currentProfilePictureUrl != null &&
                          widget.currentProfilePictureUrl!.isNotEmpty
                      ? 'Güncel fotoğrafınız'
                      : 'Varsayılan avatar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  /// İşlem butonu widget'ı
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: _isProcessing ? Colors.grey[100] : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  // ========== İŞLEM METODLARI ==========

  /// Galeriden resim seç
  Future<void> _pickImageFromGallery() async {
    setState(() {
      _currentStep = UploadStep.selecting;
      _statusMessage = 'Galeri açılıyor...';
      _currentError = UploadError.none;
    });

    try {
      final File? imageFile = await _profilePictureService.pickImageFromGallery();
      
      if (imageFile != null) {
        await _uploadAndUpdateImage(imageFile);
      } else {
        // Kullanıcı iptal etti
        setState(() {
          _currentStep = UploadStep.idle;
        });
      }
    } catch (e) {
      _handleError(UploadError.selectionFailed, e.toString());
    }
  }

  /// Kamera ile resim çek
  Future<void> _pickImageFromCamera() async {
    setState(() {
      _currentStep = UploadStep.selecting;
      _statusMessage = 'Kamera açılıyor...';
      _currentError = UploadError.none;
    });

    try {
      final File? imageFile = await _profilePictureService.pickImageFromCamera();
      
      if (imageFile != null) {
        await _uploadAndUpdateImage(imageFile);
      } else {
        // Kullanıcı iptal etti
        setState(() {
          _currentStep = UploadStep.idle;
        });
      }
    } catch (e) {
      _handleError(UploadError.selectionFailed, e.toString());
    }
  }

  /// Avatar seçim dialogunu göster
  Future<void> _showAvatarSelection() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AvatarSelectionWidget(
          onAvatarSelected: (selectedAvatar) async {
            await _updateProfilePicture(selectedAvatar);
            Navigator.of(context).pop();
          },
          currentAvatarUrl: widget.currentProfilePictureUrl,
        ),
      ),
    );
  }

  /// Resim yükle ve profili güncelle
  Future<void> _uploadAndUpdateImage(File imageFile) async {
    try {
      // Adım 1: Firebase Storage'a yükle
      setState(() {
        _currentStep = UploadStep.uploading;
        _statusMessage = 'Fotoğraf yükleniyor...';
        _uploadProgress = 0.0;
      });

      // Firebase Storage'a yükle
      final String? imageUrl = await _profilePictureService.uploadImageToFirebase(imageFile);
      
      if (imageUrl == null) {
        _handleError(UploadError.uploadFailed, 'URL alınamadı');
        return;
      }

      // Adım 2: Profili güncelle
      setState(() {
        _currentStep = UploadStep.processing;
        _statusMessage = 'Profil güncelleniyor...';
        _uploadProgress = 1.0;
      });

      await _updateProfilePicture(imageUrl);

    } catch (e) {
      _handleError(UploadError.uploadFailed, e.toString());
    }
  }

  /// Profil fotoğrafını güncelle
  Future<void> _updateProfilePicture(String imageUrl) async {
    try {
      setState(() {
        _currentStep = UploadStep.processing;
        _statusMessage = 'Profil kaydediliyor...';
      });

      final updatedUrl = await _profilePictureService.replaceProfilePicture(
          imageUrl, _profileService);

      if (updatedUrl != null) {
        // Başarılı
        setState(() {
          _currentStep = UploadStep.complete;
          _statusMessage = 'Profil fotoğrafınız başarıyla güncellendi!';
          _currentError = UploadError.none;
        });

        // Callback'i çağır
        widget.onProfilePictureUpdated?.call(updatedUrl);
        
        // 2 saniye sonra dialog'u kapat
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _handleError(UploadError.uploadFailed, 'Profil güncellenemedi');
      }
    } catch (e) {
      _handleError(UploadError.unknown, e.toString());
    }
  }

  /// İşlemi iptal et
  void _cancelOperation() {
    setState(() {
      _currentStep = UploadStep.idle;
      _currentError = UploadError.none;
      _statusMessage = '';
      _uploadProgress = 0.0;
    });
  }

  /// İşlemi tekrar dene
  void _retryOperation() {
    setState(() {
      _retryCount++;
      _currentError = UploadError.none;
      _currentStep = UploadStep.idle;
      _statusMessage = '';
      _uploadProgress = 0.0;
    });
  }

  /// Hata yönetimi
  void _handleError(UploadError error, String details) {
    setState(() {
      _currentStep = UploadStep.error;
      _currentError = error;
      _errorDetails = details;
      _uploadProgress = 0.0;
    });
    
    // Debug için log
    debugPrint('❌ Profil fotoğrafı hatası: $error - $details');
  }
}

