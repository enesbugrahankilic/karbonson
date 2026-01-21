// lib/services/daily_task_refresh_service.dart
// Günlük Görev Otomatik Yenileme Servisi
// Her gün otomatik olarak yeni görevler oluşturur ve eski görevleri temizler

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_challenge.dart';
import 'challenge_service.dart';
import 'notification_service.dart';

/// Günlük görev yenileme durumu
enum DailyTaskRefreshState {
  idle,
  checking,
  refreshing,
  completed,
  error,
}

/// Günlük görev yenileme servisi
class DailyTaskRefreshService {
  static final DailyTaskRefreshService _instance =
      DailyTaskRefreshService._internal();
  factory DailyTaskRefreshService() => _instance;
  DailyTaskRefreshService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChallengeService _challengeService = ChallengeService();
  final NotificationService _notificationService = NotificationService();

  // Timer for periodic checking
  Timer? _refreshTimer;
  Timer? _dailyCheckTimer;

  // State management
  final StreamController<DailyTaskRefreshState> _stateController =
      StreamController<DailyTaskRefreshState>.broadcast();
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  // Refresh state
  DailyTaskRefreshState _currentState = DailyTaskRefreshState.idle;
  DateTime? _lastRefreshDate;
  String? _lastError;

  // Constants
  static const String _prefsLastRefreshKey = 'daily_tasks_last_refresh';
  static const Duration _refreshCheckInterval = Duration(hours: 1);
  static const Duration _dailyCheckInterval = Duration(hours: 4);

  // Stream getters
  Stream<DailyTaskRefreshState> get stateStream => _stateController.stream;
  Stream<String> get logStream => _logController.stream;

  // State getters
  DailyTaskRefreshState get currentState => _currentState;
  DateTime? get lastRefreshDate => _lastRefreshDate;
  String? get lastError => _lastError;

  /// Servisi başlat
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('🚀 DailyTaskRefreshService başlatılıyor...');
    }

    try {
      // Son yenileme tarihini yükle
      await _loadLastRefreshDate();

      // Periyodik kontrol başlat
      _startPeriodicCheck();

      // Günlük kontrol başlat
      _startDailyCheck();

      // Kullanıcı oturum değişikliğini dinle
      _auth.authStateChanges().listen(_onAuthStateChanged);

      _updateState(DailyTaskRefreshState.completed);
      
      if (kDebugMode) {
        debugPrint('✅ DailyTaskRefreshService başlatıldı');
      }
    } catch (e) {
      _lastError = 'Initialization error: $e';
      _updateState(DailyTaskRefreshState.error);
      if (kDebugMode) {
        debugPrint('❌ DailyTaskRefreshService başlatma hatası: $e');
      }
    }
  }

  /// Son yenileme tarihini yükle
  Future<void> _loadLastRefreshDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_prefsLastRefreshKey);
      if (timestamp != null) {
        _lastRefreshDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (kDebugMode) {
          debugPrint('📅 Son yenileme: $_lastRefreshDate');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Last refresh date yüklenemedi: $e');
    }
  }

  /// Son yenileme tarihini kaydet
  Future<void> _saveLastRefreshDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _prefsLastRefreshKey, DateTime.now().millisecondsSinceEpoch);
      _lastRefreshDate = DateTime.now();
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Last refresh date kaydedilemedi: $e');
    }
  }

  /// Periyodik kontrol başlat
  void _startPeriodicCheck() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshCheckInterval, (_) {
      _checkAndRefreshIfNeeded();
    });
  }

  /// Günlük kontrol başlat
  void _startDailyCheck() {
    _dailyCheckTimer?.cancel();
    
    // Her 4 saatte bir gün değişikliğini kontrol et
    _dailyCheckTimer = Timer.periodic(_dailyCheckInterval, (_) {
      _checkForNewDay();
    });
  }

  /// Gün değişikliğini kontrol et
  void _checkForNewDay() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_lastRefreshDate != null) {
        final lastRefresh = DateTime(
          _lastRefreshDate!.year,
          _lastRefreshDate!.month,
          _lastRefreshDate!.day,
        );

        if (today.isAfter(lastRefresh)) {
          if (kDebugMode) {
            debugPrint('🔄 Yeni gün tespit edildi, görevler yenileniyor...');
          }
          await refreshDailyTasks();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Gün kontrolü hatası: $e');
    }
  }

  /// Gerektiğinde kontrol et ve yenile
  Future<void> _checkAndRefreshIfNeeded() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Bugün için görev var mı kontrol et
      final todayChallenges =
          await _challengeService.getTodayDailyChallenges();

      if (todayChallenges.isEmpty) {
        if (kDebugMode) {
          debugPrint('📋 Bugün için görev bulunamadı, yenileniyor...');
        }
        await refreshDailyTasks();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Kontrol hatası: $e');
    }
  }

  /// Oturum değişikliğinde kontrol et
  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      if (kDebugMode) {
        debugPrint('👤 Kullanıcı giriş yaptı, görevler kontrol ediliyor...');
      }
      await _checkAndRefreshIfNeeded();
    }
  }

  /// Günlük görevleri yenile
  Future<bool> refreshDailyTasks() async {
    if (_currentState == DailyTaskRefreshState.refreshing) {
      if (kDebugMode) {
        debugPrint('⏳ Yenileme zaten devam ediyor');
      }
      return false;
    }

    _updateState(DailyTaskRefreshState.refreshing);
    _log('🔄 Günlük görevler yenileniyor...');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _lastError = 'Kullanıcı girişi yapmamış';
        _updateState(DailyTaskRefreshState.error);
        return false;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Eski görevleri kontrol et
      await _cleanupOldChallenges(user.uid, today);

      // Bugün için görevleri kontrol et
      final todayChallenges =
          await _challengeService.getTodayDailyChallenges(uid: user.uid);

      if (todayChallenges.isNotEmpty) {
        _log('ℹ️ Bugün için ${todayChallenges.length} görev zaten mevcut');
        await _saveLastRefreshDate();
        _updateState(DailyTaskRefreshState.completed);
        return true;
      }

      // Yeni görevler oluştur
      _log('📝 Yeni görevler oluşturuluyor...');

      // ChallengeService ile görevler oluştur
      final dailyChallengeIds =
          await _challengeService.generateTodayDailyChallenges(uid: user.uid);
      final weeklyChallengeIds =
          await _challengeService.generateWeeklyChallenges(uid: user.uid);

      // Özel görevler de ekle
      await _generateSpecialChallenges(user.uid, today);

      await _saveLastRefreshDate();

      _log('✅ ${dailyChallengeIds.length} günlük, ${weeklyChallengeIds.length} haftalık görev oluşturuldu');

      // Bildirim gönder
      await _notificationService.showDailyChallengeNotification();

      _updateState(DailyTaskRefreshState.completed);
      return true;
    } catch (e) {
      _lastError = 'Yenileme hatası: $e';
      _log('❌ Hata: $e');
      _updateState(DailyTaskRefreshState.error);
      return false;
    }
  }

  /// Özel görevler oluştur
  Future<void> _generateSpecialChallenges(String userId, DateTime date) async {
    try {
      final now = DateTime.now();
      final dateOnly = DateTime(now.year, now.month, now.day);
      final expiresAt = dateOnly.add(const Duration(days: 1));

      // Energy task
      final energyChallenge = DailyChallenge(
        id: '',
        title: 'Enerji Tasarrufu Uzmanı',
        description: 'Gün içinde 2 enerji quizi çöz',
        type: ChallengeType.energy,
        targetValue: 2,
        currentValue: 0,
        rewardPoints: 40,
        rewardType: RewardType.points,
        date: dateOnly,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.easy,
        icon: '⚡',
      );
      await _challengeService.createDailyChallenge(energyChallenge);

      // Water task
      final waterChallenge = DailyChallenge(
        id: '',
        title: 'Su Duyarlılığı',
        description: 'Su tasarrufu hakkında 2 quiz çöz',
        type: ChallengeType.water,
        targetValue: 2,
        currentValue: 0,
        rewardPoints: 35,
        rewardType: RewardType.points,
        date: dateOnly,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.easy,
        icon: '💧',
      );
      await _challengeService.createDailyChallenge(waterChallenge);

      // Recycling task
      final recyclingChallenge = DailyChallenge(
        id: '',
        title: 'Geri Dönüşüm Elçisi',
        description: 'Geri dönüşüm konusunda 2 quiz çöz',
        type: ChallengeType.recycling,
        targetValue: 2,
        currentValue: 0,
        rewardPoints: 35,
        rewardType: RewardType.points,
        date: dateOnly,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.easy,
        icon: '♻️',
      );
      await _challengeService.createDailyChallenge(recyclingChallenge);

      // Forest task
      final forestChallenge = DailyChallenge(
        id: '',
        title: 'Orman Sever',
        description: 'Ormanlar hakkında 2 quiz çöz',
        type: ChallengeType.forest,
        targetValue: 2,
        currentValue: 0,
        rewardPoints: 35,
        rewardType: RewardType.points,
        date: dateOnly,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.easy,
        icon: '🌲',
      );
      await _challengeService.createDailyChallenge(forestChallenge);

      // Streak task
      final streakChallenge = DailyChallenge(
        id: '',
        title: 'Seri Koruma',
        description: 'Bugün quiz çözerek serini koru',
        type: ChallengeType.streak,
        targetValue: 1,
        currentValue: 0,
        rewardPoints: 20,
        rewardType: RewardType.points,
        date: dateOnly,
        expiresAt: expiresAt,
        isCompleted: false,
        difficulty: ChallengeDifficulty.easy,
        icon: '🔥',
      );
      await _challengeService.createDailyChallenge(streakChallenge);

      if (kDebugMode) {
        debugPrint('✅ 5 özel görev oluşturuldu');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Özel görev oluşturma hatası: $e');
    }
  }

  /// Eski görevleri temizle
  Future<void> _cleanupOldChallenges(String userId, DateTime today) async {
    try {
      final challenges =
          await _challengeService.getUserDailyChallenges(uid: userId);

      for (final challenge in challenges) {
        final challengeDate = DateTime(
          challenge.date.year,
          challenge.date.month,
          challenge.date.day,
        );

        // 2 günden eski görevleri sil
        if (today.difference(challengeDate).inDays > 1) {
          await _challengeService.deleteDailyChallenge(challenge.id,
              uid: userId);
          if (kDebugMode) {
            debugPrint('🗑️ Eski görev silindi: ${challenge.title}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Görev temizleme hatası: $e');
    }
  }

  /// Manuel yenileme tetikle
  Future<bool> forceRefresh() async {
    if (kDebugMode) {
      debugPrint('🔄 Manuel yenileme tetiklendi');
    }
    return await refreshDailyTasks();
  }

  /// Durumu güncelle
  void _updateState(DailyTaskRefreshState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Log ekle
  void _log(String message) {
    _logController.add(message);
    if (kDebugMode) debugPrint(message);
  }

  /// Bugün görevler yenilendi mi?
  bool get isRefreshedToday {
    if (_lastRefreshDate == null) return false;
    final today = DateTime.now();
    final lastRefresh = DateTime(
      _lastRefreshDate!.year,
      _lastRefreshDate!.month,
      _lastRefreshDate!.day,
    );
    return today.isAtSameMomentAs(lastRefresh);
  }

  /// Sonraki yenileme zamanını hesapla
  DateTime? get nextRefreshTime {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));

    // Son yenileme bugün yapıldıysa, yarına bak
    if (isRefreshedToday) {
      return tomorrow;
    }

    // Son yenileme yapılmamışsa, yarın sabah 00:00
    return tomorrow;
  }

  /// Servisi durdur
  void dispose() {
    _refreshTimer?.cancel();
    _dailyCheckTimer?.cancel();
    _stateController.close();
    _logController.close();
  }
}

