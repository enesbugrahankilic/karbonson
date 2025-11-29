// lib/services/quiz_logic.dart
import '../models/question.dart';
import '../data/questions_database.dart';
import '../services/language_service.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'notification_service.dart';

class QuizLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentScore = 0;
  int _highScore = 0;
  final List<String> _answeredQuestions = [];
  final Set<String> _usedQuestionIds = {}; // Track questions used across sessions
  DateTime? _lastPlayTime;
  final List<Question> _allQuestions = []; // Will be populated from database
  AppLanguage _currentLanguage = AppLanguage.turkish;

  List<Question> questions = [];
  final Random _random = Random();

  QuizLogic() {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('highScore') ?? 0;
      final lastPlayTimeMillis = prefs.getInt('lastPlayTime');
      if (lastPlayTimeMillis != null) {
        _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(lastPlayTimeMillis);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading high score: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _highScore);
      if (_lastPlayTime != null) {
        await prefs.setInt('lastPlayTime', _lastPlayTime!.millisecondsSinceEpoch);
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('scores').doc(userId).set({
          'highScore': _highScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving high score: $e');
    }
  }

  void _selectRandomQuestions(int count, {AppLanguage? language}) {
    // Use provided language or default to current language
    final selectedLanguage = language ?? _currentLanguage;
    
    // Get questions from database in selected language
    final allAvailableQuestions = QuestionsDatabase.getQuestions(selectedLanguage);
    
    // Clear answered questions for new session to ensure variety
    _answeredQuestions.clear();
    
    var regularQuestions = allAvailableQuestions.where((q) => q.options.length == 4).toList();
    var bonusQuestions = allAvailableQuestions.where((q) => q.options.length == 5).toList();

    // Filter out already used questions to prevent duplicates
    var availableRegular = regularQuestions.where((q) => !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage))).toList();
    var availableBonus = bonusQuestions.where((q) => !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage))).toList();

    // If we've used too many questions, reset the used set for this language
    if (availableRegular.length + availableBonus.length < count) {
      _usedQuestionIds.clear();
      availableRegular = regularQuestions;
      availableBonus = bonusQuestions;
    }

    availableRegular.shuffle(_random);
    availableBonus.shuffle(_random);

    questions = [];
    int selected = 0;

    // Select regular questions first
    for (var q in availableRegular) {
      if (selected >= count) break;
      questions.add(q);
      _answeredQuestions.add(q.text);
      _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
      selected++;
    }

    // If still need more questions, select from bonus questions
    for (var q in availableBonus) {
      if (selected >= count) break;
      questions.add(q);
      _answeredQuestions.add(q.text);
      _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
      selected++;
    }

    // If still need more questions (edge case), allow duplicates
    if (selected < count) {
      var allQuestions = List<Question>.from(allAvailableQuestions);
      allQuestions.shuffle(_random);
      
      for (var q in allQuestions) {
        if (selected >= count) break;
        if (!questions.contains(q)) {
          questions.add(q);
          _answeredQuestions.add(q.text);
          selected++;
        }
      }
    }
  }

  String _getQuestionId(Question question, AppLanguage language) {
    // Create a unique ID for each question per language
    return '${language.code}_${question.text.hashCode}';
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      // Refresh questions for new language if quiz is active
      if (questions.isNotEmpty) {
        await startNewQuiz();
      }
    }
  }

  Future<List<Question>> getQuestions() async {
    return questions;
  }

  Future<bool> checkAnswer(Question question, String answer) async {
    Option selectedOption = question.options.firstWhere(
      (option) => option.text == answer,
      orElse: () => Option(text: '', score: 0),
    );

    _currentScore += selectedOption.score;

    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      await _saveHighScore();
      // Send notification for new high score
      try {
        await NotificationService.scheduleHighScoreNotification();
      } catch (e) {
        if (kDebugMode) debugPrint('Error sending high score notification: $e');
      }
    }

    return selectedOption.score > 0;
  }

  int getCurrentScore() => _currentScore;
  
  int getHighScore() => _highScore;

  void resetScore() {
    _currentScore = 0;
  }

  Future<void> startNewQuiz() async {
    resetScore();
    _selectRandomQuestions(15); // 15 questions per quiz
    await _loadHighScore();
    _lastPlayTime = DateTime.now();
    await _saveHighScore(); // Save last play time
  }

  // Preload questions for immediate access
  Future<void> preloadQuestions() async {
    _selectRandomQuestions(15);
  }

  // Get total number of available questions for current language
  int getTotalQuestions() {
    return QuestionsDatabase.getTotalQuestions(_currentLanguage);
  }

  // Get debug information about current quiz session
  Map<String, dynamic> getQuizDebugInfo() {
    return {
      'totalQuestions': getTotalQuestions(),
      'currentSessionQuestions': questions.length,
      'answeredQuestionsCount': _answeredQuestions.length,
      'currentSessionQuestionTexts': questions.map((q) => q.text).toList(),
      'usedQuestionIds': _usedQuestionIds.toList(),
      'currentLanguage': _currentLanguage.code,
    };
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('scores')
          .orderBy('highScore', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userId': doc.id,
          'highScore': data['highScore'] ?? 0,
          'lastUpdated': data['lastUpdated'],
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  Future<void> saveGameResults(int score, List<String> answeredQuestions) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('game_results').add({
          'userId': userId,
          'score': score,
          'answeredQuestions': answeredQuestions,
          'language': _currentLanguage.code,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving game results: $e');
    }
  }

  // 12-hour reminder check
  Future<void> checkAndSendReminderNotification() async {
    if (_lastPlayTime == null) return;

    final now = DateTime.now();
    final difference = now.difference(_lastPlayTime!);

    if (difference.inHours >= 12) {
      try {
        await NotificationService.scheduleReminderNotification();
        if (kDebugMode) debugPrint('Reminder notification sent after ${difference.inHours} hours');
      } catch (e) {
        if (kDebugMode) debugPrint('Error sending reminder notification: $e');
      }
    }
  }

  // Get current language
  AppLanguage get currentLanguage => _currentLanguage;
  
  // Clear used questions (for testing or reset purposes)
  void clearUsedQuestions() {
    _usedQuestionIds.clear();
  }
}