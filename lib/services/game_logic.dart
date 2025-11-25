// lib/services/game_logic.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_board.dart';
import 'quiz_logic.dart'; 

class GameLogic with ChangeNotifier {
  final GameBoard board = GameBoard();
  final QuizLogic quizLogic = QuizLogic();
  late Player player;

  int _lastDiceRoll = 0;
  bool _isDiceRolling = false;
  
  // OYUNCU KORUMA İÇİN: Kaç kez zar atıldığını tutar. (Koruma <= 2 zar için geçerli)
  int _diceRollCount = 0; 
  
  bool _isDisposed = false; 

  Timer? _timer;
  int _timeElapsedInSeconds = 0; 
  bool _isQuizActive = false; 
  
  // Public Getters
  int get timeElapsedInSeconds => _timeElapsedInSeconds; 
  bool get isQuizActive => _isQuizActive;
  int get lastDiceRoll => _lastDiceRoll;
  bool get isDiceRolling => _isDiceRolling;
  bool get isGameFinished => player.position == GameBoard.totalTiles - 1;

  String get timeElapsedFormatted {
    final minutes = (_timeElapsedInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeElapsedInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _isDisposed = true; 
    super.dispose();
  }

  void initializeGame(String nickname) {
    player = Player(nickname: nickname);
    _timeElapsedInSeconds = 0;
    player.turnsToSkip = 0;
    _diceRollCount = 0; // Başlangıçta 0
    _startTimer();
    notifyListeners();
  }
  
  void _startTimer() {
    _timer?.cancel(); 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isQuizActive && !isGameFinished) {
        _timeElapsedInSeconds++;
        notifyListeners(); 
      }
    });
  }

  void setIsQuizActive(bool active) {
    _isQuizActive = active;
    notifyListeners();
  }
  
  Future<int> rollDice() async {
    if (_isDiceRolling || isGameFinished || isQuizActive) return 0;
    
    if (player.turnsToSkip > 0) {
      _lastDiceRoll = 0; 
      player.turnsToSkip--; 
      _isDiceRolling = false;
      notifyListeners();
      return -1; 
    }
    
    _isDiceRolling = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700)); 

    final roll = Random().nextInt(3) + 1; 
    _lastDiceRoll = roll;
    
    _diceRollCount++; // ZAR ATILDIĞINDA SAYACI ARTIR
    
    _movePlayer(roll);
    
    _isDiceRolling = false;
    notifyListeners();
    return roll;
  }

  void _movePlayer(int steps) {
    int newPosition = player.position + steps;

    if (newPosition >= GameBoard.totalTiles - 1) {
      player.position = GameBoard.totalTiles - 1;
      _endGame();
    } else {
      player.position = newPosition;
    }
  }
  
  String applyTileEffect(BoardTile tile) {
    String message = "";
    
    switch (tile.type) {
      case TileType.bonus:
        _timeElapsedInSeconds = max(0, _timeElapsedInSeconds - 5); 
        message = "+5 Saniye Kazandın! ⏱️";
        break;
      
      case TileType.penalty:
        // CEZA KONTROLÜ: İlk 2 zar atışında koruma
        if (_diceRollCount <= 2) {
            message = "Güvenli Bölge! İlk 2 tur koruması devrede. 🎉";
        } else {
            // 3. zar atışından itibaren ceza uygula
            _timeElapsedInSeconds += 5; // 5 Saniye Ceza
            message = "5 Saniye Ceza! 🛑 (5 Puan kaybı Quiz bitince uygulanacak)"; 
        }
        break;
        
      case TileType.quiz:
        message = "Quiz Vakti! Puan Kazan. 🧠"; 
        break;
      case TileType.start:
        message = "Oyuna Başla!";
        break;
      case TileType.finish:
        break;
    }
    return message;
  }
  
  String? onQuizFinished(int score) {
    player.quizScore += score;
    setIsQuizActive(false); 

    // Quiz bittikten sonra Ceza Karesi kontrolü
    if (board.tiles[player.position].type == TileType.penalty) {
      
      // İlk 2 tur koruması bittiyse puanı düşür.
      if (_diceRollCount > 2) {
          player.quizScore = max(0, player.quizScore - 5); // 5 Puan Kaybı
          notifyListeners();
          return "Quiz Puanı: $score. Ceza Karesi: -5 Puan ve 5 Saniye Ceza uygulandı.";
      } else {
          notifyListeners();
          return "Quiz Puanı: $score. Güvenli Bölge: Ceza uygulanmadı.";
      }
    }
    
    notifyListeners();
    return "Quiz Puanı: $score"; 
  }

  void _endGame() {
    _timer?.cancel();
    notifyListeners();
  }
}