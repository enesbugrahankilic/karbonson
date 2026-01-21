// lib/pages/quiz_page.dart
// Redesigned with full-width widgets, scroll support, and fixed settings dialog
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
  DifficultyLevel _selectedDifficulty = DifficultyLevel.medium; // quiz_settings_page ile tutarlı
  int _selectedQuestionCount = 15;
  
  // Time tracking
  DateTime? _quizStartTime;
  int _timeSpentSeconds = 0;
  String _difficultyDisplayName = 'Orta';
  bool _completionEventSent = false;

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
      final passedQuestionCount = args?['questionCount'] as int?; // SORU SAYISI ALINIYOR

      if (passedCategory != null) {
        // Use passed values directly
        _selectedCategory = passedCategory;
        if (passedDifficulty != null) {
          _selectedDifficulty = passedDifficulty;
          _difficultyDisplayName = passedDifficulty.displayName;
        }
        if (passedQuestionCount != null) {
          _selectedQuestionCount = passedQuestionCount;
        }
        // Start time tracking
        _quizStartTime = DateTime.now();
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

    // Initialize with first category selected
    if (_selectedCategory == null) {
      _selectedCategory = categories[0];
    }

    final selectedValues = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
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
                                width: (MediaQuery.of(context).size.width - 
                                    2 * DesignSystem.spacingL - 
                                    DesignSystem.spacingS * 2) / 2,
                                child: RadioListTile<String>(
                                  title: Text(category),
                                  value: category,
                                  groupValue: _selectedCategory,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      _selectedCategory = value;
                                    });
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
                                setDialogState(() {
                                  _selectedDifficulty = value!;
                                });
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
                                setDialogState(() {
                                  _selectedQuestionCount = value;
                                });
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
                          // Validate that category is selected
                          if (_selectedCategory == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lütfen bir kategori seçin'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
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
        _difficultyDisplayName = selectedDifficulty.displayName;
        // Start time tracking
        _quizStartTime = DateTime.now();
        context.read<QuizBloc>().add(LoadQuiz(
            category: selectedCategory == 'Tümü' ? null : selectedCategory,
            difficulty: selectedDifficulty,
            questionCount: selectedQuestionCount));
      }
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final navigator = Navigator.of(context);

    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
        title: const Text('Quizden Çıkış'),
        content: const Text(
            'Quizden çıkarsanız, ilerlemeniz kaydedilmeyecek. Devam etmek istiyor musunuz?'),
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

    final progress = totalQuestions > 0 ? currentQuestion / totalQuestions : 0.0;

    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideController),
        child: Column(
          children: [
            // Progress bar
            Container(
              margin: const EdgeInsets.only(bottom: DesignSystem.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme',
                        style: DesignSystem.getBodySmall(context).copyWith(
                          color: ThemeColors.getSecondaryText(context),
                        ),
                      ),
                      Text(
                        '$currentQuestion / $totalQuestions',
                        style: DesignSystem.getBodySmall(context).copyWith(
                          color: ThemeColors.getPrimaryButtonColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacingXs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: ThemeColors.getCardBackground(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeColors.getPrimaryButtonColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Score row
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingM,
                vertical: DesignSystem.spacingS,
              ),
              decoration: BoxDecoration(
                color: ThemeColors.getSuccessColor(context).withOpacity(0.15),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                border: Border.all(
                  color: ThemeColors.getSuccessColor(context).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Puan',
                        style: DesignSystem.getBodySmall(context).copyWith(
                          color: ThemeColors.getSecondaryText(context),
                        ),
                      ),
                      Text(
                        '$score',
                        style: AppTheme.getGameScoreStyle(context).copyWith(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: ThemeColors.getBorder(context).withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        'Soru',
                        style: DesignSystem.getBodySmall(context).copyWith(
                          color: ThemeColors.getSecondaryText(context),
                        ),
                      ),
                      Text(
                        '$currentQuestion / $totalQuestions',
                        style: DesignSystem.getTitleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.getTitleColor(context),
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted)
                    Container(
                      width: 1,
                      height: 40,
                      color: ThemeColors.getBorder(context).withOpacity(0.3),
                    ),
                  if (isCompleted)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, score),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('Bitir',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getSuccessColor(context),
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSystem.spacingM,
                          vertical: DesignSystem.spacingS,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
              title: Text(
                'Soru ${state.currentQuestion + 1}/${state.questions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: DesignSystem.spacingS),
                  decoration: BoxDecoration(
                    color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    onPressed: () => _confirmExit(context),
                    tooltip: 'Oyundan Çık',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Score area at top
                      Padding(
                        padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
                        child: _buildScoreArea(state),
                      ),
                      
                      // Question card with full width
                      FadeTransition(
                        opacity: _fadeController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.2),
                            end: Offset.zero,
                          ).animate(_slideController),
                          child: CustomQuestionCard(
                            question: currentQuestion.text,
                            options: currentQuestion.options
                                .map((o) => o.text)
                                .toList(),
                            onOptionSelected: (answer) =>
                                _onAnswerSelected(answer, state.currentQuestion),
                            isAnswered:
                                state.answers[state.currentQuestion].isNotEmpty,
                            selectedAnswer:
                                state.answers[state.currentQuestion],
                            correctAnswer: currentQuestion.options
                                .firstWhere((o) => o.score > 0)
                                .text,
                            difficulty: _selectedDifficulty,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: DesignSystem.spacingXl),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (state is QuizCompleted) {
          // Completion screen - backend was successful
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Quiz Tamamlandı',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: DesignSystem.spacingS),
                  decoration: BoxDecoration(
                    color: ThemeColors.getSuccessColor(context).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: () => Navigator.pop(context, state.score),
                    tooltip: 'Ana Sayfaya Dön',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Score area at top
                      Padding(
                        padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
                        child: _buildScoreArea(state),
                      ),
                      
                      // Completion message
                      FadeTransition(
                        opacity: _fadeController,
                        child: Container(
                          padding: const EdgeInsets.all(DesignSystem.spacingXl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ThemeColors.getSuccessColor(context).withOpacity(0.1),
                                ThemeColors.getSuccessColor(context).withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                            border: Border.all(
                              color: ThemeColors.getSuccessColor(context).withOpacity(0.3),
                            ),
                          ),
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: DesignSystem.spacingM),
                              Text(
                                'Toplam Puan: ${state.score}/${state.questions.length}',
                                style: AppTheme.getGameScoreStyle(context).copyWith(
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: DesignSystem.spacingL),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context, state.score),
                                icon: const Icon(Icons.home, color: Colors.white),
                                label: const Text('Ana Sayfaya Dön',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeColors.getSuccessColor(context),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DesignSystem.spacingXl,
                                    vertical: DesignSystem.spacingM,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Handle QuizCompletionInProgress state
        if (state is QuizCompletionInProgress) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Kaydediliyor...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: DesignSystem.spacingL),
                      Text(
                        'Quiz sonucunuz kaydediliyor...',
                        style: DesignSystem.getTitleMedium(context).copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignSystem.spacingS),
                      Text(
                        'Lütfen bekleyin',
                        style: DesignSystem.getBodyMedium(context).copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Handle QuizCompletionError state
        if (state is QuizCompletionError) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Hata',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Score area
                      Padding(
                        padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
                        child: _buildScoreArea(state),
                      ),
                      
                      // Error message
                      FadeTransition(
                        opacity: _fadeController,
                        child: Container(
                          padding: const EdgeInsets.all(DesignSystem.spacingXl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.red.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red,
                              ),
                              const SizedBox(height: DesignSystem.spacingL),
                              Text(
                                'Bir Hata Oluştu!',
                                style: AppTheme.getGameQuestionStyle(context).copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: DesignSystem.spacingM),
                              Text(
                                state.errorMessage,
                                style: DesignSystem.getBodyMedium(context).copyWith(
                                  fontSize: 16,
                                  color: ThemeColors.getTitleColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: DesignSystem.spacingL),
                              Text(
                                'Puanınız: ${state.score}/${state.questions.length}',
                                style: AppTheme.getGameScoreStyle(context).copyWith(
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: DesignSystem.spacingXl),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context, state.score),
                                    icon: const Icon(Icons.home, color: Colors.white),
                                    label: const Text('Ana Sayfaya Dön'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DesignSystem.spacingM,
                                        vertical: DesignSystem.spacingS,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context.read<QuizBloc>().add(const RetryQuizCompletion());
                                    },
                                    icon: const Icon(Icons.refresh, color: Colors.white),
                                    label: const Text('Tekrar Dene'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DesignSystem.spacingM,
                                        vertical: DesignSystem.spacingS,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

