// lib/services/achievement_service.dart
// Achievement and progress tracking system for user engagement

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../models/daily_challenge.dart';
import '../models/task_reminder.dart';
import '../models/user_activity.dart';
import '../services/reward_service.dart';
import '../services/task_reminder_service.dart';
import '../services/user_activity_service.dart';

/// Achievement and progress tracking service
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  final RewardService _rewardService = RewardService();
  final TaskReminderService _taskReminderService = TaskReminderService();
  final UserActivityService _userActivityService = UserActivityService();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers for real-time updates
  final StreamController<List<Achievement>> _achievementsController =
      StreamController.broadcast();
  final StreamController<UserProgress> _progressController =
      StreamController.broadcast();
  final StreamController<List<DailyChallenge>> _challengesController =
      StreamController.broadcast();

  // Getters for streams
  Stream<List<Achievement>> get achievementsStream =>
      _achievementsController.stream;
  Stream<UserProgress> get progressStream => _progressController.stream;
  Stream<List<DailyChallenge>> get challengesStream =>
      _challengesController.stream;

  // Achievement definitions
  final List<Achievement> _allAchievements = [
    // Quiz Achievements
    Achievement(
      id: 'first_quiz',
      title: 'İlk Adım',
      description: 'İlk quizini tamamla',
      icon: '🎯',
      category: AchievementCategory.quiz,
      points: 10,
      requirements: {'completedQuizzes': 1},
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'quiz_master',
      title: 'Quiz Ustası',
      description: '10 quiz tamamla',
      icon: '🏆',
      category: AchievementCategory.quiz,
      points: 50,
      requirements: {'completedQuizzes': 10},
      rarity: AchievementRarity.rare,
    ),
    Achievement(
      id: 'perfect_score',
      title: 'Mükemmeliyetçi',
      description: 'Bir quizde %100 doğruluk oranı yakala',
      icon: '💎',
      category: AchievementCategory.quiz,
      points: 100,
      requirements: {'perfectScore': 1},
      rarity: AchievementRarity.epic,
    ),

    // Duel Achievements
    Achievement(
      id: 'first_duel',
      title: 'Düello Başlangıcı',
      description: 'İlk düellonu kazan',
      icon: '⚔️',
      category: AchievementCategory.duel,
      points: 25,
      requirements: {'duelWins': 1},
      rarity: AchievementRarity.common,
    ),
    Achievement(
      id: 'duel_champion',
      title: 'Düello Şampiyonu',
      description: '10 düello kazan',
      icon: '👑',
      category: AchievementCategory.duel,
      points: 150,
      requirements: {'duelWins': 10},
      rarity: AchievementRarity.legendary,
    ),

    // Social Achievements
    Achievement(
      id: 'social_butterfly',
      title: 'Sosyal Kelebek',
      description: '5 arkadaş ekle',
      icon: '🦋',
      category: AchievementCategory.social,
      points: 30,
      requirements: {'friendsCount': 5},
      rarity: AchievementRarity.rare,
    ),
    Achievement(
      id: 'team_player',
      title: 'Takım Oyuncusu',
      description: '5 çok oyunculu maç kazan',
      icon: '🤝',
      category: AchievementCategory.multiplayer,
      points: 75,
      requirements: {'multiplayerWins': 5},
      rarity: AchievementRarity.epic,
    ),

    // Streak Achievements
    Achievement(
      id: 'consistent_player',
      title: 'Düzenli Oyuncu',
      description: '7 gün üst üste oyna',
      icon: '🔥',
      category: AchievementCategory.streak,
      points: 200,
      requirements: {'loginStreak': 7},
      rarity: AchievementRarity.legendary,
    ),

    // Special Achievements
    Achievement(
      id: 'speed_demon',
      title: 'Hız Şeytanı',
      description: 'Bir quiz sorusunu 5 saniyede cevapla',
      icon: '⚡',
      category: AchievementCategory.special,
      points: 50,
      requirements: {'fastAnswer': 1},
      rarity: AchievementRarity.rare,
    ),
  ];

  /// Initialize service for current user
  Future<void> initializeForUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Load user progress
      await _loadUserProgress(userId);

      // Load achievements
      await _loadUserAchievements(userId);

      // Generate daily challenges
      await _generateDailyChallenges(userId);

      if (kDebugMode) {
        debugPrint('AchievementService initialized for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize AchievementService: $e');
    }
  }

  /// Load user progress from Firestore
  Future<void> _loadUserProgress(String userId) async {
    try {
      final doc =
          await _firestore.collection('user_progress').doc(userId).get();

      if (doc.exists) {
        final progress = UserProgress.fromJson(doc.data()!);
        _progressController.add(progress);
      } else {
        // Create initial progress
        final initialProgress = UserProgress(
          userId: userId,
          totalPoints: 0,
          level: 1,
          experiencePoints: 0,
          completedQuizzes: 0,
          duelWins: 0,
          multiplayerWins: 0,
          friendsCount: 0,
          loginStreak: 0,
          lastLoginDate: DateTime.now(),
          achievements: [],
          unlockedFeatures: [],
          bestScore: 0,
          totalTimeSpent: 0,
          weeklyActivity: {},
          totalDuels: 0,
        );

        await _firestore
            .collection('user_progress')
            .doc(userId)
            .set(initialProgress.toJson());
        _progressController.add(initialProgress);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user progress: $e');
    }
  }

  /// Load user achievements
  Future<void> _loadUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_achievements')
          .doc(userId)
          .collection('achievements')
          .get();

      final userAchievements =
          snapshot.docs.map((doc) => Achievement.fromJson(doc.data())).toList();

      _achievementsController.add(userAchievements);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user achievements: $e');
    }
  }

  /// Generate daily challenges
  Future<void> _generateDailyChallenges(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';

      // Check if challenges already exist for today
      final existingChallenges = await _firestore
          .collection('daily_challenges')
          .doc(userId)
          .collection('challenges')
          .where('date', isEqualTo: todayString)
          .get();

      if (existingChallenges.docs.isNotEmpty) {
        final challenges = existingChallenges.docs
            .map((doc) => DailyChallenge.fromJson(doc.data()))
            .toList();
        _challengesController.add(challenges);
        return;
      }

      // Generate new challenges
      final challenges = _createDailyChallenges(today);
      final batch = _firestore.batch();

      for (final challenge in challenges) {
        final docRef = _firestore
            .collection('daily_challenges')
            .doc(userId)
            .collection('challenges')
            .doc(challenge.id);

        batch.set(docRef, challenge.toJson());
      }

      await batch.commit();
      _challengesController.add(challenges);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to generate daily challenges: $e');
    }
  }

  /// Create daily challenges for the day
  List<DailyChallenge> _createDailyChallenges(DateTime date) {
    final challenges = <DailyChallenge>[];
    final random = DateTime.now().millisecond % 6; // Increased for more variety

    // Base challenges - always include these
    challenges.addAll([
      DailyChallenge(
        id: 'daily_quiz_${date.millisecondsSinceEpoch}',
        title: 'Günlük Quiz',
        description: 'Bugün 3 quiz tamamla',
        type: ChallengeType.quiz,
        targetValue: 3,
        currentValue: 0,
        rewardPoints: 25,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.easy,
        icon: '🧠',
      ),
      DailyChallenge(
        id: 'daily_duel_${date.millisecondsSinceEpoch}',
        title: 'Düello Mücadelesi',
        description: 'Bugün 2 düello kazan',
        type: ChallengeType.duel,
        targetValue: 2,
        currentValue: 0,
        rewardPoints: 50,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.medium,
        icon: '⚔️',
      ),
    ]);

    // Add 2-3 random challenges for more variety
    final randomChallenges = [
      DailyChallenge(
        id: 'daily_social_${date.millisecondsSinceEpoch}',
        title: 'Sosyal Bağ',
        description: 'Bugün 1 arkadaş ekle',
        type: ChallengeType.social,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 15,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.easy,
        icon: '👥',
      ),
      DailyChallenge(
        id: 'daily_multiplayer_${date.millisecondsSinceEpoch}',
        title: 'Takım Ruhu',
        description: 'Bugün 1 çok oyunculu maç kazan',
        type: ChallengeType.multiplayer,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 40,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.medium,
        icon: '🤝',
      ),
      DailyChallenge(
        id: 'daily_speed_${date.millisecondsSinceEpoch}',
        title: 'Hız Testi',
        description: 'Bir soruyu 10 saniyede cevapla',
        type: ChallengeType.special,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 30,
        rewardType: RewardType.feature,
        rewardItem: 'hint_system',
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.hard,
        icon: '⚡',
      ),
      DailyChallenge(
        id: 'daily_perfect_${date.millisecondsSinceEpoch}',
        title: 'Mükemmeliyet',
        description: 'Bir quizde %80+ doğruluk oranı yakala',
        type: ChallengeType.quiz,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 60,
        rewardType: RewardType.avatar,
        rewardItem: 'star_avatar',
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.hard,
        icon: '💎',
      ),
      DailyChallenge(
        id: 'daily_streak_${date.millisecondsSinceEpoch}',
        title: 'Seri Devam',
        description: '7 günlük giriş serini koru',
        type: ChallengeType.streak,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 75,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.medium,
        icon: '🔥',
      ),
      DailyChallenge(
        id: 'daily_carbon_${date.millisecondsSinceEpoch}',
        title: 'Çevre Dostu',
        description: 'Karbon ayak izini hesapla',
        type: ChallengeType.energy,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 20,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.easy,
        icon: '🌱',
      ),
      DailyChallenge(
        id: 'daily_explore_${date.millisecondsSinceEpoch}',
        title: 'Keşif',
        description: 'Uygulamada 3 farklı bölüm keşfet',
        type: ChallengeType.social,
        targetValue: 3,
        currentValue: 0,
        rewardPoints: 35,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.easy,
        icon: '🔍',
      ),
      DailyChallenge(
        id: 'daily_share_${date.millisecondsSinceEpoch}',
        title: 'Paylaş',
        description: 'Skorunu arkadaşlarınla paylaş',
        type: ChallengeType.social,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 25,
        rewardType: RewardType.points,
        date: date,
        isCompleted: false,
        expiresAt: date.add(const Duration(days: 1)),
        difficulty: ChallengeDifficulty.easy,
        icon: '📤',
      ),
    ];

    // Shuffle and pick 2-3 random challenges
    randomChallenges.shuffle();
    challenges.addAll(randomChallenges.take(3));

    return challenges;
  }

  /// Update user progress
  Future<void> updateProgress({
    int? completedQuizzes,
    int? duelWins,
    int? multiplayerWins,
    int? friendsCount,
    bool? perfectScore,
    bool? fastAnswer,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final docRef = _firestore.collection('user_progress').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) return;

      final currentProgress = UserProgress.fromJson(doc.data()!);
      final updatedProgress = currentProgress.copyWith(
        completedQuizzes: completedQuizzes != null
            ? currentProgress.completedQuizzes + completedQuizzes
            : currentProgress.completedQuizzes,
        duelWins: duelWins != null
            ? currentProgress.duelWins + duelWins
            : currentProgress.duelWins,
        multiplayerWins: multiplayerWins != null
            ? currentProgress.multiplayerWins + multiplayerWins
            : currentProgress.multiplayerWins,
        friendsCount: friendsCount != null
            ? currentProgress.friendsCount + friendsCount
            : currentProgress.friendsCount,
      );

      // Calculate new level and experience
      final newProgress = _calculateLevelAndExperience(updatedProgress);

      // Check for new achievements
      final newAchievements = await _checkForNewAchievements(newProgress);

      // Update Firestore
      await docRef.update(newProgress.toJson());

      // Update streams
      _progressController.add(newProgress);

      // Log activity for quiz completion
      if (completedQuizzes != null && completedQuizzes > 0) {
        await _userActivityService.logActivity(
          type: ActivityType.quizCompleted,
          title: 'Quiz Tamamlandı',
          description: '$completedQuizzes quiz başarıyla tamamlandı',
          metadata: {'score': completedQuizzes},
        );
      }

      // Award new achievements
      if (newAchievements.isNotEmpty) {
        await _awardAchievements(userId, newAchievements);

        // Check for unlockable rewards
        await _checkForUnlockableRewards(newProgress);
      }

      // Update daily challenges
      await _updateDailyChallenges(
        userId: userId,
        completedQuizzes: completedQuizzes,
        duelWins: duelWins,
        multiplayerWins: multiplayerWins,
        friendsCount: friendsCount,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update progress: $e');
    }
  }

  /// Calculate level and experience points
  UserProgress _calculateLevelAndExperience(UserProgress progress) {
    // Simple leveling system: 100 XP per level
    final totalXP = progress.duelWins * 20 +
        progress.completedQuizzes * 10 +
        progress.multiplayerWins * 15 +
        progress.friendsCount * 5;

    final newLevel = (totalXP / 100).floor() + 1;
    final experiencePoints = totalXP % 100;

    return progress.copyWith(
      level: newLevel,
      experiencePoints: experiencePoints,
      totalPoints: totalXP,
    );
  }

  /// Check for new achievements
  Future<List<Achievement>> _checkForNewAchievements(
      UserProgress progress) async {
    final newAchievements = <Achievement>[];

    for (final achievement in _allAchievements) {
      if (progress.achievements.contains(achievement.id)) continue;

      bool unlocked = true;
      achievement.requirements.forEach((key, value) {
        switch (key) {
          case 'completedQuizzes':
            if (progress.completedQuizzes < value) unlocked = false;
            break;
          case 'duelWins':
            if (progress.duelWins < value) unlocked = false;
            break;
          case 'multiplayerWins':
            if (progress.multiplayerWins < value) unlocked = false;
            break;
          case 'friendsCount':
            if (progress.friendsCount < value) unlocked = false;
            break;
          case 'loginStreak':
            if (progress.loginStreak < value) unlocked = false;
            break;
          case 'perfectScore':
            if (!progress.achievements.contains('perfect_score')) {
              unlocked = false;
            }
            break;
          case 'fastAnswer':
            if (!progress.achievements.contains('speed_demon')) {
              unlocked = false;
            }
            break;
        }
      });

      if (unlocked) {
        newAchievements.add(achievement);
      }
    }

    return newAchievements;
  }

  /// Award achievements to user
  Future<void> _awardAchievements(
      String userId, List<Achievement> achievements) async {
    final batch = _firestore.batch();

    for (final achievement in achievements) {
      final docRef = _firestore
          .collection('user_achievements')
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id);

      batch.set(docRef, {
        ...achievement.toJson(),
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    // Update progress with new achievements
    final progressDoc =
        await _firestore.collection('user_progress').doc(userId).get();
    if (progressDoc.exists) {
      final progress = UserProgress.fromJson(progressDoc.data()!);
      final updatedAchievements = [...progress.achievements];
      updatedAchievements.addAll(achievements.map((a) => a.id));

      await _firestore.collection('user_progress').doc(userId).update({
        'achievements': updatedAchievements,
      });

      _progressController
          .add(progress.copyWith(achievements: updatedAchievements));
    }

    // Update achievements stream
    final currentAchievements = await _loadUserAchievementsList(userId);
    _achievementsController.add(currentAchievements);
  }

  /// Load user achievements list
  Future<List<Achievement>> _loadUserAchievementsList(String userId) async {
    final snapshot = await _firestore
        .collection('user_achievements')
        .doc(userId)
        .collection('achievements')
        .get();

    return snapshot.docs
        .map((doc) => Achievement.fromJson(doc.data()))
        .toList();
  }

  /// Update daily challenges progress
  Future<void> _updateDailyChallenges({
    required String userId,
    int? completedQuizzes,
    int? duelWins,
    int? multiplayerWins,
    int? friendsCount,
  }) async {
    try {
      final challengesRef = _firestore
          .collection('daily_challenges')
          .doc(userId)
          .collection('challenges');

      final snapshot = await challengesRef.get();

      for (final doc in snapshot.docs) {
        final challenge = DailyChallenge.fromJson(doc.data());
        bool updated = false;

        if (!challenge.isCompleted) {
          switch (challenge.type) {
            case ChallengeType.quiz:
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.duel:
              if (duelWins != null && duelWins > 0) {
                final newCurrentValue = (challenge.currentValue + duelWins)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.multiplayer:
              if (multiplayerWins != null && multiplayerWins > 0) {
                final newCurrentValue = (challenge.currentValue + multiplayerWins)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.social:
              if (friendsCount != null && friendsCount > 0) {
                final newCurrentValue = (challenge.currentValue + friendsCount)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.special:
              // Special challenges are handled manually
              break;
            case ChallengeType.weekly:
              // Weekly challenges are handled separately
              break;
            case ChallengeType.seasonal:
              // Seasonal challenges are handled separately
              break;
            case ChallengeType.friendship:
              // Friendship challenges are handled separately
              break;
            case ChallengeType.streak:
              // Streak challenges are handled separately
              break;
            case ChallengeType.energy:
              // Energy challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.water:
              // Water challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.recycling:
              // Recycling challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.forest:
              // Forest challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.climate:
              // Climate challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.transportation:
              // Transportation challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.biodiversity:
              // Biodiversity challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.consumption:
              // Consumption challenges are quiz-based
              if (completedQuizzes != null && completedQuizzes > 0) {
                final newCurrentValue = (challenge.currentValue + completedQuizzes)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
            case ChallengeType.boardGame:
              // Board game challenges
              if (multiplayerWins != null && multiplayerWins > 0) {
                final newCurrentValue = (challenge.currentValue + multiplayerWins)
                    .clamp(0, challenge.targetValue);
                final updatedChallenge = challenge.copyWith(
                  currentValue: newCurrentValue,
                  isCompleted: newCurrentValue >= challenge.targetValue,
                );
                await doc.reference.update(updatedChallenge.toJson());
                updated = true;
              }
              break;
          }

          if (updated) {
            // Challenge was already updated in the switch cases above
          }
        }
      }

      // Reload challenges
      final updatedChallenges = snapshot.docs
          .map((doc) => DailyChallenge.fromJson(doc.data()))
          .toList();
      _challengesController.add(updatedChallenges);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update daily challenges: $e');
    }
  }

  /// Get user achievements (requires initialization first)
  Future<List<Achievement>> getUserAchievements(String userId) async {
    await initializeForUser();
    return _loadUserAchievementsList(userId);
  }

  /// Get all available achievements
  List<Achievement> getAllAchievements() => _allAchievements;

  /// Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _allAchievements
        .where((achievement) => achievement.category == category)
        .toList();
  }

  /// Check if user has achievement
  Future<bool> hasAchievement(String achievementId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('user_achievements')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get user level info
  Future<Map<String, dynamic>> getUserLevelInfo() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      final doc =
          await _firestore.collection('user_progress').doc(userId).get();
      if (!doc.exists) return {};

      final progress = UserProgress.fromJson(doc.data()!);
      final nextLevelXP = progress.level * 100;
      final progressToNext = (progress.experiencePoints / 100) * 100;

      return {
        'currentLevel': progress.level,
        'experiencePoints': progress.experiencePoints,
        'nextLevelXP': nextLevelXP,
        'progressToNext': progressToNext.clamp(0, 100),
        'totalPoints': progress.totalPoints,
      };
    } catch (e) {
      return {};
    }
  }

  /// Check for unlockable rewards based on progress
  Future<void> _checkForUnlockableRewards(UserProgress progress) async {
    try {
      final availableRewards = await _rewardService.getAvailableRewards(progress);
      
      for (final reward in availableRewards) {
        await _rewardService.unlockReward(reward.id);
        if (kDebugMode) {
          debugPrint('Unlocked reward: ${reward.name} for user progress');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to check unlockable rewards: $e');
    }
  }

  /// Create reminders for incomplete daily challenges
  Future<void> createChallengeReminders(String userId) async {
    try {
      final challenges = await _getTodayChallenges(userId);
      final incompleteChallenges = challenges.where((c) => !c.isCompleted && !c.isExpired).toList();

      for (final challenge in incompleteChallenges) {
        // Check if reminder already exists
        final existingReminders = await _taskReminderService.getTasksByCategory('challenge_${challenge.id}');
        if (existingReminders.isNotEmpty) continue;

        // Create reminder for evening (6 PM)
        final now = DateTime.now();
        final reminderTime = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM

        // Only create if it's before reminder time
        if (now.isBefore(reminderTime)) {
          final reminder = TaskReminder(
            id: '',
            userId: userId,
            title: 'Görev Hatırlatma: ${challenge.title}',
            description: '${challenge.description} - ${challenge.currentValue}/${challenge.targetValue} tamamlandı.',
            category: 'challenge_${challenge.id}',
            scheduledTime: reminderTime,
            status: TaskStatus.pending,
            reminderType: ReminderType.daily,
            isRecurring: false,
            streakCount: 0,
            createdAt: now,
          );

          await _taskReminderService.createTaskReminder(reminder);
          if (kDebugMode) {
            debugPrint('Created reminder for challenge: ${challenge.title}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to create challenge reminders: $e');
    }
  }

  /// Get today's challenges for a user
  Future<List<DailyChallenge>> _getTodayChallenges(String userId) async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';

      final snapshot = await _firestore
          .collection('daily_challenges')
          .doc(userId)
          .collection('challenges')
          .where('date', isEqualTo: todayString)
          .get();

      return snapshot.docs
          .map((doc) => DailyChallenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get today challenges: $e');
      return [];
    }
  }

  /// Clean up resources
  void dispose() {
    _achievementsController.close();
    _progressController.close();
    _challengesController.close();
  }
}
