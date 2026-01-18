// lib/core/navigation/navigation_service.dart
// Centralized navigation state management and analytics

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// Navigation event types for analytics
enum NavigationEventType {
  push,
  pop,
  pushReplacement,
  pushAndRemoveUntil,
  deepLink,
  error,
}

/// Navigation analytics event
class NavigationAnalyticsEvent {
  final NavigationEventType type;
  final String? fromRoute;
  final String? toRoute;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const NavigationAnalyticsEvent({
    required this.type,
    this.fromRoute,
    this.toRoute,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'fromRoute': fromRoute,
        'toRoute': toRoute,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

/// Navigation service for centralized state management and analytics
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Global navigator key for programmatic navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigation state
  final List<String> _routeStack = [];
  final List<NavigationAnalyticsEvent> _navigationHistory = [];
  final Set<NavigatorObserver> _observers = {};

  // Current route state
  String? get currentRoute => _routeStack.isEmpty ? null : _routeStack.last;
  List<String> get routeStack => List.unmodifiable(_routeStack);
  List<NavigationAnalyticsEvent> get navigationHistory =>
      List.unmodifiable(_navigationHistory);

  /// Add a route to the stack
  void _addRoute(String route) {
    _routeStack.add(route);
    logNavigationEvent(
      NavigationEventType.push,
      toRoute: route,
    );
  }

  /// Remove a route from the stack
  String? _removeRoute() {
    if (_routeStack.isEmpty) return null;
    final removedRoute = _routeStack.removeLast();
    logNavigationEvent(
      NavigationEventType.pop,
      fromRoute: removedRoute,
    );
    return removedRoute;
  }

  /// Log navigation event for analytics
  void logNavigationEvent(
    NavigationEventType type, {
    String? fromRoute,
    String? toRoute,
    Map<String, dynamic>? metadata,
  }) {
    final event = NavigationAnalyticsEvent(
      type: type,
      fromRoute: fromRoute,
      toRoute: toRoute,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _navigationHistory.add(event);

    // Keep only last 100 events to prevent memory issues
    if (_navigationHistory.length > 100) {
      _navigationHistory.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint(
          'Navigation: ${type.name} ${fromRoute ?? ''} -> ${toRoute ?? ''}');
    }

    // Notify observers (Flutter handles the actual route notifications)
    if (kDebugMode) {
      debugPrint('Navigation event logged: ${type.name}');
    }
  }

  /// Register a navigation observer
  void registerObserver(NavigatorObserver observer) {
    _observers.add(observer);
  }

  /// Unregister a navigation observer
  void unregisterObserver(NavigatorObserver observer) {
    _observers.remove(observer);
  }

  /// Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
  }

  /// Get navigation statistics
  Map<String, dynamic> getNavigationStats() {
    final routeCounts = <String, int>{};
    final eventCounts = <String, int>{};

    for (final event in _navigationHistory) {
      eventCounts[event.type.name] = (eventCounts[event.type.name] ?? 0) + 1;
      if (event.toRoute != null) {
        routeCounts[event.toRoute!] = (routeCounts[event.toRoute!] ?? 0) + 1;
      }
    }

    return {
      'totalEvents': _navigationHistory.length,
      'currentRoute': currentRoute,
      'routeStackDepth': _routeStack.length,
      'eventTypeCounts': eventCounts,
      'routeVisitCounts': routeCounts,
      'mostVisitedRoute': routeCounts.isEmpty
          ? null
          : routeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key,
    };
  }

  /// Analyze navigation patterns
  Map<String, dynamic> analyzeNavigationPatterns() {
    if (_navigationHistory.length < 2) {
      return {'message': 'Not enough navigation data for analysis'};
    }

    final routes = _navigationHistory
        .where((e) => e.toRoute != null)
        .map((e) => e.toRoute!)
        .toList();

    final transitions = <String, int>{};
    for (int i = 0; i < routes.length - 1; i++) {
      final transition = '${routes[i]} -> ${routes[i + 1]}';
      transitions[transition] = (transitions[transition] ?? 0) + 1;
    }

    // Find most common navigation flow
    String? mostCommonFlow;
    int maxCount = 0;
    transitions.forEach((flow, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonFlow = flow;
      }
    });

    return {
      'totalNavigations': routes.length,
      'uniqueRoutesVisited': routes.toSet().length,
      'mostCommonFlow': mostCommonFlow,
      'mostCommonFlowCount': maxCount,
      'averageSessionDepth': _calculateAverageSessionDepth(),
      'abandonedRoutes': _findAbandonedRoutes(),
    };
  }

  double _calculateAverageSessionDepth() {
    if (_navigationHistory.isEmpty) return 0;

    int sessionDepth = 0;
    int sessions = 1;

    for (final event in _navigationHistory) {
      switch (event.type) {
        case NavigationEventType.push:
          sessionDepth++;
          break;
        case NavigationEventType.pop:
          sessionDepth = (sessionDepth - 1).clamp(0, sessionDepth);
          break;
        case NavigationEventType.pushReplacement:
          // No change to depth
          break;
        case NavigationEventType.pushAndRemoveUntil:
          sessionDepth = 1; // Reset to base
          break;
        default:
          break;
      }

      if (sessionDepth == 0 && event.type == NavigationEventType.push) {
        sessions++;
      }
    }

    return _navigationHistory.length / sessions;
  }

  List<String> _findAbandonedRoutes() {
    // Routes that were visited but never completed (user left the app)
    final visitedRoutes = _navigationHistory
        .where((e) => e.toRoute != null)
        .map((e) => e.toRoute!)
        .toSet();

    final completedRoutes = <String>{};
    for (final event in _navigationHistory.reversed) {
      if (event.type == NavigationEventType.pop) {
        completedRoutes.add(event.fromRoute!);
      }
    }

    return visitedRoutes.difference(completedRoutes).toList();
  }

  /// Get recent navigation activity
  List<NavigationAnalyticsEvent> getRecentActivity({int limit = 10}) {
    final startIndex =
        (_navigationHistory.length - limit).clamp(0, _navigationHistory.length);
    return _navigationHistory.sublist(startIndex);
  }

  /// Check if user navigated to a specific route recently
  bool hasVisitedRouteRecently(String route,
      {Duration within = const Duration(minutes: 5)}) {
    final cutoff = DateTime.now().subtract(within);
    return _navigationHistory.any(
      (event) => event.toRoute == route && event.timestamp.isAfter(cutoff),
    );
  }

  /// Get navigation performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    if (_navigationHistory.isEmpty) {
      return {'message': 'No navigation data available'};
    }

    final navigations = _navigationHistory
        .where((e) =>
            e.type == NavigationEventType.push ||
            e.type == NavigationEventType.pushReplacement)
        .toList();

    if (navigations.length < 2) {
      return {'message': 'Not enough navigation data for performance analysis'};
    }

    final intervals = <int>[];
    for (int i = 1; i < navigations.length; i++) {
      final diff = navigations[i]
          .timestamp
          .difference(navigations[i - 1].timestamp)
          .inMilliseconds;
      intervals.add(diff);
    }

    final averageInterval =
        intervals.reduce((a, b) => a + b) / intervals.length;
    final maxInterval = intervals.reduce((a, b) => a > b ? a : b);
    final minInterval = intervals.reduce((a, b) => a < b ? a : b);

    return {
      'totalNavigations': navigations.length,
      'averageTimeBetweenNavigationsMs': averageInterval.round(),
      'longestTimeBetweenNavigationsMs': maxInterval,
      'shortestTimeBetweenNavigationsMs': minInterval,
      'navigationFrequencyPerMinute': (60000 / averageInterval).round(),
    };
  }

  /// Export navigation data for analysis
  Map<String, dynamic> exportData() {
    return {
      'exportTimestamp': DateTime.now().toIso8601String(),
      'totalEvents': _navigationHistory.length,
      'routeStack': List<String>.from(_routeStack),
      'events': _navigationHistory.map((e) => e.toJson()).toList(),
      'statistics': getNavigationStats(),
      'patterns': analyzeNavigationPatterns(),
      'performance': getPerformanceMetrics(),
    };
  }

  /// Programmatic navigation methods
  void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  void navigateToReplacement(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  void navigateBack({Object? result}) {
    navigatorKey.currentState?.pop(result);
  }

  /// Show snackbar using navigator context
  void showSnackBar(String message, {Color? backgroundColor, Duration? duration}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration ?? const Duration(seconds: 4),
        ),
      );
    }
  }
}

/// Custom Navigator observer for tracking navigation
class AppNavigatorObserver extends NavigatorObserver {
  final NavigationService _navigationService = NavigationService();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = _getRouteName(route);

    if (routeName != null) {
      _navigationService._addRoute(routeName);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = _getRouteName(route);

    if (routeName != null) {
      _navigationService._removeRoute();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final newRouteName = _getRouteName(newRoute);
    final oldRouteName = _getRouteName(oldRoute);

    if (oldRouteName != null) {
      _navigationService._removeRoute();
    }

    if (newRouteName != null) {
      _navigationService._addRoute(newRouteName);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = _getRouteName(route);

    if (routeName != null) {
      _navigationService._removeRoute();
    }
  }

  String? _getRouteName(Route<dynamic>? route) {
    if (route?.settings is AppRouteSettings) {
      return (route!.settings as AppRouteSettings).name;
    }
    return route?.settings.name;
  }
}

/// Enhanced route settings with metadata
class AppRouteSettings extends RouteSettings {
  final Map<String, dynamic>? metadata;
  final bool requiresAuth;
  final String? redirectTo;

  const AppRouteSettings({
    required super.name,
    super.arguments,
    this.metadata,
    this.requiresAuth = false,
    this.redirectTo,
  });

  AppRouteSettings copyWith({
    String? name,
    Object? arguments,
    Map<String, dynamic>? metadata,
    bool? requiresAuth,
    String? redirectTo,
  }) {
    return AppRouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      metadata: metadata ?? this.metadata,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      redirectTo: redirectTo ?? this.redirectTo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'metadata': metadata,
      'requiresAuth': requiresAuth,
      'redirectTo': redirectTo,
    };
  }
}
