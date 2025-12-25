// lib/services/enhanced_quiz_logic_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question.dart';
import '../data/questions_database.dart';
import '../enums/app_language.dart';
import 'difficulty_recommendation_service.dart';

/// Gelişmiş Quiz Logic Service - Zorluk seviyeleri ve akıllı adaptasyon ile
class EnhancedQuizLogicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DifficultyRecommendationService _difficultyService = DifficultyRecommendationService();
  final Random _random = Random();

  // Core state management
  List<Question> _currentQuestions = [];
  int _currentScore = 0;
  int _highScore = 0;
  DifficultyLevel _currentDifficulty = DifficultyLevel.easy;
  AppLanguage _currentLanguage = AppLanguage.turkish;
  
  // Performance tracking
  DateTime? _sessionStartTime;
  Duration _totalPlayTime = Duration.zero;
  final Map<String, int> _wrongAnswerCategories = {};
  final Map<String, int> _correctAnswerCategories = {};
  final List<Question> _sessionQuestions = [];
  final List<bool> _sessionAnswers = [];
  
  // Advanced analytics
  final Map<DifficultyLevel, Map<String, dynamic>> _difficultyStats = {};
  final List<Map<String, dynamic>> _performanceHistory = [];
  final Set<String> _usedQuestionIds = {};
  
  // Real-time adaptation
  int _consecutiveCorrectAnswers = 0;
  int _consecutiveWrongAnswers = 0;
  double _currentSessionAccuracy = 0.0;
  bool _isAdaptationEnabled = true;

  // Constructor
  EnhancedQuizLogicService() {
    _initializeStats();
    _loadUserData();
  }

  void _initializeStats() {
    for (final difficulty in DifficultyLevel.values) {
      _difficultyStats[difficulty] = {
        'totalQuizzes': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
        'averageScore': 0,
        'bestScore': 0,
        'averageTime': 0,
      };
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('highScore') ?? 0;
      
      // Load session data
      final sessionDataJson = prefs.getString('currentSessionData');
      if (sessionDataJson != null) {
        // Parse session data if needed
      }
      
      await _difficultyService.loadUserStats();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _highScore);
      
      // Save session data
      final sessionData = {
        'currentDifficulty': _currentDifficulty.toString(),
        'currentLanguage': _currentLanguage.code,
        'sessionStartTime': _sessionStartTime?.millisecondsSinceEpoch,
        'totalPlayTime': _totalPlayTime.inMinutes,
      };
      
      await prefs.setString('currentSessionData', sessionData.toString());
      await _difficultyService.saveUserStats();
      
      // Save to Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _saveToFirestore(userId);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving user data: $e');
    }
  }

  Future<void> _saveToFirestore(String userId) async {
    try {
      await _firestore.collection('user_quiz_stats').doc(userId).set({
        'highScore': _highScore,
        'difficultyStats': _difficultyStats,
        'performanceHistory': _performanceHistory,
        'lastUpdated': FieldValue.serverTimestamp(),
        'totalPlayTime': _totalPlayTime.inMinutes,
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving to Firestore: $e');
    }
  }

  // Public API methods

  /// Yeni quiz oturumu başlat
  Future<void> startNewQuiz({
    String? category,
    DifficultyLevel? preferredDifficulty,
    bool enableAdaptation = true,
  }) async {
    _sessionStartTime = DateTime.now();
    _currentScore = 0;
    _sessionQuestions.clear();
    _sessionAnswers.clear();
    _consecutiveCorrectAnswers = 0;
    _consecutiveWrongAnswers = 0;
    _isAdaptationEnabled = enableAdaptation;

    // Get recommended difficulty or use preferred
    _currentDifficulty = preferredDifficulty ?? 
        _difficultyService.getRecommendedDifficulty();

    // Generate questions based on difficulty
    await _generateQuestions(
      count: _getQuestionCountForDifficulty(_currentDifficulty),
      category: category,
      difficulty: _currentDifficulty,
    );

    await _saveUserData();
    
    if (kDebugMode) {
      debugPrint('New quiz started - Difficulty: ${_currentDifficulty.displayName}, '
          'Questions: ${_currentQuestions.length}');
    }
  }

  /// Cevap kontrolü ve performans takibi
  Future<bool> submitAnswer(Question question, String answer) async {
    final isCorrect = await _checkAnswer(question, answer);
    
    // Record in session
    _sessionQuestions.add(question);
    _sessionAnswers.add(isCorrect);
    
    // Update running accuracy
    _updateSessionAccuracy(isCorrect);
    
    // Update difficulty service
    _updateDifficultyService(question, isCorrect);
    
    // Check for real-time adaptation
    if (_isAdaptationEnabled) {
      _checkForDifficultyAdaptation();
    }
    
    return isCorrect;
  }

  Future<bool> _checkAnswer(Question question, String answer) async {
    final selectedOption = question.options.firstWhere(
      (option) => option.text == answer,
      orElse: () => Option(text: '', score: 0),
    );

    final isCorrect = selectedOption.score > 0;
    
    // Update score
    if (isCorrect) {
      _currentScore += selectedOption.score;
      _consecutiveCorrectAnswers++;
      _consecutiveWrongAnswers = 0;
      
      // Track correct answers by category
      _correctAnswerCategories[question.category] = 
          (_correctAnswerCategories[question.category] ?? 0) + 1;
    } else {
      _consecutiveWrongAnswers++;
      _consecutiveCorrectAnswers = 0;
      
      // Track wrong answers by category
      _wrongAnswerCategories[question.category] = 
          (_wrongAnswerCategories[question.category] ?? 0) + 1;
    }

    // Update high score
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
    }

    return isCorrect;
  }

  void _updateSessionAccuracy(bool isCorrect) {
    final totalAnswers = _sessionAnswers.length;
    final correctAnswers = _sessionAnswers.where((a) => a).length;
    _currentSessionAccuracy = totalAnswers > 0 ? 
        (correctAnswers / totalAnswers) * 100 : 0.0;
  }

  void _updateDifficultyService(Question question, bool isCorrect) {
    final wrongCategories = <String>[];
    if (!isCorrect) {
      wrongCategories.add(question.category);
    }

    _difficultyService.recordQuizPerformance(
      difficulty: _currentDifficulty,
      score: _currentScore,
      totalQuestions: _sessionQuestions.length + 1,
      wrongAnswerCategories: wrongCategories,
      completionTime: _sessionStartTime != null ? 
          DateTime.now().difference(_sessionStartTime!) : Duration.zero,
    );
  }

  void _checkForDifficultyAdaptation() {
    // Adapt difficulty based on performance
    if (_sessionAnswers.length >= 3) { // After at least 3 answers
      if (_consecutiveCorrectAnswers >= 4) {
        // Increase difficulty
        _adaptDifficulty(true);
      } else if (_consecutiveWrongAnswers >= 3) {
        // Decrease difficulty
        _adaptDifficulty(false);
      }
    }
  }

  void _adaptDifficulty(bool shouldIncrease) {
    final oldDifficulty = _currentDifficulty;
    
    if (shouldIncrease) {
      switch (_currentDifficulty) {
        case DifficultyLevel.easy:
          _currentDifficulty = DifficultyLevel.medium;
          break;
        case DifficultyLevel.medium:
          _currentDifficulty = DifficultyLevel.hard;
          break;
        case DifficultyLevel.hard:
          // Stay at hard, but maybe increase question complexity
          break;
      }
    } else {
      switch (_currentDifficulty) {
        case DifficultyLevel.hard:
          _currentDifficulty = DifficultyLevel.medium;
          break;
        case DifficultyLevel.medium:
          _currentDifficulty = DifficultyLevel.easy;
          break;
        case DifficultyLevel.easy:
          // Stay at easy
          break;
      }
    }

    // If difficulty changed, regenerate remaining questions
    if (oldDifficulty != _currentDifficulty && _currentQuestions.isNotEmpty) {
      _regenerateRemainingQuestions();
    }
  }

  Future<void> _generateQuestions({
    required int count,
    String? category,
    required DifficultyLevel difficulty,
  }) async {
    var availableQuestions = _getQuestionsByDifficulty(difficulty);
    
    // Filter by category if specified
    if (category != null && category != 'Tümü') {
      availableQuestions = availableQuestions
          .where((q) => q.category == category)
          .toList();
    }

    // Apply intelligent selection algorithm
    _currentQuestions = _selectQuestionsIntelligently(
      availableQuestions, 
      count,
      difficulty,
    );

    // Update used questions tracking
    for (final question in _currentQuestions) {
      _usedQuestionIds.add(_getQuestionId(question));
    }
  }

  List<Question> _selectQuestionsIntelligently(
    List<Question> availableQuestions,
    int count,
    DifficultyLevel difficulty,
  ) {
    // Separate questions by performance categories
    final weakCategoryQuestions = <Question>[];
    final strongCategoryQuestions = <Question>[];
    final neutralQuestions = <Question>[];

    for (final question in availableQuestions) {
      final wrongCount = _wrongAnswerCategories[question.category] ?? 0;
      final correctCount = _correctAnswerCategories[question.category] ?? 0;
      
      if (wrongCount > correctCount && wrongCount >= 2) {
        weakCategoryQuestions.add(question);
      } else if (correctCount > wrongCount && correctCount >= 2) {
        strongCategoryQuestions.add(question);
      } else {
        neutralQuestions.add(question);
      }
    }

    // Smart selection strategy
    final selectedQuestions = <Question>[];
    
    // 50% from weak categories (to improve them)
    final weakCount = (count * 0.5).round();
    selectedQuestions.addAll(_selectRandomSubset(
      weakCategoryQuestions, 
      weakCount,
    ));

    // 30% from neutral categories
    final neutralCount = (count * 0.3).round();
    selectedQuestions.addAll(_selectRandomSubset(
      neutralQuestions, 
      neutralCount,
    ));

    // 20% from strong categories (for challenge)
    final strongCount = count - selectedQuestions.length;
    selectedQuestions.addAll(_selectRandomSubset(
      strongCategoryQuestions, 
      strongCount,
    ));

    // Shuffle and ensure we have the right count
    selectedQuestions.shuffle(_random);
    return selectedQuestions.take(count).toList();
  }

  List<Question> _selectRandomSubset(List<Question> questions, int count) {
    if (questions.isEmpty) return [];
    if (questions.length <= count) return List.from(questions);
    
    questions.shuffle(_random);
    return questions.take(count).toList();
  }

  void _regenerateRemainingQuestions() {
    if (_sessionQuestions.isEmpty) return;
    
    final remainingCount = _currentQuestions.length - _sessionQuestions.length;
    if (remainingCount <= 0) return;

    // Keep already answered questions, generate new ones for remaining slots
    final answeredQuestionIds = _sessionQuestions.map((q) => q.text).toSet();
    final newQuestions = _currentQuestions.where((q) => 
        !answeredQuestionIds.contains(q.text)).toList();
    
    // Generate additional questions to fill the gap
    final additionalNeeded = remainingCount - newQuestions.length;
    if (additionalNeeded > 0) {
      final availableQuestions = _getQuestionsByDifficulty(_currentDifficulty)
          .where((q) => !answeredQuestionIds.contains(q.text))
          .toList();
      
      final additionalQuestions = _selectRandomSubset(
        availableQuestions, 
        additionalNeeded,
      );
      
      newQuestions.addAll(additionalQuestions);
    }

    // Replace the remaining questions
    final allQuestions = [..._sessionQuestions, ...newQuestions];
    _currentQuestions = allQuestions.take(_currentQuestions.length).toList();
  }

  List<Question> _getQuestionsByDifficulty(DifficultyLevel difficulty) {
    return QuestionsDatabase.getQuestionsByDifficulty(_currentLanguage, difficulty);
  }

  String _getQuestionId(Question question) {
    return '${_currentLanguage.code}_${question.text.hashCode}';
  }

  int _getQuestionCountForDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 15;
      case DifficultyLevel.medium:
        return 12;
      case DifficultyLevel.hard:
        return 10;
    }
  }

  // Getters
  List<Question> get currentQuestions => List.unmodifiable(_currentQuestions);
  int get currentScore => _currentScore;
  int get highScore => _highScore;
  DifficultyLevel get currentDifficulty => _currentDifficulty;
  AppLanguage get currentLanguage => _currentLanguage;
  double get currentSessionAccuracy => _currentSessionAccuracy;
  Duration get sessionDuration => _sessionStartTime != null ? 
      DateTime.now().difference(_sessionStartTime!) : Duration.zero;
  
  // Public setter methods for BLoC compatibility
  void setDifficulty(DifficultyLevel difficulty) {
    _currentDifficulty = difficulty;
    if (_sessionAnswers.length >= 3) {
      _regenerateRemainingQuestions();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      // If there's an active quiz, regenerate questions with new language
      if (_sessionStartTime != null && _currentQuestions.isNotEmpty) {
        await _regenerateQuestionsForLanguage();
      }
      await _saveUserData();
    }
  }

  Future<void> _regenerateQuestionsForLanguage() async {
    try {
      // Keep track of which questions have been answered
      final answeredQuestionIds = _sessionQuestions.map((q) => q.text).toSet();
      final remainingQuestions = _currentQuestions
          .where((q) => !answeredQuestionIds.contains(q.text))
          .toList();

      // Generate new questions for the remaining slots
      final neededCount = _currentQuestions.length - _sessionQuestions.length;
      if (neededCount > 0) {
        final availableQuestions = _getQuestionsByDifficulty(_currentDifficulty)
            .where((q) => !answeredQuestionIds.contains(q.text))
            .toList();
        
        final newQuestions = _selectRandomSubset(availableQuestions, neededCount);
        remainingQuestions.addAll(newQuestions);
      }

      // Update the questions list
      _currentQuestions = [..._sessionQuestions, ...remainingQuestions];
      
      if (kDebugMode) {
        debugPrint('Regenerated ${remainingQuestions.length} questions for language: ${_currentLanguage.code}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error regenerating questions for language: $e');
    }
  }
  
  // Quiz state getters
  int get answeredQuestions => _sessionAnswers.length;
  int get totalQuestions => _currentQuestions.length;
  bool get isQuizActive => _sessionStartTime != null;
  bool get canAdaptDifficulty => _isAdaptationEnabled && _sessionAnswers.length >= 3;

  /// Quiz oturumunu sonlandır ve sonuçları kaydet
  Future<Map<String, dynamic>> finishQuiz() async {
    if (_sessionStartTime == null) {
      return {'error': 'No active quiz session'};
    }

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    _totalPlayTime += sessionDuration;

    // Calculate final statistics
    final correctAnswers = _sessionAnswers.where((a) => a).length;
    final wrongAnswers = _sessionAnswers.length - correctAnswers;
    final finalAccuracy = _sessionAnswers.isNotEmpty ? 
        (correctAnswers / _sessionAnswers.length) * 100 : 0.0;

    // Update difficulty statistics
    _updateDifficultyStats(finalAccuracy, sessionDuration);

    // Record performance history
    final performanceData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'difficulty': _currentDifficulty.toString(),
      'score': _currentScore,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'accuracy': finalAccuracy,
      'duration': sessionDuration.inMinutes,
      'questionsCount': _sessionQuestions.length,
    };
    
    _performanceHistory.add(performanceData);
    
    // Keep only last 50 records
    if (_performanceHistory.length > 50) {
      _performanceHistory.removeAt(0);
    }

    // Save all data
    await _saveUserData();

    // Prepare results
    final results = {
      'score': _currentScore,
      'highScore': _highScore,
      'accuracy': finalAccuracy,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'duration': sessionDuration.inMinutes,
      'difficulty': _currentDifficulty.displayName,
      'questionsCount': _sessionQuestions.length,
      'wrongCategories': _wrongAnswerCategories,
      'performanceTrend': _difficultyService.getPerformanceTrend(),
      'weakAreas': _difficultyService.getWeakAreas(),
      'nextRecommendation': _difficultyService.getRecommendedDifficulty().displayName,
    };

    // Reset session
    _resetSession();

    return results;
  }

  void _updateDifficultyStats(double accuracy, Duration duration) {
    final stats = _difficultyStats[_currentDifficulty]!;
    stats['totalQuizzes'] = (stats['totalQuizzes'] ?? 0) + 1;
    
    if (accuracy >= 70) {
      stats['totalCorrect'] = (stats['totalCorrect'] ?? 0) + 1;
    } else {
      stats['totalWrong'] = (stats['totalWrong'] ?? 0) + 1;
    }
    
    stats['bestScore'] = max(stats['bestScore'] ?? 0, _currentScore);
    
    // Calculate new average
    final totalQuizzes = stats['totalQuizzes'] ?? 0;
    final currentAvg = stats['averageScore'] ?? 0.0;
    final newAvg = ((currentAvg * (totalQuizzes - 1)) + accuracy) / totalQuizzes;
    stats['averageScore'] = newAvg.toDouble();
    
    // Update average time
    final currentTimeAvg = stats['averageTime'] ?? 0.0;
    final newTimeAvg = ((currentTimeAvg * (totalQuizzes - 1)) + duration.inSeconds) / totalQuizzes;
    stats['averageTime'] = newTimeAvg.toDouble();
  }

  void _resetSession() {
    _sessionStartTime = null;
    _currentScore = 0;
    _sessionQuestions.clear();
    _sessionAnswers.clear();
    _consecutiveCorrectAnswers = 0;
    _consecutiveWrongAnswers = 0;
    _currentSessionAccuracy = 0.0;
  }

  /// Detaylı analiz ve raporlama
  Map<String, dynamic> getDetailedAnalytics() {
    return {
      'overallStats': {
        'totalQuizzes': _performanceHistory.length,
        'highScore': _highScore,
        'totalPlayTime': _totalPlayTime.inMinutes,
        'averageAccuracy': _calculateOverallAccuracy(),
      },
      'difficultyStats': _difficultyStats,
      'categoryPerformance': {
        'correctAnswers': _correctAnswerCategories,
        'wrongAnswers': _wrongAnswerCategories,
      },
      'performanceTrend': _difficultyService.getPerformanceTrend(),
      'recommendations': {
        'currentDifficulty': _currentDifficulty.displayName,
        'suggestedDifficulty': _difficultyService.getRecommendedDifficulty().displayName,
        'weakAreas': _difficultyService.getWeakAreas(),
        'questionCount': _getRecommendedQuestionCount(),
      },
      'recentPerformance': _performanceHistory.take(10).toList(),
    };
  }

  double _calculateOverallAccuracy() {
    if (_performanceHistory.isEmpty) return 0.0;
    
    final validAccuracies = _performanceHistory
        .map((data) => data['accuracy'] as double?)
        .where((accuracy) => accuracy != null)
        .cast<double>()
        .toList();
    
    if (validAccuracies.isEmpty) return 0.0;
    
    double totalAccuracy = 0.0;
    for (final accuracy in validAccuracies) {
      totalAccuracy += accuracy;
    }
    
    return totalAccuracy / validAccuracies.length;
  }

  int _getRecommendedQuestionCount() {
    return _difficultyService.getRecommendedQuestionCount(_currentDifficulty);
  }

  /// Performans verilerini temizle (test için)
  void clearPerformanceData() {
    _wrongAnswerCategories.clear();
    _correctAnswerCategories.clear();
    _performanceHistory.clear();
    _usedQuestionIds.clear();
    _difficultyService.clearStats();
  }

  /// Debug bilgisi
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentSession': {
        'isActive': _sessionStartTime != null,
        'difficulty': _currentDifficulty.toString(),
        'score': _currentScore,
        'answeredQuestions': _sessionAnswers.length,
        'totalQuestions': _currentQuestions.length,
        'accuracy': _currentSessionAccuracy,
        'consecutiveCorrect': _consecutiveCorrectAnswers,
        'consecutiveWrong': _consecutiveWrongAnswers,
      },
      'usedQuestionsCount': _usedQuestionIds.length,
      'performanceHistoryLength': _performanceHistory.length,
      'currentLanguage': _currentLanguage.code,
      'adaptationEnabled': _isAdaptationEnabled,
    };
  }
}
