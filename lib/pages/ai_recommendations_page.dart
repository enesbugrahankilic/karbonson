import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../provides/ai_bloc.dart';
import '../widgets/ai_recommendation_widget.dart';

class AIRecommendationsPage extends StatelessWidget {
  const AIRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
      ),
      body: BlocBuilder<AIBloc, AIState>(
        builder: (context, state) {
          if (state is AILoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecommendationsLoaded) {
            return ListView.builder(
              itemCount: state.recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = state.recommendations[index];
                return AIRecommendationWidget(
                  recommendation: recommendation,
                  onTap: () {
                    // Navigate to quiz details
                  },
                );
              },
            );
          } else if (state is AIError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Load recommendations'));
          }
        },
      ),
    );
  }
}
