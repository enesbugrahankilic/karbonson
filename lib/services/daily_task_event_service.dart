// lib/services/daily_task_event_service.dart
// Günlük Görevler için Event-Driven Servis
// quiz_completed ve game_played event'lerini dinler ve görev ilerlemesini otomatik artırır

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_challenge.dart';

/// Event types for daily task updates
enum DailyTaskEventType {
  quizCompleted,
  gamePlayed,
  duelCompleted,
  multiplayerCompleted,
  challengeUpdated,
  allChallengesUpdated,
}

/// Event data for daily task updates
class DailyTaskEvent {
  final DailyTaskEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const DailyTaskEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Create from quiz completion
  factory DailyTaskEvent.fromQuizCompletion({
    required String category,
    required int score,
    required int correctAnswers,
    required String difficulty,
  }) {
    return DailyTaskEvent(
      type: DailyTaskEventType.quizCompleted,
      data: {
        'category': category,
        'score': score,
        'correctAnswers': correctAnswers,
        'difficulty': difficulty,
        'increment': 1,
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create from game completion
  factory DailyTaskEvent.fromGamePlayed({
    required String gameType,
    required int finalScore,
    required bool isWinner,
    required int position,
  }) {
    return DailyTaskEvent(
      type: DailyTaskEventType.gamePlayed,
      data: {
        'gameType': gameType,
        'finalScore': finalScore,
        'isWinner': isWinner,
        'position': position,
        'increment': isWinner ? 1 : 0,
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create from duel completion
  factory DailyTaskEvent.fromDuelCompleted({
    required bool isWinner,
    required int score,
  }) {
    return DailyTaskEvent(
      type: DailyTaskEventType.duelCompleted,
      data: {
        'isWinner': isWinner,
        'score': score,
        'increment': isWinner ? 1 : 0,
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create from multiplayer completion
  factory DailyTaskEvent.fromMultiplayerCompleted({
    required bool isWinner,
    required int position,
  }) {
    return DailyTaskEvent(
      type: DailyTaskEventType.multiplayerCompleted,
      data: {
        'isWinner': isWinner,
        'position': position,
        'increment': isWinner ? 1 : 0,
      },
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

/// Result of challenge update operation
class ChallengeUpdateResult {
  final String challengeId;
  final String challengeTitle;
  final int previousValue;
  final int newValue;
  final int targetValue;
  final bool isCompleted;
  final bool justCompleted;

  const ChallengeUpdateResult({
    required this.challengeId,
    required this.challengeTitle,
    required this.previousValue,
    required this.newValue,
    required this.targetValue,
    required this.isCompleted,
    required this.justCompleted,
  });

  double get progressPercentage {
    return (newValue / targetValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'previousValue': previousValue,
      'newValue': newValue,
      'targetValue': targetValue,
      'isCompleted': isCompleted,
      'justCompleted': justCompleted,
      'progressPercentage': progressPercentage,
    };
  }
}

/// Weekly Challenge model (for event service)
class WeeklyChallengeEventModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ChallengeType type;
  final int targetValue;
  final int currentValue;
  final int rewardPoints;
  final RewardType rewardType;
  final String? rewardItem;
  final DateTime weekStart;
  final DateTime weekEnd;
  final bool isCompleted;
  final ChallengeDifficulty difficulty;
  final String? bonusReward;

  const WeeklyChallengeEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.rewardPoints,
    required this.rewardType,
    this.rewardItem,
    required this.weekStart,
    required this.weekEnd,
    required this.isCompleted,
    this.difficulty = ChallengeDifficulty.medium,
    this.bonusReward,
  });

  factory WeeklyChallengeEventModel.fromJson(Map<String, dynamic> json) {
    return WeeklyChallengeEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: ChallengeType.values[json['type'] as int],
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      rewardPoints: json['rewardPoints'] as int,
      rewardType: RewardType.values[json['rewardType'] as int],
      rewardItem: json['rewardItem'] as String?,
      weekStart: DateTime.fromMillisecondsSinceEpoch(json['weekStart'] as int),
      weekEnd: DateTime.fromMillisecondsSinceEpoch(json['weekEnd'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      difficulty: ChallengeDifficulty.values[json['difficulty'] as int? ?? 1],
      bonusReward: json['bonusReward'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'rewardPoints': rewardPoints,
      'rewardType': rewardType.index,
      'rewardItem': rewardItem,
      'weekStart': weekStart.millisecondsSinceEpoch,
      'weekEnd': weekEnd.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'difficulty': difficulty.index,
      'bonusReward': bonusReward,
    };
  }
}

/// Daily Task Event Service - Event-driven challenge progress updates
class DailyTaskEventService {
  static final DailyTaskEventService _instance =
      DailyTaskEventService._internal();
  factory DailyTaskEventService() => _instance;
  DailyTaskEventService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers
  final StreamController<DailyTaskEvent> _eventController =
      StreamController<DailyTaskEvent>.broadcast();
  final StreamController<List<ChallengeUpdateResult>> _updateResultsController =
      StreamController<List<ChallengeUpdateResult>>.broadcast();
  final StreamController<Map<String, dynamic>> _statisticsController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Stream getters
  Stream<DailyTaskEvent> get eventStream => _eventController.stream;
  Stream<List<ChallengeUpdateResult>> get updateResultsStream =>
      _updateResultsController.stream;
  Stream<Map<String, dynamic>> get statisticsStream =>
      _statisticsController.stream;

  // Batch update tracking
  final List<ChallengeUpdateResult> _pendingUpdates = [];
  Timer? _batchTimer;
  static const Duration _batchWindow = Duration(milliseconds: 500);

  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _startBatchTimer();
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ DailyTaskEventService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing DailyTaskEventService: $e');
      }
    }
  }

  /// Start batch timer for aggregating updates
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(_batchWindow, (_) {
      _flushPendingUpdates();
    });
  }

  /// Flush pending updates to stream
  void _flushPendingUpdates() {
    if (_pendingUpdates.isEmpty) return;

    final updates = List<ChallengeUpdateResult>.from(_pendingUpdates);
    _pendingUpdates.clear();

    if (updates.isNotEmpty) {
      _updateResultsController.add(updates);
      _updateStatistics(updates);
    }
  }

  /// Update statistics based on recent updates
  void _updateStatistics(List<ChallengeUpdateResult> updates) {
    int completedCount = updates.where((u) => u.justCompleted).length;
    int totalProgress = updates.fold(0, (sum, u) => sum + u.newValue);

    _statisticsController.add({
      'recentlyCompleted': completedCount,
      'totalProgress': totalProgress,
      'updatedChallenges': updates.length,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Handle quiz completed event
  Future<List<ChallengeUpdateResult>> onQuizCompleted({
    required String category,
    required int score,
    required int correctAnswers,
    required String difficulty,
  }) async {
    final event = DailyTaskEvent.fromQuizCompletion(
      category: category,
      score: score,
      correctAnswers: correctAnswers,
      difficulty: difficulty,
    );

    _eventController.add(event);

    final results = await _updateChallengeProgress(
      eventType: DailyTaskEventType.quizCompleted,
      increment: 1,
      metadata: {
        'category': category,
        'score': score,
        'correctAnswers': correctAnswers,
        'difficulty': difficulty,
      },
    );

    _flushPendingUpdates();

    if (kDebugMode) {
      debugPrint(
          '📝 Quiz completed: category=$category, score=$score, updated ${results.length} challenges');
    }

    return results;
  }

  /// Handle game played event
  Future<List<ChallengeUpdateResult>> onGamePlayed({
    required String gameType,
    required int finalScore,
    required bool isWinner,
    required int position,
  }) async {
    final event = DailyTaskEvent.fromGamePlayed(
      gameType: gameType,
      finalScore: finalScore,
      isWinner: isWinner,
      position: position,
    );

    _eventController.add(event);

    final eventType = gameType == 'duel'
        ? DailyTaskEventType.duelCompleted
        : DailyTaskEventType.multiplayerCompleted;

    final increment = isWinner ? 1 : 0;
    final results = await _updateChallengeProgress(
      eventType: eventType,
      increment: increment,
      metadata: {
        'gameType': gameType,
        'finalScore': finalScore,
        'isWinner': isWinner,
        'position': position,
      },
    );

    _flushPendingUpdates();

    if (kDebugMode) {
      debugPrint(
          '🎮 Game played: type=$gameType, winner=$isWinner, updated ${results.length} challenges');
    }

    return results;
  }

  /// Handle duel completed event
  Future<List<ChallengeUpdateResult>> onDuelCompleted({
    required bool isWinner,
    required int score,
  }) async {
    final event = DailyTaskEvent.fromDuelCompleted(
      isWinner: isWinner,
      score: score,
    );

    _eventController.add(event);

    final results = await _updateChallengeProgress(
      eventType: DailyTaskEventType.duelCompleted,
      increment: isWinner ? 1 : 0,
      metadata: {'isWinner': isWinner, 'score': score},
    );

    _flushPendingUpdates();

    return results;
  }

  /// Handle multiplayer completed event
  Future<List<ChallengeUpdateResult>> onMultiplayerCompleted({
    required bool isWinner,
    required int position,
  }) async {
    final event = DailyTaskEvent.fromMultiplayerCompleted(
      isWinner: isWinner,
      position: position,
    );

    _eventController.add(event);

    final results = await _updateChallengeProgress(
      eventType: DailyTaskEventType.multiplayerCompleted,
      increment: isWinner ? 1 : 0,
      metadata: {'isWinner': isWinner, 'position': position},
    );

    _flushPendingUpdates();

    return results;
  }

  /// Update challenge progress based on event type
  Future<List<ChallengeUpdateResult>> _updateChallengeProgress({
    required DailyTaskEventType eventType,
    required int increment,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (increment <= 0) return [];

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      if (kDebugMode) debugPrint('❌ No authenticated user found');
      return [];
    }

    final results = <ChallengeUpdateResult>[];

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Query daily challenges
      final dailyQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('date', isLessThan: endOfDay.millisecondsSinceEpoch)
          .where('isCompleted', isEqualTo: false);

      final dailySnapshot = await dailyQuery.get();

      // Query weekly challenges
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weeklyQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('weekly_challenges')
          .where('weekStart', isGreaterThanOrEqualTo: weekStart.millisecondsSinceEpoch)
          .where('weekStart', isLessThan: weekEnd.millisecondsSinceEpoch)
          .where('isCompleted', isEqualTo: false);

      final weeklySnapshot = await weeklyQuery.get();

      // Update daily challenges
      for (final doc in dailySnapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final shouldUpdate = _shouldUpdateChallenge(challenge.type, eventType);
        if (!shouldUpdate) continue;

        final previousValue = challenge.currentValue;
        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;
        final justCompleted = isCompleted && !challenge.isCompleted;

        if (newValue > previousValue) {
          await doc.reference.update({
            'currentValue': newValue,
            'isCompleted': isCompleted,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          final result = ChallengeUpdateResult(
            challengeId: doc.id,
            challengeTitle: challenge.title,
            previousValue: previousValue,
            newValue: newValue,
            targetValue: challenge.targetValue,
            isCompleted: isCompleted,
            justCompleted: justCompleted,
          );

          results.add(result);
          _pendingUpdates.add(result);

          if (justCompleted) {
            await _logDailyChallengeCompletion(challenge, metadata);
          }

          if (kDebugMode) {
            debugPrint(
                '✅ Updated challenge "${challenge.title}": $previousValue → $newValue/${challenge.targetValue}');
          }
        }
      }

      // Update weekly challenges
      for (final doc in weeklySnapshot.docs) {
        final challenge = WeeklyChallengeEventModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final shouldUpdate = _shouldUpdateChallenge(challenge.type, eventType);
        if (!shouldUpdate) continue;

        final previousValue = challenge.currentValue;
        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;
        final justCompleted = isCompleted && !challenge.isCompleted;

        if (newValue > previousValue) {
          await doc.reference.update({
            'currentValue': newValue,
            'isCompleted': isCompleted,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          final result = ChallengeUpdateResult(
            challengeId: doc.id,
            challengeTitle: challenge.title,
            previousValue: previousValue,
            newValue: newValue,
            targetValue: challenge.targetValue,
            isCompleted: isCompleted,
            justCompleted: justCompleted,
          );

          results.add(result);
          _pendingUpdates.add(result);

          if (justCompleted) {
            await _logWeeklyChallengeCompletion(challenge, metadata);
          }

          if (kDebugMode) {
            debugPrint(
                '✅ Updated weekly challenge "${challenge.title}": $previousValue → $newValue/${challenge.targetValue}');
          }
        }
      }

      // Emit challenge updated event
      if (results.isNotEmpty) {
        final updateEvent = DailyTaskEvent(
          type: DailyTaskEventType.challengeUpdated,
          data: {
            'updatedCount': results.length,
            'justCompleted': results.where((r) => r.justCompleted).length,
            'metadata': metadata,
          },
          timestamp: DateTime.now(),
        );
        _eventController.add(updateEvent);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating challenge progress: $e');
    }

    return results;
  }

  /// Check if challenge should be updated based on event type
  bool _shouldUpdateChallenge(ChallengeType challengeType, DailyTaskEventType eventType) {
    switch (eventType) {
      case DailyTaskEventType.quizCompleted:
        return challengeType == ChallengeType.quiz;
      case DailyTaskEventType.duelCompleted:
        return challengeType == ChallengeType.duel;
      case DailyTaskEventType.multiplayerCompleted:
        return challengeType == ChallengeType.multiplayer;
      case DailyTaskEventType.gamePlayed:
        return challengeType == ChallengeType.duel ||
            challengeType == ChallengeType.multiplayer;
      default:
        return false;
    }
  }

  /// Log daily challenge completion activity
  Future<void> _logDailyChallengeCompletion(
    DailyChallenge challenge,
    Map<String, dynamic> metadata,
  ) async {
    try {
      await _firestore
          .collection('user_activities')
          .doc(_auth.currentUser?.uid)
          .collection('activities')
          .add({
        'type': 'challenge_completed',
        'title': 'Görev Tamamlandı',
        'description': '"${challenge.title}" görevi tamamlandı! +${challenge.rewardPoints} puan',
        'metadata': {
          ...metadata,
          'challengeId': challenge.id,
          'challengeTitle': challenge.title,
          'rewardPoints': challenge.rewardPoints,
          'rewardType': challenge.rewardType.index,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('🎉 Challenge completion logged: ${challenge.title}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error logging challenge completion: $e');
    }
  }

  /// Log weekly challenge completion activity
  Future<void> _logWeeklyChallengeCompletion(
    WeeklyChallengeEventModel challenge,
    Map<String, dynamic> metadata,
  ) async {
    try {
      await _firestore
          .collection('user_activities')
          .doc(_auth.currentUser?.uid)
          .collection('activities')
          .add({
        'type': 'weekly_challenge_completed',
        'title': 'Haftalık Görev Tamamlandı',
        'description': '"${challenge.title}" haftalık görevi tamamlandı! +${challenge.rewardPoints} puan',
        'metadata': {
          ...metadata,
          'challengeId': challenge.id,
          'challengeTitle': challenge.title,
          'rewardPoints': challenge.rewardPoints,
          'rewardType': challenge.rewardType.index,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('🎉 Weekly challenge completion logged: ${challenge.title}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error logging weekly challenge completion: $e');
    }
  }

  /// Get current challenge statistics
  Future<Map<String, dynamic>> getChallengeStatistics() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dailyQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('date', isLessThan: endOfDay.millisecondsSinceEpoch);

      final dailySnapshot = await dailyQuery.get();

      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weeklyQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('weekly_challenges')
          .where('weekStart', isGreaterThanOrEqualTo: weekStart.millisecondsSinceEpoch)
          .where('weekStart', isLessThan: weekEnd.millisecondsSinceEpoch);

      final weeklySnapshot = await weeklyQuery.get();

      int dailyCompleted = 0;
      int dailyTotal = dailySnapshot.docs.length;
      int dailyProgress = 0;
      int dailyTarget = 0;

      for (final doc in dailySnapshot.docs) {
        final challenge = DailyChallenge.fromJson({...doc.data()!, 'id': doc.id});
        if (challenge.isCompleted) dailyCompleted++;
        dailyProgress += challenge.currentValue;
        dailyTarget += challenge.targetValue;
      }

      int weeklyCompleted = 0;
      int weeklyTotal = weeklySnapshot.docs.length;
      int weeklyProgress = 0;
      int weeklyTarget = 0;

      for (final doc in weeklySnapshot.docs) {
        final challenge = WeeklyChallengeEventModel.fromJson({...doc.data()!, 'id': doc.id});
        if (challenge.isCompleted) weeklyCompleted++;
        weeklyProgress += challenge.currentValue;
        weeklyTarget += challenge.targetValue;
      }

      return {
        'daily': {
          'total': dailyTotal,
          'completed': dailyCompleted,
          'progress': dailyProgress,
          'target': dailyTarget,
          'completionRate': dailyTotal > 0
              ? (dailyCompleted / dailyTotal * 100).toStringAsFixed(1)
              : '0.0',
        },
        'weekly': {
          'total': weeklyTotal,
          'completed': weeklyCompleted,
          'progress': weeklyProgress,
          'target': weeklyTarget,
          'completionRate': weeklyTotal > 0
              ? (weeklyCompleted / weeklyTotal * 100).toStringAsFixed(1)
              : '0.0',
        },
        'lastUpdated': now.millisecondsSinceEpoch,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting challenge statistics: $e');
      return {};
    }
  }

  /// Get week start date (Monday)
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    final mondayOffset = dayOfWeek - DateTime.monday;
    return date.subtract(Duration(days: mondayOffset));
  }

  /// Manually refresh all challenges (e.g., after login)
  Future<void> refreshAllChallenges() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final dailyQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('date', isLessThan: endOfDay.millisecondsSinceEpoch);

      final dailySnapshot = await dailyQuery.get();
      final dailyChallenges = dailySnapshot.docs
          .map((doc) => DailyChallenge.fromJson({...doc.data()!, 'id': doc.id}))
          .toList();

      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weeklyQuery = _firestore
          .collection('users')
          .doc(userId)
          .collection('weekly_challenges')
          .where('weekStart', isGreaterThanOrEqualTo: weekStart.millisecondsSinceEpoch)
          .where('weekStart', isLessThan: weekEnd.millisecondsSinceEpoch);

      final weeklySnapshot = await weeklyQuery.get();
      final weeklyChallenges = weeklySnapshot.docs
          .map((doc) => WeeklyChallengeEventModel.fromJson({...doc.data()!, 'id': doc.id}))
          .toList();

      final event = DailyTaskEvent(
        type: DailyTaskEventType.allChallengesUpdated,
        data: {
          'dailyChallenges': dailyChallenges.map((c) => c.toJson()).toList(),
          'weeklyChallenges': weeklyChallenges.map((c) => c.toJson()).toList(),
        },
        timestamp: DateTime.now(),
      );

      _eventController.add(event);

      if (kDebugMode) {
        debugPrint(
            '🔄 Refreshed ${dailyChallenges.length} daily and ${weeklyChallenges.length} weekly challenges');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error refreshing challenges: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _batchTimer?.cancel();
    _eventController.close();
    _updateResultsController.close();
    _statisticsController.close();
    _isInitialized = false;
  }
}

