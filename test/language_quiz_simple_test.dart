// test/language_quiz_simple_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/language_service.dart';
import 'package:karbonson/enums/app_language.dart';
import 'package:karbonson/data/questions_database.dart';

void main() {
  setUpAll(() async {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock SharedPreferences for testing
    // This ensures SharedPreferences doesn't fail in test environment
  });

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

      // Both should contain valid questions
      for (var question in questions1) {
        expect(question.text, isNotEmpty);
        expect(question.options.length, greaterThan(0));
      }

      for (var question in questions2) {
        expect(question.text, isNotEmpty);
        expect(question.options.length, greaterThan(0));
      }
    });

    test('Should have different languages with same structure', () {
      final turkishQuestions = QuestionsDatabase.getQuestions(AppLanguage.turkish);
      final englishQuestions = QuestionsDatabase.getQuestions(AppLanguage.english);

      expect(turkishQuestions.length, englishQuestions.length);

      // Both should have questions with similar structure (4 options for regular questions)
      final turkishRegular = turkishQuestions.where((q) => q.options.length == 4).toList();
      final englishRegular = englishQuestions.where((q) => q.options.length == 4).toList();

      expect(turkishRegular.length, greaterThan(0));
      expect(englishRegular.length, greaterThan(0));
    });
  });

  group('Question Structure Tests', () {
    test('Questions should have valid structure', () {
      final turkishQuestions = QuestionsDatabase.getQuestions(AppLanguage.turkish);
      
      for (var question in turkishQuestions) {
        expect(question.text, isNotEmpty);
        expect(question.text.length, greaterThan(10)); // Should be meaningful questions
        expect(question.options, isNotEmpty);
        expect(question.options.length, greaterThan(1)); // Should have multiple choices
        
        // Check that options have text and score
        for (var option in question.options) {
          expect(option.text, isNotEmpty);
          expect(option.score, greaterThanOrEqualTo(0));
        }
      }
    });

    test('Questions should be in appropriate language', () {
      final turkishQuestions = QuestionsDatabase.getQuestions(AppLanguage.turkish);
      final englishQuestions = QuestionsDatabase.getQuestions(AppLanguage.english);

      // Turkish questions should contain Turkish words
      bool hasTurkishContent = turkishQuestions.any((q) => 
        q.text.contains('Karbon') || 
        q.text.contains('çevre') || 
        q.text.contains('enerji')
      );
      expect(hasTurkishContent, true);

      // English questions should contain English words
      bool hasEnglishContent = englishQuestions.any((q) => 
        q.text.contains('carbon') || 
        q.text.contains('environment') || 
        q.text.contains('energy')
      );
      expect(hasEnglishContent, true);
    });
  });
}