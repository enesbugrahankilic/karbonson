import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provides/theme_provider.dart';
import 'provides/language_provider.dart';
import 'provides/quiz_bloc.dart';
import 'provides/profile_bloc.dart';
import 'provides/ai_bloc.dart';
import 'services/ai_service.dart';
import 'services/quiz_logic.dart';
import 'services/profile_service.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/authentication_state_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/deep_linking_service.dart';
// Removed unused imports
import 'theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';

void main() {
  // Run the app inside a guarded zone; call ensureInitialized and runApp
  // from inside the same zone to avoid "Zone mismatch" errors.
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    // Forward Flutter framework errors into the current zone so runZonedGuarded can catch them
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
    };

    if (kDebugMode) debugPrint('main: starting app (guarded zone)');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => AuthenticationStateService()),
          BlocProvider(create: (_) => QuizBloc(quizLogic: QuizLogic())),
          BlocProvider(create: (_) => ProfileBloc(profileService: ProfileService())),
          BlocProvider(create: (_) => AIBloc(AIService(baseUrl: 'http://localhost:5000'))),
        ],
        child: const AppRoot(),
      ),
    );
  }, (error, stack) {
    // Log uncaught errors from the zone
    if (kDebugMode) debugPrint('Uncaught zone error: $error');
    if (kDebugMode) debugPrint('$stack');
  });
}

/// AppRoot shows a lightweight splash while performing async initialization
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget the initialization sequence that updates state
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      // Initialize Firebase safely (web uses options; native uses platform files)
      if (kDebugMode) debugPrint('AppRoot: initializing Firebase (kIsWeb=$kIsWeb)');
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      } else {
        try {
          await Firebase.initializeApp();
        } on FirebaseException catch (fe) {
          if (fe.code == 'duplicate-app') {
            if (kDebugMode) debugPrint('AppRoot: duplicate-app during Firebase.initializeApp - ignoring.');
          } else {
            rethrow;
          }
        }
      }

      // Initialize authentication persistence to keep users logged in
      try {
        if (kDebugMode) debugPrint('AppRoot: initializing authentication persistence');
        await FirebaseAuthService.initializeAuthPersistence();
        if (kDebugMode) debugPrint('AppRoot: Authentication persistence initialized');
      } catch (e, st) {
        if (kDebugMode) debugPrint('AppRoot: Authentication persistence init failed: $e');
        if (kDebugMode) debugPrint('$st');
      }

      // Restore authentication state from persistent session
      try {
        if (kDebugMode) debugPrint('AppRoot: restoring authentication state');
        final authStateService = AuthenticationStateService();
        await authStateService.initializeAuthState();
        if (kDebugMode) debugPrint('AppRoot: Authentication state restored');
      } catch (e, st) {
        if (kDebugMode) debugPrint('AppRoot: Authentication state restoration failed: $e');
        if (kDebugMode) debugPrint('$st');
      }

      // Initialize deep linking service for password reset and 2FA flows
      try {
        if (kDebugMode) debugPrint('AppRoot: initializing deep linking service');
        await DeepLinkingService().initialize();
        if (kDebugMode) debugPrint('AppRoot: Deep linking service initialized');
      } catch (e, st) {
        if (kDebugMode) debugPrint('AppRoot: Deep linking service init failed: $e');
        if (kDebugMode) debugPrint('$st');
      }

      // Safe notification initialization (best-effort)
      try {
        if (kDebugMode) debugPrint('AppRoot: initializing NotificationService');
        await NotificationService.initialize();
        if (kDebugMode) debugPrint('AppRoot: NotificationService initialized');

        // 12 saatlik hatırlatma kontrolü
        try {
          await QuizLogic().checkAndSendReminderNotification();
          if (kDebugMode) debugPrint('AppRoot: Reminder notification check completed');
        } catch (e, st) {
          if (kDebugMode) debugPrint('AppRoot: Reminder notification check failed: $e');
          if (kDebugMode) debugPrint('$st');
        }
      } catch (e, st) {
        if (kDebugMode) debugPrint('AppRoot: NotificationService init failed: $e');
        if (kDebugMode) debugPrint('$st');
      }

      setState(() => _initializing = false);
    } catch (e, st) {
      if (kDebugMode) debugPrint('AppRoot: initialization error: $e');
      if (kDebugMode) debugPrint('$st');
      setState(() {
        _initializing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Başlatılıyor... Lütfen bekleyin', style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Başlatma Hatası', style: TextStyle(color: Colors.black87))),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Uygulama başlatılırken hata oluştu.', style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                Text(_error ?? '', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _initialize, child: const Text('Tekrar Dene')),
              ],
            ),
          ),
        ),
      );
    }

    // Normal app entry after initialization
    return const Karbon2App();
  }
}

class Karbon2App extends StatefulWidget {
  const Karbon2App({super.key});

  @override
  State<Karbon2App> createState() => _Karbon2AppState();
}

class _Karbon2AppState extends State<Karbon2App> {
  bool _hasSeenTutorial = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenTutorial') ?? false;
    setState(() {
      _hasSeenTutorial = hasSeen;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        ThemeData themeToShow;
        String title;
        
        if (themeProvider.isHighContrast) {
          themeToShow = AppTheme.highContrastTheme;
          title = 'Eco Game - Yüksek Kontrast';
        } else {
          themeToShow = themeProvider.themeMode == ThemeMode.dark 
            ? AppTheme.darkTheme 
            : AppTheme.lightTheme;
          title = 'Eco Game';
        }

        return MaterialApp(
          title: title,
          debugShowCheckedModeBanner: false,
          theme: themeToShow,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isHighContrast 
            ? ThemeMode.light 
            : themeProvider.themeMode,
          locale: languageProvider.locale,
          navigatorKey: GlobalKey<NavigatorState>(),
          navigatorObservers: [
            AppNavigatorObserver(),
          ],
          onGenerateRoute: AppRouter().generateRoute,
          initialRoute: _hasSeenTutorial ? AppRoutes.login : AppRoutes.tutorial,
        );
      },
    );
  }
}