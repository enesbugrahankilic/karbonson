// lib/services/shop_state_manager.dart
// Manage shop and loot box state to prevent duplicates and data loss

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';
import 'analytics_service.dart';

class ShopStateManager {
  static final ShopStateManager _instance = ShopStateManager._internal();
  factory ShopStateManager() => _instance;
  ShopStateManager._internal();

  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  // Track in-flight operations
  final Set<String> _inFlightTransactions = {};
  final StreamController<bool> _shopStateController = StreamController<bool>.broadcast();

  /// Initialize shop state manager
  void initialize() {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    if (kDebugMode) {
      debugPrint('✅ Shop state manager initialized');
    }
  }

  /// Purchase shop item with atomic transaction
  Future<bool> purchaseShopItem({
    required String itemId,
    required int cost,
    required String itemType, // 'box', 'power-up', 'cosmetic'
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        if (kDebugMode) debugPrint('❌ User not authenticated');
        return false;
      }

      // Check for duplicate in-flight transaction
      if (_inFlightTransactions.contains('purchase_$itemId')) {
        if (kDebugMode) debugPrint('⚠️ Purchase already in flight: $itemId');
        return false;
      }

      _inFlightTransactions.add('purchase_$itemId');

      try {
        // Atomic transaction
        final success = await _firestore.runTransaction((transaction) async {
          final userRef = _firestore.collection('users').doc(userId);
          final userDoc = await transaction.get(userRef);

          if (!userDoc.exists) {
            throw Exception('User not found');
          }

          // Get current points
          final currentPoints = (userDoc['points'] as int?) ?? 0;

          // Check sufficient points
          if (currentPoints < cost) {
            throw Exception('Insufficient points');
          }

          // Deduct points
          transaction.update(userRef, {
            'points': FieldValue.increment(-cost),
            'last_shop_purchase': FieldValue.serverTimestamp(),
          });

          // Add item to inventory
          await _firestore.collection('user_inventory').doc(userId).collection('items').add({
            'item_id': itemId,
            'item_type': itemType,
            'purchased_at': FieldValue.serverTimestamp(),
            'cost': cost,
            'is_opened': false, // For boxes
          });

          // Log purchase
          await _firestore.collection('purchase_history').add({
            'user_id': userId,
            'item_id': itemId,
            'item_type': itemType,
            'cost': cost,
            'purchased_at': FieldValue.serverTimestamp(),
          });

          return true;
        });

        if (success) {
          if (kDebugMode) {
            debugPrint('✅ Item purchased: $itemId (-$cost points)');
          }

          await AnalyticsService().logReward(
            'shop_purchase',
            amount: -cost,
            source: 'shop',
          );

          _shopStateController.add(true);
        }

        return success;
      } finally {
        _inFlightTransactions.remove('purchase_$itemId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Purchase error: $e');
      await AnalyticsService().logError('ShopPurchaseError', e.toString());
      return false;
    }
  }

  /// Open loot box with atomic state update
  Future<bool> openLootBox({
    required String boxId,
    required List<String> rewards,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Check for duplicate in-flight transaction
      if (_inFlightTransactions.contains('open_$boxId')) {
        if (kDebugMode) debugPrint('⚠️ Box open already in flight: $boxId');
        return false;
      }

      _inFlightTransactions.add('open_$boxId');

      try {
        // Atomic transaction
        final success = await _firestore.runTransaction((transaction) async {
          final boxRef = _firestore.collection('user_inventory').doc(userId).collection('items').doc(boxId);
          final boxDoc = await transaction.get(boxRef);

          if (!boxDoc.exists) {
            throw Exception('Box not found');
          }

          if (boxDoc['is_opened'] == true) {
            throw Exception('Box already opened');
          }

          // Mark box as opened
          transaction.update(boxRef, {
            'is_opened': true,
            'opened_at': FieldValue.serverTimestamp(),
            'rewards': rewards,
          });

          // Add rewards to user
          final userRef = _firestore.collection('users').doc(userId);
          transaction.update(userRef, {
            'boxes_opened': FieldValue.increment(1),
          });

          // Log box opening
          await _firestore.collection('box_opens').add({
            'user_id': userId,
            'box_id': boxId,
            'rewards': rewards,
            'opened_at': FieldValue.serverTimestamp(),
          });

          return true;
        });

        if (success) {
          if (kDebugMode) {
            debugPrint('✅ Box opened: $boxId (rewards: ${rewards.length})');
          }

          await AnalyticsService().logCustomEvent('box_opened', {
            'box_id': boxId,
            'reward_count': rewards.length,
          });

          _shopStateController.add(true);
        }

        return success;
      } finally {
        _inFlightTransactions.remove('open_$boxId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Box open error: $e');
      await AnalyticsService().logError('BoxOpenError', e.toString());
      return false;
    }
  }

  /// Get user inventory
  Future<List<Map<String, dynamic>>> getUserInventory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final query = await _firestore
          .collection('user_inventory')
          .doc(userId)
          .collection('items')
          .orderBy('purchased_at', descending: true)
          .limit(100)
          .get();

      return query.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error fetching inventory: $e');
      return [];
    }
  }

  /// Get unopened boxes count
  Future<int> getUnoopenedBoxesCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final query = await _firestore
          .collection('user_inventory')
          .doc(userId)
          .collection('items')
          .where('item_type', isEqualTo: 'box')
          .where('is_opened', isEqualTo: false)
          .count()
          .get();

      return query.count ?? 0;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error counting boxes: $e');
      return 0;
    }
  }

  /// Check if user can afford item
  Future<bool> canAffordItem(int cost) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return false;

      final points = (userDoc['points'] as int?) ?? 0;
      return points >= cost;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error checking affordability: $e');
      return false;
    }
  }

  /// Get shop state stream
  Stream<bool> getShopStateStream() => _shopStateController.stream;

  /// Get in-flight transaction count
  int getInFlightCount() => _inFlightTransactions.length;

  /// Dispose
  void dispose() {
    _inFlightTransactions.clear();
    _shopStateController.close();
  }
}
