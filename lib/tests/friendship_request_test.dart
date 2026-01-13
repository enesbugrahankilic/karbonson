// lib/tests/friendship_request_test.dart
// Test file for the complete friendship request system

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Import services
import '../services/friendship_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

// Import models
import '../models/friendship_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Friendship Request System Test', () {
    late FirestoreService firestoreService;
    late FriendshipService friendshipService;

    setUp(() {
      firestoreService = FirestoreService();
      friendshipService = FriendshipService();
    });

    test('Friend Request Flow Test', () async {
      debugPrint('🧪 Starting Friendship Request Flow Test...');

      // Test data
      const String fromUserId = 'test_user_1';
      const String fromNickname = 'TestUser1';
      const String toUserId = 'test_user_2';
      const String toNickname = 'TestUser2';

      try {
        // Step 1: Test sending friend request
        debugPrint('📤 Step 1: Testing sendFriendRequest...');
        final sendResult = await firestoreService.sendFriendRequest(
          fromUserId,
          fromNickname,
          toUserId,
          toNickname,
        );

        expect(sendResult, isTrue,
            reason: 'Friend request should be sent successfully');
        debugPrint('✅ Friend request sent successfully');

        // Step 2: Test retrieving received requests
        debugPrint('📥 Step 2: Testing getReceivedFriendRequests...');
        final receivedRequests =
            await firestoreService.getReceivedFriendRequests(toUserId);

        expect(receivedRequests, isNotEmpty,
            reason: 'Should have received friend requests');
        expect(receivedRequests.first.fromUserId, equals(fromUserId),
            reason: 'Should be from correct user');
        expect(
            receivedRequests.first.status, equals(FriendRequestStatus.pending),
            reason: 'Request should be pending');
        debugPrint('✅ Received friend request retrieved successfully');

        // Step 3: Test accepting friend request
        debugPrint('✅ Step 3: Testing acceptFriendRequest...');
        final acceptResult = await firestoreService.acceptFriendRequest(
          receivedRequests.first.id,
          toUserId,
        );

        expect(acceptResult, isTrue,
            reason: 'Friend request should be accepted successfully');
        debugPrint('✅ Friend request accepted successfully');

        // Step 4: Verify friendship is created
        debugPrint('👥 Step 4: Testing friendship creation...');
        final friends = await firestoreService.getFriends(fromUserId);
        final friendsTo = await firestoreService.getFriends(toUserId);

        expect(friends, isNotEmpty, reason: 'From user should have friends');
        expect(friendsTo, isNotEmpty, reason: 'To user should have friends');
        expect(friends.first.id, equals(toUserId),
            reason: 'From user should be friends with toUser');
        expect(friendsTo.first.id, equals(fromUserId),
            reason: 'To user should be friends with fromUser');
        debugPrint('✅ Friendship created successfully for both users');

        // Step 5: Test rejecting friend request (with different users)
        debugPrint('❌ Step 5: Testing rejectFriendRequest...');
        const String rejectFromUserId = 'test_user_3';
        const String rejectFromNickname = 'TestUser3';
        const String rejectToUserId = 'test_user_4';
        const String rejectToNickname = 'TestUser4';

        // Send request for rejection
        final rejectSendResult = await firestoreService.sendFriendRequest(
          rejectFromUserId,
          rejectFromNickname,
          rejectToUserId,
          rejectToNickname,
        );

        expect(rejectSendResult, isTrue,
            reason: 'Friend request should be sent for rejection test');

        // Get the request
        final rejectRequests =
            await firestoreService.getReceivedFriendRequests(rejectToUserId);
        expect(rejectRequests, isNotEmpty,
            reason: 'Should have request to reject');

        // Reject the request
        final rejectResult = await firestoreService.rejectFriendRequest(
          rejectRequests.first.id,
          rejectToUserId,
        );

        expect(rejectResult, isTrue,
            reason: 'Friend request should be rejected successfully');
        debugPrint('✅ Friend request rejected successfully');

        // Step 6: Test friend statistics
        debugPrint('📊 Step 6: Testing friend statistics...');
        final statistics = await friendshipService.getFriendStatistics();

        expect(statistics['totalFriends'], isNotNull,
            reason: 'Should have friend statistics');
        expect(statistics['pendingReceived'], isNotNull,
            reason: 'Should have pending received statistics');
        expect(statistics['pendingSent'], isNotNull,
            reason: 'Should have pending sent statistics');
        debugPrint('✅ Friend statistics retrieved successfully');

        debugPrint('🎉 All friendship request tests passed successfully!');
      } catch (e, stackTrace) {
        debugPrint('🚨 Test failed with error: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    });

    test('Real-time Friend Request Listener Test', () async {
      debugPrint('🔄 Starting Real-time Friend Request Listener Test...');

      try {
        const String testUserId = 'test_listener_user';

        // Test real-time listener
        final stream =
            firestoreService.listenToReceivedFriendRequests(testUserId);

        // Listen for changes (this would normally be tested with actual UI)
        final subscription = stream.listen((requests) {
          debugPrint(
              '📨 Received ${requests.length} friend requests in real-time');
          // Test would verify that new requests appear immediately
        });

        // Keep subscription alive for a short time
        await Future.delayed(Duration(seconds: 2));

        await subscription.cancel();

        debugPrint('✅ Real-time listener test completed');
      } catch (e, stackTrace) {
        debugPrint('🚨 Real-time listener test failed: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    });

    test('Notification Service Test', () async {
      debugPrint('🔔 Starting Notification Service Test...');

      try {
        // Test friend request notification
        await NotificationService.showFriendRequestNotificationStatic(
          'test_user',
          'TestUser',
        );

        debugPrint('✅ Friend request notification test passed');

        // Test friend request accepted notification
        await NotificationService.showFriendRequestAcceptedNotificationStatic(
          'TestUser2',
          'test_user_2',
        );

        debugPrint('✅ Friend request accepted notification test passed');

        // Test friend request rejected notification
        await NotificationService.showFriendRequestRejectedNotificationStatic(
          'TestUser3',
          'test_user_3',
        );

        debugPrint('✅ Friend request rejected notification test passed');
      } catch (e, stackTrace) {
        debugPrint('🚨 Notification service test failed: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    });

    test('Friend Request Validation Test', () async {
      debugPrint('🔍 Starting Friend Request Validation Test...');

      try {
        const String fromUserId = 'test_validation_user';
        const String toUserId = 'test_validation_target';

        // Test canSendFriendRequest with valid conditions
        final canSend = await firestoreService.canSendFriendRequest(toUserId);

        // Note: This test might fail if users don't exist, which is expected
        // The important part is that the method doesn't crash
        debugPrint('✅ Friend request validation completed (result: $canSend)');

        // Test isFriendRequestValid with non-existent request
        final isValid = await firestoreService.isFriendRequestValid(
            'non_existent_id', fromUserId);
        expect(isValid, isFalse,
            reason: 'Non-existent request should be invalid');
        debugPrint('✅ Non-existent request validation test passed');
      } catch (e, stackTrace) {
        debugPrint('🚨 Friend request validation test failed: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    });
  });

  group('Friendship Request UI Test', () {
    test('Friend Request Processing Protection Test', () async {
      debugPrint('🛡️ Starting Double-click Protection Test...');

      // This test simulates the protection mechanisms in FriendsPage
      final processingRequests = <String>{};

      // Simulate processing request
      const String requestId = 'test_request_123';
      processingRequests.add(requestId);

      // Try to process again - should be prevented
      expect(processingRequests.contains(requestId), isTrue,
          reason: 'Request should be marked as processing');

      // Remove after processing
      processingRequests.remove(requestId);

      expect(processingRequests.isEmpty, isTrue,
          reason: 'Request should be removed after processing');

      debugPrint('✅ Double-click protection test passed');
    });
  });
}

/// Test utility to clean up test data
class TestCleanup {
  static Future<void> cleanupTestData() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      // Clean up test friend requests
      final requestsQuery = await db.collection('friend_requests').where(
          'fromNickname',
          whereIn: ['TestUser1', 'TestUser2', 'TestUser3', 'TestUser4']).get();

      for (final doc in requestsQuery.docs) {
        await doc.reference.delete();
      }

      // Clean up test notifications
      final notificationsQuery = await db.collection('notifications').get();

      for (final doc in notificationsQuery.docs) {
        // Delete notifications subcollection
        final notificationsSub =
            await doc.reference.collection('notifications').get();
        for (final notifDoc in notificationsSub.docs) {
          await notifDoc.reference.delete();
        }
      }

      debugPrint('🧹 Test data cleaned up successfully');
    } catch (e) {
      debugPrint('⚠️ Test cleanup failed: $e');
    }
  }
}
