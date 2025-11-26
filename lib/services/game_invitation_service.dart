// lib/services/game_invitation_service.dart
// Game invitation service for multiplayer functionality

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_board.dart';

class GameInvitationService {
  static const String _gameInvitationsCollection = 'game_invitations';
  static const String _roomsCollection = 'game_rooms';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Invite a friend to join a game room
  Future<GameInvitationResult> inviteFriendToGame({
    required String roomId,
    required String friendId,
    required String friendNickname,
    required String inviterNickname,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return GameInvitationResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      // Verify room exists and is joinable
      final roomDoc = await _firestore.collection(_roomsCollection).doc(roomId).get();
      if (!roomDoc.exists) {
        return GameInvitationResult(
          success: false,
          error: 'Game room not found',
        );
      }

      final roomData = roomDoc.data()!;
      final players = (roomData['players'] as List<dynamic>? ?? []);
      
      // Check if room is full
      if (players.length >= 4) {
        return GameInvitationResult(
          success: false,
          error: 'Game room is full',
        );
      }

      // Check if room is still waiting for players
      final roomStatus = roomData['status'] as String;
      if (roomStatus != 'waiting') {
        return GameInvitationResult(
          success: false,
          error: 'Game has already started',
        );
      }

      // Create game invitation
      final invitationId = _firestore.collection(_gameInvitationsCollection).doc().id;
      
      final invitation = GameInvitation(
        id: invitationId,
        fromUserId: currentUser.uid,
        fromNickname: inviterNickname,
        toUserId: friendId,
        roomId: roomId,
        roomHostNickname: roomData['hostNickname'] as String,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(_gameInvitationsCollection).doc(invitationId).set({
        'id': invitation.id,
        'fromUserId': invitation.fromUserId,
        'fromNickname': invitation.fromNickname,
        'toUserId': invitation.toUserId,
        'roomId': invitation.roomId,
        'roomHostNickname': invitation.roomHostNickname,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (kDebugMode) {
        debugPrint('✅ Game invitation sent: ${inviterNickname} -> ${friendNickname} for room $roomId');
      }

      return GameInvitationResult(
        success: true,
        message: 'Invitation sent to $friendNickname',
      );

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error inviting friend to game: $e');
      return GameInvitationResult(
        success: false,
        error: 'Failed to send invitation: $e',
      );
    }
  }

  /// Accept a game invitation
  Future<GameInvitationActionResult> acceptInvitation(String invitationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return GameInvitationActionResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      // Get invitation details
      final invitationDoc = await _firestore.collection(_gameInvitationsCollection).doc(invitationId).get();
      if (!invitationDoc.exists) {
        return GameInvitationActionResult(
          success: false,
          error: 'Invitation not found',
        );
      }

      final invitationData = invitationDoc.data()!;
      if (invitationData['toUserId'] != currentUser.uid) {
        return GameInvitationActionResult(
          success: false,
          error: 'Unauthorized',
        );
      }

      if (invitationData['status'] != 'pending') {
        return GameInvitationActionResult(
          success: false,
          error: 'Invitation is no longer valid',
        );
      }

      final roomId = invitationData['roomId'] as String;

      // Get room details to create player
      final roomDoc = await _firestore.collection(_roomsCollection).doc(roomId).get();
      if (!roomDoc.exists) {
        return GameInvitationActionResult(
          success: false,
          error: 'Game room no longer exists',
        );
      }

      final roomData = roomDoc.data()!;
      final players = (roomData['players'] as List<dynamic>? ?? []);
      
      // Check if room is still joinable
      if (players.length >= 4) {
        // Update invitation status to expired
        await _firestore.collection(_gameInvitationsCollection).doc(invitationId).update({
          'status': 'expired',
          'respondedAt': FieldValue.serverTimestamp(),
        });
        
        return GameInvitationActionResult(
          success: false,
          error: 'Game room is now full',
        );
      }

      // Get current user profile for nickname
      final userProfileDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      String userNickname = 'Unknown Player';
      if (userProfileDoc.exists) {
        final profileData = userProfileDoc.data()!;
        userNickname = profileData['nickname'] as String? ?? 'Unknown Player';
      }

      // Create player object
      final newPlayer = MultiplayerPlayer(
        id: currentUser.uid,
        nickname: userNickname,
        isReady: false,
      );

      // Add player to room
      players.add(newPlayer.toMap());
      await _firestore.collection(_roomsCollection).doc(roomId).update({
        'players': players,
      });

      // Update invitation status to accepted
      await _firestore.collection(_gameInvitationsCollection).doc(invitationId).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Game invitation accepted: $invitationId, joined room $roomId');
      }

      return GameInvitationActionResult(
        success: true,
        message: 'Successfully joined the game!',
        roomId: roomId,
      );

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error accepting invitation: $e');
      return GameInvitationActionResult(
        success: false,
        error: 'Failed to accept invitation: $e',
      );
    }
  }

  /// Decline a game invitation
  Future<GameInvitationActionResult> declineInvitation(String invitationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return GameInvitationActionResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      // Get invitation details
      final invitationDoc = await _firestore.collection(_gameInvitationsCollection).doc(invitationId).get();
      if (!invitationDoc.exists) {
        return GameInvitationActionResult(
          success: false,
          error: 'Invitation not found',
        );
      }

      final invitationData = invitationDoc.data()!;
      if (invitationData['toUserId'] != currentUser.uid) {
        return GameInvitationActionResult(
          success: false,
          error: 'Unauthorized',
        );
      }

      // Update invitation status to declined
      await _firestore.collection(_gameInvitationsCollection).doc(invitationId).update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Game invitation declined: $invitationId');
      }

      return GameInvitationActionResult(
        success: true,
        message: 'Invitation declined',
      );

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error declining invitation: $e');
      return GameInvitationActionResult(
        success: false,
        error: 'Failed to decline invitation: $e',
      );
    }
  }

  /// Get received game invitations for current user
  Future<List<GameInvitation>> getReceivedInvitations() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final querySnapshot = await _firestore
          .collection(_gameInvitationsCollection)
          .where('toUserId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return GameInvitation.fromMap(data);
      }).toList();

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting invitations: $e');
      return [];
    }
  }

  /// Listen to new game invitations in real-time
  Stream<List<GameInvitation>> listenToInvitations() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_gameInvitationsCollection)
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GameInvitation.fromMap(data);
      }).toList();
    });
  }
}

/// Game invitation model
class GameInvitation {
  final String id;
  final String fromUserId;
  final String fromNickname;
  final String toUserId;
  final String roomId;
  final String roomHostNickname;
  final DateTime createdAt;
  String status; // 'pending', 'accepted', 'declined', 'expired'
  DateTime? respondedAt;

  GameInvitation({
    required this.id,
    required this.fromUserId,
    required this.fromNickname,
    required this.toUserId,
    required this.roomId,
    required this.roomHostNickname,
    required this.createdAt,
    this.status = 'pending',
    this.respondedAt,
  });

  factory GameInvitation.fromMap(Map<String, dynamic> map) {
    return GameInvitation(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromNickname: map['fromNickname'] ?? '',
      toUserId: map['toUserId'] ?? '',
      roomId: map['roomId'] ?? '',
      roomHostNickname: map['roomHostNickname'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      respondedAt: map['respondedAt'] != null 
          ? (map['respondedAt'] as Timestamp).toDate() 
          : null,
    );
  }
}

/// Result classes for game invitation operations
class GameInvitationResult {
  final bool success;
  final String? error;
  final String? message;

  GameInvitationResult({
    required this.success,
    this.error,
    this.message,
  });
}

class GameInvitationActionResult {
  final bool success;
  final String? error;
  final String? message;
  final String? roomId;

  GameInvitationActionResult({
    required this.success,
    this.error,
    this.message,
    this.roomId,
  });
}