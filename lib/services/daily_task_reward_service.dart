// lib/services/daily_task_reward_service.dart
// Günlük Görev Ödül Servisi - Görev tamamlandığında anında ödül/loot box ver

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_challenge.dart';
import '../models/loot_box.dart';
import '../services/loot_box_service.dart';
import '../services/state_refresh_service.dart';
import '../services/notification_service.dart';

/// Ödül türü enum
enum DailyTaskRewardType {
  points,      // Karbon Puanı
  lootBox,     // Loot Box
  badge,       // Rozet
  avatar,      // Avatar
}

/// Ödül grant sonucu
class DailyTaskRewardResult {
  final bool success;
  final String challengeId;
  final DailyTaskRewardType rewardType;
  final String rewardId;
  final String rewardName;
  final String? message;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const DailyTaskRewardResult({
    required this.success,
    required this.challengeId,
    required this.rewardType,
    required this.rewardId,
    required this.rewardName,
    this.message,
    this.metadata,
    required this.timestamp,
  });

  factory DailyTaskRewardResult.failure({
    required String challengeId,
    required String message,
  }) {
    return DailyTaskRewardResult(
      success: false,
      challengeId: challengeId,
      rewardType: DailyTaskRewardType.points,
      rewardId: '',
      rewardName: '',
      message: message,
      timestamp: DateTime.now(),
    );
  }

  factory DailyTaskRewardResult.points({
    required String challengeId,
    required int points,
  }) {
    return DailyTaskRewardResult(
      success: true,
      challengeId: challengeId,
      rewardType: DailyTaskRewardType.points,
      rewardId: 'points_$points',
      rewardName: '$points KP',
      message: '+$points Karbon Puanı kazandın!',
      metadata: {'points': points},
      timestamp: DateTime.now(),
    );
  }

  factory DailyTaskRewardResult.lootBox({
    required String challengeId,
    required String boxId,
    required LootBoxRarity rarity,
  }) {
    return DailyTaskRewardResult(
      success: true,
      challengeId: challengeId,
      rewardType: DailyTaskRewardType.lootBox,
      rewardId: boxId,
      rewardName: '${rarityName(rarity)} Loot Kutusu',
      message: '${rarityName(rarity)} loot kutusu kazandın!',
      metadata: {
        'rarity': rarity.index,
        'rarityName': rarityName(rarity),
      },
      timestamp: DateTime.now(),
    );
  }

  static String rarityName(LootBoxRarity rarity) {
    switch (rarity) {
      case LootBoxRarity.common: return 'Sıradan';
      case LootBoxRarity.rare: return 'Nadir';
      case LootBoxRarity.epic: return 'Destansı';
      case LootBoxRarity.legendary: return 'Efsanevi';
      case LootBoxRarity.mythic: return 'Mitolojik';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'challengeId': challengeId,
      'rewardType': rewardType.index,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'message': message,
      'metadata': metadata,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

/// Challenge completion ile ilişkili reward event
class ChallengeRewardEvent {
  final String challengeId;
  final String challengeTitle;
  final DailyTaskRewardResult rewardResult;
  final bool isFirstCompletion; // Günün ilk görevi mi?

  const ChallengeRewardEvent({
    required this.challengeId,
    required this.challengeTitle,
    required this.rewardResult,
    required this.isFirstCompletion,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'rewardResult': rewardResult.toJson(),
      'isFirstCompletion': isFirstCompletion,
    };
  }
}

/// Günlük Görev Ödül Servisi
class DailyTaskRewardService {
  static final DailyTaskRewardService _instance =
      DailyTaskRewardService._internal();
  factory DailyTaskRewardService() => _instance;
  DailyTaskRewardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LootBoxService _lootBoxService = LootBoxService();
  final StateRefreshService _stateRefreshService = StateRefreshService();
  final NotificationService _notificationService = NotificationService();

  // Stream controllers
  final StreamController<ChallengeRewardEvent> _rewardEventController =
      StreamController<ChallengeRewardEvent>.broadcast();
  final StreamController<List<DailyTaskRewardResult>> _rewardsBatchController =
      StreamController<List<DailyTaskRewardResult>>.broadcast();

  // Streams
  Stream<ChallengeRewardEvent> get rewardEventStream =>
      _rewardEventController.stream;
  Stream<List<DailyTaskRewardResult>> get rewardsBatchStream =>
      _rewardsBatchController.stream;

  // Batch tracking
  final List<DailyTaskRewardResult> _pendingRewards = [];
  Timer? _batchTimer;
  static const Duration _batchWindow = Duration(milliseconds: 300);

  // Track daily completions for bonus
  final Map<String, DateTime> _todayCompletions = {};
  int _todayCompletedCount = 0;

  bool _isInitialized = false;

  /// Initialize service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _startBatchTimer();
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ DailyTaskRewardService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing DailyTaskRewardService: $e');
      }
    }
  }

  /// Start batch timer for aggregating reward events
  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(_batchWindow, (_) {
      _flushPendingRewards();
    });
  }

  /// Flush pending rewards to stream
  void _flushPendingRewards() {
    if (_pendingRewards.isEmpty) return;

    final rewards = List<DailyTaskRewardResult>.from(_pendingRewards);
    _pendingRewards.clear();
    _rewardsBatchController.add(rewards);
  }

  /// Challenge tamamlandığında ödül ver
  /// Bu ana metod - hem points hem loot box yönetimi
  Future<DailyTaskRewardResult> grantRewardForChallengeCompletion({
    required DailyChallenge challenge,
    bool grantLootBox = true,
    bool forceLootBox = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return DailyTaskRewardResult.failure(
        challengeId: challenge.id,
        message: 'Kullanıcı giriş yapmamış',
      );
    }

    try {
      // Check if already rewarded today
      final todayKey = '${userId}_${challenge.id}_${_getDateKey(DateTime.now())}';
      if (_todayCompletions.containsKey(todayKey) && !forceLootBox) {
        if (kDebugMode) {
          debugPrint('ℹ️ Challenge already rewarded today: ${challenge.id}');
        }
        return DailyTaskRewardResult.failure(
          challengeId: challenge.id,
          message: 'Bugün için zaten ödül verildi',
        );
      }

      // Track completion
      _todayCompletions[todayKey] = DateTime.now();
      _todayCompletedCount++;

      final results = <DailyTaskRewardResult>[];
      final batch = _firestore.batch();

      // 1. Grant points (always)
      final pointsResult = await _grantPoints(
        challenge: challenge,
        batch: batch,
      );
      results.add(pointsResult);

      // 2. Grant loot box (if enabled)
      DailyTaskRewardResult? lootBoxResult;
      if (grantLootBox) {
        lootBoxResult = await _grantLootBoxForChallenge(
          challenge: challenge,
          batch: batch,
        );
        if (lootBoxResult != null) {
          results.add(lootBoxResult);
        }
      }

      // Commit batch
      await batch.commit();

      // Trigger UI refresh
      _stateRefreshService.triggerRewardsRefresh();
      _stateRefreshService.triggerProgressRefresh();

      // Show notification
      await _showRewardNotification(results);

      // Emit event
      for (final result in results) {
        final event = ChallengeRewardEvent(
          challengeId: challenge.id,
          challengeTitle: challenge.title,
          rewardResult: result,
          isFirstCompletion: _todayCompletedCount == 1,
        );
        _rewardEventController.add(event);
        _pendingRewards.add(result);
      }

      _flushPendingRewards();

      // Log activity
      await _logRewardActivity(challenge, results);

      if (kDebugMode) {
        debugPrint(
            '🎁 Rewards granted for challenge "${challenge.title}": ${results.length} rewards');
      }

      // Return the primary result (loot box if granted, else points)
      return lootBoxResult ?? pointsResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 Error granting reward for challenge: $e');
      }
      return DailyTaskRewardResult.failure(
        challengeId: challenge.id,
        message: 'Ödül verilemedi: $e',
      );
    }
  }

  /// Points grant helper
  Future<DailyTaskRewardResult> _grantPoints({
    required DailyChallenge challenge,
    required WriteBatch batch,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return DailyTaskRewardResult.failure(
        challengeId: challenge.id,
        message: 'Kullanıcı giriş yapmamış',
      );
    }

    try {
      // Update user points
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'totalPoints': FieldValue.increment(challenge.rewardPoints),
        'lastPointsUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Log points transaction
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('point_transactions')
          .doc();
      batch.set(transactionRef, {
        'amount': challenge.rewardPoints,
        'type': 'challenge_completion',
        'relatedId': challenge.id,
        'description': '"${challenge.title}" görev ödülü',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return DailyTaskRewardResult.points(
        challengeId: challenge.id,
        points: challenge.rewardPoints,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error granting points: $e');
      return DailyTaskRewardResult.failure(
        challengeId: challenge.id,
        message: 'Puanlar verilemedi',
      );
    }
  }

  /// Loot box grant based on challenge difficulty
  Future<DailyTaskRewardResult?> _grantLootBoxForChallenge({
    required DailyChallenge challenge,
    required WriteBatch batch,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Determine loot box rarity based on difficulty
      final rarity = _calculateLootBoxRarity(challenge.difficulty);

      // Grant loot box via LootBoxService
      final success = await _lootBoxService.grantLootBox(
        boxType: LootBoxType.challenge,
        rarity: rarity,
        sourceDescription: '"${challenge.title}" görev ödülü',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      if (!success) {
        if (kDebugMode) debugPrint('⚠️ Failed to grant loot box');
        return null;
      }

      return DailyTaskRewardResult.lootBox(
        challengeId: challenge.id,
        boxId: 'box_${challenge.id}',
        rarity: rarity,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error granting loot box: $e');
      return null;
    }
  }

  /// Calculate loot box rarity based on challenge difficulty
  LootBoxRarity _calculateLootBoxRarity(ChallengeDifficulty difficulty) {
    final random = Random();
    final value = random.nextDouble();

    switch (difficulty) {
      case ChallengeDifficulty.easy:
        // 100% Common
        return LootBoxRarity.common;

      case ChallengeDifficulty.medium:
        // 70% Common, 30% Rare
        if (value < 0.70) return LootBoxRarity.common;
        return LootBoxRarity.rare;

      case ChallengeDifficulty.hard:
        // 60% Rare, 30% Epic, 10% Legendary
        if (value < 0.60) return LootBoxRarity.rare;
        if (value < 0.90) return LootBoxRarity.epic;
        return LootBoxRarity.legendary;

      case ChallengeDifficulty.expert:
        // 50% Epic, 40% Legendary, 10% Mythic
        if (value < 0.50) return LootBoxRarity.epic;
        if (value < 0.90) return LootBoxRarity.legendary;
        return LootBoxRarity.mythic;
    }
  }

  /// Show reward notification
  Future<void> _showRewardNotification(
      List<DailyTaskRewardResult> results) async {
    try {
      final primaryResult = results.firstWhere(
        (r) => r.rewardType == DailyTaskRewardType.lootBox,
        orElse: () => results.first,
      );

      await _notificationService.showRewardNotification({
        'title': '🎉 Görev Tamamlandı!',
        'body': primaryResult.message ?? 'Ödül kazandın!',
        'rewardType': primaryResult.rewardType.index,
        'rewardId': primaryResult.rewardId,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error showing notification: $e');
    }
  }

  /// Log reward activity
  Future<void> _logRewardActivity(
    DailyChallenge challenge,
    List<DailyTaskRewardResult> results,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('user_activities')
          .doc(userId)
          .collection('activities')
          .add({
        'type': 'challenge_reward',
        'title': 'Görev Ödülü',
        'description': '"${challenge.title}" görevi tamamlandı',
        'metadata': {
          'challengeId': challenge.id,
          'challengeTitle': challenge.title,
          'rewards': results.map((r) => r.toJson()).toList(),
          'rewardCount': results.length,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error logging reward activity: $e');
    }
  }

  /// Get date key for tracking
  String _getDateKey(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }

  /// Get today's reward statistics
  Future<Map<String, dynamic>> getTodayRewardStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      final todayKey = _getDateKey(DateTime.now());

      final query = await _firestore
          .collection('user_activities')
          .doc(userId)
          .collection('activities')
          .where('type', isEqualTo: 'challenge_reward')
          .where('createdAt', isGreaterThanOrEqualTo: _getTodayStartTimestamp())
          .get();

      num totalPoints = 0;
      num lootBoxes = 0;

      for (final doc in query.docs) {
        final metadata = doc.data()['metadata'] as Map<String, dynamic>?;
        if (metadata != null) {
          final rewards = metadata['rewards'] as List?;
          if (rewards != null) {
            for (final reward in rewards) {
              final rewardData = reward as Map<String, dynamic>;
              if (rewardData['rewardType'] == 0) { // points
                totalPoints += (rewardData['metadata'] as Map)?['points'] ?? 0;
              } else if (rewardData['rewardType'] == 1) { // lootBox
                lootBoxes = lootBoxes + 1;
              }
            }
          }
        }
      }

      return {
        'totalPoints': totalPoints,
        'lootBoxes': lootBoxes,
        'completedCount': _todayCompletedCount,
        'date': todayKey,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting today stats: $e');
      return {};
    }
  }

  DateTime _getTodayStartTimestamp() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Reset daily tracking (call at midnight)
  void resetDailyTracking() {
    _todayCompletions.clear();
    _todayCompletedCount = 0;
    if (kDebugMode) {
      debugPrint('🔄 DailyTaskRewardService daily tracking reset');
    }
  }

  /// Dispose resources
  void dispose() {
    _batchTimer?.cancel();
    _rewardEventController.close();
    _rewardsBatchController.close();
    _isInitialized = false;
  }
}

