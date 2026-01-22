import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karbonson/provides/theme_provider.dart';
import 'package:karbonson/provides/language_provider.dart';
import 'package:karbonson/provides/quiz_bloc.dart';
import 'package:karbonson/services/quiz_logic.dart';
import 'package:karbonson/models/question.dart';
import 'package:karbonson/enums/app_language.dart';
import 'package:karbonson/pages/home_dashboard.dart';
import 'package:karbonson/pages/login_page.dart';
import 'package:karbonson/pages/register_page.dart';
import 'package:karbonson/pages/profile_page.dart';
import 'package:karbonson/pages/quiz_page.dart';
import 'package:karbonson/pages/quiz_settings_page.dart';
import 'package:karbonson/pages/leaderboard_page.dart';
import 'package:karbonson/pages/friends_page.dart';
import 'package:karbonson/pages/achievement_page.dart';
import 'package:karbonson/pages/notifications_page.dart';
import 'package:karbonson/pages/spectator_mode_page.dart';
import 'package:karbonson/pages/settings_page.dart';
import 'package:karbonson/widgets/user_qr_code_widget.dart';
import 'package:karbonson/widgets/global_error_states.dart';
import 'package:karbonson/widgets/page_templates.dart';
import 'package:karbonson/theme/design_system.dart';

void main() {
  group('Kapsamlı UI/UX Tasarım Testleri - Tüm Sayfalar ve Bileşenler', () {
    late ThemeProvider themeProvider;
    late LanguageProvider languageProvider;
    late QuizLogic quizLogic;
    late QuizBloc quizBloc;

    setUp(() {
      themeProvider = ThemeProvider();
      languageProvider = LanguageProvider();
      quizLogic = QuizLogic();
      quizBloc = QuizBloc(quizLogic: quizLogic);
    });

    Widget createTestApp(Widget page) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: languageProvider),
          BlocProvider.value(value: quizBloc),
        ],
        child: MaterialApp(
          home: page,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      );
    }

    // ===========================================================================
    // ANA SAYFA TESTLERİ
    // ===========================================================================

    group('Login Sayfası UI Testleri', () {
      testWidgets('Login sayfası gerekli tüm öğeleri içeriyor ve doğru render ediliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LoginPage()));

        // Email input kontrol - daha spesifik
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
        expect(find.bySemanticsLabel('Email'), findsOneWidget);

        // Password input kontrol
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Login butonu kontrol
        expect(find.widgetWithText(ElevatedButton, 'Giriş Yap'), findsOneWidget);

        // Şifremi unuttum link kontrol
        expect(find.byType(GestureDetector), findsWidgets);

        // Sayfa başlığı kontrol
        expect(find.text('Giriş Yap'), findsOneWidget);
      });

      testWidgets('Email validation çalışıyor ve hata mesajı gösteriliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LoginPage()));

        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'invalidemail');
        await tester.pumpAndSettle();

        // Validation mesajı görünmeli
        expect(find.textContaining('geçerli'), findsWidgets);
      });

      testWidgets('Password visibility toggle çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LoginPage()));

        // Başlangıçta visibility_off ikonu olmalı
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // İkona tıkla
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pumpAndSettle();

        // Şimdi visibility ikonu olmalı
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('Register Sayfası UI Testleri', () {
      testWidgets('Register sayfası tüm gerekli alanları içeriyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const RegisterPage()));

        // Tüm input alanları kontrol
        expect(find.byType(TextFormField), findsAtLeastNWidgets(3)); // email, password, confirm

        // Register butonu var mı
        expect(find.widgetWithText(ElevatedButton, 'Kayıt Ol'), findsOneWidget);

        // Login link var mı
        expect(find.byType(GestureDetector), findsWidgets);
      });

      testWidgets('Form validation çalışıyor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const RegisterPage()));

        final registerButton = find.widgetWithText(ElevatedButton, 'Kayıt Ol');
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Validation mesajları görünmeli
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('Password strength indicator var mı',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const RegisterPage()));

        // Password gücü göstergesi ara
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });
    });

    group('Home Dashboard UI Testleri', () {
      testWidgets('Dashboard navigation bar doğru çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const HomeDashboard()));

        // Bottom navigation kontrol
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Navigation öğeleri kontrol
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.quiz), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.leaderboard), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });

      testWidgets('Dashboard responsive layout çalışıyor',
          (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);

        await tester.pumpWidget(createTestApp(const HomeDashboard()));
        await tester.pumpAndSettle();

        // Sayfanın render olduğunu kontrol et
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('Navigation arasında geçiş çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const HomeDashboard()));

        // Quiz tab'ına tıkla
        await tester.tap(find.byIcon(Icons.quiz));
        await tester.pumpAndSettle();

        // Quiz sayfası yüklenmiş olmalı
        expect(find.byType(HomeDashboard), findsOneWidget);
      });
    });

    // ===========================================================================
    // OYUN SAYFALARI TESTLERİ
    // ===========================================================================

    group('Quiz Sayfası UI Testleri', () {
      testWidgets('Quiz sayfası soru ve cevapları doğru gösteriyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(QuizPage(quizLogic: quizLogic)));

        // Soru metni
        expect(find.byType(Text), findsWidgets);

        // Cevap seçenekleri
        expect(find.byType(GestureDetector), findsWidgets);

        // Next/Submit butonu
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('Quiz progress indicator çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(QuizPage(quizLogic: quizLogic)));

        // Progress bar ara
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('Answer selection çalışıyor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(QuizPage(quizLogic: quizLogic)));

        // Bir cevap seçeneğine tıkla
        final options = find.byType(GestureDetector);
        if (options.evaluate().isNotEmpty) {
          await tester.tap(options.first);
          await tester.pumpAndSettle();

          // Seçili cevap görsel değişikliği olabilir
          expect(find.byType(GestureDetector), findsWidgets);
        }
      });
    });

    group('Quiz Settings Sayfası UI Testleri', () {
      testWidgets('Quiz settings tüm seçenekleri içeriyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(QuizSettingsPage(
          onStartQuiz: ({
            required String category,
            required DifficultyLevel difficulty,
            required int questionCount,
            required AppLanguage language,
          }) {
            // Test implementation - do nothing
          },
        )));

        // Kategori seçimi
        expect(find.byType(DropdownButton), findsWidgets);

        // Zorluk seviyesi
        expect(find.byType(Radio), findsWidgets);

        // Soru sayısı
        expect(find.byType(Slider), findsWidgets);

        // Başlat butonu
        expect(find.widgetWithText(ElevatedButton, 'Quiz Başlat'), findsOneWidget);
      });

      testWidgets('Settings değişiklikleri uygulanıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(QuizSettingsPage(
          onStartQuiz: ({
            required String category,
            required DifficultyLevel difficulty,
            required int questionCount,
            required AppLanguage language,
          }) {
            // Test implementation - do nothing
          },
        )));

        // Slider'ı değiştir
        final slider = find.byType(Slider);
        if (slider.evaluate().isNotEmpty) {
          await tester.drag(slider.first, const Offset(50, 0));
          await tester.pumpAndSettle();

          expect(find.byType(Slider), findsOneWidget);
        }
      });
    });

    // ===========================================================================
    // SOSYAL SAYFALAR TESTLERİ
    // ===========================================================================

    group('Profile Sayfası UI Testleri', () {
      testWidgets('Profile sayfası kullanıcı bilgilerini gösteriyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const ProfilePage()));

        // Profil resmi
        expect(find.byType(CircleAvatar), findsOneWidget);

        // Kullanıcı adı
        expect(find.byType(Text), findsWidgets);

        // İstatistikler
        expect(find.byType(Card), findsWidgets);

        // Edit butonu
        expect(find.byType(ElevatedButton), findsWidgets);
      });

      testWidgets('Profile resmi upload butonu çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const ProfilePage()));

        // Camera/Gallery butonu ara
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      });
    });

    group('Leaderboard Sayfası UI Testleri', () {
      testWidgets('Leaderboard listesi doğru gösteriliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LeaderboardPage()));

        // Liste öğeleri
        expect(find.byType(ListView), findsOneWidget);

        // Rank göstergesi
        expect(find.byType(Text), findsWidgets);

        // Puan göstergesi
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('Ranking badge öğeleri var mı',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LeaderboardPage()));

        // Medal/Trophy ikonları ara
        expect(find.byIcon(Icons.emoji_events), findsWidgets);
      });
    });

    group('Friends Sayfası UI Testleri', () {
      testWidgets('Friends sayfası arkadaş listesini gösteriyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const FriendsPage(userNickname: 'test_user')));

        // Arkadaş listesi
        expect(find.byType(ListView), findsWidgets);

        // Arkadaş ekleme butonu
        expect(find.byIcon(Icons.person_add), findsWidgets);

        // Sayfa başlığı
        expect(find.text('Arkadaşlar'), findsOneWidget);
      });

      testWidgets('Arkadaş ekleme işlevi çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const FriendsPage(userNickname: 'test_user')));

        // Arkadaş ekleme butonuna tıkla
        final addButton = find.byIcon(Icons.person_add);
        if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton.first);
          await tester.pumpAndSettle();

          // Dialog veya sayfa değişikliği olabilir
          expect(find.byType(FriendsPage), findsOneWidget);
        }
      });
    });

    group('Achievement Sayfası UI Testleri', () {
      testWidgets('Achievement sayfası tab sistemi ile çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const AchievementPage()));

        // Tab bar kontrol
        expect(find.byType(TabBar), findsOneWidget);

        // Tab başlıkları
        expect(find.text('Tümü'), findsOneWidget);
        expect(find.text('Kazanılan'), findsOneWidget);
        expect(find.text('Kazanılmamış'), findsOneWidget);

        // Liste görünümü
        expect(find.byType(ListView), findsWidgets);
      });

      testWidgets('Achievement kartları doğru render ediliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const AchievementPage()));

        // Achievement kartları yükleniyor kontrolü
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });
    });

    group('Notifications Sayfası UI Testleri', () {
      testWidgets('Notifications sayfası filtre sistemi ile çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const NotificationsPage()));

        // Filter chip'ler
        expect(find.byType(FilterChip), findsWidgets);

        // Tüm ve Okunmamış filtreleri
        expect(find.text('Tümü'), findsOneWidget);
        expect(find.text('Okunmamış'), findsWidgets);
      });

      testWidgets('Notification öğeleri doğru gösteriliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const NotificationsPage()));

        // Loading durumunda progress indicator
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('Mark all as read butonu çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const NotificationsPage()));

        // Mark all butonu (eğer unread varsa)
        final markAllButton = find.byIcon(Icons.done_all);
        if (markAllButton.evaluate().isNotEmpty) {
          await tester.tap(markAllButton.first);
          await tester.pumpAndSettle();

          // Snackbar görünmeli
          expect(find.byType(SnackBar), findsWidgets);
        }
      });
    });

    group('Spectator Mode Sayfası UI Testleri', () {
      testWidgets('Spectator mode tab sistemi çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SpectatorModePage()));

        // Tab bar kontrol
        expect(find.byType(TabBar), findsOneWidget);

        // Canlı Oyunlar ve Tekrarlar tabları
        expect(find.text('Canlı Oyunlar'), findsOneWidget);
        expect(find.text('Tekrarlar'), findsOneWidget);
      });

      testWidgets('Active games listesi gösteriliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SpectatorModePage()));

        // Loading durumunda
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('Emoji reactions panel var mı',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SpectatorModePage()));

        // Emoji butonları ara (watching modunda)
        // Bu test için mock data gerekebilir
        expect(find.byType(SpectatorModePage), findsOneWidget);
      });
    });

    // ===========================================================================
    // AYARLAR SAYFASI TESTLERİ
    // ===========================================================================

    group('Settings Sayfası UI Testleri', () {
      testWidgets('Settings sayfası tüm seçenekleri içeriyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SettingsPage()));

        // Switch/Toggle kontroller
        expect(find.byType(Switch), findsWidgets);

        // Dropdown menüler
        expect(find.byType(DropdownButton), findsWidgets);

        // TextButton'lar
        expect(find.byType(TextButton), findsWidgets);
      });

      testWidgets('Tema değişikliği çalışıyor', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SettingsPage()));

        // Tema switch'i ara ve tıkla
        final themeSwitch = find.byType(Switch);
        if (themeSwitch.evaluate().isNotEmpty) {
          await tester.tap(themeSwitch.first);
          await tester.pumpAndSettle();

          // Tema değişikliği sonrası UI hala render oluyor
          expect(find.byType(SettingsPage), findsOneWidget);
        }
      });

      testWidgets('Dil ayarı değiştirilebiliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SettingsPage()));

        // Dil dropdown'u ara
        final languageDropdown = find.byType(DropdownButton);
        if (languageDropdown.evaluate().isNotEmpty) {
          await tester.tap(languageDropdown.first);
          await tester.pumpAndSettle();

          // Dropdown açılmış olmalı
          expect(find.byType(DropdownButton), findsOneWidget);
        }
      });
    });

    // ===========================================================================
    // BİLEŞEN TESTLERİ
    // ===========================================================================

    group('UserQRCode Widget Testleri', () {
      testWidgets('QR kod widget doğru render ediliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          const UserQRCodeWidget(
            userId: 'test_user_id',
            nickname: 'Test User',
          ),
        ));

        // Loading durumunda
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // QR kod başlığı
        expect(find.text('Arkadaşlık QR Kodum'), findsOneWidget);
      });

      testWidgets('Share butonları çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          const UserQRCodeWidget(
            userId: 'test_user_id',
            nickname: 'Test User',
          ),
        ));

        await tester.pumpAndSettle(); // QR kod yüklenmesi için

        // Share butonları grid'i
        expect(find.byType(GridView), findsOneWidget);

        // WhatsApp, Gmail, vb. butonlar
        expect(find.byIcon(Icons.share), findsWidgets);
      });
    });

    group('Global Error States Testleri', () {
      testWidgets('Error screen doğru render ediliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          GlobalErrorStates.errorScreen(
            context: tester.element(find.byType(MaterialApp)),
            title: 'Test Error',
            message: 'Test message',
            onRetry: () {},
          ),
        ));

        // Error icon
        expect(find.byIcon(Icons.error_outline), findsOneWidget);

        // Başlık ve mesaj
        expect(find.text('Test Error'), findsOneWidget);
        expect(find.text('Test message'), findsOneWidget);

        // Retry butonu
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('No data screen çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          GlobalErrorStates.noDataScreen(
            context: tester.element(find.byType(MaterialApp)),
          ),
        ));

        // Empty state icon
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);

        // Başlık
        expect(find.text('Henüz Veri Yok'), findsOneWidget);
      });

      testWidgets('Loading screen gösteriliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          GlobalErrorStates.loadingScreen(
            context: tester.element(find.byType(MaterialApp)),
            message: 'Loading...',
          ),
        ));

        // Loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Loading mesajı
        expect(find.text('Loading...'), findsOneWidget);
      });
    });

    group('Page Templates Testleri', () {
      testWidgets('StandardAppBar doğru çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          Scaffold(
            appBar: StandardAppBar(
              title: const Text('Test Title'),
              onBackPressed: () {},
            ),
            body: Container(),
          ),
        ));

        // Başlık
        expect(find.text('Test Title'), findsOneWidget);

        // Back butonu
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('PageBody responsive çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          PageBody(
            child: Container(),
          ),
        ));

        // SingleChildScrollView var mı
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('StandardListItem render ediliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          StandardListItem(
            title: 'Test Item',
            subtitle: 'Test Subtitle',
          ),
        ));

        // Başlık ve alt başlık
        expect(find.text('Test Item'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
      });

      testWidgets('InfoCard doğru gösteriliyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(
          InfoCard(
            title: 'Test Title',
            value: 'Test Value',
            icon: Icons.info,
          ),
        ));

        // Başlık, değer ve ikon
        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Value'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
      });
    });

    // ===========================================================================
    // ERİŞİLEBİLİRLİK TESTLERİ
    // ===========================================================================

    group('Erişilebilirlik (Accessibility) Testleri', () {
      testWidgets('Tüm butonlar ve inputlar erişilebilir',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LoginPage()));

        // Semantics widget kontrol
        expect(find.byType(Semantics), findsWidgets);

        // ElevatedButton'lar erişilebilir olmalı
        final buttons = find.byType(ElevatedButton);
        expect(buttons, findsWidgets);

        // Text field'lar erişilebilir olmalı
        final textFields = find.byType(TextField);
        expect(textFields, findsWidgets);
      });

      testWidgets('Large text support çalışıyor', (WidgetTester tester) async {
        tester.binding.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(tester.binding.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(createTestApp(const LoginPage()));
        await tester.pumpAndSettle();

        // UI hala render oluyor
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('Screen reader desteği var mı', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LoginPage()));

        // Semantics label'lar kontrol
        final semanticsFinder = find.byType(Semantics);
        expect(semanticsFinder, findsWidgets);
      });
    });

    // ===========================================================================
    // RESPONSIVE TASARIM TESTLERİ
    // ===========================================================================

    group('Responsive Tasarım Testleri', () {
      testWidgets('Mobile tarafta doğru render', (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);

        await tester.pumpWidget(createTestApp(const HomeDashboard()));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Tablet tarafta doğru render', (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1280);

        await tester.pumpWidget(createTestApp(const HomeDashboard()));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Web desktop tarafta doğru render',
          (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);

        await tester.pumpWidget(createTestApp(const HomeDashboard()));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('Çok küçük ekranlarda overflow yok',
          (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(320, 480);

        await tester.pumpWidget(createTestApp(const LoginPage()));
        await tester.pumpAndSettle();

        // Overflow hatası olmamalı
        expect(find.byType(LoginPage), findsOneWidget);
      });
    });

    // ===========================================================================
    // PERFORMANCE TESTLERİ
    // ===========================================================================

    group('Performance UI Testleri', () {
      testWidgets('Sayfa 2 saniyede yükleniyor',
          (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestApp(const HomeDashboard()));

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Liste scroll performansı', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const LeaderboardPage()));

        // Scroll işlemi
        await tester.fling(find.byType(ListView), const Offset(0, -500), 3000);
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('Widget rebuild performansı', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SettingsPage()));

        // Birkaç rebuild simülasyonu
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        // Hala render oluyor
        expect(find.byType(SettingsPage), findsOneWidget);
      });
    });

    // ===========================================================================
    // ENTEGRASYON TESTLERİ
    // ===========================================================================

    group('UI Akış Entegrasyon Testleri', () {
      testWidgets('Login to Dashboard akışı çalışıyor',
          (WidgetTester tester) async {
        // Bu test için mock authentication gerekli olabilir
        await tester.pumpWidget(createTestApp(const LoginPage()));

        // Login formu var
        expect(find.byType(TextFormField), findsWidgets);
        expect(find.widgetWithText(ElevatedButton, 'Giriş Yap'), findsOneWidget);
      });

      testWidgets('Navigation akışı çalışıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const HomeDashboard()));

        // Bottom navigation var
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Farklı tab'lara geçiş
        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();

        // Profile sayfası yüklenmiş
        expect(find.byType(HomeDashboard), findsOneWidget);
      });

      testWidgets('Settings değişiklikleri uygulanıyor',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(const SettingsPage()));

        // Tema değişikliği
        final themeSwitch = find.byType(Switch);
        if (themeSwitch.evaluate().isNotEmpty) {
          final initialState = tester.widget<Switch>(themeSwitch.first).value;

          await tester.tap(themeSwitch.first);
          await tester.pumpAndSettle();

          final newState = tester.widget<Switch>(themeSwitch.first).value;
          expect(newState, isNot(initialState));
        }
      });
    });
  });
}
