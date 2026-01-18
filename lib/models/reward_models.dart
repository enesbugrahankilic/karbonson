// lib/models/reward_models.dart
// Gelişmiş Ödül Modelleri - Karbon Puanı ve Ödül Sistemi

import 'package:equatable/equatable.dart';

enum RewardType { avatar, theme, feature, currency, badge, title, item }
enum RewardRarity { common, uncommon, rare, epic, legendary, mythic }
enum RewardStatus { locked, available, unlocked, equipped, expired }
enum PointTransactionType { earned, spent, bonus, penalty, streak_bonus, daily_login, achievement, challenge, seasonal }

class PointTransaction extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final PointTransactionType type;
  final String description;
  final DateTime timestamp;
  final String? relatedId;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
    this.relatedId,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      type: PointTransactionType.values[json['type'] as int],
      description: json['description'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      relatedId: json['relatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'userId': userId, 'amount': amount, 'type': type.index,
      'description': description, 'timestamp': timestamp.millisecondsSinceEpoch,
      'relatedId': relatedId,
    };
  }

  @override List<Object?> get props => [id, userId, amount, type, description, timestamp, relatedId];
}

class PointWallet extends Equatable {
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int lifetimePoints;
  final int levelPoints;
  final int streakMultiplier;
  final DateTime lastEarnedAt;
  final List<PointTransaction> transactions;

  const PointWallet({
    required this.userId, required this.totalPoints, required this.availablePoints,
    required this.lifetimePoints, required this.levelPoints, required this.streakMultiplier,
    required this.lastEarnedAt, required this.transactions,
  });

  factory PointWallet.fromJson(Map<String, dynamic> json) {
    return PointWallet(
      userId: json['userId'] as String,
      totalPoints: json['totalPoints'] as int? ?? 0,
      availablePoints: json['availablePoints'] as int? ?? 0,
      lifetimePoints: json['lifetimePoints'] as int? ?? 0,
      levelPoints: json['levelPoints'] as int? ?? 0,
      streakMultiplier: json['streakMultiplier'] as int? ?? 1,
      lastEarnedAt: DateTime.fromMillisecondsSinceEpoch(json['lastEarnedAt'] as int),
      transactions: (json['transactions'] as List?)
          ?.map((t) => PointTransaction.fromJson(t)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId, 'totalPoints': totalPoints, 'availablePoints': availablePoints,
      'lifetimePoints': lifetimePoints, 'levelPoints': levelPoints,
      'streakMultiplier': streakMultiplier, 'lastEarnedAt': lastEarnedAt.millisecondsSinceEpoch,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  PointWallet addPoints(int amount, PointTransactionType type, String description, {String? relatedId}) {
    return PointWallet(
      userId: userId, totalPoints: totalPoints + amount, availablePoints: availablePoints + amount,
      lifetimePoints: lifetimePoints + amount, levelPoints: levelPoints, streakMultiplier: streakMultiplier,
      lastEarnedAt: DateTime.now(),
      transactions: [
        ...transactions,
        PointTransaction(id: '${userId}_${DateTime.now().millisecondsSinceEpoch}', userId: userId,
          amount: amount, type: type, description: description, timestamp: DateTime.now(), relatedId: relatedId),
      ],
    );
  }

  PointWallet spendPoints(int amount, String description, {String? relatedId}) {
    if (availablePoints < amount) return this;
    return PointWallet(
      userId: userId, totalPoints: totalPoints, availablePoints: availablePoints - amount,
      lifetimePoints: lifetimePoints, levelPoints: levelPoints, streakMultiplier: streakMultiplier,
      lastEarnedAt: lastEarnedAt,
      transactions: [
        ...transactions,
        PointTransaction(id: '${userId}_${DateTime.now().millisecondsSinceEpoch}', userId: userId,
          amount: -amount, type: PointTransactionType.spent, description: description, timestamp: DateTime.now(), relatedId: relatedId),
      ],
    );
  }

  PointWallet copyWith({
    String? userId, int? totalPoints, int? availablePoints, int? lifetimePoints,
    int? levelPoints, int? streakMultiplier, DateTime? lastEarnedAt, List<PointTransaction>? transactions,
  }) {
    return PointWallet(
      userId: userId ?? this.userId, totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints, lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      levelPoints: levelPoints ?? this.levelPoints, streakMultiplier: streakMultiplier ?? this.streakMultiplier,
      lastEarnedAt: lastEarnedAt ?? this.lastEarnedAt, transactions: transactions ?? this.transactions,
    );
  }

  @override List<Object?> get props => [userId, totalPoints, availablePoints, lifetimePoints, levelPoints, streakMultiplier, lastEarnedAt, transactions];
}

class Reward extends Equatable {
  final String id, name, description, icon;
  final String? imageUrl;
  final RewardType type;
  final RewardRarity rarity;
  final RewardStatus status;
  final int unlockRequirement, price, levelRequired;
  final Map<String, dynamic> properties;
  final DateTime? unlockedAt, expiresAt;
  final bool isLimited;
  final int? stockRemaining;
  final int progress;
  final String category;

  const Reward({
    required this.id, required this.name, required this.description, required this.icon,
    this.imageUrl, required this.type, required this.rarity, required this.status,
    required this.unlockRequirement, this.price = 0, this.levelRequired = 1,
    this.properties = const {}, this.unlockedAt, this.expiresAt, this.isLimited = false,
    this.stockRemaining, this.progress = 0, this.category = 'general',
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String, name: json['name'] as String, description: json['description'] as String,
      icon: json['icon'] as String, imageUrl: json['imageUrl'] as String?,
      type: RewardType.values[json['type'] as int], rarity: RewardRarity.values[json['rarity'] as int],
      status: RewardStatus.values[json['status'] as int], unlockRequirement: json['unlockRequirement'] as int? ?? 0,
      price: json['price'] as int? ?? 0, levelRequired: json['levelRequired'] as int? ?? 1,
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      unlockedAt: json['unlockedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int) : null,
      isLimited: json['isLimited'] as bool? ?? false, stockRemaining: json['stockRemaining'] as int?,
      progress: json['progress'] as int? ?? 0, category: json['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'name': name, 'description': description, 'icon': icon, 'imageUrl': imageUrl,
      'type': type.index, 'rarity': rarity.index, 'status': status.index,
      'unlockRequirement': unlockRequirement, 'price': price, 'levelRequired': levelRequired,
      'properties': properties, 'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch, 'isLimited': isLimited,
      'stockRemaining': stockRemaining, 'progress': progress, 'category': category,
    };
  }

  double get progressPercentage => unlockRequirement == 0 ? 0 : (progress / unlockRequirement).clamp(0.0, 1.0);
  bool get canUnlock => status == RewardStatus.available || status == RewardStatus.locked;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  String get rarityName {
    switch (rarity) {
      case RewardRarity.common: return 'Sıradan'; case RewardRarity.uncommon: return 'Olağan';
      case RewardRarity.rare: return 'Nadir'; case RewardRarity.epic: return 'Destansı';
      case RewardRarity.legendary: return 'Efsanevi'; case RewardRarity.mythic: return 'Mitolojik';
    }
  }

  String get typeName {
    switch (type) {
      case RewardType.avatar: return 'Avatar'; case RewardType.theme: return 'Tema';
      case RewardType.feature: return 'Özellik'; case RewardType.currency: return 'Puan';
      case RewardType.badge: return 'Rozet'; case RewardType.title: return 'Unvan';
      case RewardType.item: return 'Eşya';
    }
  }

  Reward copyWith({
    String? id, String? name, String? description, String? icon, String? imageUrl,
    RewardType? type, RewardRarity? rarity, RewardStatus? status, int? unlockRequirement,
    int? price, int? levelRequired, Map<String, dynamic>? properties, DateTime? unlockedAt,
    DateTime? expiresAt, bool? isLimited, int? stockRemaining, int? progress, String? category,
  }) {
    return Reward(
      id: id ?? this.id, name: name ?? this.name, description: description ?? this.description,
      icon: icon ?? this.icon, imageUrl: imageUrl ?? this.imageUrl, type: type ?? this.type,
      rarity: rarity ?? this.rarity, status: status ?? this.status,
      unlockRequirement: unlockRequirement ?? this.unlockRequirement, price: price ?? this.price,
      levelRequired: levelRequired ?? this.levelRequired, properties: properties ?? this.properties,
      unlockedAt: unlockedAt ?? this.unlockedAt, expiresAt: expiresAt ?? this.expiresAt,
      isLimited: isLimited ?? this.isLimited, stockRemaining: stockRemaining ?? this.stockRemaining,
      progress: progress ?? this.progress, category: category ?? this.category,
    );
  }

  @override List<Object?> get props => [
    id, name, description, icon, imageUrl, type, rarity, status, unlockRequirement,
    price, levelRequired, properties, unlockedAt, expiresAt, isLimited, stockRemaining, progress, category,
  ];
}

class UserRewardInventory extends Equatable {
  final String userId;
  final List<String> unlockedRewardIds;
  final List<String> equippedAvatarIds;
  final List<String> equippedThemeIds;
  final List<String> unlockedTitleIds;
  final Map<String, int> itemQuantities;
  final DateTime lastUpdated;

  const UserRewardInventory({
    required this.userId, required this.unlockedRewardIds, required this.equippedAvatarIds,
    required this.equippedThemeIds, required this.unlockedTitleIds, required this.itemQuantities,
    required this.lastUpdated,
  });

  factory UserRewardInventory.fromJson(Map<String, dynamic> json) {
    return UserRewardInventory(
      userId: json['userId'] as String,
      unlockedRewardIds: List<String>.from(json['unlockedRewardIds'] as List),
      equippedAvatarIds: List<String>.from(json['equippedAvatarIds'] as List),
      equippedThemeIds: List<String>.from(json['equippedThemeIds'] as List),
      unlockedTitleIds: List<String>.from(json['unlockedTitleIds'] as List),
      itemQuantities: Map<String, int>.from(json['itemQuantities'] as Map? ?? {}),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId, 'unlockedRewardIds': unlockedRewardIds, 'equippedAvatarIds': equippedAvatarIds,
      'equippedThemeIds': equippedThemeIds, 'unlockedTitleIds': unlockedTitleIds,
      'itemQuantities': itemQuantities, 'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  bool hasRewardUnlocked(String rewardId) => unlockedRewardIds.contains(rewardId);
  bool hasTitleUnlocked(String titleId) => unlockedTitleIds.contains(titleId);
  int getItemQuantity(String itemId) => itemQuantities[itemId] ?? 0;

  UserRewardInventory copyWith({
    String? userId, List<String>? unlockedRewardIds, List<String>? equippedAvatarIds,
    List<String>? equippedThemeIds, List<String>? unlockedTitleIds, Map<String, int>? itemQuantities,
    DateTime? lastUpdated,
  }) {
    return UserRewardInventory(
      userId: userId ?? this.userId, unlockedRewardIds: unlockedRewardIds ?? this.unlockedRewardIds,
      equippedAvatarIds: equippedAvatarIds ?? this.equippedAvatarIds,
      equippedThemeIds: equippedThemeIds ?? this.equippedThemeIds,
      unlockedTitleIds: unlockedTitleIds ?? this.unlockedTitleIds,
      itemQuantities: itemQuantities ?? this.itemQuantities, lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override List<Object?> get props => [
    userId, unlockedRewardIds, equippedAvatarIds, equippedThemeIds, unlockedTitleIds, itemQuantities, lastUpdated,
  ];
}

class MilestoneReward extends Equatable {
  final String id, name, description, icon;
  final int targetValue;
  final String targetType;
  final Reward reward;
  final bool isClaimed;
  final DateTime? claimedAt;

  const MilestoneReward({
    required this.id, required this.name, required this.description, required this.icon,
    required this.targetValue, required this.targetType, required this.reward,
    this.isClaimed = false, this.claimedAt,
  });

  factory MilestoneReward.fromJson(Map<String, dynamic> json) {
    return MilestoneReward(
      id: json['id'] as String, name: json['name'] as String, description: json['description'] as String,
      icon: json['icon'] as String, targetValue: json['targetValue'] as int,
      targetType: json['targetType'] as String, reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
      isClaimed: json['isClaimed'] as bool? ?? false,
      claimedAt: json['claimedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['claimedAt'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'name': name, 'description': description, 'icon': icon,
      'targetValue': targetValue, 'targetType': targetType, 'reward': reward.toJson(),
      'isClaimed': isClaimed, 'claimedAt': claimedAt?.millisecondsSinceEpoch,
    };
  }

  double getProgress(int currentValue) => (currentValue / targetValue).clamp(0.0, 1.0);
  bool isAchieved(int currentValue) => currentValue >= targetValue && !isClaimed;

  MilestoneReward copyWith({
    String? id, String? name, String? description, String? icon, int? targetValue,
    String? targetType, Reward? reward, bool? isClaimed, DateTime? claimedAt,
  }) {
    return MilestoneReward(
      id: id ?? this.id, name: name ?? this.name, description: description ?? this.description,
      icon: icon ?? this.icon, targetValue: targetValue ?? this.targetValue,
      targetType: targetType ?? this.targetType, reward: reward ?? this.reward,
      isClaimed: isClaimed ?? this.isClaimed, claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  @override List<Object?> get props => [id, name, description, icon, targetValue, targetType, reward, isClaimed, claimedAt];
}

class StreakReward extends Equatable {
  final String id;
  final int streakDays;
  final int pointsBonus;
  final String icon;
  final String title;

  const StreakReward({required this.id, required this.streakDays, required this.pointsBonus, required this.icon, required this.title});

  factory StreakReward.fromJson(Map<String, dynamic> json) {
    return StreakReward(
      id: json['id'] as String, streakDays: json['streakDays'] as int,
      pointsBonus: json['pointsBonus'] as int, icon: json['icon'] as String, title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'streakDays': streakDays, 'pointsBonus': pointsBonus, 'icon': icon, 'title': title};
  }

  @override List<Object?> get props => [id, streakDays, pointsBonus, icon, title];
}

class UserStreak extends Equatable {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastLoginDate;
  final int consecutiveDays;
  final int weeklyBonusClaimed;
  final DateTime streakStartDate;

  const UserStreak({
    required this.userId, required this.currentStreak, required this.longestStreak,
    required this.lastLoginDate, required this.consecutiveDays, required this.weeklyBonusClaimed,
    required this.streakStartDate,
  });

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      userId: json['userId'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastLoginDate: DateTime.fromMillisecondsSinceEpoch(json['lastLoginDate'] as int),
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
      weeklyBonusClaimed: json['weeklyBonusClaimed'] as int? ?? 0,
      streakStartDate: DateTime.fromMillisecondsSinceEpoch(json['streakStartDate'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId, 'currentStreak': currentStreak, 'longestStreak': longestStreak,
      'lastLoginDate': lastLoginDate.millisecondsSinceEpoch, 'consecutiveDays': consecutiveDays,
      'weeklyBonusClaimed': weeklyBonusClaimed, 'streakStartDate': streakStartDate.millisecondsSinceEpoch,
    };
  }

  UserStreak updateStreak() {
    final now = DateTime.now();
    final daysDiff = now.difference(lastLoginDate).inDays;
    if (daysDiff == 1) {
      final newStreak = currentStreak + 1;
      return copyWith(currentStreak: newStreak, longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastLoginDate: now, consecutiveDays: newStreak, streakStartDate: currentStreak == 0 ? now : streakStartDate);
    } else if (daysDiff > 1) {
      return copyWith(currentStreak: 1, lastLoginDate: now, consecutiveDays: 1, streakStartDate: now);
    }
    return copyWith(lastLoginDate: now);
  }

  UserStreak copyWith({
    String? userId, int? currentStreak, int? longestStreak, DateTime? lastLoginDate,
    int? consecutiveDays, int? weeklyBonusClaimed, DateTime? streakStartDate,
  }) {
    return UserStreak(
      userId: userId ?? this.userId, currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak, lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      weeklyBonusClaimed: weeklyBonusClaimed ?? this.weeklyBonusClaimed,
      streakStartDate: streakStartDate ?? this.streakStartDate,
    );
  }

  @override List<Object?> get props => [userId, currentStreak, longestStreak, lastLoginDate, consecutiveDays, weeklyBonusClaimed, streakStartDate];
}
