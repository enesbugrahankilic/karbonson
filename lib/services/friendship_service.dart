// lib/services/friendship_service.dart
// Specification: Friendship and Relationship Management (II.1-II.3)
// Simplified version using existing models to avoid conflicts

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';
import '../models/game_board.dart'; // For existing Friend, FriendRequest, and FriendRequestStatus
import 'firestore_service.dart';

class FriendshipService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Collections
  static const String _usersCollection = 'users';
  static const String _friendsCollection = 'friends';
  static const String _friendRequestsCollection = 'friend_requests';
  static const String _friendInvitationsCollection = 'friend_invitations';
  static const String _notificationsCollection = 'notifications';

  /// Get current user ID with validation (Specification I.1)
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Send a friend request with privacy validation (Specification II.3)
  Future<FriendRequestResult> sendFriendRequest(String targetUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return FriendRequestResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      if (currentUser.uid == targetUserId) {
        return FriendRequestResult(
          success: false,
          error: 'Cannot send request to yourself',
        );
      }

      // Check if request can be sent (Specification II.3)
      final canSendRequest = await _firestoreService.canSendFriendRequest(targetUserId);
      if (!canSendRequest) {
        return FriendRequestResult(
          success: false,
          error: 'Cannot send friend request to this user',
        );
      }

      // Get current user's profile for nickname
      final currentUserProfile = await _firestoreService.getUserProfile(currentUser.uid);
      if (currentUserProfile == null) {
        return FriendRequestResult(
          success: false,
          error: 'Current user profile not found',
        );
      }

      // Get target user's profile for validation and nickname
      final targetUserProfile = await _firestoreService.getUserProfile(targetUserId);
      if (targetUserProfile == null) {
        return FriendRequestResult(
          success: false,
          error: 'Target user not found',
        );
      }

      // Double-check privacy settings (Specification II.3)
      if (!targetUserProfile.privacySettings.allowFriendRequests) {
        return FriendRequestResult(
          success: false,
          error: 'User does not accept friend requests',
        );
      }

      // Check if already friends
      final isAlreadyFriend = await _areUsersFriends(currentUser.uid, targetUserId);
      if (isAlreadyFriend) {
        return FriendRequestResult(
          success: false,
          error: 'Users are already friends',
        );
      }

      // Check for existing request (prevent spam)
      final existingRequest = await _getExistingFriendRequest(currentUser.uid, targetUserId);
      if (existingRequest != null) {
        return FriendRequestResult(
          success: false,
          error: 'Friend request already sent',
          existingRequest: existingRequest,
        );
      }

      // Create friend request using existing FirestoreService
      final success = await _firestoreService.sendFriendRequest(
        currentUser.uid,
        currentUserProfile.nickname,
        targetUserId,
        targetUserProfile.nickname,
      );
      
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Friend request sent: ${currentUserProfile.nickname} -> ${targetUserProfile.nickname}');
        }

        return FriendRequestResult(
          success: true,
          message: 'Friend request sent successfully',
        );
      } else {
        return FriendRequestResult(
          success: false,
          error: 'Failed to send friend request',
        );
      }

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error sending friend request: $e');
      return FriendRequestResult(
        success: false,
        error: 'Failed to send friend request: $e',
      );
    }
  }

  /// Accept a friend request with atomic batch operation (Specification II.1-II.2)
  Future<FriendRequestActionResult> acceptFriendRequest(String requestId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return FriendRequestActionResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      // Validate request belongs to current user
      final isValidRequest = await _firestoreService.isFriendRequestValid(requestId, currentUser.uid);
      if (!isValidRequest) {
        return FriendRequestActionResult(
          success: false,
          error: 'Invalid or expired friend request',
        );
      }

      // Use the existing FirestoreService method for atomic operation
      final success = await _firestoreService.acceptFriendRequest(requestId, currentUser.uid);
      
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Friend request accepted: $requestId');
        }

        return FriendRequestActionResult(
          success: true,
          message: 'Friend request accepted successfully',
        );
      } else {
        return FriendRequestActionResult(
          success: false,
          error: 'Failed to process friend request',
        );
      }

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error accepting friend request: $e');
      return FriendRequestActionResult(
        success: false,
        error: 'Failed to accept friend request: $e',
      );
    }
  }

  /// Reject a friend request with atomic batch operation (Specification II.1-II.2)
  Future<FriendRequestActionResult> rejectFriendRequest(String requestId, {String? reason}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return FriendRequestActionResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      // Validate request belongs to current user
      final isValidRequest = await _firestoreService.isFriendRequestValid(requestId, currentUser.uid);
      if (!isValidRequest) {
        return FriendRequestActionResult(
          success: false,
          error: 'Invalid or expired friend request',
        );
      }

      // Use the existing FirestoreService method for atomic operation
      final success = await _firestoreService.rejectFriendRequest(
        requestId, 
        currentUser.uid,
        sendNotification: true,
      );
      
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Friend request rejected: $requestId');
        }

        return FriendRequestActionResult(
          success: true,
          message: 'Friend request rejected',
        );
      } else {
        return FriendRequestActionResult(
          success: false,
          error: 'Failed to process friend request',
        );
      }

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error rejecting friend request: $e');
      return FriendRequestActionResult(
        success: false,
        error: 'Failed to reject friend request: $e',
      );
    }
  }

  /// Get user's friends list
  Future<List<Friend>> getFriends() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // Get friends from FirestoreService
      final friends = await _firestoreService.getFriends(currentUser.uid);
      
      // Return friends as-is (online status will be added later with RTDB)
      return friends;

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting friends: $e');
      return [];
    }
  }

  /// Get received friend requests
  Future<List<FriendRequest>> getReceivedFriendRequests() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      return await _firestoreService.getReceivedFriendRequests(currentUser.uid);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting received requests: $e');
      return [];
    }
  }

  /// Get sent friend requests
  Future<List<FriendRequest>> getSentFriendRequests() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      return await _firestoreService.getSentFriendRequests(currentUser.uid);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting sent requests: $e');
      return [];
    }
  }

  /// Get simplified friend statistics
  Future<Map<String, int>> getFriendStatistics() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return {
        'totalFriends': 0,
        'pendingReceived': 0,
        'pendingSent': 0,
      };

      // Get all data in parallel for efficiency
      final futures = await Future.wait([
        getFriends(),
        getReceivedFriendRequests(),
        getSentFriendRequests(),
      ]);

      final friends = futures[0] as List<Friend>;
      final receivedRequests = futures[1] as List<FriendRequest>;
      final sentRequests = futures[2] as List<FriendRequest>;

      return {
        'totalFriends': friends.length,
        'pendingReceived': receivedRequests.where((req) => req.status == FriendRequestStatus.pending).length,
        'pendingSent': sentRequests.where((req) => req.status == FriendRequestStatus.pending).length,
      };

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting friend statistics: $e');
      return {
        'totalFriends': 0,
        'pendingReceived': 0,
        'pendingSent': 0,
      };
    }
  }

  /// Remove a friend relationship
  Future<bool> removeFriend(String friendId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final success = await _firestoreService.removeFriend(currentUser.uid, friendId);
      
      if (success && kDebugMode) {
        debugPrint('✅ Friend removed: $friendId');
      }

      return success;

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error removing friend: $e');
      return false;
    }
  }

  /// Check if two users are friends
  Future<bool> _areUsersFriends(String userId1, String userId2) async {
    try {
      final friends = await _firestoreService.getFriends(userId1);
      return friends.any((friend) => friend.id == userId2);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking friendship: $e');
      return false;
    }
  }

  /// Get existing friend request between two users
  Future<FriendRequest?> _getExistingFriendRequest(String fromUserId, String toUserId) async {
    try {
      // Check if there's a pending request from fromUserId to toUserId
      final querySnapshot = await FirebaseFirestore.instance
          .collection(_friendRequestsCollection)
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      
      return FriendRequest.fromMap(querySnapshot.docs.first.data());
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking existing request: $e');
      return null;
    }
  }

  /// Clean up expired friend requests (should be called periodically)
  Future<int> cleanupExpiredRequests() async {
    try {
      final expiredTime = DateTime.now().subtract(const Duration(days: 7)); // 7 days expiry
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection(_friendRequestsCollection)
          .where('status', isEqualTo: 'pending')
          .where('createdAt', isLessThan: Timestamp.fromDate(expiredTime))
          .get();

      int cleanedCount = 0;
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'respondedAt': FieldValue.serverTimestamp(),
        });
        cleanedCount++;
      }

      if (cleanedCount > 0) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint('🧹 Cleaned up $cleanedCount expired friend requests');
        }
      }

      return cleanedCount;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error cleaning up expired requests: $e');
      return 0;
    }
  }
}

/// Result class for friend request operations
class FriendRequestResult {
  final bool success;
  final String? error;
  final String? message;
  final String? requestId;
  final FriendRequest? existingRequest;

  FriendRequestResult({
    required this.success,
    this.error,
    this.message,
    this.requestId,
    this.existingRequest,
  });
}

/// Result class for friend request acceptance/rejection
class FriendRequestActionResult {
  final bool success;
  final String? error;
  final String? message;

  FriendRequestActionResult({
    required this.success,
    this.error,
    this.message,
  });
}