// lib/services/task_reminder_service.dart
// Task Reminder Management with Firestore Integration
// UID Centrality: Subcollection under users/{uid}/task_reminders

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_reminder.dart';
import '../models/user_preferences.dart';

/// Task Reminder Service for managing user task reminders
class TaskReminderService {
  static final TaskReminderService _instance = TaskReminderService._internal();
  factory TaskReminderService() => _instance;
  TaskReminderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name (subcollection under users)
  static const String _collectionName = 'task_reminders';

  /// Get all task reminders for a user
  Future<List<TaskReminder>> getUserTasks({String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return [];
      }

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .orderBy('scheduledTime', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Use document ID as task ID
        return TaskReminder.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user tasks: $e');
      return [];
    }
  }

  /// Get a specific task reminder
  Future<TaskReminder?> getTaskReminder(String taskId, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final targetUid = uid ?? user.uid;
      
      final doc = await _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .doc(taskId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) debugPrint('📄 Task reminder not found: $taskId');
        return null;
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      return TaskReminder.fromMap(data);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting task reminder: $e');
      return null;
    }
  }

  /// Create a new task reminder
  Future<String?> createTaskReminder(TaskReminder task) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != task.userId) {
        if (kDebugMode) debugPrint('❌ Invalid user for task creation');
        return null;
      }

      final docRef = await _firestore
          .collection('users')
          .doc(task.userId)
          .collection(_collectionName)
          .add(task.toMap());

      if (kDebugMode) {
        debugPrint('✅ Task reminder created: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error creating task reminder: $e');
      return null;
    }
  }

  /// Update an existing task reminder
  Future<bool> updateTaskReminder(TaskReminder task) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != task.userId) {
        if (kDebugMode) debugPrint('❌ Invalid user for task update');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(task.userId)
          .collection(_collectionName)
          .doc(task.id)
          .set(task.toMap(), SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('✅ Task reminder updated: ${task.id}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating task reminder: $e');
      return false;
    }
  }

  /// Delete a task reminder
  Future<bool> deleteTaskReminder(String taskId, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final targetUid = uid ?? user.uid;
      
      await _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .doc(taskId)
          .delete();

      if (kDebugMode) {
        debugPrint('🗑️ Task reminder deleted: $taskId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error deleting task reminder: $e');
      return false;
    }
  }

  /// Mark task as completed
  Future<bool> completeTask(String taskId, {String? uid, String? notes}) async {
    try {
      final task = await getTaskReminder(taskId, uid: uid);
      if (task == null) return false;

      final completedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        notes: notes ?? task.notes,
      );

      return await updateTaskReminder(completedTask);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error completing task: $e');
      return false;
    }
  }

  /// Mark task as missed
  Future<bool> markTaskAsMissed(String taskId, {String? uid}) async {
    try {
      final task = await getTaskReminder(taskId, uid: uid);
      if (task == null) return false;

      final missedTask = task.copyWith(
        status: TaskStatus.missed,
      );

      return await updateTaskReminder(missedTask);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error marking task as missed: $e');
      return false;
    }
  }

  /// Snooze a task reminder
  Future<bool> snoozeTask(String taskId, DateTime snoozeUntil, {String? uid}) async {
    try {
      final task = await getTaskReminder(taskId, uid: uid);
      if (task == null) return false;

      final snoozedTask = task.copyWith(
        status: TaskStatus.snoozed,
        scheduledTime: snoozeUntil,
        snoozedUntil: snoozeUntil,
      );

      return await updateTaskReminder(snoozedTask);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error snoozing task: $e');
      return false;
    }
  }

  /// Get pending tasks (for notification scheduling)
  Future<List<TaskReminder>> getPendingTasks({String? uid}) async {
    try {
      final allTasks = await getUserTasks(uid: uid);
      return allTasks.where((task) => 
        task.status == TaskStatus.pending || 
        task.status == TaskStatus.snoozed
      ).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting pending tasks: $e');
      return [];
    }
  }

  /// Get today's tasks
  Future<List<TaskReminder>> getTodayTasks({String? uid}) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .where('scheduledTime', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('scheduledTime', isLessThan: endOfDay.millisecondsSinceEpoch)
          .orderBy('scheduledTime', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskReminder.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting today tasks: $e');
      return [];
    }
  }

  /// Get tasks by category
  Future<List<TaskReminder>> getTasksByCategory(String category, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('scheduledTime', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskReminder.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting tasks by category: $e');
      return [];
    }
  }

  /// Get tasks by type
  Future<List<TaskReminder>> getTasksByType(ReminderType type, {String? uid}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .where('reminderType', isEqualTo: type.name)
          .orderBy('scheduledTime', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskReminder.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting tasks by type: $e');
      return [];
    }
  }

  /// Get overdue tasks
  Future<List<TaskReminder>> getOverdueTasks({String? uid}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final user = _auth.currentUser;
      if (user == null) return [];

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .where('status', isEqualTo: TaskStatus.pending.name)
          .where('scheduledTime', isLessThan: now)
          .orderBy('scheduledTime', descending: true);

      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskReminder.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting overdue tasks: $e');
      return [];
    }
  }

  /// Update task streak count
  Future<bool> updateTaskStreak(String taskId, {String? uid}) async {
    try {
      final task = await getTaskReminder(taskId, uid: uid);
      if (task == null) return false;

      final updatedTask = task.copyWith(
        streakCount: task.streakCount + 1,
      );

      return await updateTaskReminder(updatedTask);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating task streak: $e');
      return false;
    }
  }

  /// Reset task streak count
  Future<bool> resetTaskStreak(String taskId, {String? uid}) async {
    try {
      final task = await getTaskReminder(taskId, uid: uid);
      if (task == null) return false;

      final updatedTask = task.copyWith(
        streakCount: 0,
      );

      return await updateTaskReminder(updatedTask);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error resetting task streak: $e');
      return false;
    }
  }

  /// Create recurring task template
  Future<String?> createRecurringTask({
    required String userId,
    required String title,
    required String description,
    required String category,
    required TimeOfDay time,
    required ReminderType reminderType,
    required List<int> daysOfWeek, // 0=Sunday, 1=Monday, etc.
  }) async {
    try {
      final now = DateTime.now();
      
      // Create template for next occurrence
      DateTime nextOccurrence = _getNextOccurrence(now, daysOfWeek, time);
      
      final task = TaskReminder(
        id: '', // Will be generated
        userId: userId,
        title: title,
        description: description,
        category: category,
        scheduledTime: nextOccurrence,
        status: TaskStatus.pending,
        reminderType: reminderType,
        isRecurring: true,
        streakCount: 0,
        createdAt: now,
      );

      return await createTaskReminder(task);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error creating recurring task: $e');
      return null;
    }
  }

  /// Auto-complete recurring tasks
  Future<bool> autoCompleteRecurringTask(String taskId, {String? uid}) async {
    try {
      final task = await getTaskReminder(taskId, uid: uid);
      if (task == null || !task.isRecurring) return false;

      // Mark current task as completed
      await completeTask(taskId, uid: uid);

      // Create next occurrence if it's recurring
      final nextTime = task.scheduledTime.add(const Duration(days: 1));
      final nextTask = task.copyWith(
        id: '', // Will be generated
        scheduledTime: nextTime,
        status: TaskStatus.pending,
        completedAt: null,
        snoozedUntil: null,
      );

      await createTaskReminder(nextTask);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error auto-completing recurring task: $e');
      return false;
    }
  }

  /// Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics({String? uid}) async {
    try {
      final tasks = await getUserTasks(uid: uid);
      
      int completed = 0;
      int pending = 0;
      int missed = 0;
      int snoozed = 0;
      
      for (final task in tasks) {
        switch (task.status) {
          case TaskStatus.completed:
            completed++;
            break;
          case TaskStatus.pending:
            pending++;
            break;
          case TaskStatus.missed:
            missed++;
            break;
          case TaskStatus.snoozed:
            snoozed++;
            break;
        }
      }

      return {
        'total': tasks.length,
        'completed': completed,
        'pending': pending,
        'missed': missed,
        'snoozed': snoozed,
        'completionRate': tasks.isNotEmpty ? (completed / tasks.length * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting task statistics: $e');
      return {};
    }
  }

  /// Get streak statistics
  Future<Map<String, dynamic>> getStreakStatistics({String? uid}) async {
    try {
      final tasks = await getUserTasks(uid: uid);
      
      int maxStreak = 0;
      int currentStreak = 0;
      int totalCompletions = 0;
      
      for (final task in tasks) {
        if (task.isCompleted) {
          totalCompletions++;
          if (task.streakCount > maxStreak) {
            maxStreak = task.streakCount;
          }
        }
      }

      // Calculate current streak (simplified - from most recent completed task)
      final completedTasks = tasks.where((t) => t.isCompleted).toList();
      if (completedTasks.isNotEmpty) {
        completedTasks.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
        currentStreak = completedTasks.first.streakCount;
      }

      return {
        'maxStreak': maxStreak,
        'currentStreak': currentStreak,
        'totalCompletions': totalCompletions,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting streak statistics: $e');
      return {};
    }
  }

  /// Clean up old completed tasks (admin function)
  Future<bool> cleanupOldTasks({String? uid, int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;
      
      final user = _auth.currentUser;
      if (user == null) return false;

      final targetUid = uid ?? user.uid;
      
      final query = _firestore
          .collection('users')
          .doc(targetUid)
          .collection(_collectionName)
          .where('status', isEqualTo: TaskStatus.completed.name)
          .where('completedAt', isLessThan: cutoffTimestamp);

      final snapshot = await query.get();
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      if (kDebugMode) {
        debugPrint('🧹 Cleaned up ${snapshot.docs.length} old tasks');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error cleaning up old tasks: $e');
      return false;
    }
  }

  /// Helper method to get next occurrence for recurring tasks
  DateTime _getNextOccurrence(DateTime now, List<int> daysOfWeek, TimeOfDay time) {
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      if (daysOfWeek.contains(checkDate.weekday)) {
        return DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          time.hour,
          time.minute,
        );
      }
    }
    
    // Fallback to next week
    final nextWeek = now.add(const Duration(days: 7));
    return DateTime(
      nextWeek.year,
      nextWeek.month,
      nextWeek.day,
      time.hour,
      time.minute,
    );
  }
}
