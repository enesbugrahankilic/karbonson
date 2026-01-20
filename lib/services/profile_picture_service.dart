// lib/services/profile_picture_service.dart
// Profil fotoğrafı yükleme servisi - Güvenli ve stabilize implementasyon

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import 'profile_service.dart';

class ProfilePictureService {
  // Yapılandırma sabitleri
  static const String _storagePath = 'profile_images';
  static const int _maxImageWidth = 1024;
  static const int _maxImageHeight = 1024;
  static const int _imageQuality = 85;
  static const int _maxFileSizeMB = 10;

  // Default avatars path
  static const String _defaultAvatarsPath = 'assets/avatars/';

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Track active upload tasks to prevent memory leaks
  final List<UploadTask> _activeUploadTasks = [];

  // Default avatars listesi
  List<String> get defaultAvatars {
    final avatars = [
      '${_defaultAvatarsPath}default_avatar_1.svg',
      '${_defaultAvatarsPath}default_avatar_2.svg',
      '${_defaultAvatarsPath}default_avatar_3.svg',
      '${_defaultAvatarsPath}default_avatar_4.svg',
      '${_defaultAvatarsPath}default_avatar_5.svg',
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

  /// Galeriden resim seç
  Future<File?> pickImageFromGallery() async {
    try {
      if (kDebugMode) {
        debugPrint('📷 Galeriden resim seçiliyor...');
      }

      // Check if image picker is available
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _imageQuality,
      );

      if (images.isNotEmpty) {
        final XFile image = images.first;
        if (kDebugMode) {
          debugPrint('✅ Galeriden resim seçildi: ${image.path}');
        }
        return File(image.path);
      }

      if (kDebugMode) {
        debugPrint('⚠️ Kullanıcı resim seçmedi');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Galeriden resim seçme hatası: $e');
      }
      // Return null instead of crashing - user might have denied permission
      return null;
    }
  }

  /// Kamera ile resim çek
  Future<File?> pickImageFromCamera() async {
    try {
      if (kDebugMode) {
        debugPrint('📷 Kameradan resim çekiliyor...');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _imageQuality,
      );

      if (image != null) {
        if (kDebugMode) {
          debugPrint('✅ Kameradan resim çekildi: ${image.path}');
        }
        return File(image.path);
      }

      if (kDebugMode) {
        debugPrint('⚠️ Kullanıcı resim çekmedi');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Kameradan resim çekme hatası: $e');
      }
      // Return null instead of crashing - user might have denied permission
      return null;
    }
  }

  /// Resmi Firebase Storage'a yükle
  /// Basit ve doğru upload mantığı - crash önleyici düzeltmeler ile
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      // Kullanıcı kontrolü
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('❌ Kullanıcı oturumu bulunamadı');
        }
        return null;
      }

      if (kDebugMode) {
        debugPrint('📤 Firebase Storage\'a yükleniyor...');
        debugPrint('   Kullanıcı UID: ${user.uid}');
        debugPrint('   Dosya yolu: ${imageFile.path}');
      }

      // Dosya boyutu kontrolü
      final fileSizeBytes = await imageFile.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      
      if (fileSizeMB > _maxFileSizeMB) {
        if (kDebugMode) {
          debugPrint('❌ Dosya boyutu çok büyük: ${fileSizeMB.toStringAsFixed(2)} MB (max: $_maxFileSizeMB MB)');
        }
        return null;
      }

      // Benzersiz dosya adı oluştur
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = '$_storagePath/${user.uid}/$fileName';

      // Storage referansı oluştur
      final Reference storageRef = _storage.ref().child(filePath);

      // Metadata ekle - Firebase Storage kuralları için gerekli
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'purpose': 'profile_picture',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
        cacheControl: 'public, max-age=31536000',
      );

      // Dosyayı yükle
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Track this task to prevent memory leaks
      _activeUploadTasks.add(uploadTask);

      // Yükleme durumunu dinle (opsiyonel) - subscription yönetimi
      StreamSubscription<TaskSnapshot>? subscription;
      subscription = uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (kDebugMode) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(0);
          debugPrint('📊 Yükleme ilerlemesi: $progress%');
        }
      }, onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ Upload event error: $error');
        }
      });

      try {
        // Yüklemeyi bekle
        final TaskSnapshot snapshot = await uploadTask;

        // Cancel subscription to prevent memory leaks
        await subscription.cancel();
        _activeUploadTasks.remove(uploadTask);

        if (snapshot.state == TaskState.success) {
          // Download URL al
          final String downloadUrl = await storageRef.getDownloadURL();
          
          if (kDebugMode) {
            debugPrint('✅ Resim başarıyla yüklendi');
            debugPrint('   URL: $downloadUrl');
          }
          
          return downloadUrl;
        } else {
          if (kDebugMode) {
            debugPrint('❌ Resim yükleme başarısız: ${snapshot.state}');
          }
          return null;
        }
      } catch (e) {
        // Cleanup on error
        await subscription.cancel();
        _activeUploadTasks.remove(uploadTask);
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase Storage yükleme hatası: $e');
      }
      return null;
    }
  }

  /// Profil fotoğrafını güncelle
  Future<bool> updateProfilePicture(
      String imageUrl, ProfileService profileService) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('❌ Kullanıcı oturumu bulunamadı');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('🔄 Profil fotoğrafı güncelleniyor...');
      }

      // ProfileService üzerinden Firestore'u güncelle
      final success = await profileService.updateProfilePicture(imageUrl);

      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Profil fotoğrafı başarıyla güncellendi');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Profil fotoğrafı güncellenemedi');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Profil fotoğrafı güncelleme hatası: $e');
      }
      return false;
    }
  }

  /// Firebase Storage'dan eski resmi sil
  Future<bool> deleteImageFromFirebase(String imageUrl) async {
    try {
      if (imageUrl.isEmpty || !imageUrl.contains('firebase')) {
        if (kDebugMode) {
          debugPrint('⚠️ Geçersiz resim URL\'i, silme atlandı');
        }
        return true; // Silme başarılı say (asset'ler için)
      }

      // URL'den dosya yolunu çıkar
      final String storagePath = imageUrl
          .split('?')[0]
          .replaceFirst('https://firebasestorage.googleapis.com/v0/b/', '')
          .replaceFirst(
              '${FirebaseStorage.instance.app.options.projectId}.appspot.com/o/',
              '')
          .replaceAll('%2F', '/'); // URL encoding'i düzelt

      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.delete();

      if (kDebugMode) {
        debugPrint('🗑️ Eski profil fotoğrafı silindi');
      }
      return true;
    } catch (e) {
      // Silme hatası kritik değil - dosya zaten yok olabilir
      if (kDebugMode) {
        debugPrint('⚠️ Profil fotoğrafı silme uyarısı: $e');
      }
      return true; // Silinemediğinde bile devam et
    }
  }

  /// Eski profil fotoğrafını temizle ve yenisiyle değiştir
  Future<String?> replaceProfilePicture(
      String newImageUrl, ProfileService profileService) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('❌ Kullanıcı oturumu bulunamadı');
        }
        return null;
      }

      // Mevcut kullanıcı profilini al
      final currentProfile = await profileService.loadServerProfile();
      final oldImageUrl = currentProfile?.profilePictureUrl;

      // Yeni profili güncelle
      final success = await profileService.updateProfilePicture(newImageUrl);
      if (!success) {
        if (kDebugMode) {
          debugPrint('❌ Profil fotoğrafı güncellenemedi');
        }
        return null;
      }

      // Eski fotoğrafı sil (asset değilse ve farklıysa)
      if (oldImageUrl != null &&
          oldImageUrl.isNotEmpty &&
          !oldImageUrl.contains('assets/') &&
          !oldImageUrl.contains('default_avatar') &&
          oldImageUrl != newImageUrl) {
        await deleteImageFromFirebase(oldImageUrl);
      }

      if (kDebugMode) {
        debugPrint('✅ Profil fotoğrafı başarıyla değiştirildi');
      }
      
      return newImageUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Profil fotoğrafı değiştirme hatası: $e');
      }
      return null;
    }
  }

  /// Resmi kırp - context null kontrolü ile
  Future<File?> cropImage(File imageFile, BuildContext? context) async {
    try {
      if (kDebugMode) {
        debugPrint('✂️ Resim kırpılıyor...');
      }

      // Context kontrolü - crash önleme
      if (context == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Context null, kırpma atlandı');
        }
        return imageFile; // Kırpma olmadan devam et
      }

      // Context'in widget ağacında olup olmadığını kontrol et
      if (!context.mounted) {
        if (kDebugMode) {
          debugPrint('⚠️ Context mounted değil, kırpma atlandı');
        }
        return imageFile;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Kare oran
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Profil Fotoğrafı',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Profil Fotoğrafı',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        if (kDebugMode) {
          debugPrint('✅ Resim kırpıldı');
        }
        return File(croppedFile.path);
      }

      if (kDebugMode) {
        debugPrint('⚠️ Kullanıcı kırpma işlemini iptal etti');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Resim kırpma hatası: $e');
      }
      // Kırpma hatası durumunda orijinal dosyayı döndür
      return imageFile;
    }
  }

  /// Resim dosya boyutunu kontrol et
  Future<bool> validateImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      final sizeInMB = bytes / (1024 * 1024);
      
      if (kDebugMode) {
        debugPrint('📏 Resim boyutu: ${sizeInMB.toStringAsFixed(2)} MB');
      }
      
      return sizeInMB <= _maxFileSizeMB;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Resim boyutu kontrol hatası: $e');
      }
      return false;
    }
  }

  /// Resim kaynak seçim dialogunu göster - mounted kontrolü ile
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    // Context kontrolü
    if (!context.mounted) {
      if (kDebugMode) {
        debugPrint('⚠️ Context mounted değil');
      }
      return null;
    }

    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profil Fotoğrafı Seç'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera ile Çek'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tam profil fotoğrafı yükleme akışı
  /// Bu metod tüm süreci tek seferde yönetir - crash önleyici düzeltmeler ile
  Future<String?> uploadProfilePicture({
    required BuildContext context,
    required ImageSource source,
    required ProfileService profileService,
    bool shouldCrop = true,
  }) async {
    try {
      // Context mounted kontrolü
      if (!context.mounted) {
        if (kDebugMode) {
          debugPrint('❌ Context mounted değil');
        }
        return null;
      }

      // 1. Resim seç
      File? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await pickImageFromGallery();
      } else {
        imageFile = await pickImageFromCamera();
      }

      if (imageFile == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Resim seçilmedi');
        }
        return null;
      }

      // 2. Boyut kontrolü
      final isValidSize = await validateImageSize(imageFile);
      if (!isValidSize) {
        if (kDebugMode) {
          debugPrint('❌ Resim boyutu çok büyük (max $_maxFileSizeMB MB)');
        }
        return null;
      }

      // 3. Opsiyonel: Kırp - context kontrolü ile
      if (shouldCrop) {
        final croppedFile = await cropImage(imageFile, context);
        if (croppedFile != null) {
          imageFile = croppedFile;
        }
      }

      // Context mounted kontrolü devam eden işlemler için
      if (!context.mounted) {
        if (kDebugMode) {
          debugPrint('⚠️ Context artık mounted değil, işlem iptal edildi');
        }
        return null;
      }

      // 4. Firebase Storage'a yükle
      final imageUrl = await uploadImageToFirebase(imageFile);
      if (imageUrl == null) {
        if (kDebugMode) {
          debugPrint('❌ Firebase Storage yüklemesi başarısız');
        }
        return null;
      }

      // 5. Firestore profilini güncelle
      final result = await replaceProfilePicture(imageUrl, profileService);
      
      if (result != null) {
        if (kDebugMode) {
          debugPrint('✅ Profil fotoğrafı başarıyla yüklendi ve güncellendi');
        }
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Profil fotoğrafı yükleme akışı hatası: $e');
      }
      return null;
    }
  }

  /// Clean up all active upload tasks - call when leaving the page
  void cancelAllUploads() {
    for (final task in _activeUploadTasks) {
      try {
        // Cancel the task if it's still active
        final snapshot = task.snapshot;
        if (snapshot.state == TaskState.running || snapshot.state == TaskState.paused) {
          task.cancel();
        }
      } catch (e) {
        // Task may already be completed or errored
        if (kDebugMode) {
          debugPrint('⚠️ Error canceling upload task: $e');
        }
      }
    }
    _activeUploadTasks.clear();
  }
}

