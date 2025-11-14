// lib/models/question.dart

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

  Question({required this.text, required this.options});

  factory Question.fromMap(Map<String, dynamic> data) {
    final List<dynamic> optionsData = data['options'] as List<dynamic>;
    final options = optionsData.map((opt) => Option.fromMap(opt as Map<String, dynamic>)).toList();
    
    return Question(
      text: data['text'] as String,
      options: options,
    );
  }
}