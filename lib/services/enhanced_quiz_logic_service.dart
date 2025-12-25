import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question.dart';
import '../data/questions_database.dart';
import '../enums/app_language.dart';
import 'difficulty_recommendation_service.dart';

/// Gelişmiş Quiz Logic Service - Zorluk seviyeleri ve akıllı adaptasyon
class EnhancedQuizLogicService {
  // Firebase ve Services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DifficultyRecommendationService _difficultyService =
      DifficultyRecommendationService();
  final Random _random = Random();

  // Quiz State
  late List<Question> _currentQuestions;
  late int _currentScore;
  late int _highScore;
  late DifficultyLevel _currentDifficulty;
  late AppLanguage _currentLanguage;

  // Session Tracking
  late DateTime? _sessionStartTime;
  late Duration _totalPlayTime;
  late final Map<String, int> _wrongAnswerCategories;
  late final Map<String, int> _correctAnswerCategories;
  late final List<Question> _sessionQuestions;
  late final List<bool> _sessionAnswers;

  // Analytics
  late final Map<DifficultyLevel, Map<String, dynamic>> _difficultyStats;
  late final List<Map<String, dynamic>> _performanceHistory;
  late final Set<String> _usedQuestionIds;

  // Real-time Adaptation
  late int _consecutiveCorrectAnswers;
  late int _consecutiveWrongAnswers;
  late double _currentSessionAccuracy;
  late bool _isAdaptationEnabled;

  EnhancedQuizLogicService() {
    _initializeFields();
    _initializeStats();
    _loadUserData();
  }

  void _initializeFields() {
    _currentQuestions = [];
    _currentScore = 0;
    _highScore = 0;
    _currentDifficulty = DifficultyLevel.easy;
    _currentLanguage = AppLanguage.turkish;
    _sessionStartTime = null;
    _totalPlayTime = Duration.zero;
    _wrongAnswerCategories = {};
    _correctAnswerCategories = {};
    _sessionQuestions = [];
    _sessionAnswers = [];
    _difficultyStats = {};
    _performanceHistory = [];
    _usedQuestionIds = {};
    _consecutiveCorrectAnswers = 0;
    _consecutiveWrongAnswers = 0;
    _currentSessionAccuracy = 0.0;
    _isAdaptationEnabled = true;
  }

  void _initializeStats() {
    for (final difficulty in DifficultyLevel.values) {
      _difficultyStats[difficulty] = {
        'totalQuizzes': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
        'averageScore': 0.0,
        'bestScore': 0,
        'averageTime': 0.0,
      };
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('highScore') ?? 0;
      await _difficultyService.loadUserStats();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Veri yükleme hatası: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _highScore);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _saveToFirestore(userId);
      }

      await _difficultyService.saveUserStats();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Veri kaydetme hatası: $e');
    }
  }

  Future<void> _saveToFirestore(String userId) async {
    try {
      await _firestore.collection('user_quiz_stats').doc(userId).set(
        {
          'highScore': _highScore,
          'difficultyStats': _difficultyStats,
          'performanceHistory': _performanceHistory,
          'lastUpdated': FieldValue.serverTimestamp(),
          'totalPlayTime': _totalPlayTime.inMinutes,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore kaydetme hatası: $e');
    }
  }

  // ============ PUBLIC API METHODS ============

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

    _currentDifficulty =
        preferredDifficulty ?? _difficultyService.getRecommendedDifficulty();

    await _generateQuestions(
      count: _getQuestionCountForDifficulty(_currentDifficulty),
      category: category,
      difficulty: _currentDifficulty,
    );

    await _saveUserData();

    if (kDebugMode) {
      debugPrint(
        '✅ Quiz başladı - Zorluk: ${_currentDifficulty.displayName}, '
        'Soru sayısı: ${_currentQuestions.length}',
      );
    }
  }

  Future<bool> submitAnswer(Question question, String answer) async {
    final isCorrect = await _checkAnswer(question, answer);

    _sessionQuestions.add(question);
    _sessionAnswers.add(isCorrect);

    _updateSessionAccuracy(isCorrect);
    _updateDifficultyService(question, isCorrect);

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

    if (isCorrect) {
      _currentScore += selectedOption.score;
      _consecutiveCorrectAnswers++;
      _consecutiveWrongAnswers = 0;
      _correctAnswerCategories[question.category] =
          (_correctAnswerCategories[question.category] ?? 0) + 1;
    } else {
      _consecutiveWrongAnswers++;
      _consecutiveCorrectAnswers = 0;
      _wrongAnswerCategories[question.category] =
          (_wrongAnswerCategories[question.category] ?? 0) + 1;
    }

    if (_currentScore > _highScore) {
      _highScore = _currentScore;
    }

    return isCorrect;
  }

  void _updateSessionAccuracy(bool isCorrect) {
    final totalAnswers = _sessionAnswers.length;
    if (totalAnswers == 0) return;

    final correctAnswers = _sessionAnswers.where((a) => a).length;
    _currentSessionAccuracy = (correctAnswers / totalAnswers) * 100;
  }

  void _updateDifficultyService(Question question, bool isCorrect) {
    _difficultyService.recordQuizPerformance(
      difficulty: _currentDifficulty,
      score: _currentScore,
      totalQuestions: _sessionQuestions.length,
      wrongAnswerCategories: isCorrect ? [] : [question.category],
      completionTime: _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : Duration.zero,
    );
  }

  void _checkForDifficultyAdaptation() {
    if (_sessionAnswers.length < 3) return;

    if (_consecutiveCorrectAnswers >= 4) {
      _adaptDifficulty(true);
    } else if (_consecutiveWrongAnswers >= 3) {
      _adaptDifficulty(false);
    }
  }

  void _adaptDifficulty(bool shouldIncrease) {
    final oldDifficulty = _currentDifficulty;

    if (shouldIncrease) {
      if (_currentDifficulty == DifficultyLevel.easy) {
        _currentDifficulty = DifficultyLevel.medium;
      } else if (_currentDifficulty == DifficultyLevel.medium) {
        _currentDifficulty = DifficultyLevel.hard;
      }
    } else {
      if (_currentDifficulty == DifficultyLevel.hard) {
        _currentDifficulty = DifficultyLevel.medium;
      } else if (_currentDifficulty == DifficultyLevel.medium) {
        _currentDifficulty = DifficultyLevel.easy;
      }
    }

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

    if (category != null && category != 'Tümü') {
      availableQuestions =
          availableQuestions.where((q) => q.category == category).toList();
    }

    _currentQuestions =
        _selectQuestionsIntelligently(availableQuestions, count, difficulty);

    for (final question in _currentQuestions) {
      _usedQuestionIds.add(_getQuestionId(question));
    }
  }

  List<Question> _selectQuestionsIntelligently(
    List<Question> availableQuestions,
    int count,
    DifficultyLevel difficulty,
  ) {
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

    final selectedQuestions = <Question>[];

    // %50 zayıf kategorilerden
    final weakCount = (count * 0.5).round();
    selectedQuestions
        .addAll(_selectRandomSubset(weakCategoryQuestions, weakCount));

    // %30 nötr kategorilerden
    final neutralCount = (count * 0.3).round();
    selectedQuestions
        .addAll(_selectRandomSubset(neutralQuestions, neutralCount));

    // %20 güçlü kategorilerden
    final strongCount = count - selectedQuestions.length;
    selectedQuestions
        .addAll(_selectRandomSubset(strongCategoryQuestions, strongCount));

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

    final answeredQuestionIds =
        _sessionQuestions.map((q) => q.text).toSet();
    final remainingCount =
        _currentQuestions.length - _sessionQuestions.length;

    if (remainingCount <= 0) return;

    final availableQuestions = _getQuestionsByDifficulty(_currentDifficulty)
        .where((q) => !answeredQuestionIds.contains(q.text))
        .toList();

    final newQuestions =
        _selectRandomSubset(availableQuestions, remainingCount);

    _currentQuestions = [
      ..._sessionQuestions,
      ...newQuestions,
    ].take(_currentQuestions.length).toList();
  }

  List<Question> _getQuestionsByDifficulty(DifficultyLevel difficulty) {
    return QuestionsDatabase.getQuestionsByDifficulty(
      _currentLanguage,
      difficulty,
    );
  }

  String _getQuestionId(Question question) {
    return '${_currentLanguage.code}_${question.text.hashCode}';
  }

  int _getQuestionCountForDifficulty(DifficultyLevel difficulty) {
    return switch (difficulty) {
      DifficultyLevel.easy => 15,
      DifficultyLevel.medium => 12,
      DifficultyLevel.hard => 10,
    };
  }

  // ============ SETTERS ============

  void setDifficulty(DifficultyLevel difficulty) {
    _currentDifficulty = difficulty;
    if (_sessionAnswers.length >= 3) {
      _regenerateRemainingQuestions();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;

    if (_sessionStartTime != null && _currentQuestions.isNotEmpty) {
      await _regenerateQuestionsForLanguage();
    }

    await _saveUserData();
  }

  Future<void> _regenerateQuestionsForLanguage() async {
    try {
      final answeredQuestionIds =
          _sessionQuestions.map((q) => q.text).toSet();
      final remainingQuestions = _currentQuestions
          .where((q) => !answeredQuestionIds.contains(q.text))
          .toList();

      final neededCount = _currentQuestions.length - _sessionQuestions.length;

      if (neededCount > 0) {
        final availableQuestions = _getQuestionsByDifficulty(_currentDifficulty)
            .where((q) => !answeredQuestionIds.contains(q.text))
            .toList();

        final newQuestions =
            _selectRandomSubset(availableQuestions, neededCount);
        remainingQuestions.addAll(newQuestions);
      }

      _currentQuestions = [..._sessionQuestions, ...remainingQuestions];

      if (kDebugMode) {
        debugPrint(
          '✅ ${remainingQuestions.length} soru dile çevrildi: ${_currentLanguage.code}',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Soru yeniden oluşturma hatası: $e');
    }
  }

  // ============ GETTERS ============

  List<Question> get currentQuestions => List.unmodifiable(_currentQuestions);
  int get currentScore => _currentScore;
  int get highScore => _highScore;
  DifficultyLevel get currentDifficulty => _currentDifficulty;
  AppLanguage get currentLanguage => _currentLanguage;
  double get currentSessionAccuracy => _currentSessionAccuracy;
  int get answeredQuestions => _sessionAnswers.length;
  int get totalQuestions => _currentQuestions.length;
  bool get isQuizActive => _sessionStartTime != null;
  bool get canAdaptDifficulty =>
      _isAdaptationEnabled && _sessionAnswers.length >= 3;

  Duration get sessionDuration => _sessionStartTime != null
      ? DateTime.now().difference(_sessionStartTime!)
      : Duration.zero;

  // ============ QUIZ COMPLETION ============

  Future<Map<String, dynamic>> finishQuiz() async {
    if (_sessionStartTime == null) {
      return {'error': 'Aktif quiz oturumu yok'};
    }

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    _totalPlayTime += sessionDuration;

    final correctAnswers = _sessionAnswers.where((a) => a).length;
    final wrongAnswers = _sessionAnswers.length - correctAnswers;
    final finalAccuracy = _sessionAnswers.isNotEmpty
        ? (correctAnswers / _sessionAnswers.length) * 100
        : 0.0;

    _updateDifficultyStats(finalAccuracy, sessionDuration);

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

    if (_performanceHistory.length > 50) {
      _performanceHistory.removeAt(0);
    }

    await _saveUserData();

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
      'nextRecommendation':
          _difficultyService.getRecommendedDifficulty().displayName,
    };

    _resetSession();

    return results;
  }

  void _updateDifficultyStats(double accuracy, Duration duration) {
    final stats = _difficultyStats[_currentDifficulty]!;
    final totalQuizzes = (stats['totalQuizzes'] as int? ?? 0) + 1;

    stats['totalQuizzes'] = totalQuizzes;

    if (accuracy >= 70) {
      stats['totalCorrect'] = (stats['totalCorrect'] as int? ?? 0) + 1;
    } else {
      stats['totalWrong'] = (stats['totalWrong'] as int? ?? 0) + 1;
    }

    stats['bestScore'] = max(stats['bestScore'] as int? ?? 0, _currentScore);

    final currentAvg = stats['averageScore'] as double? ?? 0.0;
    final newAvg = ((currentAvg * (totalQuizzes - 1)) + accuracy) / totalQuizzes;
    stats['averageScore'] = newAvg;

    final currentTimeAvg = stats['averageTime'] as double? ?? 0.0;
    final newTimeAvg =
        ((currentTimeAvg * (totalQuizzes - 1)) + duration.inSeconds) /
            totalQuizzes;
    stats['averageTime'] = newTimeAvg;
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

  // ============ ANALYTICS ============

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
        'suggestedDifficulty':
            _difficultyService.getRecommendedDifficulty().displayName,
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
        .whereType<double>()
        .toList();

    if (validAccuracies.isEmpty) return 0.0;

    final totalAccuracy =
        validAccuracies.fold<double>(0.0, (sum, accuracy) => sum + accuracy);
    return totalAccuracy / validAccuracies.length;
  }

  int _getRecommendedQuestionCount() {
    return _difficultyService.getRecommendedQuestionCount(_currentDifficulty);
  }

  void clearPerformanceData() {
    _wrongAnswerCategories.clear();
    _correctAnswerCategories.clear();
    _performanceHistory.clear();
    _usedQuestionIds.clear();
    _difficultyService.clearStats();
  }

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