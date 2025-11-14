// lib/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/quiz_logic.dart';
import '../models/question.dart';
import '../providers/quiz_bloc.dart';
import '../widgets/custom_question_card.dart';

class QuizPage extends StatefulWidget {
  final String userNickname;
  final QuizLogic quizLogic;

  const QuizPage({super.key, required this.userNickname, required this.quizLogic});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    context.read<QuizBloc>().add(LoadQuiz());
  }

  Future<void> _confirmExit(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quizden Çıkış'),
        content: const Text('Quizden çıkarsanız, ilerlemeniz kaydedilmeyecek. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Çık'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      Navigator.pop(context);
    }
  }

  void _onAnswerSelected(String answer, int questionIndex) {
    context.read<QuizBloc>().add(AnswerQuestion(answer, questionIndex));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        if (state is QuizLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is QuizError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is QuizLoaded) {
          final currentQuestion = state.questions[state.currentQuestion];
          final isLastQuestion = state.currentQuestion == state.questions.length - 1;
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quiz Zamanı!'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => _confirmExit(context),
                  tooltip: 'Oyundan Çık',
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: CustomQuestionCard(
                    question: currentQuestion.text,
                    options: currentQuestion.options.map((o) => o.text).toList(),
                    onOptionSelected: (answer) => _onAnswerSelected(answer, state.currentQuestion),
                    isAnswered: state.answers[state.currentQuestion].isNotEmpty,
                    selectedAnswer: state.answers[state.currentQuestion],
                    correctAnswer: currentQuestion.options
                        .firstWhere((o) => o.score > 0)
                        .text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Puan: ${state.score}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Soru ${state.currentQuestion + 1}/${state.questions.length}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (isLastQuestion && state.answers[state.currentQuestion].isNotEmpty)
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, state.score),
                          child: const Text('Quizi Bitir'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Beklenmeyen durum'));
      },
    );
  }
}