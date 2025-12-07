import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karbonson/models/user_data.dart';

class AIService {
  final String baseUrl;

  AIService({required this.baseUrl});

  Future<Map<String, dynamic>> getPersonalizedQuizRecommendations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommendations?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get recommendations');
    }
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