// test/quiz_system_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/quiz_logic.dart';

void main() {
  group('QuizLogic Tests', () {
    late QuizLogic quizLogic;

    setUp(() {
      quizLogic = QuizLogic();
    });

    test('Should have total of 50 questions', () {
      expect(quizLogic.getTotalQuestions(), 50);
    });

    test('Should generate different questions in different sessions', () async {
      // Start first quiz
      await quizLogic.startNewQuiz();
      final firstQuestions = await quizLogic.getQuestions();
      
      // Start second quiz
      await quizLogic.startNewQuiz();
      final secondQuestions = await quizLogic.getQuestions();
      
      // Questions should be different (at least most of them)
      final firstTexts = firstQuestions.map((q) => q.text).toSet();
      final secondTexts = secondQuestions.map((q) => q.text).toSet();
      
      expect(firstTexts.length, equals(15)); // Should have 15 questions per session
      expect(secondTexts.length, equals(15)); // Should have 15 questions per session
      
      // At least some questions should be different
      final commonQuestions = firstTexts.intersection(secondTexts);
      expect(commonQuestions.length, lessThan(15)); // Not all questions should be the same
    });

    test('Should reset answered questions for new session', () async {
      // Start first quiz
      await quizLogic.startNewQuiz();
      final firstQuestions = await quizLogic.getQuestions();
      expect(firstQuestions.length, equals(15));
      
      // Check debug info
      final debugInfo = quizLogic.getQuizDebugInfo();
      expect(debugInfo['answeredQuestionsCount'], equals(15));
      expect(debugInfo['currentSessionQuestions'], equals(15));
      
      // Start new quiz - should reset and give different questions
      await quizLogic.startNewQuiz();
      final secondQuestions = await quizLogic.getQuestions();
      expect(secondQuestions.length, equals(15));
      
      final newDebugInfo = quizLogic.getQuizDebugInfo();
      expect(newDebugInfo['answeredQuestionsCount'], equals(15)); // Reset to current session
    });

    test('Should increase question count per session', () async {
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      
      // Should now have 15 questions instead of 5
      expect(questions.length, equals(15));
    });
  });
}