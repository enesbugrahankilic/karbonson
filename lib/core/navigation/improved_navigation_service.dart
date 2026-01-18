// lib/core/navigation/improved_navigation_service.dart
// Advanced navigation service with guards, analytics, and state management

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'improved_app_router.dart';
import '../../services/comprehensive_2fa_service.dart';

/// Navigation event for analytics and logging
class NavigationEvent {
  final String fromRoute;
  final String toRoute;
  final DateTime timestamp;
  final Map<String, dynamic>? arguments;
  final NavigationType type;

  NavigationEvent({
    required this.fromRoute,
    required this.toRoute,
    required this.timestamp,
    this.arguments,
    this.type = NavigationType.push,
  });

  @override
  String toString() => 'NavigationEvent(from: $fromRoute, to: $toRoute, type: $type)';
}

/// Types of navigation events
enum NavigationType { push, pop, replace, replaceAll }

/// Navigation guards for route protection
abstract class NavigationGuard {
  Future<bool> canNavigate(String toRoute, Map<String, dynamic>? arguments);
  String get name;
}

/// Authentication guard
class AuthenticationGuard implements NavigationGuard {
  final Future<bool> Function() isAuthenticated;

  AuthenticationGuard(this.isAuthenticated);

  @override
  String get name => 'AuthenticationGuard';

  @override
  Future<bool> canNavigate(String toRoute, Map<String, dynamic>? arguments) async {
    // Protected routes
    final protectedRoutes = [
      '/app',
      '/user',
    ];

    if (protectedRoutes.any((route) => toRoute.startsWith(route))) {
      final authenticated = await isAuthenticated();
      if (!authenticated) {
        if (kDebugMode) {
          debugPrint('$name: Access denied to $toRoute - Not authenticated');
        }
        return false;
      }
    }
    return true;
  }
}

/// Two-Factor Authentication guard
class TwoFactorAuthGuard implements NavigationGuard {
  final Future<bool> Function() is2FARequired;
  final Future<bool> Function() is2FACompleted;

  TwoFactorAuthGuard({
    required this.is2FARequired,
    required this.is2FACompleted,
  });

  @override
  String get name => 'TwoFactorAuthGuard';

  @override
  Future<bool> canNavigate(String toRoute, Map<String, dynamic>? arguments) async {
    // Check if 2FA is required for this route
    final needsApp = toRoute.startsWith('/app');
    
    if (needsApp) {
      final requires2FA = await is2FARequired();
      if (requires2FA) {
        final completed = await is2FACompleted();
        if (!completed) {
          if (kDebugMode) {
            debugPrint('$name: 2FA required but not completed for $toRoute');
          }
          return false;
        }
      }
    }
    return true;
  }
}

/// Improved navigation service with guards and analytics
class ImprovedNavigationService {
  static final ImprovedNavigationService _instance = ImprovedNavigationService._internal();

  factory ImprovedNavigationService() {
    return _instance;
  }

  ImprovedNavigationService._internal();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  final List<NavigationEvent> _navigationHistory = [];
  final List<NavigationGuard> _guards = [];
  final List<void Function(NavigationEvent)> _listeners = [];

  String _currentRoute = '/auth/login';

  /// Get current route
  String get currentRoute => _currentRoute;

  /// Get navigation history
  List<NavigationEvent> get history => List.unmodifiable(_navigationHistory);

  /// Get navigator state
  NavigatorState? get _navigator => navigatorKey.currentState;

  /// Initialize navigation service with guards
  void initialize({
    required AuthenticationGuard authGuard,
    required TwoFactorAuthGuard twoFactorGuard,
  }) {
    addGuard(authGuard);
    addGuard(twoFactorGuard);

    if (kDebugMode) {
      debugPrint('ImprovedNavigationService initialized with ${_guards.length} guards');
    }
  }

  /// Add a navigation guard
  void addGuard(NavigationGuard guard) {
    _guards.add(guard);
    if (kDebugMode) {
      debugPrint('Added guard: ${guard.name}');
    }
  }

  /// Add a navigation listener
  void addListener(void Function(NavigationEvent) listener) {
    _listeners.add(listener);
  }

  /// Remove a navigation listener
  void removeListener(void Function(NavigationEvent) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners(NavigationEvent event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error in navigation listener: $e');
        }
      }
    }
  }

  /// Push route with guards and checks
  Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
  }) async {
    if (!await _checkGuards(routeName, arguments as Map<String, dynamic>?)) {
      if (kDebugMode) {
        debugPrint('Navigation blocked: $routeName');
      }
      return null;
    }

    final previousRoute = _currentRoute;
    _currentRoute = routeName;

    _recordNavigation(
      fromRoute: previousRoute,
      toRoute: routeName,
      arguments: arguments as Map<String, dynamic>?,
      type: NavigationType.push,
    );

    return _navigator?.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Pop route
  void pop<T>([T? result]) {
    if (_navigationHistory.isNotEmpty) {
      final lastEvent = _navigationHistory.last;
      _currentRoute = lastEvent.fromRoute;
    }

    _recordNavigation(
      fromRoute: _currentRoute,
      toRoute: 'pop',
      type: NavigationType.pop,
    );

    _navigator?.pop(result);
  }

  /// Replace route
  Future<T?> replace<T>(
    String routeName, {
    Object? arguments,
  }) async {
    if (!await _checkGuards(routeName, arguments as Map<String, dynamic>?)) {
      return null;
    }

    final previousRoute = _currentRoute;
    _currentRoute = routeName;

    _recordNavigation(
      fromRoute: previousRoute,
      toRoute: routeName,
      arguments: arguments as Map<String, dynamic>?,
      type: NavigationType.replace,
    );

    return _navigator?.pushReplacementNamed<T, T>(routeName, arguments: arguments);
  }

  /// Replace all routes and navigate to home
  Future<void> replaceAll(String routeName, {Object? arguments}) async {
    if (!await _checkGuards(routeName, arguments as Map<String, dynamic>?)) {
      return;
    }

    final previousRoute = _currentRoute;
    _currentRoute = routeName;

    _recordNavigation(
      fromRoute: previousRoute,
      toRoute: routeName,
      arguments: arguments as Map<String, dynamic>?,
      type: NavigationType.replaceAll,
    );

    _navigator?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to home
  Future<void> goHome() async {
    await replaceAll(AppRoutesV2.appHome);
  }

  /// Navigate to login
  Future<void> goLogin() async {
    _navigationHistory.clear();
    await replaceAll(AppRoutesV2.authLogin);
  }

  /// Navigate to 2FA verification
  Future<void> go2FAVerification({
    required VerificationMethod method,
    String? phoneNumber,
    String? totpSecret,
    List<VerificationMethod>? availableMethods,
  }) async {
    await pushNamed(
      AppRoutesV2.auth2FAVerify,
      arguments: {
        'method': method,
        'phoneNumber': phoneNumber,
        'totpSecret': totpSecret,
        'availableMethods': availableMethods ?? [],
      },
    );
  }

  /// Check all guards before navigation
  Future<bool> _checkGuards(
    String routeName,
    Map<String, dynamic>? arguments,
  ) async {
    for (final guard in _guards) {
      final canNavigate = await guard.canNavigate(routeName, arguments);
      if (!canNavigate) {
        if (kDebugMode) {
          debugPrint('Guard ${guard.name} blocked navigation to $routeName');
        }
        return false;
      }
    }
    return true;
  }

  /// Record navigation event
  void _recordNavigation({
    required String fromRoute,
    required String toRoute,
    Map<String, dynamic>? arguments,
    NavigationType type = NavigationType.push,
  }) {
    final event = NavigationEvent(
      fromRoute: fromRoute,
      toRoute: toRoute,
      timestamp: DateTime.now(),
      arguments: arguments,
      type: type,
    );

    _navigationHistory.add(event);
    _notifyListeners(event);

    if (kDebugMode) {
      debugPrint('Navigation: $event');
    }
  }

  /// Get navigation stack
  List<String> getNavigationStack() {
    if (_navigationHistory.isEmpty) return [_currentRoute];

    final stack = <String>[
      _navigationHistory.first.fromRoute,
      ..._navigationHistory.map((e) => e.toRoute),
    ];

    return stack;
  }

  /// Clear history (for logout)
  void clearHistory() {
    _navigationHistory.clear();
    _currentRoute = '/auth/login';
  }

  /// Get navigation analytics
  NavigationAnalytics getAnalytics() {
    return NavigationAnalytics(
      totalNavigations: _navigationHistory.length,
      currentRoute: _currentRoute,
      history: _navigationHistory,
      mostFrequentRoute: _getMostFrequentRoute(),
      averageTimePerRoute: _getAverageTimePerRoute(),
    );
  }

  String? _getMostFrequentRoute() {
    if (_navigationHistory.isEmpty) return null;

    final routeCounts = <String, int>{};
    for (final event in _navigationHistory) {
      routeCounts[event.toRoute] = (routeCounts[event.toRoute] ?? 0) + 1;
    }

    var maxCount = 0;
    String? mostFrequent;
    routeCounts.forEach((route, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = route;
      }
    });

    return mostFrequent;
  }

  Duration _getAverageTimePerRoute() {
    if (_navigationHistory.length < 2) return Duration.zero;

    final timeDifferences = <int>[];
    for (int i = 1; i < _navigationHistory.length; i++) {
      final diff = _navigationHistory[i].timestamp
          .difference(_navigationHistory[i - 1].timestamp)
          .inMilliseconds;
      timeDifferences.add(diff);
    }

    final average = timeDifferences.isEmpty
        ? 0
        : timeDifferences.reduce((a, b) => a + b) ~/ timeDifferences.length;

    return Duration(milliseconds: average);
  }
}

/// Navigation analytics data
class NavigationAnalytics {
  final int totalNavigations;
  final String currentRoute;
  final List<NavigationEvent> history;
  final String? mostFrequentRoute;
  final Duration averageTimePerRoute;

  NavigationAnalytics({
    required this.totalNavigations,
    required this.currentRoute,
    required this.history,
    this.mostFrequentRoute,
    required this.averageTimePerRoute,
  });

  @override
  String toString() => '''
NavigationAnalytics(
  total: $totalNavigations,
  current: $currentRoute,
  mostFrequent: $mostFrequentRoute,
  avgTime: ${averageTimePerRoute.inMilliseconds}ms
)
''';
}
