// lib/models/profile_data.dart

import '../utils/datetime_parser.dart';

/// Server-side profile data fetched from Firebase
class ServerProfileData {
  final String uid;
  final String nickname;
  final String? profilePictureUrl;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  ServerProfileData({
    required this.uid,
    required this.nickname,
    this.profilePictureUrl,
    this.lastLogin,
    this.createdAt,
  });

  factory ServerProfileData.fromMap(Map<String, dynamic> map) {
    return ServerProfileData(
      uid: map['uid'] ?? '',
      nickname: map['nickname'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      lastLogin: DateTimeParser.parse(map['lastLogin']),
      createdAt: DateTimeParser.parse(map['createdAt']),
    );
  }

  ServerProfileData copyWith({
    String? uid,
    String? nickname,
    String? profilePictureUrl,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return ServerProfileData(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'profilePictureUrl': profilePictureUrl,
      'lastLogin': DateTimeParser.toTimestamp(lastLogin),
      'createdAt': DateTimeParser.toTimestamp(createdAt),
    };
  }
}

/// Local game statistics and history data
class LocalStatisticsData {
  final double winRate;
  final int totalGamesPlayed;
  final int highestScore;
  final int averageScore;
  final List<GameHistoryItem> recentGames;
  final DateTime lastUpdated;

  LocalStatisticsData({
    required this.winRate,
    required this.totalGamesPlayed,
    required this.highestScore,
    required this.averageScore,
    required this.recentGames,
    required this.lastUpdated,
  });

  factory LocalStatisticsData.fromMap(Map<String, dynamic> map) {
    return LocalStatisticsData(
      winRate: (map['winRate'] as num).toDouble(),
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      highestScore: map['highestScore'] ?? 0,
      averageScore: map['averageScore'] ?? 0,
      recentGames: (map['recentGames'] as List<dynamic>?)
          ?.map((item) => GameHistoryItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'winRate': winRate,
      'totalGamesPlayed': totalGamesPlayed,
      'highestScore': highestScore,
      'averageScore': averageScore,
      'recentGames': recentGames.map((item) => item.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LocalStatisticsData.empty() {
    return LocalStatisticsData(
      winRate: 0.0,
      totalGamesPlayed: 0,
      highestScore: 0,
      averageScore: 0,
      recentGames: [],
      lastUpdated: DateTime.now(),
    );
  }
}

/// Individual game history item
class GameHistoryItem {
  final String gameId;
  final int score;
  final bool isWin;
  final DateTime playedAt;
  final String gameType; // 'single', 'multiplayer'

  GameHistoryItem({
    required this.gameId,
    required this.score,
    required this.isWin,
    required this.playedAt,
    required this.gameType,
  });

  factory GameHistoryItem.fromMap(Map<String, dynamic> map) {
    return GameHistoryItem(
      gameId: map['gameId'] ?? '',
      score: map['score'] ?? 0,
      isWin: map['isWin'] ?? false,
      playedAt: DateTime.parse(map['playedAt']),
      gameType: map['gameType'] ?? 'single',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'score': score,
      'isWin': isWin,
      'playedAt': playedAt.toIso8601String(),
      'gameType': gameType,
    };
  }
}

/// Combined profile data for UI
class ProfileData {
  final ServerProfileData? serverData;
  final LocalStatisticsData localData;
  final bool isLoading;
  final String? error;

  ProfileData({
    this.serverData,
    required this.localData,
    this.isLoading = false,
    this.error,
  });

  ProfileData copyWith({
    ServerProfileData? serverData,
    LocalStatisticsData? localData,
    bool? isLoading,
    String? error,
  }) {
    return ProfileData(
      serverData: serverData ?? this.serverData,
      localData: localData ?? this.localData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasServerData => serverData != null;
  bool get hasLocalData => localData.totalGamesPlayed > 0;
}