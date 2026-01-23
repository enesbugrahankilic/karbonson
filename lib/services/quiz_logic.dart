// lib/services/quiz_logic.dart
import '../models/question.dart';
import '../data/questions_database.dart';
import '../services/language_service.dart';
import '../services/notification_service.dart';
import '../enums/app_language.dart';
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
  bool _highScoreLoaded = false; // Track if high score has been loaded
  bool _localDataMigrated = false; // Track if local data has been migrated to Firestore

  List<Question> questions = [];
  final Random _random = Random();

  // YENİ ZORLUK SEVİYESİ PROPERTIES
  DifficultyLevel _currentDifficulty = DifficultyLevel.easy;

  QuizLogic();

  Future<void> _ensureHighScoreLoaded() async {
    // Only load once to avoid repeated async calls
    if (_highScoreLoaded) return;
    await _loadHighScore();
    _highScoreLoaded = true;
  }

  Future<void> _loadHighScore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      // First, try to load from Firestore (primary source)
      if (userId != null) {
        try {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            _highScore = data['highestScore'] as int? ?? 0;
            if (kDebugMode) {
              debugPrint('✅ High score loaded from Firestore: $_highScore');
            }
          }
        } catch (firestoreError) {
          if (kDebugMode) {
            debugPrint('⚠️ Firestore error, falling back to local storage: $firestoreError');
          }
          // Fall back to SharedPreferences if Firestore fails
          await _loadFromLocalStorage();
        }
      } else {
        // No user logged in, use local storage
        await _loadFromLocalStorage();
      }
      
      // Load last play time from local storage (personal preference)
      await _loadLastPlayTime();
      
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading high score: $e');
      // Final fallback to local storage
      await _loadFromLocalStorage();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('highScore') ?? 0;
      
      // Load wrong answer categories from local storage
      final wrongCategoriesJson = prefs.getString('wrongAnswerCategories');
      if (wrongCategoriesJson != null) {
        _wrongAnswerCategories.clear();
        wrongCategoriesJson.split(',').forEach((entry) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            _wrongAnswerCategories[parts[0]] = int.parse(parts[1]);
          }
        });
      }
      
      if (kDebugMode) {
        debugPrint('✅ High score loaded from SharedPreferences: $_highScore');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading from local storage: $e');
    }
  }

  Future<void> _loadLastPlayTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPlayTimeMillis = prefs.getInt('lastPlayTime');
      if (lastPlayTimeMillis != null) {
        _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(lastPlayTimeMillis);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading last play time: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      // Save to local storage first (for offline access)
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

      // Save to Firestore (primary source for cross-device sync)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).set({
          'highestScore': _highScore,
          'lastScoreUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        if (kDebugMode) {
          debugPrint('✅ High score saved to Firestore: $_highScore');
        }
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

  /// Belirli zorluk seviyesinde soru seçimi - SORU SAYISI SENKRONİZASYONU DÜZELTİLDİ
  void _selectRandomQuestionsByDifficulty(int count,
      {AppLanguage? language, String? category, DifficultyLevel? difficulty}) {
    // Use provided language or default to current language
    final selectedLanguage = language ?? _currentLanguage;

    // Use provided difficulty or default to current difficulty
    final selectedDifficulty = difficulty ?? _currentDifficulty;

    // Get questions by difficulty from database (all categories)
    final allQuestionsByDifficulty =
        QuestionsDatabase.getQuestionsByDifficulty(selectedLanguage, selectedDifficulty);

    // Separate category-specific and other questions
    List<Question> categoryQuestions = [];
    List<Question> otherQuestions = [];

    if (category != null && category != 'Tümü') {
      // Split questions by category
      categoryQuestions = allQuestionsByDifficulty
          .where((q) => q.category == category)
          .toList();
      otherQuestions = allQuestionsByDifficulty
          .where((q) => q.category != category)
          .toList();
    } else {
      // If no category specified, all questions are "other"
      otherQuestions = List.from(allQuestionsByDifficulty);
    }

    // Clear answered questions for new session to ensure variety
    _answeredQuestions.clear();

    // Filter out already used questions to prevent duplicates
    var availableCategoryQuestions = categoryQuestions
        .where((q) =>
            !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage)))
        .toList();
    var availableOtherQuestions = otherQuestions
        .where((q) =>
            !_usedQuestionIds.contains(_getQuestionId(q, selectedLanguage)))
        .toList();

    // If we've used too many questions, reset the used set for this language
    if (availableCategoryQuestions.length + availableOtherQuestions.length < count) {
      _usedQuestionIds.clear();
      availableCategoryQuestions = categoryQuestions;
      availableOtherQuestions = otherQuestions;
    }

    // Separate questions by wrong answer categories for weighted selection
    final wrongCategoryQuestions = <Question>[];
    final otherCategoryQuestions = <Question>[];

    // Check category questions for wrong answers
    for (var q in availableCategoryQuestions) {
      if (_wrongAnswerCategories.containsKey(q.category) &&
          _wrongAnswerCategories[q.category]! > 0) {
        wrongCategoryQuestions.add(q);
      } else {
        otherCategoryQuestions.add(q);
      }
    }

    // Check other questions for wrong answers
    for (var q in availableOtherQuestions) {
      if (_wrongAnswerCategories.containsKey(q.category) &&
          _wrongAnswerCategories[q.category]! > 0) {
        wrongCategoryQuestions.add(q);
      } else {
        otherCategoryQuestions.add(q);
      }
    }

    questions = [];
    final selectedIds = <String>{};

    // First priority: Category-specific questions (if category selected)
    if (categoryQuestions.isNotEmpty) {
      // Shuffle category questions
      availableCategoryQuestions.shuffle(_random);

      // Add as many category questions as possible
      for (var q in availableCategoryQuestions) {
        if (questions.length >= count) break;
        final qid = _getQuestionId(q, selectedLanguage);
        if (!selectedIds.contains(qid)) {
          questions.add(q);
          _answeredQuestions.add(q.text);
          _usedQuestionIds.add(qid);
          selectedIds.add(qid);
        }
      }
    }

    // Second priority: Fill remaining slots with other categories
    if (questions.length < count) {
      // Combine remaining wrong and other category questions
      final remainingQuestions = [...wrongCategoryQuestions, ...otherCategoryQuestions]
          .where((q) => !selectedIds.contains(_getQuestionId(q, selectedLanguage)))
          .toList();

      remainingQuestions.shuffle(_random);

      for (var q in remainingQuestions) {
        if (questions.length >= count) break;
        final qid = _getQuestionId(q, selectedLanguage);
        if (!selectedIds.contains(qid)) {
          questions.add(q);
          _answeredQuestions.add(q.text);
          _usedQuestionIds.add(qid);
          selectedIds.add(qid);
        }
      }
    }

    // If still need more questions, allow duplicates from all available questions
    if (questions.length < count) {
      final allAvailable = List<Question>.from(allQuestionsByDifficulty);
      allAvailable.shuffle(_random);

      for (var q in allAvailable) {
        if (questions.length >= count) break;
        final qid = _getQuestionId(q, selectedLanguage);
        if (!selectedIds.contains(qid)) {
          questions.add(q);
          _answeredQuestions.add(q.text);
          _usedQuestionIds.add(qid);
          selectedIds.add(qid);
        } else {
          // Allow duplicate in extreme edge case
          questions.add(q);
          _answeredQuestions.add(q.text);
        }
      }
    }

    // Ensure we have exactly 'count' questions
    if (questions.length > count) {
      questions = questions.take(count).toList();
      final int removeCount = _answeredQuestions.length - count;
      if (removeCount > 0) {
        _answeredQuestions.removeRange(0, removeCount);
      }
    }

    // Debug log for verification
    if (kDebugMode) {
      debugPrint('✅ _selectRandomQuestionsByDifficulty: Requested=$count, Actual=${questions.length}, Category=$category');
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
        await NotificationService.showHighScoreNotificationStatic(_highScore);
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
      {String? category, DifficultyLevel? difficulty, int questionCount = 15}) async {
    resetScore();

    // Ensure high score is loaded before starting quiz
    await _ensureHighScoreLoaded();

    // Use provided difficulty or current difficulty
    final selectedDifficulty = difficulty ?? _currentDifficulty;

    // Zorluk seviyesine göre soru seçimi (optimize edilmiş)
    // Not: DifficultyLevel enum'unda sadece easy, medium, hard mevcut
    // mixed için özel bir case yok, varsayılan olarak karışık soru seçimi kullanılır
    switch (selectedDifficulty) {
      case DifficultyLevel.easy:
      case DifficultyLevel.medium:
      case DifficultyLevel.hard:
        _selectRandomQuestionsByDifficulty(questionCount, category: category, difficulty: selectedDifficulty);
        break;
      default:
        // Varsayılan (mixed gibi) - karışık soru seçimi
        _selectMixedDifficultyQuestions(questionCount, category: category);
        break;
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
