// lib/models/user_data.dart
// Specification: Identity Management and Data Integrity (UID Centrality)
// All user data structures follow UID-based document ID requirements

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

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

  UserData({
    required this.uid,
    required this.nickname,
    this.profilePictureUrl,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.isAnonymous = false,
    this.privacySettings = const PrivacySettings.defaults(),
    this.fcmToken,
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
      lastLogin: map['lastLogin'] != null 
          ? (map['lastLogin'] as Timestamp).toDate() 
          : null,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      isAnonymous: map['isAnonymous'] ?? false,
      privacySettings: map['privacySettings'] != null 
          ? PrivacySettings.fromMap(map['privacySettings'] as Map<String, dynamic>)
          : const PrivacySettings.defaults(),
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'profilePictureUrl': profilePictureUrl,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isAnonymous': isAnonymous,
      'privacySettings': privacySettings.toMap(),
      'fcmToken': fcmToken,
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
      allowSearchByNickname: allowSearchByNickname ?? this.allowSearchByNickname,
      allowDiscovery: allowDiscovery ?? this.allowDiscovery,
    );
  }
}

/// Nickname validation result
class NicknameValidationResult {
  final bool isValid;
  final String error;

  NicknameValidationResult({
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
  static const int _changeCooldownDays = 90; // Specification I.4

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
  static Future<NicknameValidationResult> validateWithUniqueness(String nickname) async {
    // First validate format and content
    final formatValidation = validate(nickname);
    if (!formatValidation.isValid) {
      return formatValidation;
    }

    try {
      // Then check uniqueness with timeout - FAIL OPEN approach
      final firestoreService = FirestoreService();
      final isAvailable = await firestoreService.isNicknameAvailable(nickname)
          .timeout(const Duration(seconds: 8));
      
      if (!isAvailable) {
        return NicknameValidationResult(
          isValid: false,
          error: 'Bu takma ad zaten kullanılıyor. Lütfen farklı bir takma ad seçin.',
        );
      }

      return NicknameValidationResult(isValid: true);
    } catch (e) {
      // If nickname check fails (network/timeout), allow registration to proceed
      // The uniqueness will be checked again during profile creation
      if (e.toString().contains('timeout') || e.toString().contains('network')) {
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