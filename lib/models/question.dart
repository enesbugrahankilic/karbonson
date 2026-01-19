// lib/models/question.dart
// Enhanced Question Model with time limit, explanations, and tags

import 'package:flutter/material.dart';

/// Soru zorluk seviyeleri enum'u
enum DifficultyLevel {
  easy('Kolay', 1.0, Colors.green),
  medium('Orta', 2.0, Colors.orange),
  hard('Zor', 3.0, Colors.red);

  const DifficultyLevel(this.displayName, this.pointMultiplier, this.color);
  final String displayName;
  final double pointMultiplier;
  final Color color;
}

/// Quiz kategori enum'u
enum QuizCategory {
  all('Tümü', Icons.public, Colors.purple),
  energy('Enerji', Icons.bolt, Colors.orange),
  water('Su', Icons.water_drop, Colors.blue),
  forest('Orman', Icons.forest, Colors.green),
  recycling('Geri Dönüşüm', Icons.recycling, Colors.teal),
  transportation('Ulaşım', Icons.directions_car, Colors.indigo),
  consumption('Tüketim', Icons.shopping_cart, Colors.pink);

  const QuizCategory(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;

  String get questionCountKey => '${name}_questions';

  static String getQuestionCountKey(QuizCategory category) {
    return '${category.name}_questions';
  }
}

class Option {
  final String text;
  final int score;
  final String? feedback;

  Option({
    required this.text,
    required this.score,
    this.feedback,
  });

  bool get isCorrect => score > 0;

  factory Option.fromMap(Map<String, dynamic> data) {
    return Option(
      text: data['text'] as String,
      score: data['score'] as int,
      feedback: data['feedback'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'score': score,
      'feedback': feedback,
    };
  }

  Option copyWith({
    String? text,
    int? score,
    String? feedback,
  }) {
    return Option(
      text: text ?? this.text,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<Option> options;
  final String category;
  final DifficultyLevel difficulty;
  final int timeLimit; // saniye cinsinden
  final String? explanation; // Doğru cevap açıklaması
  final List<String> tags; // Soru etiketleri
  final String? imageUrl; // Opcional görsel

  Question({
    String? id,
    required this.text,
    required this.options,
    this.category = 'Genel',
    this.difficulty = DifficultyLevel.medium,
    this.timeLimit = 30,
    this.explanation,
    this.tags = const [],
    this.imageUrl,
  }) : id = id ?? '${category}_${text.hashCode}';

  /// Difficulty level'a göre puan çarpanı
  double get difficultyMultiplier => difficulty.pointMultiplier;

  /// Temel puan (zorluk çarpanı olmadan)
  int get basePoints {
    final correctOption = options.firstWhere((o) => o.isCorrect, orElse: () => options[0]);
    return correctOption.score.abs();
  }

  /// Zorluk ile hesaplanan toplam puan
  int get totalPoints => (basePoints * difficultyMultiplier).round();

  /// Doğru cevabı bul
  Option get correctOption => options.firstWhere(
        (o) => o.isCorrect,
        orElse: () => options[0],
      );

  /// Cevap seçeneklerini karıştır (görüntüleme için)
  List<Option> get shuffledOptions {
    final shuffled = List<Option>.from(options);
    shuffled.shuffle();
    return shuffled;
  }

  /// Sorunun metin uzunluğuna göre tahmini süre
  int get estimatedTime {
    final wordCount = text.split(' ').length;
    // Her kelime için yaklaşık 1 saniye, minimum 15 saniye
    return (wordCount * 0.8).clamp(15, timeLimit).toInt();
  }

  factory Question.fromMap(Map<String, dynamic> data) {
    final List<dynamic> optionsData = data['options'] as List<dynamic>;
    final options = optionsData
        .map((opt) => Option.fromMap(opt as Map<String, dynamic>))
        .toList();

    // Difficulty level'ı parse et
    DifficultyLevel difficulty = DifficultyLevel.medium;
    if (data['difficulty'] != null) {
      final difficultyStr = data['difficulty'].toString();
      switch (difficultyStr.toLowerCase()) {
        case 'easy':
        case 'kolay':
          difficulty = DifficultyLevel.easy;
          break;
        case 'hard':
        case 'zor':
          difficulty = DifficultyLevel.hard;
          break;
        case 'medium':
        case 'orta':
        default:
          difficulty = DifficultyLevel.medium;
          break;
      }
    }

    // Tags'i parse et
    List<String> tags = [];
    if (data['tags'] != null) {
      if (data['tags'] is List) {
        tags = List<String>.from(data['tags'] as List);
      } else if (data['tags'] is String) {
        tags = (data['tags'] as String).split(',').map((t) => t.trim()).toList();
      }
    }

    return Question(
      id: data['id'] as String?,
      text: data['text'] as String,
      options: options,
      category: data['category'] as String? ?? 'Genel',
      difficulty: difficulty,
      timeLimit: data['timeLimit'] as int? ?? 30,
      explanation: data['explanation'] as String?,
      tags: tags,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options.map((o) => o.toMap()).toList(),
      'category': category,
      'difficulty': difficulty.name,
      'timeLimit': timeLimit,
      'explanation': explanation,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  Question copyWith({
    String? id,
    String? text,
    List<Option>? options,
    String? category,
    DifficultyLevel? difficulty,
    int? timeLimit,
    String? explanation,
    List<String>? tags,
    String? imageUrl,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Difficulty seviyesini string olarak döndür
  String get difficultyDisplayName => difficulty.displayName;

  /// Soru zorluk seviyesi renk getter'ı
  Color get difficultyColor => difficulty.color;

  /// Kategori rengi
  Color get categoryColor {
    try {
      final categoryEnum = QuizCategory.values.firstWhere(
        (c) => c.name == category.toLowerCase(),
        orElse: () => QuizCategory.all,
      );
      return categoryEnum.color;
    } catch (_) {
      return Colors.purple;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Quiz sonuç modeli
class QuizResult {
  final String quizId;
  final int totalQuestions;
  final int correctAnswers;
  final int totalPoints;
  final int timeSpent; // saniye cinsinden
  final DateTime completedAt;
  final String category;
  final DifficultyLevel difficulty;

  QuizResult({
    required this.quizId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalPoints,
    required this.timeSpent,
    required this.completedAt,
    required this.category,
    required this.difficulty,
  });

  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0;

  int get wrongAnswers => totalQuestions - correctAnswers;

  String get accuracyPercentage => '${(accuracy * 100).toStringAsFixed(1)}%';

  String get formattedTime {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    return '${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'totalPoints': totalPoints,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
      'category': category,
      'difficulty': difficulty.name,
      'accuracy': accuracy,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> data) {
    return QuizResult(
      quizId: data['quizId'] as String,
      totalQuestions: data['totalQuestions'] as int,
      correctAnswers: data['correctAnswers'] as int,
      totalPoints: data['totalPoints'] as int,
      timeSpent: data['timeSpent'] as int,
      completedAt: DateTime.parse(data['completedAt'] as String),
      category: data['category'] as String,
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == data['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
    );
  }
}

