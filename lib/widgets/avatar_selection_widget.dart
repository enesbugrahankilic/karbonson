// lib/widgets/avatar_selection_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/profile_picture_service.dart';

class AvatarSelectionWidget extends StatefulWidget {
  final Function(String) onAvatarSelected;
  final String? currentAvatarUrl;

  const AvatarSelectionWidget({
    super.key,
    required this.onAvatarSelected,
    this.currentAvatarUrl,
  });

  @override
  State<AvatarSelectionWidget> createState() => _AvatarSelectionWidgetState();
}

class _AvatarSelectionWidgetState extends State<AvatarSelectionWidget> {
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.currentAvatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Profil Fotografi Sec',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Default Avatars Section
                  _buildSectionTitle('Varsayilan Avatar'),
                  _buildAvatarGrid(_profilePictureService.defaultAvatars),

                  const SizedBox(height: 16),

                  // Emoji Avatars Section
                  _buildSectionTitle('Emoji Avatar'),
                  _buildAvatarGrid(_profilePictureService.emojiAvatars),

                  const SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAvatarGrid(List<String> avatars) {
    // Eğer avatar listesi boşsa bilgi mesajı göster
    if (avatars.isEmpty) {
      return Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: const Center(
          child: Text(
            'Avatar bulunamadı',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          final String avatarUrl = avatars[index];
          return _buildAvatarItem(avatarUrl);
        },
      ),
    );
  }

  Widget _buildAvatarItem(String avatarUrl) {
    final bool isSelected = _selectedAvatar == avatarUrl;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedAvatar = avatarUrl;
              });
              widget.onAvatarSelected(avatarUrl);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarUrl.endsWith('.svg')
                    ? _buildSvgWidget(avatarUrl)
                    : _buildImageWidget(avatarUrl),
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: Colors.blue,
              size: 20,
            ),
          // Debug: Avatar URL'i göster
          Text(
            avatarUrl.split('/').last,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSvgWidget(String avatarUrl) {
    return SvgPicture.asset(
      avatarUrl,
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: Center(
          child: Text(
            avatarUrl.split('/').last.replaceAll('.svg', ''),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ SVG yükleme hatası: $avatarUrl - $error');
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 20),
              const SizedBox(height: 4),
              Text(
                'Hata',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String avatarUrl) {
    return Image.network(
      avatarUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Resim yükleme hatası: $avatarUrl - $error');
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
              label: const Text('Iptal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectedAvatar != null
                  ? () {
                      widget.onAvatarSelected(_selectedAvatar!);
                      Navigator.of(context).pop();
                    }
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Sec'),
            ),
          ),
        ],
      ),
    );
  }
}
