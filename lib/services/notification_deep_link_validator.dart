// lib/services/notification_deep_link_validator.dart
// Validate notification deep links before navigation

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'analytics_service.dart';

class NotificationDeepLinkValidator {
  static final NotificationDeepLinkValidator _instance = NotificationDeepLinkValidator._internal();
  factory NotificationDeepLinkValidator() => _instance;
  NotificationDeepLinkValidator._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validate and process deep link from notification
  Future<bool> validateAndProcessDeepLink(String link, String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔗 Validating deep link: $link');
      }

      // Parse link
      final parts = link.split('/');
      if (parts.isEmpty) {
        await _logInvalidLink(link, 'Invalid format');
        return false;
      }

      final linkType = parts[0]; // 'duel', 'friend', 'achievement', etc.

      switch (linkType) {
        case 'duel':
          return await _validateDuelLink(parts, userId);

        case 'friend':
          return await _validateFriendLink(parts, userId);

        case 'achievement':
          return await _validateAchievementLink(parts, userId);

        case 'daily':
          return await _validateDailyLink(parts, userId);

        case 'shop':
          return await _validateShopLink(parts, userId);

        default:
          await _logInvalidLink(link, 'Unknown link type: $linkType');
          return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Deep link validation error: $e');
      await AnalyticsService().logError('DeepLinkValidationError', e.toString());
      return false;
    }
  }

  /// Validate duel deep link
  Future<bool> _validateDuelLink(List<String> parts, String userId) async {
    try {
      if (parts.length < 2) {
        await _logInvalidLink('duel/${parts.join('/')}', 'Missing duel ID');
        return false;
      }

      final duelId = parts[1];

      // Check if duel exists
      final duelDoc = await _firestore.collection('duels').doc(duelId).get();

      if (!duelDoc.exists) {
        await _logInvalidLink('duel/$duelId', 'Duel not found');
        return false;
      }

      // Check if user is participant
      final duelData = duelDoc.data()!;
      final player1 = duelData['player1_id'] as String?;
      final player2 = duelData['player2_id'] as String?;

      if (userId != player1 && userId != player2) {
        await _logInvalidLink('duel/$duelId', 'User not participant');
        return false;
      }

      // Check if duel is still active
      if (duelData['status'] != 'active' && duelData['status'] != 'pending') {
        if (kDebugMode) {
          debugPrint('ℹ️ Duel no longer active: ${duelData['status']}');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('✅ Duel link validated: $duelId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Duel link validation error: $e');
      return false;
    }
  }

  /// Validate friend deep link
  Future<bool> _validateFriendLink(List<String> parts, String userId) async {
    try {
      if (parts.length < 2) {
        await _logInvalidLink('friend/${parts.join('/')}', 'Missing friend ID');
        return false;
      }

      final friendId = parts[1];

      // Check if friend exists
      final friendDoc = await _firestore.collection('users').doc(friendId).get();

      if (!friendDoc.exists) {
        await _logInvalidLink('friend/$friendId', 'Friend not found');
        return false;
      }

      if (kDebugMode) {
        debugPrint('✅ Friend link validated: $friendId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Friend link validation error: $e');
      return false;
    }
  }

  /// Validate achievement deep link
  Future<bool> _validateAchievementLink(List<String> parts, String userId) async {
    try {
      if (parts.length < 2) {
        await _logInvalidLink('achievement/${parts.join('/')}', 'Missing achievement ID');
        return false;
      }

      final achievementId = parts[1];

      // Check if achievement exists
      final achievementDoc = await _firestore.collection('achievements').doc(achievementId).get();

      if (!achievementDoc.exists) {
        await _logInvalidLink('achievement/$achievementId', 'Achievement not found');
        return false;
      }

      if (kDebugMode) {
        debugPrint('✅ Achievement link validated: $achievementId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Achievement link validation error: $e');
      return false;
    }
  }

  /// Validate daily task deep link
  Future<bool> _validateDailyLink(List<String> parts, String userId) async {
    try {
      if (parts.length < 2) {
        await _logInvalidLink('daily/${parts.join('/')}', 'Missing task ID');
        return false;
      }

      final taskId = parts[1];

      // Daily tasks are always valid (user-specific)
      if (kDebugMode) {
        debugPrint('✅ Daily link validated: $taskId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Daily link validation error: $e');
      return false;
    }
  }

  /// Validate shop deep link
  Future<bool> _validateShopLink(List<String> parts, String userId) async {
    try {
      if (parts.length < 2) {
        await _logInvalidLink('shop/${parts.join('/')}', 'Missing shop item ID');
        return false;
      }

      final itemId = parts[1];

      // Check if shop item exists
      final itemDoc = await _firestore.collection('shop_items').doc(itemId).get();

      if (!itemDoc.exists) {
        await _logInvalidLink('shop/$itemId', 'Shop item not found');
        return false;
      }

      if (kDebugMode) {
        debugPrint('✅ Shop link validated: $itemId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Shop link validation error: $e');
      return false;
    }
  }

  /// Log invalid deep link
  Future<void> _logInvalidLink(String link, String reason) async {
    if (kDebugMode) {
      debugPrint('❌ Invalid deep link: $link - $reason');
    }

    await AnalyticsService().logError('InvalidDeepLink', '$link: $reason');
  }
}
