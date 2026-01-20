// lib/models/friend_suggestion.dart
// Friend Suggestion Model - Friend recommendation system

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a friend suggestion in the system
/// Used for recommending friends based on various criteria
class FriendSuggestion {
  final String userId;
  final String nickname;
  final String? profilePictureUrl;
  final SuggestionReason reason;
  final int score; // Recommendation score (higher = better)
  final int commonFriendsCount;
  final DateTime? lastPlayedTogether;
  final int totalGamesPlayed;
  final int winRate;
  final DateTime? lastActive;

  FriendSuggestion({
    required this.userId,
    required this.nickname,
    this.profilePictureUrl,
    this.reason = SuggestionReason.other,
    this.score = 0,
    this.commonFriendsCount = 0,
    this.lastPlayedTogether,
    this.totalGamesPlayed = 0,
    this.winRate = 0,
    this.lastActive,
  });

  factory FriendSuggestion.fromMap(Map<String, dynamic> map) {
    return FriendSuggestion(
      userId: map['userId'] ?? '',
      nickname: map['nickname'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      reason: SuggestionReason.fromString(map['reason'] ?? 'other'),
      score: map['score'] ?? 0,
      commonFriendsCount: map['commonFriendsCount'] ?? 0,
      lastPlayedTogether: map['lastPlayedTogether'] != null
          ? (map['lastPlayedTogether'] as Timestamp).toDate()
          : null,
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      winRate: map['winRate'] ?? 0,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nickname': nickname,
      'profilePictureUrl': profilePictureUrl,
      'reason': reason.toString().split('.').last,
      'score': score,
      'commonFriendsCount': commonFriendsCount,
      'lastPlayedTogether': lastPlayedTogether != null
          ? Timestamp.fromDate(lastPlayedTogether!)
          : null,
      'totalGamesPlayed': totalGamesPlayed,
      'winRate': winRate,
      'lastActive': lastActive != null
          ? Timestamp.fromDate(lastActive!)
          : null,
    };
  }

  FriendSuggestion copyWith({
    String? userId,
    String? nickname,
    String? profilePictureUrl,
    SuggestionReason? reason,
    int? score,
    int? commonFriendsCount,
    DateTime? lastPlayedTogether,
    int? totalGamesPlayed,
    int? winRate,
    DateTime? lastActive,
  }) {
    return FriendSuggestion(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      reason: reason ?? this.reason,
      score: score ?? this.score,
      commonFriendsCount: commonFriendsCount ?? this.commonFriendsCount,
      lastPlayedTogether: lastPlayedTogether ?? this.lastPlayedTogether,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      winRate: winRate ?? this.winRate,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  String toString() {
    return 'FriendSuggestion(userId: $userId, nickname: $nickname, reason: $reason, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendSuggestion && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// Reason for the friend suggestion
enum SuggestionReason {
  commonFriends,      // Ortak arkadaşlar
  recentlyPlayed,     // Son oynanan oyunlar
  leaderboard,        // Liderlik tablosu yakını
  nearby,             // Yakın konum (gelecek)
  suggested,          // AI önerisi (gelecek)
  popular,            // Popüler oyuncular
  other;              // Diğer

  static SuggestionReason fromString(String reason) {
    switch (reason.toLowerCase()) {
      case 'commonfriends':
      case 'common_friends':
        return SuggestionReason.commonFriends;
      case 'recentlyplayed':
      case 'recently_played':
        return SuggestionReason.recentlyPlayed;
      case 'leaderboard':
        return SuggestionReason.leaderboard;
      case 'nearby':
        return SuggestionReason.nearby;
      case 'suggested':
        return SuggestionReason.suggested;
      case 'popular':
        return SuggestionReason.popular;
      default:
        return SuggestionReason.other;
    }
  }

  String get displayName {
    switch (this) {
      case SuggestionReason.commonFriends:
        return 'Ortak Arkadaşlar';
      case SuggestionReason.recentlyPlayed:
        return 'Birlikte Oynadıklarınız';
      case SuggestionReason.leaderboard:
        return 'Liderlik Tablosu';
      case SuggestionReason.nearby:
        return 'Yakınınızdaki Oyuncular';
      case SuggestionReason.suggested:
        return 'Önerilen';
      case SuggestionReason.popular:
        return 'Popüler Oyuncular';
      case SuggestionReason.other:
        return 'Öneriler';
    }
  }

  String get description {
    switch (this) {
      case SuggestionReason.commonFriends:
        return 'Ortak arkadaşlarınız olan oyuncular';
      case SuggestionReason.recentlyPlayed:
        return 'Son zamanlarda birlikte oynadığınız oyuncular';
      case SuggestionReason.leaderboard:
        return 'Skorunıza yakın oyuncular';
      case SuggestionReason.nearby:
        return 'Yakınınızdaki oyuncular';
      case SuggestionReason.suggested:
        return 'Sizin için önerilen oyuncular';
      case SuggestionReason.popular:
        return 'Popüler oyuncular';
      case SuggestionReason.other:
        return 'Önerilen oyuncular';
    }
  }

  String get icon {
    switch (this) {
      case SuggestionReason.commonFriends:
        return '👥';
      case SuggestionReason.recentlyPlayed:
        return '🎮';
      case SuggestionReason.leaderboard:
        return '🏆';
      case SuggestionReason.nearby:
        return '📍';
      case SuggestionReason.suggested:
        return '✨';
      case SuggestionReason.popular:
        return '⭐';
      case SuggestionReason.other:
        return '👤';
    }
  }
}

/// Result class for friend suggestion operations
class FriendSuggestionResult {
  final bool success;
  final String? error;
  final List<FriendSuggestion> suggestions;

  FriendSuggestionResult({
    required this.success,
    this.error,
    this.suggestions = const [],
  });

  factory FriendSuggestionResult.success(List<FriendSuggestion> suggestions) {
    return FriendSuggestionResult(
      success: true,
      suggestions: suggestions,
    );
  }

  factory FriendSuggestionResult.failure(String error) {
    return FriendSuggestionResult(
      success: false,
      error: error,
    );
  }
}

/// Group of suggestions by reason
class GroupedFriendSuggestions {
  final SuggestionReason reason;
  final List<FriendSuggestion> suggestions;

  GroupedFriendSuggestions({
    required this.reason,
    required this.suggestions,
  });
}

