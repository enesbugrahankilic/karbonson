// lib/pages/board_game_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_logic.dart';
import '../models/game_board.dart';
import 'quiz_page.dart'; 
import 'leaderboard_page.dart'; 
import '../services/firestore_service.dart'; 
import 'login_page.dart'; 

class BoardGamePage extends StatelessWidget {
  final String userNickname;
  
  const BoardGamePage({super.key, required this.userNickname});

  // Quiz penceresini açar
  Future<void> _startQuiz(BuildContext context, GameLogic gameLogic) async {
    gameLogic.quizLogic.startNewQuiz(); 
    gameLogic.setIsQuizActive(true); 

    final resultScore = await Navigator.push<int>(
      context, 
      MaterialPageRoute(
        builder: (context) => QuizPage(
          userNickname: gameLogic.player.nickname,
          quizLogic: gameLogic.quizLogic, 
        ),
      ),
    );
    
    if (resultScore != null) {
      final message = gameLogic.onQuizFinished(resultScore);
      _showTileEffectDialog(context, "Quiz Sonucu", "Puan: $resultScore. \n$message");
    } else {
      gameLogic.setIsQuizActive(false); 
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
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

    if (shouldExit == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showTileEffectDialog(BuildContext context, String title, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showEndGameDialog(BuildContext context, GameLogic gameLogic) {
    final finalScore = gameLogic.player.quizScore;
    final totalScore = finalScore - (gameLogic.timeElapsedInSeconds ~/ 10); 
    
    FirestoreService().saveUserScore(gameLogic.player.nickname, totalScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('OYUN BİTTİ! 🎉', style: TextStyle(color: Color(0xFF4CAF50))),
          content: Text(
            'Tebrikler ${gameLogic.player.nickname}!\n'
            'Geçen Süre: ${gameLogic.timeElapsedFormatted}\n'
            'Toplam Quiz Puanı: ${gameLogic.player.quizScore}\n'
            'Oyun Sonu Skoru: $totalScore',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Liderlik Tablosunu Gör', style: TextStyle(color: Color(0xFF1E88E5))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameLogic()..initializeGame(userNickname),
      child: Consumer<GameLogic>(
        builder: (context, gameLogic, child) {
          
          if (gameLogic.isGameFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showEndGameDialog(context, gameLogic);
            });
            return Container(); 
          }
          
          final currentTile = gameLogic.board.tiles[gameLogic.player.position];
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Karbon Hesaplama Oyunu'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Center(
                    child: Text(
                      'Süre: ${gameLogic.timeElapsedFormatted}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => _confirmExit(context),
                  tooltip: 'Oyundan Çık',
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF1E88E5)),
                    title: Text('Oyuncu: ${gameLogic.player.nickname}'),
                    subtitle: Text('Quiz Puanı: ${gameLogic.player.quizScore}'),
                    trailing: gameLogic.player.turnsToSkip > 0 
                      ? Text('PAS TUR: ${gameLogic.player.turnsToSkip}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                      : null,
                  ),
                  const Divider(),
                  _buildGameBoard(gameLogic, currentTile),
                  const SizedBox(height: 25),
                  _buildDiceArea(context, gameLogic, currentTile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameBoard(GameLogic gameLogic, BoardTile currentTile) {
    return AspectRatio(
      aspectRatio: 1.0, 
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: GameBoard.totalTiles,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, 
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          final tile = gameLogic.board.tiles[index];
          final isPlayerHere = gameLogic.player.position == index;
          return _buildTile(context, tile, isPlayerHere);
        },
      ),
    );
  }

  Widget _buildTile(BuildContext context, BoardTile tile, bool isPlayerHere) {
    Color tileColor;
    switch (tile.type) {
      case TileType.Start:
        tileColor = Colors.lightGreen.shade300;
        break;
      case TileType.Finish:
        tileColor = Colors.amber.shade400;
        break;
      case TileType.Quiz:
        tileColor = Colors.blue.shade200;
        break;
      case TileType.Bonus:
        tileColor = Colors.green.shade200;
        break;
      case TileType.Penalty:
        tileColor = Colors.red.shade300;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
        border: isPlayerHere ? Border.all(color: Colors.black, width: 3) : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tile.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            if (isPlayerHere) 
              const Icon(Icons.eco, color: Colors.black, size: 24), 
          ],
        ),
      ),
    );
  }

  Widget _buildDiceArea(BuildContext context, GameLogic gameLogic, BoardTile currentTile) {
    
    bool isDisabled = gameLogic.isDiceRolling || gameLogic.isGameFinished || gameLogic.isQuizActive || gameLogic.player.turnsToSkip > 0;

    return Column(
      children: [
        // Zar Değeri Gösterimi
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: gameLogic.lastDiceRoll > 0
            ? Text('Zar: ${gameLogic.lastDiceRoll}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E88E5)))
            : Text('Zar At!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.grey.shade600)),
        ),
        
        const SizedBox(height: 15),

        // Zar At Butonu
        ElevatedButton(
          onPressed: isDisabled 
            ? null 
            : () async {
                final rollResult = await gameLogic.rollDice();
                
                if (rollResult == -1) {
                    _showTileEffectDialog(context, "Pas", "Tur Atlandı! Cezanız Bitmedi.");
                } else if (rollResult > 0) {
                    
                    final currentTileAfterMove = gameLogic.board.tiles[gameLogic.player.position];
                    
                    // 1. Kare etkisini uygula
                    final message = gameLogic.applyTileEffect(currentTileAfterMove); 
                    
                    // 2. Etki diyalogunu göster (Quiz hariç)
                    if (currentTileAfterMove.type != TileType.Start && 
                        currentTileAfterMove.type != TileType.Finish &&
                        currentTileAfterMove.type != TileType.Quiz) 
                    {
                        _showTileEffectDialog(context, currentTileAfterMove.label, message);
                    }
                    
                    // 3. Quiz Kontrolü: Eğer kare Quiz ise, zar atma işlemi bittikten hemen sonra quiz'i aç
                    if (currentTileAfterMove.type == TileType.Quiz) {
                        // SnackBar göster (Quiz Vakti mesajı)
                        _showTileEffectDialog(context, currentTileAfterMove.label, message);
                        // Quiz'i aç
                        await _startQuiz(context, gameLogic);
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
            gameLogic.isQuizActive
                ? 'Quiz Açık...'
                : (gameLogic.player.turnsToSkip > 0 ? 'Pas Geçiliyor (${gameLogic.player.turnsToSkip})' : 'Zar At!'),
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}