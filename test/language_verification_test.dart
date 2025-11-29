// test/language_verification_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/data/questions_database.dart';
import 'package:karbonson/services/language_service.dart';

void main() {
  setUpAll(() async {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Language Implementation Verification', () {
    test('Languages enum should be correctly defined', () {
      expect(AppLanguage.turkish.code, 'tr');
      expect(AppLanguage.turkish.displayName, 'Türkçe');
      expect(AppLanguage.turkish.flag, '🇹🇷');

      expect(AppLanguage.english.code, 'en');
      expect(AppLanguage.english.displayName, 'English');
      expect(AppLanguage.english.flag, '🇺🇸');
    });

    test('Questions database should contain multilingual content', () {
      final turkishQuestions = QuestionsDatabase.getQuestions(AppLanguage.turkish);
      final englishQuestions = QuestionsDatabase.getQuestions(AppLanguage.english);

      // Both languages should have questions
      expect(turkishQuestions.isNotEmpty, true);
      expect(englishQuestions.isNotEmpty, true);

      // Verify Turkish questions are in Turkish
      final hasTurkishQuestions = turkishQuestions.any((q) => 
        q.text.contains('Karbon') || 
        q.text.contains('çevre') || 
        q.text.contains('enerji') ||
        q.text.contains('sürdürülebilir')
      );
      expect(hasTurkishQuestions, true, reason: 'Should contain Turkish environmental terms');

      // Verify English questions are in English
      final hasEnglishQuestions = englishQuestions.any((q) => 
        q.text.contains('carbon') || 
        q.text.contains('environment') || 
        q.text.contains('energy') ||
        q.text.contains('sustainable')
      );
      expect(hasEnglishQuestions, true, reason: 'Should contain English environmental terms');

      // Both should have same number of questions for consistency
      expect(turkishQuestions.length, englishQuestions.length);
    });

    test('Questions should have proper scoring structure', () {
      final turkishQuestions = QuestionsDatabase.getQuestions(AppLanguage.turkish);
      
      for (var question in turkishQuestions) {
        expect(question.text.isNotEmpty, true);
        expect(question.options.isNotEmpty, true);
        
        // At least one option should have a positive score (correct answer)
        final hasPositiveScore = question.options.any((option) => option.score > 0);
        expect(hasPositiveScore, true, reason: 'Each question should have at least one correct answer');
        
        // All options should have scores
        for (var option in question.options) {
          expect(option.score >= 0, true);
          expect(option.text.isNotEmpty, true);
        }
      }
    });

    test('Random question generation should work', () {
      final randomQuestions1 = QuestionsDatabase.getRandomQuestions(AppLanguage.turkish, 3);
      final randomQuestions2 = QuestionsDatabase.getRandomQuestions(AppLanguage.turkish, 3);

      expect(randomQuestions1.length, 3);
      expect(randomQuestions2.length, 3);

      // Both should contain valid Question objects
      for (var question in [...randomQuestions1, ...randomQuestions2]) {
        expect(question.text.isNotEmpty, true);
        expect(question.options.isNotEmpty, true);
        expect(question.options.length >= 2, true);
      }
    });

    test('Question count should be consistent', () {
      final turkishCount = QuestionsDatabase.getTotalQuestions(AppLanguage.turkish);
      final englishCount = QuestionsDatabase.getTotalQuestions(AppLanguage.english);

      expect(turkishCount, greaterThan(0));
      expect(englishCount, greaterThan(0));
      expect(turkishCount, englishCount); // Should be balanced
    });
  });
}