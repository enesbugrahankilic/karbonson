// lib/services/user_preferences_service.dart
// User Preferences Management with Firestore Integration
// UID Centrality: Document ID = Firebase Auth UID

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_preferences.dart';

/// User Preferences Service for managing user settings
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name
  static const String _collectionName = 'user_preferences';

  /// Get user preferences from Firestore
  Future<UserPreferences?> getUserPreferences({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return null;
      }

      final targetUid = uid ?? user.uid;
      
      final doc = await _firestore
          .collection(_collectionName)
          .doc(targetUid)
          .get();

      if (!doc.exists) {
        if (kDebugMode) debugPrint('📄 No preferences found for user: $targetUid');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        if (kDebugMode) debugPrint('⚠️ Empty preferences data for user: $targetUid');
        return null;
      }

      // Add userId to data before creating UserPreferences
      final preferencesData = Map<String, dynamic>.from(data);
      preferencesData['userId'] = targetUid;

      return UserPreferences.fromMap(preferencesData);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user preferences: $e');
      return null;
    }
  }

  /// Create or update user preferences
  Future<bool> saveUserPreferences(UserPreferences preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != preferences.userId) {
        if (kDebugMode) debugPrint('❌ Invalid user for preferences update');
        return false;
      }

      final preferencesData = preferences.toMap();
      
      await _firestore
          .collection(_collectionName)
          .doc(preferences.userId)
          .set(preferencesData, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('✅ User preferences saved for: ${preferences.userId}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error saving user preferences: $e');
      return false;
    }
  }

  /// Initialize preferences for new user
  Future<UserPreferences?> initializeUserPreferences(String uid) async {
    try {
      final now = DateTime.now();
      final newPreferences = UserPreferences(
        userId: uid,
        smsNotificationsEnabled: true,
        dailyRemindersEnabled: true,
        weeklyReportsEnabled: true,
        streakRemindersEnabled: true,
        preferredReminderTime: TimeOfDay(hour: 9, minute: 0), // Default 09:00
        reminderCategories: [],
        snoozeDuration: 30,
        weekendReminders: false,
        missedTaskReminders: true,
        language: 'tr', // Turkish as default
        createdAt: now,
        updatedAt: now,
      );

      final success = await saveUserPreferences(newPreferences);
      return success ? newPreferences : null;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error initializing user preferences: $e');
      return null;
    }
  }

  /// Update SMS notifications setting
  Future<bool> updateSmsNotifications(bool enabled, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        smsNotificationsEnabled: enabled,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating SMS notifications: $e');
      return false;
    }
  }

  /// Update daily reminders setting
  Future<bool> updateDailyReminders(bool enabled, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        dailyRemindersEnabled: enabled,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating daily reminders: $e');
      return false;
    }
  }

  /// Update weekly reports setting
  Future<bool> updateWeeklyReports(bool enabled, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        weeklyReportsEnabled: enabled,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating weekly reports: $e');
      return false;
    }
  }

  /// Update streak reminders setting
  Future<bool> updateStreakReminders(bool enabled, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        streakRemindersEnabled: enabled,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating streak reminders: $e');
      return false;
    }
  }

  /// Update preferred reminder time
  Future<bool> updatePreferredReminderTime(TimeOfDay time, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        preferredReminderTime: time,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating reminder time: $e');
      return false;
    }
  }

  /// Update reminder categories
  Future<bool> updateReminderCategories(List<String> categories, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        reminderCategories: categories,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating reminder categories: $e');
      return false;
    }
  }

  /// Update snooze duration
  Future<bool> updateSnoozeDuration(int duration, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        snoozeDuration: duration,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating snooze duration: $e');
      return false;
    }
  }

  /// Update weekend reminders setting
  Future<bool> updateWeekendReminders(bool enabled, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        weekendReminders: enabled,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating weekend reminders: $e');
      return false;
    }
  }

  /// Update missed task reminders setting
  Future<bool> updateMissedTaskReminders(bool enabled, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        missedTaskReminders: enabled,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating missed task reminders: $e');
      return false;
    }
  }

  /// Update language preference
  Future<bool> updateLanguage(String language, {String? uid}) async {
    try {
      final currentPreferences = await getUserPreferences(uid: uid);
      if (currentPreferences == null) return false;

      final updatedPreferences = currentPreferences.copyWith(
        language: language,
        updatedAt: DateTime.now(),
      );

      return await saveUserPreferences(updatedPreferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating language: $e');
      return false;
    }
  }

  /// Get notification settings summary
  Future<Map<String, dynamic>> getNotificationSummary({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      if (preferences == null) return {};

      return {
        'smsEnabled': preferences.smsNotificationsEnabled,
        'dailyRemindersEnabled': preferences.dailyRemindersEnabled,
        'weeklyReportsEnabled': preferences.weeklyReportsEnabled,
        'streakRemindersEnabled': preferences.streakRemindersEnabled,
        'reminderTime': preferences.preferredReminderTime?.toString() ?? '09:00',
        'weekendReminders': preferences.weekendReminders,
        'missedTaskReminders': preferences.missedTaskReminders,
        'snoozeDuration': preferences.snoozeDuration,
        'categories': preferences.reminderCategories,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting notification summary: $e');
      return {};
    }
  }

  /// Check if SMS notifications are enabled
  Future<bool> isSmsNotificationsEnabled({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      return preferences?.smsNotificationsEnabled ?? true; // Default true
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking SMS notifications: $e');
      return true;
    }
  }

  /// Check if daily reminders are enabled
  Future<bool> isDailyRemindersEnabled({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      return preferences?.dailyRemindersEnabled ?? true; // Default true
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking daily reminders: $e');
      return true;
    }
  }

  /// Check if weekend reminders are enabled
  Future<bool> isWeekendRemindersEnabled({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      return preferences?.weekendReminders ?? false; // Default false
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking weekend reminders: $e');
      return false;
    }
  }

  /// Get reminder time for today
  Future<TimeOfDay?> getTodayReminderTime({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      if (preferences == null) return null;

      final now = DateTime.now();
      final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

      // Check if weekend reminders are disabled and today is weekend
      if (isWeekend && !preferences.weekendReminders) {
        return null;
      }

      return preferences.preferredReminderTime;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting reminder time: $e');
      return null;
    }
  }

  /// Get preferred reminder time
  Future<TimeOfDay?> getPreferredReminderTime({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      return preferences?.preferredReminderTime;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting preferred reminder time: $e');
      return null;
    }
  }

  /// Get reminder categories
  Future<List<String>> getReminderCategories({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      return preferences?.reminderCategories ?? [];
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting reminder categories: $e');
      return [];
    }
  }

  /// Get snooze duration
  Future<int> getSnoozeDuration({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      return preferences?.snoozeDuration ?? 30; // Default 30 minutes
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting snooze duration: $e');
      return 30;
    }
  }

  /// Check if notifications should be sent for specific category
  Future<bool> shouldSendNotificationForCategory(String category, {String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      if (preferences == null) return true; // Default allow

      // If no specific categories set, allow all
      if (preferences.reminderCategories.isEmpty) {
        return true;
      }

      return preferences.reminderCategories.contains(category);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking category notification: $e');
      return true;
    }
  }

  /// Reset user preferences to defaults (admin function)
  Future<bool> resetUserPreferences(String uid) async {
    try {
      final defaultPreferences = await initializeUserPreferences(uid);
      return defaultPreferences != null;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error resetting user preferences: $e');
      return false;
    }
  }

  /// Export user preferences (for backup)
  Future<Map<String, dynamic>?> exportPreferences({String? uid}) async {
    try {
      final preferences = await getUserPreferences(uid: uid);
      if (preferences == null) return null;

      return {
        'exportedAt': DateTime.now().toIso8601String(),
        'preferences': preferences.toMap(),
        'version': '1.0',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error exporting preferences: $e');
      return null;
    }
  }

  /// Import user preferences (from backup)
  Future<bool> importPreferences(Map<String, dynamic> data, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final targetUid = uid ?? user.uid;

      // Validate import data structure
      if (!data.containsKey('preferences')) {
        if (kDebugMode) debugPrint('❌ Invalid import data: missing preferences');
        return false;
      }

      final preferencesData = data['preferences'] as Map<String, dynamic>;
      preferencesData['userId'] = targetUid; // Ensure correct user ID
      preferencesData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      final preferences = UserPreferences.fromMap(preferencesData);
      return await saveUserPreferences(preferences);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error importing preferences: $e');
      return false;
    }
  }
}
