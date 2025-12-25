// lib/models/question.dart

/// Soru zorluk seviyeleri enum'u
enum DifficultyLevel {
  easy('Kolay'),
  medium('Orta'),
  hard('Zor');

  const DifficultyLevel(this.displayName);
  final String displayName;
}

class Option {
  final String text;
  final int score;

  Option({required this.text, required this.score});

  factory Option.fromMap(Map<String, dynamic> data) {
    return Option(
      text: data['text'] as String,
      score: data['score'] as int,
    );
  }
}

class Question {
  final String text;
  final List<Option> options;
  final String category;
  final DifficultyLevel difficulty;

  Question({
    required this.text,
    required this.options,
    this.category = 'Genel',
    this.difficulty = DifficultyLevel.medium,
  });

  /// Difficulty level'a göre puan çarpanı
  double get difficultyMultiplier {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 1.0;
      case DifficultyLevel.medium:
        return 2.0;
      case DifficultyLevel.hard:
        return 3.0;
    }
  }

  factory Question.fromMap(Map<String, dynamic> data) {
    final List<dynamic> optionsData = data['options'] as List<dynamic>;
    final options = optionsData
        .map((opt) => Option.fromMap(opt as Map<String, dynamic>))
        .toList();

    // Difficulty level'ı parse et
    DifficultyLevel difficulty = DifficultyLevel.medium;
    if (data['difficulty'] != null) {
      final difficultyStr = data['difficulty'] as String;
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

    return Question(
      text: data['text'] as String,
      options: options,
      category: data['category'] as String? ?? 'Genel',
      difficulty: difficulty,
    );
  }

  /// Difficulty seviyesini string olarak döndür
  String get difficultyDisplayName => difficulty.displayName;

  /// Difficulty seviyesine göre renk döndür
  String get difficultyColor {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'green';
      case DifficultyLevel.medium:
        return 'orange';
      case DifficultyLevel.hard:
        return 'red';
    }
  }
}
