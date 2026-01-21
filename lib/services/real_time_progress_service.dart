// lib/services/real_time_progress_service.dart
// Real-time progress tracking service for achievements during gameplay

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';

/// Real-time progress tracking service for achievements
class RealTimeProgressService {
  static final RealTimeProgressService _instance =
      RealTimeProgressService._internal();

  factory RealTimeProgressService() => _instance;

  RealTimeProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers for real-time updates
  final StreamController<Map<String, double>> _progressUpdateController =
      StreamController.broadcast();
  final StreamController<List<String>> _unlockedAchievementsController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _sessionProgressController =
      StreamController.broadcast();

  // Streams
  Stream<Map<String, double>> get progressUpdates =>
      _progressUpdateController.stream;
  Stream<List<String>> get unlockedAchievements =>
      _unlockedAchievementsController.stream;
  Stream<Map<String, dynamic>> get sessionProgress =>
      _sessionProgressController.stream;

  // Local session tracking
  final Map<String, int> _sessionProgress = {
    'completedQuizzes': 0,
    'duelWins': 0,
    'multiplayerWins': 0,
    'friendsCount': 0,
    'perfectScore': 0,
    'fastAnswer': 0,
    'streak': 0,
  };

  // Achievement target values
  final Map<String, int> _achievementTargets = {
    'first_quiz': 1,
    'quiz_master': 10,
    'perfect_score': 1,
    'first_duel': 1,
    'duel_champion': 10,
    'social_butterfly': 5,
    'team_player': 5,
    'consistent_player': 7,
    'speed_demon': 1,
  };

  // Track which achievements are unlocked in current session
  final Set<String> _sessionUnlockedAchievements = {};

  // Timer for periodic progress updates
  Timer? _updateTimer;

  /// Start tracking real-time progress
  void startTracking() {
    _updateTimer =
        Timer.periodic(const Duration(milliseconds: 500), (_) {
      _emitProgressUpdates();
    });

    if (kDebugMode) {
      debugPrint('RealTimeProgressService: Tracking started');
    }
  }

  /// Stop tracking real-time progress
  void stopTracking() {
    _updateTimer?.cancel();
    _updateTimer = null;

    if (kDebugMode) {
      debugPrint('RealTimeProgressService: Tracking stopped');
    }
  }

  /// Reset session progress
  void resetSessionProgress() {
    _sessionProgress.updateAll((key, value) => 0);
    _sessionUnlockedAchievements.clear();
    _emitProgressUpdates();

    if (kDebugMode) {
      debugPrint('RealTimeProgressService: Session progress reset');
    }
  }

  /// Increment quiz progress
  void incrementQuizProgress({bool perfectScore = false, bool fastAnswer = false}) {
    _sessionProgress['completedQuizzes'] =
        (_sessionProgress['completedQuizzes'] ?? 0) + 1;

    if (perfectScore) {
      _sessionProgress['perfectScore'] = (_sessionProgress['perfectScore'] ?? 0) + 1;
    }

    if (fastAnswer) {
      _sessionProgress['fastAnswer'] = (_sessionProgress['fastAnswer'] ?? 0) + 1;
    }

    _checkAndUnlockAchievements();
    _emitProgressUpdates();
  }

  /// Increment duel progress
  void incrementDuelProgress() {
    _sessionProgress['duelWins'] = (_sessionProgress['duelWins'] ?? 0) + 1;
    _checkAndUnlockAchievements();
    _emitProgressUpdates();
  }

  /// Increment multiplayer progress
  void incrementMultiplayerProgress() {
    _sessionProgress['multiplayerWins'] =
        (_sessionProgress['multiplayerWins'] ?? 0) + 1;
    _checkAndUnlockAchievements();
    _emitProgressUpdates();
  }

  /// Increment friends count
  void incrementFriendsCount() {
    _sessionProgress['friendsCount'] = (_sessionProgress['friendsCount'] ?? 0) + 1;
    _checkAndUnlockAchievements();
    _emitProgressUpdates();
  }

  /// Update login streak
  void updateStreak(int days) {
    _sessionProgress['streak'] = days;
    _checkAndUnlockAchievements();
    _emitProgressUpdates();
  }

  /// Get current progress for an achievement
  double getProgressForAchievement(String achievementId) {
    final target = _achievementTargets[achievementId] ?? 1;
    final current = _getCurrentProgress(achievementId);
    return (current / target).clamp(0.0, 1.0);
  }

  /// Get progress percentage for display
  int getProgressPercentage(String achievementId) {
    return (getProgressForAchievement(achievementId) * 100).toInt();
  }

  /// Get current progress value for an achievement
  int _getCurrentProgress(String achievementId) {
    switch (achievementId) {
      case 'first_quiz':
        return _sessionProgress['completedQuizzes'] ?? 0;
      case 'quiz_master':
        return _sessionProgress['completedQuizzes'] ?? 0;
      case 'perfect_score':
        return _sessionProgress['perfectScore'] ?? 0;
      case 'first_duel':
        return _sessionProgress['duelWins'] ?? 0;
      case 'duel_champion':
        return _sessionProgress['duelWins'] ?? 0;
      case 'social_butterfly':
        return _sessionProgress['friendsCount'] ?? 0;
      case 'team_player':
        return _sessionProgress['multiplayerWins'] ?? 0;
      case 'consistent_player':
        return _sessionProgress['streak'] ?? 0;
      case 'speed_demon':
        return _sessionProgress['fastAnswer'] ?? 0;
      default:
        return 0;
    }
  }

  /// Get target value for an achievement
  int getTargetForAchievement(String achievementId) {
    return _achievementTargets[achievementId] ?? 1;
  }

  /// Check and unlock achievements based on current progress
  void _checkAndUnlockAchievements() {
    final achievementsToUnlock = <String>[];

    // Quiz achievements
    if (_sessionProgress['completedQuizzes']! >= 1 &&
        !_sessionUnlockedAchievements.contains('first_quiz')) {
      achievementsToUnlock.add('first_quiz');
    }
    if (_sessionProgress['completedQuizzes']! >= 10 &&
        !_sessionUnlockedAchievements.contains('quiz_master')) {
      achievementsToUnlock.add('quiz_master');
    }
    if (_sessionProgress['perfectScore']! >= 1 &&
        !_sessionUnlockedAchievements.contains('perfect_score')) {
      achievementsToUnlock.add('perfect_score');
    }
    if (_sessionProgress['fastAnswer']! >= 1 &&
        !_sessionUnlockedAchievements.contains('speed_demon')) {
      achievementsToUnlock.add('speed_demon');
    }

    // Duel achievements
    if (_sessionProgress['duelWins']! >= 1 &&
        !_sessionUnlockedAchievements.contains('first_duel')) {
      achievementsToUnlock.add('first_duel');
    }
    if (_sessionProgress['duelWins']! >= 10 &&
        !_sessionUnlockedAchievements.contains('duel_champion')) {
      achievementsToUnlock.add('duel_champion');
    }

    // Social achievements
    if (_sessionProgress['friendsCount']! >= 5 &&
        !_sessionUnlockedAchievements.contains('social_butterfly')) {
      achievementsToUnlock.add('social_butterfly');
    }

    // Multiplayer achievements
    if (_sessionProgress['multiplayerWins']! >= 5 &&
        !_sessionUnlockedAchievements.contains('team_player')) {
      achievementsToUnlock.add('team_player');
    }

    // Streak achievements
    if (_sessionProgress['streak']! >= 7 &&
        !_sessionUnlockedAchievements.contains('consistent_player')) {
      achievementsToUnlock.add('consistent_player');
    }

    // Emit unlocked achievements
    if (achievementsToUnlock.isNotEmpty) {
      _sessionUnlockedAchievements.addAll(achievementsToUnlock);
      _unlockedAchievementsController.add(achievementsToUnlock);

      if (kDebugMode) {
        debugPrint(
            'RealTimeProgressService: Unlocked achievements: $achievementsToUnlock');
      }
    }
  }

  /// Emit progress updates to streams
  void _emitProgressUpdates() {
    final progressMap = <String, double>{};

    // Calculate progress for each tracked metric
    _sessionProgress.forEach((key, value) {
      final target = _getTargetForMetric(key);
      progressMap[key] = (value / target).clamp(0.0, 1.0);
    });

    _progressUpdateController.add(progressMap);

    // Emit session progress summary
    _sessionProgressController.add({
      'sessionProgress': Map<String, int>.from(_sessionProgress),
      'unlockedAchievements': _sessionUnlockedAchievements.toList(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  int _getTargetForMetric(String metric) {
    switch (metric) {
      case 'completedQuizzes':
        return 10; // For quiz_master
      case 'duelWins':
        return 10; // For duel_champion
      case 'multiplayerWins':
        return 5; // For team_player
      case 'friendsCount':
        return 5; // For social_butterfly
      case 'perfectScore':
        return 1;
      case 'fastAnswer':
        return 1;
      case 'streak':
        return 7; // For consistent_player
      default:
        return 1;
    }
  }

  /// Get all active achievements with their current progress
  List<Map<String, dynamic>> getActiveAchievementsWithProgress() {
    final activeAchievements = <Map<String, dynamic>>[];

    // Define achievement details
    final achievementDetails = {
      'first_quiz': {'title': 'İlk Adım', 'icon': '🎯', 'category': 'quiz'},
      'quiz_master': {'title': 'Quiz Ustası', 'icon': '🏆', 'category': 'quiz'},
      'perfect_score': {'title': 'Mükemmeliyetçi', 'icon': '💎', 'category': 'quiz'},
      'speed_demon': {'title': 'Hız Şeytanı', 'icon': '⚡', 'category': 'special'},
      'first_duel': {'title': 'Düello Başlangıcı', 'icon': '⚔️', 'category': 'duel'},
      'duel_champion': {'title': 'Düello Şampiyonu', 'icon': '👑', 'category': 'duel'},
      'social_butterfly': {'title': 'Sosyal Kelebek', 'icon': '🦋', 'category': 'social'},
      'team_player': {'title': 'Takım Oyuncusu', 'icon': '🤝', 'category': 'multiplayer'},
      'consistent_player': {'title': 'Düzenli Oyuncu', 'icon': '🔥', 'category': 'streak'},
    };

    achievementDetails.forEach((id, details) {
      final current = _getCurrentProgress(id);
      final target = getTargetForAchievement(id);
      final isUnlocked = _sessionUnlockedAchievements.contains(id);
      final progress = (current / target).clamp(0.0, 1.0);

      activeAchievements.add({
        'id': id,
        'title': details['title'] as String,
        'icon': details['icon'] as String,
        'category': details['category'] as String,
        'current': current,
        'target': target,
        'progress': progress,
        'isUnlocked': isUnlocked,
      });
    });

    return activeAchievements;
  }

  /// Get session summary
  Map<String, dynamic> getSessionSummary() {
    return {
      'sessionProgress': Map<String, int>.from(_sessionProgress),
      'unlockedAchievements': _sessionUnlockedAchievements.toList(),
      'activeAchievements': getActiveAchievementsWithProgress(),
      'totalActions': _sessionProgress.values.fold(0, (a, b) => a + b),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Subscribe to real-time progress updates from Firestore
  Future<void> subscribeToUserProgress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Subscribe to user progress changes
      _firestore
          .collection('user_progress')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final progress = UserProgress.fromJson(snapshot.data()!);
          _handleRemoteProgressUpdate(progress);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RealTimeProgressService: Failed to subscribe to user progress: $e');
      }
    }
  }

  /// Handle remote progress update from Firestore
  void _handleRemoteProgressUpdate(UserProgress progress) {
    // Merge remote progress with session progress
    if (progress.completedQuizzes > (_sessionProgress['completedQuizzes'] ?? 0)) {
      _sessionProgress['completedQuizzes'] = progress.completedQuizzes;
    }
    if (progress.duelWins > (_sessionProgress['duelWins'] ?? 0)) {
      _sessionProgress['duelWins'] = progress.duelWins;
    }
    if (progress.multiplayerWins > (_sessionProgress['multiplayerWins'] ?? 0)) {
      _sessionProgress['multiplayerWins'] = progress.multiplayerWins;
    }
    if (progress.friendsCount > (_sessionProgress['friendsCount'] ?? 0)) {
      _sessionProgress['friendsCount'] = progress.friendsCount;
    }
    if (progress.loginStreak > (_sessionProgress['streak'] ?? 0)) {
      _sessionProgress['streak'] = progress.loginStreak;
    }

    _emitProgressUpdates();
  }

  /// Save current progress to Firestore
  Future<void> saveProgressToFirestore() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('user_progress').doc(userId).update({
        'completedQuizzes': FieldValue.increment(_sessionProgress['completedQuizzes'] ?? 0),
        'duelWins': FieldValue.increment(_sessionProgress['duelWins'] ?? 0),
        'multiplayerWins': FieldValue.increment(_sessionProgress['multiplayerWins'] ?? 0),
        'friendsCount': FieldValue.increment(_sessionProgress['friendsCount'] ?? 0),
        'loginStreak': _sessionProgress['streak'] ?? 0,
        'lastProgressUpdate': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('RealTimeProgressService: Progress saved to Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RealTimeProgressService: Failed to save progress: $e');
      }
    }
  }

  /// Clean up resources
  void dispose() {
    stopTracking();
    _progressUpdateController.close();
    _unlockedAchievementsController.close();
    _sessionProgressController.close();
  }
}

/// Achievement progress notifier for widgets
class AchievementProgressNotifier extends ChangeNotifier {
  final RealTimeProgressService _progressService = RealTimeProgressService();

  Map<String, double> _currentProgress = {};
  List<String> _unlockedAchievements = [];
  bool _isLoading = true;

  Map<String, double> get currentProgress => _currentProgress;
  List<String> get unlockedAchievements => _unlockedAchievements;
  bool get isLoading => _isLoading;

  AchievementProgressNotifier() {
    _initialize();
  }

  void _initialize() {
    // Listen to progress updates
    _progressService.progressUpdates.listen((progress) {
      _currentProgress = progress;
      notifyListeners();
    });

    // Listen to unlocked achievements
    _progressService.unlockedAchievements.listen((achievements) {
      _unlockedAchievements = achievements;
      notifyListeners();
    });

    // Start tracking
    _progressService.startTracking();
    _isLoading = false;
  }

  /// Get progress for a specific metric
  double getProgress(String metric) {
    return _currentProgress[metric] ?? 0.0;
  }

  /// Check if an achievement is unlocked
  bool isUnlocked(String achievementId) {
    return _unlockedAchievements.contains(achievementId);
  }

  /// Get active achievements with progress
  List<Map<String, dynamic>> getActiveAchievements() {
    return _progressService.getActiveAchievementsWithProgress();
  }

  @override
  void dispose() {
    _progressService.dispose();
    super.dispose();
  }
}

