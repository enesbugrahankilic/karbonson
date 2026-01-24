// lib/core/navigation/simplified_app_router.dart
// 🚀 Simplified Router - Clean Route Definitions

import 'package:flutter/material.dart';
import '../../pages/login_page.dart';
import '../../pages/welcome_page.dart';
import '../../pages/register_page.dart';
import '../../pages/register_page_refactored.dart';
import '../../pages/home_dashboard.dart';
import '../../pages/settings_page.dart';
import '../../pages/how_to_play_page.dart';
import '../../pages/forgot_password_page.dart';
import '../../pages/forgot_password_page_enhanced.dart';
import '../../pages/quiz_page.dart';
import '../../pages/quiz_settings_page.dart';
import '../../pages/quiz_results_page.dart';
import '../../pages/duel_page.dart';
import '../../pages/duel_invitation_page.dart';
import '../../pages/board_game_page.dart';
import '../../pages/multiplayer_lobby_page.dart';
import '../../pages/spectator_mode_page.dart';
import '../../pages/leaderboard_page.dart';
import '../../pages/achievement_page.dart';
import '../../pages/achievements_gallery_page.dart';
import '../../pages/rewards_shop_page.dart';
import '../../pages/rewards_main_page.dart';
import '../../pages/daily_challenge_page.dart';
import '../../pages/ai_recommendations_page.dart';
import '../../pages/carbon_footprint_page.dart';
import '../../pages/notifications_page.dart';
import '../../pages/won_boxes_page.dart';
import '../../pages/friends_page.dart';
import '../../pages/profile_page.dart';
import '../../services/authentication_state_service.dart';
import '../../enums/app_language.dart';
import '../../models/question.dart';

/// 🚀 Simplified Route Constants
class AppRoutes {
  AppRoutes._();

  // AUTH ROUTES
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerRefactored = '/register-refactored';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordEnhanced = '/forgot-password-enhanced';

  // MAIN APP ROUTES (5 TAB SYSTEM)
  static const String home = '/home';
  static const String gameModes = '/game-modes';
  static const String social = '/social';
  static const String friends = '/friends';
  static const String profile = '/profile';

  // SUB ROUTES
  static const String settings = '/settings';
  static const String howToPlay = '/how-to-play';
  
  // GAME SUB-ROUTES
  static const String quiz = '/game/quiz';
  static const String quizSettings = '/game/quiz-settings';
  static const String quizResults = '/game/quiz-results';
  static const String duel = '/game/duel';
  static const String duelInvite = '/game/duel/invite';
  static const String boardGame = '/game/board';
  static const String multiplayerLobby = '/game/multiplayer';
  static const String spectatorMode = '/game/spectator';

  // SOCIAL SUB-ROUTES
  static const String leaderboard = '/social/leaderboard';
  static const String achievements = '/social/achievements';
  static const String achievementsGallery = '/social/achievements-gallery';
  static const String rewards = '/social/rewards';
  static const String rewardsShop = '/social/rewards-shop';
  static const String dailyChallenges = '/social/daily-challenges';

  // PROFILE SUB-ROUTES
  static const String aiRecommendations = '/profile/ai-recommendations';
  static const String carbonFootprint = '/profile/carbon-footprint';
  static const String notifications = '/profile/notifications';
  static const String wonBoxes = '/profile/won-boxes';
}

/// 🚀 Simplified App Router
class SimplifiedAppRouter {
  static final AuthenticationStateService _authService = AuthenticationStateService();

  static PageRoute<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? AppRoutes.home;
    final Object? arguments = settings.arguments;

    switch (routeName) {
      // AUTH ROUTES
      case AppRoutes.splash:
      case AppRoutes.welcome:
        return _createRoute(WelcomePage());

      case AppRoutes.login:
        return _createRoute(LoginPage());

      case AppRoutes.register:
        return _createRoute(RegisterPage());

      case AppRoutes.registerRefactored:
        return _createRoute(RegisterPageRefactored());

      case AppRoutes.forgotPassword:
        return _createRoute(ForgotPasswordPage());

      case AppRoutes.forgotPasswordEnhanced:
        return _createRoute(ForgotPasswordPageEnhanced());

      // MAIN APP ROUTES
      case AppRoutes.home:
        return _createProtectedRoute(HomeDashboard(), settings);

      case AppRoutes.gameModes:
        return _createRoute(QuizPage());

      case AppRoutes.social:
        return _createRoute(LeaderboardPage());

      case AppRoutes.friends:
        return _createProtectedRoute(FriendsPage(userNickname: ''), settings);

      case AppRoutes.profile:
        return _createProtectedRoute(ProfilePage(), settings);

      // SUB ROUTES
      case AppRoutes.settings:
        return _createProtectedRoute(SettingsPage(), settings);

      case AppRoutes.howToPlay:
        return _createRoute(HowToPlayPage());

      // GAME SUB-ROUTES
      case AppRoutes.quiz:
        return _createRoute(QuizPage());

      case AppRoutes.quizSettings:
        return _createRoute(QuizSettingsPage(
          onStartQuiz: _onQuizStart,
        ));

      case AppRoutes.quizResults:
        return _createRoute(_buildQuizResults(arguments));

      case AppRoutes.duel:
        return _createRoute(DuelPage());

      case AppRoutes.duelInvite:
        return _createRoute(DuelInvitationPage());

      case AppRoutes.boardGame:
        return _createRoute(BoardGamePage(userNickname: 'Player'));

      case AppRoutes.multiplayerLobby:
        return _createRoute(MultiplayerLobbyPage(userNickname: 'Player'));

      case AppRoutes.spectatorMode:
        return _createRoute(SpectatorModePage());

      // SOCIAL SUB-ROUTES
      case AppRoutes.leaderboard:
        return _createRoute(LeaderboardPage());

      case AppRoutes.achievements:
        return _createRoute(AchievementPage());

      case AppRoutes.achievementsGallery:
        return _createRoute(AchievementsGalleryPage());

      case AppRoutes.rewards:
        return _createRoute(RewardsMainPage());

      case AppRoutes.rewardsShop:
        return _createRoute(RewardsShopPage());

      case AppRoutes.dailyChallenges:
        return _createRoute(DailyChallengePage());

      // PROFILE SUB-ROUTES
      case AppRoutes.aiRecommendations:
        return _createProtectedRoute(AIRecommendationsPage(), settings);

      case AppRoutes.carbonFootprint:
        return _createProtectedRoute(CarbonFootprintPage(), settings);

      case AppRoutes.notifications:
        return _createProtectedRoute(NotificationsPage(), settings);

      case AppRoutes.wonBoxes:
        return _createProtectedRoute(WonBoxesPage(), settings);

      default:
        return _createRoute(WelcomePage());
    }
  }

  static void _onQuizStart({
    required String category,
    required DifficultyLevel difficulty,
    required int questionCount,
    required AppLanguage language,
  }) {}

  static QuizResultsPage _buildQuizResults(Object? arguments) {
    if (arguments is Map<String, dynamic>) {
      return QuizResultsPage(
        score: arguments['score'] ?? 0,
        totalQuestions: arguments['totalQuestions'] ?? 15,
        category: arguments['category'] ?? 'Tümü',
        difficulty: arguments['difficulty'] ?? 'Orta',
        correctAnswers: arguments['correctAnswers'] ?? 0,
      );
    }
    return QuizResultsPage(
      score: 0,
      totalQuestions: 15,
      category: 'Tümü',
      difficulty: 'Orta',
      correctAnswers: 0,
    );
  }

  static PageRoute<T> _createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
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

  static PageRoute<T> _createProtectedRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
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
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
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
}

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
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.fallbackRoute,
          (route) => false,
          arguments: widget.fallbackArguments,
        );
      }
    } catch (e) {
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
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Kimlik doğrulanıyor...'),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? widget.child : const SizedBox.shrink();
  }
}
