// lib/services/multiplayer_game_logic.dart
// Enhanced Multiplayer Game Logic with improved error handling and null safety

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
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

  // Error handling
  String? _lastError;
  bool _hasError = false;

  // Public Getters
  GameRoom? get currentRoom => _currentRoom;
  MultiplayerPlayer? get currentPlayer => _currentPlayer;
  int get timeElapsedInSeconds => _timeElapsedInSeconds;
  bool get isQuizActive => _isQuizActive;
  int get lastDiceRoll => _lastDiceRoll;
  bool get isDiceRolling => _isDiceRolling;
  bool get isGameFinished => _currentRoom?.status == GameStatus.finished;
  bool get isMyTurn {
    if (_currentRoom == null ||
        _currentPlayer == null ||
        _currentRoom!.players.isEmpty ||
        _currentRoom!.currentPlayerIndex < 0 ||
        _currentRoom!.currentPlayerIndex >= _currentRoom!.players.length) {
      return false;
    }
    return _currentRoom!.players[_currentRoom!.currentPlayerIndex].id ==
        _currentPlayer!.id;
  }

  // Error getters
  String? get lastError => _lastError;
  bool get hasError => _hasError;

  String get timeElapsedFormatted {
    final minutes = (_timeElapsedInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeElapsedInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      // Batch notifications to prevent excessive rebuilds
      Future.delayed(Duration.zero, () {
        if (!_isDisposed) {
          super.notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _timer?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  /// Initialize room with enhanced error handling
  Future<bool> initializeRoom(GameRoom room, String playerId) async {
    try {
      // Clear any previous errors
      _clearError();

      // Validate inputs
      if (room.id.isEmpty) {
        _setError('Room ID cannot be empty');
        return false;
      }

      if (playerId.isEmpty) {
        _setError('Player ID cannot be empty');
        return false;
      }

      if (!room.players.any((p) => p.id == playerId)) {
        _setError('Player not found in room');
        return false;
      }

      _currentRoom = room;
      _currentPlayer = room.players.firstWhere((p) => p.id == playerId);
      _timeElapsedInSeconds = room.timeElapsedInSeconds;

      _startTimer();
      _listenToRoomChanges();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to initialize room: $e');
      return false;
    }
  }

  /// Listen to room changes with enhanced error handling
  void _listenToRoomChanges() {
    _roomSubscription?.cancel();
    if (_currentRoom == null || _currentRoom!.id.isEmpty) {
      return;
    }

    try {
      _roomSubscription =
          _firestoreService.listenToRoom(_currentRoom!.id).listen(
        (room) {
          if (room != null) {
            _currentRoom = room;
            _timeElapsedInSeconds = room.timeElapsedInSeconds;

            // Update current player reference with null safety
            if (_currentPlayer != null) {
              try {
                _currentPlayer = room.players.firstWhere(
                  (p) => p.id == _currentPlayer!.id,
                  orElse: () => _currentPlayer!,
                );
              } catch (e) {
                // Player not found, keep current player
                if (kDebugMode) {
                  debugPrint('Player not found in updated room: $e');
                }
              }
            }

            notifyListeners();
          }
        },
        onError: (error) {
          _setError('Error listening to room changes: $error');
        },
      );
    } catch (e) {
      _setError('Failed to set up room listener: $e');
    }
  }

  /// Start timer with enhanced error handling
  void _startTimer() {
    _timer?.cancel();

    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        try {
          if (!_isQuizActive && _currentRoom?.status == GameStatus.playing) {
            _timeElapsedInSeconds++;
            // Sync time to Firestore every 10 seconds
            if (_timeElapsedInSeconds % 10 == 0) {
              _syncTimeToFirestore();
            }
            notifyListeners();
          }
        } catch (e) {
          _setError('Timer error: $e');
          timer.cancel();
        }
      });
    } catch (e) {
      _setError('Failed to start timer: $e');
    }
  }

  /// Sync time to Firestore with error handling
  void _syncTimeToFirestore() {
    if (_currentRoom == null || _currentRoom!.id.isEmpty) {
      return;
    }

    try {
      _firestoreService.updateGameState(_currentRoom!.id,
          timeElapsedInSeconds: _timeElapsedInSeconds);
    } catch (e) {
      _setError('Failed to sync time: $e');
    }
  }

  void setIsQuizActive(bool active) {
    _isQuizActive = active;
    notifyListeners();
  }

  /// Roll dice with enhanced error handling and race condition prevention
  Future<int> rollDice() async {
    try {
      // Prevent multiple simultaneous rolls
      if (_isDiceRolling || _currentRoom == null || _currentPlayer == null) {
        return 0;
      }

      if (isGameFinished || isQuizActive || !isMyTurn) {
        return 0;
      }

      final currentPlayerIndex = _currentRoom!.currentPlayerIndex;
      if (currentPlayerIndex < 0 ||
          currentPlayerIndex >= _currentRoom!.players.length) {
        _setError('Invalid player index');
        return 0;
      }

      final currentPlayer = _currentRoom!.players[currentPlayerIndex];

      // Check if player needs to skip turn
      if (currentPlayer.turnsToSkip > 0) {
        _lastDiceRoll = 0;
        currentPlayer.turnsToSkip--;
        _isDiceRolling = false;

        // Update player in Firestore
        final success = await _updatePlayerInFirestore(currentPlayer);
        if (success) {
          await _nextTurn();
        }
        notifyListeners();
        return -1;
      }

      // Start rolling animation
      _isDiceRolling = true;
      notifyListeners();

      // Simulate dice roll delay
      await Future.delayed(const Duration(milliseconds: 700));

      // Generate random dice roll (1-3 for game balance)
      final roll = Random().nextInt(3) + 1;
      _lastDiceRoll = roll;
      _diceRollCount++;

      // Move player
      _movePlayer(currentPlayer, roll);

      // Update in Firestore
      final success = await _updatePlayerInFirestore(currentPlayer);
      if (success) {
        await _nextTurn();
      }

      _isDiceRolling = false;
      notifyListeners();
      return roll;
    } catch (e) {
      _isDiceRolling = false;
      _setError('Dice roll error: $e');
      notifyListeners();
      return 0;
    }
  }

  /// Move player with enhanced validation
  void _movePlayer(MultiplayerPlayer player, int steps) {
    try {
      if (steps < 0 || steps > 10) {
        _setError('Invalid move parameters');
        return;
      }

      int newPosition = player.position + steps;

      if (newPosition >= GameBoard.totalTiles - 1) {
        player.position = GameBoard.totalTiles - 1;
        _endGame();
      } else {
        player.position = newPosition;
      }
    } catch (e) {
      _setError('Move player error: $e');
    }
  }

  /// Next turn with error handling
  Future<bool> _nextTurn() async {
    try {
      if (_currentRoom == null || _currentRoom!.id.isEmpty) {
        return false;
      }

      final playerCount = _currentRoom!.players.length;
      if (playerCount == 0) {
        _setError('No players in room');
        return false;
      }

      int nextIndex = (_currentRoom!.currentPlayerIndex + 1) % playerCount;
      await _firestoreService.updateGameState(_currentRoom!.id,
          currentPlayerIndex: nextIndex);
      return true;
    } catch (e) {
      _setError('Next turn error: $e');
      return false;
    }
  }

  /// Update player in Firestore with error handling
  Future<bool> _updatePlayerInFirestore(MultiplayerPlayer player) async {
    try {
      if (_currentRoom == null || _currentRoom!.id.isEmpty) {
        return false;
      }

      if (player.id.isEmpty) {
        _setError('Player ID cannot be empty');
        return false;
      }

      final updatedPlayers = _currentRoom!.players.map((p) {
        return p.id == player.id ? player : p;
      }).toList();

      await _firestoreService.updateGameState(_currentRoom!.id,
          players: updatedPlayers);
      return true;
    } catch (e) {
      _setError('Update player error: $e');
      return false;
    }
  }

  /// Apply tile effect with enhanced error handling
  String? applyTileEffect(MultiplayerPlayer player, BoardTile tile) {
    try {
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
            message =
                "5 Saniye Ceza! 🛑 (5 Puan kaybı Quiz bitince uygulanacak)";
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
        default:
          message = "Bilinmeyen kare türü";
      }

      notifyListeners();
      return message;
    } catch (e) {
      _setError('Tile effect error: $e');
      return null;
    }
  }

  /// Quiz finished with enhanced error handling
  String? onQuizFinished(int score, MultiplayerPlayer player) {
    try {
      player.quizScore += score;
      setIsQuizActive(false);

      if (board.tiles.isNotEmpty &&
          player.position >= 0 &&
          player.position < board.tiles.length &&
          board.tiles[player.position].type == TileType.penalty) {
        if (_diceRollCount > 2) {
          player.quizScore = max(0, player.quizScore - 5);
          return "Quiz Puanı: $score. Ceza Karesi: -5 Puan ve 5 Saniye Ceza uygulandı.";
        } else {
          return "Quiz Puanı: $score. Güvenli Bölge: Ceza uygulanmadı.";
        }
      }

      return "Quiz Puanı: $score";
    } catch (e) {
      _setError('Quiz finished error: $e');
      return null;
    }
  }

  /// End game with error handling
  void _endGame() {
    try {
      if (_currentRoom != null && _currentRoom!.id.isNotEmpty) {
        _firestoreService.endGame(_currentRoom!.id);
      }
      _timer?.cancel();
      notifyListeners();
    } catch (e) {
      _setError('End game error: $e');
    }
  }

  /// Leave room with enhanced error handling
  Future<bool> leaveRoom() async {
    try {
      bool success = true;

      if (_currentRoom != null &&
          _currentRoom!.id.isNotEmpty &&
          _currentPlayer != null) {
        try {
          await _firestoreService.leaveRoom(
              _currentRoom!.id, _currentPlayer!.id);
        } catch (e) {
          _setError('Leave room error: $e');
          success = false;
        }
      }

      _roomSubscription?.cancel();
      _timer?.cancel();
      _currentRoom = null;
      _currentPlayer = null;
      _clearError();
      notifyListeners();

      return success;
    } catch (e) {
      _setError('Leave room fatal error: $e');
      return false;
    }
  }

  /// Set error message
  void _setError(String error) {
    _lastError = error;
    _hasError = true;
    if (kDebugMode) {
      debugPrint('MultiplayerGameLogic Error: $error');
    }
  }

  /// Clear error state
  void _clearError() {
    _lastError = null;
    _hasError = false;
  }

  /// Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
