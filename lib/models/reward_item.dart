// lib/models/reward_item.dart
// Reward items model for avatar, theme, and special features

import 'package:equatable/equatable.dart';

/// Reward item types
enum RewardItemType {
  avatar,
  theme,
  feature,
}

/// Reward item rarity
enum RewardItemRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Reward item model
class RewardItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final RewardItemType type;
  final RewardItemRarity rarity;
  final int unlockRequirement; // Points or achievement count required
  final String? assetPath; // Path to avatar image or theme file
  final Map<String, dynamic>? properties; // Additional properties for the item
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.unlockRequirement,
    this.assetPath,
    this.properties,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Create reward item from JSON
  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: RewardItemType.values[json['type'] as int],
      rarity: RewardItemRarity.values[json['rarity'] as int],
      unlockRequirement: json['unlockRequirement'] as int,
      assetPath: json['assetPath'] as String?,
      properties: json['properties'] as Map<String, dynamic>?,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int)
          : null,
    );
  }

  /// Convert reward item to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type.index,
      'rarity': rarity.index,
      'unlockRequirement': unlockRequirement,
      'assetPath': assetPath,
      'properties': properties,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  /// Get rarity color
  String get rarityColor {
    switch (rarity) {
      case RewardItemRarity.common:
        return '#8B8B8B'; // Gray
      case RewardItemRarity.rare:
        return '#4A90E2'; // Blue
      case RewardItemRarity.epic:
        return '#9B59B6'; // Purple
      case RewardItemRarity.legendary:
        return '#F39C12'; // Orange
    }
  }

  /// Get rarity name in Turkish
  String get rarityName {
    switch (rarity) {
      case RewardItemRarity.common:
        return 'Sıradan';
      case RewardItemRarity.rare:
        return 'Nadir';
      case RewardItemRarity.epic:
        return 'Destansı';
      case RewardItemRarity.legendary:
        return 'Efsanevi';
    }
  }

  /// Get type name in Turkish
  String get typeName {
    switch (type) {
      case RewardItemType.avatar:
        return 'Avatar';
      case RewardItemType.theme:
        return 'Tema';
      case RewardItemType.feature:
        return 'Özellik';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        type,
        rarity,
        unlockRequirement,
        assetPath,
        properties,
        isUnlocked,
        unlockedAt,
      ];

  /// Copy with method
  RewardItem copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    RewardItemType? type,
    RewardItemRarity? rarity,
    int? unlockRequirement,
    String? assetPath,
    Map<String, dynamic>? properties,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return RewardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      unlockRequirement: unlockRequirement ?? this.unlockRequirement,
      assetPath: assetPath ?? this.assetPath,
      properties: properties ?? this.properties,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// User's unlocked reward items
class UserRewardInventory extends Equatable {
  final String userId;
  final List<String> unlockedAvatarIds;
  final List<String> unlockedThemeIds;
  final List<String> unlockedFeatureIds;
  final String? currentAvatarId;
  final String? currentThemeId;
  final DateTime lastUpdated;

  const UserRewardInventory({
    required this.userId,
    required this.unlockedAvatarIds,
    required this.unlockedThemeIds,
    required this.unlockedFeatureIds,
    this.currentAvatarId,
    this.currentThemeId,
    required this.lastUpdated,
  });

  /// Create inventory from JSON
  factory UserRewardInventory.fromJson(Map<String, dynamic> json) {
    return UserRewardInventory(
      userId: json['userId'] as String,
      unlockedAvatarIds: List<String>.from(json['unlockedAvatarIds'] as List),
      unlockedThemeIds: List<String>.from(json['unlockedThemeIds'] as List),
      unlockedFeatureIds: List<String>.from(json['unlockedFeatureIds'] as List),
      currentAvatarId: json['currentAvatarId'] as String?,
      currentThemeId: json['currentThemeId'] as String?,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['lastUpdated'] as int,
      ),
    );
  }

  /// Convert inventory to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'unlockedAvatarIds': unlockedAvatarIds,
      'unlockedThemeIds': unlockedThemeIds,
      'unlockedFeatureIds': unlockedFeatureIds,
      'currentAvatarId': currentAvatarId,
      'currentThemeId': currentThemeId,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  /// Check if user has avatar unlocked
  bool hasAvatarUnlocked(String avatarId) {
    return unlockedAvatarIds.contains(avatarId);
  }

  /// Check if user has theme unlocked
  bool hasThemeUnlocked(String themeId) {
    return unlockedThemeIds.contains(themeId);
  }

  /// Check if user has feature unlocked
  bool hasFeatureUnlocked(String featureId) {
    return unlockedFeatureIds.contains(featureId);
  }

  /// Get total unlocked items count
  int get totalUnlockedItems {
    return unlockedAvatarIds.length +
        unlockedThemeIds.length +
        unlockedFeatureIds.length;
  }

  @override
  List<Object?> get props => [
        userId,
        unlockedAvatarIds,
        unlockedThemeIds,
        unlockedFeatureIds,
        currentAvatarId,
        currentThemeId,
        lastUpdated,
      ];

  /// Copy with method
  UserRewardInventory copyWith({
    String? userId,
    List<String>? unlockedAvatarIds,
    List<String>? unlockedThemeIds,
    List<String>? unlockedFeatureIds,
    String? currentAvatarId,
    String? currentThemeId,
    DateTime? lastUpdated,
  }) {
    return UserRewardInventory(
      userId: userId ?? this.userId,
      unlockedAvatarIds: unlockedAvatarIds ?? this.unlockedAvatarIds,
      unlockedThemeIds: unlockedThemeIds ?? this.unlockedThemeIds,
      unlockedFeatureIds: unlockedFeatureIds ?? this.unlockedFeatureIds,
      currentAvatarId: currentAvatarId ?? this.currentAvatarId,
      currentThemeId: currentThemeId ?? this.currentThemeId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}