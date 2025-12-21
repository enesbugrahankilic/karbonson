// lib/services/profile_service.dart
// Updated with UID Centrality and Privacy Settings (Specification I.1-I.4, II.3)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile_data.dart';
import '../models/user_data.dart';
import 'firestore_service.dart';
import 'firebase_auth_service.dart';

class ProfileService {
  static const String _localStatsKey = 'user_game_statistics';
  static const String _localUidKey = 'cached_user_uid';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Load local statistics data from SharedPreferences
  Future<LocalStatisticsData> loadLocalStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_localStatsKey);

      if (statsJson != null) {
        final statsMap = json.decode(statsJson);
        return LocalStatisticsData.fromMap(statsMap);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading local statistics: $e');
    }

    return LocalStatisticsData.empty();
  }

  /// Save local statistics data to SharedPreferences
  Future<bool> saveLocalStatistics(LocalStatisticsData stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toMap());
      return await prefs.setString(_localStatsKey, statsJson);
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving local statistics: $e');
      return false;
    }
  }

  /// Load server profile data from Firebase with UID Centrality (Specification I.1-I.2)
  Future<UserData?> loadServerProfile({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('No authenticated user found');
        return null;
      }

      // Use provided UID if available, otherwise use current user's UID
      final targetUid = uid ?? user.uid;
      final userData = await _firestoreService.getUserProfile(targetUid);
      return userData;
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading server profile: $e');
    }

    return null;
  }

  /// Update profile picture URL
  Future<bool> updateProfilePicture(String imageUrl) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode)
          debugPrint('❌ No user available for profile picture update');
        return false;
      }

      if (kDebugMode) {
        debugPrint('📸 Updating profile picture for user: ${user.uid}');
        debugPrint('📸 New image URL: $imageUrl');
      }

      // Get current user profile
      final currentProfile = await _firestoreService.getUserProfile(user.uid);
      if (currentProfile == null) {
        if (kDebugMode)
          debugPrint('❌ User profile not found for picture update');
        return false;
      }

      // Create updated user data with new profile picture URL
      final updatedUserData = currentProfile.copyWith(
        profilePictureUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      if (kDebugMode) {
        debugPrint(
            '📸 Updated user data prepared: ${updatedUserData.nickname}');
      }

      // Save updated profile
      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
      );

      if (success != null && kDebugMode) {
        debugPrint(
            '✅ Profile picture updated successfully: ${updatedUserData.profilePictureUrl}');
      } else if (kDebugMode) {
        debugPrint('❌ Failed to update profile picture');
      }

      return success != null;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating profile picture: $e');
      return false;
    }
  }

  /// Update user profile in Firebase with UID Centrality (Specification I.1-I.2)
  Future<bool> updateServerProfile(UserData userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userData.uid) return false;

      final updatedUserData = userData.copyWith(
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
        fcmToken: updatedUserData.fcmToken,
      );

      return success != null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating server profile: $e');
      return false;
    }
  }

  /// Add a new game result to local statistics
  Future<void> addGameResult({
    required int score,
    required bool isWin,
    required String gameType,
  }) async {
    try {
      final currentStats = await loadLocalStatistics();

      // Create new game history item
      final newGame = GameHistoryItem(
        gameId: DateTime.now().millisecondsSinceEpoch.toString(),
        score: score,
        isWin: isWin,
        playedAt: DateTime.now(),
        gameType: gameType,
      );

      // Update recent games (keep only last 10 games)
      final updatedGames =
          [newGame, ...currentStats.recentGames].take(10).toList();

      // Calculate new statistics
      final totalGames = currentStats.totalGamesPlayed + 1;
      final totalWins = currentStats.recentGames.where((g) => g.isWin).length +
          (isWin ? 1 : 0);
      final newWinRate = totalGames > 0 ? (totalWins / totalGames) : 0.0;

      // Calculate new average score
      final totalScore = currentStats.recentGames
              .fold<int>(0, (total, game) => total + game.score) +
          score;
      final newAverageScore =
          totalGames > 0 ? (totalScore / totalGames).round() : score;

      // Update highest score if needed
      final newHighestScore =
          score > currentStats.highestScore ? score : currentStats.highestScore;

      final updatedStats = LocalStatisticsData(
        winRate: newWinRate,
        totalGamesPlayed: totalGames,
        highestScore: newHighestScore,
        averageScore: newAverageScore,
        recentGames: updatedGames,
        lastUpdated: DateTime.now(),
      );

      await saveLocalStatistics(updatedStats);
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding game result: $e');
    }
  }

  /// Convert UserData to ServerProfileData for backward compatibility
  ServerProfileData? _convertUserDataToServerProfileData(UserData? userData) {
    if (userData == null) return null;

    return ServerProfileData(
      uid: userData.uid,
      nickname: userData.nickname,
      profilePictureUrl: userData.profilePictureUrl,
      lastLogin: userData.lastLogin,
      createdAt: userData.createdAt,
    );
  }

  /// Get combined profile data with prioritized loading strategy (Specification III.1-III.2)
  Future<ProfileData> getProfileData() async {
    // First priority: Load local data immediately
    final localData = await loadLocalStatistics();

    // Second priority: Load server data in background with UID centrality
    final userData = await loadServerProfile();
    final serverData = _convertUserDataToServerProfileData(userData);

    return ProfileData(
      serverData: serverData,
      localData: localData,
      isLoading: false,
    );
  }

  /// Refresh server data only (for background updates)
  Future<ProfileData> refreshServerData(ProfileData currentProfile) async {
    final userData = await loadServerProfile();
    final serverData = _convertUserDataToServerProfileData(userData);
    if (serverData != null) {
      return currentProfile.copyWith(serverData: serverData);
    }
    return currentProfile;
  }

  /// Initialize profile for a new user with UID Centrality (Specification I.1-I.2)
  /// Now accepts user parameter to avoid race condition
  Future<void> initializeProfile({
    required String nickname,
    String? profilePictureUrl,
    PrivacySettings? privacySettings,
    User? user, // Accept user parameter to avoid race condition
  }) async {
    try {
      final currentUser = user ?? _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode)
          debugPrint('❌ No user available for profile initialization');
        return;
      }

      // Initialize server profile with UID centrality
      await _firestoreService.createOrUpdateUserProfile(
        nickname: nickname,
        profilePictureUrl: profilePictureUrl,
        privacySettings: privacySettings,
      );

      // Initialize local statistics
      await saveLocalStatistics(LocalStatisticsData.empty());

      // Cache UID locally for offline access
      await cacheUid(currentUser.uid);
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing profile: $e');
    }
  }

  /// Update nickname with validation (Specification I.4)
  Future<bool> updateNickname(String newNickname) async {
    return await _firestoreService.updateUserNickname(newNickname);
  }

  /// Copy UID to clipboard helper method (for UI use)
  static String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  /// Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  /// Get current user UID with validation (Specification I.1)
  String? get currentUserUid => _firestoreService.currentUserId;

  /// Get current user nickname from cache or server
  Future<String?> getCurrentNickname() async {
    // First try to get from local cache
    final prefs = await SharedPreferences.getInstance();
    final cachedNickname = prefs.getString('cached_nickname');

    if (cachedNickname != null) {
      return cachedNickname;
    }

    // Fallback to server data
    final serverData = await loadServerProfile();
    if (serverData != null) {
      await prefs.setString('cached_nickname', serverData.nickname);
      return serverData.nickname;
    }

    return null;
  }

  /// Cache nickname locally
  Future<void> cacheNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_nickname', nickname);
  }

  /// Cache UID locally for offline access (Specification I.1)
  Future<void> cacheUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUidKey, uid);
  }

  /// Get cached UID for offline access
  Future<String?> getCachedUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localUidKey);
  }

  /// Update privacy settings (Specification II.3)
  Future<bool> updatePrivacySettings(PrivacySettings privacySettings) async {
    return await _firestoreService.updatePrivacySettings(privacySettings);
  }

  /// Check if user is authenticated with UID validation
  bool get isUserAuthenticated => _firestoreService.isUserAuthenticated;

  /// Check if user is registered (has email/password account vs anonymous)
  Future<bool> isUserRegistered() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user has email (indicates registration) and is not anonymous
      final isEmailUser = user.email != null && user.email!.isNotEmpty;
      final isAnonymous = user.isAnonymous;

      return isEmailUser && !isAnonymous;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking registration status: $e');
      return false;
    }
  }

  /// Copy UID to clipboard helper method (Specification III.3)
  static Future<void> copyUidToClipboard(String uid) async {
    // This would typically use the clipboard package
    // For now, just return - implementation would depend on the clipboard service
    if (kDebugMode) debugPrint('Copy to clipboard: $uid');
  }

  /// Email verification methods
  /// Check if current user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Reload user data to get latest verification status
      await user.reload();

      return user.emailVerified;
    } catch (e) {
      if (kDebugMode)
        debugPrint('Error checking email verification status: $e');
      return false;
    }
  }

  /// Get email verification status with detailed information
  Future<EmailVerificationStatus> getEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return EmailVerificationStatus(
          isVerified: false,
          hasEmail: false,
          email: null,
          message: 'Kullanıcı oturumu bulunamadı',
        );
      }

      // Reload user to get latest email verification status
      await user.reload();
      final currentUser = _auth.currentUser!;

      final hasEmail =
          currentUser.email != null && currentUser.email!.isNotEmpty;
      final isVerified = currentUser.emailVerified;

      return EmailVerificationStatus(
        isVerified: isVerified,
        hasEmail: hasEmail,
        email: currentUser.email,
        message: isVerified
            ? 'E-posta adresi doğrulanmış'
            : 'E-posta adresi doğrulanmamış',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting email verification status: $e');
      return EmailVerificationStatus(
        isVerified: false,
        hasEmail: false,
        email: null,
        message: 'Doğrulama durumu kontrol edilemedi',
      );
    }
  }

  /// Update user profile with email verification status
  Future<bool> updateEmailVerificationStatus(bool isVerified) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get current user profile
      final userData = await _firestoreService.getUserProfile(user.uid);
      if (userData == null) return false;

      // Update email verification status
      final updatedUserData = userData.copyWith(
        isEmailVerified: isVerified,
        emailVerifiedAt: isVerified ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      // Save updated profile
      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
        fcmToken: updatedUserData.fcmToken,
      );

      return success != null;
    } catch (e) {
      if (kDebugMode)
        debugPrint('Error updating email verification status: $e');
      return false;
    }
  }

  /// Sync email verification status between Firebase Auth and Firestore
  Future<bool> syncEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get current verification status from Firebase Auth
      await user.reload();
      final isVerified = user.emailVerified;

      // Update Firestore profile with verification status
      return await updateEmailVerificationStatus(isVerified);
    } catch (e) {
      if (kDebugMode) debugPrint('Error syncing email verification status: $e');
      return false;
    }
  }

  /// ============================================
  /// 2FA (Multi-Factor Authentication) Methods
  /// ============================================

  /// Update user profile with 2FA status
  Future<bool> update2FAStatus(bool is2FAEnabled, String? phoneNumber) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Get current user profile
      final userData = await _firestoreService.getUserProfile(user.uid);
      if (userData == null) return false;

      // Update 2FA status
      final updatedUserData = userData.copyWith(
        is2FAEnabled: is2FAEnabled,
        phoneNumber: phoneNumber,
        last2FAVerification: is2FAEnabled ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      // Save updated profile
      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
        fcmToken: updatedUserData.fcmToken,
      );

      return success != null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating 2FA status: $e');
      return false;
    }
  }

  /// Get 2FA status information for current user
  Future<Map<String, dynamic>> get2FAStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'is2FAEnabled': false,
          'phoneNumber': null,
          'last2FAVerification': null,
        };
      }

      // Get current user profile
      final userData = await _firestoreService.getUserProfile(user.uid);
      if (userData == null) {
        return {
          'is2FAEnabled': false,
          'phoneNumber': null,
          'last2FAVerification': null,
        };
      }

      return {
        'is2FAEnabled': userData.is2FAEnabled,
        'phoneNumber': userData.phoneNumber,
        'last2FAVerification': userData.last2FAVerification,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting 2FA status: $e');
      return {
        'is2FAEnabled': false,
        'phoneNumber': null,
        'last2FAVerification': null,
      };
    }
  }

  /// Sync 2FA status with Firebase Auth state
  Future<bool> sync2FAStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user has phone provider linked (indicates 2FA is enabled)
      final hasPhoneProvider =
          user.providerData.any((provider) => provider.providerId == 'phone');

      // Get the phone number if available
      String? phoneNumber;
      if (hasPhoneProvider) {
        final phoneProvider = user.providerData
            .firstWhere((provider) => provider.providerId == 'phone');
        phoneNumber = phoneProvider.phoneNumber;
      }

      // Update Firestore profile with 2FA status
      return await update2FAStatus(hasPhoneProvider, phoneNumber);
    } catch (e) {
      if (kDebugMode) debugPrint('Error syncing 2FA status: $e');
      return false;
    }
  }
}
