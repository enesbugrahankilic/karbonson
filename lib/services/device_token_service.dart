// lib/services/device_token_service.dart
// Specification: Device Token Management for Multi-Device Push Notifications
// Manages multiple FCM tokens per user account with automatic cleanup

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device_token.dart';

/// Device Token Service for managing multiple FCM tokens per user
/// Supports token registration, update, deletion, and stale token cleanup
class DeviceTokenService {
  static final DeviceTokenService _instance = DeviceTokenService._internal();
  factory DeviceTokenService() => _instance;
  DeviceTokenService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  // Collection names
  static const String _devicesCollection = 'devices';

  // Constants
  static const int _staleDaysThreshold = 30;
  static const int _cleanupBatchSize = 100;

  /// Initialize device token service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = true;
      if (kDebugMode) debugPrint('DeviceTokenService initialized');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize DeviceTokenService: $e');
      return false;
    }
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isUserAuthenticated => _auth.currentUser != null;

  /// Register or update device token for the current user
  /// Returns the deviceId
  Future<String?> registerDeviceToken(String fcmToken) async {
    final userId = currentUserId;
    if (userId == null) {
      if (kDebugMode) debugPrint('Cannot register token: user not authenticated');
      return null;
    }

    try {
      final platform = 'mobile';
      const appVersion = '1.0.0';

      // Check if this device already has a token registered
      final existingDeviceId = await _findExistingDeviceId(userId, fcmToken);

      if (existingDeviceId != null) {
        await _updateToken(userId, existingDeviceId, fcmToken);
        if (kDebugMode) debugPrint('Device token updated: $existingDeviceId');
        return existingDeviceId;
      }

      // Register new device
      final newDeviceToken = DeviceToken.create(
        fcmToken: fcmToken,
        platform: platform,
        appVersion: appVersion,
      );

      await _db
          .collection('users')
          .doc(userId)
          .collection(_devicesCollection)
          .doc(newDeviceToken.deviceId)
          .set(newDeviceToken.toMap());

      if (kDebugMode) {
        debugPrint('New device token registered: ${newDeviceToken.deviceId}');
      }

      return newDeviceToken.deviceId;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to register device token: $e');
      return null;
    }
  }

  /// Find existing deviceId by token
  Future<String?> _findExistingDeviceId(String userId, String fcmToken) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection(_devicesCollection)
          .where('token', isEqualTo: fcmToken)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }

      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error finding existing device: $e');
      return null;
    }
  }

  /// Update existing token
  Future<bool> _updateToken(String userId, String deviceId, String newToken) async {
    try {
      final docRef = _db
          .collection('users')
          .doc(userId)
          .collection(_devicesCollection)
          .doc(deviceId);

      await docRef.update({
        'token': newToken,
        'lastUsedAt': Timestamp.fromDate(DateTime.now()),
        'isActive': true,
      });

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update token: $e');
      return false;
    }
  }

  /// Get all active device tokens for a user
  Future<List<DeviceToken>> getUserDeviceTokens({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      if (kDebugMode) debugPrint('Cannot get tokens: user not authenticated');
      return [];
    }

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection(_devicesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final List<DeviceToken> tokens = [];
      for (final doc in snapshot.docs) {
        try {
          final token = DeviceToken.fromMap(doc.data(), doc.id);
          tokens.add(token);
        } catch (err) {
          if (kDebugMode) debugPrint('Error parsing device token: $err');
        }
      }
      
      return tokens;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get device tokens: $e');
      return [];
    }
  }

  /// Mark a device token as inactive
  Future<bool> deactivateDeviceToken(String deviceId, {String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return false;

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection(_devicesCollection)
          .doc(deviceId)
          .update({'isActive': false});

      if (kDebugMode) debugPrint('Device token deactivated: $deviceId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to deactivate token: $e');
      return false;
    }
  }

  /// Get active device count for a user
  Future<int> getActiveDeviceCount({String? userId}) async {
    final tokens = await getUserDeviceTokens(userId: userId);
    return tokens.length;
  }

  /// Check if user has any active devices
  Future<bool> hasActiveDevices({String? userId}) async {
    final count = await getActiveDeviceCount(userId: userId);
    return count > 0;
  }

  /// Update last used timestamp for a device
  Future<bool> updateLastUsed(String deviceId, {String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return false;

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection(_devicesCollection)
          .doc(deviceId)
          .update({'lastUsedAt': Timestamp.fromDate(DateTime.now())});

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update last used: $e');
      return false;
    }
  }

  /// Get device info summary for debugging
  Future<Map<String, dynamic>> getDeviceInfoSummary({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      return {'error': 'User not authenticated'};
    }

    final activeTokens = await getUserDeviceTokens(userId: uid);

    return {
      'userId': uid,
      'activeDeviceCount': activeTokens.length,
      'devices': activeTokens.map((t) => {
        'deviceId': t.deviceId,
        'platform': t.platform,
        'appVersion': t.appVersion,
        'lastUsed': t.lastUsedAt.toIso8601String(),
      }).toList(),
    };
  }
}

