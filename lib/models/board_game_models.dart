// lib/models/board_game_models.dart
// Board game models for environmental board game

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BoardTileType {
  energy,
  water,
  forest,
  recycling,
  transport,
  carbon,
  chance,
  community,
}

class BoardTile {
  final int id;
  final BoardTileType type;
  final int position;
  final String title;
  final String description;
  final int points;

  BoardTile({
    required this.id,
    required this.type,
    required this.position,
    required this.title,
    required this.description,
    required this.points,
  });
}

class BoardPlayer {
  final String id;
  final String nickname;
  final int position;
  final int points;
  final String? avatarUrl;
  final Color color;

  BoardPlayer({
    required this.id,
    required this.nickname,
    required this.position,
    required this.points,
    this.avatarUrl,
    required this.color,
  });
}

class BoardGameRoom {
  final String id;
  final String hostId;
  final String hostNickname;
  final List<BoardGamePlayer> players;
  final int currentPlayerIndex;
  final int currentTurn;
  final bool isGameActive;
  final DateTime createdAt;

  BoardGameRoom({
    required this.id,
    required this.hostId,
    required this.hostNickname,
    required this.players,
    this.currentPlayerIndex = 0,
    this.currentTurn = 1,
    this.isGameActive = false,
    required this.createdAt,
  });

  factory BoardGameRoom.fromMap(Map<String, dynamic> map) {
    return BoardGameRoom(
      id: map['id'] ?? '',
      hostId: map['hostId'] ?? '',
      hostNickname: map['hostNickname'] ?? '',
      players: (map['players'] as List<dynamic>? ?? [])
          .map((p) => BoardGamePlayer.fromMap(p as Map<String, dynamic>))
          .toList(),
      currentPlayerIndex: map['currentPlayerIndex'] ?? 0,
      currentTurn: map['currentTurn'] ?? 1,
      isGameActive: map['isGameActive'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hostId': hostId,
      'hostNickname': hostNickname,
      'players': players.map((p) => p.toMap()).toList(),
      'currentPlayerIndex': currentPlayerIndex,
      'currentTurn': currentTurn,
      'isGameActive': isGameActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class BoardGamePlayer {
  final String id;
  final String nickname;
  final int position;
  final int points;
  final String? avatarUrl;
  final Color? color;

  BoardGamePlayer({
    required this.id,
    required this.nickname,
    this.position = 0,
    this.points = 0,
    this.avatarUrl,
    this.color,
  });

  factory BoardGamePlayer.fromMap(Map<String, dynamic> map) {
    return BoardGamePlayer(
      id: map['id'] ?? '',
      nickname: map['nickname'] ?? '',
      position: map['position'] ?? 0,
      points: map['points'] ?? 0,
      avatarUrl: map['avatarUrl'],
      color: map['color'] != null ? Color(map['color']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'position': position,
      'points': points,
      'avatarUrl': avatarUrl,
      'color': color?.value,
    };
  }
}