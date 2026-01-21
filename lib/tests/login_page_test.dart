import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/pages/login_page.dart';

void main() {
  group('LoginPage Class/Branch Selection Tests', () {
    testWidgets('should show class dropdown with correct options', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find class dropdown
      expect(find.text('Sınıf'), findsOneWidget);

      // Open dropdown
      await tester.tap(find.text('Sınıf'));
      await tester.pumpAndSettle();

      // Check class options
      expect(find.text('9. Sınıf'), findsOneWidget);
      expect(find.text('10. Sınıf'), findsOneWidget);
      expect(find.text('11. Sınıf'), findsOneWidget);
      expect(find.text('12. Sınıf'), findsOneWidget);
    });

    testWidgets('should show branch dropdown with correct options for 9th grade', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Select 9th grade
      await tester.tap(find.text('Sınıf'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9. Sınıf'));
      await tester.pumpAndSettle();

      // Check branch dropdown is enabled
      expect(find.text('Şube'), findsOneWidget);

      // Open branch dropdown
      await tester.tap(find.text('Şube'));
      await tester.pumpAndSettle();

      // Should show A, B, C, D for 9th grade
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      // Should NOT show E, F for 9th grade
      expect(find.text('E'), findsNothing);
      expect(find.text('F'), findsNothing);
    });

    testWidgets('should show branch dropdown with correct options for 10th grade', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Select 10th grade
      await tester.tap(find.text('Sınıf'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10. Sınıf'));
      await tester.pumpAndSettle();

      // Open branch dropdown
      await tester.tap(find.text('Şube'));
      await tester.pumpAndSettle();

      // Should show A, B, C, D, E, F for 10th grade
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('should reset branch when class changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Select 10th grade and branch A
      await tester.tap(find.text('Sınıf'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10. Sınıf'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Şube'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Verify branch is selected
      expect(find.text('A'), findsOneWidget);

      // Change class to 9th grade
      await tester.tap(find.text('Sınıf'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9. Sınıf'));
      await tester.pumpAndSettle();

      // Branch should be reset (showing hint text)
      expect(find.text('Şubenizi seçin'), findsOneWidget);
    });

    testWidgets('should validate form correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Try to start game without selections
      await tester.tap(find.text('Tek Oyun'));
      await tester.pumpAndSettle();

      // Should show error messages
      expect(find.text('Lütfen bir sınıf seçin'), findsOneWidget);
      expect(find.text('Lütfen bir şube seçin'), findsOneWidget);
    });

    testWidgets('should accept valid class-branch combinations', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Select valid combination: 9th grade, A branch
      await tester.tap(find.text('Sınıf'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9. Sınıf'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Şube'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // Enter nickname
      await tester.enterText(find.byType(TextFormField).first, 'TestUser');

      // Should not show validation errors
      expect(find.text('Lütfen bir sınıf seçin'), findsNothing);
      expect(find.text('Lütfen bir şube seçin'), findsNothing);
    });
  });
}