// lib/services/profile_service.dart
// Updated with UID Centrality and Privacy Settings (Specification I.1-I.4, II.3)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/profile_data.dart';
import '../models/user_data.dart';
import 'firestore_service.dart';

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
  Future<UserData?> loadServerProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userData = await _firestoreService.getUserProfile(user.uid);
      return userData;
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading server profile: $e');
    }
    
    return null;
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
      final updatedGames = [newGame, ...currentStats.recentGames].take(10).toList();

      // Calculate new statistics
      final totalGames = currentStats.totalGamesPlayed + 1;
      final totalWins = currentStats.recentGames.where((g) => g.isWin).length + (isWin ? 1 : 0);
      final newWinRate = totalGames > 0 ? (totalWins / totalGames) : 0.0;
      
      // Calculate new average score
      final totalScore = currentStats.recentGames.fold<int>(0, (total, game) => total + game.score) + score;
      final newAverageScore = totalGames > 0 ? (totalScore / totalGames).round() : score;
      
      // Update highest score if needed
      final newHighestScore = score > currentStats.highestScore ? score : currentStats.highestScore;

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
  Future<void> initializeProfile({
    required String nickname,
    String? profilePictureUrl,
    PrivacySettings? privacySettings,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Initialize server profile with UID centrality
      await _firestoreService.createOrUpdateUserProfile(
        nickname: nickname,
        profilePictureUrl: profilePictureUrl,
        privacySettings: privacySettings,
      );

      // Initialize local statistics
      await saveLocalStatistics(LocalStatisticsData.empty());
      
      // Cache UID locally for offline access
      await cacheUid(user.uid);
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

  /// Copy UID to clipboard helper method (Specification III.3)
  static Future<void> copyUidToClipboard(String uid) async {
    // This would typically use the clipboard package
    // For now, just return - implementation would depend on the clipboard service
    if (kDebugMode) debugPrint('Copy to clipboard: $uid');
  }
}