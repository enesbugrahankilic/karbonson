import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/question.dart';
import '../services/quiz_logic.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuiz extends QuizEvent {}
class AnswerQuestion extends QuizEvent {
  final String answer;
  final int questionIndex;

  const AnswerQuestion(this.answer, this.questionIndex);

  @override
  List<Object> get props => [answer, questionIndex];
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

  const QuizLoaded({
    required this.questions,
    required this.currentQuestion,
    required this.score,
    required this.answers,
  });

  @override
  List<Object> get props => [questions, currentQuestion, score, answers];
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
  }

  Future<void> _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      // Start a new quiz and preload questions
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      emit(QuizLoaded(
        questions: questions,
        currentQuestion: 0,
        score: 0,
        answers: List.filled(questions.length, ''),
      ));
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) async {
    final currentState = state;
    if (currentState is QuizLoaded) {
      final isCorrect = await quizLogic.checkAnswer(
        currentState.questions[event.questionIndex],
        event.answer,
      );
      List<String> newAnswers = List.from(currentState.answers);
      newAnswers[event.questionIndex] = event.answer;

      // Prevent advancing the index past the last question to avoid
      // RangeError when the UI accesses `questions[currentQuestion]`.
      final nextIndex = (event.questionIndex + 1) >= currentState.questions.length
          ? currentState.questions.length - 1
          : event.questionIndex + 1;

      emit(QuizLoaded(
        questions: currentState.questions,
        currentQuestion: nextIndex,
        score: isCorrect ? currentState.score + 1 : currentState.score,
        answers: newAnswers,
      ));
    }
  }
}