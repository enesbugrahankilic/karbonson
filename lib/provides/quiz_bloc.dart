import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/question.dart';
import '../services/quiz_logic.dart';
import '../services/language_service.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuiz extends QuizEvent {
  final AppLanguage language;
  final String? category;

  const LoadQuiz({this.language = AppLanguage.turkish, this.category});

  @override
  List<Object> get props => [language, category ?? ''];
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

// Bloc
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizLogic quizLogic;

  QuizBloc({required this.quizLogic}) : super(QuizInitial()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      // Set language if provided
      await quizLogic.setLanguage(event.language);

      // Start a new quiz and preload questions
      await quizLogic.startNewQuiz(category: event.category);
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

      // Prevent advancing the index past the last question to avoid
      // RangeError when the UI accesses `questions[currentQuestion]`.
      final nextIndex =
          (event.questionIndex + 1) >= currentState.questions.length
              ? currentState.questions.length - 1
              : event.questionIndex + 1;

      emit(QuizLoaded(
        questions: currentState.questions,
        currentQuestion: nextIndex,
        score: isCorrect ? currentState.score + 1 : currentState.score,
        answers: newAnswers,
        currentLanguage: currentState.currentLanguage,
      ));
    }
  }
}
