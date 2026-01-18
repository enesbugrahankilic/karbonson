// lib/core/navigation/app_router.dart
// Modern Flutter navigation system with named routes, guards, and deep linking

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../../services/comprehensive_2fa_service.dart';
import '../../pages/login_page.dart';
import '../../pages/tutorial_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/board_game_page.dart';
import '../../pages/quiz_page.dart';
import '../../pages/leaderboard_page.dart';
import '../../pages/friends_page.dart';
import '../../pages/multiplayer_lobby_page.dart';
import '../../pages/duel_page.dart';
import '../../pages/duel_invitation_page.dart';
import '../../pages/room_management_page.dart';
import '../../pages/settings_page.dart';
import '../../pages/home_dashboard.dart';
import '../../pages/register_page.dart';
import '../../pages/register_page_refactored.dart';
import '../../pages/email_verification_page.dart';
import '../../pages/forgot_password_page.dart';
import '../../pages/forgot_password_page_enhanced.dart';
import '../../pages/two_factor_auth_setup_page.dart';
import '../../pages/two_factor_auth_verification_page.dart';
import '../../pages/enhanced_two_factor_auth_setup_page.dart';
import '../../pages/enhanced_two_factor_auth_verification_page.dart';
import '../../pages/comprehensive_two_factor_auth_setup_page.dart';
import '../../pages/comprehensive_2fa_verification_page.dart';
import '../../pages/ai_recommendations_page.dart';
import '../../pages/achievement_page.dart';
import '../../pages/achievements_gallery_page.dart';
import '../../pages/daily_challenge_page.dart';
import '../../pages/email_otp_verification_page.dart';
import '../../pages/email_verification_redirect_page.dart';
import '../../pages/how_to_play_page.dart';
import '../../pages/rewards_shop_page.dart';
import '../../pages/two_factor_auth_page.dart';
import '../../services/authentication_state_service.dart';
import '../../services/quiz_logic.dart';

/// Route names constants for better maintainability
class AppRoutes {
  const AppRoutes._(); // Private constructor to prevent instantiation

  // Authentication routes
  static const String login = '/login';
  static const String tutorial = '/tutorial';
  static const String register = '/register';
  static const String registerRefactored = '/register-refactored';
  static const String emailVerification = '/email-verification';
  static const String emailOtpVerification = '/email-otp-verification';
  static const String emailVerificationRedirect = '/email-verification-redirect';
  static const String enhancedEmailVerificationRedirect = '/enhanced-email-verification-redirect';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordEnhanced = '/forgot-password-enhanced';
  static const String spamSafePasswordReset = '/spam-safe-password-reset';
  static const String passwordResetInformation = '/password-reset-information';
  static const String passwordChange = '/password-change';
  static const String newPassword = '/new-password';

  // 2FA routes
  static const String twoFactorAuthSetup = '/2fa-setup';
  static const String twoFactorAuthVerification = '/2fa-verification';
  static const String twoFactorAuthPage = '/2fa-page';
  static const String enhanced2FASetup = '/enhanced-2fa-setup';
  static const String enhanced2FAVerification = '/enhanced-2fa-verification';
  static const String comprehensive2FASetup = '/comprehensive-2fa-setup';
  static const String comprehensive2FAVerification = '/comprehensive-2fa-verification';

  // Main app routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String boardGame = '/board-game';
  static const String quiz = '/quiz';
  static const String leaderboard = '/leaderboard';
  static const String friends = '/friends';
  static const String multiplayerLobby = '/multiplayer-lobby';
  static const String duel = '/duel';
  static const String duelInvitation = '/duel-invitation';
  static const String roomManagement = '/room-management';
  static const String settings = '/settings';
  static const String aiRecommendations = '/ai-recommendations';
  static const String achievement = '/achievement';
  static const String achievementsGallery = '/achievements-gallery';
  static const String dailyChallenge = '/daily-challenge';
  static const String rewardsShop = '/rewards-shop';
  static const String howToPlay = '/how-to-play';
  static const String tutorialPage = '/tutorial-page';

  // Debug routes (only in debug mode)
  static const String uidDebug = '/uid-debug';
}

/// Navigation configuration with route definitions
class AppRouter {
  const AppRouter._(); // Private constructor to prevent instantiation

  static final AuthenticationStateService _authService = AuthenticationStateService();

  /// Generate routes for the app
  static PageRoute<dynamic> generateRoute(RouteSettings settings) {
    if (kDebugMode) {
      debugPrint('Navigating to: ${settings.name}');
    }

    switch (settings.name) {
      // Authentication routes
      case AppRoutes.login:
        return _createRoute(const LoginPage());
      case AppRoutes.tutorial:
        return _createRoute(const TutorialPage());
      case AppRoutes.register:
        return _createRoute(const RegisterPage());
      case AppRoutes.registerRefactored:
        return _createRoute(const RegisterPageRefactored());
      case AppRoutes.emailVerification:
        return _createRoute(const EmailVerificationPage());
      case AppRoutes.forgotPassword:
        return _createRoute(const ForgotPasswordPage());
      case AppRoutes.forgotPasswordEnhanced:
        return _createRoute(const ForgotPasswordPageEnhanced());

      // 2FA routes
      case AppRoutes.twoFactorAuthSetup:
        return _createRoute(const TwoFactorAuthSetupPage());
      case AppRoutes.twoFactorAuthVerification:
        // For 2FA verification, we need to provide a default auth result for development
        // In production, this should come from the login flow
        final authResult = settings.arguments ?? _createDefaultAuthResult();
        return _createRoute(
            TwoFactorAuthVerificationPage(authResult: authResult));
      case AppRoutes.enhanced2FASetup:
        return _createRoute(const EnhancedTwoFactorAuthSetupPage());
      case AppRoutes.enhanced2FAVerification:
        final authResult = settings.arguments ?? _createDefaultAuthResult();
        return _createRoute(
            EnhancedTwoFactorAuthVerificationPage(authResult: authResult));
      case AppRoutes.comprehensive2FASetup:
        return _createRoute(const ComprehensiveTwoFactorAuthSetupPage());
      case AppRoutes.comprehensive2FAVerification:
        final arguments = settings.arguments as Map<String, dynamic>? ?? {};
        return _createRoute(Comprehensive2FAVerificationPage(
          initialMethod: arguments['initialMethod'] ?? VerificationMethod.sms,
          availableMethods: arguments['availableMethods'] ??
              [VerificationMethod.sms, VerificationMethod.backupCode],
        ));

      // Main app routes
      case AppRoutes.home:
        return _createProtectedRoute(const HomeDashboard(), settings);
      case AppRoutes.profile:
        return _createProtectedRoute(const ProfilePage(), settings);
      case AppRoutes.boardGame:
        return _createRoute(BoardGamePage(
          userNickname: settings.arguments is String
              ? settings.arguments as String
              : 'Player',
        ));
      case AppRoutes.quiz:
        return _createRoute(QuizPage(
          quizLogic: QuizLogic(),
        ));
      case AppRoutes.leaderboard:
        return _createRoute(const LeaderboardPage());
      case AppRoutes.friends:
        return _createRoute(FriendsPage(
          userNickname: settings.arguments is String
              ? settings.arguments as String
              : 'Player',
        ));
      case AppRoutes.multiplayerLobby:
        return _createRoute(MultiplayerLobbyPage(
          userNickname: settings.arguments is String
              ? settings.arguments as String
              : 'Player',
        ));
      case AppRoutes.duel:
        return _createRoute(const DuelPage());
      case AppRoutes.duelInvitation:
        return _createRoute(const DuelInvitationPage());
      case AppRoutes.roomManagement:
        final userNickname = settings.arguments is String
            ? settings.arguments as String
            : 'Player';
        return _createRoute(RoomManagementPage(userNickname: userNickname));
      case AppRoutes.settings:
        return _createRoute(const SettingsPage());
      case AppRoutes.aiRecommendations:
        return _createRoute(const AIRecommendationsPage());
      case AppRoutes.achievement:
        return _createRoute(const AchievementPage());
      case AppRoutes.dailyChallenge:
        return _createRoute(const DailyChallengePage());

      // Extended app routes
      case AppRoutes.achievementsGallery:
        return _createRoute(const AchievementsGalleryPage());
      case AppRoutes.rewardsShop:
        return _createRoute(const RewardsShopPage());
      case AppRoutes.howToPlay:
        return _createRoute(const HowToPlayPage());
      case AppRoutes.emailOtpVerification:
        return _createRoute(EmailOtpVerificationPage(
          email: settings.arguments is String ? settings.arguments as String : '',
          verificationId: '',
          onVerify: (otp) {},
        ));
      case AppRoutes.emailVerificationRedirect:
        return _createRoute(const EmailVerificationRedirectPage());
      case AppRoutes.enhancedEmailVerificationRedirect:
        return _createRoute(const EmailVerificationRedirectPage());
      case AppRoutes.spamSafePasswordReset:
        return _createRoute(const ForgotPasswordPageEnhanced());
      case AppRoutes.passwordResetInformation:
        return _createRoute(const EmailVerificationPage());
      case AppRoutes.passwordChange:
        return _createRoute(const ForgotPasswordPage());
      case AppRoutes.newPassword:
        return _createRoute(const ForgotPasswordPage());
      case AppRoutes.twoFactorAuthPage:
        return _createRoute(TwoFactorAuthPage(
          userId: settings.arguments is String ? settings.arguments as String : '',
        ));
      case AppRoutes.tutorialPage:
        return _createRoute(const TutorialPage());

      // Debug routes (only in debug mode)
      case AppRoutes.uidDebug:
        if (kDebugMode) {
          return _createRoute(const LoginPage());
        }
        return _createRoute(const LoginPage());

      default:
        // Default route
        return _createRoute(const LoginPage());
    }
  }

  /// Create a standard route with modern transitions
  static PageRoute<T> _createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Create a protected route that requires authentication
  static PageRoute<T> _createProtectedRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          _ProtectedRouteWrapper(
        authService: _authService,
        fallbackRoute: AppRoutes.login,
        fallbackArguments: {'redirectTo': settings.name},
        child: page,
      ),
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Create default auth result for 2FA pages (development only)
  static dynamic _createDefaultAuthResult() {
    // This is a placeholder for development - in production this should come from auth flow
    return {
      'requires2FA': false,
      'phoneProvider': null,
      'multiFactorResolver': null,
      'isMock': true,
    };
  }
}

/// Wrapper widget for protected routes that handles authentication checks
class _ProtectedRouteWrapper extends StatefulWidget {
  final Widget child;
  final AuthenticationStateService authService;
  final String fallbackRoute;
  final Map<String, dynamic>? fallbackArguments;

  const _ProtectedRouteWrapper({
    required this.authService,
    required this.fallbackRoute,
    required this.child,
    this.fallbackArguments,
  });

  @override
  State<_ProtectedRouteWrapper> createState() => _ProtectedRouteWrapperState();
}

class _ProtectedRouteWrapperState extends State<_ProtectedRouteWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final isAuth = await widget.authService.isCurrentUserAuthenticated();
      setState(() {
        _isAuthenticated = isAuth;
        _isLoading = false;
      });

      if (!isAuth && mounted) {
        // Navigate to login with fallback info
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.fallbackRoute,
          (route) => false,
          arguments: widget.fallbackArguments,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Authentication check failed: $e');
      }
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.fallbackRoute,
          (route) => false,
          arguments: widget.fallbackArguments,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Authenticating...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? widget.child : const SizedBox.shrink();
  }
}
