// lib/models/daily_challenge.dart
// Daily and weekly challenge models for user engagement

import 'package:equatable/equatable.dart';

/// Challenge types
enum ChallengeType {
  quiz,
  duel,
  multiplayer,
  social,
  special,
}

/// Reward types
enum RewardType {
  points,
  avatar,
  theme,
  feature,
}

/// Challenge difficulty levels
enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Daily Challenge model
class DailyChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  int currentValue;
  final int rewardPoints;
  final RewardType rewardType;
  final String? rewardItem; // ID of avatar, theme, or feature
  final DateTime date;
  final DateTime expiresAt;
  bool isCompleted;
  final ChallengeDifficulty difficulty;
  final String? icon;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.rewardPoints,
    required this.rewardType,
    this.rewardItem,
    required this.date,
    required this.expiresAt,
    required this.isCompleted,
    this.difficulty = ChallengeDifficulty.medium,
    this.icon,
  });

  /// Create challenge from JSON
  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values[json['type'] as int],
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int,
      rewardType: RewardType.values[json['rewardType'] as int],
      rewardItem: json['rewardItem'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      difficulty: ChallengeDifficulty.values[json['difficulty'] as int? ?? 1],
      icon: json['icon'] as String?,
    );
  }

  /// Convert challenge to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'rewardPoints': rewardPoints,
      'rewardType': rewardType.index,
      'rewardItem': rewardItem,
      'date': date.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'difficulty': difficulty.index,
      'icon': icon,
    };
  }

  /// Get progress percentage
  double get progressPercentage {
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get difficulty color
  String get difficultyColor {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return '#4CAF50'; // Green
      case ChallengeDifficulty.medium:
        return '#FF9800'; // Orange
      case ChallengeDifficulty.hard:
        return '#F44336'; // Red
      case ChallengeDifficulty.expert:
        return '#9C27B0'; // Purple
    }
  }

  /// Get difficulty name in Turkish
  String get difficultyName {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Kolay';
      case ChallengeDifficulty.medium:
        return 'Orta';
      case ChallengeDifficulty.hard:
        return 'Zor';
      case ChallengeDifficulty.expert:
        return 'Uzman';
    }
  }

  /// Get type name in Turkish
  String get typeName {
    switch (type) {
      case ChallengeType.quiz:
        return 'Quiz';
      case ChallengeType.duel:
        return 'Düello';
      case ChallengeType.multiplayer:
        return 'Çok Oyunculu';
      case ChallengeType.social:
        return 'Sosyal';
      case ChallengeType.special:
        return 'Özel';
    }
  }

  /// Check if challenge is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get reward type name in Turkish
  String get rewardTypeName {
    switch (rewardType) {
      case RewardType.points:
        return 'Puan';
      case RewardType.avatar:
        return 'Avatar';
      case RewardType.theme:
        return 'Tema';
      case RewardType.feature:
        return 'Özellik';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetValue,
        currentValue,
        rewardPoints,
        rewardType,
        rewardItem,
        date,
        expiresAt,
        isCompleted,
        difficulty,
        icon,
      ];

  /// Copy with method
  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    int? targetValue,
    int? currentValue,
    int? rewardPoints,
    RewardType? rewardType,
    String? rewardItem,
    DateTime? date,
    DateTime? expiresAt,
    bool? isCompleted,
    ChallengeDifficulty? difficulty,
    String? icon,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardType: rewardType ?? this.rewardType,
      rewardItem: rewardItem ?? this.rewardItem,
      date: date ?? this.date,
      expiresAt: expiresAt ?? this.expiresAt,
      isCompleted: isCompleted ?? this.isCompleted,
      difficulty: difficulty ?? this.difficulty,
      icon: icon ?? this.icon,
    );
  }
}

/// Weekly Challenge model
class WeeklyChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ChallengeType type;
  final int targetValue;
  final int currentValue;
  final int rewardPoints;
  final RewardType rewardType;
  final String? rewardItem;
  final DateTime weekStart;
  final DateTime weekEnd;
  final bool isCompleted;
  final ChallengeDifficulty difficulty;
  final String? bonusReward;

  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.rewardPoints,
    required this.rewardType,
    this.rewardItem,
    required this.weekStart,
    required this.weekEnd,
    required this.isCompleted,
    this.difficulty = ChallengeDifficulty.medium,
    this.bonusReward,
  });

  /// Create weekly challenge from JSON
  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: ChallengeType.values[json['type'] as int],
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int,
      rewardType: RewardType.values[json['rewardType'] as int],
      rewardItem: json['rewardItem'] as String?,
      weekStart: DateTime.fromMillisecondsSinceEpoch(json['weekStart'] as int),
      weekEnd: DateTime.fromMillisecondsSinceEpoch(json['weekEnd'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      difficulty: ChallengeDifficulty.values[json['difficulty'] as int? ?? 1],
      bonusReward: json['bonusReward'] as String?,
    );
  }

  /// Convert weekly challenge to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'rewardPoints': rewardPoints,
      'rewardType': rewardType.index,
      'rewardItem': rewardItem,
      'weekStart': weekStart.millisecondsSinceEpoch,
      'weekEnd': weekEnd.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'difficulty': difficulty.index,
      'bonusReward': bonusReward,
    };
  }

  /// Get progress percentage
  double get progressPercentage {
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get remaining days
  int get remainingDays {
    final now = DateTime.now();
    final difference = weekEnd.difference(now).inDays;
    return difference.clamp(0, 7);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        type,
        targetValue,
        currentValue,
        rewardPoints,
        rewardType,
        rewardItem,
        weekStart,
        weekEnd,
        isCompleted,
        difficulty,
        bonusReward,
      ];

  /// Copy with method
  WeeklyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    ChallengeType? type,
    int? targetValue,
    int? currentValue,
    int? rewardPoints,
    RewardType? rewardType,
    String? rewardItem,
    DateTime? weekStart,
    DateTime? weekEnd,
    bool? isCompleted,
    ChallengeDifficulty? difficulty,
    String? bonusReward,
  }) {
    return WeeklyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardType: rewardType ?? this.rewardType,
      rewardItem: rewardItem ?? this.rewardItem,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      isCompleted: isCompleted ?? this.isCompleted,
      difficulty: difficulty ?? this.difficulty,
      bonusReward: bonusReward ?? this.bonusReward,
    );
  }
}
