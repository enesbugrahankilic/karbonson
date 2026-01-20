// lib/services/spectator_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_board.dart';
import 'firestore_service.dart';

/// Enhanced SpectatorService with game discovery and real-time watching
class SpectatorService {
  static SpectatorService? _instance;
  static SpectatorService get instance => _instance ??= SpectatorService._();

  SpectatorService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  final StreamController<List<Spectator>> _spectatorsController =
      StreamController<List<Spectator>>.broadcast();

  final StreamController<List<GameReplay>> _replaysController =
      StreamController<List<GameReplay>>.broadcast();

  final StreamController<List<LiveGameInfo>> _activeGamesController =
      StreamController<List<LiveGameInfo>>.broadcast();

  final StreamController<LiveGameState?> _gameStateController =
      StreamController<LiveGameState?>.broadcast();

  final StreamController<List<SpectatorChatMessage>> _chatMessagesController =
      StreamController<List<SpectatorChatMessage>>.broadcast();

  final StreamController<List<EmojiReaction>> _reactionsController =
      StreamController<List<EmojiReaction>>.broadcast();

  Stream<List<Spectator>> get spectatorsStream => _spectatorsController.stream;
  Stream<List<GameReplay>> get replaysStream => _replaysController.stream;
  Stream<List<LiveGameInfo>> get activeGamesStream => _activeGamesController.stream;
  Stream<LiveGameState?> get gameStateStream => _gameStateController.stream;
  Stream<List<SpectatorChatMessage>> get chatMessagesStream => _chatMessagesController.stream;
  Stream<List<EmojiReaction>> get reactionsStream => _reactionsController.stream;

  // Active games listener
  StreamSubscription<List<LiveGameInfo>>? _activeGamesSubscription;
  StreamSubscription<LiveGameState?>? _gameStateSubscription;
  StreamSubscription<List<SpectatorChatMessage>>? _chatSubscription;
  StreamSubscription<List<EmojiReaction>>? _reactionsSubscription;

  // Spectator Management
  Future<String> joinAsSpectator(
      String gameId, String spectatorId, String spectatorName,
      {String? avatarUrl}) async {
    try {
      final spectator = Spectator(
        id: spectatorId,
        name: spectatorName,
        avatarUrl: avatarUrl,
        joinedAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('game_rooms')
          .doc(gameId)
          .collection('spectators')
          .doc(spectatorId)
          .set(spectator.toMap());

      // Increment spectator count in game room
      await _firestore.collection('game_rooms').doc(gameId).update({
        'spectatorCount': FieldValue.increment(1),
      });

      return gameId;
    } catch (e) {
      throw Exception('İzleyici olarak katılma hatası: $e');
    }
  }

  Future<void> leaveSpectatorMode(String gameId, String spectatorId) async {
    try {
      await _firestore
          .collection('game_rooms')
          .doc(gameId)
          .collection('spectators')
          .doc(spectatorId)
          .delete();

      // Decrement spectator count
      await _firestore.collection('game_rooms').doc(gameId).update({
        'spectatorCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('İzleyici modundan ayrılma hatası: $e');
    }
  }

  StreamSubscription<List<Spectator>>? _spectatorSubscription;

  void listenToSpectators(String gameId) {
    _spectatorSubscription?.cancel();

    _spectatorSubscription = _firestore
        .collection('game_rooms')
        .doc(gameId)
        .collection('spectators')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Spectator.fromMap(doc.data(), doc.id))
          .where((spectator) => spectator.isActive)
          .toList();
    }).listen((spectators) {
      _spectatorsController.add(spectators);
    });
  }

  void stopListeningToSpectators() {
    _spectatorSubscription?.cancel();
    _spectatorSubscription = null;
  }

  /// Get list of active games that can be watched
  Future<List<LiveGameInfo>> getActiveGames({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('game_rooms')
          .where('status', isEqualTo: 'playing')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LiveGameInfo(
          id: doc.id,
          hostNickname: data['hostNickname'] ?? 'Bilinmeyen',
          playerCount: data['players'] != null ? (data['players'] as List).length : 1,
          spectatorCount: data['spectatorCount'] ?? 0,
          timeElapsedInSeconds: data['timeElapsedInSeconds'] ?? 0,
          status: 'playing',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Aktif oyunları yükleme hatası: $e');
    }
  }

  /// Start listening to active games list
  void startListeningToActiveGames() {
    _activeGamesSubscription?.cancel();

    _activeGamesSubscription = _firestore
        .collection('game_rooms')
        .where('status', isEqualTo: 'playing')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LiveGameInfo(
          id: doc.id,
          hostNickname: data['hostNickname'] ?? 'Bilinmeyen',
          playerCount: data['players'] != null ? (data['players'] as List).length : 1,
          spectatorCount: data['spectatorCount'] ?? 0,
          timeElapsedInSeconds: data['timeElapsedInSeconds'] ?? 0,
          status: 'playing',
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    }).listen((games) {
      _activeGamesController.add(games);
    });
  }

  void stopListeningToActiveGames() {
    _activeGamesSubscription?.cancel();
    _activeGamesSubscription = null;
  }

  /// Watch a specific game's state in real-time
  Future<void> watchGameState(String gameId) async {
    try {
      // Get initial game state
      final roomDoc = await _firestore.collection('game_rooms').doc(gameId).get();
      if (!roomDoc.exists) {
        throw Exception('Oyun bulunamadı');
      }

      final roomData = roomDoc.data()!;
      
      // Create initial game state
      final initialState = LiveGameState(
        gameId: gameId,
        hostNickname: roomData['hostNickname'] ?? 'Bilinmeyen',
        players: _parsePlayers(roomData['players']),
        currentPlayerIndex: roomData['currentPlayerIndex'] ?? 0,
        timeElapsedInSeconds: roomData['timeElapsedInSeconds'] ?? 0,
        status: roomData['status'] ?? 'waiting',
        lastAction: roomData['lastAction'] ?? '',
        lastActionTimestamp: roomData['lastActionTimestamp'] != null
            ? (roomData['lastActionTimestamp'] as Timestamp).toDate()
            : null,
      );

      _gameStateController.add(initialState);

      // Start listening to changes
      _gameStateSubscription = _firestore
          .collection('game_rooms')
          .doc(gameId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final gameState = LiveGameState(
            gameId: gameId,
            hostNickname: data['hostNickname'] ?? 'Bilinmeyen',
            players: _parsePlayers(data['players']),
            currentPlayerIndex: data['currentPlayerIndex'] ?? 0,
            timeElapsedInSeconds: data['timeElapsedInSeconds'] ?? 0,
            status: data['status'] ?? 'waiting',
            lastAction: data['lastAction'] ?? '',
            lastActionTimestamp: data['lastActionTimestamp'] != null
                ? (data['lastActionTimestamp'] as Timestamp).toDate()
                : null,
          );
          _gameStateController.add(gameState);
        }
      }) as StreamSubscription<LiveGameState?>?;
    } catch (e) {
      throw Exception('Oyun durumu izleme hatası: $e');
    }
  }

  List<LivePlayerState> _parsePlayers(List<dynamic>? playersData) {
    if (playersData == null) return [];
    
    return playersData.map((player) {
      return LivePlayerState(
        id: player['id'] ?? '',
        nickname: player['nickname'] ?? 'Bilinmeyen',
        position: player['position'] ?? 0,
        quizScore: player['quizScore'] ?? 0,
        isOnline: player['isOnline'] ?? true,
      );
    }).toList();
  }

  void stopWatchingGameState() {
    _gameStateSubscription?.cancel();
    _gameStateSubscription = null;
    _gameStateController.add(null);
  }

  /// Send emoji reaction during game
  Future<void> sendEmojiReaction(
      String gameId, String spectatorId, String emoji) async {
    try {
      final reaction = EmojiReaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        spectatorId: spectatorId,
        emoji: emoji,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('game_rooms')
          .doc(gameId)
          .collection('emoji_reactions')
          .doc(reaction.id)
          .set(reaction.toMap());
    } catch (e) {
      throw Exception('Emoji gönderme hatası: $e');
    }
  }

  /// Listen to emoji reactions
  void startListeningToEmojiReactions(String gameId) {
    _reactionsSubscription?.cancel();

    _reactionsSubscription = _firestore
        .collection('game_rooms')
        .doc(gameId)
        .collection('emoji_reactions')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmojiReaction.fromMap(doc.data()))
          .toList();
    }).listen((reactions) {
      _reactionsController.add(reactions);
    });
  }

  void stopListeningToEmojiReactions() {
    _reactionsSubscription?.cancel();
    _reactionsSubscription = null;
  }

  /// Get available game replays
  Future<List<GameReplay>> getAvailableReplays({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('game_replays')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final List<GameReplay> replays = [];

      for (final doc in snapshot.docs) {
        try {
          final movesSnapshot = await _firestore
              .collection('game_replays')
              .doc(doc.id)
              .collection('moves')
              .orderBy('moveNumber')
              .get();

          final moves = movesSnapshot.docs
              .map((moveDoc) => GameMoveRecord.fromMap(moveDoc.data()))
              .toList();

          replays.add(GameReplay.fromMap(doc.data(), doc.id, moves));
        } catch (e) {
          debugPrint('Replay moves yüklenirken hata: $e');
        }
      }

      return replays;
    } catch (e) {
      throw Exception('Oyun tekrarlarını yükleme hatası: $e');
    }
  }

  // Game Replay System
  Future<void> recordGameMove(
      String gameId, GameMove move, int moveNumber) async {
    try {
      final gameMove = GameMoveRecord(
        moveNumber: moveNumber,
        playerId: move.playerId,
        playerName: move.playerName,
        moveType: move.moveType,
        timestamp: DateTime.now(),
        diceValue: move.diceValue,
        newPosition: move.newPosition,
        scoreChange: move.scoreChange,
        questionAnswered: move.questionAnswered,
        questionResult: move.questionResult,
        tileType: move.tileType,
      );

      await _firestore
          .collection('game_replays')
          .doc(gameId)
          .collection('moves')
          .doc('move_$moveNumber')
          .set(gameMove.toMap());
    } catch (e) {
      throw Exception('Hamle kaydetme hatası: $e');
    }
  }

  Future<GameReplay?> createReplay(
      String gameId, List<GameMoveRecord> moves) async {
    try {
      final replay = GameReplay(
        id: gameId,
        moves: moves,
        createdAt: DateTime.now(),
        isPublic: false,
        totalMoves: moves.length,
      );

      await _firestore
          .collection('game_replays')
          .doc(gameId)
          .set(replay.toMap());

      return replay;
    } catch (e) {
      throw Exception('Oyun tekrarı oluşturma hatası: $e');
    }
  }

  Future<GameReplay?> getGameReplay(String replayId) async {
    try {
      final doc =
          await _firestore.collection('game_replays').doc(replayId).get();

      if (doc.exists) {
        // Get moves
        final movesSnapshot = await _firestore
            .collection('game_replays')
            .doc(replayId)
            .collection('moves')
            .orderBy('moveNumber')
            .get();

        final moves = movesSnapshot.docs
            .map((doc) => GameMoveRecord.fromMap(doc.data()))
            .toList();

        return GameReplay.fromMap(doc.data()!, replayId, moves);
      }
    } catch (e) {
      throw Exception('Oyun tekrarı yükleme hatası: $e');
    }
    return null;
  }

  Future<List<GameReplay>> getPublicReplays({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('game_replays')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final List<GameReplay> replays = [];

      for (final doc in snapshot.docs) {
        final movesSnapshot = await _firestore
            .collection('game_replays')
            .doc(doc.id)
            .collection('moves')
            .orderBy('moveNumber')
            .get();

        final moves = movesSnapshot.docs
            .map((moveDoc) => GameMoveRecord.fromMap(moveDoc.data()))
            .toList();

        replays.add(GameReplay.fromMap(doc.data(), doc.id, moves));
      }

      return replays;
    } catch (e) {
      throw Exception('Genel oyun tekrarlarını yükleme hatası: $e');
    }
  }

  Future<void> makeReplayPublic(String replayId, bool isPublic) async {
    try {
      await _firestore
          .collection('game_replays')
          .doc(replayId)
          .update({'isPublic': isPublic});
    } catch (e) {
      throw Exception('Tekrar görünürlük ayarlama hatası: $e');
    }
  }

  // Spectator Chat
  Future<void> sendSpectatorMessage(
      String gameId, String spectatorId, String message) async {
    try {
      final chatMessage = SpectatorChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        spectatorId: spectatorId,
        message: message,
        timestamp: DateTime.now(),
        type: ChatMessageType.text,
      );

      await _firestore
          .collection('game_rooms')
          .doc(gameId)
          .collection('spectator_chat')
          .doc(chatMessage.id)
          .set(chatMessage.toMap());
    } catch (e) {
      throw Exception('İzleyici mesajı gönderme hatası: $e');
    }
  }

  void listenToSpectatorChat(String gameId) {
    _chatSubscription?.cancel();

    _chatSubscription = _firestore
        .collection('game_rooms')
        .doc(gameId)
        .collection('spectator_chat')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SpectatorChatMessage.fromMap(doc.data()))
          .toList();
    }).listen((messages) {
      // Emit to the chat messages controller
      _chatMessagesController.add(messages);
    });
  }

  void stopListeningToSpectatorChat() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  void dispose() {
    _spectatorsController.close();
    _replaysController.close();
    _activeGamesController.close();
    _gameStateController.close();
    _chatMessagesController.close();
    _reactionsController.close();
    _spectatorSubscription?.cancel();
    _chatSubscription?.cancel();
    _activeGamesSubscription?.cancel();
    _gameStateSubscription?.cancel();
    _reactionsSubscription?.cancel();
  }
}

// Data Models for Spectator Mode

class Spectator {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedAt;
  final bool isActive;
  final DateTime? lastActivity;

  Spectator({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.joinedAt,
    this.isActive = true,
    this.lastActivity,
  });

  factory Spectator.fromMap(Map<String, dynamic> map, String id) {
    return Spectator(
      id: id,
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      lastActivity: map['lastActivity'] != null
          ? (map['lastActivity'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      'lastActivity':
          lastActivity != null ? Timestamp.fromDate(lastActivity!) : null,
    };
  }
}

class GameMove {
  final String playerId;
  final String playerName;
  final String moveType; // 'dice_roll', 'quiz_answer', 'move'
  final int? diceValue;
  final int? newPosition;
  final int? scoreChange;
  final bool questionAnswered;
  final int? questionResult;
  final TileType? tileType;

  GameMove({
    required this.playerId,
    required this.playerName,
    required this.moveType,
    this.diceValue,
    this.newPosition,
    this.scoreChange,
    this.questionAnswered = false,
    this.questionResult,
    this.tileType,
  });
}

class GameMoveRecord {
  final int moveNumber;
  final String playerId;
  final String playerName;
  final String moveType;
  final DateTime timestamp;
  final int? diceValue;
  final int? newPosition;
  final int? scoreChange;
  final bool questionAnswered;
  final int? questionResult;
  final TileType? tileType;

  GameMoveRecord({
    required this.moveNumber,
    required this.playerId,
    required this.playerName,
    required this.moveType,
    required this.timestamp,
    this.diceValue,
    this.newPosition,
    this.scoreChange,
    this.questionAnswered = false,
    this.questionResult,
    this.tileType,
  });

  factory GameMoveRecord.fromMap(Map<String, dynamic> map) {
    return GameMoveRecord(
      moveNumber: map['moveNumber'] ?? 0,
      playerId: map['playerId'] ?? '',
      playerName: map['playerName'] ?? '',
      moveType: map['moveType'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      diceValue: map['diceValue'],
      newPosition: map['newPosition'],
      scoreChange: map['scoreChange'],
      questionAnswered: map['questionAnswered'] ?? false,
      questionResult: map['questionResult'],
      tileType: map['tileType'] != null
          ? TileType.values.firstWhere(
              (t) => t.toString().split('.').last == map['tileType'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moveNumber': moveNumber,
      'playerId': playerId,
      'playerName': playerName,
      'moveType': moveType,
      'timestamp': Timestamp.fromDate(timestamp),
      'diceValue': diceValue,
      'newPosition': newPosition,
      'scoreChange': scoreChange,
      'questionAnswered': questionAnswered,
      'questionResult': questionResult,
      'tileType': tileType?.toString().split('.').last,
    };
  }
}

class GameReplay {
  final String id;
  final String? title;
  final String? description;
  final List<GameMoveRecord> moves;
  final DateTime createdAt;
  final bool isPublic;
  final int totalMoves;
  final int? durationInSeconds;

  GameReplay({
    required this.id,
    this.title,
    this.description,
    required this.moves,
    required this.createdAt,
    this.isPublic = false,
    required this.totalMoves,
    this.durationInSeconds,
  });

  factory GameReplay.fromMap(
      Map<String, dynamic> map, String id, List<GameMoveRecord> moves) {
    return GameReplay(
      id: id,
      title: map['title'],
      description: map['description'],
      moves: moves,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isPublic: map['isPublic'] ?? false,
      totalMoves: map['totalMoves'] ?? moves.length,
      durationInSeconds: map['durationInSeconds'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'totalMoves': totalMoves,
      'durationInSeconds': durationInSeconds,
    };
  }
}

class SpectatorChatMessage {
  final String id;
  final String spectatorId;
  final String message;
  final DateTime timestamp;
  final ChatMessageType type;

  SpectatorChatMessage({
    required this.id,
    required this.spectatorId,
    required this.message,
    required this.timestamp,
    this.type = ChatMessageType.text,
  });

  factory SpectatorChatMessage.fromMap(Map<String, dynamic> map) {
    return SpectatorChatMessage(
      id: map['id'] ?? '',
      spectatorId: map['spectatorId'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: ChatMessageType.values.firstWhere(
        (t) => t.toString().split('.').last == map['type'],
        orElse: () => ChatMessageType.text,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spectatorId': spectatorId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
    };
  }
}

enum ChatMessageType {
  text,
  emoji,
  system,
}

// New Models for Enhanced Spectator Mode

/// Information about an active game that can be watched
class LiveGameInfo {
  final String id;
  final String hostNickname;
  final int playerCount;
  final int spectatorCount;
  final int timeElapsedInSeconds;
  final String status;
  final DateTime createdAt;

  LiveGameInfo({
    required this.id,
    required this.hostNickname,
    required this.playerCount,
    required this.spectatorCount,
    required this.timeElapsedInSeconds,
    required this.status,
    required this.createdAt,
  });

  String get timeElapsedFormatted {
    final minutes = (timeElapsedInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeElapsedInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Real-time game state for spectators
class LiveGameState {
  final String gameId;
  final String hostNickname;
  final List<LivePlayerState> players;
  final int currentPlayerIndex;
  final int timeElapsedInSeconds;
  final String status;
  final String lastAction;
  final DateTime? lastActionTimestamp;

  LiveGameState({
    required this.gameId,
    required this.hostNickname,
    required this.players,
    required this.currentPlayerIndex,
    required this.timeElapsedInSeconds,
    required this.status,
    this.lastAction = '',
    this.lastActionTimestamp,
  });

  String get timeElapsedFormatted {
    final minutes = (timeElapsedInSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeElapsedInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  LivePlayerState? get currentPlayer {
    if (currentPlayerIndex >= 0 && currentPlayerIndex < players.length) {
      return players[currentPlayerIndex];
    }
    return null;
  }
}

/// Player state in a live game
class LivePlayerState {
  final String id;
  final String nickname;
  final int position;
  final int quizScore;
  final bool isOnline;

  LivePlayerState({
    required this.id,
    required this.nickname,
    required this.position,
    required this.quizScore,
    required this.isOnline,
  });
}

/// Emoji reaction from spectators
class EmojiReaction {
  final String id;
  final String spectatorId;
  final String emoji;
  final DateTime timestamp;

  EmojiReaction({
    required this.id,
    required this.spectatorId,
    required this.emoji,
    required this.timestamp,
  });

  factory EmojiReaction.fromMap(Map<String, dynamic> map) {
    return EmojiReaction(
      id: map['id'] ?? '',
      spectatorId: map['spectatorId'] ?? '',
      emoji: map['emoji'] ?? '👍',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spectatorId': spectatorId,
      'emoji': emoji,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
