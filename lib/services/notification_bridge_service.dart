// lib/services/notification_bridge_service.dart
// Specification: Account-to-Device Notification Bridge
// Bridges account-based notifications (Firestore) to device push notifications (FCM)
// Core principle: Account notification is the source, push is a reflection to online devices

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_data.dart';
import 'device_token_service.dart';

/// Notification Bridge Service
/// Connects account-based notifications to device push notifications
/// 
/// Flow:
/// 1. Create account notification in Firestore (source of truth)
/// 2. Check user's online presence
/// 3. Send FCM push to online devices (reflection only)
/// 4. Update delivery status
class NotificationBridgeService {
  static final NotificationBridgeService _instance = NotificationBridgeService._internal();
  factory NotificationBridgeService() => _instance;
  NotificationBridgeService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;
  DeviceTokenService? _deviceTokenService;

  // Collection names
  static const String _notificationsCollection = 'notifications';
  static const String _deliveryStatusCollection = 'delivery_status';

  /// Initialize notification bridge service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _deviceTokenService = DeviceTokenService();
      await _deviceTokenService!.initialize();
      
      _isInitialized = true;
      if (kDebugMode) debugPrint('NotificationBridgeService initialized');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize NotificationBridgeService: $e');
      return false;
    }
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Send account notification with push bridge
  /// 
  /// This is the main method that:
  /// 1. Saves notification to Firestore (account-based, source of truth)
  /// 2. Checks user presence
  /// 3. Sends push notification to online devices (reflection)
  Future<NotificationSendResult> sendAccountNotification({
    required String recipientId,
    required NotificationType type,
    required String title,
    required String message,
    String? senderId,
    String? senderNickname,
    Map<String, dynamic>? additionalData,
    bool skipPush = false,
  }) async {
    final notificationId = '$recipientId-${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      // Step 1: Save notification to Firestore (account-based source of truth)
      final notificationData = NotificationData(
        id: notificationId,
        type: type,
        title: title,
        message: message,
        senderId: senderId,
        senderNickname: senderNickname,
        additionalData: additionalData,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _saveNotificationToFirestore(recipientId, notificationData);
      
      if (kDebugMode) {
        debugPrint('Notification saved to Firestore: $notificationId');
      }

      // Step 2: Update delivery status
      await _updateDeliveryStatus(
        notificationId: notificationId,
        recipientId: recipientId,
        pushSent: false,
        devicesNotified: 0,
      );

      return NotificationSendResult(
        success: true,
        notificationId: notificationId,
        firestoreSaved: true,
        pushSent: false,
        devicesNotified: 0,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to send account notification: $e');
      return NotificationSendResult(
        success: false,
        notificationId: notificationId,
        firestoreSaved: false,
        error: e.toString(),
      );
    }
  }

  /// Save notification to Firestore (account-based)
  Future<void> _saveNotificationToFirestore(String recipientId, NotificationData data) async {
    await _db
        .collection(_notificationsCollection)
        .doc(recipientId)
        .collection('notifications')
        .doc(data.id)
        .set(data.toMap());
  }

  /// Update delivery status in Firestore
  Future<void> _updateDeliveryStatus({
    required String notificationId,
    required String recipientId,
    required bool pushSent,
    required int devicesNotified,
  }) async {
    try {
      final deliveryStatus = {
        'notificationId': notificationId,
        'recipientId': recipientId,
        'firestoreSaved': true,
        'pushSent': pushSent,
        'devicesNotified': devicesNotified,
        'deliveredAt': FieldValue.serverTimestamp(),
        'status': pushSent ? 'delivered' : 'pending',
      };

      await _db
          .collection(_notificationsCollection)
          .doc(recipientId)
          .collection(_deliveryStatusCollection)
          .doc(notificationId)
          .set(deliveryStatus);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update delivery status: $e');
    }
  }

  /// Check if user has active devices
  Future<bool> userHasActiveDevices(String userId) async {
    try {
      final service = _deviceTokenService ?? DeviceTokenService();
      return await service.hasActiveDevices(userId: userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to check active devices: $e');
      return false;
    }
  }

  /// Get user's device tokens
  Future<List<dynamic>> getUserDevices(String userId) async {
    try {
      final service = _deviceTokenService ?? DeviceTokenService();
      return await service.getUserDeviceTokens(userId: userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get user devices: $e');
      return [];
    }
  }

  /// Get delivery statistics for a user
  Future<DeliveryStats> getDeliveryStats({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) return DeliveryStats.empty();

    try {
      final snapshot = await _db
          .collection(_notificationsCollection)
          .doc(uid)
          .collection(_deliveryStatusCollection)
          .get();

      int total = snapshot.docs.length;
      int delivered = 0;
      int pending = 0;
      int failed = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['pushSent'] == true) {
          delivered++;
        } else if (data['pushSent'] == false) {
          pending++;
        } else {
          failed++;
        }
      }

      return DeliveryStats(
        totalNotifications: total,
        deliveredCount: delivered,
        pendingCount: pending,
        failedCount: failed,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get delivery stats: $e');
      return DeliveryStats.empty();
    }
  }
}

/// Result of notification send operation
class NotificationSendResult {
  final bool success;
  final String? notificationId;
  final bool firestoreSaved;
  final bool pushSent;
  final int devicesNotified;
  final String? error;

  const NotificationSendResult({
    required this.success,
    this.notificationId,
    this.firestoreSaved = false,
    this.pushSent = false,
    this.devicesNotified = 0,
    this.error,
  });

  bool get hasError => error != null;
}

/// Delivery statistics
class DeliveryStats {
  final int totalNotifications;
  final int deliveredCount;
  final int pendingCount;
  final int failedCount;

  DeliveryStats({
    required this.totalNotifications,
    required this.deliveredCount,
    required this.pendingCount,
    required this.failedCount,
  });

  double get deliveryRate {
    if (totalNotifications == 0) return 0;
    return deliveredCount / totalNotifications;
  }

  factory DeliveryStats.empty() {
    return DeliveryStats(
      totalNotifications: 0,
      deliveredCount: 0,
      pendingCount: 0,
      failedCount: 0,
    );
  }
}

