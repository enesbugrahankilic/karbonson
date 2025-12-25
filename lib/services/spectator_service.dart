// lib/services/spectator_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_board.dart';

class SpectatorService {
  static SpectatorService? _instance;
  static SpectatorService get instance => _instance ??= SpectatorService._();

  SpectatorService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<Spectator>> _spectatorsController =
      StreamController<List<Spectator>>.broadcast();

  final StreamController<List<GameReplay>> _replaysController =
      StreamController<List<GameReplay>>.broadcast();

  Stream<List<Spectator>> get spectatorsStream => _spectatorsController.stream;
  Stream<List<GameReplay>> get replaysStream => _replaysController.stream;

  // Spectator Management
  Future<String> joinAsSpectator(
      String gameId, String spectatorId, String spectatorName) async {
    try {
      final spectator = Spectator(
        id: spectatorId,
        name: spectatorName,
        joinedAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('game_rooms')
          .doc(gameId)
          .collection('spectators')
          .doc(spectatorId)
          .set(spectator.toMap());

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

  StreamSubscription<List<SpectatorChatMessage>>? _chatSubscription;

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
      // In a real implementation, you'd have a controller for chat messages
      // For now, we'll just log them
      debugPrint('Spectator chat update: ${messages.length} messages');
    });
  }

  void stopListeningToSpectatorChat() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
  }

  void dispose() {
    _spectatorsController.close();
    _replaysController.close();
    _spectatorSubscription?.cancel();
    _chatSubscription?.cancel();
  }
}

// Data Models for Spectator Mode

class Spectator {
  final String id;
  final String name;
  final DateTime joinedAt;
  final bool isActive;
  final DateTime? lastActivity;

  Spectator({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.isActive = true,
    this.lastActivity,
  });

  factory Spectator.fromMap(Map<String, dynamic> map, String id) {
    return Spectator(
      id: id,
      name: map['name'] ?? '',
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
