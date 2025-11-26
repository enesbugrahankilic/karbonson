// lib/models/game_board.dart
import 'dart:math';

enum TileType {
  start,
  quiz,
  bonus,
  penalty,
  finish,
}

class BoardTile {
  final int index;
  final TileType type;
  final String label;

  BoardTile({required this.index, required this.type, required this.label});
}

class Player {
  final String nickname;
  int position;
  int turnsToSkip;
  int quizScore;

  Player({
    required this.nickname,
    this.position = 0,
    this.turnsToSkip = 0,
    this.quizScore = 0,
  });
}

enum GameStatus {
  waiting,
  playing,
  finished,
}

class MultiplayerPlayer extends Player {
  final String id;
  bool isOnline;
  bool isReady;

  MultiplayerPlayer({
    required this.id,
    required super.nickname,
    super.position = 0,
    super.turnsToSkip = 0,
    super.quizScore = 0,
    this.isOnline = true,
    this.isReady = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'position': position,
      'turnsToSkip': turnsToSkip,
      'quizScore': quizScore,
      'isOnline': isOnline,
      'isReady': isReady,
    };
  }

  factory MultiplayerPlayer.fromMap(Map<String, dynamic> map) {
    return MultiplayerPlayer(
      id: map['id'],
      nickname: map['nickname'],
      position: map['position'] ?? 0,
      turnsToSkip: map['turnsToSkip'] ?? 0,
      quizScore: map['quizScore'] ?? 0,
      isOnline: map['isOnline'] ?? true,
      isReady: map['isReady'] ?? false,
    );
  }
}

class GameRoom {
  final String id;
  final String hostId;
  final String hostNickname;
  List<MultiplayerPlayer> players;
  GameStatus status;
  int currentPlayerIndex;
  int timeElapsedInSeconds;
  List<Map<String, dynamic>> boardTiles; // Serialized board
  DateTime createdAt;
  
  // Room access control
  final String roomCode; // 4-digit unique code
  final bool isActive; // Active/Passive status
  final String? accessCode; // 4-digit access code for joining

  GameRoom({
    required this.id,
    required this.hostId,
    required this.hostNickname,
    required this.players,
    this.status = GameStatus.waiting,
    this.currentPlayerIndex = 0,
    this.timeElapsedInSeconds = 0,
    required this.boardTiles,
    required this.createdAt,
    required this.roomCode,
    this.isActive = true,
    this.accessCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostId': hostId,
      'hostNickname': hostNickname,
      'players': players.map((p) => p.toMap()).toList(),
      'status': status.toString().split('.').last,
      'currentPlayerIndex': currentPlayerIndex,
      'timeElapsedInSeconds': timeElapsedInSeconds,
      'boardTiles': boardTiles,
      'createdAt': createdAt.toIso8601String(),
      'roomCode': roomCode,
      'isActive': isActive,
      'accessCode': accessCode,
    };
  }

  factory GameRoom.fromMap(Map<String, dynamic> map) {
    return GameRoom(
      id: map['id'],
      hostId: map['hostId'],
      hostNickname: map['hostNickname'],
      players: (map['players'] as List<dynamic>?)
          ?.map((p) => MultiplayerPlayer.fromMap(p as Map<String, dynamic>))
          .toList() ?? [],
      status: GameStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => GameStatus.waiting,
      ),
      currentPlayerIndex: map['currentPlayerIndex'] ?? 0,
      timeElapsedInSeconds: map['timeElapsedInSeconds'] ?? 0,
      boardTiles: (map['boardTiles'] as List<dynamic>?)
          ?.map((t) => t as Map<String, dynamic>)
          .toList() ?? [],
      createdAt: DateTime.parse(map['createdAt']),
      roomCode: map['roomCode'] ?? '',
      isActive: map['isActive'] ?? true,
      accessCode: map['accessCode'],
    );
  }
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
}

class Friend {
  final String id;
  final String nickname;
  final DateTime addedAt;

  Friend({
    required this.id,
    required this.nickname,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      nickname: map['nickname'],
      addedAt: DateTime.parse(map['addedAt']),
    );
  }
}

class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromNickname;
  final String toUserId;
  final String toNickname;
  FriendRequestStatus status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromNickname,
    required this.toUserId,
    required this.toNickname,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromNickname': fromNickname,
      'toUserId': toUserId,
      'toNickname': toNickname,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'],
      fromUserId: map['fromUserId'],
      fromNickname: map['fromNickname'],
      toUserId: map['toUserId'],
      toNickname: map['toNickname'],
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => FriendRequestStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class GameBoard {
  static const int totalTiles = 25; 
  
  final List<BoardTile> tiles = [];

  GameBoard() {
    _initializeBoard();
  }

  void _initializeBoard() {
    final random = Random();
    
    for (int i = 0; i < totalTiles; i++) {
      TileType type;
      String label;

      if (i == 0) {
        type = TileType.start;
        label = "Başla";
      } else if (i == totalTiles - 1) {
        type = TileType.finish;
        label = "Bitiş";
      } else {
        int rand = random.nextInt(10); 
        
        if (rand < 4) { 
          type = TileType.quiz;
          label = "Quiz 💡";
        } else if (rand < 7) { 
          type = TileType.bonus;
          label = "+Bonus 💰";
        } else if (rand < 9) { 
          if (random.nextBool()) { 
             type = TileType.penalty;
             label = "-Ceza 🛑";
          } else {
             type = TileType.bonus; 
             label = "+Bonus 💰";
          }
        } else { 
          type = TileType.quiz;
          label = "Quiz 💡";
        }
      }
      
      tiles.add(BoardTile(index: i, type: type, label: label));
    }
  }
}