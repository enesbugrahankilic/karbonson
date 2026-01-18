// lib/models/seasonal_event.dart
// Seasonal events and special challenges model

import 'package:equatable/equatable.dart';

/// Seasonal event types
enum SeasonalEventType {
  holiday,
  competition,
  celebration,
  tournament,
}

/// Seasonal event status
enum SeasonalEventStatus {
  upcoming,
  active,
  completed,
  expired,
}

/// Seasonal event model
class SeasonalEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final SeasonalEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final SeasonalEventStatus status;
  final List<String> challengeIds; // IDs of related challenges
  final Map<String, dynamic> rewards;
  final String? themeColor;
  final String? bannerImage;

  const SeasonalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.challengeIds,
    required this.rewards,
    this.themeColor,
    this.bannerImage,
  });

  /// Create event from JSON
  factory SeasonalEvent.fromJson(Map<String, dynamic> json) {
    return SeasonalEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: SeasonalEventType.values[json['type'] as int],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int),
      status: SeasonalEventStatus.values[json['status'] as int],
      challengeIds: List<String>.from(json['challengeIds'] as List),
      rewards: Map<String, dynamic>.from(json['rewards'] as Map),
      themeColor: json['themeColor'] as String?,
      bannerImage: json['bannerImage'] as String?,
    );
  }

  /// Convert event to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.index,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'status': status.index,
      'challengeIds': challengeIds,
      'rewards': rewards,
      'themeColor': themeColor,
      'bannerImage': bannerImage,
    };
  }

  /// Get event type name in Turkish
  String get typeName {
    switch (type) {
      case SeasonalEventType.holiday:
        return 'Tatil';
      case SeasonalEventType.competition:
        return 'Yarışma';
      case SeasonalEventType.celebration:
        return 'Kutlama';
      case SeasonalEventType.tournament:
        return 'Turnuva';
    }
  }

  /// Get status name in Turkish
  String get statusName {
    switch (status) {
      case SeasonalEventStatus.upcoming:
        return 'Yaklaşan';
      case SeasonalEventStatus.active:
        return 'Aktif';
      case SeasonalEventStatus.completed:
        return 'Tamamlandı';
      case SeasonalEventStatus.expired:
        return 'Süresi Doldu';
    }
  }

  /// Check if event is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == SeasonalEventStatus.active &&
           now.isAfter(startDate) &&
           now.isBefore(endDate);
  }

  /// Get days remaining until event starts
  int get daysUntilStart {
    final now = DateTime.now();
    return startDate.difference(now).inDays;
  }

  /// Get days remaining until event ends
  int get daysUntilEnd {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        type,
        startDate,
        endDate,
        status,
        challengeIds,
        rewards,
        themeColor,
        bannerImage,
      ];

  /// Copy with method
  SeasonalEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    SeasonalEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    SeasonalEventStatus? status,
    List<String>? challengeIds,
    Map<String, dynamic>? rewards,
    String? themeColor,
    String? bannerImage,
  }) {
    return SeasonalEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      challengeIds: challengeIds ?? this.challengeIds,
      rewards: rewards ?? this.rewards,
      themeColor: themeColor ?? this.themeColor,
      bannerImage: bannerImage ?? this.bannerImage,
    );
  }
}

/// User participation in seasonal event
class UserSeasonalParticipation extends Equatable {
  final String userId;
  final String eventId;
  final int pointsEarned;
  final int challengesCompleted;
  final List<String> rewardsClaimed;
  final DateTime joinedAt;
  final DateTime? lastActivity;

  const UserSeasonalParticipation({
    required this.userId,
    required this.eventId,
    required this.pointsEarned,
    required this.challengesCompleted,
    required this.rewardsClaimed,
    required this.joinedAt,
    this.lastActivity,
  });

  /// Create participation from JSON
  factory UserSeasonalParticipation.fromJson(Map<String, dynamic> json) {
    return UserSeasonalParticipation(
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      challengesCompleted: json['challengesCompleted'] as int? ?? 0,
      rewardsClaimed: List<String>.from(json['rewardsClaimed'] as List? ?? []),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(json['joinedAt'] as int),
      lastActivity: json['lastActivity'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastActivity'] as int)
          : null,
    );
  }

  /// Convert participation to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'pointsEarned': pointsEarned,
      'challengesCompleted': challengesCompleted,
      'rewardsClaimed': rewardsClaimed,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'lastActivity': lastActivity?.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        eventId,
        pointsEarned,
        challengesCompleted,
        rewardsClaimed,
        joinedAt,
        lastActivity,
      ];

  /// Copy with method
  UserSeasonalParticipation copyWith({
    String? userId,
    String? eventId,
    int? pointsEarned,
    int? challengesCompleted,
    List<String>? rewardsClaimed,
    DateTime? joinedAt,
    DateTime? lastActivity,
  }) {
    return UserSeasonalParticipation(
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      rewardsClaimed: rewardsClaimed ?? this.rewardsClaimed,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}