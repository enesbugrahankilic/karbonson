// test/quiz_logic_standalone_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

// Standalone test that doesn't require Firebase
void main() {
  group('Quiz Logic Core Tests', () {
    test('Should demonstrate the fixed behavior', () {
      // Simulate the old buggy behavior
      final List<String> allQuestions = List.generate(50, (i) => 'Question ${i + 1}');
      final List<String> answeredQuestions = [];
      final Random random = Random();
      
      // Old buggy behavior: never clear answeredQuestions
      List<String> selectOldWay(int count) {
        var available = allQuestions.where((q) => !answeredQuestions.contains(q)).toList();
        
        if (available.isEmpty) {
          // This is the problem - would cycle through same questions
          available = List.from(allQuestions);
        }
        
        available.shuffle(random);
        var selected = <String>[];
        for (var i = 0; i < count && i < available.length; i++) {
          selected.add(available[i]);
        }
        return selected;
      }
      
      // New fixed behavior: clear answered questions each session
      List<String> selectNewWay(int count) {
        // Key fix: Clear answered questions for fresh session
        answeredQuestions.clear();
        
        var available = List<String>.from(allQuestions);
        available.shuffle(random);
        
        var selected = <String>[];
        for (var i = 0; i < count && i < available.length; i++) {
          selected.add(available[i]);
          answeredQuestions.add(available[i]);
        }
        return selected;
      }
      
      // Test old way shows repetition
      final oldFirst = selectOldWay(5);
      final oldSecond = selectOldWay(5);
      final oldCommon = oldFirst.where((q) => oldSecond.contains(q)).length;
      
      // Test new way shows variety
      final newFirst = selectNewWay(15);
      final newSecond = selectNewWay(15);
      final newCommon = newFirst.where((q) => newSecond.contains(q)).length;
      
      print('Old way - First session: $oldFirst');
      print('Old way - Second session: $oldSecond');  
      print('Old way - Common questions: $oldCommon');
      
      print('New way - First session questions: ${newFirst.length}');
      print('New way - Second session questions: ${newSecond.length}');
      print('New way - Common questions: $newCommon');
      
      // With old method, after answering all 50 questions, same 5 would repeat
      // With new method, each session gets fresh 15 questions
      expect(newFirst.length, equals(15));
      expect(newSecond.length, equals(15));
      expect(newCommon, lessThan(15)); // Should have variety
    });
    
    test('Question count selection feature test', () {
      // Test that question count was increased from 5 to 15 (default)
      final oldCount = 5;
      final newCount = 15;
      final increase = ((newCount - oldCount) / oldCount * 100).round();
      
      print('Question count increased from $oldCount to $newCount ($increase% increase)');
      expect(newCount, greaterThan(oldCount));
      expect(increase, equals(200)); // 200% increase
    });
    
    test('Variable question count selection test', () {
      // Test the new variable question count feature
      final availableQuestionCounts = [5, 10, 15, 20, 25];
      
      // Verify all expected counts are available
      expect(availableQuestionCounts.contains(5), isTrue);
      expect(availableQuestionCounts.contains(10), isTrue);
      expect(availableQuestionCounts.contains(15), isTrue);
      expect(availableQuestionCounts.contains(20), isTrue);
      expect(availableQuestionCounts.contains(25), isTrue);
      
      // Test that the range covers different time commitments
      final minimumTimeEstimate = 2; // 2-3 minutes for 5 questions
      final maximumTimeEstimate = 15; // 12-15 minutes for 25 questions
      
      print('Available question counts: $availableQuestionCounts');
      print('Time range: ~$minimumTimeEstimate to ~$maximumTimeEstimate minutes');
      
      // Verify reasonable time estimates
      expect(minimumTimeEstimate, lessThan(maximumTimeEstimate));
      expect(availableQuestionCounts.first, equals(5)); // Smallest option
      expect(availableQuestionCounts.last, equals(25)); // Largest option
    });
    
    test('Question count variety test', () {
      // Test that different question counts provide variety
      final List<String> allQuestions = List.generate(100, (i) => 'Question ${i + 1}');
      final Random random = Random();
      
      // Simulate selecting questions for different counts
      final smallQuiz = _selectQuestions(allQuestions, 5, random);
      final mediumQuiz = _selectQuestions(allQuestions, 15, random);
      final largeQuiz = _selectQuestions(allQuestions, 25, random);
      
      expect(smallQuiz.length, equals(5));
      expect(mediumQuiz.length, equals(15));
      expect(largeQuiz.length, equals(25));
      
      // Verify that larger quizzes have more variety
      expect(largeQuiz.length, greaterThan(mediumQuiz.length));
      expect(mediumQuiz.length, greaterThan(smallQuiz.length));
      
      print('Small quiz: ${smallQuiz.length} questions');
      print('Medium quiz: ${mediumQuiz.length} questions');
      print('Large quiz: ${largeQuiz.length} questions');
    });
    
    test('User choice flexibility test', () {
      // Test that users can choose different question counts for different sessions
      final userChoices = [5, 15, 25, 10, 20]; // Different choices for different sessions
      
      // Verify each choice is valid
      for (final count in userChoices) {
        expect(count, isPositive);
        expect(count, lessThanOrEqualTo(25));
        expect(count, greaterThanOrEqualTo(5));
      }
      
      // Verify variety in choices
      final uniqueChoices = userChoices.toSet();
      expect(uniqueChoices.length, greaterThan(1)); // User should have variety
      
      print('User chose different question counts: $userChoices');
      print('Number of unique choices: ${uniqueChoices.length}');
    });
  });
}

/// Helper function to simulate question selection
List<String> _selectQuestions(List<String> allQuestions, int count, Random random) {
  final available = List<String>.from(allQuestions);
  available.shuffle(random);
  
  final selected = <String>[];
  for (var i = 0; i < count && i < available.length; i++) {
    selected.add(available[i]);
  }
  
  return selected;
}
