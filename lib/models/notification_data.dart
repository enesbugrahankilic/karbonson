// lib/models/notification_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types for different events
enum NotificationType {
  friendRequestAccepted,
  friendRequestRejected,
  gameInvite,
  gameInviteAccepted,
  dailyTaskCompleted,
  rewardBoxEarned,
  boxOpened,
  achievementEarned,
  general,
}

/// Notification data model
class NotificationData {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? senderId;
  final String? senderNickname;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final bool isRead;

  NotificationData({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.senderId,
    this.senderNickname,
    this.additionalData,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      id: map['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => NotificationType.general,
      ),
      title: map['title'],
      message: map['message'],
      senderId: map['senderId'],
      senderNickname: map['senderNickname'],
      additionalData: map['additionalData'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'senderId': senderId,
      'senderNickname': senderNickname,
      'additionalData': additionalData,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  /// Create notification for friend request accepted
  factory NotificationData.friendRequestAccepted({
    required String senderId,
    required String senderNickname,
    required String recipientNickname,
  }) {
    return NotificationData(
      id: '', // Will be set when created
      type: NotificationType.friendRequestAccepted,
      title: 'Arkadaşlık İsteği Kabul Edildi',
      message:
          '$senderNickname arkadaşlık isteğinizi kabul etti. Artık arkadaşsınız!',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'recipientNickname': recipientNickname,
        'action': 'accepted',
      },
      createdAt: DateTime.now(),
    );
  }

  /// Create notification for friend request rejected
  factory NotificationData.friendRequestRejected({
    required String senderId,
    required String senderNickname,
    required String recipientNickname,
  }) {
    return NotificationData(
      id: '', // Will be set when created
      type: NotificationType.friendRequestRejected,
      title: 'Arkadaşlık İsteği Reddedildi',
      message: '$senderNickname arkadaşlık isteğinizi reddetti.',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'recipientNickname': recipientNickname,
        'action': 'rejected',
      },
      createdAt: DateTime.now(),
    );
  }

  NotificationData copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? senderId,
    String? senderNickname,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      senderNickname: senderNickname ?? this.senderNickname,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
