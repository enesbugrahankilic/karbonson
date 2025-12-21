// lib/models/daily_challenge.dart
// Daily challenge model for daily tasks and rewards

import 'package:equatable/equatable.dart';

/// Challenge types
enum ChallengeType {
  quiz,
  duel,
  social,
  special,
}

/// Reward types
enum RewardType {
  points,
  achievement,
  feature,
}

/// Daily challenge model
class DailyChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  int currentValue;
  final int rewardPoints;
  final RewardType rewardType;
  final DateTime date;
  bool isCompleted;
  final DateTime expiresAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.rewardPoints,
    required this.rewardType,
    required this.date,
    required this.isCompleted,
    required this.expiresAt,
  });

  /// Create daily challenge from JSON
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
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int),
    );
  }

  /// Convert daily challenge to JSON
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
      'date': date.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
  }

  /// Get progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Get remaining value to complete
  int get remainingValue {
    return (targetValue - currentValue).clamp(0, targetValue);
  }

  /// Check if challenge is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Get challenge type name in Turkish
  String get typeName {
    switch (type) {
      case ChallengeType.quiz:
        return 'Quiz';
      case ChallengeType.duel:
        return 'Düello';
      case ChallengeType.social:
        return 'Sosyal';
      case ChallengeType.special:
        return 'Özel';
    }
  }

  /// Get reward type name in Turkish
  String get rewardTypeName {
    switch (rewardType) {
      case RewardType.points:
        return 'Puan';
      case RewardType.achievement:
        return 'Başarı';
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
        date,
        isCompleted,
        expiresAt,
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
    DateTime? date,
    bool? isCompleted,
    DateTime? expiresAt,
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
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
