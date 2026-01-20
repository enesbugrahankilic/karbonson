// lib/models/loot_box_reward.dart
// Loot Box Reward Model - Kutu İçindeki Ödüller

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'loot_box.dart';

/// Loot box içindeki ödül modeli
class LootBoxReward extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final LootBoxContentType contentType;
  final LootBoxRarity rarity;
  final int amount; // Puan miktarı veya öğe sayısı
  final String? rewardId; // İlgili ödül ID'si (avatar, theme, etc.)
  final Map<String, dynamic> properties;
  final double dropWeight; // Düşme ağırlığı (olasılık için)
  final bool isDuplicateAllowed;
  final int? maxDuplicates;

  const LootBoxReward({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.contentType,
    required this.rarity,
    this.amount = 1,
    this.rewardId,
    this.properties = const {},
    this.dropWeight = 1.0,
    this.isDuplicateAllowed = true,
    this.maxDuplicates,
  });

  /// JSON'dan oluştur
  factory LootBoxReward.fromJson(Map<String, dynamic> json) {
    return LootBoxReward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      contentType: LootBoxContentType.values[json['contentType'] as int],
      rarity: LootBoxRarity.values[json['rarity'] as int],
      amount: json['amount'] as int? ?? 1,
      rewardId: json['rewardId'] as String?,
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      dropWeight: (json['dropWeight'] as double?) ?? 1.0,
      isDuplicateAllowed: json['isDuplicateAllowed'] as bool? ?? true,
      maxDuplicates: json['maxDuplicates'] as int?,
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'contentType': contentType.index,
      'rarity': rarity.index,
      'amount': amount,
      'rewardId': rewardId,
      'properties': properties,
      'dropWeight': dropWeight,
      'isDuplicateAllowed': isDuplicateAllowed,
      'maxDuplicates': maxDuplicates,
    };
  }

  /// Nadirlik rengi
  Color get rarityColor {
    switch (rarity) {
      case LootBoxRarity.common:
        return const Color(0xFF8B8B8B);
      case LootBoxRarity.rare:
        return const Color(0xFF4A90E2);
      case LootBoxRarity.epic:
        return const Color(0xFF9B59B6);
      case LootBoxRarity.legendary:
        return const Color(0xFFF39C12);
      case LootBoxRarity.mythic:
        return const Color(0xFFE74C3C);
    }
  }

  /// Nadirlik ismi (Türkçe)
  String get rarityName {
    switch (rarity) {
      case LootBoxRarity.common:
        return 'Sıradan';
      case LootBoxRarity.rare:
        return 'Nadir';
      case LootBoxRarity.epic:
        return 'Destansı';
      case LootBoxRarity.legendary:
        return 'Efsanevi';
      case LootBoxRarity.mythic:
        return 'Mitolojik';
    }
  }

  /// İçerik türü ismi (Türkçe)
  String get contentTypeName {
    switch (contentType) {
      case LootBoxContentType.points:
        return 'Karbon Puanı';
      case LootBoxContentType.avatar:
        return 'Avatar';
      case LootBoxContentType.theme:
        return 'Tema';
      case LootBoxContentType.feature:
        return 'Özellik';
      case LootBoxContentType.badge:
        return 'Rozet';
      case LootBoxContentType.title:
        return 'Unvan';
      case LootBoxContentType.item:
        return 'Eşya';
    }
  }

  /// Ödül metni
  String get rewardText {
    switch (contentType) {
      case LootBoxContentType.points:
        return '$amount KP';
      case LootBoxContentType.avatar:
      case LootBoxContentType.theme:
      case LootBoxContentType.feature:
      case LootBoxContentType.badge:
      case LootBoxContentType.title:
      case LootBoxContentType.item:
        return name;
    }
  }

  /// Kopya
  LootBoxReward copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    LootBoxContentType? contentType,
    LootBoxRarity? rarity,
    int? amount,
    String? rewardId,
    Map<String, dynamic>? properties,
    double? dropWeight,
    bool? isDuplicateAllowed,
    int? maxDuplicates,
  }) {
    return LootBoxReward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      contentType: contentType ?? this.contentType,
      rarity: rarity ?? this.rarity,
      amount: amount ?? this.amount,
      rewardId: rewardId ?? this.rewardId,
      properties: properties ?? this.properties,
      dropWeight: dropWeight ?? this.dropWeight,
      isDuplicateAllowed: isDuplicateAllowed ?? this.isDuplicateAllowed,
      maxDuplicates: maxDuplicates ?? this.maxDuplicates,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        contentType,
        rarity,
        amount,
        rewardId,
        properties,
        dropWeight,
        isDuplicateAllowed,
        maxDuplicates,
      ];
}

/// Açılmış ödül sonucu
class OpenedReward extends Equatable {
  final String id;
  final String lootBoxId;
  final LootBoxReward reward;
  final DateTime openedAt;
  final bool isNew; // İlk kez mi kazanıldı
  final bool isDuplicate; // Daha önce var mıydı

  const OpenedReward({
    required this.id,
    required this.lootBoxId,
    required this.reward,
    required this.openedAt,
    this.isNew = true,
    this.isDuplicate = false,
  });

  /// JSON'dan oluştur
  factory OpenedReward.fromJson(Map<String, dynamic> json) {
    return OpenedReward(
      id: json['id'] as String,
      lootBoxId: json['lootBoxId'] as String,
      reward: LootBoxReward.fromJson(json['reward'] as Map<String, dynamic>),
      openedAt: DateTime.fromMillisecondsSinceEpoch(json['openedAt'] as int),
      isNew: json['isNew'] as bool? ?? true,
      isDuplicate: json['isDuplicate'] as bool? ?? false,
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lootBoxId': lootBoxId,
      'reward': reward.toJson(),
      'openedAt': openedAt.millisecondsSinceEpoch,
      'isNew': isNew,
      'isDuplicate': isDuplicate,
    };
  }

  @override
  List<Object?> get props => [
        id,
        lootBoxId,
        reward,
        openedAt,
        isNew,
        isDuplicate,
      ];
}

/// Loot box açma sonucu
class LootBoxOpenResult extends Equatable {
  final bool success;
  final String? errorMessage;
  final UserLootBox? openedBox;
  final List<OpenedReward> rewards;
  final int totalPoints;
  final bool hasRareOrHigher;
  final bool hasLegendaryOrHigher;

  const LootBoxOpenResult({
    required this.success,
    this.errorMessage,
    this.openedBox,
    required this.rewards,
    required this.totalPoints,
    required this.hasRareOrHigher,
    required this.hasLegendaryOrHigher,
  });

  /// Başarısız sonuç
  factory LootBoxOpenResult.failure(String error) {
    return LootBoxOpenResult(
      success: false,
      errorMessage: error,
      rewards: [],
      totalPoints: 0,
      hasRareOrHigher: false,
      hasLegendaryOrHigher: false,
    );
  }

  /// Başarılı sonuç
  factory LootBoxOpenResult.success({
    required UserLootBox openedBox,
    required List<OpenedReward> rewards,
  }) {
    int totalPoints = 0;
    bool hasRareOrHigher = false;
    bool hasLegendaryOrHigher = false;

    for (final reward in rewards) {
      if (reward.reward.contentType == LootBoxContentType.points) {
        totalPoints += reward.reward.amount;
      }
      if (reward.reward.rarity == LootBoxRarity.rare ||
          reward.reward.rarity == LootBoxRarity.epic ||
          reward.reward.rarity == LootBoxRarity.legendary ||
          reward.reward.rarity == LootBoxRarity.mythic) {
        hasRareOrHigher = true;
      }
      if (reward.reward.rarity == LootBoxRarity.legendary ||
          reward.reward.rarity == LootBoxRarity.mythic) {
        hasLegendaryOrHigher = true;
      }
    }

    return LootBoxOpenResult(
      success: true,
      openedBox: openedBox,
      rewards: rewards,
      totalPoints: totalPoints,
      hasRareOrHigher: hasRareOrHigher,
      hasLegendaryOrHigher: hasLegendaryOrHigher,
    );
  }

  @override
  List<Object?> get props => [
        success,
        errorMessage,
        openedBox,
        rewards,
        totalPoints,
        hasRareOrHigher,
        hasLegendaryOrHigher,
      ];
}

/// Loot box pool - belirli bir kutu türü için ödül havuzu
class LootBoxPool extends Equatable {
  final String id;
  final String name;
  final LootBoxType boxType;
  final List<LootBoxReward> commonRewards;
  final List<LootBoxReward> rareRewards;
  final List<LootBoxReward> epicRewards;
  final List<LootBoxReward> legendaryRewards;
  final List<LootBoxReward> mythicRewards;
  final Map<LootBoxRarity, double> rarityWeights;
  final bool isActive;
  final DateTime? validUntil;

  const LootBoxPool({
    required this.id,
    required this.name,
    required this.boxType,
    required this.commonRewards,
    required this.rareRewards,
    required this.epicRewards,
    required this.legendaryRewards,
    required this.mythicRewards,
    required this.rarityWeights,
    this.isActive = true,
    this.validUntil,
  });

  /// Tüm ödülleri getir
  List<LootBoxReward> get allRewards {
    return [
      ...commonRewards,
      ...rareRewards,
      ...epicRewards,
      ...legendaryRewards,
      ...mythicRewards,
    ];
  }

  /// Nadirlik bazında ödülleri getir
  List<LootBoxReward> getRewardsByRarity(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common:
        return commonRewards;
      case LootBoxRarity.rare:
        return rareRewards;
      case LootBoxRarity.epic:
        return epicRewards;
      case LootBoxRarity.legendary:
        return legendaryRewards;
      case LootBoxRarity.mythic:
        return mythicRewards;
    }
  }

  /// Toplam ağırlık
  double get totalWeight {
    return rarityWeights.values.fold(0, (sum, weight) => sum + weight);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        boxType,
        commonRewards,
        rareRewards,
        epicRewards,
        legendaryRewards,
        mythicRewards,
        rarityWeights,
        isActive,
        validUntil,
      ];
}

