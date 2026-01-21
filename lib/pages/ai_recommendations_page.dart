import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provides/ai_bloc.dart';
import '../widgets/ai_recommendation_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../utils/firebase_logger.dart';

class AIRecommendationsPage extends StatefulWidget {
  const AIRecommendationsPage({super.key});

  @override
  State<AIRecommendationsPage> createState() => _AIRecommendationsPageState();
}

class _AIRecommendationsPageState extends State<AIRecommendationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendations(context);
    });
  }

  void _loadRecommendations(BuildContext context) {
    if (kDebugMode) {
      debugPrint('🎯 [AI_PAGE] Loading AI recommendations...');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      BlocProvider.of<AIBloc>(context).add(LoadRecommendations(user.uid));
    } else {
      if (kDebugMode) {
        debugPrint('❌ [AI_PAGE] No user logged in');
      }
      // Handle not logged in case
      BlocProvider.of<AIBloc>(context).add(SetNotAuthenticated());
    }
  }

  Future<void> _refresh() async {
    if (kDebugMode) {
      debugPrint('🔄 [AI_PAGE] Refreshing recommendations...');
    }
    _loadRecommendations(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Önerileri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: BlocBuilder<AIBloc, AIState>(
        builder: (context, state) {
          if (state is AIInitial) {
            FirebaseLogger.logAIService(
              operation: 'INITIAL_STATE',
              success: true,
              responseSize: '0',
            );
            return const EmptyStateWidget(
              type: EmptyStateType.loading,
              showLoading: true,
            );
          } else if (state is AILoading) {
            FirebaseLogger.logAIService(
              operation: 'LOADING',
              success: true,
              responseSize: '0',
            );
            return const EmptyStateWidget(
              type: EmptyStateType.loading,
              showLoading: true,
              message: 'AI önerileri yükleniyor...',
            );
          } else if (state is RecommendationsLoaded) {
            FirebaseLogger.logAIService(
              operation: 'LOAD_SUCCESS',
              success: true,
              responseSize: '${state.recommendations.length}',
            );

            if (state.recommendations.isEmpty) {
              return EmptyStateWidget(
                type: EmptyStateType.noData,
                title: 'Öneri Yok',
                message: 'Şu için kişiselleştirilmiş öneriniz bulunmuyor. Daha fazla quiz çözerek öneriler alabilirsiniz.',
                onRetry: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = state.recommendations[index];
                  return AIRecommendationWidget(
                    recommendation: recommendation,
                    onTap: () {
                      if (kDebugMode) {
                        debugPrint('🎯 [AI_PAGE] Tapped recommendation: ${recommendation.quizTitle}');
                      }
                    },
                  );
                },
              ),
            );
          } else if (state is AIError) {
            FirebaseLogger.logAIService(
              operation: 'LOAD_ERROR',
              success: false,
              error: state.message,
            );

            return EmptyStateWidget(
              type: EmptyStateType.error,
              title: 'Hata Oluştu',
              message: state.message.isNotEmpty
                ? 'Hata: ${state.message}'
                : 'AI önerileri yüklenirken bir hata oluştu.',
              onRetry: _refresh,
              retryText: 'Tekrar Dene',
            );
          } else if (state is AINotAuthenticated) {
            return EmptyStateWidget(
              type: EmptyStateType.error,
              title: 'Oturum Açın',
              message: 'AI önerilerini görmek için lütfen oturum açın.',
              onRetry: _refresh,
              retryText: 'Yenile',
            );
          } else {
            return EmptyStateWidget(
              type: EmptyStateType.general,
              title: 'Öneriler',
              message: 'AI önerileri için bekleyin...',
              onRetry: _refresh,
            );
          }
        },
      ),
    );
  }
}

