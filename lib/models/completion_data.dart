// lib/models/completion_data.dart
// Quiz ve Oyun Tamamlama Event Veri Modeli

import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Quiz tamamlama event'i için veri modeli
class QuizCompletionEvent {
  final String eventId;
  final String eventType;
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpentSeconds;
  final String category;
  final String difficulty;
  final List<String> answers;
  final List<bool> correctAnswersList;
  final DateTime completedAt;
  final Map<String, dynamic> additionalData;

  QuizCompletionEvent({
    String? quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpentSeconds,
    required this.category,
    required this.difficulty,
    required this.answers,
    required this.correctAnswersList,
    DateTime? completedAt,
    this.additionalData = const {},
  })  : eventId = const Uuid().v4(),
        eventType = 'quiz_completion',
        quizId = quizId ?? const Uuid().v4(),
        completedAt = completedAt ?? DateTime.now();

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpentSeconds': timeSpentSeconds,
      'category': category,
      'difficulty': difficulty,
      'answers': answers,
      'correctAnswersList': correctAnswersList,
      'completedAt': completedAt.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  /// JSON deserialization
  factory QuizCompletionEvent.fromJson(Map<String, dynamic> json) {
    return QuizCompletionEvent(
      quizId: json['quizId'] as String?,
      userId: json['userId'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      timeSpentSeconds: json['timeSpentSeconds'] as int,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      answers: List<String>.from(json['answers'] as List),
      correctAnswersList: List<bool>.from(json['correctAnswersList'] as List),
      completedAt: DateTime.parse(json['completedAt'] as String),
      additionalData: Map<String, dynamic>.from(json['additionalData'] as Map? ?? {}),
    );
  }

  /// JSON string conversion
  String toJsonString() => jsonEncode(toJson());

  /// Calculate accuracy percentage
  double get accuracyPercentage {
    if (totalQuestions == 0) return 0.0;
    return (correctAnswers / totalQuestions) * 100;
  }

  /// Create a copy with updated fields
  QuizCompletionEvent copyWith({
    String? quizId,
    String? userId,
    int? score,
    int? totalQuestions,
    int? correctAnswers,
    int? timeSpentSeconds,
    String? category,
    String? difficulty,
    List<String>? answers,
    List<bool>? correctAnswersList,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return QuizCompletionEvent(
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      answers: answers ?? this.answers,
      correctAnswersList: correctAnswersList ?? this.correctAnswersList,
      completedAt: completedAt ?? this.completedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Oyun tamamlama event'i için veri modeli
class GameCompletionEvent {
  final String eventId;
  final String eventType;
  final String gameId;
  final String roomId;
  final String userId;
  final String gameType;
  final int finalScore;
  final int quizScore;
  final int timeElapsedSeconds;
  final int position;
  final bool isWinner;
  final DateTime completedAt;
  final Map<String, dynamic> playerResults;
  final Map<String, dynamic> additionalData;

  GameCompletionEvent({
    String? gameId,
    required this.roomId,
    required this.userId,
    required this.gameType,
    required this.finalScore,
    required this.quizScore,
    required this.timeElapsedSeconds,
    required this.position,
    required this.isWinner,
    required this.playerResults,
    this.additionalData = const {},
  })  : eventId = const Uuid().v4(),
        eventType = 'game_completion',
        gameId = gameId ?? const Uuid().v4(),
        completedAt = DateTime.now();

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'gameId': gameId,
      'roomId': roomId,
      'userId': userId,
      'gameType': gameType,
      'finalScore': finalScore,
      'quizScore': quizScore,
      'timeElapsedSeconds': timeElapsedSeconds,
      'position': position,
      'isWinner': isWinner,
      'completedAt': completedAt.toIso8601String(),
      'playerResults': playerResults,
      'additionalData': additionalData,
    };
  }

  /// JSON deserialization
  factory GameCompletionEvent.fromJson(Map<String, dynamic> json) {
    return GameCompletionEvent(
      gameId: json['gameId'] as String?,
      roomId: json['roomId'] as String,
      userId: json['userId'] as String,
      gameType: json['gameType'] as String,
      finalScore: json['finalScore'] as int,
      quizScore: json['quizScore'] as int,
      timeElapsedSeconds: json['timeElapsedSeconds'] as int,
      position: json['position'] as int,
      isWinner: json['isWinner'] as bool,
      playerResults: Map<String, dynamic>.from(json['playerResults'] as Map),
      additionalData: Map<String, dynamic>.from(json['additionalData'] as Map? ?? {}),
    );
  }

  /// JSON string conversion
  String toJsonString() => jsonEncode(toJson());

  /// Create a copy with updated fields
  GameCompletionEvent copyWith({
    String? gameId,
    String? roomId,
    String? userId,
    String? gameType,
    int? finalScore,
    int? quizScore,
    int? timeElapsedSeconds,
    int? position,
    bool? isWinner,
    Map<String, dynamic>? playerResults,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return GameCompletionEvent(
      gameId: gameId ?? this.gameId,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      finalScore: finalScore ?? this.finalScore,
      quizScore: quizScore ?? this.quizScore,
      timeElapsedSeconds: timeElapsedSeconds ?? this.timeElapsedSeconds,
      position: position ?? this.position,
      isWinner: isWinner ?? this.isWinner,
      playerResults: playerResults ?? this.playerResults,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Genel completion event wrapper
class CompletionEvent {
  final String eventId;
  final String eventType;
  final String quizId;
  final String gameId;
  final String roomId;
  final String userId;
  final String completionType;
  final int score;
  final int totalItems;
  final int correctItems;
  final int timeSpentSeconds;
  final String category;
  final String difficulty;
  final String gameType;
  final List<String> answers;
  final List<bool> correctAnswersList;
  final DateTime completedAt;
  final Map<String, dynamic> metadata;

  CompletionEvent._({
    required this.eventId,
    required this.eventType,
    required this.quizId,
    required this.gameId,
    required this.roomId,
    required this.userId,
    required this.completionType,
    required this.score,
    required this.totalItems,
    required this.correctItems,
    required this.timeSpentSeconds,
    required this.category,
    required this.difficulty,
    required this.gameType,
    required this.answers,
    required this.correctAnswersList,
    required this.completedAt,
    required this.metadata,
  });

  /// Quiz'den CompletionEvent oluştur
  factory CompletionEvent.fromQuizCompletion(QuizCompletionEvent quizEvent) {
    return CompletionEvent._(
      eventId: quizEvent.eventId,
      eventType: quizEvent.eventType,
      quizId: quizEvent.quizId,
      gameId: '',
      roomId: '',
      userId: quizEvent.userId,
      completionType: 'quiz',
      score: quizEvent.score,
      totalItems: quizEvent.totalQuestions,
      correctItems: quizEvent.correctAnswers,
      timeSpentSeconds: quizEvent.timeSpentSeconds,
      category: quizEvent.category,
      difficulty: quizEvent.difficulty,
      gameType: '',
      answers: quizEvent.answers,
      correctAnswersList: quizEvent.correctAnswersList,
      completedAt: quizEvent.completedAt,
      metadata: quizEvent.additionalData,
    );
  }

  /// Game'den CompletionEvent oluştur
  factory CompletionEvent.fromGameCompletion(GameCompletionEvent gameEvent) {
    return CompletionEvent._(
      eventId: gameEvent.eventId,
      eventType: gameEvent.eventType,
      quizId: '',
      gameId: gameEvent.gameId,
      roomId: gameEvent.roomId,
      userId: gameEvent.userId,
      completionType: 'game',
      score: gameEvent.finalScore,
      totalItems: gameEvent.quizScore,
      correctItems: gameEvent.position,
      timeSpentSeconds: gameEvent.timeElapsedSeconds,
      category: '',
      difficulty: '',
      gameType: gameEvent.gameType,
      answers: [],
      correctAnswersList: [],
      completedAt: gameEvent.completedAt,
      metadata: {
        'playerResults': gameEvent.playerResults,
        'isWinner': gameEvent.isWinner,
        ...gameEvent.additionalData,
      },
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'quizId': quizId,
      'gameId': gameId,
      'roomId': roomId,
      'userId': userId,
      'completionType': completionType,
      'score': score,
      'totalItems': totalItems,
      'correctItems': correctItems,
      'timeSpentSeconds': timeSpentSeconds,
      'category': category,
      'difficulty': difficulty,
      'gameType': gameType,
      'answers': answers,
      'correctAnswersList': correctAnswersList,
      'completedAt': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// JSON string conversion
  String toJsonString() => jsonEncode(toJson());

  /// Pretty print for debugging
  String toPrettyString() {
    final buffer = StringBuffer();
    buffer.writeln('CompletionEvent {');
    buffer.writeln('  eventId: $eventId');
    buffer.writeln('  eventType: $eventType');
    buffer.writeln('  completionType: $completionType');
    buffer.writeln('  userId: $userId');
    buffer.writeln('  score: $score / $totalItems');
    buffer.writeln('  timeSpent: ${timeSpentSeconds}s');
    buffer.writeln('  completedAt: $completedAt');
    buffer.writeln('}');
    return buffer.toString();
  }
}

