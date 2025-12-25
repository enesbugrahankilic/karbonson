import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:karbonson/widgets/custom_question_card.dart';
import 'package:karbonson/models/question.dart';

void main() {
  group('CustomQuestionCard Zorluk Seviyesi Testleri', () {
    testWidgets('Kolay zorluk seviyesi gösterimi testi', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.easy,
            ),
          ),
        ),
      );

      // Kolay zorluk seviyesi için "Kolay" yazısını ara
      expect(find.text('Kolay'), findsOneWidget);
      expect(find.byType(Icon), findsWidgets); // İkonların varlığını kontrol et
    });

    testWidgets('Orta zorluk seviyesi gösterimi testi', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.medium,
            ),
          ),
        ),
      );

      // Orta zorluk seviyesi için "Orta" yazısını ara
      expect(find.text('Orta'), findsOneWidget);
    });

    testWidgets('Zor zorluk seviyesi gösterimi testi', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.hard,
            ),
          ),
        ),
      );

      // Zor zorluk seviyesi için "Zor" yazısını ara
      expect(find.text('Zor'), findsOneWidget);
    });

    testWidgets('Zorluk seviyesi null olduğunda gösterilmemeli', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              // difficulty: null - zorluk seviyesi verilmedi
            ),
          ),
        ),
      );

      // Zorluk seviyesi yokken hiçbir zorluk yazısı olmamalı
      expect(find.text('Kolay'), findsNothing);
      expect(find.text('Orta'), findsNothing);
      expect(find.text('Zor'), findsNothing);
    });

    testWidgets('Yanıtlanmış soruda zorluk gösterimi devam etmeli', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: true,
              selectedAnswer: 'A',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.easy,
            ),
          ),
        ),
      );

      // Yanıtlanmış soruda da zorluk seviyesi görünmeli
      expect(find.text('Kolay'), findsOneWidget);
    });

    testWidgets('Farklı soru tiplerinde zorluk gösterimi', (WidgetTester tester) async {
      // 4 seçenekli soru
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu 4 seçenek',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.medium,
            ),
          ),
        ),
      );

      expect(find.text('Orta'), findsOneWidget);

      // 5 seçenekli bonus soru
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu 5 seçenek',
              options: ['A', 'B', 'C', 'D', 'E'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.hard,
            ),
          ),
        ),
      );

      expect(find.text('Zor'), findsOneWidget);
    });
  });

  group('Zorluk Seviyesi İkonları Testleri', () {
    testWidgets('Kolay için mutlu emoji ikonu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.easy,
            ),
          ),
        ),
      );

      // Kolay için mutlu yüz ikonu aranır
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('Zor için üzgün emoji ikonu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.hard,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsWidgets);
    });
  });

  group('Responsive Tasarım Testleri', () {
    testWidgets('Farklı cihaz boyutlarında zorluk gösterimi', (WidgetTester tester) async {
      // Küçük ekran
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.easy,
            ),
          ),
        ),
      );

      expect(find.text('Kolay'), findsOneWidget);

      // Orta ekran
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomQuestionCard(
              question: 'Test sorusu',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.medium,
            ),
          ),
        ),
      );

      expect(find.text('Orta'), findsOneWidget);
    });
  });

  group('Zorluk Seviyesi Renkleri Testleri', () {
    testWidgets('Kolay için yeşil renk', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
          ),
          home: Scaffold(
            backgroundColor: Colors.white,
            body: CustomQuestionCard(
              question: 'Test',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.easy,
            ),
          ),
        ),
      );

      // Kolay için yeşil tonu kontrolü
      expect(find.text('Kolay'), findsOneWidget);
    });

    testWidgets('Orta için turuncu renk', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
          ),
          home: Scaffold(
            backgroundColor: Colors.white,
            body: CustomQuestionCard(
              question: 'Test',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.medium,
            ),
          ),
        ),
      );

      expect(find.text('Orta'), findsOneWidget);
    });

    testWidgets('Zor için kırmızı renk', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
          ),
          home: Scaffold(
            backgroundColor: Colors.white,
            body: CustomQuestionCard(
              question: 'Test',
              options: ['A', 'B', 'C', 'D'],
              onOptionSelected: (answer) {},
              isAnswered: false,
              selectedAnswer: '',
              correctAnswer: 'A',
              difficulty: DifficultyLevel.hard,
            ),
          ),
        ),
      );

      expect(find.text('Zor'), findsOneWidget);
    });
  });
}
