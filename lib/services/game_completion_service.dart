// lib/services/game_completion_service.dart
// Quiz ve Oyun Tamamlama Backend Event Servisi

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/completion_data.dart';
import 'state_refresh_service.dart';
import 'daily_task_event_service.dart';

/// Backend completion event gönderme servisi
class GameCompletionService {
  static final GameCompletionService _instance = GameCompletionService._internal();
  factory GameCompletionService() => _instance;
  GameCompletionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Daily Task Event Service for automatic challenge progress updates
  final DailyTaskEventService _dailyTaskService = DailyTaskEventService();

  // Offline queue for pending events
  final List<String> _pendingEvents = [];
  bool _isInitialized = false;
  Timer? _syncTimer;

  /// Servisi başlat ve pending event'leri senkronize et
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load pending events from local storage
      await _loadPendingEvents();
      
      // Start periodic sync
      _startPeriodicSync();
      
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ GameCompletionService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing GameCompletionService: $e');
      }
    }
  }

  /// Periodic sync timer başlat
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncPendingEvents();
    });
  }

  /// Quiz completion event gönder
  Future<bool> sendQuizCompletion({
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpentSeconds,
    required String category,
    required String difficulty,
    required List<String> answers,
    required List<bool> correctAnswersList,
    String? quizId,
    Map<String, dynamic> additionalData = const {},
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('❌ No user logged in for quiz completion');
        }
        return false;
      }

      final event = QuizCompletionEvent(
        quizId: quizId,
        userId: userId,
        score: score,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        timeSpentSeconds: timeSpentSeconds,
        category: category,
        difficulty: difficulty,
        answers: answers,
        correctAnswersList: correctAnswersList,
        additionalData: additionalData,
      );

      // Send to Firestore
      final success = await _sendToFirestore(event.toJson(), 'quiz_completions');
      
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Quiz completion event sent: ${event.eventId}');
          debugPrint('   Score: $score/$totalQuestions, Category: $category');
        }
        
        // Trigger state refresh after successful completion
        _triggerRefreshAfterCompletion('quiz');
        
        // Update daily task challenge progress (event-driven)
        await _dailyTaskService.onQuizCompleted(
          category: category,
          score: score,
          correctAnswers: correctAnswers,
          difficulty: difficulty,
        );
      } else {
        // Add to queue for later
        await _addToQueue(event.toJsonString());
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending quiz completion: $e');
      }
      return false;
    }
  }

  /// Game completion event gönder
  Future<bool> sendGameCompletion({
    required String gameType,
    required int finalScore,
    required int quizScore,
    required int timeElapsedSeconds,
    required int position,
    required bool isWinner,
    required Map<String, dynamic> playerResults,
    String? roomId,
    String? gameId,
    Map<String, dynamic> additionalData = const {},
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('❌ No user logged in for game completion');
        }
        return false;
      }

      final event = GameCompletionEvent(
        gameId: gameId,
        roomId: roomId ?? '',
        userId: userId,
        gameType: gameType,
        finalScore: finalScore,
        quizScore: quizScore,
        timeElapsedSeconds: timeElapsedSeconds,
        position: position,
        isWinner: isWinner,
        playerResults: playerResults,
        additionalData: additionalData,
      );

      // Send to Firestore
      final success = await _sendToFirestore(event.toJson(), 'game_completions');
      
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Game completion event sent: ${event.eventId}');
          debugPrint('   GameType: $gameType, Score: $finalScore, Position: $position');
        }
        
        // Update daily task challenge progress (event-driven)
        // Only counts wins for duel/multiplayer challenges
        await _dailyTaskService.onGamePlayed(
          gameType: gameType,
          finalScore: finalScore,
          isWinner: isWinner,
          position: position,
        );
      } else {
        // Add to queue for later
        await _addToQueue(event.toJsonString());
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending game completion: $e');
      }
      return false;
    }
  }

  /// Generic completion event gönder
  Future<bool> sendCompletionEvent(CompletionEvent event) async {
    try {
      final collection = event.completionType == 'quiz' ? 'quiz_completions' : 'game_completions';
      final success = await _sendToFirestore(event.toJson(), collection);
      
      if (success) {
        if (kDebugMode) {
          debugPrint('✅ Completion event sent: ${event.eventId}');
        }
      } else {
        await _addToQueue(event.toJsonString());
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending completion event: $e');
      }
      return false;
    }
  }

  /// Firestore'a event gönder - retry mekanizması ve offline support ile
  Future<bool> _sendToFirestore(Map<String, dynamic> data, String collection) async {
    try {
      // Retry mekanizması: 3 kez dene, her deneme arasında 1 saniye bekle
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(seconds: 1);

      while (retryCount < maxRetries) {
        try {
          await _firestore.collection(collection).add({
            ...data,
            'createdAt': FieldValue.serverTimestamp(),
            'devicePlatform': defaultTargetPlatform.name.toString(),
          }).timeout(const Duration(seconds: 10));
          
          if (kDebugMode) {
            debugPrint('✅ Firestore write successful for $collection');
          }
          return true;
        } catch (e) {
          retryCount++;
          if (retryCount < maxRetries) {
            if (kDebugMode) {
              debugPrint('⚠️ Firestore retry $retryCount/$maxRetries for $collection: $e');
            }
            await Future.delayed(retryDelay);
          } else {
            throw e;
          }
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firestore error for $collection after retries: $e');
      }
      
      // Save to offline queue even if failed
      try {
        await _addToQueue(jsonEncode(data));
        if (kDebugMode) {
          debugPrint('✅ Data saved to offline queue: $collection');
        }
      } catch (queueError) {
        if (kDebugMode) {
          debugPrint('❌ Error adding to queue: $queueError');
        }
      }
      
      return false;
    }
  }

  /// Event'i queue'ya ekle (offline durum için)
  Future<void> _addToQueue(String eventJson) async {
    try {
      _pendingEvents.add(eventJson);
      await _savePendingEvents();
      
      if (kDebugMode) {
        debugPrint('⚠️ Event added to queue. Pending: ${_pendingEvents.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error adding to queue: $e');
      }
    }
  }

  /// Pending event'leri queue'dan yükle
  Future<void> _loadPendingEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList('pending_completion_events');
      if (eventsJson != null) {
        _pendingEvents.clear();
        _pendingEvents.addAll(eventsJson);
      }
      if (kDebugMode) {
        debugPrint('📦 Loaded ${_pendingEvents.length} pending events from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error loading pending events: $e');
      }
    }
  }

  /// Pending event'leri kaydet
  Future<void> _savePendingEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('pending_completion_events', _pendingEvents);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving pending events: $e');
      }
    }
  }

  /// Pending event'leri Firestore'a senkronize et
  Future<void> _syncPendingEvents() async {
    if (_pendingEvents.isEmpty) return;
    
    if (kDebugMode) {
      debugPrint('🔄 Syncing ${_pendingEvents.length} pending events...');
    }

    final List<String> failedEvents = [];
    
    for (final eventJson in List.from(_pendingEvents)) {
      try {
        final eventData = jsonDecode(eventJson) as Map<String, dynamic>;
        final completionType = eventData['completionType'] as String? ?? 'quiz';
        final collection = completionType == 'quiz' ? 'quiz_completions' : 'game_completions';
        
        final success = await _sendToFirestore(eventData, collection);
        if (success) {
          _pendingEvents.remove(eventJson);
        } else {
          failedEvents.add(eventJson);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error syncing event: $e');
        }
        failedEvents.add(eventJson);
      }
    }

    // Update pending events
    _pendingEvents.clear();
    _pendingEvents.addAll(failedEvents);
    await _savePendingEvents();

    if (kDebugMode) {
      debugPrint('✅ Sync complete. Remaining: ${_pendingEvents.length}');
    }
  }

  /// Manuel senkronizasyon tetikle
  Future<void> syncNow() async {
    await _syncPendingEvents();
  }

  /// Pending event sayısını getir
  int getPendingCount() => _pendingEvents.length;

  /// Servisi temizle (logout için)
  Future<void> dispose() async {
    _syncTimer?.cancel();
    _syncTimer = null;
    await _savePendingEvents();
    _isInitialized = false;
  }

  /// Trigger state refresh after successful completion
  /// This method calls StateRefreshService to update all related UI
  void _triggerRefreshAfterCompletion(String completionType) {
    try {
      if (completionType == 'quiz') {
        StateRefreshService().triggerQuizCompletionRefresh();
      } else if (completionType == 'game') {
        StateRefreshService().triggerGameCompletionRefresh();
      } else {
        StateRefreshService().triggerComprehensiveRefresh();
      }
      
      if (kDebugMode) {
        debugPrint('🔄 State refresh triggered after $completionType completion');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error triggering state refresh: $e');
      }
    }
  }
}

/// Quiz completion için yardımcı fonksiyon
class QuizCompletionHelper {
  /// Quiz completion eventi oluştur ve gönder
  static Future<bool> completeQuiz({
    required int score,
    required int totalQuestions,
    required int timeSpentSeconds,
    required String category,
    required String difficulty,
    required List<String> answers,
    required List<bool> correctAnswersList,
  }) async {
    final correctAnswers = correctAnswersList.where((a) => a).length;
    
    return await GameCompletionService().sendQuizCompletion(
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      timeSpentSeconds: timeSpentSeconds,
      category: category,
      difficulty: difficulty,
      answers: answers,
      correctAnswersList: correctAnswersList,
      additionalData: {
        'accuracy': totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).toStringAsFixed(1) : '0',
      },
    );
  }
}

/// Game completion için yardımcı fonksiyon
class GameCompletionHelper {
  /// Single player game completion
  static Future<bool> completeSinglePlayerGame({
    required int quizScore,
    required int timeElapsedSeconds,
    required int finalScore,
    required String nickname,
  }) async {
    return await GameCompletionService().sendGameCompletion(
      gameType: 'single_player',
      finalScore: finalScore,
      quizScore: quizScore,
      timeElapsedSeconds: timeElapsedSeconds,
      position: 1,
      isWinner: true,
      playerResults: {
        'players': [
          {
            'nickname': nickname,
            'quizScore': quizScore,
            'finalScore': finalScore,
          }
        ]
      },
      additionalData: {
        'gameMode': 'single_player',
      },
    );
  }

  /// Multiplayer game completion
  static Future<bool> completeMultiplayerGame({
    required String roomId,
    required int quizScore,
    required int timeElapsedSeconds,
    required int finalScore,
    required int position,
    required bool isWinner,
    required String nickname,
    required List<Map<String, dynamic>> allPlayers,
  }) async {
    // Find winner nickname
    final maxScore = allPlayers.map((e) => e['finalScore'] as int).reduce((a, b) => a > b ? a : b);
    final winnerNickname = allPlayers.firstWhere(
      (p) => p['finalScore'] == maxScore,
      orElse: () => {'nickname': ''},
    )['nickname'] as String? ?? '';
    
    return await GameCompletionService().sendGameCompletion(
      roomId: roomId,
      gameType: 'multiplayer',
      finalScore: finalScore,
      quizScore: quizScore,
      timeElapsedSeconds: timeElapsedSeconds,
      position: position,
      isWinner: isWinner,
      playerResults: {
        'players': allPlayers,
        'winnerNickname': winnerNickname,
      },
      additionalData: {
        'gameMode': 'multiplayer',
        'roomId': roomId,
      },
    );
  }
}

