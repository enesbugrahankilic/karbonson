// lib/models/user_data.dart
// Specification: Identity Management and Data Integrity (UID Centrality)
// All user data structures follow UID-based document ID requirements

import '../services/firestore_service.dart';
import '../utils/datetime_parser.dart';
import '../models/profile_data.dart'; // For GameHistoryItem



/// Server-side user profile data with UID centrality
/// Specification I.1 & I.2: Document ID MUST be Firebase Auth UID
class UserData {
  final String uid;
  final String nickname;
  final String? profilePictureUrl;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isAnonymous;

  // Privacy Settings (Specification II.3)
  final PrivacySettings privacySettings;

  // FCM Token Management (Specification V.2)
  final String? fcmToken;

  // Email Verification
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;

  // 2FA (Multi-Factor Authentication) Fields
  final bool is2FAEnabled;
  final String? phoneNumber;
  final DateTime? last2FAVerification;

  // Game Statistics Fields
  final double winRate;
  final int totalGamesPlayed;
  final int highestScore;
  final int averageScore;
  final List<GameHistoryItem> recentGames;

  // Leaderboard Category Fields
  final int friendCount;           // For "Social Butterflies" category
  final int duelWins;              // For "Duel Champions" category
  final int longestStreak;         // For "Streak Kings" category
  final int quizCount;             // For "Quiz Masters" category

  // Class and Section Information
  final int? classLevel;           // 9, 10, 11, 12
  final String? classSection;      // A, B, C, D, E, F

  const UserData({
    required this.uid,
    required this.nickname,
    this.profilePictureUrl,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.isAnonymous = false,
    this.privacySettings = const PrivacySettings.defaults(),
    this.fcmToken,
    this.isEmailVerified = false,
    this.emailVerifiedAt,
    this.is2FAEnabled = false,
    this.phoneNumber,
    this.last2FAVerification,
    this.winRate = 0.0,
    this.totalGamesPlayed = 0,
    this.highestScore = 0,
    this.averageScore = 0,
    this.recentGames = const [],
    this.friendCount = 0,
    this.duelWins = 0,
    this.longestStreak = 0,
    this.quizCount = 0,
    this.classLevel,
    this.classSection,
  });

  factory UserData.fromMap(Map<String, dynamic> map, String documentId) {
    // Specification I.2: Document ID verification
    assert(
      documentId == map['uid'] || map['uid'] == null,
      'Document ID must match UID for data integrity',
    );

    return UserData(
      uid: documentId, // Always use document ID as UID
      nickname: map['nickname'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      lastLogin: DateTimeParser.parse(map['lastLogin']),
      createdAt: DateTimeParser.parse(map['createdAt']),
      updatedAt: DateTimeParser.parse(map['updatedAt']),
      isAnonymous: map['isAnonymous'] ?? false,
      privacySettings: map['privacySettings'] != null
          ? PrivacySettings.fromMap(
              map['privacySettings'] as Map<String, dynamic>)
          : const PrivacySettings.defaults(),
      fcmToken: map['fcmToken'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      emailVerifiedAt: DateTimeParser.parse(map['emailVerifiedAt']),
      is2FAEnabled: map['is2FAEnabled'] ?? false,
      phoneNumber: map['phoneNumber'],
      last2FAVerification: DateTimeParser.parse(map['last2FAVerification']),
      winRate: (map['winRate'] as num?)?.toDouble() ?? 0.0,
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      highestScore: map['highestScore'] ?? 0,
      averageScore: map['averageScore'] ?? 0,
      recentGames: (map['recentGames'] as List<dynamic>?)
              ?.map((item) => GameHistoryItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      // Leaderboard category fields
      friendCount: map['friendCount'] ?? 0,
      duelWins: map['duelWins'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      quizCount: map['quizCount'] ?? 0,
      // Class and section information
      classLevel: map['classLevel'],
      classSection: map['classSection'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'profilePictureUrl': profilePictureUrl,
      'lastLogin': DateTimeParser.toTimestamp(lastLogin),
      'createdAt': DateTimeParser.toTimestamp(createdAt),
      'updatedAt': DateTimeParser.toTimestamp(updatedAt),
      'isAnonymous': isAnonymous,
      'privacySettings': privacySettings.toMap(),
      'fcmToken': fcmToken,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': DateTimeParser.toTimestamp(emailVerifiedAt),
      'is2FAEnabled': is2FAEnabled,
      'phoneNumber': phoneNumber,
      'last2FAVerification': DateTimeParser.toTimestamp(last2FAVerification),
      'winRate': winRate,
      'totalGamesPlayed': totalGamesPlayed,
      'highestScore': highestScore,
      'averageScore': averageScore,
      'recentGames': recentGames.map((item) => item.toMap()).toList(),
      // Leaderboard category fields
      'friendCount': friendCount,
      'duelWins': duelWins,
      'longestStreak': longestStreak,
      'quizCount': quizCount,
      // Class and section information
      'classLevel': classLevel,
      'classSection': classSection,
    };
  }

  UserData copyWith({
    String? uid,
    String? nickname,
    String? profilePictureUrl,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
    PrivacySettings? privacySettings,
    String? fcmToken,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
    bool? is2FAEnabled,
    String? phoneNumber,
    DateTime? last2FAVerification,
    double? winRate,
    int? totalGamesPlayed,
    int? highestScore,
    int? averageScore,
    List<GameHistoryItem>? recentGames,
    int? friendCount,
    int? duelWins,
    int? longestStreak,
    int? quizCount,
    int? classLevel,
    String? classSection,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      privacySettings: privacySettings ?? this.privacySettings,
      fcmToken: fcmToken ?? this.fcmToken,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      last2FAVerification: last2FAVerification ?? this.last2FAVerification,
      winRate: winRate ?? this.winRate,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      highestScore: highestScore ?? this.highestScore,
      averageScore: averageScore ?? this.averageScore,
      recentGames: recentGames ?? this.recentGames,
      friendCount: friendCount ?? this.friendCount,
      duelWins: duelWins ?? this.duelWins,
      longestStreak: longestStreak ?? this.longestStreak,
      quizCount: quizCount ?? this.quizCount,
      classLevel: classLevel ?? this.classLevel,
      classSection: classSection ?? this.classSection,
    );
  }
}

/// Privacy Settings Implementation (Specification II.3)
/// Controls who can send friend requests and search for users
class PrivacySettings {
  final bool allowFriendRequests; // true = friends only, false = nobody
  final bool allowSearchByNickname;
  final bool allowDiscovery;

  const PrivacySettings({
    this.allowFriendRequests = true,
    this.allowSearchByNickname = true,
    this.allowDiscovery = true,
  });

  const PrivacySettings.defaults()
      : allowFriendRequests = true,
        allowSearchByNickname = true,
        allowDiscovery = true;

  const PrivacySettings.friendsOnly()
      : allowFriendRequests = true,
        allowSearchByNickname = false,
        allowDiscovery = false;

  const PrivacySettings.private()
      : allowFriendRequests = false,
        allowSearchByNickname = false,
        allowDiscovery = false;

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      allowFriendRequests: map['allowFriendRequests'] ?? true,
      allowSearchByNickname: map['allowSearchByNickname'] ?? true,
      allowDiscovery: map['allowDiscovery'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowFriendRequests': allowFriendRequests,
      'allowSearchByNickname': allowSearchByNickname,
      'allowDiscovery': allowDiscovery,
    };
  }

  PrivacySettings copyWith({
    bool? allowFriendRequests,
    bool? allowSearchByNickname,
    bool? allowDiscovery,
  }) {
    return PrivacySettings(
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      allowSearchByNickname:
          allowSearchByNickname ?? this.allowSearchByNickname,
      allowDiscovery: allowDiscovery ?? this.allowDiscovery,
    );
  }
}

/// Nickname validation result
class NicknameValidationResult {
  final bool isValid;
  final String error;

  const NicknameValidationResult({
    required this.isValid,
    this.error = '',
  });
}

/// Nickname validation and filtering (Specification I.4)
class NicknameValidator {
  static const List<String> _bannedWords = [
    // Turkish profanity - this should be expanded with a comprehensive list
    'aptal', 'salak', 'gerizekalı', 'mal',
    // Add more banned words as needed
  ];

  static const int _minLength = 3;
  static const int _maxLength = 20;

  /// Validates nickname according to specification rules
  /// This validates format, length, and content but NOT uniqueness
  static NicknameValidationResult validate(String nickname) {
    if (nickname.isEmpty) {
      return NicknameValidationResult(
        isValid: false,
        error: 'Nickname boş olamaz',
      );
    }

    if (nickname.length < _minLength) {
      return NicknameValidationResult(
        isValid: false,
        error: 'Nickname en az $_minLength karakter olmalı',
      );
    }

    if (nickname.length > _maxLength) {
      return NicknameValidationResult(
        isValid: false,
        error: 'Nickname en fazla $_maxLength karakter olmalı',
      );
    }

    // Check for profanity
    final lowercaseNickname = nickname.toLowerCase();
    for (final bannedWord in _bannedWords) {
      if (lowercaseNickname.contains(bannedWord)) {
        return NicknameValidationResult(
          isValid: false,
          error: 'Nickname uygunsuz kelime içeriyor',
        );
      }
    }

    // Check for valid characters (alphanumeric, underscore, dash)
    final RegExp validChars = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validChars.hasMatch(nickname)) {
      return NicknameValidationResult(
        isValid: false,
        error: 'Nickname sadece harf, rakam, alt çizgi ve tire içerebilir',
      );
    }

    return NicknameValidationResult(isValid: true);
  }

  /// Validates nickname including uniqueness check
  /// This is the comprehensive validation method for registration
  static Future<NicknameValidationResult> validateWithUniqueness(
      String nickname) async {
    // First validate format and content
    final formatValidation = validate(nickname);
    if (!formatValidation.isValid) {
      return formatValidation;
    }

    try {
      // Then check uniqueness with timeout - FAIL OPEN approach
      final firestoreService = FirestoreService();
      final isAvailable = await firestoreService
          .isNicknameAvailable(nickname)
          .timeout(const Duration(seconds: 8));

      if (!isAvailable) {
        return NicknameValidationResult(
          isValid: false,
          error:
              'Bu takma ad zaten kullanılıyor. Lütfen farklı bir takma ad seçin.',
        );
      }

      return NicknameValidationResult(isValid: true);
    } catch (e) {
      // If nickname check fails (network/timeout), allow registration to proceed
      // The uniqueness will be checked again during profile creation
      if (e.toString().contains('timeout') ||
          e.toString().contains('network')) {
        return NicknameValidationResult(
          isValid: true,
          error: '',
        );
      }

      // For other errors, still allow but log
      return NicknameValidationResult(isValid: true);
    }
  }

  /// Checks if nickname can be changed based on cooldown period
  static Future<bool> canChangeNickname(String uid) async {
    // This would typically check Firestore for last change timestamp
    // For now, returning true - implementation would need Firestore check
    return true;
  }
}
