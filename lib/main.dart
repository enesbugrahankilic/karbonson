// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/login_page.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/quiz_bloc.dart';
import 'services/quiz_logic.dart'; 
// Not: firebase_options.dart dosyası sizin projenizden gelen kodu içerir.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => QuizBloc(quizLogic: QuizLogic())),
      ],
      child: const Karbon2App(),
    ),
  );
}

class Karbon2App extends StatelessWidget {
  const Karbon2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karbon Ayak İzi Hesaplama (Karbon2)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5), 
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(
          secondary: const Color(0xFF4CAF50), 
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5), 
          foregroundColor: Colors.white,
          elevation: 0, 
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}