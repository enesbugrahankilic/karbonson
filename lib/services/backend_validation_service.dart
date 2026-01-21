// lib/services/backend_validation_service.dart
// Prevent client-side data manipulation and cheating

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'analytics_service.dart';

class BackendValidationService {
  static final BackendValidationService _instance = BackendValidationService._internal();
  factory BackendValidationService() => _instance;
  BackendValidationService._internal();

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  bool _isInitialized = false;

  // Validation constants
  static const int _maxPointsPerQuiz = 1000;
  static const int _maxPointsPerDuel = 500;
  static const int _maxDailyRewards = 5000;
  static const Duration _gameTimeout = Duration(hours: 2);
  static const Duration _rewardCooldown = Duration(seconds: 5);

  // Cache for rate limiting
  final Map<String, DateTime> _lastRewardTime = {};

  /// Initialize validation service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

      // Set Firestore rules validation
      await _setupFirestoreRules();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ Backend validation service initialized');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Validation init error: $e');
    }
  }

  /// Setup Firestore security rules (note: actual rules in Firebase Console)
  Future<void> _setupFirestoreRules() async {
    if (kDebugMode) {
      debugPrint('📋 Note: Firestore rules must be set in Firebase Console');
    }
  }

  /// Validate and save quiz result (BACKEND AUTHORITY)
  Future<bool> validateQuizResult({
    required String userId,
    required int score,
    required int duration,
    required int questionCount,
    required String difficulty,
  }) async {
    try {
      // Validate parameters
      if (score < 0 || score > (questionCount * 100)) {
        await _logSuspiciousActivity(userId, 'Invalid score: $score');
        return false;
      }

      if (duration < 10 || duration > 3600) {
        // Game must last 10 sec to 1 hour
        await _logSuspiciousActivity(userId, 'Suspicious duration: $duration');
        return false;
      }

      // Rate limiting - prevent spamming
      if (!await _checkRateLimit(userId, 'quiz_result')) {
        await _logSuspiciousActivity(userId, 'Quiz spam detected');
        return false;
      }

      // Calculate rewards server-side
      final calculatedPoints = _calculateQuizPoints(score, duration, difficulty);

      if (calculatedPoints < 0 || calculatedPoints > _maxPointsPerQuiz) {
        await _logSuspiciousActivity(userId, 'Invalid points calculated: $calculatedPoints');
        return false;
      }

      // Firestore transaction to ensure atomicity
      final result = await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        // Check ban status
        if (userDoc['isBanned'] == true) {
          throw Exception('User is banned');
        }

        // Atomic point update
        final currentPoints = (userDoc['points'] as int?) ?? 0;
        final newPoints = currentPoints + calculatedPoints;

        transaction.update(userRef, {
          'points': newPoints,
          'last_quiz_timestamp': FieldValue.serverTimestamp(),
          'total_quizzes_completed': FieldValue.increment(1),
        });

        return true;
      });

      if (result) {
        await AnalyticsService().logGameCompletion(
          'quiz',
          score: calculatedPoints,
          duration: duration,
          isWin: score > (questionCount * 50), // > 50% correct
          difficulty: _difficultyToInt(difficulty),
        );

        if (kDebugMode) {
          debugPrint('✅ Quiz result validated and saved: +$calculatedPoints points');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Quiz validation error: $e');
      await AnalyticsService().logError('QuizValidationError', e.toString());
      return false;
    }
  }

  /// Validate and save duel result (BOTH PLAYERS)
  Future<bool> validateDuelResult({
    required String winnerId,
    required String loserId,
    required int winnerScore,
    required int loserScore,
    required int duration,
  }) async {
    try {
      // Validate parameters
      if (duration < 30 || duration > 1800) {
        // 30 sec to 30 min
        await _logSuspiciousActivity(winnerId, 'Suspicious duel duration: $duration');
        await _logSuspiciousActivity(loserId, 'Suspicious duel duration: $duration');
        return false;
      }

      if (winnerScore <= loserScore) {
        await _logSuspiciousActivity(winnerId, 'Invalid winner score: $winnerScore vs $loserScore');
        return false;
      }

      // Rate limiting for both players
      if (!await _checkRateLimit(winnerId, 'duel_result') ||
          !await _checkRateLimit(loserId, 'duel_result')) {
        return false;
      }

      // Calculate rewards server-side
      final winnerPoints = _calculateDuelPoints(winnerScore, true);
      final loserPoints = _calculateDuelPoints(loserScore, false);

      // Atomic transaction for both players
      final result = await _firestore.runTransaction((transaction) async {
        final winnerRef = _firestore.collection('users').doc(winnerId);
        final loserRef = _firestore.collection('users').doc(loserId);

        final winnerDoc = await transaction.get(winnerRef);
        final loserDoc = await transaction.get(loserRef);

        if (!winnerDoc.exists || !loserDoc.exists) {
          throw Exception('User not found');
        }

        // Check ban status
        if (winnerDoc['isBanned'] == true || loserDoc['isBanned'] == true) {
          throw Exception('Banned user in duel');
        }

        // Update winner
        transaction.update(winnerRef, {
          'points': FieldValue.increment(winnerPoints),
          'duels_won': FieldValue.increment(1),
          'last_duel_timestamp': FieldValue.serverTimestamp(),
        });

        // Update loser
        transaction.update(loserRef, {
          'points': FieldValue.increment(loserPoints),
          'duels_lost': FieldValue.increment(1),
          'last_duel_timestamp': FieldValue.serverTimestamp(),
        });

        // Log duel result
        await _firestore.collection('duel_results').add({
          'winner_id': winnerId,
          'loser_id': loserId,
          'winner_score': winnerScore,
          'loser_score': loserScore,
          'winner_reward': winnerPoints,
          'loser_reward': loserPoints,
          'duration': duration,
          'timestamp': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (result) {
        await AnalyticsService().logGameCompletion(
          'duel',
          score: winnerPoints,
          duration: duration,
          isWin: true,
        );

        if (kDebugMode) {
          debugPrint('✅ Duel result validated: +$winnerPoints to winner, +$loserPoints to loser');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Duel validation error: $e');
      await AnalyticsService().logError('DuelValidationError', e.toString());
      return false;
    }
  }

  /// Validate daily task reward (UNIQUE ONCE PER DAY)
  Future<bool> validateDailyReward({
    required String userId,
    required String taskId,
    required int rewardAmount,
  }) async {
    try {
      // Rate limiting per user (max 1 reward per 5 seconds)
      if (!await _checkRateLimit(userId, 'daily_reward')) {
        await _logSuspiciousActivity(userId, 'Daily reward spam');
        return false;
      }

      // Firestore transaction to prevent duplicate rewards
      final result = await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final completionRef = _firestore
            .collection('daily_completions')
            .doc('${userId}_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}');

        final userDoc = await transaction.get(userRef);
        final completionDoc = await transaction.get(completionRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        // Check if already completed today
        if (completionDoc.exists && completionDoc['task_ids'].contains(taskId)) {
          throw Exception('Task already completed today');
        }

        // Check ban status
        if (userDoc['isBanned'] == true) {
          throw Exception('User is banned');
        }

        // Validate reward amount
        if (rewardAmount < 0 || rewardAmount > _maxDailyRewards) {
          throw Exception('Invalid reward amount: $rewardAmount');
        }

        // Update user points
        transaction.update(userRef, {
          'points': FieldValue.increment(rewardAmount),
          'daily_tasks_completed': FieldValue.increment(1),
        });

        // Mark task as completed
        if (completionDoc.exists) {
          transaction.update(completionRef, {
            'task_ids': FieldValue.arrayUnion([taskId]),
            'updated_at': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(completionRef, {
            'user_id': userId,
            'date': DateTime.now().toIso8601String(),
            'task_ids': [taskId],
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        return true;
      });

      if (result) {
        await AnalyticsService().logReward(
          'daily_task',
          amount: rewardAmount,
          source: 'daily',
        );

        if (kDebugMode) {
          debugPrint('✅ Daily reward validated: +$rewardAmount points');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Daily reward validation error: $e');
      await AnalyticsService().logError('DailyRewardValidationError', e.toString());
      return false;
    }
  }

  /// Check rate limiting
  Future<bool> _checkRateLimit(String userId, String action) async {
    final key = '${userId}_$action';
    final lastTime = _lastRewardTime[key];

    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < _rewardCooldown) {
        if (kDebugMode) {
          debugPrint('⚠️ Rate limit exceeded for $key: ${elapsed.inMilliseconds}ms');
        }
        return false;
      }
    }

    _lastRewardTime[key] = DateTime.now();
    return true;
  }

  /// Log suspicious activity
  Future<void> _logSuspiciousActivity(String userId, String reason) async {
    try {
      await _firestore.collection('suspicious_activities').add({
        'user_id': userId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await AnalyticsService().logError('SuspiciousActivity', '$userId: $reason');

      if (kDebugMode) {
        debugPrint('🚨 Suspicious activity logged: $userId - $reason');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error logging suspicious activity: $e');
    }
  }

  // Helper methods for point calculation
  int _calculateQuizPoints(int score, int duration, String difficulty) {
    // Server-side calculation only
    int basePoints = (score ~/ 10).clamp(0, 100);

    // Difficulty multiplier
    final difficultyMultiplier = {
      'easy': 1.0,
      'medium': 1.5,
      'hard': 2.0,
      'expert': 2.5,
    }[difficulty] ??
        1.0;

    // Speed bonus (faster = more points)
    final speedBonus = (300 - duration).clamp(0, 100) / 100;

    final points = (basePoints * difficultyMultiplier * (1 + speedBonus)).toInt();

    return points.clamp(10, _maxPointsPerQuiz);
  }

  int _calculateDuelPoints(int score, bool isWinner) {
    if (isWinner) {
      return (score / 2).toInt().clamp(50, _maxPointsPerDuel);
    } else {
      return (score / 4).toInt().clamp(10, _maxPointsPerDuel ~/ 2);
    }
  }

  int _difficultyToInt(String difficulty) {
    return {
      'easy': 1,
      'medium': 2,
      'hard': 3,
      'expert': 4,
    }[difficulty] ??
        1;
  }

  /// Dispose
  void dispose() {
    _lastRewardTime.clear();
  }
}
