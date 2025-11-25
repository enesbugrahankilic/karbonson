// lib/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/quiz_logic.dart';
import '../provides/quiz_bloc.dart';
import '../widgets/custom_question_card.dart';

class QuizPage extends StatefulWidget {
  final String userNickname;
  final QuizLogic quizLogic;

  const QuizPage({super.key, required this.userNickname, required this.quizLogic});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _didLoadQuiz = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadQuiz) {
      _didLoadQuiz = true;
      context.read<QuizBloc>().add(LoadQuiz());
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    // Capture navigator before awaiting dialog to avoid using BuildContext after await
    final navigator = Navigator.of(context);

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

    if (!mounted) return;

    if (shouldExit == true) {
      navigator.pop();
    }
  }

  void _onAnswerSelected(String answer, int questionIndex) {
    context.read<QuizBloc>().add(AnswerQuestion(answer, questionIndex));
  }

  Widget _buildScoreArea(QuizLoaded state) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            Text(
              'Puan: ${state.score}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Soru ${state.currentQuestion + 1}/${state.questions.length}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (state.currentQuestion == state.questions.length - 1 && state.answers[state.currentQuestion].isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, state.score),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Quizi Bitir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => _confirmExit(context),
                  tooltip: 'Oyundan Çık',
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        color: Color.fromRGBO(255, 255, 255, 0.97),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
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
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                    child: _buildScoreArea(state),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('Beklenmeyen durum'));
      },
    );
  }
}