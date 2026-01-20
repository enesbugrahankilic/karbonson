
// lib/services/friend_suggestion_service.dart
// Friend Suggestion Service - AI-based and criteria-based friend recommendations
// Specification: Friend Recommendation System (II.4)

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_suggestion.dart';
import 'firestore_service.dart';

class FriendSuggestionService {
  static final FriendSuggestionService _instance =
      FriendSuggestionService._internal();
  factory FriendSuggestionService() => _instance;
  FriendSuggestionService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Collections
  static const String _usersCollection = 'users';
  static const String _friendsCollection = 'friends';
  static const String _gamesCollection = 'games';
  static const String _friendRequestsCollection = 'friend_requests';

  // Suggestion limits
  static const int _maxSuggestionsPerCategory = 10;
  static const int _maxTotalSuggestions = 30;

  /// Get all registered users (for fallback)
  Future<List<Map<String, dynamic>>> _getAllUsers(String excludeUserId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != excludeUserId)
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting all users: $e');
      return [];
    }
  }

  /// Get existing friend IDs
  Future<Set<String>> _getExistingFriendIds(String userId) async {
    try {
      final friends = await _firestoreService.getFriends(userId);
      return friends.map((f) => f.id).toSet();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting friend IDs: $e');
      return {};
    }
  }

  /// Get blocked user IDs
  Future<Set<String>> _getBlockedUserIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('blocked_users')
          .doc(userId)
          .collection('blocked')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting blocked users: $e');
      return {};
    }
  }

  /// Get user IDs with pending friend requests
  Future<Set<String>> _getPendingRequestUserIds(String userId) async {
    try {
      final receivedRequests =
          await _firestoreService.getReceivedFriendRequests(userId);
      final sentRequests =
          await _firestoreService.getSentFriendRequests(userId);

      final receivedIds = receivedRequests.map((r) => r.fromUserId).toSet();
      final sentIds = sentRequests.map((r) => r.toUserId).toSet();

      return {...receivedIds, ...sentIds};
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting pending requests: $e');
      return {};
    }
  }

  /// Filter and score suggestions
  List<FriendSuggestion> _filterAndScoreSuggestions(
    List<FriendSuggestion> suggestions,
    Set<String> existingFriendIds,
    Set<String> blockedUserIds, {
    Set<String> pendingRequestUserIds = const {},
  }) {
    return suggestions
        .where((s) => !existingFriendIds.contains(s.userId))
        .where((s) => !blockedUserIds.contains(s.userId))
        .where((s) => !pendingRequestUserIds.contains(s.userId))
        .take(_maxSuggestionsPerCategory)
        .toList();
  }

  /// Get comprehensive friend suggestions based on multiple criteria
  Future<List<FriendSuggestion>> getSuggestions({
    int limit = _maxTotalSuggestions,
    List<SuggestionReason> includedReasons = const [
      SuggestionReason.commonFriends,
      SuggestionReason.recentlyPlayed,
      SuggestionReason.leaderboard,
      SuggestionReason.popular,
    ],
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) debugPrint('❌ User not authenticated');
        return [];
      }

      final userId = currentUser.uid;
      final List<FriendSuggestion> allSuggestions = [];

      // Get all data in parallel
      final results = await Future.wait([
        _getCommonFriendsSuggestions(userId),
        _getRecentlyPlayedSuggestions(userId),
        _getLeaderboardSuggestions(userId),
        _getPopularPlayersSuggestions(userId),
        _getExistingFriendIds(userId),
        _getBlockedUserIds(userId),
        _getPendingRequestUserIds(userId),
      ]);

      final commonFriendsSuggestions = results[0] as List<FriendSuggestion>;
      final recentlyPlayedSuggestions = results[1] as List<FriendSuggestion>;
      final leaderboardSuggestions = results[2] as List<FriendSuggestion>;
      final popularSuggestions = results[3] as List<FriendSuggestion>;
      final existingFriendIds = results[4] as Set<String>;
      final blockedUserIds = results[5] as Set<String>;
      final pendingRequestUserIds = results[6] as Set<String>;

      // Filter and add suggestions based on included reasons
      if (includedReasons.contains(SuggestionReason.commonFriends)) {
        allSuggestions.addAll(_filterAndScoreSuggestions(
            commonFriendsSuggestions, existingFriendIds, blockedUserIds,
            pendingRequestUserIds: pendingRequestUserIds));
      }

      if (includedReasons.contains(SuggestionReason.recentlyPlayed)) {
        allSuggestions.addAll(_filterAndScoreSuggestions(
            recentlyPlayedSuggestions, existingFriendIds, blockedUserIds,
            pendingRequestUserIds: pendingRequestUserIds));
      }

      if (includedReasons.contains(SuggestionReason.leaderboard)) {
        allSuggestions.addAll(_filterAndScoreSuggestions(
            leaderboardSuggestions, existingFriendIds, blockedUserIds,
            pendingRequestUserIds: pendingRequestUserIds));
      }

      if (includedReasons.contains(SuggestionReason.popular)) {
        allSuggestions.addAll(_filterAndScoreSuggestions(
            popularSuggestions, existingFriendIds, blockedUserIds,
            pendingRequestUserIds: pendingRequestUserIds));
      }

      // Sort by score and limit
      allSuggestions.sort((a, b) => b.score.compareTo(a.score));
      final filteredSuggestions = allSuggestions
          .where((s) => !existingFriendIds.contains(s.userId))
          .where((s) => !blockedUserIds.contains(s.userId))
          .where((s) => !pendingRequestUserIds.contains(s.userId))
          .take(limit)
          .toList();

      if (kDebugMode) {
        debugPrint(
            '✅ Generated ${filteredSuggestions.length} friend suggestions');
      }

      return filteredSuggestions;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting friend suggestions: $e');
      return [];
    }
  }

  /// Get suggestions based on common friends
  Future<List<FriendSuggestion>> _getCommonFriendsSuggestions(
      String userId) async {
    try {
      // Get user's friends
      final friends = await _firestoreService.getFriends(userId);
      if (friends.isEmpty) return [];

      final friendIds = friends.map((f) => f.id).toList();
      final Map<String, int> commonFriendsCount = {};

      // For each friend, get their friends and count common connections
      for (final friendId in friendIds) {
        final friendFriends =
            await _firestoreService.getFriends(friendId);
        for (final ff in friendFriends) {
          if (ff.id != userId && !friendIds.contains(ff.id)) {
            commonFriendsCount[ff.id] =
                (commonFriendsCount[ff.id] ?? 0) + 1;
          }
        }
      }

      // Get user profiles for those with common friends
      final List<FriendSuggestion> suggestions = [];
      final sortedEntries = commonFriendsCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedEntries.take(_maxSuggestionsPerCategory)) {
        final profile = await _getUserProfile(entry.key);
        if (profile != null) {
          suggestions.add(FriendSuggestion(
            userId: entry.key,
            nickname: profile.nickname,
            profilePictureUrl: profile.profilePictureUrl,
            reason: SuggestionReason.commonFriends,
            score: entry.value * 10, // Score based on common friends count
            commonFriendsCount: entry.value,
            lastActive: profile.lastActive,
          ));
        }
      }

      return suggestions;
    } catch (e) {
      if (kDebugMode)
        debugPrint('🚨 Error getting common friends suggestions: $e');
      return [];
    }
  }

  /// Get suggestions based on recently played together
  Future<List<FriendSuggestion>> _getRecentlyPlayedSuggestions(
      String userId) async {
    try {
      // Query games collection for recent games played with others
      final thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30));

      final gamesQuery = await _firestore
          .collection(_gamesCollection)
          .where('participants', arrayContains: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final Map<String, DateTime> lastPlayedWith = {};
      final Map<String, int> gamesPlayedWith = {};

      for (final gameDoc in gamesQuery.docs) {
        final data = gameDoc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final createdAt = (data['createdAt'] as Timestamp).toDate();

        for (final participantId in participants) {
          if (participantId != userId) {
            lastPlayedWith[participantId] = createdAt;
            gamesPlayedWith[participantId] =
                (gamesPlayedWith[participantId] ?? 0) + 1;
          }
        }
      }

      final List<FriendSuggestion> suggestions = [];
      final sortedEntries = gamesPlayedWith.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedEntries.take(_maxSuggestionsPerCategory)) {
        final profile = await _getUserProfile(entry.key);
        if (profile != null) {
          suggestions.add(FriendSuggestion(
            userId: entry.key,
            nickname: profile.nickname,
            profilePictureUrl: profile.profilePictureUrl,
            reason: SuggestionReason.recentlyPlayed,
            score: entry.value * 5, // Score based on games played together
            totalGamesPlayed: entry.value,
            lastPlayedTogether: lastPlayedWith[entry.key],
            lastActive: profile.lastActive,
          ));
        }
      }

      return suggestions;
    } catch (e) {
      if (kDebugMode)
        debugPrint('🚨 Error getting recently played suggestions: $e');
      return [];
    }
  }

  /// Get suggestions based on leaderboard proximity
  Future<List<FriendSuggestion>> _getLeaderboardSuggestions(
      String userId) async {
    try {
      // Get current user's score/rank
      final userProfile = await _getUserProfile(userId);
      if (userProfile == null) return [];

      final userScore = userProfile.totalPoints;

      // Get nearby players by score
      final minScore = (userScore * 0.5).toInt();
      final maxScore = (userScore * 1.5).toInt();

      QuerySnapshot<Map<String, dynamic>> nearbyPlayers;
      
      if (userScore > 0) {
        nearbyPlayers = await _firestore
            .collection(_usersCollection)
            .where('totalPoints', isGreaterThan: minScore, isLessThan: maxScore)
            .orderBy('totalPoints')
            .limit(_maxSuggestionsPerCategory * 2)
            .get();
      } else {
        // For users with 0 points, just get recent users
        nearbyPlayers = await _firestore
            .collection(_usersCollection)
            .orderBy('createdAt', descending: true)
            .limit(_maxSuggestionsPerCategory * 2)
            .get();
      }

      final List<FriendSuggestion> suggestions = [];

      for (final doc in nearbyPlayers.docs) {
        final playerId = doc.id;
        if (playerId == userId) continue;

        final data = doc.data();
        final playerScore = (data['totalPoints'] ?? 0).toInt();
        final int scoreDifference = (userScore - playerScore).abs().toInt();

        suggestions.add(FriendSuggestion(
          userId: playerId,
          nickname: data['nickname'] ?? 'Unknown',
          profilePictureUrl: data['profilePictureUrl'],
          reason: SuggestionReason.leaderboard,
          score: 100 - (scoreDifference > 1000 ? 1000 : scoreDifference),
          lastActive: data['lastActive'] != null
              ? (data['lastActive'] as Timestamp).toDate()
              : null,
        ));
      }

      // Sort by score proximity
      suggestions.sort((a, b) => b.score.compareTo(a.score));

      return suggestions.take(_maxSuggestionsPerCategory).toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('🚨 Error getting leaderboard suggestions: $e');
      return [];
    }
  }

  /// Get suggestions based on popular players
  Future<List<FriendSuggestion>> _getPopularPlayersSuggestions(
      String userId) async {
    try {
      // Get players with most friends/wins
      final popularPlayers = await _firestore
          .collection(_usersCollection)
          .orderBy('friendsCount', descending: true)
          .orderBy('totalWins', descending: true)
          .limit(_maxSuggestionsPerCategory * 2)
          .get();

      final List<FriendSuggestion> suggestions = [];

      for (final doc in popularPlayers.docs) {
        if (doc.id == userId) continue;

        final data = doc.data();
        final friendsCount = data['friendsCount'] ?? 0;
        final totalWins = data['totalWins'] ?? 0;

        suggestions.add(FriendSuggestion(
          userId: doc.id,
          nickname: data['nickname'] ?? 'Unknown',
          profilePictureUrl: data['profilePictureUrl'],
          reason: SuggestionReason.popular,
          score: (friendsCount * 2) + (totalWins * 3),
          lastActive: data['lastActive'] != null
              ? (data['lastActive'] as Timestamp).toDate()
              : null,
        ));
      }

      return suggestions.take(_maxSuggestionsPerCategory).toList();
    } catch (e) {
      if (kDebugMode)
        debugPrint('🚨 Error getting popular players suggestions: $e');
      return [];
    }
  }

  /// Get user profile data from Firestore
  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserProfile(
        uid: doc.id,
        nickname: data['nickname'] ?? '',
        profilePictureUrl: data['profilePictureUrl'],
        totalPoints: (data['totalPoints'] ?? 0).toInt(),
        lastActive: data['lastActive'] != null
            ? (data['lastActive'] as Timestamp).toDate()
            : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user profile: $e');
      return null;
    }
  }

  /// Send friend request from suggestion
  Future<bool> sendRequestFromSuggestion(FriendSuggestion suggestion) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final profile = await _getUserProfile(currentUser.uid);
      if (profile == null) return false;

      final success = await _firestoreService.sendFriendRequest(
        currentUser.uid,
        profile.nickname,
        suggestion.userId,
        suggestion.nickname,
      );

      if (success && kDebugMode) {
        debugPrint(
            '✅ Friend request sent from suggestion: ${suggestion.nickname}');
      }

      return success;
    } catch (e) {
      if (kDebugMode)
        debugPrint('🚨 Error sending request from suggestion: $e');
      return false;
    }
  }

  /// Get grouped suggestions by reason
  Future<Map<SuggestionReason, List<FriendSuggestion>>>
      getGroupedSuggestions() async {
    final suggestions = await getSuggestions();
    final grouped = <SuggestionReason, List<FriendSuggestion>>{};

    for (final suggestion in suggestions) {
      grouped
          .putIfAbsent(suggestion.reason, () => [])
          .add(suggestion);
    }

    return grouped;
  }

  /// Dismiss a suggestion (to prevent showing again)
  Future<void> dismissSuggestion(String suggestedUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Store dismissed suggestion in local preferences or Firestore
      await _firestore
          .collection('dismissed_suggestions')
          .doc(currentUser.uid)
          .collection('users')
          .doc(suggestedUserId)
          .set({
        'dismissedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Suggestion dismissed: $suggestedUserId');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error dismissing suggestion: $e');
    }
  }

  /// Get dismissed suggestion IDs
  Future<Set<String>> getDismissedSuggestionIds() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return {};

      final snapshot = await _firestore
          .collection('dismissed_suggestions')
          .doc(currentUser.uid)
          .collection('users')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      if (kDebugMode)
          debugPrint('🚨 Error getting dismissed suggestions: $e');
      return {};
    }
  }
}

/// User profile data class
class UserProfile {
  final String uid;
  final String nickname;
  final String? profilePictureUrl;
  final int totalPoints;
  final DateTime? lastActive;

  UserProfile({
    required this.uid,
    required this.nickname,
    this.profilePictureUrl,
    this.totalPoints = 0,
    this.lastActive,
  });
}

