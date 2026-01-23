import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/question.dart';
import '../services/quiz_logic.dart';
import '../enums/app_language.dart';
import '../services/game_completion_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuiz extends QuizEvent {
  final AppLanguage language;
  final String? category;
  final DifficultyLevel? difficulty;
  final int questionCount;

  const LoadQuiz({
    this.language = AppLanguage.turkish,
    this.category,
    this.difficulty,
    this.questionCount = 15, // Default 15 questions
  });

  @override
  List<Object> get props => [language, category ?? '', difficulty ?? '', questionCount];
}

class AnswerQuestion extends QuizEvent {
  final String answer;
  final int questionIndex;

  const AnswerQuestion(this.answer, this.questionIndex);

  @override
  List<Object> get props => [answer, questionIndex];
}

class ChangeLanguage extends QuizEvent {
  final AppLanguage language;

  const ChangeLanguage(this.language);

  @override
  List<Object> get props => [language];
}

class RetryQuizCompletion extends QuizEvent {
  const RetryQuizCompletion();

  @override
  List<Object> get props => [];
}

// States
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Question> questions;
  final int currentQuestion;
  final int score;
  final List<String> answers;
  final AppLanguage currentLanguage;

  const QuizLoaded({
    required this.questions,
    required this.currentQuestion,
    required this.score,
    required this.answers,
    this.currentLanguage = AppLanguage.turkish,
  });

  @override
  List<Object> get props =>
      [questions, currentQuestion, score, answers, currentLanguage];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object> get props => [message];
}

/// State for when no questions are available for the selected combination
class QuizNoQuestionsAvailable extends QuizState {
  final String category;
  final DifficultyLevel? difficulty;
  final String message;

  const QuizNoQuestionsAvailable({
    required this.category,
    this.difficulty,
    required this.message,
  });

  @override
  List<Object> get props => [category, difficulty ?? '', message];
}

class QuizCompleted extends QuizState {
  final List<Question> questions;
  final int score;
  final List<String> answers;
  final AppLanguage currentLanguage;

  const QuizCompleted({
    required this.questions,
    required this.score,
    required this.answers,
    this.currentLanguage = AppLanguage.turkish,
  });

  @override
  List<Object> get props => [questions, score, answers, currentLanguage];
}

/// State for when quiz completion is being processed by backend
class QuizCompletionInProgress extends QuizState {
  final List<Question> questions;
  final int score;
  final List<String> answers;
  final AppLanguage currentLanguage;

  const QuizCompletionInProgress({
    required this.questions,
    required this.score,
    required this.answers,
    this.currentLanguage = AppLanguage.turkish,
  });

  @override
  List<Object> get props => [questions, score, answers, currentLanguage];
}

/// State for when quiz completion fails on backend
class QuizCompletionError extends QuizState {
  final List<Question> questions;
  final int score;
  final List<String> answers;
  final AppLanguage currentLanguage;
  final String errorMessage;

  const QuizCompletionError({
    required this.questions,
    required this.score,
    required this.answers,
    required this.errorMessage,
    this.currentLanguage = AppLanguage.turkish,
  });

  @override
  List<Object> get props => [questions, score, answers, errorMessage, currentLanguage];
}

// Bloc
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizLogic quizLogic;

  QuizBloc({required this.quizLogic}) : super(QuizInitial()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<ChangeLanguage>(_onChangeLanguage);
    on<RetryQuizCompletion>(_onRetryQuizCompletion);
  }

  Future<void> _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      // Set language if provided
      await quizLogic.setLanguage(event.language);

      // Start a new quiz and preload questions with difficulty and question count support
      await quizLogic.startNewQuiz(
        category: event.category,
        difficulty: event.difficulty,
        questionCount: event.questionCount,
      );
      final questions = await quizLogic.getQuestions();
      
      // ✅ Validation: Check if questions are empty
      if (questions.isEmpty) {
        final categoryName = event.category ?? 'Tümü';
        final difficultyName = event.difficulty?.displayName ?? 'Orta';
        emit(QuizNoQuestionsAvailable(
          category: categoryName,
          difficulty: event.difficulty,
          message: 'Maalesef "$categoryName" kategorisinde $difficultyName zorluk seviyesinde soru bulunamadı.\n\nLütfen başka bir kategori veya zorluk seviyesi seçiniz.',
        ));
        return;
      }
      
      emit(QuizLoaded(
        questions: questions,
        currentQuestion: 0,
        score: 0,
        answers: List.filled(questions.length, ''),
        currentLanguage: event.language,
      ));
    } catch (e) {
      emit(QuizError('Soru yükleme hatası: ${e.toString()}'));
    }
  }

  Future<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      // Set language and restart quiz
      await quizLogic.setLanguage(event.language);
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      emit(QuizLoaded(
        questions: questions,
        currentQuestion: 0,
        score: 0,
        answers: List.filled(questions.length, ''),
        currentLanguage: event.language,
      ));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onAnswerQuestion(
      AnswerQuestion event, Emitter<QuizState> emit) async {
    final currentState = state;
    if (currentState is QuizLoaded) {
      final isCorrect = await quizLogic.checkAnswer(
        currentState.questions[event.questionIndex],
        event.answer,
      );
      List<String> newAnswers = List.from(currentState.answers);
      newAnswers[event.questionIndex] = event.answer;

      // Record wrong answer category for learning improvement
      if (!isCorrect) {
        final question = currentState.questions[event.questionIndex];
        quizLogic.recordWrongAnswer(question.category);
      }

      final newScore = isCorrect ? currentState.score + 1 : currentState.score;

      // Check if this is the last question
      if (event.questionIndex == currentState.questions.length - 1) {
        // Calculate correct answers list
        final correctAnswersList = List<bool>.filled(currentState.questions.length, false);
        for (int i = 0; i < currentState.questions.length; i++) {
          final correctOption = currentState.questions[i].options.firstWhere((o) => o.score > 0);
          correctAnswersList[i] = newAnswers[i] == correctOption.text;
        }
        
        // Emit in-progress state to show loading in UI
        emit(QuizCompletionInProgress(
          questions: currentState.questions,
          score: newScore,
          answers: newAnswers,
          currentLanguage: currentState.currentLanguage,
        ));
        
        // Send completion event to backend
        final userId = FirebaseAuth.instance.currentUser?.uid;
        String? errorMessage;
        
        if (userId != null) {
          final backendSuccess = await GameCompletionService().sendQuizCompletion(
            score: newScore,
            totalQuestions: currentState.questions.length,
            correctAnswers: correctAnswersList.where((a) => a).length,
            timeSpentSeconds: 0, // Will be calculated on the page side
            category: currentState.questions.isNotEmpty 
                ? currentState.questions[0].category 
                : 'General',
            difficulty: currentState.currentLanguage == AppLanguage.turkish 
                ? 'medium' 
                : 'medium',
            answers: newAnswers,
            correctAnswersList: correctAnswersList,
          );
          
          // Even if backend fails, data is saved to offline queue
          // So we can show success if offline
          if (!backendSuccess) {
            errorMessage = 'Veriler kaydedilirken hata oluştu. Lütfen internet bağlantınızı kontrol edin.';
          }
        } else {
          errorMessage = 'Kullanıcı girişi yapılmamış.';
        }
        
        // Always show completion (data is either in Firestore or offline queue)
        emit(QuizCompleted(
          questions: currentState.questions,
          score: newScore,
          answers: newAnswers,
          currentLanguage: currentState.currentLanguage,
        ));
      } else {
        // Continue to next question
        final nextIndex = event.questionIndex + 1;
        emit(QuizLoaded(
          questions: currentState.questions,
          currentQuestion: nextIndex,
          score: newScore,
          answers: newAnswers,
          currentLanguage: currentState.currentLanguage,
        ));
      }
    }
  }

  Future<void> _onRetryQuizCompletion(
      RetryQuizCompletion event, Emitter<QuizState> emit) async {
    final currentState = state;
    if (currentState is QuizCompletionError) {
      // Emit in-progress state
      emit(QuizCompletionInProgress(
        questions: currentState.questions,
        score: currentState.score,
        answers: currentState.answers,
        currentLanguage: currentState.currentLanguage,
      ));
      
      // Calculate correct answers list
      final correctAnswersList = List<bool>.filled(currentState.questions.length, false);
      for (int i = 0; i < currentState.questions.length; i++) {
        final correctOption = currentState.questions[i].options.firstWhere((o) => o.score > 0);
        correctAnswersList[i] = currentState.answers[i] == correctOption.text;
      }
      
      // Retry sending completion event to backend
      final userId = FirebaseAuth.instance.currentUser?.uid;
      bool backendSuccess = false;
      
      if (userId != null) {
        backendSuccess = await GameCompletionService().sendQuizCompletion(
          score: currentState.score,
          totalQuestions: currentState.questions.length,
          correctAnswers: correctAnswersList.where((a) => a).length,
          timeSpentSeconds: 0,
          category: currentState.questions.isNotEmpty 
              ? currentState.questions[0].category 
              : 'General',
          difficulty: 'medium',
          answers: currentState.answers,
          correctAnswersList: correctAnswersList,
        );
      }
      
      if (backendSuccess) {
        // Backend success - show completion screen
        emit(QuizCompleted(
          questions: currentState.questions,
          score: currentState.score,
          answers: currentState.answers,
          currentLanguage: currentState.currentLanguage,
        ));
      } else {
        // Backend still failed - show error again
        emit(QuizCompletionError(
          questions: currentState.questions,
          score: currentState.score,
          answers: currentState.answers,
          errorMessage: 'Tekrar denendi ancak sunucuya kaydedilemedi.',
          currentLanguage: currentState.currentLanguage,
        ));
      }
    }
  }
}
