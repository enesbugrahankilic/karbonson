
// lib/pages/quiz_page.dart
// Updated to use Design System for consistent styling
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/quiz_logic.dart';
import '../provides/quiz_bloc.dart';
import '../widgets/custom_question_card.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';

class QuizPage extends StatefulWidget {
  final QuizLogic quizLogic;

  const QuizPage({super.key, required this.quizLogic});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  bool _didLoadQuiz = false;
  String? _selectedCategory;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.easy;
  int _selectedQuestionCount = 15;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadQuiz) {
      _didLoadQuiz = true;

      // Check if category was passed as argument
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final passedCategory = args?['category'] as String?;
      final passedDifficulty = args?['difficulty'] as DifficultyLevel?;

      if (passedCategory != null) {
        // Use passed category directly
        _selectedCategory = passedCategory;
        if (passedDifficulty != null) {
          _selectedDifficulty = passedDifficulty;
        }
        context.read<QuizBloc>().add(LoadQuiz(
            category: passedCategory == 'Tümü' ? null : passedCategory,
            difficulty: passedDifficulty ?? _selectedDifficulty,
            questionCount: _selectedQuestionCount));
      } else {
        // Show category selection dialog
        _showCategorySelection();
      }
    }
  }

  Future<void> _showCategorySelection() async {
    final categories = [
      'Tümü',
      'Enerji',
      'Su',
      'Orman',
      'Geri Dönüşüm',
      'Ulaşım',
      'Tüketim'
    ];

    final difficulties = [
      DifficultyLevel.easy,
      DifficultyLevel.medium,
      DifficultyLevel.hard,
    ];

    final selectedValues = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignSystem.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quiz Ayarları',
                  style: DesignSystem.getHeadlineSmall(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spacingL),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori Seçin:',
                          style: DesignSystem.getTitleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacingS),
                        Wrap(
                          spacing: DesignSystem.spacingS,
                          runSpacing: DesignSystem.spacingS,
                          children: categories.map((category) {
                            return SizedBox(
                              width: (MediaQuery.of(context).size.width - 2 * DesignSystem.spacingL - DesignSystem.spacingS) / 2,
                              child: RadioListTile<String>(
                                title: Text(category),
                                value: category,
                                groupValue: _selectedCategory,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(),
                        Text(
                          'Zorluk Seviyesi Seçin:',
                          style: DesignSystem.getTitleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacingS),
                        ...difficulties.map((difficulty) {
                          return RadioListTile<DifficultyLevel>(
                            title: Text(difficulty.displayName),
                            value: difficulty,
                            groupValue: _selectedDifficulty,
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                        const Divider(),
                        Text(
                          'Soru Sayısı Seçin:',
                          style: DesignSystem.getTitleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: DesignSystem.spacingS),
                        DropdownButtonFormField<int>(
                          value: _selectedQuestionCount,
                          decoration: InputDecoration(
                            labelText: 'Soru Sayısı',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 5, child: Text('5 Soru (2-3 dakika)')),
                            DropdownMenuItem(value: 10, child: Text('10 Soru (~5 dakika)')),
                            DropdownMenuItem(value: 15, child: Text('15 Soru (~7-8 dakika)')),
                            DropdownMenuItem(value: 20, child: Text('20 Soru (~10-12 dakika)')),
                            DropdownMenuItem(value: 25, child: Text('25 Soru (~12-15 dakika)')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedQuestionCount = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: DesignSystem.spacingM),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'category': _selectedCategory,
                          'difficulty': _selectedDifficulty,
                          'questionCount': _selectedQuestionCount,
                        });
                      },
                      child: const Text('Başla'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selectedValues != null && mounted) {
      final selectedCategory = selectedValues['category'] as String?;
      final selectedDifficulty = selectedValues['difficulty'] as DifficultyLevel?;
      final selectedQuestionCount = selectedValues['questionCount'] as int? ?? 15;

      if (selectedCategory != null && selectedDifficulty != null) {
        _selectedCategory = selectedCategory;
        _selectedDifficulty = selectedDifficulty;
        _selectedQuestionCount = selectedQuestionCount;
        context.read<QuizBloc>().add(LoadQuiz(
            category: selectedCategory == 'Tümü' ? null : selectedCategory,
            difficulty: selectedDifficulty,
            questionCount: selectedQuestionCount));
      }
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    // Capture navigator before awaiting dialog to avoid using BuildContext after await
    final navigator = Navigator.of(context);

    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => DesignSystem.semantic(
        context,
        label: 'Quiz çıkış onay dialog',
        hint:
            'Quizden çıkmak istediğinizi onaylamanız gerektiğini belirten dialog',
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
          title: DesignSystem.semantic(
            context,
            label: 'Quizden Çıkış başlığı',
            child: const Text('Quizden Çıkış'),
          ),
          content: DesignSystem.semantic(
            context,
            label: 'Dialog içeriği',
            child: const Text(
                'Quizden çıkarsanız, ilerlemeniz kaydedilmeyecek. Devam etmek istiyor musunuz?'),
          ),
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

  Widget _buildScoreArea(dynamic state) {
    int score = 0;
    int currentQuestion = 0;
    int totalQuestions = 0;
    bool isCompleted = false;

    if (state is QuizLoaded) {
      score = state.score;
      currentQuestion = state.currentQuestion + 1;
      totalQuestions = state.questions.length;
      isCompleted = false;
    } else if (state is QuizCompleted) {
      score = state.score;
      currentQuestion = state.questions.length;
      totalQuestions = state.questions.length;
      isCompleted = true;
    }

    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideController),
        child: DesignSystem.card(
          context,
          backgroundColor:
              ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
          child: Column(
            children: [
              Text(
                'Puan: $score',
                style: AppTheme.getGameScoreStyle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: DesignSystem.spacingS),
              Text(
                'Soru $currentQuestion/$totalQuestions',
                style: DesignSystem.getTitleMedium(context).copyWith(
                  color: ThemeColors.getTitleColor(context),
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black12,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: DesignSystem.spacingM),
              if (isCompleted)
                AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fadeController.value,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, score),
                        icon:
                            const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('Quizi Bitir',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        style: DesignSystem.getPrimaryButtonStyle(context),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        if (state is QuizLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ThemeColors.getGradientColors(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: DesignSystem.loadingIndicator(context,
                  message: 'Quiz yükleniyor...'),
            ),
          );
        }

        if (state is QuizError) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ThemeColors.getGradientColors(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: DesignSystem.errorState(
                context,
                message: 'Error: ${state.message}',
                onRetry: () {
                  context.read<QuizBloc>().add(LoadQuiz(
                      category: _selectedCategory == 'Tümü'
                          ? null
                          : _selectedCategory));
                },
                retryText: 'Tekrar Dene',
              ),
            ),
          );
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
                Container(
                  margin: const EdgeInsets.only(right: DesignSystem.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                  child: DesignSystem.semantic(
                    context,
                    label: 'Çıkış butonu',
                    hint: 'Quizden çıkmak için kullanılır',
                    child: IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      onPressed: () => _confirmExit(context),
                      tooltip: 'Oyundan Çık',
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ThemeColors.getGradientColors(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Puan alanını üst kısımda sabit tut
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0),
                          vertical: isSmallScreen ? 8.0 : 12.0),
                      child: _buildScoreArea(state),
                    ),
                    // Soru kartını kalan alanda genişlet
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0),
                            vertical: isSmallScreen ? 8.0 : 12.0),
                        child: FadeTransition(
                          opacity: _fadeController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_slideController),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: DesignSystem.glassCard(
                                context,
                                child: CustomQuestionCard(
                                  question: currentQuestion.text,
                                  options: currentQuestion.options
                                      .map((o) => o.text)
                                      .toList(),
                                  onOptionSelected: (answer) => _onAnswerSelected(
                                      answer, state.currentQuestion),
                                  isAnswered: state
                                      .answers[state.currentQuestion].isNotEmpty,
                                  selectedAnswer:
                                      state.answers[state.currentQuestion],
                                  correctAnswer: currentQuestion.options
                                      .firstWhere((o) => o.score > 0)
                                      .text,
                                  difficulty: _selectedDifficulty,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is QuizCompleted) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: DesignSystem.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                  child: DesignSystem.semantic(
                    context,
                    label: 'Çıkış butonu',
                    hint: 'Quizden çıkmak için kullanılır',
                    child: IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      onPressed: () => Navigator.pop(context, state.score),
                      tooltip: 'Ana Sayfaya Dön',
                    ),
                  ),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ThemeColors.getGradientColors(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Puan alanını üst kısımda sabit tut
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0),
                          vertical: isSmallScreen ? 8.0 : 12.0),
                      child: _buildScoreArea(state),
                    ),
                    // Tamamlanma mesajını kalan alanda ortala
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0)),
                          child: FadeTransition(
                            opacity: _fadeController,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: DesignSystem.glassCard(
                                context,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.celebration,
                                      size: 80,
                                      color: ThemeColors.getSuccessColor(context),
                                    ),
                                    const SizedBox(height: DesignSystem.spacingL),
                                    Text(
                                      'Quiz Tamamlandı!',
                                      style: AppTheme.getGameQuestionStyle(context).copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: DesignSystem.spacingM),
                                    Text(
                                      'Toplam Puan: ${state.score}/${state.questions.length}',
                                      style: AppTheme.getGameScoreStyle(context).copyWith(
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: DesignSystem.spacingL),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ThemeColors.getGradientColors(context),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: DesignSystem.emptyState(
              context,
              message: 'Beklenmeyen durum',
              icon: Icons.error_outline,
            ),
          ),
        );
      },
    );
  }


}
