// lib/services/challenge_service.dart
// Challenge Management with Firestore Integration
// UID Centrality: Subcollections under users/{uid}/daily_challenges and users/{uid}/weekly_challenges

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_challenge.dart';
import '../services/daily_task_reward_service.dart';

/// Challenge Service for managing daily and weekly challenges
class ChallengeService {
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection names (subcollections under users)
  static const String _dailyCollectionName = 'daily_challenges';
  static const String _weeklyCollectionName = 'weekly_challenges';

  // ========== DAILY CHALLENGES ==========

  /// Get all daily challenges for a user
  Future<List<DailyChallenge>> getUserDailyChallenges({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return [];
      }

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_dailyCollectionName)
          .orderBy('date', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Use document ID as challenge ID
        return DailyChallenge.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting daily challenges: $e');
      return [];
    }
  }

  /// Get today's daily challenges
  Future<List<DailyChallenge>> getTodayDailyChallenges({String? uid}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_dailyCollectionName)
          .where('date', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('date', isLessThan: endOfDay.millisecondsSinceEpoch)
          .orderBy('date', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DailyChallenge.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting today daily challenges: $e');
      return [];
    }
  }

  /// Get a specific daily challenge
  Future<DailyChallenge?> getDailyChallenge(String challengeId, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final targetUid = uid ?? user.uid;
      
      final doc = await _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_dailyCollectionName)
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) debugPrint('📄 Daily challenge not found: $challengeId');
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return DailyChallenge.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting daily challenge: $e');
      return null;
    }
  }

  /// Create a new daily challenge
  Future<String?> createDailyChallenge(DailyChallenge challenge) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return null;
      }

      // Add userId to challenge data
      final challengeData = challenge.toJson();
      challengeData['userId'] = user.uid;

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_dailyCollectionName)
          .add(challengeData);

      if (kDebugMode) {
        debugPrint('✅ Daily challenge created: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error creating daily challenge: $e');
      return null;
    }
  }

  /// Update daily challenge progress
  Future<bool> updateDailyChallengeProgress(String challengeId, int newValue, {String? uid}) async {
    try {
      final challenge = await getDailyChallenge(challengeId, uid: uid);
      if (challenge == null) return false;

      final updatedChallenge = challenge.copyWith(
        currentValue: newValue,
        isCompleted: newValue >= challenge.targetValue,
      );

      return await updateDailyChallenge(updatedChallenge);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating daily challenge progress: $e');
      return false;
    }
  }

  /// Mark daily challenge as completed
  Future<bool> completeDailyChallenge(String challengeId, {String? uid}) async {
    try {
      final challenge = await getDailyChallenge(challengeId, uid: uid);
      if (challenge == null) return false;

      final completedChallenge = challenge.copyWith(
        currentValue: challenge.targetValue,
        isCompleted: true,
      );

      return await updateDailyChallenge(completedChallenge);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error completing daily challenge: $e');
      return false;
    }
  }

  /// Update daily challenge
  Future<bool> updateDailyChallenge(DailyChallenge challenge) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final challengeData = challenge.toJson();
      challengeData['userId'] = user.uid;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_dailyCollectionName)
          .doc(challenge.id)
          .set(challengeData, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('✅ Daily challenge updated: ${challenge.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating daily challenge: $e');
      return false;
    }
  }

  /// Delete daily challenge
  Future<bool> deleteDailyChallenge(String challengeId, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final targetUid = uid ?? user.uid;
      
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_dailyCollectionName)
          .doc(challengeId)
          .delete();

      if (kDebugMode) {
        debugPrint('🗑️ Daily challenge deleted: $challengeId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error deleting daily challenge: $e');
      return false;
    }
  }

  // ========== WEEKLY CHALLENGES ==========

  /// Get all weekly challenges for a user
  Future<List<WeeklyChallenge>> getUserWeeklyChallenges({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return [];
      }

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_weeklyCollectionName)
          .orderBy('weekStart', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WeeklyChallenge.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting weekly challenges: $e');
      return [];
    }
  }

  /// Get current week weekly challenges
  Future<List<WeeklyChallenge>> getCurrentWeekChallenges({String? uid}) async {
    try {
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_weeklyCollectionName)
          .where('weekStart', isGreaterThanOrEqualTo: weekStart.millisecondsSinceEpoch)
          .where('weekStart', isLessThan: weekEnd.millisecondsSinceEpoch)
          .orderBy('weekStart', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WeeklyChallenge.fromJson(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting current week challenges: $e');
      return [];
    }
  }

  /// Get a specific weekly challenge
  Future<WeeklyChallenge?> getWeeklyChallenge(String challengeId, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final targetUid = uid ?? user.uid;
      
      final doc = await _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_weeklyCollectionName)
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) debugPrint('📄 Weekly challenge not found: $challengeId');
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return WeeklyChallenge.fromJson(data);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting weekly challenge: $e');
      return null;
    }
  }

  /// Create a new weekly challenge
  Future<String?> createWeeklyChallenge(WeeklyChallenge challenge) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return null;
      }

      // Add userId to challenge data
      final challengeData = challenge.toJson();
      challengeData['userId'] = user.uid;

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_weeklyCollectionName)
          .add(challengeData);

      if (kDebugMode) {
        debugPrint('✅ Weekly challenge created: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error creating weekly challenge: $e');
      return null;
    }
  }

  /// Update weekly challenge progress
  Future<bool> updateWeeklyChallengeProgress(String challengeId, int newValue, {String? uid}) async {
    try {
      final challenge = await getWeeklyChallenge(challengeId, uid: uid);
      if (challenge == null) return false;

      final updatedChallenge = challenge.copyWith(
        currentValue: newValue,
        isCompleted: newValue >= challenge.targetValue,
      );

      return await updateWeeklyChallenge(updatedChallenge);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating weekly challenge progress: $e');
      return false;
    }
  }

  /// Mark weekly challenge as completed
  Future<bool> completeWeeklyChallenge(String challengeId, {String? uid}) async {
    try {
      final challenge = await getWeeklyChallenge(challengeId, uid: uid);
      if (challenge == null) return false;

      final completedChallenge = challenge.copyWith(
        currentValue: challenge.targetValue,
        isCompleted: true,
      );

      return await updateWeeklyChallenge(completedChallenge);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error completing weekly challenge: $e');
      return false;
    }
  }

  /// Update weekly challenge
  Future<bool> updateWeeklyChallenge(WeeklyChallenge challenge) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final challengeData = challenge.toJson();
      challengeData['userId'] = user.uid;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_weeklyCollectionName)
          .doc(challenge.id)
          .set(challengeData, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('✅ Weekly challenge updated: ${challenge.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating weekly challenge: $e');
      return false;
    }
  }

  /// Delete weekly challenge
  Future<bool> deleteWeeklyChallenge(String challengeId, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final targetUid = uid ?? user.uid;
      
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_weeklyCollectionName)
          .doc(challengeId)
          .delete();

      if (kDebugMode) {
        debugPrint('🗑️ Weekly challenge deleted: $challengeId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error deleting weekly challenge: $e');
      return false;
    }
  }

  // ========== CHALLENGE GENERATION ==========

  /// Generate today's daily challenges automatically
  Future<List<String>> generateTodayDailyChallenges({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      // Check if today's challenges already exist
      final todayChallenges = await getTodayDailyChallenges(uid: uid);
      if (todayChallenges.isNotEmpty) {
        if (kDebugMode) debugPrint('ℹ️ Today\'s challenges already exist');
        return todayChallenges.map((c) => c.id).toList();
      }

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      final expiresAt = date.add(const Duration(days: 1));

      // Generate random challenges based on difficulty
      final challenges = <String>[];
      
      // Easy challenge - Quiz (3 questions)
      final easyChallenge = DailyChallenge(
        id: '',
        title: 'Günlük Quiz',
        description: 'Bugün 3 soru yanıtla',
        type: ChallengeType.quiz,
        targetValue: 3,
        currentValue: 0,
        rewardPoints: 50,
        rewardType: RewardType.points,
        date: date,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.easy,
        icon: '🧠',
      );

      final easyId = await createDailyChallenge(easyChallenge);
      if (easyId != null) challenges.add(easyId);

      // Medium challenge - Duel (1 win)
      final mediumChallenge = DailyChallenge(
        id: '',
        title: 'Düello Kazan',
        description: 'Bir düello kazan',
        type: ChallengeType.duel,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 100,
        rewardType: RewardType.points,
        date: date,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.medium,
        icon: '⚔️',
      );

      final mediumId = await createDailyChallenge(mediumChallenge);
      if (mediumId != null) challenges.add(mediumId);

      // Hard challenge - Social (add friend)
      final hardChallenge = DailyChallenge(
        id: '',
        title: 'Arkadaş Ekle',
        description: 'Bir arkadaş ekle',
        type: ChallengeType.social,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 75,
        rewardType: RewardType.points,
        date: date,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.hard,
        icon: '👥',
      );

      final hardId = await createDailyChallenge(hardChallenge);
      if (hardId != null) challenges.add(hardId);

      if (kDebugMode) {
        debugPrint('✅ Generated ${challenges.length} daily challenges for today');
      }

      return challenges;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error generating today challenges: $e');
      return [];
    }
  }

  /// Generate weekly challenges for current week
  Future<List<String>> generateWeeklyChallenges({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      // Check if current week challenges already exist
      final currentWeekChallenges = await getCurrentWeekChallenges(uid: uid);
      if (currentWeekChallenges.isNotEmpty) {
        if (kDebugMode) debugPrint('ℹ️ Current week challenges already exist');
        return currentWeekChallenges.map((c) => c.id).toList();
      }

      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Generate weekly challenges
      final challenges = <String>[];
      
      // Main weekly challenge - Quiz (20 questions)
      final mainChallenge = WeeklyChallenge(
        id: '',
        title: 'Haftalık Quiz Uzmanı',
        description: 'Bu hafta 20 soru yanıtla',
        icon: '🎯',
        type: ChallengeType.quiz,
        targetValue: 20,
        currentValue: 0,
        rewardPoints: 500,
        rewardType: RewardType.points,
        weekStart: weekStart,
        weekEnd: weekEnd,
        isCompleted: false,
        difficulty: ChallengeDifficulty.medium,
        bonusReward: 'special_avatar',
      );

      final mainId = await createWeeklyChallenge(mainChallenge);
      if (mainId != null) challenges.add(mainId);

      // Bonus weekly challenge - Duel (5 wins)
      final bonusChallenge = WeeklyChallenge(
        id: '',
        title: 'Haftalık Savaşçı',
        description: '5 düello kazan',
        icon: '🏆',
        type: ChallengeType.duel,
        targetValue: 5,
        currentValue: 0,
        rewardPoints: 300,
        rewardType: RewardType.points,
        weekStart: weekStart,
        weekEnd: weekEnd,
        isCompleted: false,
        difficulty: ChallengeDifficulty.hard,
        bonusReward: 'theme_pack',
      );

      // Special weekly challenge - Friendship (3 friends)
      final friendshipChallenge = WeeklyChallenge(
        id: '',
        title: 'Haftalık Arkadaş',
        description: '3 yeni arkadaş ekle',
        icon: '👥',
        type: ChallengeType.friendship,
        targetValue: 3,
        currentValue: 0,
        rewardPoints: 250,
        rewardType: RewardType.avatar,
        rewardItem: 'friendship_avatar',
        weekStart: weekStart,
        weekEnd: weekEnd,
        isCompleted: false,
        difficulty: ChallengeDifficulty.medium,
        bonusReward: 'social_badge',
      );

      final friendshipId = await createWeeklyChallenge(friendshipChallenge);
      if (friendshipId != null) challenges.add(friendshipId);

      final bonusId = await createWeeklyChallenge(bonusChallenge);
      if (bonusId != null) challenges.add(bonusId);

      if (kDebugMode) {
        debugPrint('✅ Generated ${challenges.length} weekly challenges');
      }

      return challenges;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error generating weekly challenges: $e');
      return [];
    }
  }

  // ========== STATISTICS ==========

  /// Get challenge statistics
  Future<Map<String, dynamic>> getChallengeStatistics({String? uid}) async {
    try {
      final dailyChallenges = await getUserDailyChallenges(uid: uid);
      final weeklyChallenges = await getUserWeeklyChallenges(uid: uid);
      
      int dailyCompleted = 0;
      int dailyTotal = dailyChallenges.length;
      int weeklyCompleted = 0;
      int weeklyTotal = weeklyChallenges.length;
      
      for (final challenge in dailyChallenges) {
        if (challenge.isCompleted) dailyCompleted++;
      }
      
      for (final challenge in weeklyChallenges) {
        if (challenge.isCompleted) weeklyCompleted++;
      }

      return {
        'daily': {
          'total': dailyTotal,
          'completed': dailyCompleted,
          'completionRate': dailyTotal > 0 ? (dailyCompleted / dailyTotal * 100).toStringAsFixed(1) : '0.0',
        },
        'weekly': {
          'total': weeklyTotal,
          'completed': weeklyCompleted,
          'completionRate': weeklyTotal > 0 ? (weeklyCompleted / weeklyTotal * 100).toStringAsFixed(1) : '0.0',
        },
        'totalPointsEarned': _calculateTotalPointsEarned(dailyChallenges, weeklyChallenges),
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting challenge statistics: $e');
      return {};
    }
  }

  /// Get active challenges (not expired)
  Future<Map<String, List>> getActiveChallenges({String? uid}) async {
    try {
      final now = DateTime.now();
      final dailyChallenges = await getUserDailyChallenges(uid: uid);
      final weeklyChallenges = await getUserWeeklyChallenges(uid: uid);
      
      final activeDaily = dailyChallenges.where((c) => !c.isExpired).toList();
      final activeWeekly = weeklyChallenges.where((c) => c.weekEnd.isAfter(DateTime.now())).toList();
      
      return {
        'daily': activeDaily,
        'weekly': activeWeekly,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting active challenges: $e');
      return {'daily': [], 'weekly': []};
    }
  }

  /// Get expired challenges
  Future<Map<String, List>> getExpiredChallenges({String? uid}) async {
    try {
      final now = DateTime.now();
      final dailyChallenges = await getUserDailyChallenges(uid: uid);
      final weeklyChallenges = await getUserWeeklyChallenges(uid: uid);
      
      final expiredDaily = dailyChallenges.where((c) => c.isExpired).toList();
      final expiredWeekly = weeklyChallenges.where((c) => c.weekEnd.isBefore(DateTime.now())).toList();
      
      return {
        'daily': expiredDaily,
        'weekly': expiredWeekly,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting expired challenges: $e');
      return {'daily': [], 'weekly': []};
    }
  }

  // ========== CLEANUP ==========

  /// Clean up expired challenges
  Future<bool> cleanupExpiredChallenges({String? uid, int daysToKeep = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;
      
      final user = _auth.currentUser;
      if (user == null) return false;

      final targetUid = uid ?? user.uid;
      
      // Clean up expired daily challenges
      final dailyQuery = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_dailyCollectionName)
          .where('expiresAt', isLessThan: cutoffTimestamp);

      final dailySnapshot = await dailyQuery.get();
      
      // Clean up expired weekly challenges
      final weeklyQuery = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_weeklyCollectionName)
          .where('weekEnd', isLessThan: cutoffTimestamp);

      final weeklySnapshot = await weeklyQuery.get();
      
      final batch = _firestore.batch();
      for (final doc in [...dailySnapshot.docs, ...weeklySnapshot.docs]) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      if (kDebugMode) {
        debugPrint('🧹 Cleaned up ${dailySnapshot.docs.length + weeklySnapshot.docs.length} expired challenges');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error cleaning up expired challenges: $e');
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  /// Get week start date (Monday)
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    final mondayOffset = dayOfWeek - DateTime.monday;
    return date.subtract(Duration(days: mondayOffset));
  }

  /// Calculate total points earned from completed challenges
  int _calculateTotalPointsEarned(List<DailyChallenge> daily, List<WeeklyChallenge> weekly) {
    int total = 0;
    
    for (final challenge in daily) {
      if (challenge.isCompleted) {
        total += challenge.rewardPoints;
      }
    }
    
    for (final challenge in weekly) {
      if (challenge.isCompleted) {
        total += challenge.rewardPoints;
      }
    }
    
    return total;
  }

  /// Auto-update challenge progress based on user activity
  Future<bool> updateChallengeProgressFromActivity({
    required String activityType,
    required int value,
    String? uid,
  }) async {
    try {
      final activeChallenges = await getActiveChallenges(uid: uid);
      bool updated = false;

      // Update daily challenges
      for (final challenge in activeChallenges['daily'] as List<DailyChallenge>) {
        if (challenge.type.name == activityType && !challenge.isCompleted) {
          final newValue = challenge.currentValue + value;
          final success = await updateDailyChallengeProgress(challenge.id, newValue, uid: uid);
          if (success) updated = true;
        }
      }

      // Update weekly challenges
      for (final challenge in activeChallenges['weekly'] as List<WeeklyChallenge>) {
        if (challenge.type.name == activityType && !challenge.isCompleted) {
          final newValue = challenge.currentValue + value;
          final success = await updateWeeklyChallengeProgress(challenge.id, newValue, uid: uid);
          if (success) updated = true;
        }
      }

      return updated;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating challenge progress from activity: $e');
      return false;
    }
  }
}
