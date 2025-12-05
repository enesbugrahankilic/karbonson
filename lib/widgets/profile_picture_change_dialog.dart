// lib/widgets/profile_picture_change_dialog.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/profile_picture_service.dart';
import '../services/profile_service.dart';
import 'avatar_selection_widget.dart';

class ProfilePictureChangeDialog extends StatefulWidget {
  final String? currentProfilePictureUrl;
  final VoidCallback? onProfilePictureUpdated;

  const ProfilePictureChangeDialog({
    Key? key,
    this.currentProfilePictureUrl,
    this.onProfilePictureUpdated,
  }) : super(key: key);

  @override
  State<ProfilePictureChangeDialog> createState() => _ProfilePictureChangeDialogState();
}

class _ProfilePictureChangeDialogState extends State<ProfilePictureChangeDialog> {
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  final ProfileService _profileService = ProfileService();
  
  bool _isLoading = false;
  String? _selectedAvatar;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6, // Ekran yüksekliğinin %60'ı
        padding: const EdgeInsets.all(16),
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isLoading ? 'Profil fotografi guncelleniyor...' : 'Yukleniyor...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profil Fotografi Degistir',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        
        // Current Profile Picture Preview
        _buildCurrentPicturePreview(),
        const SizedBox(height: 20),
        
        // Scrollable Action Buttons
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.photo_library,
                  title: 'Galeriden Sec',
                  subtitle: 'Cihazinizdan fotograf secin',
                  color: Colors.blue,
                  onTap: _pickImageFromGallery,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.camera_alt,
                  title: 'Kamera ile Cek',
                  subtitle: 'Yeni bir fotograf cekin',
                  color: Colors.green,
                  onTap: _pickImageFromCamera,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.emoji_emotions,
                  title: 'Avatar Sec',
                  subtitle: 'Hazir avatar veya emoji secin',
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
            radius: 30,
            backgroundImage: widget.currentProfilePictureUrl != null
                ? NetworkImage(widget.currentProfilePictureUrl!)
                : null,
            child: widget.currentProfilePictureUrl == null
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mevcut Profil Fotografi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.currentProfilePictureUrl != null 
                    ? 'Guncel fotografiniz' 
                    : 'Varsayilan avatar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: 14,
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
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final File? imageFile = await _profilePictureService.pickImageFromGallery();
    if (imageFile != null) {
      await _uploadAndUpdateImage(imageFile);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final File? imageFile = await _profilePictureService.pickImageFromCamera();
    if (imageFile != null) {
      await _uploadAndUpdateImage(imageFile);
    }
  }

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
          },
          currentAvatarUrl: widget.currentProfilePictureUrl,
        ),
      ),
    );
  }

  Future<void> _uploadAndUpdateImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Storage'a yükle
      final String? imageUrl = await _profilePictureService.uploadImageToFirebase(imageFile);
      
      if (imageUrl != null) {
        await _updateProfilePicture(imageUrl);
      } else {
        _showErrorSnackBar('Resim yuklenemedi, lutfen tekrar deneyin.');
      }
    } catch (e) {
      _showErrorSnackBar('Bir hata olustu: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfilePicture(String imageUrl) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ProfileService ile profil fotografini güncelle
      final success = await _profileService.updateProfilePicture(imageUrl);
      
      if (success) {
        widget.onProfilePictureUpdated?.call();
        Navigator.of(context).pop(); // Dialog'u kapat
        _showSuccessSnackBar('Profil fotografi basariyla guncellendi!');
      } else {
        _showErrorSnackBar('Profil fotografi guncellenemedi.');
      }
    } catch (e) {
      _showErrorSnackBar('Bir hata olustu: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}