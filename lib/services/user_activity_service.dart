// lib/services/user_activity_service.dart
// Service for managing user activities

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_activity.dart';

class UserActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recent activities for current user
  Future<List<UserActivity>> getRecentActivities({int limit = 10}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('user_activities')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserActivity.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  // Add new activity
  Future<void> addActivity(UserActivity activity) async {
    try {
      await _firestore
          .collection('user_activities')
          .doc(activity.id)
          .set(activity.toJson());
    } catch (e) {
      print('Error adding activity: $e');
    }
  }

  // Helper method to create and add activity
  Future<void> logActivity({
    required ActivityType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final activity = UserActivity(
      id: '${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.uid,
      type: type,
      title: title,
      description: description,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await addActivity(activity);
  }
}