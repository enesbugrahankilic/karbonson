import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:local_auth/local_auth.dart';
import '../services/biometric_service.dart';

/// Biyometri kullanım durumu modeli
class BiometricUserData {
  final String userId;
  final bool isBiometricEnabled;
  final List<String> availableBiometricTypes;
  final DateTime? lastBiometricSetup;
  final DateTime? lastBiometricLogin;
  final String deviceInfo;

  BiometricUserData({
    required this.userId,
    required this.isBiometricEnabled,
    required this.availableBiometricTypes,
    this.lastBiometricSetup,
    this.lastBiometricLogin,
    required this.deviceInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isBiometricEnabled': isBiometricEnabled,
      'availableBiometricTypes': availableBiometricTypes,
      'lastBiometricSetup': lastBiometricSetup?.toIso8601String(),
      'lastBiometricLogin': lastBiometricLogin?.toIso8601String(),
      'deviceInfo': deviceInfo,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory BiometricUserData.fromMap(Map<String, dynamic> map) {
    return BiometricUserData(
      userId: map['userId'] ?? '',
      isBiometricEnabled: map['isBiometricEnabled'] ?? false,
      availableBiometricTypes: List<String>.from(map['availableBiometricTypes'] ?? []),
      lastBiometricSetup: map['lastBiometricSetup'] != null 
          ? DateTime.parse(map['lastBiometricSetup'])
          : null,
      lastBiometricLogin: map['lastBiometricLogin'] != null 
          ? DateTime.parse(map['lastBiometricLogin'])
          : null,
      deviceInfo: map['deviceInfo'] ?? '',
    );
  }
}

/// Biyometri kullanım durumu yönetim servisi
class BiometricUserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Firestore koleksiyon adı
  static const String _collectionName = 'biometric_users';

  /// Kullanıcının biyometri verilerini Firestore'a kaydet
  static Future<bool> saveBiometricSetup() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Biyometri mevcut mu kontrol et
      final isAvailable = await BiometricService.isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Bu cihazda biyometrik kimlik doğrulama mevcut değil');
      }

      // Mevcut biyometri türlerini al
      final biometricTypes = await BiometricService.getAvailableBiometrics();
      final biometricTypeNames = biometricTypes.map((type) {
        switch (type) {
          case BiometricType.face:
            return 'Face ID';
          case BiometricType.fingerprint:
            return 'Parmak İzi';
          case BiometricType.iris:
            return 'İris Tarama';
          default:
            return 'Bilinmeyen';
        }
      }).toList();

      // Cihaz bilgilerini al
      final deviceInfo = await _getDeviceInfo();

      // Biyometri kullanım verisi oluştur
      final biometricData = BiometricUserData(
        userId: user.uid,
        isBiometricEnabled: true,
        availableBiometricTypes: biometricTypeNames,
        lastBiometricSetup: DateTime.now(),
        deviceInfo: deviceInfo,
      );

      // Firestore'a kaydet
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(biometricData.toMap(), SetOptions(merge: true));

      if (kDebugMode) {
        print('Biyometri kurulumu başarıyla kaydedildi: ${user.uid}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Biyometri kurulumu kaydetme hatası: $e');
      }
      return false;
    }
  }

  /// Son biyometri giriş zamanını güncelle
  static Future<void> updateLastBiometricLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .update({
        'lastBiometricLogin': FieldValue.serverTimestamp(),
        'isBiometricEnabled': true,
      });

      if (kDebugMode) {
        print('Son biyometri giriş zamanı güncellendi: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Son biyometri giriş zamanı güncelleme hatası: $e');
      }
    }
  }

  /// Kullanıcının biyometri durumunu getir
  static Future<BiometricUserData?> getUserBiometricData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      return BiometricUserData.fromMap(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('Biyometri verisi alma hatası: $e');
      }
      return null;
    }
  }

  /// Kullanıcının biyometri kullanıp kullanmadığını kontrol et
  static Future<bool> isUserBiometricEnabled() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;

      final data = doc.data();
      return data?['isBiometricEnabled'] ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Biyometri durumu kontrol hatası: $e');
      }
      return false;
    }
  }

  /// Biyometri kullanımını devre dışı bırak
  static Future<bool> disableBiometric() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .update({
        'isBiometricEnabled': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Biyometri devre dışı bırakıldı: ${user.uid}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Biyometri devre dışı bırakma hatası: $e');
      }
      return false;
    }
  }

  /// Cihaz bilgilerini al
  static Future<String> _getDeviceInfo() async {
    try {
      // Basit cihaz bilgisi (gerçek projede platform_device_id kullanılabilir)
      return 'Flutter Device ${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Tüm kullanıcıların biyometri istatistikleri
  static Future<Map<String, dynamic>> getBiometricStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isBiometricEnabled', isEqualTo: true)
          .get();

      final totalUsers = snapshot.docs.length;
      
      // Biyometri türlerine göre dağılım
      final Map<String, int> biometricTypeCount = {};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final types = List<String>.from(data['availableBiometricTypes'] ?? []);
        
        for (final type in types) {
          biometricTypeCount[type] = (biometricTypeCount[type] ?? 0) + 1;
        }
      }

      return {
        'totalBiometricUsers': totalUsers,
        'biometricTypeDistribution': biometricTypeCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Biyometri istatistik hatası: $e');
      }
      return {};
    }
  }
}