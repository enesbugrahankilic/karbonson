// lib/services/presence_service.dart
// Specification III.4: Online Status (Presence) using Firestore
// Real-time presence tracking for friends and users (RTDB alternative)

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _presenceSubscription;
  bool _isInitialized = false;
  Timer? _presenceUpdateTimer;

  // Presence status constants
  static const String _presenceCollection = 'user_presence';
  static const int _offlineTimeout = 300000; // 5 minutes timeout
  static const String _onlineStatus = 'online';
  static const String _offlineStatus = 'offline';
  static const String _awayStatus = 'away';

  /// Initialize presence service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode)
          debugPrint('⚠️ Cannot initialize presence - user not authenticated');
        return;
      }

      _isInitialized = true;
      _setupPresenceTracking(user.uid);

      if (kDebugMode) {
        debugPrint('✅ Presence service initialized for user: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error initializing presence service: $e');
    }
  }

  /// Set up presence tracking for a user
  void _setupPresenceTracking(String userId) {
    // Set user as online immediately
    _updateUserPresence(userId, _onlineStatus);

    // Set up periodic presence updates
    _presenceUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateUserPresence(userId, _onlineStatus);
    });

    // Set user as offline when app closes
    // This would typically be handled by app lifecycle observers
  }

  /// Update user's presence status
  void _updateUserPresence(String userId, String status) async {
    try {
      final presenceData = {
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'deviceInfo': {
          'platform':
              'mobile', // Could be enhanced with actual platform detection
          'appVersion': '1.0.0', // Could be enhanced with actual app version
        },
      };

      await _firestore.collection(_presenceCollection).doc(userId).set(
            presenceData,
            SetOptions(merge: true),
          );

      if (kDebugMode) {
        debugPrint('👤 Presence updated for $userId: $status');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating presence: $e');
    }
  }

  /// Set user as online
  void setUserOnline() {
    final user = _auth.currentUser;
    if (user != null) {
      _updateUserPresence(user.uid, _onlineStatus);
    }
  }

  /// Set user as offline
  void setUserOffline() {
    final user = _auth.currentUser;
    if (user != null) {
      _updateUserPresence(user.uid, _offlineStatus);
    }
  }

  /// Get user's current presence status
  Future<PresenceStatus?> getUserPresence(String userId) async {
    try {
      final doc =
          await _firestore.collection(_presenceCollection).doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        data['lastUpdated'] =
            (data['lastUpdated'] as Timestamp).millisecondsSinceEpoch;
        data['lastSeen'] =
            (data['lastSeen'] as Timestamp).millisecondsSinceEpoch;
        return PresenceStatus.fromMap(data);
      }

      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user presence: $e');
      return null;
    }
  }

  /// Listen to multiple users' presence status
  Stream<Map<String, PresenceStatus>> listenToFriendsPresence(
      List<String> friendIds) {
    final controller = StreamController<Map<String, PresenceStatus>>();

    if (friendIds.isEmpty) {
      controller.add({});
      return controller.stream;
    }

    try {
      final query = _firestore
          .collection(_presenceCollection)
          .where(FieldPath.documentId, whereIn: friendIds)
          .limit(friendIds.length);

      _presenceSubscription = query.snapshots().listen((snapshot) {
        final Map<String, PresenceStatus> presenceMap = {};

        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['lastUpdated'] =
              (data['lastUpdated'] as Timestamp).millisecondsSinceEpoch;
          data['lastSeen'] =
              (data['lastSeen'] as Timestamp).millisecondsSinceEpoch;
          presenceMap[doc.id] = PresenceStatus.fromMap(data);
        }

        controller.add(presenceMap);
      });
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error listening to friends presence: $e');
      controller.addError(e);
    }

    return controller.stream;
  }

  /// Check if a user is currently online
  Future<bool> isUserOnline(String userId) async {
    final presence = await getUserPresence(userId);
    if (presence == null) return false;

    // Check if status is online and last update was recent
    final now = DateTime.now().millisecondsSinceEpoch;
    final isRecent = presence.lastUpdated != null &&
        (now - presence.lastUpdated!) < _offlineTimeout;

    return presence.status == _onlineStatus && isRecent;
  }

  /// Get online friends count
  Future<int> getOnlineFriendsCount(List<String> friendIds) async {
    try {
      final presenceMap = await listenToFriendsPresence(friendIds).first;
      final now = DateTime.now().millisecondsSinceEpoch;

      return presenceMap.values.where((status) {
        final isRecent = status.lastUpdated != null &&
            (now - status.lastUpdated!) < _offlineTimeout;
        return status.status == _onlineStatus && isRecent;
      }).length;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting online friends count: $e');
      return 0;
    }
  }

  /// Clean up presence data for offline users
  Future<void> cleanupOfflinePresence() async {
    try {
      final cutoffTime =
          DateTime.now().millisecondsSinceEpoch - _offlineTimeout;

      final snapshot = await _firestore
          .collection(_presenceCollection)
          .where('status', isEqualTo: _onlineStatus)
          .where('lastUpdated',
              isLessThan: Timestamp.fromMillisecondsSinceEpoch(cutoffTime))
          .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': _offlineStatus,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint(
              '🧹 Cleaned up ${snapshot.docs.length} stale presence records');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error cleaning up offline presence: $e');
    }
  }

  /// Dispose presence service
  void dispose() {
    _presenceSubscription?.cancel();
    _presenceUpdateTimer?.cancel();
    _isInitialized = false;

    // Set user as offline when disposing
    final user = _auth.currentUser;
    if (user != null) {
      setUserOffline();
    }

    if (kDebugMode) {
      debugPrint('🗑️ Presence service disposed');
    }
  }
}

/// Presence status model
class PresenceStatus {
  final String status; // 'online', 'offline', 'away'
  final int? lastUpdated;
  final int? lastSeen;
  final Map<String, dynamic>? deviceInfo;

  PresenceStatus({
    required this.status,
    this.lastUpdated,
    this.lastSeen,
    this.deviceInfo,
  });

  factory PresenceStatus.fromMap(Map<String, dynamic> map) {
    return PresenceStatus(
      status: map['status'] ?? 'offline',
      lastUpdated: map['lastUpdated'] as int?,
      lastSeen: map['lastSeen'] as int?,
      deviceInfo: map['deviceInfo'] as Map<String, dynamic>?,
    );
  }

  bool get isOnline => status == 'online';
  bool get isOffline => status == 'offline';
  bool get isAway => status == 'away';

  /// Get human-readable status
  String get displayStatus {
    switch (status) {
      case 'online':
        return 'Çevrimiçi';
      case 'away':
        return 'Uzakta';
      case 'offline':
        return 'Çevrimdışı';
      default:
        return 'Bilinmeyen';
    }
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case 'online':
        return 'green';
      case 'away':
        return 'orange';
      case 'offline':
        return 'gray';
      default:
        return 'gray';
    }
  }
}
