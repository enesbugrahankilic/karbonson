// lib/services/state_refresh_service.dart
// State Refresh Service for UI synchronization

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Event class for state refresh notifications
class RefreshEvent {
  final String type;
  final DateTime timestamp;
  
  RefreshEvent({required this.type}) : timestamp = DateTime.now();
  
  @override
  String toString() => 'RefreshEvent(type: $type)';
}

/// State Refresh Service - Handles state synchronization between backend and UI
/// Part of Tasks 15-16: General State & Data Synchronization
class StateRefreshService extends ChangeNotifier {
  static final StateRefreshService _instance = StateRefreshService._internal();
  
  factory StateRefreshService() {
    return _instance;
  }
  
  StateRefreshService._internal();
  
  // Global refresh triggers
  final Map<String, bool> _staleStates = {};
  
  // Stream for refresh events
  final StreamController<RefreshEvent> _refreshStreamController = 
      StreamController<RefreshEvent>.broadcast();
  
  // Stream getter for compatibility
  Stream<RefreshEvent> get refreshStream => _refreshStreamController.stream;
  
  /// Emit a refresh event
  void _emitRefreshEvent(String type) {
    final event = RefreshEvent(type: type);
    _refreshStreamController.add(event);
    if (kDebugMode) {
      debugPrint('📡 [STATE_REFRESH] Event emitted: $event');
    }
  }
  
  /// Mark a page/state as stale, requiring refresh
  void markAsStale(String stateKey) {
    _staleStates[stateKey] = true;
    if (kDebugMode) {
      debugPrint('🔄 [STATE_REFRESH] State marked stale: $stateKey');
    }
    notifyListeners();
  }
  
  /// Check if a state is stale
  bool isStale(String stateKey) {
    return _staleStates[stateKey] ?? false;
  }
  
  /// Clear stale state after refresh
  void clearStaleState(String stateKey) {
    _staleStates[stateKey] = false;
    if (kDebugMode) {
      debugPrint('✅ [STATE_REFRESH] State refreshed: $stateKey');
    }
  }
  
  /// Refresh all stale states
  void refreshAll() {
    if (kDebugMode) {
      debugPrint('🔄 [STATE_REFRESH] Refreshing all stale states');
    }
    _staleStates.clear();
    _emitRefreshEvent('comprehensive');
    notifyListeners();
  }
  
  /// Force refresh a specific page by key
  Future<void> forceRefresh(String stateKey) async {
    if (kDebugMode) {
      debugPrint('💪 [STATE_REFRESH] Force refreshing: $stateKey');
    }
    
    // Clear first
    clearStaleState(stateKey);
    
    // Mark as needing refresh
    markAsStale(stateKey);
    
    // Wait a tick for UI to respond
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Clear again to indicate refresh complete
    clearStaleState(stateKey);
  }
  
  // === Compatibility methods for existing code ===
  
  /// Trigger rewards refresh
  void triggerRewardsRefresh() {
    if (kDebugMode) {
      debugPrint('🎁 [STATE_REFRESH] Triggering rewards refresh');
    }
    markAsStale('rewards');
    _emitRefreshEvent('rewards');
  }
  
  /// Trigger progress refresh
  void triggerProgressRefresh() {
    if (kDebugMode) {
      debugPrint('📊 [STATE_REFRESH] Triggering progress refresh');
    }
    markAsStale('progress');
    _emitRefreshEvent('progress');
  }
  
  /// Trigger quiz completion refresh
  void triggerQuizCompletionRefresh() {
    if (kDebugMode) {
      debugPrint('✅ [STATE_REFRESH] Triggering quiz completion refresh');
    }
    markAsStale('quiz_completion');
    _emitRefreshEvent('quiz_completion');
  }
  
  /// Trigger game completion refresh
  void triggerGameCompletionRefresh() {
    if (kDebugMode) {
      debugPrint('🎮 [STATE_REFRESH] Triggering game completion refresh');
    }
    markAsStale('game_completion');
    _emitRefreshEvent('game_completion');
  }
  
  /// Trigger comprehensive refresh (all related data)
  void triggerComprehensiveRefresh() {
    if (kDebugMode) {
      debugPrint('🔄 [STATE_REFRESH] Triggering comprehensive refresh');
    }
    markAsStale('all');
    markAsStale('rewards');
    markAsStale('progress');
    markAsStale('quiz_completion');
    markAsStale('game_completion');
    markAsStale('daily_tasks');
    markAsStale('achievements');
    _emitRefreshEvent('comprehensive');
    notifyListeners();
  }
  
  // Pre-defined state keys for common pages
  static const String leaderboardState = 'leaderboard';
  static const String profileState = 'profile';
  static const String friendsState = 'friends';
  static const String achievementsState = 'achievements';
  static const String dailyTasksState = 'daily_tasks';
  static const String duelState = 'duel';
  static const String aiRecommendationsState = 'ai_recommendations';
  
  @override
  void dispose() {
    _refreshStreamController.close();
    super.dispose();
  }
}

