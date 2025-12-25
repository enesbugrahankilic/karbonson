// lib/provides/enhanced_quiz_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../services/enhanced_quiz_logic_service.dart';
import '../services/difficulty_recommendation_service.dart';
import '../enums/app_language.dart';

/// Quiz state management events
abstract class EnhancedQuizEvent {}

class StartNewQuiz extends EnhancedQuizEvent {
  final String? category;
  final DifficultyLevel? preferredDifficulty;
  final bool enableAdaptation;

  StartNewQuiz({
    this.category,
    this.preferredDifficulty,
    this.enableAdaptation = true,
  });
}

class SubmitAnswer extends EnhancedQuizEvent {
  final Question question;
  final String answer;

  SubmitAnswer({
    required this.question,
    required this.answer,
  });
}

class ChangeDifficulty extends EnhancedQuizEvent {
  final DifficultyLevel newDifficulty;

  ChangeDifficulty(this.newDifficulty);
}

class ChangeLanguage extends EnhancedQuizEvent {
  final AppLanguage newLanguage;

  ChangeLanguage(this.newLanguage);
}

class FinishQuiz extends EnhancedQuizEvent {}

class ResetQuiz extends EnhancedQuizEvent {}

class LoadQuizHistory extends EnhancedQuizEvent {}

/// Quiz states
abstract class EnhancedQuizState {}

class EnhancedQuizInitial extends EnhancedQuizState {}

class EnhancedQuizLoading extends EnhancedQuizState {
  final String message;

  EnhancedQuizLoading(this.message);
}

class EnhancedQuizReady extends EnhancedQuizState {
  final List<Question> questions;
  final DifficultyLevel currentDifficulty;
  final String? category;
  final bool canAdaptDifficulty;
  final String recommendedDifficulty;

  EnhancedQuizReady({
    required this.questions,
    required this.currentDifficulty,
    this.category,
    this.canAdaptDifficulty = false,
    this.recommendedDifficulty = '',
  });
}

class EnhancedQuizInProgress extends EnhancedQuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final int currentScore;
  final int highScore;
  final DifficultyLevel currentDifficulty;
  final double currentSessionAccuracy;
  final bool canAdaptDifficulty;
  final Duration sessionDuration;

  EnhancedQuizInProgress({
    required this.questions,
    required this.currentQuestionIndex,
    required this.currentScore,
    required this.highScore,
    required this.currentDifficulty,
    required this.currentSessionAccuracy,
    this.canAdaptDifficulty = false,
    required this.sessionDuration,
  });

  Question get currentQuestion => questions[currentQuestionIndex];
  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  int get answeredQuestions => currentQuestionIndex + 1;
  int get totalQuestions => questions.length;
  double get progress => answeredQuestions / totalQuestions;
}

class EnhancedQuizAnswered extends EnhancedQuizState {
  final Question question;
  final String selectedAnswer;
  final bool isCorrect;
  final int currentScore;
  final int highScore;
  final double currentSessionAccuracy;
  final bool difficultyChanged;
  final DifficultyLevel? newDifficulty;

  EnhancedQuizAnswered({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.currentScore,
    required this.highScore,
    required this.currentSessionAccuracy,
    this.difficultyChanged = false,
    this.newDifficulty,
  });
}

class EnhancedQuizFinished extends EnhancedQuizState {
  final Map<String, dynamic> results;

  EnhancedQuizFinished(this.results);
}

class EnhancedQuizError extends EnhancedQuizState {
  final String message;
  final dynamic error;

  EnhancedQuizError(this.message, this.error);
}

/// Enhanced Quiz BLoC
class EnhancedQuizBloc extends Bloc<EnhancedQuizEvent, EnhancedQuizState> {
  final EnhancedQuizLogicService _quizService = EnhancedQuizLogicService();
  final DifficultyRecommendationService _difficultyService = DifficultyRecommendationService();

  EnhancedQuizBloc() : super(EnhancedQuizInitial()) {
    on<StartNewQuiz>(_onStartNewQuiz);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<ChangeDifficulty>(_onChangeDifficulty);
    on<ChangeLanguage>(_onChangeLanguage);
    on<FinishQuiz>(_onFinishQuiz);
    on<ResetQuiz>(_onResetQuiz);
    on<LoadQuizHistory>(_onLoadQuizHistory);
  }

  Future<void> _onStartNewQuiz(
    StartNewQuiz event,
    Emitter<EnhancedQuizState> emit,
  ) async {
    try {
      emit(EnhancedQuizLoading('Yeni quiz başlatılıyor...'));

      await _quizService.startNewQuiz(
        category: event.category,
        preferredDifficulty: event.preferredDifficulty,
        enableAdaptation: event.enableAdaptation,
      );

      final questions = _quizService.currentQuestions;
      final currentDifficulty = _quizService.currentDifficulty;
      final canAdapt = _quizService.canAdaptDifficulty;
      final recommendedDifficulty = _difficultyService.getRecommendedDifficulty().displayName;

      emit(EnhancedQuizReady(
        questions: questions,
        currentDifficulty: currentDifficulty,
        category: event.category,
        canAdaptDifficulty: canAdapt,
        recommendedDifficulty: recommendedDifficulty,
      ));

      // Automatically move to first question
      emit(EnhancedQuizInProgress(
        questions: questions,
        currentQuestionIndex: 0,
        currentScore: _quizService.currentScore,
        highScore: _quizService.highScore,
        currentDifficulty: currentDifficulty,
        currentSessionAccuracy: _quizService.currentSessionAccuracy,
        canAdaptDifficulty: canAdapt,
        sessionDuration: _quizService.sessionDuration,
      ));
    } catch (e) {
      emit(EnhancedQuizError('Quiz başlatılırken hata oluştu: $e', e));
    }
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<EnhancedQuizState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! EnhancedQuizInProgress) {
        emit(EnhancedQuizError('Quiz aktif değil', null));
        return;
      }

      // Submit answer to service
      final isCorrect = await _quizService.submitAnswer(
        event.question,
        event.answer,
      );

      final newScore = _quizService.currentScore;
      final newHighScore = _quizService.highScore;
      final newAccuracy = _quizService.currentSessionAccuracy;
      final difficultyChanged = _checkDifficultyChange(currentState);

      // Emit answered state with feedback
      emit(EnhancedQuizAnswered(
        question: event.question,
        selectedAnswer: event.answer,
        isCorrect: isCorrect,
        currentScore: newScore,
        highScore: newHighScore,
        currentSessionAccuracy: newAccuracy,
        difficultyChanged: difficultyChanged,
        newDifficulty: difficultyChanged ? _quizService.currentDifficulty : null,
      ));

      // Wait a moment for feedback display, then continue
      await Future.delayed(const Duration(milliseconds: 1500));

      // Move to next question or finish
      final nextIndex = currentState.currentQuestionIndex + 1;
      if (nextIndex >= currentState.totalQuestions) {
        // Quiz finished
        final results = await _quizService.finishQuiz();
        emit(EnhancedQuizFinished(results));
      } else {
        // Continue with next question
        final updatedDifficulty = _quizService.currentDifficulty;
        final canAdapt = _quizService.canAdaptDifficulty;
        final newRecommendedDifficulty = _difficultyService.getRecommendedDifficulty().displayName;

        emit(EnhancedQuizInProgress(
          questions: currentState.questions,
          currentQuestionIndex: nextIndex,
          currentScore: newScore,
          highScore: newHighScore,
          currentDifficulty: updatedDifficulty,
          currentSessionAccuracy: newAccuracy,
          canAdaptDifficulty: canAdapt,
          sessionDuration: _quizService.sessionDuration,
        ));
      }
    } catch (e) {
      emit(EnhancedQuizError('Cevap gönderilirken hata oluştu: $e', e));
    }
  }

  void _onChangeDifficulty(
    ChangeDifficulty event,
    Emitter<EnhancedQuizState> emit,
  ) {
    try {
      _quizService.setDifficulty(event.newDifficulty);
      
      final currentState = state;
      if (currentState is EnhancedQuizInProgress) {
        emit(currentState.copyWith(
          currentDifficulty: event.newDifficulty,
        ));
      }
    } catch (e) {
      emit(EnhancedQuizError('Zorluk seviyesi değiştirilirken hata oluştu: $e', e));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<EnhancedQuizState> emit,
  ) async {
    try {
      emit(EnhancedQuizLoading('Dil değiştiriliyor...'));

      await _quizService.setLanguage(event.newLanguage);

      // Refresh current quiz with new language if active
      final currentState = state;
      if (currentState is EnhancedQuizInProgress) {
        // Restart current quiz with new language
        emit(EnhancedQuizLoading('Quiz yeni dilde yeniden başlatılıyor...'));
        
        // Note: In a real implementation, you'd preserve the current progress
        // and just translate the remaining questions
        await _quizService.startNewQuiz();
        
        emit(EnhancedQuizReady(
          questions: _quizService.currentQuestions,
          currentDifficulty: _quizService.currentDifficulty,
          canAdaptDifficulty: _quizService.canAdaptDifficulty,
          recommendedDifficulty: _difficultyService.getRecommendedDifficulty().displayName,
        ));
      }
    } catch (e) {
      emit(EnhancedQuizError('Dil değiştirilirken hata oluştu: $e', e));
    }
  }

  Future<void> _onFinishQuiz(
    FinishQuiz event,
    Emitter<EnhancedQuizState> emit,
  ) async {
    try {
      final results = await _quizService.finishQuiz();
      emit(EnhancedQuizFinished(results));
    } catch (e) {
      emit(EnhancedQuizError('Quiz sonlandırılırken hata oluştu: $e', e));
    }
  }

  void _onResetQuiz(
    ResetQuiz event,
    Emitter<EnhancedQuizState> emit,
  ) {
    emit(EnhancedQuizInitial());
  }

  void _onLoadQuizHistory(
    LoadQuizHistory event,
    Emitter<EnhancedQuizState> emit,
  ) {
    try {
      final analytics = _quizService.getDetailedAnalytics();
      // In a real implementation, you might emit a new state with history
      if (kDebugMode) {
        print('Quiz History: ${analytics['recentPerformance']}');
      }
    } catch (e) {
      emit(EnhancedQuizError('Quiz geçmişi yüklenirken hata oluştu: $e', e));
    }
  }

  bool _checkDifficultyChange(EnhancedQuizInProgress currentState) {
    // Check if difficulty has changed since last emission
    return currentState.currentDifficulty != _quizService.currentDifficulty;
  }

  // Helper getters for UI
  List<Question> get currentQuestions => _quizService.currentQuestions;
  int get currentScore => _quizService.currentScore;
  int get highScore => _quizService.highScore;
  DifficultyLevel get currentDifficulty => _quizService.currentDifficulty;
  double get currentSessionAccuracy => _quizService.currentSessionAccuracy;
  Duration get sessionDuration => _quizService.sessionDuration;
  bool get isQuizActive => _quizService.isQuizActive;
  bool get canAdaptDifficulty => _quizService.canAdaptDifficulty;

  /// Get detailed analytics for profile/achievement screens
  Map<String, dynamic> getDetailedAnalytics() {
    return _quizService.getDetailedAnalytics();
  }

  /// Clear all performance data (for testing or reset purposes)
  void clearPerformanceData() {
    _quizService.clearPerformanceData();
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return _quizService.getDebugInfo();
  }
}

/// Extension for copying EnhancedQuizInProgress state
extension EnhancedQuizInProgressCopy on EnhancedQuizInProgress {
  EnhancedQuizInProgress copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    int? currentScore,
    int? highScore,
    DifficultyLevel? currentDifficulty,
    double? currentSessionAccuracy,
    bool? canAdaptDifficulty,
    Duration? sessionDuration,
  }) {
    return EnhancedQuizInProgress(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentScore: currentScore ?? this.currentScore,
      highScore: highScore ?? this.highScore,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      currentSessionAccuracy: currentSessionAccuracy ?? this.currentSessionAccuracy,
      canAdaptDifficulty: canAdaptDifficulty ?? this.canAdaptDifficulty,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }
}
