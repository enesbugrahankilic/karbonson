// lib/services/enhanced_reward_service.dart
// Gelişmiş Ödül Servisi - Karbon Puanı ve Ödül Sistemi

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reward_models.dart';
import '../models/user_progress.dart';

class EnhancedRewardService {
  static final EnhancedRewardService _instance = EnhancedRewardService._internal();
  factory EnhancedRewardService() => _instance;
  EnhancedRewardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final StreamController<PointWallet> _walletController = StreamController.broadcast();
  final StreamController<UserRewardInventory> _inventoryController = StreamController.broadcast();
  final StreamController<UserStreak> _streakController = StreamController.broadcast();
  final StreamController<List<MilestoneReward>> _milestonesController = StreamController.broadcast();

  Stream<PointWallet> get walletStream => _walletController.stream;
  Stream<UserRewardInventory> get inventoryStream => _inventoryController.stream;
  Stream<UserStreak> get streakStream => _streakController.stream;
  Stream<List<MilestoneReward>> get milestonesStream => _milestonesController.stream;

  final List<StreakReward> _streakRewards = [
    StreakReward(id: 'streak_3', streakDays: 3, pointsBonus: 50, icon: '🔥', title: '3 Gün Seri'),
    StreakReward(id: 'streak_7', streakDays: 7, pointsBonus: 150, icon: '⚡', title: 'Haftalık Ustası'),
    StreakReward(id: 'streak_14', streakDays: 14, pointsBonus: 300, icon: '🌟', title: 'İki Haftalık Efsane'),
    StreakReward(id: 'streak_30', streakDays: 30, pointsBonus: 1000, icon: '👑', title: 'Aylık Şampiyon'),
    StreakReward(id: 'streak_100', streakDays: 100, pointsBonus: 5000, icon: '💎', title: 'Yüzlük Efsane'),
  ];

  List<MilestoneReward> _getDefaultMilestones() {
    return [
      MilestoneReward(
        id: 'milestone_quiz_10', name: 'Quiz Acemisi', description: '10 quiz tamamla',
        icon: '🎯', targetValue: 10, targetType: 'quiz',
        reward: Reward(id: 'avatar_beginner', name: 'Acemi Avatar', description: 'Yeni başlayanlar için özel avatar',
          icon: '🌱', type: RewardType.avatar, rarity: RewardRarity.common, status: RewardStatus.locked,
          unlockRequirement: 0, category: 'milestone'),
      ),
      MilestoneReward(
        id: 'milestone_quiz_50', name: 'Quiz Ustası', description: '50 quiz tamamla',
        icon: '🏆', targetValue: 50, targetType: 'quiz',
        reward: Reward(id: 'avatar_master', name: 'Usta Avatar', description: 'Quiz ustaları için özel avatar',
          icon: '🎖️', type: RewardType.avatar, rarity: RewardRarity.rare, status: RewardStatus.locked,
          unlockRequirement: 0, category: 'milestone'),
      ),
      MilestoneReward(
        id: 'milestone_duel_10', name: 'Düello Savaşçısı', description: '10 düello kazan',
        icon: '⚔️', targetValue: 10, targetType: 'duel',
        reward: Reward(id: 'theme_warrior', name: 'Savaşçı Teması', description: 'Düello şampiyonları için özel tema',
          icon: '⚔️', type: RewardType.theme, rarity: RewardRarity.epic, status: RewardStatus.locked,
          unlockRequirement: 0, category: 'milestone'),
      ),
      MilestoneReward(
        id: 'milestone_points_1000', name: 'Bin Puan', description: '1000 Karbon Puanı topla',
        icon: '💰', targetValue: 1000, targetType: 'points',
        reward: Reward(id: 'title_point_master', name: 'Puan Ustası', description: 'Bin puan barajını aşanlara verilen unvan',
          icon: '💎', type: RewardType.title, rarity: RewardRarity.legendary, status: RewardStatus.locked,
          unlockRequirement: 0, category: 'milestone'),
      ),
      MilestoneReward(
        id: 'milestone_level_10', name: 'Seviye 10', description: '10. seviyeye ulaş',
        icon: '⬆️', targetValue: 10, targetType: 'level',
        reward: Reward(id: 'feature_double_points', name: 'Çift Puan Gücü', description: 'Bir quizde 2x puan kazanma gücü',
          icon: '💪', type: RewardType.feature, rarity: RewardRarity.legendary, status: RewardStatus.locked,
          unlockRequirement: 0, properties: {'multiplier': 2.0}, category: 'milestone'),
      ),
    ];
  }

  Future<void> initializeForUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _loadUserWallet(userId);
      await _loadUserInventory(userId);
      await _loadUserStreak(userId);
      await _loadMilestones(userId);
      if (kDebugMode) debugPrint('EnhancedRewardService initialized for user: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize EnhancedRewardService: $e');
    }
  }

  Future<void> _loadUserWallet(String userId) async {
    try {
      final doc = await _firestore.collection('point_wallets').doc(userId).get();
      if (doc.exists) {
        final wallet = PointWallet.fromJson(doc.data()!);
        _walletController.add(wallet);
      } else {
        final initialWallet = PointWallet(
          userId: userId, totalPoints: 0, availablePoints: 0, lifetimePoints: 0,
          levelPoints: 0, streakMultiplier: 1, lastEarnedAt: DateTime.now(), transactions: [],
        );
        await _firestore.collection('point_wallets').doc(userId).set(initialWallet.toJson());
        _walletController.add(initialWallet);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user wallet: $e');
    }
  }

  Future<void> _loadUserInventory(String userId) async {
    try {
      final doc = await _firestore.collection('user_rewards').doc(userId).get();
      if (doc.exists) {
        final inventory = UserRewardInventory.fromJson(doc.data()!);
        _inventoryController.add(inventory);
      } else {
        final initialInventory = UserRewardInventory(
          userId: userId, unlockedRewardIds: [], equippedAvatarIds: [], equippedThemeIds: [],
          unlockedTitleIds: [], itemQuantities: {}, lastUpdated: DateTime.now(),
        );
        await _firestore.collection('user_rewards').doc(userId).set(initialInventory.toJson());
        _inventoryController.add(initialInventory);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user inventory: $e');
    }
  }

  Future<void> _loadUserStreak(String userId) async {
    try {
      final doc = await _firestore.collection('user_streaks').doc(userId).get();
      if (doc.exists) {
        final streak = UserStreak.fromJson(doc.data()!);
        final updatedStreak = streak.updateStreak();
        _streakController.add(updatedStreak);
        await _firestore.collection('user_streaks').doc(userId).set(updatedStreak.toJson());
      } else {
        final initialStreak = UserStreak(
          userId: userId, currentStreak: 0, longestStreak: 0, lastLoginDate: DateTime.now(),
          consecutiveDays: 0, weeklyBonusClaimed: 0, streakStartDate: DateTime.now(),
        );
        await _firestore.collection('user_streaks').doc(userId).set(initialStreak.toJson());
        _streakController.add(initialStreak);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user streak: $e');
    }
  }

  Future<void> _loadMilestones(String userId) async {
    try {
      final doc = await _firestore.collection('user_milestones').doc(userId).get();
      final defaultMilestones = _getDefaultMilestones();
      if (doc.exists) {
        final data = doc.data()!;
        final userMilestones = (data['milestones'] as List?)
            ?.map((m) => MilestoneReward.fromJson(m)).toList() ?? defaultMilestones;
        _milestonesController.add(userMilestones);
      } else {
        await _firestore.collection('user_milestones').doc(userId).set({
          'userId': userId,
          'milestones': defaultMilestones.map((m) => m.toJson()).toList(),
        });
        _milestonesController.add(defaultMilestones);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load milestones: $e');
    }
  }

  Future<bool> addPoints({required int amount, required PointTransactionType type, required String description, String? relatedId}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      final doc = await _firestore.collection('point_wallets').doc(userId).get();
      if (!doc.exists) return false;
      final currentWallet = PointWallet.fromJson(doc.data()!);
      final newWallet = PointWallet(
        userId: userId, totalPoints: currentWallet.totalPoints + amount, availablePoints: currentWallet.availablePoints + amount,
        lifetimePoints: currentWallet.lifetimePoints + amount, levelPoints: currentWallet.levelPoints,
        streakMultiplier: currentWallet.streakMultiplier, lastEarnedAt: DateTime.now(),
        transactions: [...currentWallet.transactions, PointTransaction(
          id: '${userId}_${DateTime.now().millisecondsSinceEpoch}', userId: userId,
          amount: amount, type: type, description: description, timestamp: DateTime.now(), relatedId: relatedId,
        )],
      );
      await _firestore.collection('point_wallets').doc(userId).update(newWallet.toJson());
      _walletController.add(newWallet);
      await _checkMilestoneProgress(userId, 'points', newWallet.lifetimePoints);
      if (kDebugMode) debugPrint('Added $amount points to user $userId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to add points: $e');
      return false;
    }
  }

  Future<bool> spendPoints({required int amount, required String description, String? relatedId}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      final doc = await _firestore.collection('point_wallets').doc(userId).get();
      if (!doc.exists) return false;
      final currentWallet = PointWallet.fromJson(doc.data()!);
      if (currentWallet.availablePoints < amount) {
        if (kDebugMode) debugPrint('Insufficient points');
        return false;
      }
      final newWallet = PointWallet(
        userId: userId, totalPoints: currentWallet.totalPoints, availablePoints: currentWallet.availablePoints - amount,
        lifetimePoints: currentWallet.lifetimePoints, levelPoints: currentWallet.levelPoints,
        streakMultiplier: currentWallet.streakMultiplier, lastEarnedAt: currentWallet.lastEarnedAt,
        transactions: [...currentWallet.transactions, PointTransaction(
          id: '${userId}_${DateTime.now().millisecondsSinceEpoch}', userId: userId,
          amount: -amount, type: PointTransactionType.spent, description: description, timestamp: DateTime.now(), relatedId: relatedId,
        )],
      );
      await _firestore.collection('point_wallets').doc(userId).update(newWallet.toJson());
      _walletController.add(newWallet);
      if (kDebugMode) debugPrint('Spent $amount points by user $userId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to spend points: $e');
      return false;
    }
  }

  Future<void> onQuizCompleted({required int score, required bool isPerfect, required int timeSpent}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      int points = score;
      if (isPerfect) points += 50;
      if (timeSpent < 30) points += 20;
      await addPoints(amount: points, type: PointTransactionType.earned, description: 'Quiz tamamlama ödülü');
      final progressDoc = await _firestore.collection('user_progress').doc(userId).get();
      if (progressDoc.exists) {
        final progress = UserProgress.fromJson(progressDoc.data()!);
        await _checkMilestoneProgress(userId, 'quiz', progress.completedQuizzes);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to process quiz reward: $e');
    }
  }

  Future<void> onDuelWon() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await addPoints(amount: 100, type: PointTransactionType.earned, description: 'Düello zafer ödülü');
      final progressDoc = await _firestore.collection('user_progress').doc(userId).get();
      if (progressDoc.exists) {
        final progress = UserProgress.fromJson(progressDoc.data()!);
        await _checkMilestoneProgress(userId, 'duel', progress.duelWins);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to process duel reward: $e');
    }
  }

  Future<int?> onDailyLogin() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    try {
      final doc = await _firestore.collection('user_streaks').doc(userId).get();
      if (!doc.exists) return null;
      final streak = UserStreak.fromJson(doc.data()!);
      final updatedStreak = streak.updateStreak();
      await _firestore.collection('user_streaks').doc(userId).set(updatedStreak.toJson());
      _streakController.add(updatedStreak);
      int basePoints = 10;
      int streakBonus = 0;
      for (final reward in _streakRewards) {
        if (updatedStreak.currentStreak >= reward.streakDays) streakBonus = reward.pointsBonus;
      }
      final totalPoints = basePoints + streakBonus;
      await addPoints(amount: totalPoints, type: PointTransactionType.daily_login, description: 'Günlük giriş ödülü');
      if (kDebugMode) debugPrint('Daily login reward: $totalPoints points (streak: ${updatedStreak.currentStreak})');
      return totalPoints;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to process daily login: $e');
      return null;
    }
  }

  Future<bool> unlockReward(String rewardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      final doc = await _firestore.collection('user_rewards').doc(userId).get();
      if (!doc.exists) return false;
      final inventory = UserRewardInventory.fromJson(doc.data()!);
      if (inventory.hasRewardUnlocked(rewardId)) return false;
      final updatedInventory = inventory.copyWith(
        unlockedRewardIds: [...inventory.unlockedRewardIds, rewardId],
        lastUpdated: DateTime.now(),
      );
      await _firestore.collection('user_rewards').doc(userId).update(updatedInventory.toJson());
      _inventoryController.add(updatedInventory);
      if (kDebugMode) debugPrint('Unlocked reward: $rewardId for user $userId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to unlock reward: $e');
      return false;
    }
  }

  Future<void> _checkMilestoneProgress(String userId, String type, int currentValue) async {
    try {
      final doc = await _firestore.collection('user_milestones').doc(userId).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final milestones = (data['milestones'] as List).map((m) => MilestoneReward.fromJson(m)).toList();
      bool updated = false;
      for (final milestone in milestones) {
        if (milestone.targetType == type && !milestone.isClaimed && milestone.isAchieved(currentValue)) {
          await unlockReward(milestone.reward.id);
          final updatedMilestone = milestone.copyWith(isClaimed: true, claimedAt: DateTime.now());
          final index = milestones.indexOf(milestone);
          milestones[index] = updatedMilestone;
          updated = true;
          if (kDebugMode) debugPrint('Milestone achieved: ${milestone.name}');
        }
      }
      if (updated) {
        await _firestore.collection('user_milestones').doc(userId).update({
          'milestones': milestones.map((m) => m.toJson()).toList(),
        });
        _milestonesController.add(milestones);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to check milestone progress: $e');
    }
  }

  Future<PointWallet?> getCurrentWallet() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    try {
      final doc = await _firestore.collection('point_wallets').doc(userId).get();
      if (!doc.exists) return null;
      return PointWallet.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get wallet: $e');
      return null;
    }
  }

  Future<UserRewardInventory?> getCurrentInventory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    try {
      final doc = await _firestore.collection('user_rewards').doc(userId).get();
      if (!doc.exists) return null;
      return UserRewardInventory.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get inventory: $e');
      return null;
    }
  }

  Future<UserStreak?> getCurrentStreak() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    try {
      final doc = await _firestore.collection('user_streaks').doc(userId).get();
      if (!doc.exists) return null;
      return UserStreak.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get streak: $e');
      return null;
    }
  }

  List<Reward> getAllAvailableRewards() {
    return [
      Reward(id: 'avatar_star', name: 'Yıldız Avatar', description: 'Parlayan yıldızlar ile süslenmiş özel avatar',
        icon: '⭐', type: RewardType.avatar, rarity: RewardRarity.rare, status: RewardStatus.locked,
        unlockRequirement: 5, category: 'avatar'),
      Reward(id: 'avatar_crown', name: 'Taç Avatar', description: 'Altın taçlı kraliyet avatarı',
        icon: '👑', type: RewardType.avatar, rarity: RewardRarity.legendary, status: RewardStatus.locked,
        unlockRequirement: 10, category: 'avatar'),
      Reward(id: 'theme_night', name: 'Gece Modu', description: 'Koyu renkli gece teması',
        icon: '🌙', type: RewardType.theme, rarity: RewardRarity.common, status: RewardStatus.locked,
        unlockRequirement: 3, category: 'theme'),
      Reward(id: 'theme_golden', name: 'Altın Tema', description: 'Lüks altın rengi tema',
        icon: '✨', type: RewardType.theme, rarity: RewardRarity.legendary, status: RewardStatus.locked,
        unlockRequirement: 1, category: 'theme'),
      Reward(id: 'feature_hint', name: 'İpucu Sistemi', description: 'Zor sorular için ipucu al',
        icon: '💡', type: RewardType.feature, rarity: RewardRarity.common, status: RewardStatus.locked,
        unlockRequirement: 10, category: 'feature'),
      Reward(id: 'feature_shield', name: 'Koruma Kalkanı', description: 'Yanlış cevap koruması',
        icon: '🛡️', type: RewardType.feature, rarity: RewardRarity.epic, status: RewardStatus.locked,
        unlockRequirement: 1, category: 'feature'),
    ];
  }

  List<StreakReward> getStreakRewards() => _streakRewards;

  void dispose() {
    _walletController.close();
    _inventoryController.close();
    _streakController.close();
    _milestonesController.close();
  }
}
