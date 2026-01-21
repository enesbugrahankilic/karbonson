// lib/utils/firebase_logger.dart
// Firebase Logger Utility for debugging and monitoring

import 'package:flutter/foundation.dart';

class FirebaseLogger {
  static bool _enabled = true;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  // Helper for string truncation
  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Generic log method for general operations
  static void log(String category, String message, {dynamic error}) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    
    if (kDebugMode) {
      print('[$timestamp] 📋 $category: $message');
      if (error != null) {
        print('    Error: $error');
      }
    }
  }

  // Firebase Read Operations
  static void logRead({
    required String collection,
    String? documentId,
    String? operation,
    bool success = true,
    dynamic error,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final status = success ? '✅' : '❌';
    final docInfo = documentId != null ? '/$documentId' : '';
    
    if (kDebugMode) {
      print('[$timestamp] $status FIRESTORE READ: $collection$docInfo | Operation: $operation');
      if (error != null) {
        print('    Error: $error');
      }
    }
  }

  // Firebase Write Operations
  static void logWrite({
    required String collection,
    String? documentId,
    required String operation,
    Map<String, dynamic>? data,
    bool success = true,
    dynamic error,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final status = success ? '✅' : '❌';
    final docInfo = documentId != null ? '/$documentId' : '';
    
    if (kDebugMode) {
      print('[$timestamp] $status FIRESTORE WRITE: $collection$docInfo | Operation: $operation');
      if (data != null && kDebugMode) {
        print('    Data: ${_truncate(data.toString(), 200)}');
      }
      if (error != null && !success) {
        print('    Error: $error');
      }
    }
  }

  // Duel Room Operations
  static void logDuelRoom({
    required String roomId,
    required String operation,
    String? playerId,
    bool success = true,
    dynamic error,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final status = success ? '✅' : '❌';
    final roomShort = roomId.length > 8 ? roomId.substring(0, 8) : roomId;
    final playerInfo = playerId != null ? ' | Player: ${playerId.substring(0, 8)}...' : '';
    
    if (kDebugMode) {
      print('[$timestamp] $status DUEL ROOM: $operation | Room: $roomShort$playerInfo');
      if (error != null && !success) {
        print('    Error: $error');
      }
    }
  }

  // Player Join/Leave Operations
  static void logPlayerAction({
    required String roomId,
    required String playerId,
    required String nickname,
    required String action,
    bool success = true,
    dynamic error,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final status = success ? '✅' : '❌';
    final roomShort = roomId.length > 8 ? roomId.substring(0, 8) : roomId;
    
    if (kDebugMode) {
      print('[$timestamp] $status PLAYER ACTION: $action | Room: $roomShort | Nickname: $nickname');
      if (error != null && !success) {
        print('    Error: $error');
      }
    }
  }

  // Game State Changes
  static void logGameState({
    required String roomId,
    required String state,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final roomShort = roomId.length > 8 ? roomId.substring(0, 8) : roomId;
    
    if (kDebugMode) {
      print('[$timestamp] 🎮 GAME STATE: $state | Room: $roomShort');
      if (additionalData != null && kDebugMode) {
        print('    Data: $additionalData');
      }
    }
  }

  // AI Service Operations
  static void logAIService({
    required String operation,
    bool success = true,
    dynamic error,
    String? responseSize,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final status = success ? '✅' : '❌';
    
    if (kDebugMode) {
      print('[$timestamp] $status AI SERVICE: $operation | Response: $responseSize');
      if (error != null && !success) {
        print('    Error: $error');
      }
    }
  }

  // Connection State
  static void logConnection({
    required String service,
    required bool connected,
    String? details,
  }) {
    if (!_enabled) return;
    
    final timestamp = DateTime.now().toIso8601String();
    final status = connected ? '🟢' : '🔴';
    
    if (kDebugMode) {
      print('[$timestamp] $status CONNECTION: $service | Connected: $connected');
      if (details != null) {
        print('    Details: $details');
      }
    }
  }
}

