// lib/services/quiz_logic.dart
import '../models/question.dart';
import '../data/questions_database.dart';
import '../services/language_service.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

class QuizLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentScore = 0;
  int _highScore = 0;
  final List<String> _answeredQuestions = [];
  final Set<String> _usedQuestionIds =
      {}; // Track questions used across sessions
  DateTime? _lastPlayTime;
  final List<Question> _allQuestions = []; // Will be populated from database
  AppLanguage _currentLanguage = AppLanguage.turkish;
  final Map<String, int> _wrongAnswerCategories =
      {}; // Track wrong answers by category

  List<Question> questions = [];
  final Random _random = Random();

  // YENİ ZORLUK SEVİYESİ PROPERTIES
  DifficultyLevel _currentDifficulty = DifficultyLevel.easy;

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

      // Load wrong answer categories
      final wrongCategoriesJson = prefs.getString('wrongAnswerCategories');
      if (wrongCategoriesJson != null) {
        final Map<String, dynamic> wrongCategoriesMap = {};
        // Parse JSON string back to map
        wrongCategoriesJson.split(',').forEach((entry) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            _wrongAnswerCategories[parts[0]] = int.parse(parts[1]);
          }
        });
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
        await prefs.setInt(
            'lastPlayTime', _lastPlayTime!.millisecondsSinceEpoch);
      }

      // Save wrong answer categories
      final wrongCategoriesString = _wrongAnswerCategories.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      await prefs.setString('wrongAnswerCategories', wrongCategoriesString);

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

  void _selectRandomQuestions(int count,
      {AppLanguage? language, String? category}) {
    // Use provided language or default to current language
    final selectedLanguage = language ?? _currentLanguage;

    // Get questions from database in selected language
    var allAvailableQuestions =
        QuestionsDatabase.getQuestions(selectedLanguage);

    // Filter by category if specified
    if (category != null && category != 'Tümü') {
      allAvailableQuestions =
          allAvailableQuestions.where((q) => q.category == category).toList();
    }

    // Clear answered questions for new session to ensure variety
    _answeredQuestions.clear();

    var regularQuestions =
        allAvailableQuestions.where((q) => q.options.length == 4).toList();
    var bonusQuestions =
        allAvailableQuestions.where((q) => q.options.length == 5).toList();

    // Filter out already used questions to prevent duplicates
    var availableRegular = regularQuestions
        .where((q) =>
            !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage)))
        .toList();
    var availableBonus = bonusQuestions
        .where((q) =>
            !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage)))
        .toList();

    // If we've used too many questions, reset the used set for this language
    if (availableRegular.length + availableBonus.length < count) {
      _usedQuestionIds.clear();
      availableRegular = regularQuestions;
      availableBonus = bonusQuestions;
    }

    // Separate questions by wrong answer categories for weighted selection
    final wrongCategoryQuestions = <Question>[];
    final otherCategoryQuestions = <Question>[];

    for (var q in availableRegular) {
      if (_wrongAnswerCategories.containsKey(q.category) &&
          _wrongAnswerCategories[q.category]! > 0) {
        wrongCategoryQuestions.add(q);
      } else {
        otherCategoryQuestions.add(q);
      }
    }

    // Calculate how many questions to select from each group
    final wrongCategoryCount =
        (count * 0.6).round(); // 60% from wrong categories
    final otherCategoryCount =
        count - wrongCategoryCount; // 40% from other categories

    questions = [];
    int selected = 0;

    // First, select from wrong answer categories (if available)
    if (wrongCategoryQuestions.isNotEmpty) {
      wrongCategoryQuestions.shuffle(_random);
      for (var q in wrongCategoryQuestions) {
        if (selected >= wrongCategoryCount) break;
        questions.add(q);
        _answeredQuestions.add(q.text);
        _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
        selected++;
      }
    }

    // Then fill remaining slots with other categories
    selected = 0; // Reset counter for other categories
    otherCategoryQuestions.shuffle(_random);
    for (var q in otherCategoryQuestions) {
      if (questions.length >= count) break;
      questions.add(q);
      _answeredQuestions.add(q.text);
      _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
      selected++;
    }

    // If still need more questions, add bonus questions
    if (questions.length < count) {
      availableBonus.shuffle(_random);
      for (var q in availableBonus) {
        if (questions.length >= count) break;
        questions.add(q);
        _answeredQuestions.add(q.text);
        _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
      }
    }

    // If still need more questions (edge case), allow duplicates
    if (questions.length < count) {
      var allQuestions = List<Question>.from(allAvailableQuestions);
      allQuestions.shuffle(_random);

      for (var q in allQuestions) {
        if (questions.length >= count) break;
        if (!questions.contains(q)) {
          questions.add(q);
          _answeredQuestions.add(q.text);
        }
      }
    }
  }

  // YENİ ZORLUK SEVİYESİ METHOD'LARI

  /// Belirli zorluk seviyesinde soru seçimi
  void _selectRandomQuestionsByDifficulty(int count,
      {AppLanguage? language, String? category, DifficultyLevel? difficulty}) {
    // Use provided language or default to current language
    final selectedLanguage = language ?? _currentLanguage;

    // Get questions by difficulty from database
    var allAvailableQuestions =
        QuestionsDatabase.getQuestionsByDifficulty(selectedLanguage, _currentDifficulty);

    // Filter by category if specified
    if (category != null && category != 'Tümü') {
      allAvailableQuestions = allAvailableQuestions
          .where((q) => q.category == category)
          .toList();
    }

    // Clear answered questions for new session to ensure variety
    _answeredQuestions.clear();

    // Filter out already used questions to prevent duplicates
    var availableQuestions = allAvailableQuestions
        .where((q) =>
            !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage)))
        .toList();

    // If we've used too many questions, reset the used set for this language
    if (availableQuestions.length < count) {
      _usedQuestionIds.clear();
      availableQuestions = allAvailableQuestions;
    }

    // Separate questions by wrong answer categories for weighted selection
    final wrongCategoryQuestions = <Question>[];
    final otherCategoryQuestions = <Question>[];

    for (var q in availableQuestions) {
      if (_wrongAnswerCategories.containsKey(q.category) &&
          _wrongAnswerCategories[q.category]! > 0) {
        wrongCategoryQuestions.add(q);
      } else {
        otherCategoryQuestions.add(q);
      }
    }

    // Calculate how many questions to select from each group
    final wrongCategoryCount = (count * 0.6).round(); // 60% from wrong categories
    final otherCategoryCount = count - wrongCategoryCount; // 40% from other categories

    questions = [];

    // First, select from wrong answer categories (if available)
    if (wrongCategoryQuestions.isNotEmpty) {
      wrongCategoryQuestions.shuffle(_random);
      for (var q in wrongCategoryQuestions) {
        if (questions.length >= wrongCategoryCount) break;
        questions.add(q);
        _answeredQuestions.add(q.text);
        _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
      }
    }

    // Then fill remaining slots with other categories
    otherCategoryQuestions.shuffle(_random);
    for (var q in otherCategoryQuestions) {
      if (questions.length >= count) break;
      questions.add(q);
      _answeredQuestions.add(q.text);
      _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
    }

    // If still need more questions, allow duplicates
    if (questions.length < count) {
      var allQuestions = List<Question>.from(allAvailableQuestions);
      allQuestions.shuffle(_random);

      for (var q in allQuestions) {
        if (questions.length >= count) break;
        if (!questions.contains(q)) {
          questions.add(q);
          _answeredQuestions.add(q.text);
        }
      }
    }
  }

  /// Karışık zorluk seviyelerinde soru seçimi (kolay:orta:zor = 1:1:1 oranında)
  void _selectMixedDifficultyQuestions(int count,
      {AppLanguage? language, String? category}) {
    // Use provided language or default to current language
    final selectedLanguage = language ?? _currentLanguage;

    // Get mixed difficulty questions from database
    var allAvailableQuestions =
        QuestionsDatabase.getMixedDifficultyQuestions(selectedLanguage, count);

    // Filter by category if specified
    if (category != null && category != 'Tümü') {
      allAvailableQuestions = allAvailableQuestions
          .where((q) => q.category == category)
          .toList();
    }

    // Clear answered questions for new session to ensure variety
    _answeredQuestions.clear();

    // Filter out already used questions to prevent duplicates
    var availableQuestions = allAvailableQuestions
        .where((q) =>
            !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage)))
        .toList();

    // If we've used too many questions, reset the used set for this language
    if (availableQuestions.length < count) {
      _usedQuestionIds.clear();
      availableQuestions = allAvailableQuestions;
    }

    questions = List<Question>.from(availableQuestions);
    questions.shuffle(_random);

    // Ensure we have the exact count
    if (questions.length > count) {
      questions = questions.take(count).toList();
    }

    // Add to tracking lists
    for (var q in questions) {
      _answeredQuestions.add(q.text);
      _usedQuestionIds.add(_getQuestionId(q, selectedLanguage));
    }
  }

  String _getQuestionId(Question question, AppLanguage language) {
    // Create a unique ID for each question per language
    return '${language.code}_${question.text.hashCode}';
  }

  // Zorluk seviyesi getter'ı ve setter'ı
  DifficultyLevel get currentDifficulty => _currentDifficulty;

  void setDifficulty(DifficultyLevel difficulty) {
    _currentDifficulty = difficulty;
  }

  // Get current language
  AppLanguage get currentLanguage => _currentLanguage;

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
        // await NotificationService.scheduleHighScoreNotification();
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

  Future<void> startNewQuiz(
      {String? category, DifficultyLevel? difficulty}) async {
    resetScore();

    // Use provided difficulty or current difficulty
    final selectedDifficulty = difficulty ?? _currentDifficulty;

    // Zorluk seviyesine göre soru seçimi
    if (selectedDifficulty == DifficultyLevel.easy) {
      _selectRandomQuestionsByDifficulty(15, category: category, difficulty: selectedDifficulty);
    } else if (selectedDifficulty == DifficultyLevel.medium) {
      _selectRandomQuestionsByDifficulty(15, category: category, difficulty: selectedDifficulty);
    } else if (selectedDifficulty == DifficultyLevel.hard) {
      _selectRandomQuestionsByDifficulty(15, category: category, difficulty: selectedDifficulty);
    } else {
      // Mixed difficulty - use balanced selection
      _selectMixedDifficultyQuestions(15, category: category);
    }

    await _loadHighScore();
    _lastPlayTime = DateTime.now();
    await _saveHighScore(); // Save last play time
  }

  void recordWrongAnswer(String category) {
    _wrongAnswerCategories[category] =
        (_wrongAnswerCategories[category] ?? 0) + 1;
  }

  Map<String, int> getWrongAnswerCategories() {
    return Map.from(_wrongAnswerCategories);
  }

  void resetWrongAnswerCategories() {
    _wrongAnswerCategories.clear();
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
      'currentDifficulty': _currentDifficulty.toString(),
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

  Future<void> saveGameResults(
      int score, List<String> answeredQuestions) async {
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
        // await NotificationService.scheduleReminderNotification();
        if (kDebugMode) {
          debugPrint(
              'Reminder notification sent after ${difference.inHours} hours');
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error sending reminder notification: $e');
      }
    }
  }

  // Clear used questions (for testing or reset purposes)
  void clearUsedQuestions() {
    _usedQuestionIds.clear();
  }
}
