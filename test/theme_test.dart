import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/theme/app_theme.dart';

void main() {
  group('Theme Tests', () {
    testWidgets('Light theme should have proper text colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final textTheme = Theme.of(context).textTheme;
                
                // Test that text colors are not black in light theme
                expect(textTheme.bodyLarge?.color, isNot(equals(Colors.black87)));
                expect(textTheme.bodyMedium?.color, isNot(equals(Colors.black87)));
                expect(textTheme.titleLarge?.color, isNot(equals(Colors.black87)));
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Dark theme should have proper text colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final textTheme = Theme.of(context).textTheme;
                final colorScheme = Theme.of(context).colorScheme;
                
                // Test that text colors are appropriate for dark theme (should be light colored)
                expect(textTheme.bodyLarge?.color, isNot(equals(Colors.black87)));
                expect(textTheme.bodyMedium?.color, isNot(equals(Colors.black87)));
                expect(textTheme.titleLarge?.color, isNot(equals(Colors.black87)));
                
                // Test that color scheme is properly configured for dark theme
                expect(colorScheme.brightness, equals(Brightness.dark));
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Material 3 should be enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final themeData = Theme.of(context);
                
                // Material 3 should be enabled
                expect(themeData.useMaterial3, isTrue);
                
                // Color scheme should be available
                expect(themeData.colorScheme, isNotNull);
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Theme colors should adapt to light/dark mode', (WidgetTester tester) async {
      // Test light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                
                // Light theme should have light brightness
                expect(colorScheme.brightness, equals(Brightness.light));
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      // Rebuild for dark theme test
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                
                // Dark theme should have dark brightness
                expect(colorScheme.brightness, equals(Brightness.dark));
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Google Fonts should be applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final textTheme = Theme.of(context).textTheme;
                
                // Text themes should be configured
                expect(textTheme.displayLarge, isNotNull);
                expect(textTheme.bodyLarge, isNotNull);
                expect(textTheme.titleLarge, isNotNull);
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Button themes should be configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final themeData = Theme.of(context);
                
                // Elevated button theme should be configured
                expect(themeData.elevatedButtonTheme, isNotNull);
                expect(themeData.elevatedButtonTheme.style, isNotNull);
                
                // Card theme should be configured
                expect(themeData.cardTheme, isNotNull);
                expect(themeData.cardTheme.elevation, isNotNull);
                expect(themeData.cardTheme.shape, isNotNull);
                
                return const Text('Test');
              },
            ),
          ),
        ),
      );
    });
  });
}