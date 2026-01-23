import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/page_templates.dart';
import '../widgets/quiz_layout.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../services/duel_game_logic.dart';
import '../services/firestore_service.dart';
import '../services/authentication_state_service.dart';
import '../models/question.dart';

class DuelPage extends StatefulWidget {
  final String? roomId;
  final String? opponentId;

  const DuelPage({super.key, this.roomId, this.opponentId});

  @override
  State<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends State<DuelPage> with TickerProviderStateMixin {
  final DuelGameLogic _duelGameLogic = DuelGameLogic();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthenticationStateService _authStateService = AuthenticationStateService();

  late AnimationController _answerAnimationController;
  late AnimationController _timerAnimationController;

  String? _currentPlayerId;
  String? _currentPlayerNickname;
  bool _isLoading = true;
  String? _errorMessage;

  // Timer for question
  Timer? _questionTimer;
  int _timeLeft = DuelGameLogic.questionTimeLimit;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDuel();
  }

  void _initializeAnimations() {
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: DuelGameLogic.questionTimeLimit),
      vsync: this,
    );
  }

  Future<void> _initializeDuel() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current player info
      _currentPlayerId = await _authStateService.getGamePlayerId();
      _currentPlayerNickname = await _authStateService.getGameNickname();

      if (widget.roomId != null && _currentPlayerId != null) {
        // Join existing multiplayer duel
        final room = await _firestoreService.joinDuelRoomByCode(
          widget.roomId!,
          _currentPlayerId!,
          _currentPlayerNickname ?? 'Oyuncu',
        );

        if (room != null) {
          await _duelGameLogic.initializeDuelRoom(room, _currentPlayerId!);
        } else {
          setState(() {
            _errorMessage = 'Odaya katılamadı';
            _isLoading = false;
          });
          return;
        }
      } else {
        // Single player mode - create a mock room for now
        // In a real implementation, this would create a room and wait for opponent
        setState(() {
          _errorMessage = 'Çoklu oyuncu modu gerekli';
          _isLoading = false;
        });
        return;
      }

      // Listen to game logic changes
      _duelGameLogic.addListener(_onGameStateChanged);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing duel: $e');
      setState(() {
        _errorMessage = 'Düello başlatılırken hata: $e';
        _isLoading = false;
      });
    }
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _duelGameLogic.removeListener(_onGameStateChanged);
    _duelGameLogic.dispose();
    _answerAnimationController.dispose();
    _timerAnimationController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return QuizLayout(
        title: 'Düello',
        subtitle: 'Yükleniyor...',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return QuizLayout(
        title: 'Düello',
        subtitle: 'Hata',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: ThemeColors.getErrorColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: DesignSystem.getBodyLarge(context).copyWith(
                  color: ThemeColors.getErrorColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: DesignSystem.getPrimaryButtonStyle(context),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    final room = _duelGameLogic.currentRoom;
    if (room == null) {
      return QuizLayout(
        title: 'Düello',
        subtitle: 'Oda bulunamadı',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        child: const Center(child: Text('Oda bulunamadı')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: QuizLayout(
        title: 'Düello',
        subtitle: '${room.players.length} oyuncu • Tur ${room.currentQuestionIndex + 1}/${DuelGameLogic.totalQuestions}',
        showBackButton: true,
        onBackPressed: _showExitDialog,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _showExitDialog,
            tooltip: 'Oyundan Çık',
          ),
        ],
        child: _buildGameContent(),
      ),
    );
  }

  Widget _buildGameContent() {
    final room = _duelGameLogic.currentRoom!;
    final currentQuestion = _duelGameLogic.currentQuestion;

    if (room.isGameFinished) {
      return _buildGameFinishedUI();
    }

    if (currentQuestion == null) {
      return _buildWaitingForQuestionUI();
    }

    return Column(
      children: [
        // Question header with timer
        _buildQuestionHeader(),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Question text
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    currentQuestion.text,
                    style: DesignSystem.getHeadlineSmall(context).copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Answer options
                ..._buildAnswerButtons(currentQuestion),
              ],
            ),
          ),
        ),

        // Players scores
        _buildPlayersScores(),
      ],
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
            ThemeColors.getAccentButtonColor(context).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(DesignSystem.radiusL),
          bottomRight: Radius.circular(DesignSystem.radiusL),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Question counter
          Text(
            'Soru ${_duelGameLogic.currentQuestionIndex + 1}/${DuelGameLogic.totalQuestions}',
            style: DesignSystem.getTitleMedium(context).copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
          ),

          // Timer
          Row(
            children: [
              Icon(
                Icons.timer,
                color: _timeLeft <= 5 ? Colors.red : ThemeColors.getText(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _timeLeft.toString(),
                style: DesignSystem.getTitleLarge(context).copyWith(
                  color: _timeLeft <= 5 ? Colors.red : ThemeColors.getText(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerButtons(Question question) {
    return question.shuffledOptions.map((option) {
      final isSelected = false; // We'll track this in game logic
      final isCorrect = option.isCorrect;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getCardBackground(context),
              foregroundColor: ThemeColors.getText(context),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
            ),
            onPressed: _duelGameLogic.isGameActive && _currentPlayerId != null
                ? () => _submitAnswer(option.text)
                : null,
            child: Text(
              option.text,
              style: DesignSystem.getBodyLarge(context).copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPlayersScores() {
    final room = _duelGameLogic.currentRoom!;
    final currentPlayer = room.players.firstWhere(
      (p) => p.id == _currentPlayerId,
      orElse: () => room.players[0],
    );
    final opponent = room.players.firstWhere(
      (p) => p.id != _currentPlayerId,
      orElse: () => room.players.length > 1 ? room.players[1] : room.players[0],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignSystem.radiusL),
          topRight: Radius.circular(DesignSystem.radiusL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPlayerScoreCard('Siz', currentPlayer.duelScore, true),
          ),
          Container(
            width: 1,
            height: 40,
            color: ThemeColors.getBorder(context),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: _buildPlayerScoreCard('Rakip', opponent.duelScore, false),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScoreCard(String label, int score, bool isCurrentPlayer) {
    return Column(
      children: [
        Text(
          label,
          style: DesignSystem.getBodyMedium(context).copyWith(
            color: ThemeColors.getSecondaryText(context),
            fontWeight: isCurrentPlayer ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: DesignSystem.getDisplaySmall(context).copyWith(
            color: isCurrentPlayer
                ? ThemeColors.getPrimaryButtonColor(context)
                : ThemeColors.getText(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForQuestionUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DesignSystem.modernProgressIndicator(context),
          const SizedBox(height: 24),
          Text(
            'Sonraki soru hazırlanıyor...',
            style: DesignSystem.getBodyLarge(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameFinishedUI() {
    final room = _duelGameLogic.currentRoom!;
    final currentPlayer = room.players.firstWhere((p) => p.id == _currentPlayerId);
    final opponent = room.players.firstWhere((p) => p.id != _currentPlayerId);

    final playerWon = currentPlayer.duelScore > opponent.duelScore;
    final isDraw = currentPlayer.duelScore == opponent.duelScore;

    String resultText;
    IconData resultIcon;
    Color resultColor;

    if (isDraw) {
      resultText = 'Beraberlik!';
      resultIcon = Icons.handshake;
      resultColor = Colors.orange;
    } else if (playerWon) {
      resultText = 'Kazandınız!';
      resultIcon = Icons.emoji_events;
      resultColor = Colors.amber;
    } else {
      resultText = 'Kaybettiniz';
      resultIcon = Icons.thumb_down;
      resultColor = Colors.grey;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              resultIcon,
              size: 80,
              color: resultColor,
            ),
            const SizedBox(height: 24),
            Text(
              resultText,
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ThemeColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Skor',
                    style: DesignSystem.getTitleMedium(context).copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Siz',
                            style: DesignSystem.getBodyMedium(context).copyWith(
                              color: ThemeColors.getSecondaryText(context),
                            ),
                          ),
                          Text(
                            currentPlayer.duelScore.toString(),
                            style: DesignSystem.getDisplaySmall(context).copyWith(
                              color: ThemeColors.getPrimaryButtonColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: ThemeColors.getBorder(context),
                      ),
                      Column(
                        children: [
                          Text(
                            'Rakip',
                            style: DesignSystem.getBodyMedium(context).copyWith(
                              color: ThemeColors.getSecondaryText(context),
                            ),
                          ),
                          Text(
                            opponent.duelScore.toString(),
                            style: DesignSystem.getDisplaySmall(context).copyWith(
                              color: ThemeColors.getText(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getSecondaryButtonColor(context),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ana Sayfa'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Restart game logic would go here
                      Navigator.pop(context);
                    },
                    style: DesignSystem.getPrimaryButtonStyle(context),
                    child: const Text('Yeni Oyun'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer(String answer) async {
    if (_currentPlayerId == null || !_duelGameLogic.isGameActive) return;

    try {
      await _duelGameLogic.submitAnswer(answer, _currentPlayerId!);

      // Show answer feedback animation
      await _answerAnimationController.forward();
      await _answerAnimationController.reverse();

    } catch (e) {
      if (kDebugMode) debugPrint('Error submitting answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cevap gönderilirken hata: $e'),
          backgroundColor: ThemeColors.getErrorColor(context),
        ),
      );
    }
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        ),
        backgroundColor: ThemeColors.getDialogBackground(context),
        title: Text(
          'Düellodan Çık',
          style: DesignSystem.getHeadlineSmall(context).copyWith(
            color: ThemeColors.getText(context),
          ),
        ),
        content: Text(
          'Oyundan çıkmak istediğinizden emin misiniz? İlerleme kaydedilmeyecektir.',
          style: DesignSystem.getBodyMedium(context).copyWith(
            color: ThemeColors.getText(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Devam Et',
              style: DesignSystem.getLabelLarge(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await _duelGameLogic.leaveDuelRoom();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getErrorColor(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

