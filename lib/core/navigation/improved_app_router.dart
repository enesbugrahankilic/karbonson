// lib/core/navigation/improved_app_router.dart
// Modern Flutter navigation system with organized routes and guards

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../../pages/login_page.dart';
import '../../pages/tutorial_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/board_game_page.dart';
import '../../pages/quiz_page.dart';
import '../../pages/friends_page.dart';
import '../../pages/duel_page.dart';
import '../../pages/duel_invitation_page.dart';
import '../../pages/settings_page.dart';
import '../../pages/home_dashboard.dart';
import '../../pages/register_page.dart';
import '../../pages/register_page_refactored.dart';
import '../../pages/email_verification_page.dart';
import '../../pages/forgot_password_page.dart';
import '../../pages/two_factor_auth_setup_page.dart';
import '../../pages/comprehensive_2fa_verification_page.dart';
import '../../pages/ai_recommendations_page.dart';
import '../../pages/achievement_page.dart';
import '../../pages/daily_challenge_page.dart';
import '../../services/authentication_state_service.dart';
import '../../services/quiz_logic.dart';
import '../../services/comprehensive_2fa_service.dart';

/// Improved route names with categorization
class AppRoutesV2 {
  const AppRoutesV2._();

  // Auth routes
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authEmailVerify = '/auth/email-verify';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String auth2FASetup = '/auth/2fa-setup';
  static const String auth2FAVerify = '/auth/2fa-verify';
  static const String authTutorial = '/auth/tutorial';

  // App routes
  static const String appHome = '/app/home';
  static const String appQuiz = '/app/quiz';
  static const String appDailyChallenge = '/app/daily-challenge';
  static const String appAIRecommendations = '/app/ai-recommendations';
  static const String appBoardGame = '/app/board-game';
  static const String appDuel = '/app/duel';
  static const String appDuelInvite = '/app/duel-invite';
  static const String appFriends = '/app/friends';
  static const String appLeaderboard = '/app/leaderboard';
  static const String appMultiplayerLobby = '/app/multiplayer-lobby';
  static const String appRoomManagement = '/app/room-management';

  // User routes
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  static const String userAchievements = '/user/achievements';

  // Legacy routes (mapping to new ones)
  static const String home = appHome;
  static const String login = authLogin;
  static const String register = authRegister;
  static const String quiz = appQuiz;
  static const String profile = userProfile;
  static const String settings = userSettings;
}

/// Improved App Router with better organization
class ImprovedAppRouter {
  const ImprovedAppRouter._();

  static late final AuthenticationStateService _authService;

  /// Initialize the router
  static void initialize() {
    _authService = AuthenticationStateService();
  }

  /// Generate routes for the app
  static PageRoute<dynamic> generateRoute(RouteSettings settings) {
    if (kDebugMode) {
      debugPrint('ImprovedAppRouter: Navigating to ${settings.name}');
    }

    try {
      return _buildRoute(settings);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImprovedAppRouter Error: $e');
      }
      return _createRoute(
        _buildErrorPage('Rota Bulunamadı', 'İstenen sayfa bulunamadı: ${settings.name}'),
      );
    }
  }

  static PageRoute<dynamic> _buildRoute(RouteSettings settings) {
    // Auth routes
    if (settings.name?.startsWith('/auth/') ?? false) {
      return _handleAuthRoute(settings);
    }

    // App routes
    if (settings.name?.startsWith('/app/') ?? false) {
      return _handleAppRoute(settings);
    }

    // User routes
    if (settings.name?.startsWith('/user/') ?? false) {
      return _handleUserRoute(settings);
    }

    // Legacy routes
    return _handleLegacyRoute(settings);
  }

  /// Handle authentication routes
  static PageRoute<dynamic> _handleAuthRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutesV2.authLogin => _createRoute(const LoginPage()),
      AppRoutesV2.authRegister => _createRoute(const RegisterPageRefactored()),
      AppRoutesV2.authEmailVerify => _createRoute(const EmailVerificationPage()),
      AppRoutesV2.authForgotPassword => _createRoute(const ForgotPasswordPage()),
      AppRoutesV2.auth2FASetup => _createRoute(const TwoFactorAuthSetupPage()),
      AppRoutesV2.auth2FAVerify => _buildComprehensive2FAVerification(settings),
      AppRoutesV2.authTutorial => _createRoute(const TutorialPage()),
      _ => _createRoute(_buildErrorPage('Bilinmeyen Auth Sayfası', '')),
    };
  }

  /// Handle main app routes
  static PageRoute<dynamic> _handleAppRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutesV2.appHome => _createRoute(const HomeDashboard()),
      AppRoutesV2.appQuiz => _createRoute(QuizPage(quizLogic: QuizLogic())),
      AppRoutesV2.appDailyChallenge => _createRoute(const DailyChallengePage()),
      AppRoutesV2.appAIRecommendations => _createRoute(const AIRecommendationsPage()),
      AppRoutesV2.appBoardGame => _createRoute(const BoardGamePage()),
      AppRoutesV2.appDuel => _createRoute(const DuelPage()),
      AppRoutesV2.appDuelInvite => _createRoute(const DuelInvitationPage()),
      AppRoutesV2.appFriends => _createRoute(FriendsPage(userNickname: settings.arguments as String? ?? 'User')),
      AppRoutesV2.appMultiplayerLobby => _createRoute(const SizedBox()),
      AppRoutesV2.appRoomManagement => _createRoute(const SizedBox()),
      _ => _createRoute(_buildErrorPage('Bilinmeyen App Sayfası', '')),
    };
  }

  /// Handle user routes
  static PageRoute<dynamic> _handleUserRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutesV2.userProfile => _createRoute(const ProfilePage()),
      AppRoutesV2.userSettings => _createRoute(const SettingsPage()),
      AppRoutesV2.userAchievements => _createRoute(const AchievementPage()),
      _ => _createRoute(_buildErrorPage('Bilinmeyen Kullanıcı Sayfası', '')),
    };
  }

  /// Handle legacy routes (backward compatibility)
  static PageRoute<dynamic> _handleLegacyRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRoutesV2.home => _createRoute(const HomeDashboard()),
      AppRoutesV2.login => _createRoute(const LoginPage()),
      AppRoutesV2.register => _createRoute(const RegisterPageRefactored()),
      AppRoutesV2.quiz => _createRoute(QuizPage(quizLogic: QuizLogic())),
      AppRoutesV2.profile => _createRoute(const ProfilePage()),
      AppRoutesV2.settings => _createRoute(const SettingsPage()),
      _ => _createRoute(_buildErrorPage('Sayfa Bulunamadı', 'İstenen rota tanımlanmamış')),
    };
  }

  /// Build comprehensive 2FA verification page with arguments
  static PageRoute<dynamic> _buildComprehensive2FAVerification(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    return _createRoute(
      Comprehensive2FAVerificationPage(
        initialMethod: args?['method'] ?? VerificationMethod.sms,
        phoneNumber: args?['phoneNumber'],
        totpSecret: args?['totpSecret'],
        availableMethods: args?['availableMethods'] ?? const [],
        onVerificationSuccess: args?['onSuccess'],
        onCancel: args?['onCancel'],
      ),
    );
  }

  /// Build error page widget
  static Widget _buildErrorPage(String title, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hata')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(message, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  /// Create a standard page route with fade transition
  static PageRoute<T> _createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated;
  }

}

/// Extension for easy navigation
extension NavigationExtension on NavigatorState {
  /// Navigate to auth route
  void toAuthRoute(String routeName, {Object? arguments}) {
    pushNamed('/auth/$routeName', arguments: arguments);
  }

  /// Navigate to app route
  void toAppRoute(String routeName, {Object? arguments}) {
    pushNamed('/app/$routeName', arguments: arguments);
  }

  /// Navigate to user route
  void toUserRoute(String routeName, {Object? arguments}) {
    pushNamed('/user/$routeName', arguments: arguments);
  }

  /// Navigate to home (with clearance)
  void toHome() {
    pushNamedAndRemoveUntil(AppRoutesV2.appHome, (route) => false);
  }

  /// Navigate to login (with clearance)
  void toLogin() {
    pushNamedAndRemoveUntil(AppRoutesV2.authLogin, (route) => false);
  }
}
