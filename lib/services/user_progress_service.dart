// lib/services/user_progress_service.dart
// User Progress Management with Firestore Integration
// UID Centrality: Document ID = Firebase Auth UID

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress.dart';

/// User Progress Service for managing game statistics and achievements
class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name
  static const String _collectionName = 'user_progress';

  /// Get user progress data from Firestore
  Future<UserProgress?> getUserProgress({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return null;
      }

      final targetUid = uid ?? user.uid;
      
      final doc = await _firestore
          .collection(_collectionName)
          .doc(targetUid)
          .get();

      if (!doc.exists) {
        if (kDebugMode) debugPrint('📄 No progress data found for user: $targetUid');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        if (kDebugMode) debugPrint('⚠️ Empty progress data for user: $targetUid');
        return null;
      }

      // Add userId to data before creating UserProgress
      final progressData = Map<String, dynamic>.from(data);
      progressData['userId'] = targetUid;

      return UserProgress.fromJson(progressData);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user progress: $e');
      return null;
    }
  }

  /// Create or update user progress
  Future<bool> saveUserProgress(UserProgress progress) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != progress.userId) {
        if (kDebugMode) debugPrint('❌ Invalid user for progress update');
        return false;
      }

      final progressData = progress.toJson();
      
      await _firestore
          .collection(_collectionName)
          .doc(progress.userId)
          .set(progressData, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('✅ User progress saved for: ${progress.userId}');
        debugPrint('📊 Level: ${progress.level}, Points: ${progress.totalPoints}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error saving user progress: $e');
      return false;
    }
  }

  /// Initialize progress for new user
  Future<UserProgress?> initializeUserProgress(String uid) async {
    try {
      final newProgress = UserProgress(
        userId: uid,
        totalPoints: 0,
        level: 1,
        experiencePoints: 0,
        completedQuizzes: 0,
        duelWins: 0,
        multiplayerWins: 0,
        friendsCount: 0,
        loginStreak: 1,
        lastLoginDate: DateTime.now(),
        achievements: [],
        unlockedFeatures: [],
      );

      final success = await saveUserProgress(newProgress);
      return success ? newProgress : null;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error initializing user progress: $e');
      return null;
    }
  }

  /// Update total points
  Future<bool> addPoints(int points, {String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      var updatedProgress = currentProgress.copyWith(
        totalPoints: currentProgress.totalPoints + points,
        experiencePoints: currentProgress.experiencePoints + points,
      );

      // Check for level up
      final newLevel = _calculateLevel(updatedProgress.experiencePoints);
      if (newLevel > currentProgress.level) {
        updatedProgress = updatedProgress.copyWith(level: newLevel);
        if (kDebugMode) {
          debugPrint('🎉 Level up! New level: $newLevel');
        }
      }

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error adding points: $e');
      return false;
    }
  }

  /// Complete quiz and update progress
  Future<bool> completeQuiz({
    required int score,
    bool isWin = false,
    String? uid,
  }) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      var updatedProgress = currentProgress.copyWith(
        completedQuizzes: currentProgress.completedQuizzes + 1,
        totalPoints: currentProgress.totalPoints + score,
        experiencePoints: currentProgress.experiencePoints + score,
      );

      // Check for level up
      final newLevel = _calculateLevel(updatedProgress.experiencePoints);
      if (newLevel > currentProgress.level) {
        updatedProgress = updatedProgress.copyWith(level: newLevel);
        if (kDebugMode) {
          debugPrint('🎉 Level up after quiz! New level: $newLevel');
        }
      }

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error completing quiz: $e');
      return false;
    }
  }

  /// Record duel win
  Future<bool> recordDuelWin({String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      final updatedProgress = currentProgress.copyWith(
        duelWins: currentProgress.duelWins + 1,
        totalPoints: currentProgress.totalPoints + 50, // Bonus points for duel win
      );

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error recording duel win: $e');
      return false;
    }
  }

  /// Record multiplayer win
  Future<bool> recordMultiplayerWin({String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      final updatedProgress = currentProgress.copyWith(
        multiplayerWins: currentProgress.multiplayerWins + 1,
        totalPoints: currentProgress.totalPoints + 75, // Bonus points for multiplayer win
      );

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error recording multiplayer win: $e');
      return false;
    }
  }

  /// Update friends count
  Future<bool> updateFriendsCount(int count, {String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      final updatedProgress = currentProgress.copyWith(
        friendsCount: count,
      );

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating friends count: $e');
      return false;
    }
  }

  /// Update login streak
  Future<bool> updateLoginStreak({String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      final now = DateTime.now();
      final lastLogin = currentProgress.lastLoginDate;
      
      // Calculate days difference
      final daysDifference = now.difference(lastLogin).inDays;

      int newStreak = currentProgress.loginStreak;
      
      if (daysDifference == 1) {
        // Consecutive day
        newStreak = currentProgress.loginStreak + 1;
      } else if (daysDifference > 1) {
        // Streak broken
        newStreak = 1;
      }
      // If same day (daysDifference == 0), keep current streak

      final updatedProgress = currentProgress.copyWith(
        loginStreak: newStreak,
        lastLoginDate: now,
        totalPoints: currentProgress.totalPoints + newStreak, // Bonus points for streak
      );

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating login streak: $e');
      return false;
    }
  }

  /// Add achievement
  Future<bool> addAchievement(String achievementId, {String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      // Check if achievement already exists
      if (currentProgress.achievements.contains(achievementId)) {
        if (kDebugMode) debugPrint('⚠️ Achievement already exists: $achievementId');
        return true;
      }

      final updatedAchievements = [...currentProgress.achievements, achievementId];
      
      final updatedProgress = currentProgress.copyWith(
        achievements: updatedAchievements,
        totalPoints: currentProgress.totalPoints + 100, // Achievement bonus
      );

      if (kDebugMode) {
        debugPrint('🏆 New achievement unlocked: $achievementId');
      }

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error adding achievement: $e');
      return false;
    }
  }

  /// Unlock feature
  Future<bool> unlockFeature(String featureId, {String? uid}) async {
    try {
      final currentProgress = await getUserProgress(uid: uid);
      if (currentProgress == null) return false;

      // Check if feature already unlocked
      if (currentProgress.unlockedFeatures.contains(featureId)) {
        if (kDebugMode) debugPrint('⚠️ Feature already unlocked: $featureId');
        return true;
      }

      final updatedFeatures = [...currentProgress.unlockedFeatures, featureId];
      
      final updatedProgress = currentProgress.copyWith(
        unlockedFeatures: updatedFeatures,
      );

      if (kDebugMode) {
        debugPrint('🔓 Feature unlocked: $featureId');
      }

      return await saveUserProgress(updatedProgress);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error unlocking feature: $e');
      return false;
    }
  }

  /// Check if user has achievement
  Future<bool> hasAchievement(String achievementId, {String? uid}) async {
    try {
      final progress = await getUserProgress(uid: uid);
      return progress?.achievements.contains(achievementId) ?? false;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking achievement: $e');
      return false;
    }
  }

  /// Check if user has unlocked feature
  Future<bool> hasUnlockedFeature(String featureId, {String? uid}) async {
    try {
      final progress = await getUserProgress(uid: uid);
      return progress?.unlockedFeatures.contains(featureId) ?? false;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking feature: $e');
      return false;
    }
  }

  /// Get user's level progress
  Future<Map<String, dynamic>> getLevelProgress({String? uid}) async {
    try {
      final progress = await getUserProgress(uid: uid);
      if (progress == null) return {};

      return {
        'currentLevel': progress.level,
        'currentExp': progress.experiencePoints,
        'expToNextLevel': progress.experienceToNextLevel,
        'progressPercentage': progress.levelProgressPercentage,
        'totalPoints': progress.totalPoints,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting level progress: $e');
      return {};
    }
  }

  /// Calculate level based on experience points
  int _calculateLevel(int experiencePoints) {
    // Simple level calculation: Every 100 XP = 1 level
    return (experiencePoints / 100).floor() + 1;
  }

  /// Get top users for leaderboard
  Future<List<UserProgress>> getTopUsers({
    int limit = 10,
    String orderBy = 'totalPoints',
  }) async {
    try {
      final query = _firestore
          .collection(_collectionName)
          .orderBy(orderBy, descending: true)
          .limit(limit);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return UserProgress.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting top users: $e');
      return [];
    }
  }

  /// Get user's rank
  Future<int?> getUserRank({String? uid, String orderBy = 'totalPoints'}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final targetUid = uid ?? user.uid;
      
      // Count users with higher score
      final higherScoreQuery = await _firestore
          .collection(_collectionName)
          .where(orderBy, isGreaterThan: 0)
          .get();

      int rank = 1;
      for (final doc in higherScoreQuery.docs) {
        if (doc.id == targetUid) break;
        rank++;
      }

      return rank;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user rank: $e');
      return null;
    }
  }

  /// Reset user progress (admin function)
  Future<bool> resetUserProgress(String uid) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .delete();

      if (kDebugMode) {
        debugPrint('🗑️ User progress reset for: $uid');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error resetting user progress: $e');
      return false;
    }
  }
}
