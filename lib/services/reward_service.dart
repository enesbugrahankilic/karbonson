// lib/services/reward_service.dart
// Service for managing reward items (avatars, themes, features)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reward_item.dart';
import '../models/user_progress.dart';

/// Service for managing reward items and user inventory
class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers
  final StreamController<UserRewardInventory> _inventoryController =
      StreamController.broadcast();

  // Getters for streams
  Stream<UserRewardInventory> get inventoryStream => _inventoryController.stream;

  // All available reward items
  final List<RewardItem> _allRewardItems = [
    // Avatar Rewards
    RewardItem(
      id: 'star_avatar',
      name: 'Yıldız Avatar',
      description: 'Parlayan yıldızlar ile süslenmiş özel avatar',
      icon: '⭐',
      type: RewardItemType.avatar,
      rarity: RewardItemRarity.rare,
      unlockRequirement: 5, // 5 rozet kazan
      assetPath: 'assets/avatars/star_avatar.svg',
    ),
    RewardItem(
      id: 'crown_avatar',
      name: 'Prens Avatar',
      description: 'Altın taçlı kraliyet avatarı',
      icon: '👑',
      type: RewardItemType.avatar,
      rarity: RewardItemRarity.epic,
      unlockRequirement: 10, // 10 rozet kazan
      assetPath: 'assets/avatars/crown_avatar.svg',
    ),
    RewardItem(
      id: 'mask_avatar',
      name: 'Gizem Maskesi',
      description: 'Büyülü maske takmış gizemli avatar',
      icon: '🎭',
      type: RewardItemType.avatar,
      rarity: RewardItemRarity.legendary,
      unlockRequirement: 15, // 15 rozet kazan (her kategoriden en az 1)
      assetPath: 'assets/avatars/mask_avatar.svg',
    ),
    RewardItem(
      id: 'fire_avatar',
      name: 'Ateş Savaşçısı',
      description: 'Alevlerle çevrili savaşçı avatarı',
      icon: '🔥',
      type: RewardItemType.avatar,
      rarity: RewardItemRarity.rare,
      unlockRequirement: 7, // 7 gün üst üste oyna
      assetPath: 'assets/avatars/fire_avatar.svg',
    ),
    RewardItem(
      id: 'ocean_avatar',
      name: 'Okyanus Ruhu',
      description: 'Dalgalar ve deniz yaratıkları ile avatar',
      icon: '🌊',
      type: RewardItemType.avatar,
      rarity: RewardItemRarity.epic,
      unlockRequirement: 20, // 20 düello kazan
      assetPath: 'assets/avatars/ocean_avatar.svg',
    ),

    // Theme Rewards
    RewardItem(
      id: 'night_theme',
      name: 'Gece Modu',
      description: 'Koyu renkli, göz dostu gece teması',
      icon: '🌙',
      type: RewardItemType.theme,
      rarity: RewardItemRarity.common,
      unlockRequirement: 3, // 3 rozet kazan
      assetPath: 'assets/themes/night_theme.json',
    ),
    RewardItem(
      id: 'rainbow_theme',
      name: 'Gökkuşağı',
      description: 'Renkli ve canlı gökkuşağı teması',
      icon: '🌈',
      type: RewardItemType.theme,
      rarity: RewardItemRarity.rare,
      unlockRequirement: 5, // 5 farklı kategoriden rozet
      assetPath: 'assets/themes/rainbow_theme.json',
    ),
    RewardItem(
      id: 'golden_theme',
      name: 'Altın Tema',
      description: 'Lüks altın rengi tema',
      icon: '✨',
      type: RewardItemType.theme,
      rarity: RewardItemRarity.legendary,
      unlockRequirement: 1, // 1 efsanevi rozet
      assetPath: 'assets/themes/golden_theme.json',
    ),
    RewardItem(
      id: 'nature_theme',
      name: 'Doğa',
      description: 'Yeşilliklerle dolu doğa teması',
      icon: '🌿',
      type: RewardItemType.theme,
      rarity: RewardItemRarity.epic,
      unlockRequirement: 25, // 25 quiz tamamla
      assetPath: 'assets/themes/nature_theme.json',
    ),
    RewardItem(
      id: 'space_theme',
      name: 'Uzay',
      description: 'Yıldızlar ve gezegenlerle uzay teması',
      icon: '🚀',
      type: RewardItemType.theme,
      rarity: RewardItemRarity.rare,
      unlockRequirement: 15, // 15 arkadaş ekle
      assetPath: 'assets/themes/space_theme.json',
    ),

    // Feature Rewards
    RewardItem(
      id: 'hint_system',
      name: 'İpucu Sistemi',
      description: 'Zor sorular için ipucu alabilme',
      icon: '💡',
      type: RewardItemType.feature,
      rarity: RewardItemRarity.common,
      unlockRequirement: 10, // 10 quiz tamamla
      properties: {'hintUsageLimit': 3}, // Günlük 3 ipucu
    ),
    RewardItem(
      id: 'time_extension',
      name: 'Süre Uzatma',
      description: 'Quizlerde ek süre kazanma',
      icon: '⏰',
      type: RewardItemType.feature,
      rarity: RewardItemRarity.rare,
      unlockRequirement: 3, // 3 destansı rozet
      properties: {'extraTimeSeconds': 30}, // 30 saniye ek süre
    ),
    RewardItem(
      id: 'protection_shield',
      name: 'Koruma Kalkanı',
      description: 'Yanlış cevap koruması',
      icon: '🛡️',
      type: RewardItemType.feature,
      rarity: RewardItemRarity.epic,
      unlockRequirement: 1, // 1 efsanevi rozet
      properties: {'shieldUsageLimit': 1}, // Quiz başına 1 koruma
    ),
    RewardItem(
      id: 'double_points',
      name: 'Çift Puan',
      description: 'Rozet kazanırken 2x puan',
      icon: '💎',
      type: RewardItemType.feature,
      rarity: RewardItemRarity.legendary,
      unlockRequirement: 50, // 50 toplam puan
      properties: {'multiplier': 2.0}, // 2x puan çarpanı
    ),
    RewardItem(
      id: 'priority_queue',
      name: 'Öncelik Sırası',
      description: 'Düello kuyruğunda öncelik',
      icon: '⚡',
      type: RewardItemType.feature,
      rarity: RewardItemRarity.rare,
      unlockRequirement: 10, // 10 düello kazan
      properties: {'queuePriority': 'high'}, // Yüksek öncelik
    ),
  ];

  /// Initialize service for current user
  Future<void> initializeForUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _loadUserInventory(userId);
      if (kDebugMode) debugPrint('RewardService initialized for user: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize RewardService: $e');
    }
  }

  /// Load user inventory from Firestore
  Future<void> _loadUserInventory(String userId) async {
    try {
      final doc =
          await _firestore.collection('user_rewards').doc(userId).get();

      if (doc.exists) {
        final inventory = UserRewardInventory.fromJson(doc.data()!);
        _inventoryController.add(inventory);
      } else {
        // Create initial inventory
        final initialInventory = UserRewardInventory(
          userId: userId,
          unlockedAvatarIds: [],
          unlockedThemeIds: [],
          unlockedFeatureIds: [],
          lastUpdated: DateTime.now(),
        );

        await _firestore
            .collection('user_rewards')
            .doc(userId)
            .set(initialInventory.toJson());
        _inventoryController.add(initialInventory);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user inventory: $e');
    }
  }

  /// Check if user can unlock reward item
  Future<bool> canUnlockReward(String rewardId, UserProgress progress) async {
    final rewardItem = getRewardItemById(rewardId);
    if (rewardItem == null) return false;

    // Check if already unlocked
    final inventory = await getCurrentInventory();
    if (rewardItem.type == RewardItemType.avatar &&
        inventory.hasAvatarUnlocked(rewardId)) {
      return false;
    }
    if (rewardItem.type == RewardItemType.theme &&
        inventory.hasThemeUnlocked(rewardId)) {
      return false;
    }
    if (rewardItem.type == RewardItemType.feature &&
        inventory.hasFeatureUnlocked(rewardId)) {
      return false;
    }

    // Check requirement based on reward type
    switch (rewardItem.type) {
      case RewardItemType.avatar:
        // Avatar unlocked by achievement count
        return progress.achievements.length >= rewardItem.unlockRequirement;
      case RewardItemType.theme:
        // Theme unlocked by achievement count
        return progress.achievements.length >= rewardItem.unlockRequirement;
      case RewardItemType.feature:
        // Feature unlocked by total points
        return progress.totalPoints >= rewardItem.unlockRequirement;
    }
  }

  /// Unlock reward item for user
  Future<bool> unlockReward(String rewardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final rewardItem = getRewardItemById(rewardId);
      if (rewardItem == null) return false;

      // Get current inventory
      final inventory = await getCurrentInventory();

      // Check if already unlocked
      bool alreadyUnlocked = false;
      switch (rewardItem.type) {
        case RewardItemType.avatar:
          alreadyUnlocked = inventory.hasAvatarUnlocked(rewardId);
          break;
        case RewardItemType.theme:
          alreadyUnlocked = inventory.hasThemeUnlocked(rewardId);
          break;
        case RewardItemType.feature:
          alreadyUnlocked = inventory.hasFeatureUnlocked(rewardId);
          break;
      }

      if (alreadyUnlocked) return false;

      // Add to appropriate unlocked list
      final updatedInventory = _addRewardToInventory(inventory, rewardItem);

      // Update Firestore
      await _firestore
          .collection('user_rewards')
          .doc(userId)
          .update(updatedInventory.toJson());

      // Update stream
      _inventoryController.add(updatedInventory);

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to unlock reward: $e');
      return false;
    }
  }

  /// Add reward to inventory
  UserRewardInventory _addRewardToInventory(
      UserRewardInventory inventory, RewardItem rewardItem) {
    switch (rewardItem.type) {
      case RewardItemType.avatar:
        final updatedAvatars = [...inventory.unlockedAvatarIds, rewardItem.id];
        return inventory.copyWith(
          unlockedAvatarIds: updatedAvatars,
          currentAvatarId: inventory.currentAvatarId ?? rewardItem.id,
          lastUpdated: DateTime.now(),
        );
      case RewardItemType.theme:
        final updatedThemes = [...inventory.unlockedThemeIds, rewardItem.id];
        return inventory.copyWith(
          unlockedThemeIds: updatedThemes,
          currentThemeId: inventory.currentThemeId ?? rewardItem.id,
          lastUpdated: DateTime.now(),
        );
      case RewardItemType.feature:
        final updatedFeatures = [...inventory.unlockedFeatureIds, rewardItem.id];
        return inventory.copyWith(
          unlockedFeatureIds: updatedFeatures,
          lastUpdated: DateTime.now(),
        );
    }
  }

  /// Set current avatar
  Future<bool> setCurrentAvatar(String avatarId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final inventory = await getCurrentInventory();
      if (!inventory.hasAvatarUnlocked(avatarId)) return false;

      final updatedInventory = inventory.copyWith(
        currentAvatarId: avatarId,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('user_rewards')
          .doc(userId)
          .update(updatedInventory.toJson());

      _inventoryController.add(updatedInventory);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to set current avatar: $e');
      return false;
    }
  }

  /// Set current theme
  Future<bool> setCurrentTheme(String themeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final inventory = await getCurrentInventory();
      if (!inventory.hasThemeUnlocked(themeId)) return false;

      final updatedInventory = inventory.copyWith(
        currentThemeId: themeId,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('user_rewards')
          .doc(userId)
          .update(updatedInventory.toJson());

      _inventoryController.add(updatedInventory);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to set current theme: $e');
      return false;
    }
  }

  /// Get all available reward items
  List<RewardItem> getAllRewardItems() => _allRewardItems;

  /// Get reward items by type
  List<RewardItem> getRewardItemsByType(RewardItemType type) {
    return _allRewardItems
        .where((item) => item.type == type)
        .toList();
  }

  /// Get reward item by ID
  RewardItem? getRewardItemById(String id) {
    try {
      return _allRewardItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get current user inventory
  Future<UserRewardInventory> getCurrentInventory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc =
          await _firestore.collection('user_rewards').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Inventory not found');
      }
      return UserRewardInventory.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get current inventory: $e');
      rethrow;
    }
  }

  /// Get available rewards for user based on progress
  Future<List<RewardItem>> getAvailableRewards(UserProgress progress) async {
    final availableRewards = <RewardItem>[];

    for (final reward in _allRewardItems) {
      if (await canUnlockReward(reward.id, progress)) {
        availableRewards.add(reward);
      }
    }

    return availableRewards;
  }

  /// Check if user has specific feature unlocked
  Future<bool> hasFeatureUnlocked(String featureId) async {
    try {
      final inventory = await getCurrentInventory();
      return inventory.hasFeatureUnlocked(featureId);
    } catch (e) {
      return false;
    }
  }

  /// Get feature properties
  Map<String, dynamic>? getFeatureProperties(String featureId) {
    final rewardItem = getRewardItemById(featureId);
    if (rewardItem?.type == RewardItemType.feature) {
      return rewardItem?.properties;
    }
    return null;
  }

  /// Clean up resources
  void dispose() {
    _inventoryController.close();
  }
}