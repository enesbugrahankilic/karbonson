import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karbonson/models/user_data.dart';

class AIService {
  final String baseUrl;

  AIService({this.baseUrl = 'http://localhost:5001'});

  Future<Map<String, dynamic>> getPersonalizedQuizRecommendations(
      String userId, int? classLevel) async {
    try {
      final queryParams = {
        'user_id': userId,
        if (classLevel != null) 'class_level': classLevel.toString(),
      };
      final uri = Uri.parse('$baseUrl/recommendations').replace(queryParameters: queryParams);

      print('AI Service: Getting recommendations for user $userId, class level: $classLevel');
      print('AI Service: Request URL: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recommendations');
      }
    } catch (e) {
      print('AI Service: Error connecting to AI service: $e');
      // Return fallback recommendations
      return _getFallbackRecommendations(userId, classLevel);
    }
  }

  Map<String, dynamic> _getFallbackRecommendations(String userId, int? classLevel) {
    // Generate basic fallback recommendations based on class level
    final recommendations = <Map<String, dynamic>>[];

    if (classLevel != null) {
      if (classLevel <= 9) {
        recommendations.addAll([
          {
            'quizId': 'fallback_1',
            'quizTitle': 'Temel Çevre Bilgisi',
            'category': 'Genel',
            'confidenceScore': 0.8,
            'reason': 'Fallback recommendation for elementary level'
          },
          {
            'quizId': 'fallback_2',
            'quizTitle': 'Doğa ve Çevre',
            'category': 'Doğa',
            'confidenceScore': 0.7,
            'reason': 'Fallback recommendation for elementary level'
          }
        ]);
      } else {
        recommendations.addAll([
          {
            'quizId': 'fallback_3',
            'quizTitle': 'İleri Çevre Bilimleri',
            'category': 'Bilim',
            'confidenceScore': 0.8,
            'reason': 'Fallback recommendation for high school level'
          },
          {
            'quizId': 'fallback_4',
            'quizTitle': 'Çevre ve Teknoloji',
            'category': 'Teknoloji',
            'confidenceScore': 0.7,
            'reason': 'Fallback recommendation for high school level'
          }
        ]);
      }
    } else {
      recommendations.addAll([
        {
          'quizId': 'fallback_5',
          'quizTitle': 'Genel Çevre Bilgisi',
          'category': 'Genel',
          'confidenceScore': 0.6,
          'reason': 'General fallback recommendation'
        }
      ]);
    }

    return {'recommendations': recommendations};
  }

  Future<Map<String, dynamic>> analyzeUserBehavior(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analyze?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze user behavior');
    }
  }

  Future<void> sendUserData(UserData userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user_data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData.toMap()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send user data');
    }
  }
}
