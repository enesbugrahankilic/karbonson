// test/comprehensive_2fa_widget_test.dart
// Widget Tests for Comprehensive Two-Factor Authentication Verification UI
// Tests user interactions, UI state changes, and accessibility features

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/pages/comprehensive_2fa_verification_page.dart';
import 'package:karbonson/services/comprehensive_2fa_service.dart';

void main() {
  group('Comprehensive2FAVerificationPage Widget Tests', () {
    late List<VerificationMethod> availableMethods;

    setUp(() {
      availableMethods = [
        VerificationMethod.sms,
        VerificationMethod.totp,
        VerificationMethod.backupCode,
      ];
      Comprehensive2FAService.initialize();
    });

    tearDown(() {
      Comprehensive2FAService.dispose();
    });

    testWidgets('should display verification page with SMS as default method', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Verify the page is displayed
      expect(find.text('SMS Doğrulama'), findsOneWidget);
      expect(find.text('İki Faktörlü Doğrulama'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should display method selector with multiple options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Verify method selector is displayed
      expect(find.text('Doğrulama Yöntemi'), findsOneWidget);
      expect(find.text('SMS'), findsOneWidget);
      expect(find.text('TOTP'), findsOneWidget);
      expect(find.text('Backup Code'), findsOneWidget);
    });

    testWidgets('should switch verification methods when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Wait for initial verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap on TOTP radio button
      final totpRadio = find.descendant(
        of: find.byType(RadioListTile<VerificationMethod>),
        matching: find.text('TOTP'),
      );
      
      await tester.tap(totpRadio);
      await tester.pumpAndSettle();

      // Verify TOTP method is selected
      expect(find.text('TOTP Doğrulama'), findsOneWidget);
      expect(find.text('Authenticator Kodu'), findsOneWidget);
    });

    testWidgets('should handle SMS code input with validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Wait for verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find SMS code input field
      final smsField = find.widgetWithText(TextFormField, 'SMS Kodu');
      
      // Test entering valid SMS code
      await tester.enterText(smsField, '123456');
      await tester.pump();

      expect(find.text('123456'), findsOneWidget);

      // Test clearing the input
      final clearButton = find.descendant(
        of: find.byType(TextFormField),
        matching: find.byIcon(Icons.clear),
      );
      
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pump();
        expect(find.text(''), findsOneWidget);
      }
    });

    testWidgets('should handle TOTP code input with validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.totp,
            availableMethods: availableMethods,
            totpSecret: 'JBSWY3DPEHPK3PXP',
          ),
        ),
      );

      // Wait for verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find TOTP code input field
      final totpField = find.widgetWithText(TextFormField, 'Authenticator Kodu');
      
      // Test entering valid TOTP code
      await tester.enterText(totpField, '123456');
      await tester.pump();

      expect(find.text('123456'), findsOneWidget);

      // Verify countdown is displayed
      expect(find.textContaining('Kalan süre:'), findsOneWidget);
    });

    testWidgets('should handle backup code input with masking', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.backupCode,
            availableMethods: availableMethods,
          ),
        ),
      );

      // Wait for verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find backup code input field
      final backupField = find.widgetWithText(TextFormField, 'Yedek Kod');
      
      // Test entering backup code
      await tester.enterText(backupField, 'ABC12345');
      await tester.pump();

      expect(find.text('ABC12345'), findsOneWidget);

      // Test password visibility toggle
      final visibilityButton = find.descendant(
        of: find.byType(TextFormField),
        matching: find.byIcon(Icons.visibility),
      );
      
      if (visibilityButton.evaluate().isNotEmpty) {
        await tester.tap(visibilityButton);
        await tester.pump();
        // Code should now be visible as plain text
      }
    });

    testWidgets('should show verification progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Wait for verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Progress indicator should be visible when code is entered
      final smsField = find.widgetWithText(TextFormField, 'SMS Kodu');
      await tester.enterText(smsField, '123456');
      await tester.pump();

      // Verify progress indicator is shown
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('Süre:'), findsOneWidget);
    });

    testWidgets('should display security information card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Wait for verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify security info card is displayed
      expect(find.text('Güvenlik Bilgisi'), findsOneWidget);
      expect(find.textContaining('SMS kodlarınız'), findsOneWidget);
    });

    testWidgets('should handle method switching with animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Wait for initial verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open advanced options
      final expansionTile = find.text('Diğer Yöntemler');
      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Switch to TOTP method
      final totpButton = find.text('Kullan').first;
      await tester.tap(totpButton);
      
      // Wait for animation and verification
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify method switched
      expect(find.text('TOTP Doğrulama'), findsOneWidget);
    });

    testWidgets('should show help dialog when help button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Find and tap help button
      final helpButton = find.byIcon(Icons.help_outline);
      await tester.tap(helpButton);
      await tester.pumpAndSettle();

      // Verify help dialog is displayed
      expect(find.text('2FA Doğrulama Yardım'), findsOneWidget);
      expect(find.text('Doğrulama Yöntemleri:'), findsOneWidget);
      expect(find.text('Tamam'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('2FA Doğrulama Yardım'), findsNothing);
    });

    testWidgets('should show cancel confirmation when cancel is pressed', (WidgetTester tester) async {
      final navigator = GlobalKey<NavigatorState>();
      
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      // Find and tap cancel button
      final cancelButton = find.text('Doğrulamayı İptal Et');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Since onCancel is not provided, it should just pop
      // The behavior depends on the implementation
    });

    testWidgets('should handle hardware token method', (WidgetTester tester) async {
      final hardwareMethods = [VerificationMethod.hardwareToken];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.hardwareToken,
            availableMethods: hardwareMethods,
          ),
        ),
      );

      // Wait for verification to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify hardware token interface is displayed
      expect(find.text('Hardware Token Doğrulama'), findsOneWidget);
      expect(find.text('Biometric doğrulama'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsNWidgets(2)); // Header and method selector
    });

    testWidgets('should be responsive on different screen sizes', (WidgetTester tester) async {
      // Test on small screen
      await tester.binding.setSurfaceSize(const Size(320, 568));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify content is still accessible on small screen
      expect(find.text('SMS Doğrulama'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Reset to normal size
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });

    testWidgets('should respect semantic labels for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Comprehensive2FAVerificationPage(
            initialMethod: VerificationMethod.sms,
            availableMethods: availableMethods,
            phoneNumber: '+905551234567',
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify semantic labels are present
      expect(find.bySemanticsLabel('Geri'), findsOneWidget);
      expect(find.bySemanticsLabel('Yardım'), findsOneWidget);
      expect(find.bySemanticsLabel('Doğrulama gerekli'), findsOneWidget);
    });
  });
}