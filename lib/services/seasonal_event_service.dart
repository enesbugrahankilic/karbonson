// lib/services/seasonal_event_service.dart
// Service for managing seasonal events and special challenges

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/seasonal_event.dart';

/// Service for managing seasonal events
class SeasonalEventService {
  static final SeasonalEventService _instance = SeasonalEventService._internal();
  factory SeasonalEventService() => _instance;
  SeasonalEventService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers
  final StreamController<List<SeasonalEvent>> _eventsController =
      StreamController.broadcast();
  final StreamController<UserSeasonalParticipation> _participationController =
      StreamController.broadcast();

  // Getters for streams
  Stream<List<SeasonalEvent>> get eventsStream => _eventsController.stream;
  Stream<UserSeasonalParticipation> get participationStream =>
      _participationController.stream;

  // Predefined seasonal events
  final List<SeasonalEvent> _predefinedEvents = [
    SeasonalEvent(
      id: 'new_year_celebration',
      title: 'Yeni Yıl Kutlaması',
      description: '2026\'yı coşkuyla karşıla! Özel ödüller seni bekliyor.',
      icon: '🎉',
      type: SeasonalEventType.celebration,
      startDate: DateTime(2025, 12, 28),
      endDate: DateTime(2026, 1, 5),
      status: SeasonalEventStatus.upcoming,
      challengeIds: ['new_year_quiz', 'new_year_duel', 'new_year_social'],
      rewards: {
        'completion_reward': 'special_new_year_avatar',
        'bonus_points': 500,
      },
      themeColor: '#FFD700',
      bannerImage: 'assets/events/new_year_banner.png',
    ),
    SeasonalEvent(
      id: 'spring_festival',
      title: 'Bahar Festivali',
      description: 'Bahar geldi, yeni zorluklar seni bekliyor!',
      icon: '🌸',
      type: SeasonalEventType.holiday,
      startDate: DateTime(2026, 3, 20),
      endDate: DateTime(2026, 4, 5),
      status: SeasonalEventStatus.upcoming,
      challengeIds: ['spring_quiz', 'spring_duel', 'spring_social'],
      rewards: {
        'completion_reward': 'spring_theme',
        'bonus_points': 300,
      },
      themeColor: '#FF69B4',
      bannerImage: 'assets/events/spring_banner.png',
    ),
    SeasonalEvent(
      id: 'summer_competition',
      title: 'Yaz Yarışması',
      description: 'En sıcak yarışmada en iyi oyuncu sen ol!',
      icon: '☀️',
      type: SeasonalEventType.competition,
      startDate: DateTime(2026, 6, 15),
      endDate: DateTime(2026, 7, 15),
      status: SeasonalEventStatus.upcoming,
      challengeIds: ['summer_quiz', 'summer_duel', 'summer_streak'],
      rewards: {
        'first_place': 'legendary_summer_avatar',
        'completion_reward': 'summer_theme',
        'bonus_points': 1000,
      },
      themeColor: '#FFA500',
      bannerImage: 'assets/events/summer_banner.png',
    ),
  ];

  /// Initialize service for current user
  Future<void> initializeForUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _loadActiveEvents();
      await _loadUserParticipation(userId);
      if (kDebugMode) {
        debugPrint('SeasonalEventService initialized for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize SeasonalEventService: $e');
    }
  }

  /// Load active seasonal events
  Future<void> _loadActiveEvents() async {
    try {
      final now = DateTime.now();
      final activeEvents = _predefinedEvents.where((event) {
        return event.startDate.isBefore(now) && event.endDate.isAfter(now);
      }).toList();

      // Update status to active for current events
      final updatedEvents = activeEvents.map((event) {
        if (event.status != SeasonalEventStatus.active) {
          return event.copyWith(status: SeasonalEventStatus.active);
        }
        return event;
      }).toList();

      _eventsController.add(updatedEvents);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load active events: $e');
    }
  }

  /// Load user participation data
  Future<void> _loadUserParticipation(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_seasonal_participation')
          .doc(userId)
          .get();

      if (doc.exists) {
        final participation = UserSeasonalParticipation.fromJson(doc.data()!);
        _participationController.add(participation);
      } else {
        // Create initial participation record
        final initialParticipation = UserSeasonalParticipation(
          userId: userId,
          eventId: '', // Will be set when joining an event
          pointsEarned: 0,
          challengesCompleted: 0,
          rewardsClaimed: [],
          joinedAt: DateTime.now(),
        );

        await _firestore
            .collection('user_seasonal_participation')
            .doc(userId)
            .set(initialParticipation.toJson());

        _participationController.add(initialParticipation);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load user participation: $e');
    }
  }

  /// Get all seasonal events
  List<SeasonalEvent> getAllEvents() => _predefinedEvents;

  /// Get active events
  List<SeasonalEvent> getActiveEvents() {
    final now = DateTime.now();
    return _predefinedEvents.where((event) => event.isActive).toList();
  }

  /// Get upcoming events
  List<SeasonalEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return _predefinedEvents.where((event) =>
        event.startDate.isAfter(now) &&
        event.status == SeasonalEventStatus.upcoming).toList();
  }

  /// Join a seasonal event
  Future<bool> joinEvent(String eventId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final event = _predefinedEvents.firstWhere((e) => e.id == eventId);

      final participation = UserSeasonalParticipation(
        userId: userId,
        eventId: eventId,
        pointsEarned: 0,
        challengesCompleted: 0,
        rewardsClaimed: [],
        joinedAt: DateTime.now(),
        lastActivity: DateTime.now(),
      );

      await _firestore
          .collection('user_seasonal_participation')
          .doc(userId)
          .set(participation.toJson());

      _participationController.add(participation);

      if (kDebugMode) {
        debugPrint('User $userId joined event: $eventId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to join event: $e');
      return false;
    }
  }

  /// Update user progress in seasonal event
  Future<bool> updateEventProgress(String eventId, {
    int? pointsEarned,
    int? challengesCompleted,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final docRef = _firestore
          .collection('user_seasonal_participation')
          .doc(userId);

      final doc = await docRef.get();
      if (!doc.exists) return false;

      final currentParticipation = UserSeasonalParticipation.fromJson(doc.data()!);

      final updatedParticipation = currentParticipation.copyWith(
        pointsEarned: pointsEarned != null
            ? currentParticipation.pointsEarned + pointsEarned
            : currentParticipation.pointsEarned,
        challengesCompleted: challengesCompleted != null
            ? currentParticipation.challengesCompleted + challengesCompleted
            : currentParticipation.challengesCompleted,
        lastActivity: DateTime.now(),
      );

      await docRef.update(updatedParticipation.toJson());
      _participationController.add(updatedParticipation);

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to update event progress: $e');
      return false;
    }
  }

  /// Claim reward from seasonal event
  Future<bool> claimEventReward(String eventId, String rewardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final docRef = _firestore
          .collection('user_seasonal_participation')
          .doc(userId);

      final doc = await docRef.get();
      if (!doc.exists) return false;

      final participation = UserSeasonalParticipation.fromJson(doc.data()!);

      if (participation.rewardsClaimed.contains(rewardId)) {
        return false; // Already claimed
      }

      final updatedRewards = [...participation.rewardsClaimed, rewardId];
      final updatedParticipation = participation.copyWith(
        rewardsClaimed: updatedRewards,
      );

      await docRef.update(updatedParticipation.toJson());
      _participationController.add(updatedParticipation);

      if (kDebugMode) {
        debugPrint('User $userId claimed reward: $rewardId from event: $eventId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to claim event reward: $e');
      return false;
    }
  }

  /// Get event leaderboard (simplified version)
  Future<List<Map<String, dynamic>>> getEventLeaderboard(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('user_seasonal_participation')
          .where('eventId', isEqualTo: eventId)
          .orderBy('pointsEarned', descending: true)
          .limit(10)
          .get();

      final leaderboard = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final participation = UserSeasonalParticipation.fromJson(doc.data());

        // Get user display name (simplified)
        final userDoc = await _firestore
            .collection('users')
            .doc(participation.userId)
            .get();

        final displayName = userDoc.exists
            ? (userDoc.data()?['nickname'] ?? 'Anonim')
            : 'Anonim';

        leaderboard.add({
          'userId': participation.userId,
          'displayName': displayName,
          'points': participation.pointsEarned,
          'challengesCompleted': participation.challengesCompleted,
        });
      }

      return leaderboard;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to get event leaderboard: $e');
      return [];
    }
  }

  /// Check if user can claim reward
  Future<bool> canClaimReward(String eventId, String rewardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('user_seasonal_participation')
          .doc(userId)
          .get();

      if (!doc.exists) return false;

      final participation = UserSeasonalParticipation.fromJson(doc.data()!);

      // Check if already claimed
      if (participation.rewardsClaimed.contains(rewardId)) {
        return false;
      }

      final event = _predefinedEvents.firstWhere((e) => e.id == eventId);

      // Check completion requirements based on reward type
      switch (rewardId) {
        case 'completion_reward':
          return participation.challengesCompleted >= event.challengeIds.length;
        case 'bonus_points':
          return participation.pointsEarned >= 100; // Minimum points
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _eventsController.close();
    _participationController.close();
  }
}