// lib/models/friendship_data.dart
// Specification: Friendship and Relationship Management (II.1-II.3)
// Enhanced with UID Centrality and Privacy Settings Integration

import 'package:cloud_firestore/cloud_firestore.dart';

/// Friend relationship data (Specification II.1-II.3)
/// Stored in users/{UID}/friends/{FriendUID}
class Friend {
  final String id; // Friend's UID (Specification I.1)
  final String nickname;
  final DateTime addedAt;
  final DateTime? lastSeen;
  final bool isOnline; // Will be populated from RTDB presence
  
  Friend({
    required this.id,
    required this.nickname,
    required this.addedAt,
    this.lastSeen,
    this.isOnline = false,
  });

  factory Friend.fromMap(Map<String, dynamic> map, String documentId) {
    return Friend(
      id: map['uid'] ?? documentId, // Use UID for consistency
      nickname: map['nickname'] ?? '',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      lastSeen: map['lastSeen'] != null 
          ? (map['lastSeen'] as Timestamp).toDate() 
          : null,
      isOnline: map['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id, // Always store UID for reference
      'nickname': nickname,
      'addedAt': Timestamp.fromDate(addedAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isOnline': isOnline,
    };
  }

  Friend copyWith({
    String? id,
    String? nickname,
    DateTime? addedAt,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return Friend(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      addedAt: addedAt ?? this.addedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  String toString() {
    return 'Friend(id: $id, nickname: $nickname, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Friend Request status and data (Specification II.1-II.3)
/// Stored in friend_requests collection
class FriendRequest {
  final String id;
  final String fromUserId; // Sender's UID
  final String fromNickname;
  final String toUserId; // Recipient's UID  
  final String toNickname;
  final DateTime createdAt;
  final FriendRequestStatus status;
  final DateTime? respondedAt;
  final String? responseMessage; // Optional rejection message

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromNickname,
    required this.toUserId,
    required this.toNickname,
    required this.createdAt,
    this.status = FriendRequestStatus.pending,
    this.respondedAt,
    this.responseMessage,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromNickname: map['fromNickname'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toNickname: map['toNickname'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: FriendRequestStatus.fromString(map['status'] ?? 'pending'),
      respondedAt: map['respondedAt'] != null 
          ? (map['respondedAt'] as Timestamp).toDate() 
          : null,
      responseMessage: map['responseMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromNickname': fromNickname,
      'toUserId': toUserId,
      'toNickname': toNickname,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'responseMessage': responseMessage,
    };
  }

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromNickname,
    String? toUserId,
    String? toNickname,
    DateTime? createdAt,
    FriendRequestStatus? status,
    DateTime? respondedAt,
    String? responseMessage,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromNickname: fromNickname ?? this.fromNickname,
      toUserId: toUserId ?? this.toUserId,
      toNickname: toNickname ?? this.toNickname,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }

  /// Check if request is from a specific user
  bool isFromUser(String userId) => fromUserId == userId;
  
  /// Check if request is to a specific user  
  bool isToUser(String userId) => toUserId == userId;
  
  /// Check if request is still pending
  bool get isPending => status == FriendRequestStatus.pending;
  
  /// Check if request has been responded to
  bool get hasBeenResponded => status != FriendRequestStatus.pending;
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  expired;

  static FriendRequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      case 'expired':
        return FriendRequestStatus.expired;
      default:
        return FriendRequestStatus.pending;
    }
  }
}

/// Friend statistics and relationship metadata
class FriendStatistics {
  final int totalFriends;
  final int onlineFriends;
  final int pendingRequestsReceived;
  final int pendingRequestsSent;
  final DateTime lastUpdated;

  FriendStatistics({
    required this.totalFriends,
    required this.onlineFriends,
    required this.pendingRequestsReceived,
    required this.pendingRequestsSent,
    required this.lastUpdated,
  });

  factory FriendStatistics.empty() {
    return FriendStatistics(
      totalFriends: 0,
      onlineFriends: 0,
      pendingRequestsReceived: 0,
      pendingRequestsSent: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory FriendStatistics.fromMaps({
    required List<Friend> friends,
    required List<FriendRequest> receivedRequests,
    required List<FriendRequest> sentRequests,
  }) {
    final onlineCount = friends.where((friend) => friend.isOnline).length;
    
    return FriendStatistics(
      totalFriends: friends.length,
      onlineFriends: onlineCount,
      pendingRequestsReceived: receivedRequests.where((req) => req.isPending).length,
      pendingRequestsSent: sentRequests.where((req) => req.isPending).length,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalFriends': totalFriends,
      'onlineFriends': onlineFriends,
      'pendingRequestsReceived': pendingRequestsReceived,
      'pendingRequestsSent': pendingRequestsSent,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// Friend invitation for specific activities (duels, games, etc.)
class FriendInvitation {
  final String id;
  final String inviterId;
  final String inviterNickname;
  final String inviteeId;
  final String inviteeNickname;
  final FriendInvitationType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final FriendInvitationStatus status;
  final Map<String, dynamic>? additionalData; // Game ID, room ID, etc.

  FriendInvitation({
    required this.id,
    required this.inviterId,
    required this.inviterNickname,
    required this.inviteeId,
    required this.inviteeNickname,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.status = FriendInvitationStatus.pending,
    this.additionalData,
  });

  factory FriendInvitation.fromMap(Map<String, dynamic> map) {
    return FriendInvitation(
      id: map['id'] ?? '',
      inviterId: map['inviterId'] ?? '',
      inviterNickname: map['inviterNickname'] ?? '',
      inviteeId: map['inviteeId'] ?? '',
      inviteeNickname: map['inviteeNickname'] ?? '',
      type: FriendInvitationType.fromString(map['type'] ?? 'duel'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      status: FriendInvitationStatus.fromString(map['status'] ?? 'pending'),
      additionalData: map['additionalData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inviterId': inviterId,
      'inviterNickname': inviterNickname,
      'inviteeId': inviteeId,
      'inviteeNickname': inviteeNickname,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status.toString().split('.').last,
      'additionalData': additionalData,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == FriendInvitationStatus.pending;
  bool get hasBeenResponded => status != FriendInvitationStatus.pending;
}

enum FriendInvitationType {
  duel,
  game,
  lobby;

  static FriendInvitationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'duel':
        return FriendInvitationType.duel;
      case 'game':
        return FriendInvitationType.game;
      case 'lobby':
        return FriendInvitationType.lobby;
      default:
        return FriendInvitationType.duel;
    }
  }
}

enum FriendInvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled;

  static FriendInvitationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FriendInvitationStatus.pending;
      case 'accepted':
        return FriendInvitationStatus.accepted;
      case 'declined':
        return FriendInvitationStatus.declined;
      case 'expired':
        return FriendInvitationStatus.expired;
      case 'cancelled':
        return FriendInvitationStatus.cancelled;
      default:
        return FriendInvitationStatus.pending;
    }
  }
}