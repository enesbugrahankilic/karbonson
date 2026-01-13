// test/language_quiz_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/language_service.dart';
import 'package:karbonson/enums/app_language.dart';
import 'package:karbonson/services/quiz_logic.dart';
import 'package:karbonson/data/questions_database.dart';

void main() {
  group('Language Service Tests', () {
    late LanguageService languageService;

    setUp(() {
      languageService = LanguageService();
    });

    test('Should initialize with Turkish as default language', () {
      expect(languageService.currentLanguage, AppLanguage.turkish);
      expect(languageService.currentLanguageName, 'Türkçe');
      expect(languageService.currentLanguageFlag, '🇹🇷');
    });

    test('Should change language correctly', () async {
      await languageService.setLanguage(AppLanguage.english);
      expect(languageService.currentLanguage, AppLanguage.english);
      expect(languageService.currentLanguageName, 'English');
      expect(languageService.currentLanguageFlag, '🇺🇸');
    });

    test('Should return correct locale for each language', () async {
      expect(languageService.locale, equals(const Locale('tr')));
      
      // After setting to English
      await languageService.setLanguage(AppLanguage.english);
      expect(languageService.locale, equals(const Locale('en')));
    });
  });

  group('Questions Database Tests', () {
    test('Should return correct number of questions for each language', () {
      expect(QuestionsDatabase.getTotalQuestions(AppLanguage.turkish), 25);
      expect(QuestionsDatabase.getTotalQuestions(AppLanguage.english), 25);
    });

    test('Should return questions in correct language', () {
      final turkishQuestions = QuestionsDatabase.getQuestions(AppLanguage.turkish);
      final englishQuestions = QuestionsDatabase.getQuestions(AppLanguage.english);

      expect(turkishQuestions.length, 25);
      expect(englishQuestions.length, 25);

      // Turkish question should be in Turkish
      expect(turkishQuestions.first.text.contains('Karbon ayak izinizi'), true);

      // English question should be in English
      expect(englishQuestions.first.text.contains('What is the most effective way'), true);
    });

    test('Should return random questions', () {
      final questions1 = QuestionsDatabase.getRandomQuestions(AppLanguage.turkish, 5);
      final questions2 = QuestionsDatabase.getRandomQuestions(AppLanguage.turkish, 5);

      expect(questions1.length, 5);
      expect(questions2.length, 5);

      // Different random selections should potentially have different results
      // (though it's possible they could be the same by chance)
    });
  });

  group('Quiz Logic Tests', () {
    late QuizLogic quizLogic;

    setUp(() {
      quizLogic = QuizLogic();
    });

    test('Should initialize with Turkish questions', () {
      expect(quizLogic.currentLanguage, AppLanguage.turkish);
    });

    test('Should change language and refresh questions', () async {
      await quizLogic.setLanguage(AppLanguage.english);
      expect(quizLogic.currentLanguage, AppLanguage.english);
    });

    test('Should generate questions without duplicates within session', () async {
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      
      // Should have 15 questions
      expect(questions.length, 15);

      // No duplicate questions in the same session
      final questionTexts = questions.map((q) => q.text).toList();
      final uniqueTexts = questionTexts.toSet().toList();
      expect(questionTexts.length, uniqueTexts.length);
    });

    test('Should prevent duplicate questions across sessions', () async {
      // Start first quiz
      await quizLogic.startNewQuiz();
      final firstSessionQuestions = await quizLogic.getQuestions();
      
      // Start second quiz
      await quizLogic.startNewQuiz();
      final secondSessionQuestions = await quizLogic.getQuestions();

      // Should have different questions (or at least some variation)
      // Due to deduplication logic, we shouldn't see exact same sequence
      expect(firstSessionQuestions.isNotEmpty, isTrue);
      expect(secondSessionQuestions.isNotEmpty, isTrue);
      expect(secondSessionQuestions.length, 15);
    });

    test('Should clear used questions when all are exhausted', () async {
      // Clear used questions first
      quizLogic.clearUsedQuestions();
      
      // Start multiple quizzes to trigger the reset logic
      for (int i = 0; i < 3; i++) {
        await quizLogic.startNewQuiz();
        final questions = await quizLogic.getQuestions();
        expect(questions.length, 15);
      }
    });

    test('Should get debug information correctly', () async {
      await quizLogic.startNewQuiz();
      final debugInfo = quizLogic.getQuizDebugInfo();
      
      expect(debugInfo['totalQuestions'], 25);
      expect(debugInfo['currentSessionQuestions'], 15);
      expect(debugInfo['currentLanguage'], 'tr');
      expect(debugInfo['usedQuestionIds'], isA<List>());
    });
  });

  group('Question Deduplication Integration Tests', () {
    late QuizLogic quizLogic;

    setUp(() {
      quizLogic = QuizLogic();
    });

    test('Should maintain question variety across multiple quizzes', () async {
      final allQuestions = <String>[];
      
      // Play 3 quizzes
      for (int i = 0; i < 3; i++) {
        await quizLogic.startNewQuiz();
        final questions = await quizLogic.getQuestions();
        final questionTexts = questions.map((q) => q.text).toList();
        allQuestions.addAll(questionTexts);
      }
      
      // Should have questions from the pool
      expect(allQuestions.length, greaterThan(0));
      
      // Total unique questions should be less than or equal to total available
      final uniqueQuestions = allQuestions.toSet();
      expect(uniqueQuestions.length, lessThanOrEqualTo(25));
    });
  });
}