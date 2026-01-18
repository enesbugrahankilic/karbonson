// lib/models/user_progress.dart
// User progress model for tracking achievements and leveling

import 'package:equatable/equatable.dart';

/// User progress model
class UserProgress extends Equatable {
  final String userId;
  final int totalPoints;
  final int level;
  final int experiencePoints;
  final int completedQuizzes;
  final int duelWins;
  final int multiplayerWins;
  final int friendsCount;
  final int loginStreak;
  final DateTime lastLoginDate;
  final List<String> achievements;
  final List<String> unlockedFeatures;
  final int bestScore;
  final int totalTimeSpent; // in minutes
  final Map<String, int> weeklyActivity; // day -> activity count
  final int totalDuels;

  const UserProgress({
    required this.userId,
    required this.totalPoints,
    required this.level,
    required this.experiencePoints,
    required this.completedQuizzes,
    required this.duelWins,
    required this.multiplayerWins,
    required this.friendsCount,
    required this.loginStreak,
    required this.lastLoginDate,
    required this.achievements,
    required this.unlockedFeatures,
    required this.bestScore,
    required this.totalTimeSpent,
    required this.weeklyActivity,
    required this.totalDuels,
  });

  /// Create user progress from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String,
      totalPoints: json['totalPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      completedQuizzes: json['completedQuizzes'] as int? ?? 0,
      duelWins: json['duelWins'] as int? ?? 0,
      multiplayerWins: json['multiplayerWins'] as int? ?? 0,
      friendsCount: json['friendsCount'] as int? ?? 0,
      loginStreak: json['loginStreak'] as int? ?? 0,
      lastLoginDate:
          DateTime.fromMillisecondsSinceEpoch(json['lastLoginDate'] as int),
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      unlockedFeatures:
          List<String>.from(json['unlockedFeatures'] as List? ?? []),
      bestScore: json['bestScore'] as int? ?? 0,
      totalTimeSpent: json['totalTimeSpent'] as int? ?? 0,
      weeklyActivity: Map<String, int>.from(json['weeklyActivity'] as Map? ?? {}),
      totalDuels: json['totalDuels'] as int? ?? 0,
    );
  }

  /// Convert user progress to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'level': level,
      'experiencePoints': experiencePoints,
      'completedQuizzes': completedQuizzes,
      'duelWins': duelWins,
      'multiplayerWins': multiplayerWins,
      'friendsCount': friendsCount,
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate.millisecondsSinceEpoch,
      'achievements': achievements,
      'unlockedFeatures': unlockedFeatures,
      'bestScore': bestScore,
      'totalTimeSpent': totalTimeSpent,
      'weeklyActivity': weeklyActivity,
      'totalDuels': totalDuels,
    };
  }

  /// Get progress percentage to next level
  double get levelProgressPercentage {
    return (experiencePoints / 100).clamp(0.0, 1.0);
  }

  /// Get experience points needed for next level
  int get experienceToNextLevel {
    return 100 - experiencePoints;
  }

  /// Check if user has achievement
  bool hasAchievement(String achievementId) {
    return achievements.contains(achievementId);
  }

  /// Check if user has unlocked feature
  bool hasUnlockedFeature(String featureId) {
    return unlockedFeatures.contains(featureId);
  }

  @override
  List<Object?> get props => [
        userId,
        totalPoints,
        level,
        experiencePoints,
        completedQuizzes,
        duelWins,
        multiplayerWins,
        friendsCount,
        loginStreak,
        lastLoginDate,
        achievements,
        unlockedFeatures,
        bestScore,
        totalTimeSpent,
        weeklyActivity,
        totalDuels,
      ];

  /// Copy with method
  UserProgress copyWith({
    String? userId,
    int? totalPoints,
    int? level,
    int? experiencePoints,
    int? completedQuizzes,
    int? duelWins,
    int? multiplayerWins,
    int? friendsCount,
    int? loginStreak,
    DateTime? lastLoginDate,
    List<String>? achievements,
    List<String>? unlockedFeatures,
    int? bestScore,
    int? totalTimeSpent,
    Map<String, int>? weeklyActivity,
    int? totalDuels,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
      duelWins: duelWins ?? this.duelWins,
      multiplayerWins: multiplayerWins ?? this.multiplayerWins,
      friendsCount: friendsCount ?? this.friendsCount,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      achievements: achievements ?? this.achievements,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      bestScore: bestScore ?? this.bestScore,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      totalDuels: totalDuels ?? this.totalDuels,
    );
  }
}
