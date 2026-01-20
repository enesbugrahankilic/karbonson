// lib/models/loot_box.dart
// Loot Box Model - Ödül Kutusu Sistemi

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Loot Box türleri
enum LootBoxType {
  quiz,           // Quiz tamamlama ödülü
  daily,          // Günlük ödül kutusu
  achievement,    // Başarı ödülü
  challenge,      // Görev ödülü
  returnReward,   // Geri dönüş ödülü
  seasonal,       // Mevsimlik etkinlik kutusu
  login,          // Giriş ödülü
  special,        // Özel etkinlik kutusu
  premium,        // Premium kutu
}

/// Loot Box nadirliği
enum LootBoxRarity {
  common,         // Sıradan - Gri (#8B8B8B)
  rare,           // Nadir - Mavi (#4A90E2)
  epic,           // Destansı - Mor (#9B59B6)
  legendary,      // Efsanevi - Altın (#F39C12)
  mythic,         // Mitolojik - Kırmızı (#E74C3C)
}

/// İçerik türleri
enum LootBoxContentType {
  points,         // Karbon Puanı
  avatar,         // Avatar ödülü
  theme,          // Tema ödülü
  feature,        // Özellik ödülü
  badge,          // Rozet ödülü
  title,          // Unvan ödülü
  item,           // Eşya ödülü
}

/// Loot Box modeli
class LootBox extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final LootBoxType type;
  final LootBoxRarity rarity;
  final Color? customColor;
  final DateTime? expiresAt;
  final bool isLimited;
  final int? limitedQuantity;
  final int remainingQuantity;
  final Map<String, dynamic> properties;
  final String? sourceEvent; // Kaynak etkinlik
  final DateTime createdAt;

  const LootBox({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    this.customColor,
    this.expiresAt,
    this.isLimited = false,
    this.limitedQuantity,
    this.remainingQuantity = 0,
    this.properties = const {},
    this.sourceEvent,
    required this.createdAt,
  });

  /// JSON'dan oluştur
  factory LootBox.fromJson(Map<String, dynamic> json) {
    return LootBox(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: LootBoxType.values[json['type'] as int],
      rarity: LootBoxRarity.values[json['rarity'] as int],
      customColor: json['customColor'] != null 
          ? Color(int.parse(json['customColor'] as String))
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int)
          : null,
      isLimited: json['isLimited'] as bool? ?? false,
      limitedQuantity: json['limitedQuantity'] as int?,
      remainingQuantity: json['remainingQuantity'] as int? ?? 0,
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      sourceEvent: json['sourceEvent'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type.index,
      'rarity': rarity.index,
      'customColor': customColor?.value.toRadixString(16),
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'isLimited': isLimited,
      'limitedQuantity': limitedQuantity,
      'remainingQuantity': remainingQuantity,
      'properties': properties,
      'sourceEvent': sourceEvent,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Nadirlik rengi
  Color get rarityColor {
    if (customColor != null) return customColor!;
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

  /// Nadirlik ismi (İngilizce)
  String get rarityNameEn {
    switch (rarity) {
      case LootBoxRarity.common:
        return 'Common';
      case LootBoxRarity.rare:
        return 'Rare';
      case LootBoxRarity.epic:
        return 'Epic';
      case LootBoxRarity.legendary:
        return 'Legendary';
      case LootBoxRarity.mythic:
        return 'Mythic';
    }
  }

  /// Tip ismi (Türkçe)
  String get typeName {
    switch (type) {
      case LootBoxType.quiz:
        return 'Quiz Kutusu';
      case LootBoxType.daily:
        return 'Günlük Kutusu';
      case LootBoxType.achievement:
        return 'Başarı Kutusu';
      case LootBoxType.challenge:
        return 'Görev Kutusu';
      case LootBoxType.returnReward:
        return 'Geri Dönüş Kutusu';
      case LootBoxType.seasonal:
        return 'Mevsimlik Kutusu';
      case LootBoxType.login:
        return 'Giriş Kutusu';
      case LootBoxType.special:
        return 'Özel Kutusu';
      case LootBoxType.premium:
        return 'Premium Kutusu';
    }
  }

  /// Süresi dolmuş mu?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Mevcut mu?
  bool get isAvailable {
    if (isExpired) return false;
    if (isLimited && remainingQuantity <= 0) return false;
    return true;
  }

  /// Kopya
  LootBox copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    LootBoxType? type,
    LootBoxRarity? rarity,
    Color? customColor,
    DateTime? expiresAt,
    bool? isLimited,
    int? limitedQuantity,
    int? remainingQuantity,
    Map<String, dynamic>? properties,
    String? sourceEvent,
    DateTime? createdAt,
  }) {
    return LootBox(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      customColor: customColor ?? this.customColor,
      expiresAt: expiresAt ?? this.expiresAt,
      isLimited: isLimited ?? this.isLimited,
      limitedQuantity: limitedQuantity ?? this.limitedQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      properties: properties ?? this.properties,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        type,
        rarity,
        customColor,
        expiresAt,
        isLimited,
        limitedQuantity,
        remainingQuantity,
        properties,
        sourceEvent,
        createdAt,
      ];
}

/// Kullanıcının sahip olduğu loot box (açılmamış)
class UserLootBox extends Equatable {
  final String id;
  final String userId;
  final String lootBoxId;
  final LootBoxType boxType;
  final LootBoxRarity rarity;
  final DateTime obtainedAt;
  final DateTime? expiresAt;
  final String? sourceDescription;
  final bool isOpened;
  final DateTime? openedAt;
  final String? openedRewardId;

  const UserLootBox({
    required this.id,
    required this.userId,
    required this.lootBoxId,
    required this.boxType,
    required this.rarity,
    required this.obtainedAt,
    this.expiresAt,
    this.sourceDescription,
    this.isOpened = false,
    this.openedAt,
    this.openedRewardId,
  });

  /// JSON'dan oluştur
  factory UserLootBox.fromJson(Map<String, dynamic> json) {
    return UserLootBox(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lootBoxId: json['lootBoxId'] as String,
      boxType: LootBoxType.values[json['boxType'] as int],
      rarity: LootBoxRarity.values[json['rarity'] as int],
      obtainedAt: DateTime.fromMillisecondsSinceEpoch(json['obtainedAt'] as int),
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int)
          : null,
      sourceDescription: json['sourceDescription'] as String?,
      isOpened: json['isOpened'] as bool? ?? false,
      openedAt: json['openedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['openedAt'] as int)
          : null,
      openedRewardId: json['openedRewardId'] as String?,
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'lootBoxId': lootBoxId,
      'boxType': boxType.index,
      'rarity': rarity.index,
      'obtainedAt': obtainedAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
      'sourceDescription': sourceDescription,
      'isOpened': isOpened,
      'openedAt': openedAt?.millisecondsSinceEpoch,
      'openedRewardId': openedRewardId,
    };
  }

  /// Süresi dolmuş mu?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Açılabilir mi?
  bool get canOpen => !isOpened && !isExpired;

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

/// Nadirlik ismi
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

  /// Kopya
  UserLootBox copyWith({
    String? id,
    String? userId,
    String? lootBoxId,
    LootBoxType? boxType,
    LootBoxRarity? rarity,
    DateTime? obtainedAt,
    DateTime? expiresAt,
    String? sourceDescription,
    bool? isOpened,
    DateTime? openedAt,
    String? openedRewardId,
  }) {
    return UserLootBox(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lootBoxId: lootBoxId ?? this.lootBoxId,
      boxType: boxType ?? this.boxType,
      rarity: rarity ?? this.rarity,
      obtainedAt: obtainedAt ?? this.obtainedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      sourceDescription: sourceDescription ?? this.sourceDescription,
      isOpened: isOpened ?? this.isOpened,
      openedAt: openedAt ?? this.openedAt,
      openedRewardId: openedRewardId ?? this.openedRewardId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        lootBoxId,
        boxType,
        rarity,
        obtainedAt,
        expiresAt,
        sourceDescription,
        isOpened,
        openedAt,
        openedRewardId,
      ];
}

/// Kullanıcının loot box envanteri
class UserLootBoxInventory extends Equatable {
  final String userId;
  final List<String> ownedBoxIds;
  final List<UserLootBox> unopenedBoxes;
  final int totalOpened;
  final int totalCommonOpened;
  final int totalRareOpened;
  final int totalEpicOpened;
  final int totalLegendaryOpened;
  final int totalMythicOpened;
  final DateTime lastUpdated;

  const UserLootBoxInventory({
    required this.userId,
    required this.ownedBoxIds,
    required this.unopenedBoxes,
    required this.totalOpened,
    required this.totalCommonOpened,
    required this.totalRareOpened,
    required this.totalEpicOpened,
    required this.totalLegendaryOpened,
    required this.totalMythicOpened,
    required this.lastUpdated,
  });

  /// JSON'dan oluştur
  factory UserLootBoxInventory.fromJson(Map<String, dynamic> json) {
    return UserLootBoxInventory(
      userId: json['userId'] as String,
      ownedBoxIds: List<String>.from(json['ownedBoxIds'] as List),
      unopenedBoxes: (json['unopenedBoxes'] as List?)
              ?.map((box) => UserLootBox.fromJson(box))
              .toList() ??
          [],
      totalOpened: json['totalOpened'] as int? ?? 0,
      totalCommonOpened: json['totalCommonOpened'] as int? ?? 0,
      totalRareOpened: json['totalRareOpened'] as int? ?? 0,
      totalEpicOpened: json['totalEpicOpened'] as int? ?? 0,
      totalLegendaryOpened: json['totalLegendaryOpened'] as int? ?? 0,
      totalMythicOpened: json['totalMythicOpened'] as int? ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['lastUpdated'] as int,
      ),
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ownedBoxIds': ownedBoxIds,
      'unopenedBoxes': unopenedBoxes.map((box) => box.toJson()).toList(),
      'totalOpened': totalOpened,
      'totalCommonOpened': totalCommonOpened,
      'totalRareOpened': totalRareOpened,
      'totalEpicOpened': totalEpicOpened,
      'totalLegendaryOpened': totalLegendaryOpened,
      'totalMythicOpened': totalMythicOpened,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  /// Toplam açılmamış kutu sayısı
  int get unopenedCount => unopenedBoxes.where((box) => box.canOpen).length;

  /// Nadirlik bazında sayılar
  int getUnopenedCountByRarity(LootBoxRarity rarity) {
    return unopenedBoxes
        .where((box) => box.rarity == rarity && box.canOpen)
        .length;
  }

  /// Kopya
  UserLootBoxInventory copyWith({
    String? userId,
    List<String>? ownedBoxIds,
    List<UserLootBox>? unopenedBoxes,
    int? totalOpened,
    int? totalCommonOpened,
    int? totalRareOpened,
    int? totalEpicOpened,
    int? totalLegendaryOpened,
    int? totalMythicOpened,
    DateTime? lastUpdated,
  }) {
    return UserLootBoxInventory(
      userId: userId ?? this.userId,
      ownedBoxIds: ownedBoxIds ?? this.ownedBoxIds,
      unopenedBoxes: unopenedBoxes ?? this.unopenedBoxes,
      totalOpened: totalOpened ?? this.totalOpened,
      totalCommonOpened: totalCommonOpened ?? this.totalCommonOpened,
      totalRareOpened: totalRareOpened ?? this.totalRareOpened,
      totalEpicOpened: totalEpicOpened ?? this.totalEpicOpened,
      totalLegendaryOpened: totalLegendaryOpened ?? this.totalLegendaryOpened,
      totalMythicOpened: totalMythicOpened ?? this.totalMythicOpened,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        ownedBoxIds,
        unopenedBoxes,
        totalOpened,
        totalCommonOpened,
        totalRareOpened,
        totalEpicOpened,
        totalLegendaryOpened,
        totalMythicOpened,
        lastUpdated,
      ];
}

