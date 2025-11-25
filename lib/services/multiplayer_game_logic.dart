// lib/services/multiplayer_game_logic.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_board.dart';
import 'quiz_logic.dart';
import 'firestore_service.dart';

class MultiplayerGameLogic with ChangeNotifier {
  final GameBoard board = GameBoard();
  final QuizLogic quizLogic = QuizLogic();
  final FirestoreService _firestoreService = FirestoreService();

  GameRoom? _currentRoom;
  MultiplayerPlayer? _currentPlayer;
  StreamSubscription<GameRoom?>? _roomSubscription;

  int _lastDiceRoll = 0;
  bool _isDiceRolling = false;
  int _diceRollCount = 0;
  bool _isDisposed = false;
  Timer? _timer;
  int _timeElapsedInSeconds = 0;
  bool _isQuizActive = false;

  // Public Getters
  GameRoom? get currentRoom => _currentRoom;
  MultiplayerPlayer? get currentPlayer => _currentPlayer;
  int get timeElapsedInSeconds => _timeElapsedInSeconds;
  bool get isQuizActive => _isQuizActive;
  int get lastDiceRoll => _lastDiceRoll;
  bool get isDiceRolling => _isDiceRolling;
  bool get isGameFinished => _currentRoom?.status == GameStatus.finished;
  bool get isMyTurn => _currentRoom != null &&
                      _currentPlayer != null &&
                      _currentRoom!.players.isNotEmpty &&
                      _currentRoom!.players[_currentRoom!.currentPlayerIndex].id == _currentPlayer!.id;

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
    _roomSubscription?.cancel();
    _timer?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  void initializeRoom(GameRoom room, String playerId) {
    _currentRoom = room;
    _currentPlayer = room.players.firstWhere((p) => p.id == playerId);
    _timeElapsedInSeconds = room.timeElapsedInSeconds;
    _startTimer();
    _listenToRoomChanges();
    notifyListeners();
  }

  void _listenToRoomChanges() {
    _roomSubscription?.cancel();
    if (_currentRoom != null) {
      _roomSubscription = _firestoreService.listenToRoom(_currentRoom!.id).listen((room) {
        if (room != null) {
          _currentRoom = room;
          _timeElapsedInSeconds = room.timeElapsedInSeconds;

          // Update current player reference
          if (_currentPlayer != null) {
            _currentPlayer = room.players.firstWhere(
              (p) => p.id == _currentPlayer!.id,
              orElse: () => _currentPlayer!,
            );
          }

          notifyListeners();
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isQuizActive && _currentRoom?.status == GameStatus.playing) {
        _timeElapsedInSeconds++;
        // Sync time to Firestore every 10 seconds
        if (_timeElapsedInSeconds % 10 == 0) {
          _syncTimeToFirestore();
        }
        notifyListeners();
      }
    });
  }

  void _syncTimeToFirestore() {
    if (_currentRoom != null) {
      _firestoreService.updateGameState(_currentRoom!.id, timeElapsedInSeconds: _timeElapsedInSeconds);
    }
  }

  void setIsQuizActive(bool active) {
    _isQuizActive = active;
    notifyListeners();
  }

  Future<int> rollDice() async {
    if (_isDiceRolling || isGameFinished || isQuizActive || !isMyTurn) return 0;

    final currentPlayer = _currentRoom!.players[_currentRoom!.currentPlayerIndex];

    if (currentPlayer.turnsToSkip > 0) {
      _lastDiceRoll = 0;
      currentPlayer.turnsToSkip--;
      _isDiceRolling = false;
      await _updatePlayerInFirestore(currentPlayer);
      await _nextTurn();
      notifyListeners();
      return -1;
    }

    _isDiceRolling = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final roll = Random().nextInt(3) + 1;
    _lastDiceRoll = roll;
    _diceRollCount++;

    _movePlayer(currentPlayer, roll);
    await _updatePlayerInFirestore(currentPlayer);

    _isDiceRolling = false;
    await _nextTurn();
    notifyListeners();
    return roll;
  }

  void _movePlayer(MultiplayerPlayer player, int steps) {
    int newPosition = player.position + steps;

    if (newPosition >= GameBoard.totalTiles - 1) {
      player.position = GameBoard.totalTiles - 1;
      _endGame();
    } else {
      player.position = newPosition;
    }
  }

  Future<void> _nextTurn() async {
    if (_currentRoom == null) return;

    int nextIndex = (_currentRoom!.currentPlayerIndex + 1) % _currentRoom!.players.length;
    await _firestoreService.updateGameState(_currentRoom!.id, currentPlayerIndex: nextIndex);
  }

  Future<void> _updatePlayerInFirestore(MultiplayerPlayer player) async {
    if (_currentRoom == null) return;

    final updatedPlayers = _currentRoom!.players.map((p) {
      return p.id == player.id ? player : p;
    }).toList();

    await _firestoreService.updateGameState(_currentRoom!.id, players: updatedPlayers);
  }

  String applyTileEffect(MultiplayerPlayer player, BoardTile tile) {
    String message = "";

    switch (tile.type) {
      case TileType.bonus:
        _timeElapsedInSeconds = max(0, _timeElapsedInSeconds - 5);
        message = "+5 Saniye Kazandın! ⏱️";
        break;

      case TileType.penalty:
        if (_diceRollCount <= 2) {
          message = "Güvenli Bölge! İlk 2 tur koruması devrede. 🎉";
        } else {
          _timeElapsedInSeconds += 5;
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

  String? onQuizFinished(int score, MultiplayerPlayer player) {
    player.quizScore += score;
    setIsQuizActive(false);

    if (board.tiles[player.position].type == TileType.penalty) {
      if (_diceRollCount > 2) {
        player.quizScore = max(0, player.quizScore - 5);
        return "Quiz Puanı: $score. Ceza Karesi: -5 Puan ve 5 Saniye Ceza uygulandı.";
      } else {
        return "Quiz Puanı: $score. Güvenli Bölge: Ceza uygulanmadı.";
      }
    }

    return "Quiz Puanı: $score";
  }

  void _endGame() {
    if (_currentRoom != null) {
      _firestoreService.endGame(_currentRoom!.id);
    }
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> leaveRoom() async {
    if (_currentRoom != null && _currentPlayer != null) {
      await _firestoreService.leaveRoom(_currentRoom!.id, _currentPlayer!.id);
    }
    _roomSubscription?.cancel();
    _timer?.cancel();
    _currentRoom = null;
    _currentPlayer = null;
    notifyListeners();
  }
}