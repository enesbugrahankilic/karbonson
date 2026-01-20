// lib/services/loot_box_service.dart
// Loot Box Service - Ana Servis Dosyası

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/loot_box.dart';
import '../models/loot_box_reward.dart';
import '../models/reward_models.dart';
import '../services/enhanced_reward_service.dart';
import '../services/reward_service.dart';

/// Loot Box Service - Ana servis sınıfı
class LootBoxService {
  static final LootBoxService _instance = LootBoxService._internal();
  factory LootBoxService() => _instance;
  LootBoxService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EnhancedRewardService _enhancedRewardService = EnhancedRewardService();
  final RewardService _rewardService = RewardService();

  // Stream controllers
  final StreamController<UserLootBoxInventory> _inventoryController =
      StreamController.broadcast();
  final StreamController<List<UserLootBox>> _unopenedBoxesController =
      StreamController.broadcast();
  final StreamController<OpenedReward?> _rewardRevealedController =
      StreamController.broadcast();

  // Getters for streams
  Stream<UserLootBoxInventory> get inventoryStream => _inventoryController.stream;
  Stream<List<UserLootBox>> get unopenedBoxesStream => _unopenedBoxesController.stream;
  Stream<OpenedReward?> get rewardRevealedStream => _rewardRevealedController.stream;

  // Random number generator
  final Random _random = Random();

  // ==================== İLKİLENDİRME ====================

  /// Servisi kullanıcı için başlat
  Future<void> initializeForUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _loadUserInventory(userId);
      await _loadUnopenedBoxes(userId);
      if (kDebugMode) debugPrint('LootBoxService initialized for user: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize LootBoxService: $e');
    }
  }

  /// Kullanıcı envanterini yükle
  Future<void> _loadUserInventory(String userId) async {
    try {
      final doc = await _firestore.collection('user_lootbox_inventory').doc(userId).get();

      if (doc.exists) {
        final inventory = UserLootBoxInventory.fromJson(doc.data()!);
        _inventoryController.add(inventory);
      } else {
        final initialInventory = UserLootBoxInventory(
          userId: userId,
          ownedBoxIds: [],
          unopenedBoxes: [],
          totalOpened: 0,
          totalCommonOpened: 0,
          totalRareOpened: 0,
          totalEpicOpened: 0,
          totalLegendaryOpened: 0,
          totalMythicOpened: 0,
          lastUpdated: DateTime.now(),
        );

        await _firestore
            .collection('user_lootbox_inventory')
            .doc(userId)
            .set(initialInventory.toJson());
        _inventoryController.add(initialInventory);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user inventory: $e');
    }
  }

  /// Açılmamış kutuları yükle
  Future<void> _loadUnopenedBoxes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_loot_boxes')
          .doc(userId)
          .collection('boxes')
          .where('isOpened', isEqualTo: false)
          .get();

      final boxes = snapshot.docs
          .map((doc) => UserLootBox.fromJson(doc.data()))
          .where((box) => !box.isExpired)
          .toList();

      _unopenedBoxesController.add(boxes);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load unopened boxes: $e');
    }
  }

  // ==================== KUTU VERME ====================

  /// Kullanıcıya loot box ver
  Future<bool> grantLootBox({
    required LootBoxType boxType,
    required LootBoxRarity rarity,
    String? sourceDescription,
    String? sourceEvent,
    DateTime? expiresAt,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final boxId = 'lootbox_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final userBox = UserLootBox(
        id: boxId,
        userId: userId,
        lootBoxId: _getBoxIdForType(boxType),
        boxType: boxType,
        rarity: rarity,
        obtainedAt: DateTime.now(),
        expiresAt: expiresAt,
        sourceDescription: sourceDescription,
        isOpened: false,
      );

      await _firestore
          .collection('user_loot_boxes')
          .doc(userId)
          .collection('boxes')
          .doc(boxId)
          .set(userBox.toJson());

      await _updateInventoryAfterGrant(userId, boxType);

      await _loadUnopenedBoxes(userId);
      await _loadUserInventory(userId);

      if (kDebugMode) debugPrint('Granted $rarity $boxType box to user $userId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to grant loot box: $e');
      return false;
    }
  }

  String _getBoxIdForType(LootBoxType type) {
    switch (type) {
      case LootBoxType.quiz: return 'box_quiz';
      case LootBoxType.daily: return 'box_daily';
      case LootBoxType.achievement: return 'box_achievement';
      case LootBoxType.challenge: return 'box_challenge';
      case LootBoxType.returnReward: return 'box_return';
      case LootBoxType.seasonal: return 'box_seasonal';
      case LootBoxType.login: return 'box_login';
      case LootBoxType.special: return 'box_special';
      case LootBoxType.premium: return 'box_premium';
    }
  }

  Future<void> _updateInventoryAfterGrant(String userId, LootBoxType boxType) async {
    try {
      final doc = await _firestore.collection('user_lootbox_inventory').doc(userId).get();
      if (!doc.exists) return;

      final inventory = UserLootBoxInventory.fromJson(doc.data()!);
      final updatedInventory = inventory.copyWith(
        ownedBoxIds: [...inventory.ownedBoxIds, _getBoxIdForType(boxType)],
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('user_lootbox_inventory')
          .doc(userId)
          .update(updatedInventory.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update inventory: $e');
    }
  }

  // ==================== KUTU AÇMA ====================

  Future<LootBoxOpenResult> openLootBox(String boxId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return LootBoxOpenResult.failure('Kullanıcı giriş yapmamış');
    }

    try {
      final boxDoc = await _firestore
          .collection('user_loot_boxes')
          .doc(userId)
          .collection('boxes')
          .doc(boxId)
          .get();

      if (!boxDoc.exists) {
        return LootBoxOpenResult.failure('Kutu bulunamadı');
      }

      final userBox = UserLootBox.fromJson(boxDoc.data()!);

      if (userBox.isOpened) {
        return LootBoxOpenResult.failure('Kutu zaten açılmış');
      }

      if (userBox.isExpired) {
        return LootBoxOpenResult.failure('Kutunun süresi dolmuş');
      }

      final reward = _selectRandomReward(userBox.rarity);
      final openedReward = await _awardReward(userBox, reward);

      final updatedBox = userBox.copyWith(
        isOpened: true,
        openedAt: DateTime.now(),
        openedRewardId: reward.id,
      );

      await _firestore
          .collection('user_loot_boxes')
          .doc(userId)
          .collection('boxes')
          .doc(boxId)
          .update(updatedBox.toJson());

      await _updateStatisticsAfterOpen(userId, userBox.rarity);

      await _loadUnopenedBoxes(userId);
      await _loadUserInventory(userId);

      if (kDebugMode) debugPrint('Opened box $boxId, got ${reward.name}');

      return LootBoxOpenResult.success(
        openedBox: updatedBox,
        rewards: [openedReward],
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to open loot box: $e');
      return LootBoxOpenResult.failure('Kutu açılamadı: $e');
    }
  }

  LootBoxReward _selectRandomReward(LootBoxRarity rarity) {
    final pool = _getDefaultRewardPool();
    List<LootBoxReward> rewards;

    switch (rarity) {
      case LootBoxRarity.common: rewards = pool.commonRewards; break;
      case LootBoxRarity.rare: rewards = pool.rareRewards; break;
      case LootBoxRarity.epic: rewards = pool.epicRewards; break;
      case LootBoxRarity.legendary: rewards = pool.legendaryRewards; break;
      case LootBoxRarity.mythic: rewards = pool.mythicRewards; break;
    }

    if (rewards.isEmpty) {
      return LootBoxReward(
        id: 'fallback_points',
        name: '25 KP',
        description: '25 Karbon Puanı',
        icon: '💰',
        contentType: LootBoxContentType.points,
        rarity: rarity,
        amount: 25,
      );
    }

    final totalWeight = rewards.fold(0.0, (sum, r) => sum + r.dropWeight);
    double randomValue = _random.nextDouble() * totalWeight;

    for (final reward in rewards) {
      randomValue -= reward.dropWeight;
      if (randomValue <= 0) return reward;
    }

    return rewards.first;
  }

  LootBoxPool _getDefaultRewardPool() {
    return LootBoxPool(
      id: 'default_pool',
      name: 'Varsayılan Havuz',
      boxType: LootBoxType.quiz,
      commonRewards: [
        LootBoxReward(id: 'points_10', name: '10 KP', description: '10 Karbon Puanı',
          icon: '💰', contentType: LootBoxContentType.points, rarity: LootBoxRarity.common, amount: 10, dropWeight: 30),
        LootBoxReward(id: 'points_20', name: '20 KP', description: '20 Karbon Puanı',
          icon: '💰', contentType: LootBoxContentType.points, rarity: LootBoxRarity.common, amount: 20, dropWeight: 25),
        LootBoxReward(id: 'hint_token', name: 'İpucu Jetonu', description: 'Zor sorular için ipucu hakkı',
          icon: '💡', contentType: LootBoxContentType.feature, rarity: LootBoxRarity.common, rewardId: 'hint_system', dropWeight: 15),
      ],
      rareRewards: [
        LootBoxReward(id: 'points_50', name: '50 KP', description: '50 Karbon Puanı',
          icon: '💰', contentType: LootBoxContentType.points, rarity: LootBoxRarity.rare, amount: 50, dropWeight: 20),
        LootBoxReward(id: 'points_75', name: '75 KP', description: '75 Karbon Puanı',
          icon: '💰', contentType: LootBoxContentType.points, rarity: LootBoxRarity.rare, amount: 75, dropWeight: 15),
      ],
      epicRewards: [
        LootBoxReward(id: 'points_100', name: '100 KP', description: '100 Karbon Puanı',
          icon: '💰', contentType: LootBoxContentType.points, rarity: LootBoxRarity.epic, amount: 100, dropWeight: 10),
        LootBoxReward(id: 'avatar_fire', name: 'Ateş Savaşçısı', description: 'Alevlerle çevrili savaşçı avatarı',
          icon: '🔥', contentType: LootBoxContentType.avatar, rarity: LootBoxRarity.epic, rewardId: 'fire_avatar', dropWeight: 5, isDuplicateAllowed: false),
      ],
      legendaryRewards: [
        LootBoxReward(id: 'avatar_star', name: 'Yıldız Avatar', description: 'Parlayan yıldızlar ile süslenmiş özel avatar',
          icon: '⭐', contentType: LootBoxContentType.avatar, rarity: LootBoxRarity.legendary, rewardId: 'star_avatar', dropWeight: 3, isDuplicateAllowed: false),
        LootBoxReward(id: 'theme_night', name: 'Gece Modu', description: 'Koyu renkli gece teması',
          icon: '🌙', contentType: LootBoxContentType.theme, rarity: LootBoxRarity.legendary, rewardId: 'night_theme', dropWeight: 2, isDuplicateAllowed: false),
      ],
      mythicRewards: [
        LootBoxReward(id: 'avatar_mask', name: 'Gizem Maskesi', description: 'Büyülü maske takmış gizemli avatar',
          icon: '🎭', contentType: LootBoxContentType.avatar, rarity: LootBoxRarity.mythic, rewardId: 'mask_avatar', dropWeight: 1, isDuplicateAllowed: false),
      ],
      rarityWeights: const {
        LootBoxRarity.common: 60,
        LootBoxRarity.rare: 25,
        LootBoxRarity.epic: 10,
        LootBoxRarity.legendary: 4,
        LootBoxRarity.mythic: 1,
      },
    );
  }

  Future<OpenedReward> _awardReward(UserLootBox box, LootBoxReward reward) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    bool isNew = true;
    bool isDuplicate = false;

    if (reward.rewardId != null && !reward.isDuplicateAllowed) {
      isNew = await _checkIfRewardIsNew(reward.rewardId!);
      if (!isNew) isDuplicate = true;
    }

    if (reward.contentType == LootBoxContentType.points) {
      await _enhancedRewardService.addPoints(
        amount: reward.amount,
        type: PointTransactionType.achievement,
        description: 'Loot Box ödülü: ${reward.name}',
        relatedId: reward.id,
      );
    }

    if (reward.rewardId != null) {
      await _rewardService.unlockReward(reward.rewardId!);
    }

    final openedReward = OpenedReward(
      id: 'opened_${box.id}_${DateTime.now().millisecondsSinceEpoch}',
      lootBoxId: box.id,
      reward: reward,
      openedAt: DateTime.now(),
      isNew: isNew,
      isDuplicate: isDuplicate,
    );

    _rewardRevealedController.add(openedReward);
    return openedReward;
  }

  Future<bool> _checkIfRewardIsNew(String rewardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return true;

    try {
      final inventory = await _rewardService.getCurrentInventory();
      
      if (rewardId.contains('avatar')) {
        return !inventory.unlockedAvatarIds.contains(rewardId);
      } else if (rewardId.contains('theme')) {
        return !inventory.unlockedThemeIds.contains(rewardId);
      } else if (rewardId.contains('feature')) {
        return !inventory.unlockedFeatureIds.contains(rewardId);
      }
      
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _updateStatisticsAfterOpen(String userId, LootBoxRarity rarity) async {
    try {
      final doc = await _firestore.collection('user_lootbox_inventory').doc(userId).get();
      if (!doc.exists) return;

      final inventory = UserLootBoxInventory.fromJson(doc.data()!);
      
      final updatedInventory = switch (rarity) {
        LootBoxRarity.common => inventory.copyWith(
          totalOpened: inventory.totalOpened + 1,
          totalCommonOpened: inventory.totalCommonOpened + 1,
          lastUpdated: DateTime.now(),
        ),
        LootBoxRarity.rare => inventory.copyWith(
          totalOpened: inventory.totalOpened + 1,
          totalRareOpened: inventory.totalRareOpened + 1,
          lastUpdated: DateTime.now(),
        ),
        LootBoxRarity.epic => inventory.copyWith(
          totalOpened: inventory.totalOpened + 1,
          totalEpicOpened: inventory.totalEpicOpened + 1,
          lastUpdated: DateTime.now(),
        ),
        LootBoxRarity.legendary => inventory.copyWith(
          totalOpened: inventory.totalOpened + 1,
          totalLegendaryOpened: inventory.totalLegendaryOpened + 1,
          lastUpdated: DateTime.now(),
        ),
        LootBoxRarity.mythic => inventory.copyWith(
          totalOpened: inventory.totalOpened + 1,
          totalMythicOpened: inventory.totalMythicOpened + 1,
          lastUpdated: DateTime.now(),
        ),
      };

      await _firestore
          .collection('user_lootbox_inventory')
          .doc(userId)
          .update(updatedInventory.toJson());
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update statistics: $e');
    }
  }

  // ==================== ENTEGRASYON METOTLARI ====================

  Future<void> onQuizCompleted({required int score, required bool isPerfect, int? timeSpent}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final rand = _random.nextDouble();
    LootBoxRarity rarity;
    
    if (rand < 0.60) rarity = LootBoxRarity.common;
    else if (rand < 0.85) rarity = LootBoxRarity.rare;
    else if (rand < 0.95) rarity = LootBoxRarity.epic;
    else if (rand < 0.99) rarity = LootBoxRarity.legendary;
    else rarity = LootBoxRarity.mythic;

    await grantLootBox(
      boxType: LootBoxType.quiz,
      rarity: rarity,
      sourceDescription: 'Quiz tamamlama ödülü',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  Future<bool> onDailyLogin() async {
    return await grantLootBox(
      boxType: LootBoxType.daily,
      rarity: LootBoxRarity.common,
      sourceDescription: 'Günlük giriş ödülü',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<void> onAchievementUnlocked(String achievementName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final rand = _random.nextDouble();
    LootBoxRarity rarity;

    if (rand < 0.40) rarity = LootBoxRarity.common;
    else if (rand < 0.70) rarity = LootBoxRarity.rare;
    else if (rand < 0.90) rarity = LootBoxRarity.epic;
    else if (rand < 0.98) rarity = LootBoxRarity.legendary;
    else rarity = LootBoxRarity.mythic;

    await grantLootBox(
      boxType: LootBoxType.achievement,
      rarity: rarity,
      sourceDescription: '"$achievementName" başarı ödülü',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  Future<bool> onUserReturn({required int daysSinceLastLogin}) async {
    LootBoxRarity rarity;
    
    if (daysSinceLastLogin < 7) rarity = LootBoxRarity.common;
    else if (daysSinceLastLogin < 14) rarity = LootBoxRarity.rare;
    else if (daysSinceLastLogin < 30) rarity = LootBoxRarity.epic;
    else if (daysSinceLastLogin < 60) rarity = LootBoxRarity.legendary;
    else rarity = LootBoxRarity.mythic;

    return await grantLootBox(
      boxType: LootBoxType.returnReward,
      rarity: rarity,
      sourceDescription: 'Geri dönüş ödülü - $daysSinceLastLogin gün sonra',
      expiresAt: DateTime.now().add(const Duration(days: 14)),
    );
  }

  Future<List<UserLootBox>> getUnopenedBoxes() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('user_loot_boxes')
        .doc(userId)
        .collection('boxes')
        .where('isOpened', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => UserLootBox.fromJson(doc.data()))
        .where((box) => !box.isExpired)
        .toList();
  }

  Future<UserLootBoxInventory?> getUserInventory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('user_lootbox_inventory').doc(userId).get();
      if (!doc.exists) return null;
      return UserLootBoxInventory.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get inventory: $e');
      return null;
    }
  }

  void dispose() {
    _inventoryController.close();
    _unopenedBoxesController.close();
    _rewardRevealedController.close();
  }
}
