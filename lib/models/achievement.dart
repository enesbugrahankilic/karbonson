// lib/models/achievement.dart
// Achievement model for the achievement system

import 'package:equatable/equatable.dart';

/// Achievement categories
enum AchievementCategory {
  quiz,
  duel,
  multiplayer,
  social,
  streak,
  special,
}

/// Achievement rarity levels
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Achievement model
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int points;
  final Map<String, dynamic> requirements;
  final AchievementRarity rarity;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.points,
    required this.requirements,
    required this.rarity,
    this.unlockedAt,
  });

  /// Create achievement from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values[json['category'] as int],
      points: json['points'] as int,
      requirements: Map<String, dynamic>.from(json['requirements'] as Map),
      rarity: AchievementRarity.values[json['rarity'] as int],
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int)
          : null,
    );
  }

  /// Convert achievement to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category.index,
      'points': points,
      'requirements': requirements,
      'rarity': rarity.index,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  /// Get rarity color
  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return '#8B8B8B'; // Gray
      case AchievementRarity.rare:
        return '#4A90E2'; // Blue
      case AchievementRarity.epic:
        return '#9B59B6'; // Purple
      case AchievementRarity.legendary:
        return '#F39C12'; // Orange
    }
  }

  /// Get rarity name in Turkish
  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Sıradan';
      case AchievementRarity.rare:
        return 'Nadir';
      case AchievementRarity.epic:
        return 'Destansı';
      case AchievementRarity.legendary:
        return 'Efsanevi';
    }
  }

  /// Get category name in Turkish
  String get categoryName {
    switch (category) {
      case AchievementCategory.quiz:
        return 'Quiz';
      case AchievementCategory.duel:
        return 'Düello';
      case AchievementCategory.multiplayer:
        return 'Çok Oyunculu';
      case AchievementCategory.social:
        return 'Sosyal';
      case AchievementCategory.streak:
        return 'Seri';
      case AchievementCategory.special:
        return 'Özel';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        category,
        points,
        requirements,
        rarity,
        unlockedAt
      ];

  /// Copy with method
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementCategory? category,
    int? points,
    Map<String, dynamic>? requirements,
    AchievementRarity? rarity,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      points: points ?? this.points,
      requirements: requirements ?? this.requirements,
      rarity: rarity ?? this.rarity,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
