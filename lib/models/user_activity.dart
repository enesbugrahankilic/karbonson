// lib/models/user_activity.dart
// User activity model for tracking recent activities

import 'package:equatable/equatable.dart';

enum ActivityType {
  quizCompleted,
  friendAdded,
  duelWon,
  achievementUnlocked,
  levelUp,
  loginStreak,
}

class UserActivity extends Equatable {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const UserActivity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: ActivityType.values[json['type'] as int],
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'title': title,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, userId, type, title, description, timestamp, metadata];
}