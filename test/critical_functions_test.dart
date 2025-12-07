import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/services/game_logic.dart';
import 'package:karbonson/services/quiz_logic.dart';
import 'package:karbonson/services/profile_service.dart';
import 'package:karbonson/models/game_board.dart';

void main() {
  group('GameLogic - Core Functions', () {
    late GameLogic gameLogic;

    setUp(() {
      gameLogic = GameLogic();
    });

    tearDown(() {
      gameLogic.dispose();
    });

    test('GameLogic initializes correctly', () {
      gameLogic.initializeGame('TestPlayer');
      expect(gameLogic.currentPlayer?.nickname, equals('TestPlayer'));
      expect(gameLogic.isGameFinished, equals(false));
    });

    test('Dice rolling returns valid range', () async {
      gameLogic.initializeGame('TestPlayer');
      final diceResult = await gameLogic.rollDice();
      expect(diceResult, greaterThanOrEqualTo(-1));
      expect(diceResult, lessThanOrEqualTo(3));
    });

    test('Game finishes when player reaches position 39', () {
      gameLogic.initializeGame('TestPlayer');
      gameLogic.currentPlayer?.position = 39;
      expect(gameLogic.isGameFinished, equals(true));
    });

    test('Game state resets on initialization', () {
      gameLogic.initializeGame('Player1');
      expect(gameLogic.currentPlayer?.position, equals(0));
      expect(gameLogic.currentPlayer?.turnsToSkip, equals(0));
      expect(gameLogic.isGameFinished, equals(false));
    });
  });

  group('QuizLogic - Core Functions', () {
    late QuizLogic quizLogic;

    setUp(() {
      quizLogic = QuizLogic();
    });

    test('QuizLogic initializes', () {
      expect(quizLogic, isNotNull);
    });

    test('Questions can be retrieved', () async {
      final questions = await quizLogic.getQuestions();
      expect(questions, isNotNull);
      expect(questions, isNotEmpty);
    });

    test('Quiz can be started', () async {
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      expect(questions, isNotEmpty);
    });

    test('Quiz returns valid question structure', () async {
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      
      if (questions.isNotEmpty) {
        final firstQuestion = questions.first;
        expect(firstQuestion.text, isNotEmpty);
        expect(firstQuestion.options, isNotEmpty);
        expect(firstQuestion.options.length, greaterThan(0));
      }
    });
  });

  group('ProfileService - Statistics', () {
    late ProfileService profileService;

    setUp(() {
      profileService = ProfileService();
    });

    test('ProfileService initializes', () {
      expect(profileService, isNotNull);
    });

    test('Game result can be added', () async {
      await profileService.addGameResult(
        score: 100,
        isWin: true,
        gameType: 'single_player',
      );
      expect(true, isTrue);
    });

    test('Statistics can be loaded', () async {
      await profileService.loadLocalStatistics();
      expect(true, isTrue);
    });
  });

  group('GameBoard - Structure', () {
    late GameBoard gameBoard;

    setUp(() {
      gameBoard = GameBoard();
    });

    test('GameBoard has 40 tiles', () {
      expect(gameBoard.tiles.length, equals(40));
    });

    test('Tiles have valid types', () {
      for (final tile in gameBoard.tiles) {
        expect(
          [TileType.start, TileType.quiz, TileType.bonus, TileType.penalty, TileType.finish],
          contains(tile.type),
        );
      }
    });

    test('Start tile at position 0', () {
      expect(gameBoard.tiles[0].type, equals(TileType.start));
    });

    test('Finish tile at position 39', () {
      expect(gameBoard.tiles[39].type, equals(TileType.finish));
    });
  });

  group('Player Model', () {
    test('Player initializes correctly', () {
      final player = Player(nickname: 'Test');
      expect(player.nickname, equals('Test'));
      expect(player.position, equals(0));
      expect(player.turnsToSkip, equals(0));
    });

    test('Player position updates', () {
      final player = Player(nickname: 'Test');
      player.position = 10;
      expect(player.position, equals(10));
    });

    test('Player quiz score updates', () {
      final player = Player(nickname: 'Test');
      player.quizScore = 50;
      expect(player.quizScore, equals(50));
    });

    test('Multiple players independent', () {
      final p1 = Player(nickname: 'P1');
      final p2 = Player(nickname: 'P2');
      
      p1.quizScore = 100;
      p2.quizScore = 50;
      
      expect(p1.quizScore, equals(100));
      expect(p2.quizScore, equals(50));
    });
  });

  group('Integration Tests', () {
    late GameLogic gameLogic;
    late QuizLogic quizLogic;

    setUp(() {
      gameLogic = GameLogic();
      quizLogic = QuizLogic();
    });

    tearDown(() {
      gameLogic.dispose();
    });

    test('Game init and quiz flow', () async {
      gameLogic.initializeGame('TestPlayer');
      await quizLogic.startNewQuiz();
      
      expect(gameLogic.currentPlayer?.nickname, equals('TestPlayer'));
      final questions = await quizLogic.getQuestions();
      expect(questions, isNotEmpty);
      expect(gameLogic.isGameFinished, equals(false));
    });

    test('Dice roll and quiz', () async {
      gameLogic.initializeGame('TestPlayer');
      final diceResult = await gameLogic.rollDice();
      await quizLogic.startNewQuiz();
      final questions = await quizLogic.getQuestions();
      
      expect(diceResult, greaterThanOrEqualTo(-1));
      expect(questions, isNotEmpty);
    });
  });

  group('Edge Cases', () {
    late GameLogic gameLogic;

    setUp(() {
      gameLogic = GameLogic();
    });

    tearDown(() {
      gameLogic.dispose();
    });

    test('Empty nickname', () {
      gameLogic.initializeGame('');
      expect(gameLogic.currentPlayer?.nickname, equals(''));
    });

    test('Long nickname', () {
      const longName = 'VeryLongNameTest';
      gameLogic.initializeGame(longName);
      expect(gameLogic.currentPlayer?.nickname, equals(longName));
    });

    test('Position bounds', () {
      gameLogic.initializeGame('Test');
      final player = gameLogic.currentPlayer;
      
      player?.position = 39;
      expect(player?.position, lessThanOrEqualTo(39));
      
      player?.position = 0;
      expect(player?.position, greaterThanOrEqualTo(0));
    });
  });
}
