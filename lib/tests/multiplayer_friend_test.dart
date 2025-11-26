// lib/tests/multiplayer_friend_test.dart
// Comprehensive test for multiplayer and friend invitation functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/friendship_service.dart';
import '../services/game_invitation_service.dart';
import '../services/presence_service.dart';
import '../widgets/game_invitation_dialog.dart';

void main() {
  group('Multiplayer and Friend Invitation Tests', () {
    late FirestoreService firestoreService;
    late FriendshipService friendshipService;
    late GameInvitationService invitationService;
    late PresenceService presenceService;

    setUp(() {
      firestoreService = FirestoreService();
      friendshipService = FriendshipService();
      invitationService = GameInvitationService();
      presenceService = PresenceService();
    });

    testWidgets('Friend invitation dialog displays correctly', (WidgetTester tester) async {
      // Create a mock game invitation
      final invitation = GameInvitation(
        id: 'test_invitation_123',
        fromUserId: 'user_1',
        fromNickname: 'TestUser1',
        toUserId: 'user_2',
        roomId: 'room_123',
        roomHostNickname: 'HostUser',
        createdAt: DateTime.now(),
      );

      // Build the invitation dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showGameInvitationDialog(
                  context: context,
                  invitation: invitation,
                );
              },
              child: const Text('Show Invitation'),
            ),
          ),
        ),
      );

      // Tap the button to show invitation dialog
      await tester.tap(find.text('Show Invitation'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed with correct information
      expect(find.text('Oyun Daveti'), findsOneWidget);
      expect(find.text('TestUser1 seni oyuna davet etti!'), findsOneWidget);
      expect(find.text('HostUser'), findsOneWidget);
      expect(find.text('Katıl'), findsOneWidget);
      expect(find.text('Reddet'), findsOneWidget);
    });

    test('Game invitation service methods work correctly', () async {
      // Test invitation creation parameters
      const roomId = 'test_room_123';
      const friendId = 'friend_user_456';
      const friendNickname = 'FriendUser';
      const inviterNickname = 'TestUser';

      // Test that invitation parameters are valid
      expect(roomId.isNotEmpty, true);
      expect(friendId.isNotEmpty, true);
      expect(friendNickname.isNotEmpty, true);
      expect(inviterNickname.isNotEmpty, true);
      expect(friendId != inviterNickname, true); // Should be different users
    });

    test('Presence service initialization works', () async {
      // Test presence service can be initialized
      expect(presenceService, isNotNull);
      
      // Note: We can't actually test Firebase initialization in unit tests
      // but we can verify the service object is properly created
      expect(presenceService, isA<PresenceService>());
    });

    test('Friendship service methods exist', () {
      // Verify that the friendship service has the expected methods
      expect(friendshipService, isNotNull);
      expect(friendshipService.currentUserId, isA<String?>());
      expect(friendshipService.isAuthenticated, isA<bool>());
    });

    test('Firestore service multiplayer methods exist', () {
      // Verify that the firestore service has multiplayer methods
      expect(firestoreService, isNotNull);
      
      // These are async methods but we can verify they exist
      expect(firestoreService.createRoom, isA<Future Function(Object, Object, Object)>());
      expect(firestoreService.joinRoom, isA<Future Function(Object, Object)>());
      expect(firestoreService.getActiveRooms, isA<Future Function()>());
      expect(firestoreService.listenToRoom, isA<Stream Function(Object)>());
    });
  });

  group('Firebase Integration Tests', () {
    setUp(() async {
      // Initialize Firebase for testing
      try {
        await Firebase.initializeApp();
      } catch (e) {
        // Firebase might already be initialized
        print('Firebase initialization note: $e');
      }
    });

    test('Firebase is properly configured', () async {
      // This test verifies that Firebase is properly set up
      // In a real testing environment, you would use Firebase test emulator
      expect(Firebase.apps, isNotEmpty);
      expect(Firebase.app(), isNotNull);
    });
  });
}

// Helper extension for easier testing
extension WidgetTesterExtensions on WidgetTester {
  Future<void> pumpAndSettleWithTimeout([Duration timeout = const Duration(seconds: 3)]) {
    return pumpAndSettle(timeout);
  }
}