// lib/services/qr_code_service.dart
// QR Code Service - Generate and scan QR codes for friend adding

import 'dart:convert';
import 'package:flutter/foundation.dart';

class QRFriendData {
  final String type;
  final String userId;
  final String? nickname;
  final DateTime? expiresAt;

  QRFriendData({
    this.type = 'friend_request',
    required this.userId,
    this.nickname,
    this.expiresAt,
  });

  static QRFriendData? fromString(String qrString) {
    try {
      final Map<String, dynamic> data = jsonDecode(qrString);
      if (data['type'] != 'friend_request') return null;
      return QRFriendData(
        type: data['type'] ?? 'friend_request',
        userId: data['userId'] ?? '',
        nickname: data['nickname'],
        expiresAt: data['expiresAt'] != null 
            ? DateTime.tryParse(data['expiresAt']) 
            : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing QR data: $e');
      return null;
    }
  }

  String toQRString() {
    final Map<String, dynamic> data = {
      'type': type,
      'userId': userId,
      'nickname': nickname,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid {
    return userId.isNotEmpty && !isExpired;
  }
}

class QRCodeResult {
  final bool success;
  final String? error;
  final QRFriendData? friendData;

  QRCodeResult({required this.success, this.error, this.friendData});

  factory QRCodeResult.success(QRFriendData data) {
    return QRCodeResult(success: true, friendData: data);
  }

  factory QRCodeResult.failure(String error) {
    return QRCodeResult(success: false, error: error);
  }
}

class QRCodeService {
  QRFriendData generateFriendQR({
    required String userId,
    required String nickname,
    Duration validityDuration = const Duration(days: 7),
  }) {
    return QRFriendData(
      type: 'friend_request',
      userId: userId,
      nickname: nickname,
      expiresAt: DateTime.now().add(validityDuration),
    );
  }

  String generateQRCodeData(QRFriendData data) {
    return data.toQRString();
  }

  QRCodeResult validateScannedCode(String qrString) {
    try {
      final data = QRFriendData.fromString(qrString);
      if (data == null) {
        return QRCodeResult.failure('Geçersiz QR kodu');
      }
      if (!data.isValid) {
        if (data.isExpired) {
          return QRCodeResult.failure('Bu QR kodunun suresi doldu');
        }
        return QRCodeResult.failure('Geçersiz QR kodu');
      }
      return QRCodeResult.success(data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error validating QR code: $e');
      return QRCodeResult.failure('QR kodu okunamadı');
    }
  }

  String generateShareableLink(String userId, String nickname) {
    final path = '/addfriend/${Uri.encodeComponent(userId)}';
    final params = {
      'nickname': nickname,
      'source': 'qr_code',
    };
    final uri = Uri.https('karbonson.app', path, params);
    return uri.toString();
  }

  static QRCodeResult parseScanResult(String rawValue) {
    if (rawValue.isEmpty) {
      return QRCodeResult.failure('QR kod verisi okunamadı');
    }
    return QRCodeService().validateScannedCode(rawValue);
  }
}
