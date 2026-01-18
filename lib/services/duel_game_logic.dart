// lib/services/duel_game_logic.dart
// Duel mode game logic for 2-player fast answer competition

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';
import 'quiz_logic.dart';
import 'firestore_service.dart';
import 'notification_service.dart';
import 'achievement_service.dart';

class DuelGameLogic extends ChangeNotifier {
  final QuizLogic _quizLogic = QuizLogic();
  final FirestoreService _firestoreService = FirestoreService();

  DuelRoom? _currentRoom;
  StreamSubscription<DuelRoom?>? _roomSubscription;
  Timer? _questionTimer;
  Timer? _gameTimer;

  // Game state
  Question? _currentQuestion;
  int _questionStartTime = 0;
  int _currentQuestionIndex = 0;
  int _timeElapsedInSeconds = 0;
  bool _isGameActive = false;
  bool _isDisposed = false;

  // Constants
  static const int questionTimeLimit = 15; // 15 seconds per question
  static const int totalQuestions = 5; // Best of 5 questions

  // Public getters
  DuelRoom? get currentRoom => _currentRoom;
  Question? get currentQuestion => _currentQuestion;
  int get timeElapsedInSeconds => _timeElapsedInSeconds;
  bool get isGameActive => _isGameActive;
  int get currentQuestionIndex => _currentQuestionIndex;

  String get timeElapsedFormatted {
    final minutes = (_timeElapsedInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeElapsedInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _questionTimer?.cancel();
    _gameTimer?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// Initialize duel room and start game
  Future<void> initializeDuelRoom(DuelRoom room, String playerId) async {
    _currentRoom = room;
    _timeElapsedInSeconds = 0;
    _currentQuestionIndex = 0;
    _isGameActive = true;

    _listenToRoomChanges();
    _startGameTimer();

    // Send game started notification
    final playerNames = room.players.map((p) => p.nickname).toList();
    await NotificationService().showGameStartedNotification(
      gameMode: 'Düello Modu',
      playerNames: playerNames,
    );

    // Start first question after a short delay
    Timer(const Duration(seconds: 2), () {
      _startNextQuestion();
    });

    notifyListeners();
  }

  /// Listen to room changes in real-time
  void _listenToRoomChanges() {
    _roomSubscription?.cancel();
    if (_currentRoom != null) {
      _roomSubscription =
          _firestoreService.listenToDuelRoom(_currentRoom!.id).listen((room) {
        if (room != null) {
          _currentRoom = room;
          _checkForGameEnd();
          notifyListeners();
        }
      });
    }
  }

  /// Start the game timer
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameActive) {
        _timeElapsedInSeconds++;

        // Sync time to Firestore every 10 seconds
        if (_timeElapsedInSeconds % 10 == 0) {
          _syncTimeToFirestore();
        }

        notifyListeners();
      }
    });
  }

  /// Sync time to Firestore
  void _syncTimeToFirestore() {
    if (_currentRoom != null) {
      _firestoreService.updateDuelGameState(
        _currentRoom!.id,
        timeElapsedInSeconds: _timeElapsedInSeconds,
      );
    }
  }

  /// Start the next question
  Future<void> _startNextQuestion() async {
    if (_currentQuestionIndex >= totalQuestions || _currentRoom == null) {
      _endGame();
      return;
    }

    try {
      // Get questions from QuizLogic and select random one
      final questions = await _quizLogic.getQuestions();
      if (questions.isEmpty) {
        debugPrint('🚨 No questions available');
        return;
      }

      final randomIndex =
          DateTime.now().millisecondsSinceEpoch % questions.length;
      final question = questions[randomIndex];
      _currentQuestion = question;
      _questionStartTime = DateTime.now().millisecondsSinceEpoch;
      _currentQuestionIndex++;

      // Convert question to map for Firestore
      final questionMap = {
        'text': question.text,
        'options': question.options
            .map((opt) => {
                  'text': opt.text,
                  'score': opt.score,
                })
            .toList(),
      };

      // Update room with new question
      await _firestoreService.updateDuelGameState(
        _currentRoom!.id,
        currentQuestion: questionMap,
        questionStartTime: _questionStartTime,
        currentQuestionIndex: _currentQuestionIndex,
      );

      // Start question timer
      _startQuestionTimer();

      if (kDebugMode) {
        debugPrint('🔄 Question $_currentQuestionIndex: ${question.text}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error starting next question: $e');
    }
  }

  /// Start timer for current question
  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (currentTime - _questionStartTime) ~/ 1000;

      if (elapsedSeconds >= questionTimeLimit) {
        // Time's up for this question
        _questionTimer?.cancel();
        _endQuestion(null); // No answer given
      }
    });
  }

  /// Submit answer for current question
  Future<void> submitAnswer(String answer, String playerId) async {
    if (_currentQuestion == null || _currentRoom == null || !_isGameActive) {
      return;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeTakenSeconds = (currentTime - _questionStartTime) ~/ 1000;

    // Check if time is up
    if (timeTakenSeconds > questionTimeLimit) {
      return; // Too late
    }

    // Check if answer is correct
    final isCorrect = _checkAnswer(answer);
    final playerIndex =
        _currentRoom!.players.indexWhere((p) => p.id == playerId);
    final player = _currentRoom!.players[playerIndex];

    // Update player score
    final updatedPlayers = <DuelPlayer>[..._currentRoom!.players];
    if (isCorrect) {
      // Bonus points for faster answers
      final timeBonus = questionTimeLimit - timeTakenSeconds;
      final updatedPlayer = DuelPlayer(
        id: player.id,
        nickname: player.nickname,
        duelScore: player.duelScore + 10 + timeBonus, // Base 10 + speed bonus
        isReady: player.isReady,
      );
      updatedPlayers[playerIndex] = updatedPlayer;
    }

    // Add answer to question answers
    final newAnswer = DuelAnswer(
      playerId: playerId,
      playerNickname: player.nickname,
      answer: answer,
      isCorrect: isCorrect,
      timeTaken: timeTakenSeconds,
      timestamp: DateTime.now(),
    );

    final updatedAnswers = <DuelAnswer>[
      ...(_currentRoom!.questionAnswers ?? []),
      newAnswer
    ];

    // Update room in Firestore
    await _firestoreService.updateDuelGameState(
      _currentRoom!.id,
      questionAnswers: updatedAnswers.map((a) => a.toMap()).toList(),
      players: updatedPlayers.map((p) => p.toMap()).toList(),
    );

    // End question immediately after answer
    _endQuestion(newAnswer);
  }

  /// Check if answer is correct
  bool _checkAnswer(String userAnswer) {
    if (_currentQuestion == null || _currentQuestion!.options.isEmpty) return false;

    final userAnswerLower = userAnswer.toLowerCase().trim();

    // Find the option with the highest score (correct answer)
    final correctOption = _currentQuestion!.options.fold<Option?>(
      null,
      (maxOption, option) => maxOption == null || option.score > maxOption.score 
          ? option 
          : maxOption,
    );
    
    if (correctOption == null) return false;
    
    final correctAnswer = correctOption.text.toLowerCase().trim();

    // Direct match
    if (correctAnswer == userAnswerLower) {
      return true;
    }

    // Check for common variations (remove punctuation, extra spaces)
    final cleanCorrect = correctAnswer
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final cleanUser = userAnswerLower
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleanCorrect == cleanUser) {
      return true;
    }

    return false;
  }

  /// End current question
  void _endQuestion(DuelAnswer? submittedAnswer) {
    _questionTimer?.cancel();

    // Wait 3 seconds then start next question or end game
    Timer(const Duration(seconds: 3), () {
      _startNextQuestion();
    });
  }

  /// Check if game should end
  void _checkForGameEnd() {
    if (_currentRoom == null) return;

    final player1 = _currentRoom!.players[0];
    final player2 =
        _currentRoom!.players.length > 1 ? _currentRoom!.players[1] : null;

    // Check if someone has won (first to 3 correct answers or most points after 5 questions)
    if (player2 != null) {
      final player1CorrectAnswers = _countCorrectAnswers(player1.id);
      final player2CorrectAnswers = _countCorrectAnswers(player2.id);

      // Win by correct answers
      if (player1CorrectAnswers >= 3 || player2CorrectAnswers >= 3) {
        _endGame();
        return;
      }

      // Win by points after all questions
      if (_currentQuestionIndex > totalQuestions) {
        _endGame();
        return;
      }
    }
  }

  /// Count correct answers for a player
  int _countCorrectAnswers(String playerId) {
    if (_currentRoom?.questionAnswers == null) return 0;

    return _currentRoom!.questionAnswers!
        .where((answer) => answer.playerId == playerId && answer.isCorrect)
        .length;
  }

  /// End the game
  Future<void> _endGame() async {
    if (_currentRoom == null) return;

    _isGameActive = false;
    _questionTimer?.cancel();
    _gameTimer?.cancel();

    // Determine winner
    final player1 = _currentRoom!.players[0];
    final player2 =
        _currentRoom!.players.length > 1 ? _currentRoom!.players[1] : null;

    String winnerName = 'Beraberlik!';
    int winnerScore = player1.duelScore;

    if (player2 != null) {
      final player1Correct = _countCorrectAnswers(player1.id);
      final player2Correct = _countCorrectAnswers(player2.id);

      if (player1Correct > player2Correct) {
        winnerName = player1.nickname;
        winnerScore = player1.duelScore;
      } else if (player2Correct > player1Correct) {
        winnerName = player2.nickname;
        winnerScore = player2.duelScore;
      } else {
        // Tie-breaker by total score
        if (player1.duelScore > player2.duelScore) {
          winnerName = player1.nickname;
          winnerScore = player1.duelScore;
        } else if (player2.duelScore > player1.duelScore) {
          winnerName = player2.nickname;
          winnerScore = player2.duelScore;
        }
      }
    }

    // Update room status
    _firestoreService.endDuelGame(_currentRoom!.id, winnerName, winnerScore);

    // Update achievement for winner
    if (winnerName.isNotEmpty) {
      AchievementService().updateProgress(
        duelWins: 1,
      );
    }

    // Send game finished notification
    await NotificationService().showGameFinishedNotification(
      winnerName: winnerName,
      gameMode: 'Düello Modu',
      score: winnerScore,
    );

    if (kDebugMode) {
      debugPrint(
          '🏆 Duel game ended. Winner: $winnerName (Score: $winnerScore)');
    }

    notifyListeners();
  }

  /// Leave duel room
  Future<void> leaveDuelRoom() async {
    if (_currentRoom != null) {
      await _firestoreService.leaveDuelRoom(_currentRoom!.id);
    }

    _roomSubscription?.cancel();
    _questionTimer?.cancel();
    _gameTimer?.cancel();

    _currentRoom = null;
    _currentQuestion = null;
    _isGameActive = false;
    notifyListeners();
  }
}

/// Duel room model
class DuelRoom {
  final String id;
  final String hostId;
  final String hostNickname;
  final List<DuelPlayer> players;
  final DuelGameStatus status;
  final int currentQuestionIndex;
  final int timeElapsedInSeconds;
  final Question? currentQuestion;
  final int? questionStartTime;
  final List<DuelAnswer>? questionAnswers;
  final DateTime createdAt;
  final String? winnerName;
  final int? winnerScore;

  DuelRoom({
    required this.id,
    required this.hostId,
    required this.hostNickname,
    required this.players,
    required this.status,
    this.currentQuestionIndex = 0,
    this.timeElapsedInSeconds = 0,
    this.currentQuestion,
    this.questionStartTime,
    this.questionAnswers,
    required this.createdAt,
    this.winnerName,
    this.winnerScore,
  });

  factory DuelRoom.fromMap(Map<String, dynamic> map) {
    return DuelRoom(
      id: map['id'] ?? '',
      hostId: map['hostId'] ?? '',
      hostNickname: map['hostNickname'] ?? '',
      players: (map['players'] as List<dynamic>? ?? [])
          .map((p) => DuelPlayer.fromMap(p))
          .toList(),
      status: DuelGameStatus.values.firstWhere(
        (s) => s.toString().split('.').last == (map['status'] ?? 'waiting'),
        orElse: () => DuelGameStatus.waiting,
      ),
      currentQuestionIndex: map['currentQuestionIndex'] ?? 0,
      timeElapsedInSeconds: map['timeElapsedInSeconds'] ?? 0,
      currentQuestion: map['currentQuestion'] != null
          ? Question.fromMap(map['currentQuestion'])
          : null,
      questionStartTime: map['questionStartTime'],
      questionAnswers: (map['questionAnswers'] as List<dynamic>?)
          ?.map((a) => DuelAnswer.fromMap(a))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      winnerName: map['winnerName'],
      winnerScore: map['winnerScore'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostId': hostId,
      'hostNickname': hostNickname,
      'players': players.map((p) => p.toMap()).toList(),
      'status': status.toString().split('.').last,
      'currentQuestionIndex': currentQuestionIndex,
      'timeElapsedInSeconds': timeElapsedInSeconds,
      'currentQuestion': currentQuestion != null
          ? {
              'text': currentQuestion!.text,
              'options': currentQuestion!.options
                  .map((opt) => {
                        'text': opt.text,
                        'score': opt.score,
                      })
                  .toList(),
            }
          : null,
      'questionStartTime': questionStartTime,
      'questionAnswers': questionAnswers?.map((a) => a.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'winnerName': winnerName,
      'winnerScore': winnerScore,
    };
  }

  DuelPlayer? getOpponent(String playerId) {
    return players.firstWhere(
      (p) => p.id != playerId,
      orElse: () => throw Exception('Player not found in room'),
    );
  }

  bool get isGameReady => players.length == 2;
  bool get isGameFinished => status == DuelGameStatus.finished;
  String get gameStatusText {
    switch (status) {
      case DuelGameStatus.waiting:
        return 'Oyuncu bekleniyor...';
      case DuelGameStatus.playing:
        return 'Oyun devam ediyor';
      case DuelGameStatus.finished:
        return 'Oyun bitti';
    }
  }
}

/// Duel player model
class DuelPlayer {
  final String id;
  final String nickname;
  final int duelScore;
  final bool isReady;

  DuelPlayer({
    required this.id,
    required this.nickname,
    this.duelScore = 0,
    this.isReady = false,
  });

  factory DuelPlayer.fromMap(Map<String, dynamic> map) {
    return DuelPlayer(
      id: map['id'] ?? '',
      nickname: map['nickname'] ?? '',
      duelScore: map['duelScore'] ?? 0,
      isReady: map['isReady'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'duelScore': duelScore,
      'isReady': isReady,
    };
  }
}

/// Duel answer model
class DuelAnswer {
  final String playerId;
  final String playerNickname;
  final String answer;
  final bool isCorrect;
  final int timeTaken;
  final DateTime timestamp;

  DuelAnswer({
    required this.playerId,
    required this.playerNickname,
    required this.answer,
    required this.isCorrect,
    required this.timeTaken,
    required this.timestamp,
  });

  factory DuelAnswer.fromMap(Map<String, dynamic> map) {
    return DuelAnswer(
      playerId: map['playerId'] ?? '',
      playerNickname: map['playerNickname'] ?? '',
      answer: map['answer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      timeTaken: map['timeTaken'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'playerNickname': playerNickname,
      'answer': answer,
      'isCorrect': isCorrect,
      'timeTaken': timeTaken,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

/// Duel game status
enum DuelGameStatus {
  waiting,
  playing,
  finished,
}
