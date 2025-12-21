import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/ai_recommendation.dart';
import '../services/ai_service.dart';

abstract class AIEvent {}

abstract class AIState {}

class LoadRecommendations extends AIEvent {
  final String userId;

  LoadRecommendations(this.userId);
}

class RecommendationsLoaded extends AIState {
  final List<AIRecommendation> recommendations;

  RecommendationsLoaded(this.recommendations);
}

class AIError extends AIState {
  final String message;

  AIError(this.message);
}

class AIBloc extends Bloc<AIEvent, AIState> {
  final AIService aiService;

  AIBloc(this.aiService) : super(AIInitial()) {
    on<LoadRecommendations>(_onLoadRecommendations);
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<AIState> emit,
  ) async {
    try {
      emit(AILoading());
      final data =
          await aiService.getPersonalizedQuizRecommendations(event.userId);

      final recommendations = (data['recommendations'] as List)
          .map((item) => AIRecommendation.fromJson(item))
          .toList();

      emit(RecommendationsLoaded(recommendations));
    } catch (e) {
      emit(AIError(e.toString()));
    }
  }
}

class AIInitial extends AIState {}

class AILoading extends AIState {}
