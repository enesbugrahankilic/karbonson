// lib/core/navigation/deep_link_service.dart
// Enhanced deep linking service for handling external navigation requests

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'app_router.dart';

/// Deep link handler for external navigation requests
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final Map<String, Function> _handlers = {};
  final Set<DeepLinkListener> _listeners = {};

  /// Register a deep link handler
  void registerHandler(String pattern, Function(Map<String, String> params) handler) {
    _handlers[pattern] = handler;
    if (kDebugMode) {
      debugPrint('Registered deep link handler for pattern: $pattern');
    }
  }

  /// Remove a deep link handler
  void unregisterHandler(String pattern) {
    _handlers.remove(pattern);
  }

  /// Register a deep link listener
  void addListener(DeepLinkListener listener) {
    _listeners.add(listener);
  }

  /// Remove a deep link listener
  void removeListener(DeepLinkListener listener) {
    _listeners.remove(listener);
  }

  /// Handle a deep link
  Future<bool> handleDeepLink(String url, BuildContext context) async {
    if (kDebugMode) {
      debugPrint('Handling deep link: $url');
    }

    try {
      final uri = Uri.parse(url);
      final routeName = _extractRouteName(uri);
      
      if (routeName == null) {
        if (kDebugMode) {
          debugPrint('Could not extract route name from URL: $url');
        }
        return false;
      }

      // Notify listeners
      for (final listener in _listeners) {
        listener.onDeepLinkReceived(url, routeName, uri.queryParameters);
      }

      // Handle built-in routes
      if (_handleBuiltInRoute(routeName, uri.queryParameters, context)) {
        return true;
      }

      // Handle custom handlers
      for (final entry in _handlers.entries) {
        if (_matchesPattern(routeName, entry.key)) {
          entry.value(uri.queryParameters);
          return true;
        }
      }

      if (kDebugMode) {
        debugPrint('No handler found for route: $routeName');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error handling deep link: $e');
      }
      return false;
    }
  }

  /// Extract route name from URI
  String? _extractRouteName(Uri uri) {
    // Remove leading slash and extract route
    final path = uri.path.substring(1);
    if (path.isEmpty) return null;

    // Split path and take first segment as route name
    final segments = path.split('/');
    return segments.first;
  }

  /// Handle built-in application routes
  bool _handleBuiltInRoute(
    String routeName, 
    Map<String, String> params, 
    BuildContext context
  ) {
    switch (routeName) {
      case 'login':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
        return true;

      case 'profile':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.profile,
          (route) => false,
          arguments: params['userId'],
        );
        return true;

      case 'quiz':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.quiz,
          (route) => false,
          arguments: params['category'] ?? 'general',
        );
        return true;

      case 'leaderboard':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.leaderboard,
          (route) => false,
        );
        return true;

      case 'friends':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.friends,
          (route) => false,
          arguments: params['userId'],
        );
        return true;

      case 'duel':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.duel,
          (route) => false,
          arguments: {
            'opponentId': params['opponentId'],
            'inviteId': params['inviteId'],
          },
        );
        return true;

      case 'room':
        final roomId = params['roomId'];
        if (roomId != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.multiplayerLobby,
            (route) => false,
            arguments: roomId,
          );
          return true;
        }
        break;

      case 'settings':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.settings,
          (route) => false,
        );
        return true;

      // 2FA routes
      case '2fa-setup':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.comprehensive2FASetup,
          (route) => false,
        );
        return true;

      case '2fa-verify':
        final method = params['method'] ?? 'sms';
        final methods = (params['availableMethods'] ?? 'sms,backupCode')
            .split(',')
            .map((m) => m.trim())
            .toList();
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.comprehensive2FAVerification,
          (route) => false,
          arguments: {
            'initialMethod': method,
            'availableMethods': methods,
          },
        );
        return true;

      case 'email-verify':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.emailVerification,
          (route) => false,
        );
        return true;

      case 'forgot-password':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.forgotPasswordEnhanced,
          (route) => false,
        );
        return true;

      // Authentication flow routes
      case 'reset-password':
        final token = params['token'];
        if (token != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.forgotPasswordEnhanced,
            (route) => false,
            arguments: {'resetToken': token},
          );
          return true;
        }
        break;

      case 'verify-email':
        final token = params['token'];
        if (token != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.emailVerification,
            (route) => false,
            arguments: {'verificationToken': token},
          );
          return true;
        }
        break;

      case 'register':
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.register,
          (route) => false,
        );
        return true;

      default:
        return false;
    }
    return false;
  }

  /// Check if route name matches pattern
  bool _matchesPattern(String routeName, String pattern) {
    // Simple pattern matching - can be enhanced with regex
    return routeName == pattern || routeName.startsWith(pattern);
  }

  /// Generate a deep link URL for a route
  String generateDeepLink(String routeName, [Map<String, String>? parameters]) {
    final baseUrl = 'https://eco-game.app'; // Replace with actual app URL
    final queryString = parameters?.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&') ?? '';
    
    return queryString.isEmpty 
        ? '$baseUrl/$routeName'
        : '$baseUrl/$routeName?$queryString';
  }

  /// Get all registered patterns
  List<String> getRegisteredPatterns() => _handlers.keys.toList();

  /// Clear all handlers
  void clearHandlers() {
    _handlers.clear();
  }
}

/// Deep link listener interface
abstract class DeepLinkListener {
  void onDeepLinkReceived(String url, String routeName, Map<String, String> parameters);
}

/// Predefined deep link patterns
class DeepLinkPatterns {
  // Authentication
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String verifyEmail = 'verify-email';
  static const String emailVerification = 'email-verify';

  // 2FA
  static const String twoFactorAuthSetup = '2fa-setup';
  static const String twoFactorAuthVerify = '2fa-verify';

  // Game features
  static const String profile = 'profile';
  static const String quiz = 'quiz';
  static const String leaderboard = 'leaderboard';
  static const String friends = 'friends';
  static const String duel = 'duel';
  static const String room = 'room';
  static const String multiplayer = 'multiplayer';

  // Settings
  static const String settings = 'settings';
  static const String tutorial = 'tutorial';
}

/// Deep link utility class with common deep links
class DeepLinkUtils {
  /// Generate profile deep link
  static String profile(String userId) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.profile, {
      'userId': userId,
    });
  }

  /// Generate quiz deep link
  static String quiz([String category = 'general']) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.quiz, {
      'category': category,
    });
  }

  /// Generate duel invitation deep link
  static String duelInvitation(String opponentId, String inviteId) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.duel, {
      'opponentId': opponentId,
      'inviteId': inviteId,
    });
  }

  /// Generate room deep link
  static String room(String roomId) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.room, {
      'roomId': roomId,
    });
  }

  /// Generate friends deep link
  static String friends([String? userId]) {
    final params = userId != null ? {'userId': userId} : null;
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.friends, params);
  }

  /// Generate 2FA setup deep link
  static String twoFactorAuthSetup() {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.twoFactorAuthSetup);
  }

  /// Generate 2FA verification deep link
  static String twoFactorAuthVerify(String method, [List<String>? availableMethods]) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.twoFactorAuthVerify, {
      'method': method,
      'availableMethods': availableMethods?.join(',') ?? 'sms,backupCode',
    });
  }

  /// Generate password reset deep link
  static String passwordReset(String token) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.resetPassword, {
      'token': token,
    });
  }

  /// Generate email verification deep link
  static String emailVerification(String token) {
    return DeepLinkService().generateDeepLink(DeepLinkPatterns.verifyEmail, {
      'token': token,
    });
  }
}