// test/phone_input_test.dart
// Test for PhoneInputWidget

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/widgets/phone_input_widget.dart';

void main() {
  group('PhoneInputWidget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should display with correct hint and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputWidget(
              controller: controller,
              labelText: 'Test Label',
              hintText: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('should format Turkish phone number correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputWidget(
              controller: controller,
            ),
          ),
        ),
      );

      // Enter Turkish phone number without formatting
      await tester.enterText(find.byType(TextFormField), '05551234567');
      await tester.pumpAndSettle();

      // Should be formatted as "0555 123 45 67"
      expect(find.text('0555 123 45 67'), findsOneWidget);
    });

    testWidgets('should accept valid Turkish phone number', (WidgetTester tester) async {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PhoneInputWidget(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      // Enter valid Turkish phone number
      await tester.enterText(find.byType(TextFormField), '0555 123 45 67');
      await tester.pumpAndSettle();

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      // Should not show error text
      expect(find.textContaining('Geçerli bir Türk telefon numarası'), findsNothing);
    });

    testWidgets('should reject invalid phone number', (WidgetTester tester) async {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PhoneInputWidget(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      // Enter invalid phone number
      await tester.enterText(find.byType(TextFormField), '12345');
      await tester.pumpAndSettle();

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      // Should show error text
      expect(find.textContaining('Geçerli bir Türk telefon numarası'), findsOneWidget);
    });

    testWidgets('should format international phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputWidget(
              controller: controller,
            ),
          ),
        ),
      );

      // Enter international format
      await tester.enterText(find.byType(TextFormField), '905551234567');
      await tester.pumpAndSettle();

      // Should be converted to Turkish format
      expect(find.text('0555 123 45 67'), findsOneWidget);
    });

    testWidgets('should allow empty input initially', (WidgetTester tester) async {
      GlobalKey<FormState> formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PhoneInputWidget(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      // Don't enter any text, leave it empty
      expect(controller.text, isEmpty);

      // Trigger validation on empty
      formKey.currentState?.validate();
      await tester.pumpAndSettle();

      // Should show required field error
      expect(find.textContaining('Telefon numarası girin'), findsOneWidget);
    });
  });
}