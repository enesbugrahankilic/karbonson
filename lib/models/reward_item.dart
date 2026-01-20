// lib/models/reward_item.dart
// Reward items model for avatar, theme, and special features

import 'package:equatable/equatable.dart';
import 'user_progress.dart';

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

/// Reward unlock requirement type
enum RewardUnlockType {
  achievements,    // Rozet sayısı gerekiyor
  points,          // Puan gerekiyor
  level,           // Seviye gerekiyor
  duelWins,        // Düello kazanma gerekiyor
  friends,         // Arkadaş sayısı gerekiyor
  loginStreak,     // Günlük giriş serisi gerekiyor
  quizzes,         // Quiz tamamlama gerekiyor
  seasonal,        // Mevsimlik etkinlik gerekiyor
}

/// Reward unlock status
enum RewardUnlockStatus {
  unlocked,        // Ödül zaten açıldı
  available,       // Koşullar karşılandı, alınabilir
  inProgress,      // Koşullar kısmen karşılandı
  locked,          // Koşullar karşılanmadı
}

/// Reward unlock progress info
class RewardUnlockProgress {
  final RewardUnlockStatus status;
  final int currentValue;
  final int requiredValue;
  final double progressPercentage;
  final String statusMessage;
  final String requirementDescription;

  const RewardUnlockProgress({
    required this.status,
    required this.currentValue,
    required this.requiredValue,
    required this.progressPercentage,
    required this.statusMessage,
    required this.requirementDescription,
  });

  /// Get remaining amount
  int get remainingAmount => (requiredValue - currentValue).clamp(0, requiredValue);

  /// Check if user can unlock
  bool get canUnlock => status == RewardUnlockStatus.unlocked || status == RewardUnlockStatus.available;
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

  /// Determine unlock type based on reward ID and type
  RewardUnlockType getUnlockType() {
    // Feature rewards are unlocked by points
    if (type == RewardItemType.feature) {
      // Special features with different unlock types
      if (id == 'priority_queue') return RewardUnlockType.duelWins;
      if (id == 'streak_protection') return RewardUnlockType.loginStreak;
      if (id == 'friend_bonus') return RewardUnlockType.friends;
      if (id == 'seasonal_bonus' || id == 'spring_theme' || id == 'summer_theme') {
        return RewardUnlockType.seasonal;
      }
      return RewardUnlockType.points;
    }

    // Avatar rewards based on ID patterns
    switch (id) {
      case 'star_avatar':
      case 'night_theme':
      case 'hint_system':
        return RewardUnlockType.achievements;
      case 'crown_avatar':
      case 'golden_theme':
      case 'protection_shield':
        return RewardUnlockType.achievements; // Legendary requires achievement
      case 'mask_avatar':
        return RewardUnlockType.achievements; // Requires achievements from all categories
      case 'fire_avatar':
        return RewardUnlockType.loginStreak;
      case 'ocean_avatar':
        return RewardUnlockType.duelWins;
      case 'friendship_avatar':
        return RewardUnlockType.friends;
      case 'seasonal_spring_avatar':
      case 'legendary_summer_avatar':
      case 'spring_theme':
      case 'summer_theme':
        return RewardUnlockType.seasonal;
      case 'rainbow_theme':
        return RewardUnlockType.achievements; // Different categories
      case 'nature_theme':
        return RewardUnlockType.quizzes;
      case 'space_theme':
        return RewardUnlockType.friends;
      case 'winter_theme':
        return RewardUnlockType.loginStreak;
      case 'time_extension':
        return RewardUnlockType.achievements;
      case 'double_points':
        return RewardUnlockType.points;
      default:
        return RewardUnlockType.achievements;
    }
  }

  /// Get user progress for this reward
  RewardUnlockProgress getUnlockProgress(UserProgress? progress) {
    // If already unlocked
    if (isUnlocked) {
      return RewardUnlockProgress(
        status: RewardUnlockStatus.unlocked,
        currentValue: unlockRequirement,
        requiredValue: unlockRequirement,
        progressPercentage: 1.0,
        statusMessage: 'Açıldı',
        requirementDescription: _getRequirementDescription(),
      );
    }

    // If no progress data
    if (progress == null) {
      return RewardUnlockProgress(
        status: RewardUnlockStatus.locked,
        currentValue: 0,
        requiredValue: unlockRequirement,
        progressPercentage: 0.0,
        statusMessage: 'Kilitlede',
        requirementDescription: _getRequirementDescription(),
      );
    }

    final unlockType = getUnlockType();
    final currentValue = _getCurrentValue(progress, unlockType);
    final progressPercent = (currentValue / unlockRequirement).clamp(0.0, 1.0);

    // Determine status
    if (currentValue >= unlockRequirement) {
      return RewardUnlockProgress(
        status: RewardUnlockStatus.available,
        currentValue: currentValue,
        requiredValue: unlockRequirement,
        progressPercentage: 1.0,
        statusMessage: 'Alınabilir!',
        requirementDescription: _getRequirementDescription(),
      );
    } else if (currentValue > 0) {
      return RewardUnlockProgress(
        status: RewardUnlockStatus.inProgress,
        currentValue: currentValue,
        requiredValue: unlockRequirement,
        progressPercentage: progressPercent,
        statusMessage: '${_getRemainingText()} kaldı',
        requirementDescription: _getRequirementDescription(),
      );
    } else {
      return RewardUnlockProgress(
        status: RewardUnlockStatus.locked,
        currentValue: currentValue,
        requiredValue: unlockRequirement,
        progressPercentage: 0.0,
        statusMessage: 'Kilitlede',
        requirementDescription: _getRequirementDescription(),
      );
    }
  }

  /// Get current value based on unlock type
  int _getCurrentValue(UserProgress progress, RewardUnlockType unlockType) {
    switch (unlockType) {
      case RewardUnlockType.achievements:
        return progress.achievements.length;
      case RewardUnlockType.points:
        return progress.totalPoints;
      case RewardUnlockType.level:
        return progress.level;
      case RewardUnlockType.duelWins:
        return progress.duelWins;
      case RewardUnlockType.friends:
        return progress.friendsCount;
      case RewardUnlockType.loginStreak:
        return progress.loginStreak;
      case RewardUnlockType.quizzes:
        return progress.completedQuizzes;
      case RewardUnlockType.seasonal:
        // For seasonal, we check if user has any seasonal achievements
        return progress.achievements.isEmpty ? 0 : 1;
    }
  }

  /// Get requirement description in Turkish
  String _getRequirementDescription() {
    final unlockType = getUnlockType();
    switch (unlockType) {
      case RewardUnlockType.achievements:
        return '$unlockRequirement rozet kazan';
      case RewardUnlockType.points:
        return '$unlockRequirement puan topla';
      case RewardUnlockType.level:
        return 'Seviye $unlockRequirement ol';
      case RewardUnlockType.duelWins:
        return '$unlockRequirement düello kazan';
      case RewardUnlockType.friends:
        return '$unlockRequirement arkadaş ekle';
      case RewardUnlockType.loginStreak:
        return '$unlockRequirement gün üst üste giriş yap';
      case RewardUnlockType.quizzes:
        return '$unlockRequirement quiz tamamla';
      case RewardUnlockType.seasonal:
        return 'Mevsimlik etkinliğe katıl';
    }
  }

  /// Get remaining text in Turkish
  String _getRemainingText() {
    final unlockType = getUnlockType();
    switch (unlockType) {
      case RewardUnlockType.achievements:
        return '$unlockRequirement rozet';
      case RewardUnlockType.points:
        return '$unlockRequirement puan';
      case RewardUnlockType.level:
        return '$unlockRequirement seviye';
      case RewardUnlockType.duelWins:
        return '$unlockRequirement düello';
      case RewardUnlockType.friends:
        return '$unlockRequirement arkadaş';
      case RewardUnlockType.loginStreak:
        return '$unlockRequirement gün';
      case RewardUnlockType.quizzes:
        return '$unlockRequirement quiz';
      case RewardUnlockType.seasonal:
        return 'Mevsimlik etkinlik';
    }
  }

  /// Check if user can unlock this reward
  bool canUserUnlock(UserProgress? progress) {
    if (isUnlocked) return false;
    if (progress == null) return false;
    return getUnlockProgress(progress).canUnlock;
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