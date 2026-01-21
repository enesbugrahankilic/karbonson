// lib/models/device_token.dart
// Specification: Device Token Management for Multi-Device Push Notifications
// Supports storing multiple FCM tokens per user account

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Device token model for multi-device push notification support
/// Stored in Firestore: users/{uid}/devices/{deviceId}
class DeviceToken {
  final String deviceId;
  final String token;
  final String platform; // 'ios' | 'android' | 'web'
  final String appVersion;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool isActive;

  const DeviceToken({
    required this.deviceId,
    required this.token,
    required this.platform,
    required this.appVersion,
    required this.createdAt,
    required this.lastUsedAt,
    this.isActive = true,
  });

  factory DeviceToken.fromMap(Map<String, dynamic> map, String documentId) {
    return DeviceToken(
      deviceId: documentId,
      token: map['token'] ?? '',
      platform: map['platform'] ?? 'unknown',
      appVersion: map['appVersion'] ?? '1.0.0',
      createdAt: _parseTimestamp(map['createdAt']),
      lastUsedAt: _parseTimestamp(map['lastUsedAt']) ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is String) return DateTime.tryParse(timestamp) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'platform': platform,
      'appVersion': appVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUsedAt': Timestamp.fromDate(lastUsedAt),
      'isActive': isActive,
    };
  }

  /// Create a new device token from FCM token
  factory DeviceToken.create({
    required String fcmToken,
    required String platform,
    required String appVersion,
  }) {
    return DeviceToken(
      deviceId: const Uuid().v4(),
      token: fcmToken,
      platform: platform,
      appVersion: appVersion,
      createdAt: DateTime.now(),
      lastUsedAt: DateTime.now(),
      isActive: true,
    );
  }

  /// Update token value
  DeviceToken copyWithToken(String newToken) {
    return DeviceToken(
      deviceId: deviceId,
      token: newToken,
      platform: platform,
      appVersion: appVersion,
      createdAt: createdAt,
      lastUsedAt: DateTime.now(),
      isActive: isActive,
    );
  }

  /// Mark device as inactive
  DeviceToken copyWithInactive() {
    return DeviceToken(
      deviceId: deviceId,
      token: token,
      platform: platform,
      appVersion: appVersion,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
      isActive: false,
    );
  }

  /// Update last used timestamp
  DeviceToken updateLastUsed() {
    return DeviceToken(
      deviceId: deviceId,
      token: token,
      platform: platform,
      appVersion: appVersion,
      createdAt: createdAt,
      lastUsedAt: DateTime.now(),
      isActive: isActive,
    );
  }

  /// Check if token is stale (not used for specified duration)
  bool isStale({int daysThreshold = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: daysThreshold));
    return lastUsedAt.isBefore(cutoff);
  }

  @override
  String toString() {
    return 'DeviceToken(deviceId: $deviceId, platform: $platform, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceToken && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}

