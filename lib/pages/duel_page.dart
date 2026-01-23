import 'package:flutter/material.dart';
import '../models/question.dart';
import '../data/questions_database.dart';
import '../enums/app_language.dart';
import '../widgets/page_templates.dart';

class DuelPage extends StatefulWidget {
  final String? roomId;
  final String? opponentId;

  const DuelPage({super.key, this.roomId, this.opponentId});

  @override
  State<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends State<DuelPage> with TickerProviderStateMixin {
  late AnimationController _answerAnimationController;
   
  int _playerScore = 0;
  final int _opponentScore = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;
  int _questionNumber = 0;
  int _totalQuestions = 0;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _questions = QuestionsDatabase.getRandomQuestions(AppLanguage.turkish, 10);
    _totalQuestions = _questions.length;
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _answerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: StandardAppBar(
          title: const Text('Düello'),
          onBackPressed: _showExitDialog,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '$_questionNumber/$_totalQuestions',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
        body: PageBody(
          child: _questionNumber < _totalQuestions
              ? _buildQuestionUI()
              : _buildGameOverUI(),
        ),
      ),
    );
  }

  Widget _buildQuestionUI() {
    return FutureBuilder<Question?>(
      future: _getNextQuestion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text('Soru yüklenirken hata: ${snapshot.error}'));
        }

        final question = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        question.text,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._buildAnswerButtons(question),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildScoreCard('Benim', _playerScore),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScoreCard('Rakip', _opponentScore),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildAnswerButtons(Question question) {
    return (question.shuffledOptions)
        .map((option) {
      final isCorrect = option.isCorrect;
      final isSelected = _selectedAnswer == option.text;

      Color? backgroundColor;
      if (_isAnswered && isSelected) {
        backgroundColor = isCorrect ? Colors.green : Colors.red;
      } else if (_isAnswered && isCorrect) {
        backgroundColor = Colors.green;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: backgroundColor ?? Colors.blue,
                  width: isSelected ? 2 : 1,
                ),
              ),
            ),
            onPressed: _isAnswered ? null : () => _selectAnswer(option.text, isCorrect),
            child: Text(option.text, style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildScoreCard(String label, int score) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(score.toString(),
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverUI() {
    final playerWon = _playerScore > _opponentScore;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            playerWon ? Icons.emoji_events : Icons.thumb_down,
            size: 80,
            color: playerWon ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(playerWon ? 'Kazandınız!' : 'Kaybettiniz',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Siz: $_playerScore - Rakip: $_opponentScore',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anasayfaya Dön'),
          ),
        ],
      ),
    );
  }

  Future<Question?> _getNextQuestion() async {
    try {
      if (_questionNumber < _questions.length) {
        return _questions[_questionNumber];
      }
      return null;
    } catch (e) {
      debugPrint('Error getting question: $e');
      return null;
    }
  }

  void _selectAnswer(String option, bool isCorrect) {
    setState(() {
      _selectedAnswer = option;
      _isAnswered = true;

      if (isCorrect) {
        _playerScore += 10;
      }
    });

    _answerAnimationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _questionNumber++;
            _isAnswered = false;
            _selectedAnswer = null;
            _answerAnimationController.reset();
          });
        }
      });
    });
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Düellodan Çık'),
        content: const Text('Emin misiniz? Oyun sona erecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Devam Et'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

