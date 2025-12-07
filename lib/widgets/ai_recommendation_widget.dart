import 'package:flutter/material.dart';
import '../models/ai_recommendation.dart';

class AIRecommendationWidget extends StatelessWidget {
  final AIRecommendation recommendation;
  final VoidCallback onTap;

  const AIRecommendationWidget({
    Key? key,
    required this.recommendation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(recommendation.quizTitle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${recommendation.category}'),
            Text('Confidence: ${(recommendation.confidenceScore * 100).toStringAsFixed(1)}%'),
            Text('Reason: ${recommendation.reason}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}