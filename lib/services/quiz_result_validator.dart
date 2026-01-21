// lib/services/quiz_result_validator.dart
// Validate quiz results before saving to database

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'backend_validation_service.dart';
import 'analytics_service.dart';

class QuizResultValidator {
  static final QuizResultValidator _instance = QuizResultValidator._internal();
  factory QuizResultValidator() => _instance;
  QuizResultValidator._internal();

  /// Validate and save quiz result with server-side verification
  Future<bool> validateAndSaveQuizResult({
    required String userId,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int durationSeconds,
    required String difficulty,
    required String category,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🎯 Validating quiz result...');
      }

      // Step 1: Client-side validation
      if (!_validateClientSide(score, correctAnswers, totalQuestions, durationSeconds)) {
        await AnalyticsService().logError(
          'QuizClientValidationFailed',
          'Client validation failed: score=$score, correct=$correctAnswers, total=$totalQuestions, duration=$durationSeconds',
        );
        return false;
      }

      // Step 2: Server-side validation
      final isValid = await BackendValidationService().validateQuizResult(
        userId: userId,
        score: correctAnswers * 10, // Points based on correct answers
        duration: durationSeconds,
        questionCount: totalQuestions,
        difficulty: difficulty,
      );

      if (!isValid) {
        if (kDebugMode) {
          debugPrint('❌ Server validation failed');
        }
        return false;
      }

      // Step 3: Analytics logging
      await AnalyticsService().logGameCompletion(
        'quiz',
        score: score,
        duration: durationSeconds,
        isWin: correctAnswers > (totalQuestions ~/ 2),
        difficulty: _difficultyLevel(difficulty),
      );

      if (kDebugMode) {
        debugPrint('✅ Quiz result validated and saved');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Quiz validation error: $e');
      await AnalyticsService().logError('QuizValidationException', e.toString());
      return false;
    }
  }

  /// Client-side validation checks
  bool _validateClientSide(
    int score,
    int correctAnswers,
    int totalQuestions,
    int durationSeconds,
  ) {
    // Check score consistency
    if (score < 0 || score > totalQuestions * 10) {
      if (kDebugMode) debugPrint('❌ Invalid score: $score');
      return false;
    }

    // Check correct answers range
    if (correctAnswers < 0 || correctAnswers > totalQuestions) {
      if (kDebugMode) debugPrint('❌ Invalid correct answers: $correctAnswers');
      return false;
    }

    // Check duration sanity (must be between 10 sec and 1 hour)
    if (durationSeconds < 10 || durationSeconds > 3600) {
      if (kDebugMode) debugPrint('❌ Invalid duration: $durationSeconds');
      return false;
    }

    // Check minimum time per question (at least 2 sec per question)
    if (durationSeconds < (totalQuestions * 2)) {
      if (kDebugMode) debugPrint('❌ Quiz completed too fast: ${durationSeconds}s for $totalQuestions questions');
      return false;
    }

    return true;
  }

  /// Convert difficulty string to level
  int _difficultyLevel(String difficulty) {
    return {
      'easy': 1,
      'medium': 2,
      'hard': 3,
      'expert': 4,
    }[difficulty.toLowerCase()] ??
        1;
  }
}
