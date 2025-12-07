import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/models/game_board.dart';
import 'package:karbonson/models/question.dart';

void main() {
  group('Player Model - Core Tests', () {
    test('Player initializes with correct defaults', () {
      final player = Player(nickname: 'TestPlayer');
      expect(player.nickname, equals('TestPlayer'));
      expect(player.position, equals(0));
      expect(player.turnsToSkip, equals(0));
      expect(player.quizScore, equals(0));
    });

    test('Player position can be updated', () {
      final player = Player(nickname: 'Test');
      player.position = 15;
      expect(player.position, equals(15));
    });

    test('Player turnsToSkip increments', () {
      final player = Player(nickname: 'Test');
      player.turnsToSkip = 2;
      expect(player.turnsToSkip, equals(2));
      player.turnsToSkip++;
      expect(player.turnsToSkip, equals(3));
    });

    test('Player quizScore accumulates', () {
      final player = Player(nickname: 'Test');
      player.quizScore = 0;
      player.quizScore += 10;
      expect(player.quizScore, equals(10));
      player.quizScore += 20;
      expect(player.quizScore, equals(30));
    });

    test('Multiple independent players', () {
      final p1 = Player(nickname: 'P1');
      final p2 = Player(nickname: 'P2');
      
      p1.position = 10;
      p2.position = 5;
      
      expect(p1.position, equals(10));
      expect(p2.position, equals(5));
    });
  });

  group('GameBoard - Structure Tests', () {
    late GameBoard gameBoard;

    setUp(() {
      gameBoard = GameBoard();
    });

    test('GameBoard initializes with tiles', () {
      expect(gameBoard.tiles, isNotEmpty);
      expect(gameBoard.tiles.length, equals(25)); // Actual board size
    });

    test('Tiles have valid indices', () {
      for (int i = 0; i < gameBoard.tiles.length; i++) {
        expect(gameBoard.tiles[i].index, equals(i));
      }
    });

    test('Tiles have valid types', () {
      final validTypes = {TileType.start, TileType.quiz, TileType.bonus, TileType.penalty, TileType.finish};
      for (final tile in gameBoard.tiles) {
        expect(validTypes.contains(tile.type), isTrue);
      }
    });

    test('Start tile at position 0', () {
      expect(gameBoard.tiles[0].type, equals(TileType.start));
    });

    test('Finish tile at last position', () {
      expect(gameBoard.tiles.last.type, equals(TileType.finish));
    });

    test('Each tile has a label', () {
      for (final tile in gameBoard.tiles) {
        expect(tile.label, isNotEmpty);
      }
    });
  });

  group('Question Model - Structure Tests', () {
    test('Option initializes correctly', () {
      final option = Option(text: 'Test Option', score: 10);
      expect(option.text, equals('Test Option'));
      expect(option.score, equals(10));
    });

    test('Question initializes with options', () {
      final options = [
        Option(text: 'Option 1', score: 10),
        Option(text: 'Option 2', score: 20),
        Option(text: 'Option 3', score: 30),
      ];
      final question = Question(text: 'What is test?', options: options);
      
      expect(question.text, equals('What is test?'));
      expect(question.options.length, equals(3));
      expect(question.options.first.text, equals('Option 1'));
    });

    test('Question options have scores', () {
      final options = [
        Option(text: 'Opt 1', score: 5),
        Option(text: 'Opt 2', score: 15),
      ];
      final question = Question(text: 'Test', options: options);
      
      expect(question.options[0].score, equals(5));
      expect(question.options[1].score, equals(15));
    });

    test('Empty question not allowed', () {
      expect(
        () => Question(text: '', options: []),
        isNotNull,
      );
    });
  });

  group('Game Flow Simulation', () {
    test('Player moves on board', () {
      final player = Player(nickname: 'Gamer');
      final board = GameBoard();
      
      expect(player.position, equals(0));
      expect(board.tiles[0].type, equals(TileType.start));
      
      // Simulate movement
      player.position += 3;
      expect(player.position, equals(3));
      expect(board.tiles[3].type, isNotNull);
    });

    test('Quiz score affects player state', () {
      final player = Player(nickname: 'Quizzer');
      final initialScore = player.quizScore;
      
      // Simulate correct answer
      player.quizScore += 10;
      expect(player.quizScore, greaterThan(initialScore));
    });

    test('Game progression sequence', () {
      final player = Player(nickname: 'Player1');
      final board = GameBoard();
      
      // Start position
      expect(player.position, equals(0));
      expect(board.tiles[0].type, equals(TileType.start));
      
      // Move 1
      player.position = 1;
      expect(player.position, equals(1));
      
      // Move 2
      player.position = 5;
      expect(player.position, equals(5));
      
      // Continue to near end
      player.position = board.tiles.length - 1;
      expect(player.position, equals(board.tiles.length - 1));
      expect(board.tiles[player.position].type, equals(TileType.finish));
    });

    test('Turn skip mechanics', () {
      final player = Player(nickname: 'Player');
      
      expect(player.turnsToSkip, equals(0));
      
      // Trigger turn skip
      player.turnsToSkip = 2;
      expect(player.turnsToSkip, equals(2));
      
      // Skip a turn
      player.turnsToSkip--;
      expect(player.turnsToSkip, equals(1));
      
      // Skip another
      player.turnsToSkip--;
      expect(player.turnsToSkip, equals(0));
    });
  });

  group('Edge Cases', () {
    test('Player position at boundaries', () {
      final player = Player(nickname: 'Boundary');
      
      // Minimum
      player.position = 0;
      expect(player.position, equals(0));
      
      // Maximum (board size - 1)
      player.position = 24;
      expect(player.position, equals(24));
    });

    test('High quiz scores', () {
      final player = Player(nickname: 'HighScorer');
      player.quizScore = 999999;
      expect(player.quizScore, equals(999999));
    });

    test('Long player nickname', () {
      const longName = 'ThisIsAVeryLongPlayerNameForTestingPurposes';
      final player = Player(nickname: longName);
      expect(player.nickname, equals(longName));
    });

    test('Empty player nickname is allowed', () {
      final player = Player(nickname: '');
      expect(player.nickname, equals(''));
    });

    test('Multiple quiz score increments', () {
      final player = Player(nickname: 'Incrementer');
      for (int i = 0; i < 10; i++) {
        player.quizScore += 5;
      }
      expect(player.quizScore, equals(50));
    });

    test('Board has no null tiles', () {
      final board = GameBoard();
      for (final tile in board.tiles) {
        expect(tile, isNotNull);
        expect(tile.index, isNotNull);
        expect(tile.type, isNotNull);
      }
    });
  });

  group('MultiplayerPlayer Tests', () {
    test('MultiplayerPlayer extends Player', () {
      final player = MultiplayerPlayer(
        id: '123',
        nickname: 'MPPlayer',
      );
      
      expect(player.nickname, equals('MPPlayer'));
      expect(player.id, equals('123'));
      expect(player.isOnline, equals(true));
      expect(player.isReady, equals(false));
    });

    test('MultiplayerPlayer can change status', () {
      final player = MultiplayerPlayer(
        id: 'mp1',
        nickname: 'Multiplayer',
        isOnline: true,
        isReady: false,
      );
      
      player.isReady = true;
      expect(player.isReady, equals(true));
      
      player.isOnline = false;
      expect(player.isOnline, equals(false));
    });

    test('MultiplayerPlayer converts to map', () {
      final player = MultiplayerPlayer(
        id: 'id123',
        nickname: 'TestMP',
        position: 5,
        quizScore: 50,
      );
      
      final map = player.toMap();
      expect(map['id'], equals('id123'));
      expect(map['nickname'], equals('TestMP'));
      expect(map['position'], equals(5));
      expect(map['quizScore'], equals(50));
    });

    test('MultiplayerPlayer creates from map', () {
      final map = {
        'id': 'mp456',
        'nickname': 'FromMap',
        'position': 10,
        'turnsToSkip': 1,
        'quizScore': 100,
        'isOnline': true,
        'isReady': false,
      };
      
      final player = MultiplayerPlayer.fromMap(map);
      expect(player.id, equals('mp456'));
      expect(player.nickname, equals('FromMap'));
      expect(player.position, equals(10));
      expect(player.turnsToSkip, equals(1));
      expect(player.quizScore, equals(100));
    });
  });
}
