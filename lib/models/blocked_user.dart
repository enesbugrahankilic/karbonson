// lib/models/blocked_user.dart
// Blocked User Model - User blocking functionality

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a blocked user in the system
/// Stored in: users/{UID}/blocked_users/{blockedUserUID}
class BlockedUser {
  final String id;
  final String blockedUserId;
  final String blockedUserNickname;
  final DateTime blockedAt;
  final BlockReason reason;
  final String? customReason;
  final bool isReported;

  BlockedUser({
    required this.id,
    required this.blockedUserId,
    required this.blockedUserNickname,
    required this.blockedAt,
    this.reason = BlockReason.other,
    this.customReason,
    this.isReported = false,
  });

  factory BlockedUser.fromMap(Map<String, dynamic> map, String documentId) {
    return BlockedUser(
      id: map['blockedUserId'] ?? documentId,
      blockedUserId: map['blockedUserId'] ?? documentId,
      blockedUserNickname: map['blockedUserNickname'] ?? '',
      blockedAt: (map['blockedAt'] as Timestamp).toDate(),
      reason: BlockReason.fromString(map['reason'] ?? 'other'),
      customReason: map['customReason'],
      isReported: map['isReported'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': blockedUserId,
      'blockedUserId': blockedUserId,
      'blockedUserNickname': blockedUserNickname,
      'blockedAt': Timestamp.fromDate(blockedAt),
      'reason': reason.toString().split('.').last,
      'customReason': customReason,
      'isReported': isReported,
    };
  }

  BlockedUser copyWith({
    String? id,
    String? blockedUserId,
    String? blockedUserNickname,
    DateTime? blockedAt,
    BlockReason? reason,
    String? customReason,
    bool? isReported,
  }) {
    return BlockedUser(
      id: id ?? this.id,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      blockedUserNickname: blockedUserNickname ?? this.blockedUserNickname,
      blockedAt: blockedAt ?? this.blockedAt,
      reason: reason ?? this.reason,
      customReason: customReason ?? this.customReason,
      isReported: isReported ?? this.isReported,
    );
  }

  @override
  String toString() {
    return 'BlockedUser(id: $blockedUserId, nickname: $blockedUserNickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlockedUser && other.blockedUserId == blockedUserId;
  }

  @override
  int get hashCode => blockedUserId.hashCode;
}

enum BlockReason {
  harassment,
  spam,
  cheating,
  inappropriateBehavior,
  tooManyRequests,
  personal,
  other;

  static BlockReason fromString(String reason) {
    switch (reason.toLowerCase()) {
      case 'harassment': return BlockReason.harassment;
      case 'spam': return BlockReason.spam;
      case 'cheating': return BlockReason.cheating;
      case 'inappropriatebehavior':
      case 'inappropriate_behavior': return BlockReason.inappropriateBehavior;
      case 'toomanyrequests': 
      case 'too_many_requests': return BlockReason.tooManyRequests;
      case 'personal': return BlockReason.personal;
      default: return BlockReason.other;
    }
  }

  String get displayName {
    switch (this) {
      case BlockReason.harassment: return 'Taciz';
      case BlockReason.spam: return 'Spam';
      case BlockReason.cheating: return 'Hile';
      case BlockReason.inappropriateBehavior: return 'Uygunsuz Davranış';
      case BlockReason.tooManyRequests: return 'Çok Fazla İstek';
      case BlockReason.personal: return 'Kişisel Neden';
      case BlockReason.other: return 'Diğer';
    }
  }
}

class BlockUserResult {
  final bool success;
  final String? error;
  final BlockedUser? blockedUser;

  BlockUserResult({required this.success, this.error, this.blockedUser});

  factory BlockUserResult.success(BlockedUser user) {
    return BlockUserResult(success: true, blockedUser: user);
  }

  factory BlockUserResult.failure(String error) {
    return BlockUserResult(success: false, error: error);
  }
}

class UnblockUserResult {
  final bool success;
  final String? error;
  final String unblockedUserId;

  UnblockUserResult({required this.success, this.error, required this.unblockedUserId});

  factory UnblockUserResult.success(String userId) {
    return UnblockUserResult(success: true, unblockedUserId: userId);
  }

  factory UnblockUserResult.failure(String error) {
    return UnblockUserResult(success: false, error: error, unblockedUserId: '');
  }
}

