// lib/services/uid_verification_service.dart
// UID Verification and Cleanup Service
// Identifies and fixes UID centrality violations in Firestore data

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';

class UIDVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Statistics for cleanup operations
  UIDCleanupStatistics? _lastCleanupStats;

  /// Comprehensive UID verification and cleanup
  /// Returns detailed statistics about found issues and fixes applied
  Future<UIDCleanupStatistics> performComprehensiveUIDCleanup() async {
    if (kDebugMode) {
      debugPrint('🔍 Starting comprehensive UID cleanup...');
    }

    final stats = UIDCleanupStatistics();

    try {
      // 1. Check users collection for UID inconsistencies
      await _verifyUsersCollection(stats);

      // 2. Check friend_requests collection
      await _verifyFriendRequestsCollection(stats);

      // 3. Check notifications collection
      await _verifyNotificationsCollection(stats);

      // 4. Check game_rooms collection for host/player UID issues
      await _verifyGameRoomsCollection(stats);

      // 5. Verify Auth users exist for all Firestore documents
      await _verifyAuthUsersExist(stats);

      _lastCleanupStats = stats;

      if (kDebugMode) {
        debugPrint('✅ UID cleanup completed:');
        debugPrint(
            '   📊 Invalid documents removed: ${stats.invalidDocumentsRemoved}');
        debugPrint('   🔧 Documents fixed: ${stats.documentsFixed}');
        debugPrint('   ⚠️ Orphaned data cleaned: ${stats.orphanedDataCleaned}');
        debugPrint('   👥 Missing Auth users: ${stats.missingAuthUsers}');
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 Error during UID cleanup: $e');
      }
      rethrow;
    }
  }

  /// Verify users collection UID integrity
  Future<void> _verifyUsersCollection(UIDCleanupStatistics stats) async {
    if (kDebugMode) debugPrint('🔍 Checking users collection...');

    final querySnapshot = await _firestore.collection('users').get();
    int processed = 0;

    for (final doc in querySnapshot.docs) {
      processed++;
      if (kDebugMode && processed % 50 == 0) {
        debugPrint('   📋 Processed $processed users...');
      }

      try {
        final userData = UserData.fromMap(doc.data(), doc.id);

        // Check 1: Document ID matches stored UID
        if (userData.uid != doc.id) {
          stats.invalidDocumentsRemoved++;
          await doc.reference.delete();
          if (kDebugMode) {
            debugPrint('🗑️ Removed invalid user doc (ID mismatch): ${doc.id}');
          }
          continue;
        }

        // Check 2: Verify Auth user exists by trying to get current user
        // Note: FirebaseAuth doesn't have getUserByIdentifier, so we use a different approach
        // We check if the UID format is valid and exists by attempting to verify
        final authUserValid = _isValidFirebaseUID(userData.uid);
        if (!authUserValid) {
          stats.missingAuthUsers++;
          // Don't delete immediately, mark for review
          await doc.reference.update({
            'authStatus': 'invalid_uid_format',
            'lastVerifiedAt': FieldValue.serverTimestamp(),
          });
          if (kDebugMode) {
            debugPrint('⚠️ User doc has invalid UID format: ${userData.uid}');
          }
        }

        // Check 3: Validate data integrity
        final validation = _validateUserDataIntegrity(userData);
        if (!validation.isValid) {
          stats.documentsFixed++;
          await _fixUserDataIntegrity(doc.reference, userData, validation);
        }
      } catch (e) {
        // Malformed document - remove it
        stats.invalidDocumentsRemoved++;
        await doc.reference.delete();
        if (kDebugMode) {
          debugPrint('🗑️ Removed malformed user doc: ${doc.id} - $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('✅ Users collection verified: $processed documents processed');
    }
  }

  /// Verify friend_requests collection
  Future<void> _verifyFriendRequestsCollection(
      UIDCleanupStatistics stats) async {
    if (kDebugMode) debugPrint('🔍 Checking friend_requests collection...');

    final querySnapshot = await _firestore.collection('friend_requests').get();

    for (final doc in querySnapshot.docs) {
      try {
        final data = doc.data();

        // Verify required fields exist
        if (!_hasRequiredFields(data, ['fromUserId', 'toUserId', 'status'])) {
          stats.invalidDocumentsRemoved++;
          await doc.reference.delete();
          continue;
        }

        final fromUserId = data['fromUserId'] as String;
        final toUserId = data['toUserId'] as String;
        final status = data['status'] as String;

        // Check if referenced users exist
        final fromUserExists = await _userDocExists(fromUserId);
        final toUserExists = await _userDocExists(toUserId);

        if (!fromUserExists || !toUserExists) {
          stats.orphanedDataCleaned++;
          await doc.reference.delete();
          if (kDebugMode) {
            debugPrint('🗑️ Removed orphaned friend request: ${doc.id}');
          }
        }

        // Validate status
        if (!_isValidFriendRequestStatus(status)) {
          stats.documentsFixed++;
          await doc.reference.update({'status': 'pending'});
        }
      } catch (e) {
        stats.invalidDocumentsRemoved++;
        await doc.reference.delete();
        if (kDebugMode) {
          debugPrint('🗑️ Removed malformed friend request: ${doc.id}');
        }
      }
    }
  }

  /// Verify notifications collection
  Future<void> _verifyNotificationsCollection(
      UIDCleanupStatistics stats) async {
    if (kDebugMode) debugPrint('🔍 Checking notifications collection...');

    final querySnapshot = await _firestore.collection('notifications').get();

    for (final doc in querySnapshot.docs) {
      try {
        // Check if user document exists
        final userExists = await _userDocExists(doc.id);
        if (!userExists) {
          stats.orphanedDataCleaned++;

          // Delete notifications subcollection
          final subcollection =
              await doc.reference.collection('notifications').get();
          final batch = _firestore.batch();

          for (final subDoc in subcollection.docs) {
            batch.delete(subDoc.reference);
          }

          batch.delete(doc.reference);
          await batch.commit();

          if (kDebugMode) {
            debugPrint(
                '🗑️ Removed orphaned notifications for user: ${doc.id}');
          }
        }
      } catch (e) {
        stats.invalidDocumentsRemoved++;
        await doc.reference.delete();
        if (kDebugMode) {
          debugPrint('🗑️ Removed malformed notifications doc: ${doc.id}');
        }
      }
    }
  }

  /// Verify game_rooms collection for UID issues
  Future<void> _verifyGameRoomsCollection(UIDCleanupStatistics stats) async {
    if (kDebugMode) debugPrint('🔍 Checking game_rooms collection...');

    final querySnapshot = await _firestore.collection('game_rooms').get();

    for (final doc in querySnapshot.docs) {
      try {
        final data = doc.data();

        // Check hostId
        final hostId = data['hostId'] as String?;
        if (hostId != null) {
          final hostExists = await _userDocExists(hostId);
          if (!hostExists) {
            stats.orphanedDataCleaned++;
            await doc.reference.delete();
            if (kDebugMode) {
              debugPrint('🗑️ Removed room with missing host: ${doc.id}');
            }
            continue;
          }
        }

        // Check players array
        final players = data['players'] as List?;
        if (players != null) {
          final validPlayers = <String>[];

          for (final player in players) {
            if (player is Map<String, dynamic>) {
              final playerId = player['id'] as String?;
              if (playerId != null && await _userDocExists(playerId)) {
                validPlayers.add(playerId);
              }
            }
          }

          // Update players array if invalid players were removed
          if (validPlayers.length != players.length) {
            stats.documentsFixed++;
            await doc.reference.update({'players': validPlayers});
            if (kDebugMode) {
              debugPrint('🔧 Fixed invalid players in room: ${doc.id}');
            }
          }
        }
      } catch (e) {
        stats.invalidDocumentsRemoved++;
        await doc.reference.delete();
        if (kDebugMode) {
          debugPrint('🗑️ Removed malformed game room: ${doc.id}');
        }
      }
    }
  }

  /// Verify all Firestore users have corresponding Auth users
  Future<void> _verifyAuthUsersExist(UIDCleanupStatistics stats) async {
    if (kDebugMode)
      debugPrint('🔍 Verifying Auth users exist for all Firestore docs...');

    final querySnapshot = await _firestore.collection('users').get();
    final List<String> missingAuthUsers = [];

    for (final doc in querySnapshot.docs) {
      try {
        final userData = UserData.fromMap(doc.data(), doc.id);
        // Check UID format validity (since we can't directly verify Auth users)
        final isValidUID = _isValidFirebaseUID(userData.uid);

        if (!isValidUID) {
          missingAuthUsers.add(userData.uid);
          stats.missingAuthUsers++;
        }
      } catch (e) {
        // Skip malformed documents
        continue;
      }
    }

    if (missingAuthUsers.isNotEmpty && kDebugMode) {
      debugPrint(
          '⚠️ Found ${missingAuthUsers.length} Firestore docs with invalid UIDs:');
      for (final uid in missingAuthUsers.take(10)) {
        // Show first 10
        debugPrint('   - $uid');
      }
      if (missingAuthUsers.length > 10) {
        debugPrint('   ... and ${missingAuthUsers.length - 10} more');
      }
    }
  }

  /// Validate user data integrity
  DataIntegrityValidation _validateUserDataIntegrity(UserData userData) {
    final issues = <String>[];

    // Check nickname validity
    if (userData.nickname.isEmpty) {
      issues.add('empty_nickname');
    }

    // Check UID format (basic Firebase UID format check)
    if (!_isValidFirebaseUID(userData.uid)) {
      issues.add('invalid_uid_format');
    }

    // Check timestamps
    if (userData.createdAt != null && userData.updatedAt != null) {
      if (userData.updatedAt!.isBefore(userData.createdAt!)) {
        issues.add('timestamp_inconsistency');
      }
    }

    return DataIntegrityValidation(
      isValid: issues.isEmpty,
      issues: issues,
      suggestedFix: issues.isNotEmpty ? _getSuggestedFix(issues) : null,
    );
  }

  /// Fix user data integrity issues
  Future<void> _fixUserDataIntegrity(
    DocumentReference userDocRef,
    UserData userData,
    DataIntegrityValidation validation,
  ) async {
    final updates = <String, dynamic>{};

    for (final issue in validation.issues) {
      switch (issue) {
        case 'empty_nickname':
          updates['nickname'] = 'User_${userData.uid.substring(0, 8)}';
          break;
        case 'timestamp_inconsistency':
          updates['updatedAt'] = FieldValue.serverTimestamp();
          break;
      }
    }

    if (updates.isNotEmpty) {
      updates['lastVerifiedAt'] = FieldValue.serverTimestamp();
      await userDocRef.update(updates);
    }
  }

  /// Get last cleanup statistics
  UIDCleanupStatistics? get lastCleanupStats => _lastCleanupStats;

  /// Quick UID health check (less intensive)
  Future<UIDHealthReport> performQuickUIDHealthCheck() async {
    if (kDebugMode) debugPrint('🏥 Performing quick UID health check...');

    final report = UIDHealthReport();

    try {
      // Check users collection size and obvious issues
      final usersSnapshot = await _firestore.collection('users').get();
      report.totalUsers = usersSnapshot.size;

      // Sample check for obvious issues
      int sampleSize = usersSnapshot.size > 100 ? 100 : usersSnapshot.size;
      int obviousIssues = 0;

      for (int i = 0; i < sampleSize; i++) {
        final doc = usersSnapshot.docs[i];
        try {
          final userData = UserData.fromMap(doc.data(), doc.id);
          if (userData.uid != doc.id) {
            obviousIssues++;
          }
        } catch (e) {
          obviousIssues++;
        }
      }

      report.estimatedIssuesPercentage = (obviousIssues / sampleSize) * 100;
      report.needsFullCleanup = obviousIssues > 0;

      if (kDebugMode) {
        debugPrint('📊 Quick health check completed:');
        debugPrint('   👥 Total users: ${report.totalUsers}');
        debugPrint(
            '   ⚠️ Estimated issues: ${report.estimatedIssuesPercentage.toStringAsFixed(1)}%');
        debugPrint('   🔧 Needs full cleanup: ${report.needsFullCleanup}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error during health check: $e');
      report.error = e.toString();
    }

    return report;
  }

  // Helper methods

  Future<bool> _userDocExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  bool _hasRequiredFields(Map<String, dynamic> data, List<String> fields) {
    return fields
        .every((field) => data.containsKey(field) && data[field] != null);
  }

  bool _isValidFriendRequestStatus(String status) {
    return ['pending', 'accepted', 'rejected', 'expired'].contains(status);
  }

  bool _isValidFirebaseUID(String uid) {
    // Basic Firebase UID format check
    return uid.length >= 28 &&
        uid.length <= 128 &&
        RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(uid);
  }

  String _getSuggestedFix(List<String> issues) {
    return 'Auto-fix applied for: ${issues.join(', ')}';
  }
}

/// Statistics for UID cleanup operations
class UIDCleanupStatistics {
  int invalidDocumentsRemoved = 0;
  int documentsFixed = 0;
  int orphanedDataCleaned = 0;
  int missingAuthUsers = 0;
  DateTime? completedAt;

  bool get hasIssues =>
      invalidDocumentsRemoved > 0 ||
      documentsFixed > 0 ||
      orphanedDataCleaned > 0 ||
      missingAuthUsers > 0;

  String get summary {
    return '''UID Cleanup Summary:
- Invalid documents removed: $invalidDocumentsRemoved
- Documents fixed: $documentsFixed  
- Orphaned data cleaned: $orphanedDataCleaned
- Missing Auth users: $missingAuthUsers
- Completed at: ${completedAt ?? 'Unknown'}''';
  }
}

/// Data integrity validation result
class DataIntegrityValidation {
  final bool isValid;
  final List<String> issues;
  final String? suggestedFix;

  DataIntegrityValidation({
    required this.isValid,
    required this.issues,
    this.suggestedFix,
  });
}

/// Quick health check report
class UIDHealthReport {
  int totalUsers = 0;
  double estimatedIssuesPercentage = 0.0;
  bool needsFullCleanup = false;
  String? error;

  bool get isHealthy => !needsFullCleanup && error == null;

  String get summary {
    if (error != null) {
      return 'Health check failed: $error';
    }

    return '''UID Health Report:
- Total users: $totalUsers
- Estimated issues: ${estimatedIssuesPercentage.toStringAsFixed(1)}%
- Status: ${isHealthy ? 'Healthy' : 'Needs attention'}''';
  }
}
