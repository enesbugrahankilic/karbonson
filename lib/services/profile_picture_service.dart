// lib/services/profile_picture_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'profile_service.dart';

class ProfilePictureService {
  static const String _defaultAvatarsPath = 'assets/avatars/';
  static const String _storagePath = 'profile_pictures/';

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Default avatars listesi
  List<String> get defaultAvatars {
    final avatars = [
      '${_defaultAvatarsPath}default_avatar_1.svg',
      '${_defaultAvatarsPath}default_avatar_2.svg',
    ];
    if (kDebugMode) {
      debugPrint('ProfilePictureService: Default avatars loaded: $avatars');
    }
    return avatars;
  }

  // Emoji avatars listesi
  List<String> get emojiAvatars {
    final avatars = [
      '${_defaultAvatarsPath}emoji_avatar_1.svg',
      '${_defaultAvatarsPath}emoji_avatar_2.svg',
    ];
    if (kDebugMode) {
      debugPrint('ProfilePictureService: Emoji avatars loaded: $avatars');
    }
    return avatars;
  }

  // Tum mevcut avatar secenekleri
  List<String> get allAvatars => [...defaultAvatars, ...emojiAvatars];

  /// Galeriden resim sec
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Galeri den resim secme hatasi: $e');
      return null;
    }
  }

  /// Kamera dan resim cek
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Kamera dan resim cekme hatasi: $e');
      return null;
    }
  }

  /// Firebase Storage a resim yukle
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Kullanici oturumu bulunamadi');
        return null;
      }

      // Benzersiz dosya adi olustur
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = '$_storagePath${user.uid}/$fileName';

      // Resmi yukle
      final Reference storageRef = _storage.ref().child(filePath);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Yukleme durumunu bekle
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Yuklenen resmin URL ini al
        final String downloadUrl = await storageRef.getDownloadURL();
        debugPrint('Resim basariyla yuklendi: $downloadUrl');
        return downloadUrl;
      } else {
        debugPrint('Resim yukleme basarisiz');
        return null;
      }
    } catch (e) {
      debugPrint('Firebase Storage yukleme hatasi: $e');
      return null;
    }
  }

  /// Profil fotografini guncelle
  Future<bool> updateProfilePicture(
      String imageUrl, ProfileService profileService) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ Kullanici oturumu bulunamadi');
        return false;
      }

      debugPrint('📸 Profil fotografi guncelleniyor: $imageUrl');

      // ProfileService uzerinden Firestore'u guncelle
      final success = await profileService.updateProfilePicture(imageUrl);

      if (success) {
        debugPrint('✅ Profil fotografi basariyla guncellendi: $imageUrl');
      } else {
        debugPrint('❌ Profil fotografi guncellenemedi');
      }

      return success;
    } catch (e) {
      debugPrint('🚨 Profil fotografi guncelleme hatasi: $e');
      return false;
    }
  }

  /// Storage dan resmi sil (eski fotografi temizlemek icin)
  Future<bool> deleteImageFromFirebase(String imageUrl) async {
    try {
      // URL den dosya yolunu cikar
      final String storagePath = imageUrl
          .split('?')[0]
          .replaceFirst('https://firebasestorage.googleapis.com/v0/b/', '')
          .replaceFirst(
              '${FirebaseStorage.instance.app.options.projectId}.appspot.com/o/',
              '');

      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.delete();

      debugPrint('🗑️ Eski profil fotografi silindi: $storagePath');
      return true;
    } catch (e) {
      debugPrint('❌ Profil fotografi silme hatasi: $e');
      return false;
    }
  }

  /// Eski profil fotoğrafını temizle ve yenisini yükle
  Future<String?> replaceProfilePicture(
      String newImageUrl, ProfileService profileService) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ Kullanici oturumu bulunamadi');
        return null;
      }

      // Mevcut kullanici profilini al
      final currentProfile = await profileService.loadServerProfile();
      final oldImageUrl = currentProfile?.profilePictureUrl;

      // Yeni profili güncelle
      final success = await profileService.updateProfilePicture(newImageUrl);
      if (!success) {
        debugPrint('❌ Profil fotografi guncellenemedi');
        return null;
      }

      // Eski fotografi sil (asset'ler degilse)
      if (oldImageUrl != null &&
          !oldImageUrl.contains('assets/') &&
          !oldImageUrl.contains('default_avatar') &&
          oldImageUrl != newImageUrl) {
        final deleteSuccess = await deleteImageFromFirebase(oldImageUrl);
        if (!deleteSuccess) {
          debugPrint(
              '⚠️ Eski profil fotografi silinirken hata olustu: $oldImageUrl');
        }
      }

      debugPrint('✅ Profil fotografi basariyla degistirildi: $newImageUrl');
      return newImageUrl;
    } catch (e) {
      debugPrint('🚨 Profil fotografi degistirme hatasi: $e');
      return null;
    }
  }

  /// Asset ten default avatar URL i olustur
  String getAssetAvatarUrl(String assetPath) {
    return assetPath;
  }

  /// Resim secme seceneklerini goster
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profil Fotografi Sec'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Sec'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera ile Cek'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }
}
