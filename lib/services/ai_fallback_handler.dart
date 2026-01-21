// lib/services/ai_fallback_handler.dart
// Handle AI service failures gracefully with fallback recommendations

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';
import 'analytics_service.dart';

class AIFallbackHandler {
  static final AIFallbackHandler _instance = AIFallbackHandler._internal();
  factory AIFallbackHandler() => _instance;
  AIFallbackHandler._internal();

  static const Duration _aiTimeout = Duration(seconds: 10);
  static const int _maxRetries = 2;

  /// Get recommendations with fallback
  Future<List<String>> getRecommendationsWithFallback({
    required String userId,
    required int userLevel,
    required int userScore,
    required Function() aiCall, // The actual AI service call
  }) async {
    try {
      // Try AI service with timeout
      try {
        final result = await aiCall().timeout(_aiTimeout);

        if (result != null && result.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('✅ AI recommendations received: ${result.length}');
          }

          await AnalyticsService().logCustomEvent('ai_recommendations_success', {
            'count': result.length,
          });

          return result;
        }
      } on TimeoutException {
        if (kDebugMode) debugPrint('⏱️ AI service timeout');
        await AnalyticsService().logError('AITimeout', 'AI service took too long');
      } catch (e) {
        if (kDebugMode) debugPrint('❌ AI service error: $e');
        await AnalyticsService().logError('AIServiceError', e.toString());
      }

      // Fallback to rule-based recommendations
      if (kDebugMode) {
        debugPrint('🔄 Falling back to rule-based recommendations');
      }

      final fallbackRecs = _generateFallbackRecommendations(userLevel, userScore);

      await AnalyticsService().logCustomEvent('ai_fallback_used', {
        'count': fallbackRecs.length,
        'reason': 'ai_unavailable',
      });

      return fallbackRecs;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Fallback error: $e');

      // Last resort: empty recommendations
      await AnalyticsService().logError('AIFallbackError', e.toString());

      return [];
    }
  }

  /// Generate rule-based fallback recommendations
  List<String> _generateFallbackRecommendations(int userLevel, int userScore) {
    final recommendations = <String>[];

    // Level-based recommendations
    if (userLevel < 5) {
      recommendations.addAll([
        'Başlangıç seviyesi sorularını çöz',
        'Temel konuları güçlendir',
        'Her gün 5 dakika pratik yap',
      ]);
    } else if (userLevel < 10) {
      recommendations.addAll([
        'Orta seviye sorularını dene',
        'Hızını geliştir',
        'Farklı kategorileri keşfet',
      ]);
    } else if (userLevel < 20) {
      recommendations.addAll([
        'Zor seviyelere geç',
        'Rakiplerle duel oyna',
        'Başarıları topla',
      ]);
    } else {
      recommendations.addAll([
        'Uzman seviye sorularında kaldığın noktayı tamamla',
        'Arkadaşlarla yarışma',
        'Lider tahtasında yerini al',
      ]);
    }

    // Performance-based recommendations
    if (userScore < 30) {
      recommendations.add('Daha fazla alıştırma yapman gerekiyor');
    } else if (userScore < 70) {
      recommendations.add('Gelişim gösteriyorsun, devam et!');
    } else {
      recommendations.add('Mükemmel performans! Daha da iyileş.');
    }

    return recommendations;
  }

  /// Get difficulty suggestion with fallback
  Future<String> getDifficultySuggestionWithFallback({
    required int userLevel,
    required int recentScore,
    required Function() aiCall,
  }) async {
    try {
      try {
        final result = await aiCall().timeout(_aiTimeout);

        if (result != null && result.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('✅ AI difficulty suggestion: $result');
          }

          return result;
        }
      } on TimeoutException {
        if (kDebugMode) debugPrint('⏱️ AI timeout for difficulty');
      } catch (e) {
        if (kDebugMode) debugPrint('❌ AI error for difficulty: $e');
      }

      // Fallback to rule-based logic
      if (kDebugMode) {
        debugPrint('🔄 Using rule-based difficulty suggestion');
      }

      return _generateFallbackDifficulty(userLevel, recentScore);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Difficulty fallback error: $e');
      return 'medium'; // Safe default
    }
  }

  /// Generate rule-based difficulty suggestion
  String _generateFallbackDifficulty(int userLevel, int recentScore) {
    // If recent score is high, suggest harder difficulty
    if (recentScore > 85) {
      return 'hard';
    }

    // If recent score is low, suggest easier difficulty
    if (recentScore < 60) {
      return 'easy';
    }

    // Default to medium
    return 'medium';
  }

  /// Check AI service health
  Future<bool> isAIServiceHealthy({
    required Function() healthCheck,
  }) async {
    try {
      await healthCheck().timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ AI service unhealthy: $e');
      return false;
    }
  }

  /// Retry AI call with exponential backoff
  Future<T?> retryAICall<T>({
    required Future<T> Function() call,
    int maxAttempts = _maxRetries,
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (kDebugMode) {
          debugPrint('🔄 AI retry attempt $attempt/$maxAttempts');
        }

        return await call().timeout(_aiTimeout);
      } catch (e) {
        if (attempt == maxAttempts) {
          if (kDebugMode) {
            debugPrint('❌ AI call failed after $maxAttempts attempts: $e');
          }

          await AnalyticsService().logError('AIRetryFailed', 'Failed after $maxAttempts attempts: $e');

          return null;
        }

        // Exponential backoff
        final delayMs = 500 * (2 ^ (attempt - 1));
        if (kDebugMode) {
          debugPrint('⏳ Waiting ${delayMs}ms before retry');
        }

        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    return null;
  }
}
