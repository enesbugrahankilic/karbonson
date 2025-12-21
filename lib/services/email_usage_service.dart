// lib/services/email_usage_service.dart
// Service to track and limit email usage count (maximum 2 uses per email)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Email usage tracking data model
class EmailUsage {
  final String email;
  final int usageCount;
  final DateTime? lastUsed;
  final List<String> usedUserIds; // Track which user IDs used this email

  const EmailUsage({
    required this.email,
    required this.usageCount,
    this.lastUsed,
    this.usedUserIds = const [],
  });

  factory EmailUsage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmailUsage(
      email: data['email'] ?? '',
      usageCount: data['usageCount'] ?? 0,
      lastUsed: data['lastUsed'] != null
          ? (data['lastUsed'] as Timestamp).toDate()
          : null,
      usedUserIds: List<String>.from(data['usedUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'usageCount': usageCount,
      'lastUsed': lastUsed?.toIso8601String(),
      'usedUserIds': usedUserIds,
    };
  }

  /// Check if email can be used (less than 2 uses)
  bool get canBeUsed => usageCount < 2;

  EmailUsage copyWith({
    String? email,
    int? usageCount,
    DateTime? lastUsed,
    List<String>? usedUserIds,
  }) {
    return EmailUsage(
      email: email ?? this.email,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      usedUserIds: usedUserIds ?? this.usedUserIds,
    );
  }
}

/// Result class for email usage validation
class EmailUsageValidationResult {
  final bool isValid;
  final String error;
  final EmailUsage? emailUsage;

  const EmailUsageValidationResult({
    required this.isValid,
    this.error = '',
    this.emailUsage,
  });

  factory EmailUsageValidationResult.success(EmailUsage usage) {
    return EmailUsageValidationResult(
      isValid: true,
      error: '',
      emailUsage: usage,
    );
  }

  factory EmailUsageValidationResult.failure(String error) {
    return EmailUsageValidationResult(
      isValid: false,
      error: error,
    );
  }
}

/// Service for managing email usage limitations
class EmailUsageService {
  static const int maxEmailUses = 2;
  static const String collectionName = 'email_usage';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if email can be used (has been used less than 2 times)
  Future<EmailUsageValidationResult> canEmailBeUsed(String email) async {
    try {
      if (email.isEmpty) {
        return EmailUsageValidationResult.failure('E-posta adresi boş olamaz');
      }

      final normalizedEmail = email.toLowerCase().trim();
      final docRef = _firestore.collection(collectionName).doc(normalizedEmail);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Email has never been used
        return EmailUsageValidationResult.success(
          EmailUsage(
            email: normalizedEmail,
            usageCount: 0,
          ),
        );
      }

      final emailUsage = EmailUsage.fromDocument(doc);

      if (emailUsage.canBeUsed) {
        return EmailUsageValidationResult.success(emailUsage);
      } else {
        return EmailUsageValidationResult.failure(
            'Bu e-posta adresi zaten 2 kez kullanılmış. Maksimum kullanım sayısına ulaşıldı.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email usage: $e');
      }

      // On error, allow registration to proceed (fail-open approach)
      return EmailUsageValidationResult.success(
        EmailUsage(
          email: email.toLowerCase().trim(),
          usageCount: 0,
        ),
      );
    }
  }

  /// Record email usage when a user registers
  Future<void> recordEmailUsage(String email, String userId) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final docRef = _firestore.collection(collectionName).doc(normalizedEmail);

      await _firestore.runTransaction((transaction) async {
        // Get current document
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          // First time using this email
          transaction.set(docRef, {
            'email': normalizedEmail,
            'usageCount': 1,
            'lastUsed': FieldValue.serverTimestamp(),
            'usedUserIds': [userId],
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Update existing usage
          final data = docSnapshot.data() as Map<String, dynamic>;
          final currentCount = data['usageCount'] ?? 0;
          final usedUserIds = List<String>.from(data['usedUserIds'] ?? []);

          // Only increment if userId is not already in the list (prevent duplicates)
          if (!usedUserIds.contains(userId)) {
            usedUserIds.add(userId);
          }

          transaction.update(docRef, {
            'usageCount': currentCount + 1,
            'lastUsed': FieldValue.serverTimestamp(),
            'usedUserIds': usedUserIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      if (kDebugMode) {
        debugPrint(
            'Recorded email usage for: $normalizedEmail (user: $userId)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error recording email usage: $e');
      }
      // Don't throw - registration should proceed even if usage tracking fails
    }
  }

  /// Get email usage information
  Future<EmailUsage?> getEmailUsage(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final doc = await _firestore
          .collection(collectionName)
          .doc(normalizedEmail)
          .get();

      if (doc.exists) {
        return EmailUsage.fromDocument(doc);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting email usage: $e');
      }
      return null;
    }
  }

  /// Reset email usage (admin function - for testing or manual cleanup)
  Future<void> resetEmailUsage(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      await _firestore.collection(collectionName).doc(normalizedEmail).delete();

      if (kDebugMode) {
        debugPrint('Reset email usage for: $normalizedEmail');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resetting email usage: $e');
      }
      rethrow;
    }
  }

  /// Get all email usage statistics (for admin purposes)
  Future<List<EmailUsage>> getAllEmailUsage() async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .orderBy('usageCount', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EmailUsage.fromDocument(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting all email usage: $e');
      }
      return [];
    }
  }

  /// Clean up orphaned email usage records (emails with users that don't exist)
  Future<void> cleanupOrphanedRecords() async {
    try {
      // This would require cross-referencing with Firebase Auth users
      // For now, just log the intent
      if (kDebugMode) {
        debugPrint(
            'Email usage cleanup not implemented - would require Firebase Admin SDK');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during email usage cleanup: $e');
      }
    }
  }
}
