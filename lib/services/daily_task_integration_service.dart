// lib/services/daily_task_integration_service.dart
// Günlük Görev Entegrasyon Servisi
// FriendshipService, Game Service ve Quiz Service ile entegrasyon

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_challenge.dart';
import 'challenge_service.dart';
import 'friendship_service.dart';
import 'duel_game_logic.dart';
import 'game_logic.dart';

/// Entegrasyon olay tipleri
enum DailyTaskIntegrationEvent {
  friendAdded,
  gameCompleted,
  quizCompleted,
  duelWon,
  streakUpdated,
}

/// Entegrasyon olay verisi
class DailyTaskIntegrationEventData {
  final DailyTaskIntegrationEvent type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const DailyTaskIntegrationEventData({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

/// Günlük görev entegrasyon servisi
class DailyTaskIntegrationService {
  static final DailyTaskIntegrationService _instance =
      DailyTaskIntegrationService._internal();
  factory DailyTaskIntegrationService() => _instance;
  DailyTaskIntegrationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChallengeService _challengeService = ChallengeService();
  final FriendshipService _friendshipService = FriendshipService();

  // Stream controllers
  final StreamController<DailyTaskIntegrationEventData> _eventController =
      StreamController<DailyTaskIntegrationEventData>.broadcast();

  // Stream getters
  Stream<DailyTaskIntegrationEventData> get eventStream =>
      _eventController.stream;

  bool _isInitialized = false;

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // FriendshipService dinleyicilerini ayarla
      _setupFriendshipListeners();

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ DailyTaskIntegrationService başlatıldı');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Entegrasyon servisi başlatma hatası: $e');
    }
  }

  /// Friendship dinleyicilerini ayarla
  void _setupFriendshipListeners() {
    // Arkadaş ekleme olaylarını dinle
    // Bu, FriendshipService'in başarılı arkadaş ekleme işlemlerinden sonra tetiklenir
  }

  /// Arkadaş eklendiğinde çağır
  Future<void> onFriendAdded(String friendId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Event'i yayınla
      final event = DailyTaskIntegrationEventData(
        type: DailyTaskIntegrationEvent.friendAdded,
        data: {
          'friendId': friendId,
          'increment': 1,
        },
        timestamp: DateTime.now(),
      );
      _eventController.add(event);

      // Günlük ve haftalık görevleri güncelle
      await _updateSocialChallenges(increment: 1);

      if (kDebugMode) {
        debugPrint('👤 Arkadaş eklendi: $friendId, görevler güncellendi');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Arkadaş ekleme güncelleme hatası: $e');
    }
  }

  /// Oyun tamamlandığında çağır
  Future<void> onGameCompleted({
    required String gameType,
    required bool isWinner,
    required int score,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final increment = isWinner ? 1 : 0;

      // Event'i yayınla
      final event = DailyTaskIntegrationEventData(
        type: DailyTaskIntegrationEvent.gameCompleted,
        data: {
          'gameType': gameType,
          'isWinner': isWinner,
          'score': score,
          'increment': increment,
        },
        timestamp: DateTime.now(),
      );
      _eventController.add(event);

      // Oyun tipine göre görevleri güncelle
      if (gameType == 'duel') {
        await _updateDuelChallenges(increment: increment);
      } else if (gameType == 'board_game' || gameType == 'multiplayer') {
        await _updateMultiplayerChallenges(increment: increment);
      } else if (gameType == 'boardGame') {
        await _updateBoardGameChallenges(increment: increment);
      }

      if (kDebugMode) {
        debugPrint(
            '🎮 Oyun tamamlandı: $gameType, kazanan: $isWinner, görevler güncellendi');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Oyun güncelleme hatası: $e');
    }
  }

  /// Düello kazanıldığında çağır
  Future<void> onDuelWon({required int score}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Event'i yayınla
      final event = DailyTaskIntegrationEventData(
        type: DailyTaskIntegrationEvent.duelWon,
        data: {
          'score': score,
          'increment': 1,
        },
        timestamp: DateTime.now(),
      );
      _eventController.add(event);

      // Düello görevlerini güncelle
      await _updateDuelChallenges(increment: 1);

      if (kDebugMode) {
        debugPrint('⚔️ Düello kazanıldı: $score puan, görevler güncellendi');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Düello güncelleme hatası: $e');
    }
  }

  /// Quiz tamamlandığında çağır
  Future<void> onQuizCompleted({
    required int correctAnswers,
    required int totalQuestions,
    required String category,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Event'i yayınla
      final event = DailyTaskIntegrationEventData(
        type: DailyTaskIntegrationEvent.quizCompleted,
        data: {
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'category': category,
          'increment': 1,
        },
        timestamp: DateTime.now(),
      );
      _eventController.add(event);

      // Quiz görevlerini güncelle
      await _updateQuizChallenges(increment: 1);

      // Kategori bazlı görevleri güncelle
      await _updateCategoryChallenges(category: category, increment: 1);

      if (kDebugMode) {
        debugPrint(
            '🧠 Quiz tamamlandı: $correctAnswers/$totalQuestions doğru, görevler güncellendi');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Quiz güncelleme hatası: $e');
    }
  }

  /// Seri güncellendiğinde çağır
  Future<void> onStreakUpdated({required int streakDays}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Event'i yayınla
      final event = DailyTaskIntegrationEventData(
        type: DailyTaskIntegrationEvent.streakUpdated,
        data: {
          'streakDays': streakDays,
          'increment': 1,
        },
        timestamp: DateTime.now(),
      );
      _eventController.add(event);

      // Streak görevlerini güncelle
      await _updateStreakChallenges(increment: 1);

      if (kDebugMode) {
        debugPrint('🔥 Seri güncellendi: $streakDays gün');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Streak güncelleme hatası: $e');
    }
  }

  /// Sosyal görevleri güncelle
  Future<void> _updateSocialChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Bugünkü sosyal görevleri al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', whereIn: [
            ChallengeType.social.index,
            ChallengeType.friendship.index,
          ])
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint(
              '✅ Sosyal görev güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }

      // Haftalık sosyal görevleri de güncelle
      await _updateWeeklySocialChallenges(increment: increment);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Sosyal görev güncelleme hatası: $e');
    }
  }

  /// Haftalık sosyal görevleri güncelle
  Future<void> _updateWeeklySocialChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Bu haftaki sosyal görevleri al
      final weeklyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weekly_challenges')
          .where('weekStart', isGreaterThanOrEqualTo: weekStart.millisecondsSinceEpoch)
          .where('weekStart', isLessThan: weekEnd.millisecondsSinceEpoch)
          .where('type', whereIn: [
            ChallengeType.friendship.index,
          ])
          .where('isCompleted', isEqualTo: false);

      final snapshot = await weeklyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = WeeklyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint(
              '✅ Haftalık sosyal görev güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Haftalık sosyal görev güncelleme hatası: $e');
    }
  }

  /// Düello görevlerini güncelle
  Future<void> _updateDuelChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Bugünkü düello görevlerini al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: ChallengeType.duel.index)
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (isCompleted) {
          await _logChallengeCompletion(challenge, 'duel_win');
        }

        if (kDebugMode) {
          debugPrint(
              '✅ Düello görevi güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Düello görevi güncelleme hatası: $e');
    }
  }

  /// Çok oyunculu görevleri güncelle
  Future<void> _updateMultiplayerChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Bugünkü çok oyunculu görevleri al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: ChallengeType.multiplayer.index)
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint(
              '✅ Çok oyunculu görev güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Çok oyunculu görev güncelleme hatası: $e');
    }
  }

  /// Masa oyunu görevlerini güncelle
  Future<void> _updateBoardGameChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Bugünkü masa oyunu görevlerini al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: ChallengeType.boardGame.index)
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint(
              '✅ Masa oyunu görevi güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Masa oyunu görevi güncelleme hatası: $e');
    }
  }

  /// Quiz görevlerini güncelle
  Future<void> _updateQuizChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Bugünkü quiz görevlerini al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: ChallengeType.quiz.index)
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (isCompleted) {
          await _logChallengeCompletion(challenge, 'quiz_completion');
        }

        if (kDebugMode) {
          debugPrint(
              '✅ Quiz görevi güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Quiz görevi güncelleme hatası: $e');
    }
  }

  /// Kategori bazlı görevleri güncelle
  Future<void> _updateCategoryChallenges({
    required String category,
    required int increment,
  }) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Kategori tipini belirle
      ChallengeType? categoryType;
      switch (category.toLowerCase()) {
        case 'energy':
          categoryType = ChallengeType.energy;
          break;
        case 'water':
          categoryType = ChallengeType.water;
          break;
        case 'recycling':
          categoryType = ChallengeType.recycling;
          break;
        case 'forest':
          categoryType = ChallengeType.forest;
          break;
        case 'climate':
          categoryType = ChallengeType.climate;
          break;
        case 'transportation':
          categoryType = ChallengeType.transportation;
          break;
        case 'biodiversity':
          categoryType = ChallengeType.biodiversity;
          break;
        case 'consumption':
          categoryType = ChallengeType.consumption;
          break;
        default:
          return;
      }

      // Bugünkü kategori görevlerini al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: categoryType.index)
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint(
              '✅ ${category} görevi güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Kategori görevi güncelleme hatası: $e');
    }
  }

  /// Streak görevlerini güncelle
  Future<void> _updateStreakChallenges({required int increment}) async {
    if (increment <= 0) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Bugünkü streak görevlerini al
      final dailyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_challenges')
          .where('date', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
          .where('date', isLessThan: todayEnd.millisecondsSinceEpoch)
          .where('type', isEqualTo: ChallengeType.streak.index)
          .where('isCompleted', isEqualTo: false);

      final snapshot = await dailyQuery.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });

        final newValue = (challenge.currentValue + increment)
            .clamp(0, challenge.targetValue);
        final isCompleted = newValue >= challenge.targetValue;

        await doc.reference.update({
          'currentValue': newValue,
          'isCompleted': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          debugPrint(
              '✅ Streak görevi güncellendi: "${challenge.title}" -> $newValue/${challenge.targetValue}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Streak görevi güncelleme hatası: $e');
    }
  }

  /// Görev tamamlandığında logla
  Future<void> _logChallengeCompletion(
    DailyChallenge challenge,
    String action,
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
          'challengeId': challenge.id,
          'challengeTitle': challenge.title,
          'rewardPoints': challenge.rewardPoints,
          'action': action,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('🎉 Görev tamamlandı loglandı: ${challenge.title}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Log hatası: $e');
    }
  }

  /// Hafta başlangıcını hesapla
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    final mondayOffset = dayOfWeek - DateTime.monday;
    return date.subtract(Duration(days: mondayOffset));
  }

  /// Mevcut aktif görevleri getir
  Future<List<DailyChallenge>> getActiveChallenges() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      return await _challengeService.getTodayDailyChallenges(uid: user.uid);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Aktif görevler getirme hatası: $e');
      return [];
    }
  }

  /// Servisi durdur
  void dispose() {
    _eventController.close();
    _isInitialized = false;
  }
}

