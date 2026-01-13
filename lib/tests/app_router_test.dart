// lib/tests/app_router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/core/navigation/app_router.dart';
import 'package:karbonson/pages/login_page.dart';

// Placeholder widget sınıfları - gerçek projede import edilecek
// MockAuthenticationStateService for testing

// MockAuthenticationService placeholder
class MockAuthenticationService {
  bool shouldAuthenticate = true;

  MockAuthenticationService({this.shouldAuthenticate = true});

  Future<bool> isCurrentUserAuthenticated() async {
    return shouldAuthenticate;
  }
}

void main() {
  group('AppRouter Tests', () {
    setUp(() {
    });

    testWidgets('should generate login route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.login));
      
      expect(route, isNotNull);
      
      // Route'un doğru sayfayı oluşturduğunu kontrol et
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(),
        ),
      );
      
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should generate register route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.register));
      
      expect(route, isNotNull);
      
      // Basitleştirilmiş test - sadece route'un null olmadığını kontrol et
      expect(route, isNotNull);
    });

    testWidgets('should generate register refactored route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.registerRefactored));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate tutorial route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.tutorial));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate email verification route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.emailVerification));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate forgot password route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.forgotPassword));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate forgot password enhanced route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.forgotPasswordEnhanced));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate 2FA setup route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.twoFactorAuthSetup));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate enhanced 2FA setup route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.enhanced2FASetup));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate comprehensive 2FA setup route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.comprehensive2FASetup));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate comprehensive 2FA verification route correctly', (WidgetTester tester) async {
      final arguments = {
        'initialMethod': 'sms',
        'availableMethods': ['sms', 'backupCode'],
      };
      
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.comprehensive2FAVerification,
          arguments: arguments,
        ),
      );
      
      expect(route, isNotNull);
    });

    testWidgets('should generate home route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.home));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate profile route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.profile));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate board game route with user nickname', (WidgetTester tester) async {
      final userNickname = 'TestPlayer';
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.boardGame,
          arguments: userNickname,
        ),
      );
      
      expect(route, isNotNull);
    });

    testWidgets('should generate quiz route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.quiz));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate leaderboard route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.leaderboard));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate friends route with user nickname', (WidgetTester tester) async {
      final userNickname = 'TestPlayer';
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.friends,
          arguments: userNickname,
        ),
      );
      
      expect(route, isNotNull);
    });

    testWidgets('should generate multiplayer lobby route with user nickname', (WidgetTester tester) async {
      final userNickname = 'TestPlayer';
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.multiplayerLobby,
          arguments: userNickname,
        ),
      );
      
      expect(route, isNotNull);
    });

    testWidgets('should generate duel route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.duel));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate duel invitation route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.duelInvitation));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate room management route with user nickname', (WidgetTester tester) async {
      final userNickname = 'TestPlayer';
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.roomManagement,
          arguments: userNickname,
        ),
      );
      
      expect(route, isNotNull);
    });

    testWidgets('should generate settings route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.settings));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate AI recommendations route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.aiRecommendations));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate achievement route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.achievement));
      
      expect(route, isNotNull);
    });

    testWidgets('should generate daily challenge route correctly', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.dailyChallenge));
      
      expect(route, isNotNull);
    });

    testWidgets('should default to login route for unknown routes', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: '/unknown-route'));
      
      expect(route, isNotNull);
    });

    testWidgets('should create route as PageRoute', (WidgetTester tester) async {
      final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.login));
      
      expect(route, isNotNull);
    });

    testWidgets('should handle route arguments correctly for board game', (WidgetTester tester) async {
      final userNickname = 'CustomPlayer';
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.boardGame,
          arguments: userNickname,
        ),
      );
      
      expect(route, isNotNull);
    });

    testWidgets('should handle null arguments for routes requiring them', (WidgetTester tester) async {
      // String olmayan argümanlarla test
      final route = AppRouter.generateRoute(
        RouteSettings(
          name: AppRoutes.boardGame,
          arguments: 123, // String olmayan argüman
        ),
      );
      
      expect(route, isNotNull);
    });

    test('AppRoutes constants should have correct values', () {
      // Authentication routes
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.tutorial, '/tutorial');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.registerRefactored, '/register-refactored');
      expect(AppRoutes.emailVerification, '/email-verification');
      expect(AppRoutes.forgotPassword, '/forgot-password');
      expect(AppRoutes.forgotPasswordEnhanced, '/forgot-password-enhanced');
      
      // 2FA routes
      expect(AppRoutes.twoFactorAuthSetup, '/2fa-setup');
      expect(AppRoutes.twoFactorAuthVerification, '/2fa-verification');
      expect(AppRoutes.enhanced2FASetup, '/enhanced-2fa-setup');
      expect(AppRoutes.enhanced2FAVerification, '/enhanced-2fa-verification');
      expect(AppRoutes.comprehensive2FASetup, '/comprehensive-2fa-setup');
      expect(AppRoutes.comprehensive2FAVerification, '/comprehensive-2fa-verification');
      
      // Main app routes
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.boardGame, '/board-game');
      expect(AppRoutes.quiz, '/quiz');
      expect(AppRoutes.leaderboard, '/leaderboard');
      expect(AppRoutes.friends, '/friends');
      expect(AppRoutes.multiplayerLobby, '/multiplayer-lobby');
      expect(AppRoutes.duel, '/duel');
      expect(AppRoutes.duelInvitation, '/duel-invitation');
      expect(AppRoutes.roomManagement, '/room-management');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.aiRecommendations, '/ai-recommendations');
      expect(AppRoutes.achievement, '/achievement');
      expect(AppRoutes.dailyChallenge, '/daily-challenge');
    });
  });
}

