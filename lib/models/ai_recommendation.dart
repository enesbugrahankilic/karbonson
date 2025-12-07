class AIRecommendation {
  final String quizId;
  final String quizTitle;
  final String category;
  final double confidenceScore;
  final String reason;

  AIRecommendation({
    required this.quizId,
    required this.quizTitle,
    required this.category,
    required this.confidenceScore,
    required this.reason,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      quizId: json['quizId'],
      quizTitle: json['quizTitle'],
      category: json['category'],
      confidenceScore: json['confidenceScore'].toDouble(),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'category': category,
      'confidenceScore': confidenceScore,
      'reason': reason,
    };
  }
}