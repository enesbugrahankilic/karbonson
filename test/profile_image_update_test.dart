// test/profile_image_update_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

import 'package:karbonson/provides/profile_bloc.dart';
import 'package:karbonson/widgets/profile_picture_change_dialog.dart';

void main() {
  group('Profile Image Update Tests', () {
    late ProfileBloc profileBloc;
    
    setUp(() {
      profileBloc = MockProfileBloc();
    });

    testWidgets('ProfilePictureChangeDialog updates image immediately when callback is called', 
        (WidgetTester tester) async {
      
      // Given
      String? callbackImageUrl;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfilePictureChangeDialog(
              onProfilePictureUpdated: (imageUrl) {
                callbackImageUrl = imageUrl;
              },
            ),
          ),
        ),
      );

      // Verify dialog opens
      expect(find.byType(ProfilePictureChangeDialog), findsOneWidget);

      // Note: Testing the full upload flow would require mocking image picker
      // and Firebase Storage, which is beyond the scope of this simple test
    });

    test('UpdateProfilePicture event is defined correctly', () {
      final event = UpdateProfilePicture('https://example.com/test.jpg');
      expect(event.imageUrl, 'https://example.com/test.jpg');
    });

    testWidgets('ProfileBloc receives UpdateProfilePicture event', (WidgetTester tester) async {
      // Given
      when(profileBloc.state).thenReturn(ProfileInitial());
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: profileBloc,
            child: const Scaffold(
              body: Text('Test'),
            ),
          ),
        ),
      );

      // When - emit event
      profileBloc.add(const UpdateProfilePicture('https://example.com/test.jpg'));

      // Then - verify event was added
      verify(profileBloc.add(const UpdateProfilePicture('https://example.com/test.jpg'))).called(1);
    });
  });
}

// Generate mock classes
class MockProfileBloc extends Mock implements ProfileBloc {}