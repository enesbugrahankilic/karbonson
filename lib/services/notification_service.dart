// lib/services/notification_service.dart
// Hesap Bazlı Bildirim Sistemi (Account-Based Notification System)
// Bildirimler Firestore'da saklanır ve farklı cihazlardan erişilebilir

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_data.dart';

/// Hesap Bazlı Bildirim Servisi
/// Bildirimleri Firestore'da saklar ve real-time sync sağlar
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;
  StreamSubscription? _notificationSubscription;

  // Collection names
  static const String _notificationsCollection = 'notifications';

  /// Initialize notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = true;
      if (kDebugMode) debugPrint('✅ NotificationService initialized (Account-Based)');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to initialize NotificationService: $e');
      return false;
    }
  }

  /// Save notification to Firestore (Account-Based)
  Future<String?> saveNotification({
    required String recipientId,
    required NotificationType type,
    required String title,
    required String message,
    String? senderId,
    String? senderNickname,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notificationDoc = _db
          .collection(_notificationsCollection)
          .doc(recipientId)
          .collection('notifications')
          .doc();

      final notification = NotificationData(
        id: notificationDoc.id,
        type: type,
        title: title,
        message: message,
        senderId: senderId,
        senderNickname: senderNickname,
        additionalData: additionalData,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await notificationDoc.set(notification.toMap());

      if (kDebugMode) {
        debugPrint('✅ Notification saved to Firestore: ${notificationDoc.id}');
      }

      return notificationDoc.id;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to save notification: $e');
      return null;
    }
  }

  /// Listen to notifications in real-time (Account-Based)
  Stream<List<NotificationData>> listenToNotifications(String userId) {
    if (userId.isEmpty) {
      if (kDebugMode) debugPrint('❌ Empty userId provided to listenToNotifications');
      return const Stream.empty();
    }

    try {
      return _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map((querySnapshot) {
        try {
          return querySnapshot.docs
              .map((doc) => NotificationData.fromMap(doc.data()))
              .toList();
        } catch (parseError) {
          if (kDebugMode) debugPrint('⚠️ Error parsing notification: $parseError');
          return <NotificationData>[];
        }
      }).handleError((error) {
        if (kDebugMode) debugPrint('🚨 Stream error in listenToNotifications: $error');
        return <NotificationData>[];
      });
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error setting up notification listener: $e');
      return const Stream.empty();
    }
  }

  /// Get unread notification count (Account-Based)
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read (Account-Based)
  Future<bool> markAsRead(String userId, String notificationId) async {
    try {
      await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      if (kDebugMode) debugPrint('✅ Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to mark notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read (Account-Based)
  Future<bool> markAllAsRead(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      if (kDebugMode) debugPrint('✅ All notifications marked as read for user: $userId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to mark all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification (Account-Based)
  Future<bool> deleteNotification(String userId, String notificationId) async {
    try {
      await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      if (kDebugMode) debugPrint('✅ Notification deleted: $notificationId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to delete notification: $e');
      return false;
    }
  }

  /// Delete all notifications for user (Account-Based)
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .get();

      final batch = _db.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) debugPrint('✅ All notifications deleted for user: $userId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to delete all notifications: $e');
      return false;
    }
  }

  // === Notification Creation Methods ===

  /// Create friend request notification
  Future<void> createFriendRequestNotification({
    required String recipientId,
    required String senderId,
    required String senderNickname,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '📨 Arkadaşlık İsteği',
      message: '$senderNickname arkadaşlık isteği gönderdi',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'notificationType': 'friend_request',
        'fromUserId': senderId,
        'fromNickname': senderNickname,
      },
    );
  }

  /// Create friend request accepted notification
  Future<void> createFriendRequestAcceptedNotification({
    required String recipientId,
    required String senderId,
    required String senderNickname,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.friendRequestAccepted,
      title: '✅ Arkadaşlık İsteği Kabul Edildi',
      message: '$senderNickname arkadaşlık isteğinizi kabul etti!',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'notificationType': 'friend_request_accepted',
        'fromUserId': senderId,
        'fromNickname': senderNickname,
      },
    );
  }

  /// Create friend request rejected notification
  Future<void> createFriendRequestRejectedNotification({
    required String recipientId,
    required String senderId,
    required String senderNickname,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.friendRequestRejected,
      title: '❌ Arkadaşlık İsteği Reddedildi',
      message: '$senderNickname arkadaşlık isteğinizi reddetti.',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'notificationType': 'friend_request_rejected',
        'fromUserId': senderId,
        'fromNickname': senderNickname,
      },
    );
  }

  /// Create game invitation notification
  Future<void> createGameInvitationNotification({
    required String recipientId,
    required String senderId,
    required String senderNickname,
    required String gameType,
    String? roomCode,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.gameInvite,
      title: '🎮 Oyun Daveti',
      message: '$senderNickname sizi bir $gameType oyununa davet etti!',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'notificationType': 'game_invite',
        'gameType': gameType,
        'roomCode': roomCode,
        'fromUserId': senderId,
        'fromNickname': senderNickname,
      },
    );
  }

  /// Create duel invitation notification
  Future<void> createDuelInvitationNotification({
    required String recipientId,
    required String senderId,
    required String senderNickname,
    required String roomCode,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.gameInvite,
      title: '⚔️ Düello Daveti',
      message: '$senderNickname sizi bir düelloya davet etti! (Oda: $roomCode)',
      senderId: senderId,
      senderNickname: senderNickname,
      additionalData: {
        'notificationType': 'duel_invite',
        'roomCode': roomCode,
        'fromUserId': senderId,
        'fromNickname': senderNickname,
      },
    );
  }

  /// Create achievement unlocked notification
  Future<void> createAchievementNotification({
    required String recipientId,
    required String achievementTitle,
    required String achievementDescription,
    String? achievementIcon,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '🏆 Başarı Kazanıldı!',
      message: '$achievementTitle: $achievementDescription',
      additionalData: {
        'notificationType': 'achievement',
        'achievementTitle': achievementTitle,
        'achievementDescription': achievementDescription,
        'achievementIcon': achievementIcon,
      },
    );
  }

  /// Create reward unlocked notification
  Future<void> createRewardNotification({
    required String recipientId,
    required String rewardName,
    required String rewardDescription,
    String? rewardIcon,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '🎁 Ödül Kazanıldı!',
      message: '$rewardName: $rewardDescription',
      additionalData: {
        'notificationType': 'reward',
        'rewardName': rewardName,
        'rewardDescription': rewardDescription,
        'rewardIcon': rewardIcon,
      },
    );
  }

  /// Create level up notification
  Future<void> createLevelUpNotification({
    required String recipientId,
    required int newLevel,
    int? totalPoints,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '🎉 Seviye Atladınız!',
      message: 'Tebrikler! Artık $newLevel. seviyedesiniz${totalPoints != null ? ' ($totalPoints puan)' : ''}!',
      additionalData: {
        'notificationType': 'level_up',
        'newLevel': newLevel,
        'totalPoints': totalPoints,
      },
    );
  }

  /// Create high score notification
  Future<void> createHighScoreNotification({
    required String recipientId,
    required int newHighScore,
    String? gameType,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '🎉 Yeni Yüksek Skor!',
      message: 'Tebrikler! Yeni yüksek skorunuz: $newHighScore${gameType != null ? ' ($gameType)' : ''}!',
      additionalData: {
        'notificationType': 'high_score',
        'newHighScore': newHighScore,
        'gameType': gameType,
      },
    );
  }

  /// Create daily challenge notification
  Future<void> createDailyChallengeNotification({
    required String recipientId,
    String? challengeTitle,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '📅 Günlük Meydan Okuma!',
      message: challengeTitle ?? 'Yeni günlük meydan okumaları sizi bekliyor!',
      additionalData: {
        'notificationType': 'daily_challenge',
        'challengeTitle': challengeTitle,
      },
    );
  }

  /// Create game started notification
  Future<void> createGameStartedNotification({
    required String recipientId,
    required String gameMode,
    required List<String> playerNames,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '🚀 Oyun Başladı!',
      message: '$gameMode oyunu ${playerNames.join(', ')} ile başladı!',
      additionalData: {
        'notificationType': 'game_started',
        'gameMode': gameMode,
        'playerNames': playerNames,
      },
    );
  }

  /// Create game finished notification
  Future<void> createGameFinishedNotification({
    required String recipientId,
    required String winnerName,
    required String gameMode,
    required int score,
  }) async {
    await saveNotification(
      recipientId: recipientId,
      type: NotificationType.general,
      title: '🏆 Oyun Bitti!',
      message: '$gameMode oyununda kazanan: $winnerName (Skor: $score)',
      additionalData: {
        'notificationType': 'game_finished',
        'winnerName': winnerName,
        'gameMode': gameMode,
        'score': score,
      },
    );
  }

  // === Legacy Methods (for backward compatibility) ===

  /// Show achievement unlocked notification (legacy - debug print only)
  Future<void> showAchievementNotification(dynamic achievement) async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('🏆 Achievement Unlocked: ${achievement?.title ?? 'Unknown'}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to show achievement notification: $e');
    }
  }

  /// Show reward unlocked notification (legacy - debug print only)
  Future<void> showRewardNotification(dynamic reward) async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('🎁 Reward Unlocked: ${reward?.name ?? 'Unknown'}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to show reward notification: $e');
    }
  }

  /// Show level up notification (legacy - debug print only)
  Future<void> showLevelUpNotification(int newLevel, int totalPoints) async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('🎉 Level Up! Reached level $newLevel with $totalPoints points');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to show level up notification: $e');
    }
  }

  /// Show daily challenge notification (legacy - debug print only)
  Future<void> showDailyChallengeNotification() async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('📅 Daily challenges are ready!');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to show daily challenge notification: $e');
    }
  }

  /// Show weekly challenge notification (legacy - debug print only)
  Future<void> showWeeklyChallengeNotification() async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('📊 Weekly challenges have been updated!');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to show weekly challenge notification: $e');
    }
  }

  /// Show challenge completion notification (legacy - debug print only)
  Future<void> showChallengeCompletionNotification(
    dynamic challenge,
    bool isCompleted,
  ) async {
    if (!_isInitialized) return;

    try {
      final title = isCompleted ? '🎯 Challenge Completed!' : '⏰ Challenge Expiring!';
      final message = '${challenge?.title ?? 'Challenge'} ${isCompleted ? 'completed successfully!' : 'is about to expire!'}';
      
      if (kDebugMode) {
        debugPrint('$title: $message');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to show challenge notification: $e');
    }
  }

  /// Check if notifications are enabled (simplified)
  Future<bool> areNotificationsEnabled() async {
    return true;
  }

  /// Open app notification settings (simplified)
  Future<void> openNotificationSettings() async {
    if (kDebugMode) debugPrint('Opening notification settings');
  }

  /// Cancel specific notification (simplified)
  Future<void> cancelNotification(int id) async {
    try {
      if (kDebugMode) debugPrint('Cancelled notification with id: $id');
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications (simplified)
  Future<void> cancelAllNotifications() async {
    try {
      if (kDebugMode) debugPrint('Cancelled all notifications');
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Schedule quiz reminder notification (simplified)
  Future<void> scheduleQuizReminderNotification() async {
    if (!_isInitialized) return;
    
    try {
      if (kDebugMode) {
        debugPrint('🔔 Quiz reminder scheduled');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to schedule quiz reminder: $e');
    }
  }

  // === Static Helper Methods ===

  /// Initialize service statically
  static Future<void> initializeStatic() async {
    await NotificationService().initialize();
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isUserAuthenticated => _auth.currentUser != null;

  /// Get unread count for current user
  Future<int> getCurrentUserUnreadCount() async {
    final userId = currentUserId;
    if (userId == null) return 0;
    return getUnreadCount(userId);
  }

  /// Delete all notifications for current user
  Future<bool> deleteAllCurrentUserNotifications() async {
    final userId = currentUserId;
    if (userId == null) return false;
    return deleteAllNotifications(userId);
  }

  /// Mark all as read for current user
  Future<bool> markAllCurrentUserAsRead() async {
    final userId = currentUserId;
    if (userId == null) return false;
    return markAllAsRead(userId);
  }

  /// Listen to current user's notifications
  Stream<List<NotificationData>> listenToCurrentUserNotifications() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();
    return listenToNotifications(userId);
  }

  /// Create notification with current user as sender
  Future<void> notifyCurrentUser({
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
  }) async {
    final userId = currentUserId;
    if (userId == null) return;

    await saveNotification(
      recipientId: userId,
      type: type,
      title: title,
      message: message,
      senderId: userId,
      senderNickname: null,
      additionalData: additionalData,
    );
  }

  // === Static Helper Methods for Backward Compatibility ===
  
  static Future<void> showHighScoreNotificationStatic(int newHighScore) async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('🎉 New High Score: $newHighScore points!');
  }

  static Future<void> showFriendRequestNotificationStatic(String fromUserId, String fromNickname) async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('👥 Friend request from: $fromNickname ($fromUserId)');
  }

  static Future<void> showFriendRequestAcceptedNotificationStatic(String acceptedByNickname, String acceptedByUserId) async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('👥 Friend request accepted from: $acceptedByNickname');
  }

  static Future<void> showFriendRequestRejectedNotificationStatic(String rejectedByNickname, String rejectedByUserId) async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('❌ Friend request rejected by: $rejectedByNickname ($rejectedByUserId)');
  }

  static Future<void> scheduleQuizReminderNotificationStatic() async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('🔔 Quiz reminder scheduled');
  }

  static Future<void> showGameInvitationNotificationStatic(String inviterName, String gameType) async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('🎮 Game invitation from $inviterName for $gameType');
  }

  static Future<void> showDuelInvitationNotificationStatic(String fromNickname, String roomCode) async {
    final service = NotificationService();
    await service.initialize();
    if (kDebugMode) debugPrint('⚔️ Duel invitation from: $fromNickname (Room: $roomCode)');
  }

  // Additional static methods for new functionality
  
  static Future<void> createFriendRequestNotificationStatic({
    required String recipientId,
    required String senderId,
    required String senderNickname,
  }) async {
    final service = NotificationService();
    await service.initialize();
    await service.createFriendRequestNotification(
      recipientId: recipientId,
      senderId: senderId,
      senderNickname: senderNickname,
    );
  }

  static Future<void> createFriendRequestAcceptedNotificationStatic({
    required String recipientId,
    required String senderId,
    required String senderNickname,
  }) async {
    final service = NotificationService();
    await service.initialize();
    await service.createFriendRequestAcceptedNotification(
      recipientId: recipientId,
      senderId: senderId,
      senderNickname: senderNickname,
    );
  }

  static Future<void> createDuelInvitationNotificationStatic({
    required String recipientId,
    required String senderId,
    required String senderNickname,
    required String roomCode,
  }) async {
    final service = NotificationService();
    await service.initialize();
    await service.createDuelInvitationNotification(
      recipientId: recipientId,
      senderId: senderId,
      senderNickname: senderNickname,
      roomCode: roomCode,
    );
  }

  static Future<void> createHighScoreNotificationStatic({
    required String recipientId,
    required int newHighScore,
    String? gameType,
  }) async {
    final service = NotificationService();
    await service.initialize();
    await service.createHighScoreNotification(
      recipientId: recipientId,
      newHighScore: newHighScore,
      gameType: gameType,
    );
  }

  static Future<void> createDailyChallengeNotificationStatic({
    required String recipientId,
    String? challengeTitle,
  }) async {
    final service = NotificationService();
    await service.initialize();
    await service.createDailyChallengeNotification(
      recipientId: recipientId,
      challengeTitle: challengeTitle,
    );
  }

  static Future<void> createRewardNotificationStatic({
    required String recipientId,
    required String rewardName,
    required String rewardDescription,
    String? rewardIcon,
  }) async {
    final service = NotificationService();
    await service.initialize();
    await service.createRewardNotification(
      recipientId: recipientId,
      rewardName: rewardName,
      rewardDescription: rewardDescription,
      rewardIcon: rewardIcon,
    );
  }
}

