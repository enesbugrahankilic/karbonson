// lib/pages/board_game_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;
import '../services/game_logic.dart';
import '../services/multiplayer_game_logic.dart';
import '../services/authentication_state_service.dart';
import '../models/game_board.dart';
import 'quiz_page.dart';
import 'leaderboard_page.dart';
import '../services/firestore_service.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';
import 'login_page.dart';

class BoardGamePage extends StatefulWidget {
  final String? userNickname;
  final bool isMultiplayer;
  final String? roomId;
  final String? playerId;

  const BoardGamePage({super.key, this.userNickname})
      : isMultiplayer = false,
        roomId = null,
        playerId = null;

  const BoardGamePage.multiplayer({
    super.key,
    this.userNickname,
    required String this.roomId,
    required String this.playerId,
  }) : isMultiplayer = true;

  @override
  State<BoardGamePage> createState() => _BoardGamePageState();
}

class _BoardGamePageState extends State<BoardGamePage> with TickerProviderStateMixin {
  late AnimationController _diceAnimationController;
  late Animation<double> _diceRotationAnimation;
  String? _notificationMessage;
  Color? _notificationColor;
  bool _scoreSaved = false;
  bool _endGameDialogShown = false;
  final AuthenticationStateService _authStateService = AuthenticationStateService();

  /// Get nickname from parameter or global authentication state
  Future<String> _getGameNickname() async {
    if (widget.userNickname != null && widget.userNickname!.isNotEmpty) {
      return widget.userNickname!;
    }
    return await _authStateService.getGameNickname();
  }

  @override
  void initState() {
    super.initState();
    _endGameDialogShown = false;
    _diceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _diceRotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi * 5).animate(
      CurvedAnimation(parent: _diceAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _diceAnimationController.dispose();
    super.dispose();
  }

  void _showTopNotification(String message, {Color color = Colors.blue, Duration duration = const Duration(seconds: 3)}) {
    setState(() {
      _notificationMessage = message;
      _notificationColor = color;
    });
    Future.delayed(duration, () {
      if (mounted) {
        setState(() {
          _notificationMessage = null;
          _notificationColor = null;
        });
      }
    });
  }

  // Quiz penceresini açar
  Future<void> _startQuiz(NavigatorState navigator, ScaffoldMessengerState messenger, dynamic gameLogic) async {
    gameLogic.quizLogic.startNewQuiz();
    gameLogic.setIsQuizActive(true);
    final resultScore = await navigator.push<int>(
      MaterialPageRoute(
        builder: (context) => QuizPage(
          quizLogic: gameLogic.quizLogic,
        ),
      ),
    );

    if (!mounted) return;

    if (resultScore != null) {
      final message = gameLogic.onQuizFinished(resultScore, gameLogic.currentPlayer!);
      _showTopNotification('Puan: $resultScore. \n$message', color: Colors.green);
    } else {
      gameLogic.setIsQuizActive(false);
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    // Capture navigator before awaiting dialog to avoid using BuildContext across async gaps
    final navigator = Navigator.of(context);

    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyundan Çıkış'),
        content: const Text('Ana sayfaya dönmek istediğinizden emin misiniz? Mevcut oyun skorunuz kaydedilmeyecektir.'),
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
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showEndGameDialog(BuildContext context, dynamic gameLogic) async {
    if (widget.isMultiplayer) {
      // Multiplayer end game logic
      final currentPlayer = gameLogic.currentPlayer;
      if (currentPlayer != null && !_scoreSaved) {
        final finalScore = currentPlayer.quizScore;
        final totalScore = finalScore - (gameLogic.timeElapsedInSeconds ~/ 10);

        final saveMessage = await FirestoreService().saveUserScore(currentPlayer.nickname, totalScore);
        _scoreSaved = true;

        // Save to profile statistics (isWin = true if totalScore > 0)
        await ProfileService().addGameResult(
          score: finalScore,
          isWin: totalScore > 0,
          gameType: 'multiplayer',
        );

        // Check if in top 10
        bool isInTop10 = false;
        if (saveMessage == 'Skor kaydedildi.') {
          final leaderboard = await FirestoreService().getLeaderboard();
          final playerIndex = leaderboard.indexWhere((entry) => entry['nickname'] == currentPlayer.nickname && entry['score'] == totalScore);
          if (playerIndex != -1 && playerIndex < 10) {
            isInTop10 = true;
          }
        }

        if (!mounted) return;

        // Use a fresh context if available, fallback to captured context
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: '',
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation1, animation2) => Container(),
          transitionBuilder: (BuildContext dialogContext, Animation<double> animation1, Animation<double> animation2, Widget child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: animation1, curve: Curves.elasticOut)),
              child: FadeTransition(
                opacity: animation1,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Text('ÇOK OYUNCULU OYUN BİTTİ! ', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 24)),
                      AnimatedScale(
                        scale: animation1.value,
                        duration: const Duration(milliseconds: 300),
                        child: const Text('🎉', style: TextStyle(fontSize: 30)),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tebrikler ${currentPlayer.nickname}!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Geçen Süre: ${gameLogic.timeElapsedFormatted}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Toplam Quiz Puanı: ${currentPlayer.quizScore}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            'Oyun Sonu Skoru: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '$totalScore',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                      Text(
                        saveMessage,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ... (isInTop10 ? [Text(
                        '🏆 Tebrikler! İlk 10\'a girdiniz!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      )] : []),
                      const SizedBox(height: 16),
                      const Text(
                        'Oyuncu Skorları:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ...gameLogic.currentRoom.players.map((player) => Text(
                        '${player.nickname}: ${player.quizScore} puan',
                        style: const TextStyle(fontSize: 14),
                      )),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LeaderboardPage(currentPlayerNickname: currentPlayer.nickname)),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Liderlik Tablosunu Gör', style: TextStyle(color: Color(0xFF1E88E5), fontSize: 18)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } else {
      // Single-player end game logic
      final finalScore = gameLogic.player.quizScore;
      final totalScore = finalScore - (gameLogic.timeElapsedInSeconds ~/ 10);

      String saveMessage = '';
      if (!_scoreSaved) {
        saveMessage = await FirestoreService().saveUserScore(gameLogic.player.nickname, totalScore);
        _scoreSaved = true;

        // Save to profile statistics (isWin = true if totalScore > 0)
        await ProfileService().addGameResult(
          score: finalScore,
          isWin: totalScore > 0,
          gameType: 'single_player',
        );
      }

      // Check if in top 10
      bool isInTop10 = false;
      if (saveMessage == 'Skor kaydedildi.') {
        final leaderboard = await FirestoreService().getLeaderboard();
        final playerIndex = leaderboard.indexWhere((entry) => entry['nickname'] == gameLogic.player.nickname && entry['score'] == totalScore);
        if (playerIndex != -1 && playerIndex < 10) {
          isInTop10 = true;
        }
      }

      if (!mounted) return;

      // Use a fresh context if available, fallback to captured context
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation1, animation2) => Container(),
        transitionBuilder: (BuildContext dialogContext, Animation<double> animation1, Animation<double> animation2, Widget child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: animation1, curve: Curves.elasticOut)),
            child: FadeTransition(
              opacity: animation1,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    const Text('OYUN BİTTİ! ', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 24)),
                    AnimatedScale(
                      scale: animation1.value,
                      duration: const Duration(milliseconds: 300),
                      child: const Text('🎉', style: TextStyle(fontSize: 30)),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tebrikler ${gameLogic.player.nickname}!',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Geçen Süre: ${gameLogic.timeElapsedFormatted}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Toplam Quiz Puanı: ${gameLogic.player.quizScore}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        Text(
                          'Oyun Sonu Skoru: ',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '$totalScore',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                    Text(
                      saveMessage,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ...[if (isInTop10)
                      Text(
                        '🏆 Tebrikler! İlk 10\'a girdiniz!',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      )],
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LeaderboardPage(currentPlayerNickname: gameLogic.player.nickname)),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text('Liderlik Tablosunu Gör', style: TextStyle(color: Color(0xFF1E88E5), fontSize: 18)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Future<void> _initializeMultiplayerGame(BuildContext context, MultiplayerGameLogic gameLogic) async {
    _endGameDialogShown = false; // Reset flag for new game
    final firestoreService = FirestoreService();
    final room = await firestoreService.listenToRoom(widget.roomId!).first;

    if (room != null && mounted) {
      gameLogic.initializeRoom(room, widget.playerId!);
    }
  }

  Widget _buildGameUI(BuildContext context, dynamic gameLogic, {required bool isMultiplayer}) {
    if (gameLogic.isGameFinished && !_endGameDialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _endGameDialogShown) return;
        _endGameDialogShown = true;
        _showEndGameDialog(context, gameLogic);
      });
      return Container();
    }

    final currentTile = gameLogic.board.tiles[gameLogic.currentPlayer!.position];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => _confirmExit(context),
            tooltip: 'Oyundan Çık',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_notificationMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: _notificationColor,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _notificationMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - kToolbarHeight - 36, // Account for app bar and padding
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.isMultiplayer)
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            color: ThemeColors.getPlayerInfoCardBackground(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                              child: ListTile(
                                leading: const Icon(Icons.person, color: Color(0xFF1E88E5), size: 32),
                                title: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Oyuncu: ${gameLogic.player.nickname}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.timer, color: Colors.black54, size: 20),
                                        const SizedBox(width: 4),
                                        Text(gameLogic.timeElapsedFormatted, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeColors.getGameTimeText(context))),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Text('Quiz Puanı: ${gameLogic.player.quizScore}', style: const TextStyle(fontSize: 16)),
                                trailing: gameLogic.player.turnsToSkip > 0
                                    ? Text('PAS TUR: ${gameLogic.player.turnsToSkip}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16))
                                    : null,
                              ),
                            ),
                          )
                        else
                          Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            color: ThemeColors.getPlayerInfoCardBackground(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.timer, color: Colors.black54, size: 20),
                                      const SizedBox(width: 4),
                                      Text(gameLogic.timeElapsedFormatted, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeColors.getGameTimeText(context))),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ...gameLogic.currentRoom.players.map((player) {
                                    final isCurrentPlayer = player.id == gameLogic.currentPlayer?.id;
                                    final isCurrentTurn = gameLogic.currentRoom.players[gameLogic.currentRoom.currentPlayerIndex].id == player.id;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? (isCurrentPlayer ? Colors.blue.shade700 : Colors.grey.shade700)
                                            : (isCurrentPlayer ? Colors.blue.shade50 : Colors.grey.shade50),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isCurrentTurn ? Colors.green : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? (isCurrentPlayer ? Colors.lightBlue : Colors.white70)
                                                : (isCurrentPlayer ? Colors.blue : Colors.grey),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${player.nickname} ${isCurrentPlayer ? "(Sen)" : ""}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isCurrentPlayer ? Colors.blue : ThemeColors.getPlayerStatusText(context),
                                                  ),
                                                ),
                                                Text('Puan: ${player.quizScore}'),
                                              ],
                                            ),
                                          ),
                                          if (player.turnsToSkip > 0)
                                            Text(
                                              'PAS: ${player.turnsToSkip}',
                                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          color: ThemeColors.getGameBoardBackground(context),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _buildGameBoard(gameLogic, currentTile),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          color: ThemeColors.getPlayerInfoCardBackground(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                            child: _buildDiceArea(context, gameLogic, currentTile),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(dynamic gameLogic, BoardTile currentTile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 6 : 5;
    final spacing = screenWidth > 600 ? 4.0 : 3.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: GameBoard.totalTiles,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0, // Keep tiles square
      ),
      itemBuilder: (context, index) {
        final tile = gameLogic.board.tiles[index];
        final playersHere = widget.isMultiplayer
            ? gameLogic.currentRoom.players.where((p) => p.position == index).toList()
            : gameLogic.currentPlayer != null && gameLogic.currentPlayer.position == index ? [gameLogic.currentPlayer] : [];
        return _buildTile(context, tile, playersHere, widget.isMultiplayer);
      },
    );
  }

  Widget _buildTile(BuildContext context, BoardTile tile, List<dynamic> playersHere, bool isMultiplayer) {
    Color tileColor;
    IconData tileIcon;
    switch (tile.type) {
      case TileType.start:
        tileColor = Colors.lightGreen.shade300;
        tileIcon = Icons.play_arrow;
        break;
      case TileType.finish:
        tileColor = Colors.amber.shade400;
        tileIcon = Icons.flag;
        break;
      case TileType.quiz:
        tileColor = Colors.blue.shade200;
        tileIcon = Icons.question_mark;
        break;
      case TileType.bonus:
        tileColor = Colors.green.shade200;
        tileIcon = Icons.add_circle;
        break;
      case TileType.penalty:
        tileColor = Colors.red.shade300;
        tileIcon = Icons.remove_circle;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
        border: playersHere.isNotEmpty ? Border.all(color: Colors.black, width: 3) : null,
        boxShadow: playersHere.isNotEmpty ? [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))] : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tileIcon, size: 20, color: Colors.white),
            Text(tile.label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            if (playersHere.isNotEmpty)
              AnimatedScale(
                scale: 1.2,
                duration: const Duration(milliseconds: 500),
                curve: Curves.bounceOut,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: playersHere.map((player) {
                    // Different colors for different players
                    Color playerColor = Colors.black;
                    if (isMultiplayer && playersHere.length > 1) {
                      final index = playersHere.indexOf(player);
                      playerColor = [Colors.red, Colors.blue, Colors.green, Colors.yellow][index % 4];
                    }
                    return Icon(Icons.person_pin_circle, color: playerColor, size: 28 / playersHere.length);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceArea(BuildContext context, dynamic gameLogic, BoardTile currentTile) {

    bool isDisabled = gameLogic.isDiceRolling || gameLogic.isGameFinished || gameLogic.isQuizActive;
    String buttonText = 'Zar At!';
    String turnIndicator = '';

    if (widget.isMultiplayer) {
      final currentPlayer = gameLogic.currentRoom.players[gameLogic.currentRoom.currentPlayerIndex];
      turnIndicator = 'Sıra: ${currentPlayer.nickname}';
      isDisabled = isDisabled || !gameLogic.isMyTurn || currentPlayer.turnsToSkip > 0;
      buttonText = gameLogic.isQuizActive
          ? 'Quiz Açık...'
          : (!gameLogic.isMyTurn
              ? 'Bekleniyor...'
              : (currentPlayer.turnsToSkip > 0 ? 'Pas Geçiliyor (${currentPlayer.turnsToSkip})' : 'Zar At!'));
    } else {
      isDisabled = isDisabled || (gameLogic.currentPlayer?.turnsToSkip ?? 0) > 0;
      buttonText = gameLogic.isQuizActive
          ? 'Quiz Açık...'
          : ((gameLogic.currentPlayer?.turnsToSkip ?? 0) > 0 ? 'Pas Geçiliyor (${gameLogic.currentPlayer?.turnsToSkip ?? 0})' : 'Zar At!');
    }

    return Column(
      children: [
        if (widget.isMultiplayer && turnIndicator.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: ThemeColors.getTurnIndicatorBackground(context, gameLogic.isMyTurn),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: gameLogic.isMyTurn ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: Text(
              turnIndicator,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTurnIndicatorText(context, gameLogic.isMyTurn),
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Zar Değeri Gösterimi
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeColors.getDiceAreaBackground(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedBuilder(
            animation: _diceAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: gameLogic.isDiceRolling ? _diceRotationAnimation.value : 0,
                child: gameLogic.lastDiceRoll > 0
                  ? Text('🎲 ${gameLogic.lastDiceRoll}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: ThemeColors.getDiceValueText(context)))
                  : Text('🎲 Zar At!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.grey.shade600)),
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        // Zar At Butonu
        Stack(
          alignment: Alignment.center,
          children: [
            ElevatedButton(
              onPressed: isDisabled
                ? null
                : () async {
                    // Capture context-dependent objects before any async gaps
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    // Start dice animation and haptic feedback
                    _diceAnimationController.forward(from: 0);
                    HapticFeedback.mediumImpact();

                    final rollResult = await gameLogic.rollDice();

                    // Stop animation
                    _diceAnimationController.stop();

                    // Ensure widget still mounted before using UI APIs
                    if (!mounted) return;

                    if (rollResult == -1) {
                      _showTopNotification('Tur Atlandı! Cezanız Bitmedi.', color: Colors.orange, duration: const Duration(seconds: 3));
                    } else if (rollResult > 0) {

                      final currentTileAfterMove = gameLogic.board.tiles[gameLogic.currentPlayer!.position];

                      // 1. Kare etkisini uygula
                      final message = widget.isMultiplayer
                          ? gameLogic.applyTileEffect(gameLogic.currentPlayer!, currentTileAfterMove)
                          : gameLogic.applyTileEffect(currentTileAfterMove);

                      // 2. Etki diyalogunu göster (Quiz hariç)
                        if (currentTileAfterMove.type != TileType.start &&
                        currentTileAfterMove.type != TileType.finish &&
                        currentTileAfterMove.type != TileType.quiz)
                      {
                        _showTopNotification(message, color: Colors.blue, duration: const Duration(seconds: 3));
                      }

                      // 3. Quiz Kontrolü: Eğer kare Quiz ise, zar atma işlemi bittikten hemen sonra quiz'i aç
                        if (currentTileAfterMove.type == TileType.quiz) {
                        // Top notification göster (Quiz Vakti mesajı)
                        _showTopNotification(message, color: Colors.purple, duration: const Duration(seconds: 3));
                        // Quiz'i aç
                        if (!mounted) return;
                        await _startQuiz(navigator, messenger, gameLogic);
                      }
                    }
                  },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 8,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            if (gameLogic.isDiceRolling)
              const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMultiplayer) {
      return ChangeNotifierProvider(
        create: (_) => MultiplayerGameLogic(),
        child: Consumer<MultiplayerGameLogic>(
          builder: (context, gameLogic, child) {
            // Reset flag when game is no longer finished
            if (!gameLogic.isGameFinished) {
              _endGameDialogShown = false;
            }
            
            // Initialize multiplayer game logic if room data is available
            if (gameLogic.currentRoom == null && widget.roomId != null && widget.playerId != null) {
              // We need to load the room data first
              _initializeMultiplayerGame(context, gameLogic);
              return const Center(child: CircularProgressIndicator());
            }

            return _buildGameUI(context, gameLogic, isMultiplayer: true);
          },
        ),
      );
    } else {
      return FutureBuilder<String>(
        future: _getGameNickname(),
        builder: (context, nicknameSnapshot) {
          if (!nicknameSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ChangeNotifierProvider(
            create: (_) => GameLogic()..initializeGame(nicknameSnapshot.data!),
            child: Consumer<GameLogic>(
              builder: (context, gameLogic, child) {
                // Reset flag when game is no longer finished
                if (!gameLogic.isGameFinished) {
                  _endGameDialogShown = false;
                }
                
                return _buildGameUI(context, gameLogic, isMultiplayer: false);
              },
            ),
          );
        },
      );
    }
  }
}