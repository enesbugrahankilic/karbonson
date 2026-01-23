// lib/core/navigation/app_router_complete.dart
// Comprehensive Flutter Navigation System - All Existing Pages Included

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../../services/authentication_state_service.dart';
import '../../services/comprehensive_2fa_service.dart';

// Authentication Pages
import '../../pages/login_page.dart';
import '../../pages/register_page.dart';
import '../../pages/register_page_refactored.dart';
import '../../pages/tutorial_page.dart';
import '../../pages/forgot_password_page.dart';
import '../../pages/forgot_password_page_enhanced.dart';
import '../../pages/email_verification_page.dart';
import '../../pages/email_verification_redirect_page.dart';

// 2FA Pages
import '../../pages/two_factor_auth_page.dart';
import '../../pages/two_factor_auth_setup_page.dart';
import '../../pages/two_factor_auth_verification_page.dart';
import '../../pages/enhanced_two_factor_auth_setup_page.dart';
import '../../pages/enhanced_two_factor_auth_verification_page.dart';
import '../../pages/comprehensive_two_factor_auth_setup_page.dart';
import '../../pages/comprehensive_2fa_verification_page.dart';

// Main App Pages
import '../../pages/home_dashboard.dart';
import '../../pages/quiz_page.dart';
import '../../pages/board_game_page.dart';
import '../../pages/duel_page.dart';
import '../../pages/duel_invitation_page.dart';
import '../../pages/multiplayer_lobby_page.dart';
import '../../pages/room_management_page.dart';
import '../../pages/friends_page.dart';
import '../../pages/leaderboard_page.dart';
import '../../pages/daily_challenge_page.dart';
import '../../pages/achievement_page.dart';
import '../../pages/achievements_gallery_page.dart';
import '../../pages/ai_recommendations_page.dart';
import '../../pages/rewards_shop_page.dart';
import '../../pages/how_to_play_page.dart';
import '../../pages/profile_page.dart';

// Settings Pages
import '../../pages/settings_page.dart';

/// Route names constants for better maintainability
class AppRoutes {
  AppRoutes._();

  // Authentication Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String registerRefactored = '/register-refactored';
  static const String tutorial = '/tutorial';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordEnhanced = '/forgot-password-enhanced';
  static const String emailVerification = '/email-verification';
  static const String emailVerificationRedirect = '/email-verification-redirect';

  // 2FA Routes
  static const String twoFactorAuth = '/2fa';
  static const String twoFactorAuthSetup = '/2fa-setup';
  static const String twoFactorAuthVerification = '/2fa-verification';
  static const String enhanced2FASetup = '/enhanced-2fa-setup';
  static const String enhanced2FAVerification = '/enhanced-2fa-verification';
  static const String comprehensive2FASetup = '/comprehensive-2fa-setup';
  static const String comprehensive2FAVerification = '/comprehensive-2fa-verification';

  // Main App Routes
  static const String home = '/home';
  static const String quiz = '/quiz';
  static const String boardGame = '/board-game';
  static const String duel = '/duel';
  static const String duelInvitation = '/duel-invitation';
  static const String multiplayerLobby = '/multiplayer-lobby';
  static const String roomManagement = '/room-management';
  static const String friends = '/friends';
  static const String leaderboard = '/leaderboard';
  static const String dailyChallenge = '/daily-challenge';
  static const String achievement = '/achievement';
  static const String achievementsGallery = '/achievements-gallery';
  static const String aiRecommendations = '/ai-recommendations';
  static const String rewardsShop = '/rewards-shop';
  static const String howToPlay = '/how-to-play';
  static const String profile = '/profile';

  // User Routes
  static const String settings = '/settings';
  static const String passwordChange = '/password-change';
  static const String newPassword = '/new-password';

  // Debug Routes
  static const String uidDebug = '/uid-debug';

  // Additional Pages
  static const String quizResults = '/quiz-results';
  static const String quizSettings = '/quiz-settings';
  static const String welcome = '/welcome';
  static const String rewardsMain = '/rewards-main';
  static const String notifications = '/notifications';
  static const String spectatorMode = '/spectator-mode';
  static const String carbonFootprint = '/carbon-footprint';
}

/// Navigation categories for organizing routes
enum NavigationCategory {
  authentication,
  twoFactorAuth,
  mainApp,
  user,
  debug,
}

/// Route metadata for enhanced navigation features
class RouteMetadata {
  final String title;
  final IconData? icon;
  final NavigationCategory category;
  final bool requiresAuth;
  final bool showInDrawer;
  final int? order;

  const RouteMetadata({
    required this.title,
    this.icon,
    required this.category,
    this.requiresAuth = false,
    this.showInDrawer = false,
    this.order,
  });
}

/// Complete route configuration map
class RouteConfig {
  static final Map<String, RouteMetadata> routes = {
    // Authentication Routes
    AppRoutes.login: const RouteMetadata(
      title: 'Giriş Yap',
      icon: Icons.login,
      category: NavigationCategory.authentication,
      order: 1,
    ),
    AppRoutes.register: const RouteMetadata(
      title: 'Kayıt Ol',
      icon: Icons.app_registration,
      category: NavigationCategory.authentication,
      order: 2,
    ),
    AppRoutes.registerRefactored: const RouteMetadata(
      title: 'Kayıt Ol (Yeni)',
      icon: Icons.app_registration,
      category: NavigationCategory.authentication,
      order: 3,
    ),
    AppRoutes.tutorial: const RouteMetadata(
      title: 'Tanıtım',
      icon: Icons.school,
      category: NavigationCategory.authentication,
      order: 4,
    ),
    AppRoutes.forgotPassword: const RouteMetadata(
      title: 'Şifremi Unuttum',
      icon: Icons.lock_reset,
      category: NavigationCategory.authentication,
      order: 5,
    ),
    AppRoutes.forgotPasswordEnhanced: const RouteMetadata(
      title: 'Şifremi Unuttum (Gelişmiş)',
      icon: Icons.lock_reset,
      category: NavigationCategory.authentication,
      order: 6,
    ),
    AppRoutes.emailVerification: const RouteMetadata(
      title: 'E-posta Doğrulama',
      icon: Icons.mark_email_read,
      category: NavigationCategory.authentication,
      order: 7,
    ),
    AppRoutes.emailVerificationRedirect: const RouteMetadata(
      title: 'E-posta Doğrulama Yönlendirmesi',
      icon: Icons.forward,
      category: NavigationCategory.authentication,
      order: 8,
    ),

    // 2FA Routes
    AppRoutes.twoFactorAuth: const RouteMetadata(
      title: 'İki Faktörlü Doğrulama',
      icon: Icons.security,
      category: NavigationCategory.twoFactorAuth,
      order: 1,
    ),
    AppRoutes.twoFactorAuthSetup: const RouteMetadata(
      title: '2FA Kurulum',
      icon: Icons.settings,
      category: NavigationCategory.twoFactorAuth,
      order: 2,
    ),
    AppRoutes.twoFactorAuthVerification: const RouteMetadata(
      title: '2FA Doğrulama',
      icon: Icons.verified_user,
      category: NavigationCategory.twoFactorAuth,
      order: 3,
    ),
    AppRoutes.enhanced2FASetup: const RouteMetadata(
      title: 'Gelişmiş 2FA Kurulum',
      icon: Icons.security_update,
      category: NavigationCategory.twoFactorAuth,
      order: 4,
    ),
    AppRoutes.enhanced2FAVerification: const RouteMetadata(
      title: 'Gelişmiş 2FA Doğrulama',
      icon: Icons.verified,
      category: NavigationCategory.twoFactorAuth,
      order: 5,
    ),
    AppRoutes.comprehensive2FASetup: const RouteMetadata(
      title: 'Kapsamlı 2FA Kurulum',
      icon: Icons.enhanced_encryption,
      category: NavigationCategory.twoFactorAuth,
      order: 6,
    ),
    AppRoutes.comprehensive2FAVerification: const RouteMetadata(
      title: 'Kapsamlı 2FA Doğrulama',
      icon: Icons.verified,
      category: NavigationCategory.twoFactorAuth,
      order: 7,
    ),

    // Main App Routes
    AppRoutes.home: const RouteMetadata(
      title: 'Ana Sayfa',
      icon: Icons.home,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 1,
    ),
    AppRoutes.quiz: const RouteMetadata(
      title: 'Quiz',
      icon: Icons.quiz,
      category: NavigationCategory.mainApp,
      showInDrawer: true,
      order: 2,
    ),
    AppRoutes.boardGame: const RouteMetadata(
      title: 'Masa Oyunu',
      icon: Icons.casino,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 3,
    ),
    AppRoutes.duel: const RouteMetadata(
      title: 'Düello',
      icon: Icons.sports_esports,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 4,
    ),
    AppRoutes.duelInvitation: const RouteMetadata(
      title: 'Düello Daveti',
      icon: Icons.mail,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      order: 5,
    ),
    AppRoutes.multiplayerLobby: const RouteMetadata(
      title: 'Çoklu Oyuncu Lobisi',
      icon: Icons.group,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 6,
    ),
    AppRoutes.roomManagement: const RouteMetadata(
      title: 'Oda Yönetimi',
      icon: Icons.meeting_room,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      order: 7,
    ),
    AppRoutes.friends: const RouteMetadata(
      title: 'Arkadaşlar',
      icon: Icons.people,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 8,
    ),
    AppRoutes.leaderboard: const RouteMetadata(
      title: 'Liderlik Tablosu',
      icon: Icons.leaderboard,
      category: NavigationCategory.mainApp,
      showInDrawer: true,
      order: 9,
    ),
    AppRoutes.dailyChallenge: const RouteMetadata(
      title: 'Günlük Görev',
      icon: Icons.task_alt,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 10,
    ),
    AppRoutes.achievement: const RouteMetadata(
      title: 'Başarılar',
      icon: Icons.emoji_events,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 11,
    ),
    AppRoutes.achievementsGallery: const RouteMetadata(
      title: 'Başarılar Galerisi',
      icon: Icons.wallpaper,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 12,
    ),
    AppRoutes.aiRecommendations: const RouteMetadata(
      title: 'AI Önerileri',
      icon: Icons.lightbulb,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 13,
    ),
    AppRoutes.rewardsShop: const RouteMetadata(
      title: 'Ödül Mağazası',
      icon: Icons.card_giftcard,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 14,
    ),
    AppRoutes.howToPlay: const RouteMetadata(
      title: 'Nasıl Oynanır',
      icon: Icons.help,
      category: NavigationCategory.mainApp,
      showInDrawer: true,
      order: 15,
    ),
    AppRoutes.profile: const RouteMetadata(
      title: 'Profil',
      icon: Icons.person,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 16,
    ),

    // User Routes
    AppRoutes.settings: const RouteMetadata(
      title: 'Ayarlar',
      icon: Icons.settings,
      category: NavigationCategory.user,
      requiresAuth: true,
      showInDrawer: true,
      order: 1,
    ),
    AppRoutes.passwordChange: const RouteMetadata(
      title: 'Şifre Değiştir',
      icon: Icons.password,
      category: NavigationCategory.user,
      requiresAuth: true,
      order: 2,
    ),
    AppRoutes.newPassword: const RouteMetadata(
      title: 'Yeni Şifre',
      icon: Icons.lock,
      category: NavigationCategory.user,
      order: 3,
    ),

    // Debug Routes
    AppRoutes.uidDebug: const RouteMetadata(
      title: 'UID Debug',
      icon: Icons.developer_mode,
      category: NavigationCategory.debug,
      order: 1,
    ),

    // Additional Pages
    AppRoutes.quizResults: const RouteMetadata(
      title: 'Quiz Sonuçları',
      icon: Icons.bar_chart,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 17,
    ),
    AppRoutes.quizSettings: const RouteMetadata(
      title: 'Quiz Ayarları',
      icon: Icons.tune,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 18,
    ),
    AppRoutes.welcome: const RouteMetadata(
      title: 'Hoşgeldin',
      icon: Icons.waving_hand,
      category: NavigationCategory.mainApp,
      order: 19,
    ),
    AppRoutes.rewardsMain: const RouteMetadata(
      title: 'Ödül Ana Sayfası',
      icon: Icons.stars,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 20,
    ),
    AppRoutes.notifications: const RouteMetadata(
      title: 'Bildirimler',
      icon: Icons.notifications,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 21,
    ),
    AppRoutes.spectatorMode: const RouteMetadata(
      title: 'İzleyici Modu',
      icon: Icons.visibility,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 22,
    ),
    AppRoutes.carbonFootprint: const RouteMetadata(
      title: 'Karbon Ayak İzi',
      icon: Icons.eco,
      category: NavigationCategory.mainApp,
      requiresAuth: true,
      showInDrawer: true,
      order: 23,
    ),
  };
}

/// Comprehensive App Router with all pages included
class AppRouterComplete {
  AppRouterComplete._();

  static final AuthenticationStateService _authService = AuthenticationStateService();
  static bool _initialized = false;

  /// Initialize the router
  static void initialize() {
    if (!_initialized) {
      _initialized = true;
      if (kDebugMode) {
        debugPrint('AppRouterComplete: Initialized with ${RouteConfig.routes.length} routes');
      }
    }
  }

  /// Generate routes for the app
  static PageRoute<dynamic> generateRoute(RouteSettings settings) {
    if (kDebugMode) {
      debugPrint('AppRouterComplete: Navigating to: ${settings.name}');
    }

    final String? routeName = settings.name;

    // Check for debug routes (only in debug mode)
    if (routeName == AppRoutes.uidDebug) {
      if (!kDebugMode) {
        return _buildRoute(_buildErrorPage('Sayfa Bulunamadı', 'Debug sayfaları yalnızca geliştirme modunda erişilebilir'));
      }
      return _buildRoute(_buildErrorPage('UID Debug', 'UID debug page placeholder'));
    }

    // Handle authentication routes
    return switch (routeName) {
      AppRoutes.login => _buildRoute(LoginPage()),
      AppRoutes.register => _buildRoute(RegisterPage()),
      AppRoutes.registerRefactored => _buildRoute(RegisterPageRefactored()),
      AppRoutes.tutorial => _buildRoute(TutorialPage()),
      AppRoutes.forgotPassword => _buildRoute(ForgotPasswordPage()),
      AppRoutes.forgotPasswordEnhanced => _buildRoute(ForgotPasswordPageEnhanced()),
      AppRoutes.emailVerification => _buildRoute(EmailVerificationPage()),
      AppRoutes.emailVerificationRedirect => _buildRoute(EmailVerificationRedirectPage()),
      
      // 2FA Routes
      AppRoutes.twoFactorAuth => _buildRoute(TwoFactorAuthPage(userId: settings.arguments as String? ?? '')),
      AppRoutes.twoFactorAuthSetup => _buildRoute(TwoFactorAuthSetupPage()),
      AppRoutes.twoFactorAuthVerification => _buildRoute(TwoFactorAuthVerificationPage(
        authResult: settings.arguments ?? _createDefaultAuthResult(),
      )),
      AppRoutes.enhanced2FASetup => _buildRoute(EnhancedTwoFactorAuthSetupPage()),
      AppRoutes.enhanced2FAVerification => _buildRoute(EnhancedTwoFactorAuthVerificationPage(
        authResult: settings.arguments ?? _createDefaultAuthResult(),
      )),
      AppRoutes.comprehensive2FASetup => _buildRoute(ComprehensiveTwoFactorAuthSetupPage()),
      AppRoutes.comprehensive2FAVerification => _buildComprehensive2FAVerification(settings),
      
      // Main App Routes
      AppRoutes.home => _buildProtectedRoute(HomeDashboard(), settings),
      AppRoutes.quiz => _buildRoute(const QuizPage()),
      AppRoutes.boardGame => _buildRoute(BoardGamePage(
        userNickname: settings.arguments is String ? settings.arguments as String : 'Player',
      )),
      AppRoutes.duel => _buildProtectedRoute(DuelPage(), settings),
      AppRoutes.duelInvitation => _buildProtectedRoute(DuelInvitationPage(), settings),
      AppRoutes.multiplayerLobby => _buildProtectedRoute(MultiplayerLobbyPage(
        userNickname: settings.arguments is String ? settings.arguments as String : 'Player',
      ), settings),
      AppRoutes.roomManagement => _buildProtectedRoute(RoomManagementPage(
        userNickname: settings.arguments is String ? settings.arguments as String : 'Player',
      ), settings),
      AppRoutes.friends => _buildProtectedRoute(FriendsPage(
        userNickname: settings.arguments is String ? settings.arguments as String : 'Player',
      ), settings),
      AppRoutes.leaderboard => _buildRoute(LeaderboardPage()),
      AppRoutes.dailyChallenge => _buildProtectedRoute(DailyChallengePage(), settings),
      AppRoutes.achievement => _buildProtectedRoute(AchievementPage(), settings),
      AppRoutes.achievementsGallery => _buildProtectedRoute(AchievementsGalleryPage(), settings),
      AppRoutes.aiRecommendations => _buildProtectedRoute(AIRecommendationsPage(), settings),
      AppRoutes.rewardsShop => _buildProtectedRoute(RewardsShopPage(), settings),
      AppRoutes.howToPlay => _buildRoute(HowToPlayPage()),
      AppRoutes.profile => _buildProtectedRoute(ProfilePage(), settings),
      
      // User Routes
      AppRoutes.settings => _buildProtectedRoute(SettingsPage(), settings),
      AppRoutes.passwordChange => _buildProtectedRoute(_buildPlaceholderPage('Şifre Değiştir'), settings),
      AppRoutes.newPassword => _buildProtectedRoute(_buildPlaceholderPage('Yeni Şifre'), settings),

      // Additional Pages
      AppRoutes.quizResults => _buildProtectedRoute(_buildPlaceholderPage('Quiz Sonuçları'), settings),
      AppRoutes.quizSettings => _buildProtectedRoute(_buildPlaceholderPage('Quiz Ayarları'), settings),
      AppRoutes.welcome => _buildRoute(_buildPlaceholderPage('Hoşgeldin')),
      AppRoutes.rewardsMain => _buildProtectedRoute(_buildPlaceholderPage('Ödül Ana Sayfası'), settings),
      AppRoutes.rewardsShop => _buildProtectedRoute(_buildPlaceholderPage('Ödül Mağazası'), settings),
      AppRoutes.notifications => _buildProtectedRoute(_buildPlaceholderPage('Bildirimler'), settings),
      AppRoutes.spectatorMode => _buildProtectedRoute(_buildPlaceholderPage('İzleyici Modu'), settings),
      AppRoutes.carbonFootprint => _buildProtectedRoute(_buildPlaceholderPage('Karbon Ayak İzi'), settings),

      // Default route
      _ => _buildRoute(LoginPage()),
    };
  }

  /// Build comprehensive 2FA verification page with arguments
  static PageRoute<dynamic> _buildComprehensive2FAVerification(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    return _buildRoute(
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

  /// Create a standard route with slide transition
  static PageRoute<T> _buildRoute<T>(Widget page) {
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
  static PageRoute<T> _buildProtectedRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          _AuthProtectedRouteWrapper(
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

  /// Create default auth result for 2FA pages
  static dynamic _createDefaultAuthResult() {
    return {
      'requires2FA': false,
      'phoneProvider': null,
      'multiFactorResolver': null,
      'isMock': true,
    };
  }

  /// Build error page widget
  static Widget _buildErrorPage(String title, String message) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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

  /// Build placeholder page for missing implementations
  static Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            Text('$title sayfası henüz tamamlanmadı'),
            const SizedBox(height: 8),
            const Text('Bu özellik yakında eklenecek'),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Get route metadata
  static RouteMetadata? getRouteMetadata(String routeName) {
    return RouteConfig.routes[routeName];
  }

  /// Get all routes by category
  static Map<String, RouteMetadata> getRoutesByCategory(NavigationCategory category) {
    return Map.fromEntries(
      RouteConfig.routes.entries.where((e) => e.value.category == category),
    );
  }

  /// Get all routes that require authentication
  static Map<String, RouteMetadata> getProtectedRoutes() {
    return Map.fromEntries(
      RouteConfig.routes.entries.where((e) => e.value.requiresAuth),
    );
  }

  /// Get all routes that show in drawer
  static Map<String, RouteMetadata> getDrawerRoutes() {
    return Map.fromEntries(
      RouteConfig.routes.entries.where((e) => e.value.showInDrawer),
    );
  }

  /// Check if route exists
  static bool routeExists(String routeName) {
    return RouteConfig.routes.containsKey(routeName);
  }

  /// Navigate to route by name
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to route and remove all previous routes
  static void navigateAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false, arguments: arguments);
  }

  /// Go back to previous route
  static void goBack(BuildContext context, {Object? result}) {
    Navigator.of(context).pop(result);
  }
}

/// Wrapper widget for protected routes that handles authentication checks
class _AuthProtectedRouteWrapper extends StatefulWidget {
  final Widget child;
  final AuthenticationStateService authService;
  final String fallbackRoute;
  final Map<String, dynamic>? fallbackArguments;

  const _AuthProtectedRouteWrapper({
    required this.authService,
    required this.fallbackRoute,
    required this.child,
    this.fallbackArguments,
  });

  @override
  State<_AuthProtectedRouteWrapper> createState() => _AuthProtectedRouteWrapperState();
}

class _AuthProtectedRouteWrapperState extends State<_AuthProtectedRouteWrapper> {
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
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuth;
          _isLoading = false;
        });
      }

      if (!_isAuthenticated && mounted) {
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
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }

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

/// Extension for easy navigation
extension AppNavigationExtension on NavigatorState {
  /// Navigate to home (with clearance)
  void toHome() {
    pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  /// Navigate to login (with clearance)
  void toLogin() {
    pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}

/// Smart navigation helper with context-aware navigation
class SmartNavigator {
  /// Navigate to a route with built-in authentication check
  static Future<T?> navigateWithAuth<T>({
    required BuildContext context,
    required String routeName,
    Object? arguments,
    bool requireAuth = true,
    String? authFallbackRoute,
  }) async {
    if (requireAuth) {
      final authService = AuthenticationStateService();
      final isAuth = await authService.isCurrentUserAuthenticated();
      
      if (!isAuth) {
        authFallbackRoute ??= AppRoutes.login;
        return Navigator.of(context).pushNamedAndRemoveUntil(
          authFallbackRoute,
          (route) => false,
          arguments: {'redirectTo': routeName},
        ) as T?;
      }
    }
    
    return Navigator.of(context).pushNamed(routeName, arguments: arguments) as T?;
  }

  /// Navigate to a deep link
  static Future<void> handleDeepLink(BuildContext context, String deepLink) async {
    if (kDebugMode) {
      debugPrint('SmartNavigator: Handling deep link: $deepLink');
    }

    if (deepLink.startsWith('ecogame://')) {
      final path = deepLink.replaceFirst('ecogame://', '');
      final parts = path.split('/');
      
      switch (parts[0]) {
        case 'quiz':
          await Navigator.of(context).pushNamed(AppRoutes.quiz);
          break;
        case 'duel':
          await Navigator.of(context).pushNamed(AppRoutes.duel);
          break;
        case 'profile':
          await navigateWithAuth(
            context: context,
            routeName: AppRoutes.profile,
            requireAuth: true,
          );
          break;
      }
    }
  }
}

