// lib/services/state_refresh_service.dart
// Centralized State Refresh Service - Quiz/Oyun sonrası force refresh mekanizması

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Refresh event types enum
enum RefreshType {
  /// Tüm verileri yenile
  all,
  
  /// Görevleri yenile
  tasks,
  
  /// Başarımları yenile
  achievements,
  
  /// Puan ve ilerlemeyi yenile
  progress,
  
  /// Ödülleri yenile
  rewards,
  
  /// Kutuları (loot box) yenile
  lootBoxes,
  
  /// Profil verilerini yenile
  profile,
}

/// Refresh event data class
class RefreshEvent {
  final RefreshType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RefreshEvent({
    required this.type,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a comprehensive refresh event
  static RefreshEvent comprehensive() {
    return RefreshEvent(
      type: RefreshType.all,
      metadata: {'source': 'quiz_or_game_completion'},
    );
  }

  /// Create a quiz completion refresh event
  static RefreshEvent quizCompletion({int? score, dynamic category}) {
    return RefreshEvent(
      type: RefreshType.all,
      metadata: {
        'source': 'quiz_completion',
        'score': score,
        'category': category,
      },
    );
  }

  /// Create a game completion refresh event
  static RefreshEvent gameCompletion({String? gameType, int? position}) {
    return RefreshEvent(
      type: RefreshType.all,
      metadata: {
        'source': 'game_completion',
        'gameType': gameType,
        'position': position,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Centralized State Refresh Service
/// Quiz veya oyun bittikten sonra tüm ilgili verilerin force refresh yapılmasını sağlar
class StateRefreshService {
  static final StateRefreshService _instance = StateRefreshService._internal();
  factory StateRefreshService() => _instance;
  StateRefreshService._internal();

  // Stream controller for refresh events
  final StreamController<RefreshEvent> _refreshController = StreamController<RefreshEvent>.broadcast();
  
  // Stream for specific refresh types
  final StreamController<RefreshEvent> _achievementsRefreshController = StreamController<RefreshEvent>.broadcast();
  final StreamController<RefreshEvent> _progressRefreshController = StreamController<RefreshEvent>.broadcast();
  final StreamController<RefreshEvent> _rewardsRefreshController = StreamController<RefreshEvent>.broadcast();
  final StreamController<RefreshEvent> _lootBoxesRefreshController = StreamController<RefreshEvent>.broadcast();
  final StreamController<RefreshEvent> _tasksRefreshController = StreamController<RefreshEvent>.broadcast();

  // Streams getters
  Stream<RefreshEvent> get refreshStream => _refreshController.stream;
  Stream<RefreshEvent> get achievementsRefreshStream => _achievementsRefreshController.stream;
  Stream<RefreshEvent> get progressRefreshStream => _progressRefreshController.stream;
  Stream<RefreshEvent> get rewardsRefreshStream => _rewardsRefreshController.stream;
  Stream<RefreshEvent> get lootBoxesRefreshStream => _lootBoxesRefreshController.stream;
  Stream<RefreshEvent> get tasksRefreshStream => _tasksRefreshController.stream;

  // Tracking refresh subscriptions for cleanup
  final List<StreamSubscription<RefreshEvent>> _subscriptions = [];

  /// Trigger a comprehensive refresh for all data
  /// Bu metod quiz veya oyun tamamlandıktan sonra çağrılmalıdır
  void triggerComprehensiveRefresh({Map<String, dynamic>? metadata}) {
    final event = RefreshEvent(
      type: RefreshType.all,
      metadata: metadata ?? {'source': 'manual_refresh'},
    );

    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Comprehensive refresh triggered');
    }
  }

  /// Trigger refresh after quiz completion
  void triggerQuizCompletionRefresh({int? score, String? category}) {
    final event = RefreshEvent.quizCompletion(score: score, category: category);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Quiz completion refresh triggered (score: $score)');
    }
  }

  /// Trigger refresh after game completion
  void triggerGameCompletionRefresh({String? gameType, int? position}) {
    final event = RefreshEvent.gameCompletion(gameType: gameType, position: position);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Game completion refresh triggered (gameType: $gameType)');
    }
  }

  /// Trigger achievements refresh
  void triggerAchievementsRefresh() {
    final event = RefreshEvent(type: RefreshType.achievements);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Achievements refresh triggered');
    }
  }

  /// Trigger progress refresh
  void triggerProgressRefresh() {
    final event = RefreshEvent(type: RefreshType.progress);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Progress refresh triggered');
    }
  }

  /// Trigger rewards refresh
  void triggerRewardsRefresh() {
    final event = RefreshEvent(type: RefreshType.rewards);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Rewards refresh triggered');
    }
  }

  /// Trigger loot boxes refresh
  void triggerLootBoxesRefresh() {
    final event = RefreshEvent(type: RefreshType.lootBoxes);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Loot boxes refresh triggered');
    }
  }

  /// Trigger tasks refresh
  void triggerTasksRefresh() {
    final event = RefreshEvent(type: RefreshType.tasks);
    _broadcastRefresh(event);
    
    if (kDebugMode) {
      debugPrint('🔄 StateRefreshService: Tasks refresh triggered');
    }
  }

  /// Broadcast refresh event to all streams
  void _broadcastRefresh(RefreshEvent event) {
    // Main refresh stream
    _refreshController.add(event);

    // Type-specific streams
    switch (event.type) {
      case RefreshType.all:
      case RefreshType.achievements:
        _achievementsRefreshController.add(event);
        _progressRefreshController.add(event);
        _rewardsRefreshController.add(event);
        _lootBoxesRefreshController.add(event);
        _tasksRefreshController.add(event);
        break;
      case RefreshType.achievements:
        _achievementsRefreshController.add(event);
        break;
      case RefreshType.progress:
        _progressRefreshController.add(event);
        break;
      case RefreshType.rewards:
        _rewardsRefreshController.add(event);
        break;
      case RefreshType.lootBoxes:
        _lootBoxesRefreshController.add(event);
        break;
      case RefreshType.tasks:
        _tasksRefreshController.add(event);
        break;
      case RefreshType.profile:
        _progressRefreshController.add(event);
        break;
    }
  }

  /// Subscribe to all refresh events with a callback
  StreamSubscription<RefreshEvent> subscribeToRefresh(
    void Function(RefreshEvent) onData, {
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = _refreshController.stream.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to achievements-specific refresh events
  StreamSubscription<RefreshEvent> subscribeToAchievementsRefresh(
    void Function(RefreshEvent) onData, {
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = _achievementsRefreshController.stream.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to progress-specific refresh events
  StreamSubscription<RefreshEvent> subscribeToProgressRefresh(
    void Function(RefreshEvent) onData, {
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = _progressRefreshController.stream.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to rewards-specific refresh events
  StreamSubscription<RefreshEvent> subscribeToRewardsRefresh(
    void Function(RefreshEvent) onData, {
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = _rewardsRefreshController.stream.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribe to loot boxes-specific refresh events
  StreamSubscription<RefreshEvent> subscribeToLootBoxesRefresh(
    void Function(RefreshEvent) onData, {
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = _lootBoxesRefreshController.stream.listen(
      onData,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Clean up all subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    _refreshController.close();
    _achievementsRefreshController.close();
    _progressRefreshController.close();
    _rewardsRefreshController.close();
    _lootBoxesRefreshController.close();
    _tasksRefreshController.close();
    
    if (kDebugMode) {
      debugPrint('🗑️ StateRefreshService disposed');
    }
  }
}

