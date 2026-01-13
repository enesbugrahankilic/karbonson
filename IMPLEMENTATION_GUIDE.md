# Karbonson Yeni Navigasyon Sistemi - Implementasyon Kılavuzu

## 📦 Yeni Dosyalar

### 1. **Navigasyon Dosyaları**
- `lib/core/navigation/improved_app_router.dart` - Yeni router sistemi
- `lib/core/navigation/improved_navigation_service.dart` - Yeni navigation servisi

### 2. **UI Widget Dosyaları**
- `lib/widgets/ui_friendly_base_page.dart` - UI dostu sayfa şablonu
- `lib/widgets/ui_friendly_dialogs.dart` - UI dostu dialog/modal bileşenleri

### 3. **Dokümantasyon**
- `NAVIGATION_FLOW_DESIGN.md` - Tam navigasyon akış tasarımı

---

## 🚀 Hızlı Başlangıç

### Adım 1: main.dart'ı Güncelle

```dart
// main.dart
import 'core/navigation/improved_app_router.dart';
import 'core/navigation/improved_navigation_service.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize navigation service
    _initializeNavigation();
    
    runApp(const MyApp());
  }, (error, stack) {
    // Handle errors
  });
}

void _initializeNavigation() {
  // Navigation service will be initialized in MaterialApp
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigationService = ImprovedNavigationService();

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  void _setupNavigation() {
    // Initialize guards and listeners
    final authGuard = AuthenticationGuard(
      () async => await _authService.isAuthenticated(),
    );

    final twoFactorGuard = TwoFactorAuthGuard(
      is2FARequired: () async => await _authService.is2FARequired(),
      is2FACompleted: () async => await _authService.is2FACompleted(),
    );

    _navigationService.initialize(
      authGuard: authGuard,
      twoFactorGuard: twoFactorGuard,
    );

    // Add analytics listener
    _navigationService.addListener((event) {
      if (kDebugMode) {
        print('Navigation Event: $event');
      }
      // Send to analytics service
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karbonson',
      theme: // Your theme,
      navigatorKey: _navigationService.navigatorKey,
      onGenerateRoute: ImprovedAppRouter.generateRoute,
      initialRoute: '/auth/login',
      home: const HomePage(),
    );
  }
}
```

### Adım 2: Sayfaları UIFriendlyBasePage Kullan

```dart
// Eski yol
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sayfam')),
      body: const Center(child: Text('İçerik')),
    );
  }
}

// Yeni yol
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UIFriendlyBasePage(
      title: 'Sayfam',
      pageType: PageType.main,
      body: const Center(child: Text('İçerik')),
    );
  }
}
```

### Adım 3: Navigasyon Kullan

```dart
// Yeni rota sabitlerini kullan
Navigator.of(context).pushNamed(AppRoutesV2.appQuiz);

// Veya ImprovedNavigationService kullan
final navService = ImprovedNavigationService();
await navService.pushNamed(AppRoutesV2.appQuiz);

// Extension ile kolay kullanım
Navigator.of(context).toAppRoute('quiz');
```

### Adım 4: Dialog Kullan

```dart
// Alert
await FriendlyAlertDialog.show(
  context: context,
  title: 'Onay',
  message: 'Devam etmek istiyor musunuz?',
  positiveButtonText: 'Evet',
  negativeButtonText: 'Hayır',
  onPositivePressed: () {
    // Handle action
  },
);

// Loading
LoadingDialog.show(context, message: 'Yükleniyor...');
// ... do async work
Navigator.pop(context);

// Snackbar
FriendlySnackBar.success(context, message: 'İşlem başarılı!');
```

---

## 📖 Rota Hiyerarşisi

### Authentication Routes
```
/auth/login              - Giriş sayfası
/auth/register          - Kayıt sayfası
/auth/email-verify      - E-posta doğrulama
/auth/forgot-password   - Şifremi unuttum
/auth/2fa-setup        - 2FA kurulumu
/auth/2fa-verify       - 2FA doğrulama
/auth/tutorial         - Öğretici
```

### App Routes
```
/app/home                  - Ana sayfa
/app/quiz                 - Quiz sayfası
/app/daily-challenge      - Günlük zorluk
/app/ai-recommendations  - AI önerileri
/app/board-game         - Tahta oyunu
/app/duel               - İkili oyun
/app/duel-invite        - İkili davet
/app/friends            - Arkadaşlar sayfası
/app/leaderboard        - Sıralamalar
/app/multiplayer-lobby  - Multiplayer lobby
/app/room-management    - Oda yönetimi
```

### User Routes
```
/user/profile       - Profil sayfası
/user/settings      - Ayarlar sayfası
/user/achievements  - Başarılar sayfası
```

---

## 🛡️ Navigation Guards

Guards otomatik olarak aşağıdaki koşulları kontrol eder:

### AuthenticationGuard
- Kullanıcı giriş yapmış mı?
- `/app` ve `/user` rotalarına erişim korumalı
- Giriş yapılmamışsa `/auth/login`'e yönlendir

### TwoFactorAuthGuard
- 2FA aktif mi?
- 2FA kuruluysa `/app` rotalarına gitmeden önce doğrula
- Doğrulanmamışsa `/auth/2fa-verify`'e yönlendir

```dart
// Guards otomatik çalışır
navService.pushNamed(AppRoutesV2.appHome)
  // Eğer giriş yapılmamışsa otomatik /auth/login'e gönderilir
  // Eğer 2FA gerekiyorsa otomatik /auth/2fa-verify'e gönderilir
```

---

## 📊 Navigation Analytics

Navigation hareketlerini izle:

```dart
final analytics = navService.getAnalytics();

print('Toplam navigasyon: ${analytics.totalNavigations}');
print('Şu anki rota: ${analytics.currentRoute}');
print('En sık kullanılan: ${analytics.mostFrequentRoute}');
print('Ortalama süre: ${analytics.averageTimePerRoute}');

// Tüm history'i göster
for (final event in analytics.history) {
  print('${event.fromRoute} -> ${event.toRoute} [${event.type}]');
}
```

---

## 🎨 UI Dostu Sayfalar

### Farklı Sayfa Türleri

```dart
// Auth sayfası
UIFriendlyBasePage(
  pageType: PageType.auth,
  title: 'Giriş Yap',
  body: /* form */,
)

// Main app sayfası
UIFriendlyBasePage(
  pageType: PageType.main,
  title: 'Ana Sayfa',
  body: /* content */,
)

// Modal sayfası
UIFriendlyBasePage(
  pageType: PageType.modal,
  title: 'Seçim Yap',
  body: /* modal content */,
)

// Detail sayfası
UIFriendlyBasePage(
  pageType: PageType.detail,
  title: 'Detay',
  body: /* detail content */,
)
```

### Loading Sayfası

```dart
// Sınıf olarak
return LoadingPage(
  message: 'Veriler yükleniyor...',
  color: Colors.blue,
);

// Dialog olarak
LoadingDialog.show(context, message: 'Veriler yükleniyor...');
```

### Error Sayfası

```dart
return ErrorPage(
  title: 'Hata Oluştu',
  message: 'Lütfen daha sonra tekrar deneyin.',
  buttonText: 'Tekrar Dene',
  icon: Icons.error,
  onRetry: () {
    // Retry logic
  },
);
```

### Empty Sayfası

```dart
return EmptyPage(
  title: 'Quiz Yok',
  message: 'Henüz quiz oluşturulmamış.',
  icon: Icons.quiz,
  actionText: 'Yeni Quiz Ekle',
  onAction: () {
    // Add quiz
  },
);
```

---

## 💬 Dialog Örnekleri

### Alert Dialog
```dart
await FriendlyAlertDialog.show(
  context: context,
  title: 'Çıkış Yap',
  message: 'Uygulamadan çıkmak istiyor musunuz?',
  icon: Icons.logout,
  positiveButtonText: 'Çıkış Yap',
  negativeButtonText: 'İptal',
  onPositivePressed: () => navService.goLogin(),
);
```

### Custom Dialog
```dart
await FriendlyCustomDialog.show(
  context: context,
  title: 'Ayarlar',
  content: const Text('Ayarlar burada gösterilecek'),
  buttons: [
    DialogButton(
      label: 'İptal',
      onPressed: () => Navigator.pop(context),
    ),
    DialogButton(
      label: 'Kaydet',
      onPressed: () => Navigator.pop(context),
      isPrimary: true,
    ),
  ],
);
```

### Bottom Sheet
```dart
await FriendlyBottomSheet.show(
  context: context,
  title: 'Seçim Yap',
  content: const Text('Seçenekler burada'),
  buttons: [
    DialogButton(
      label: 'Seçenek 1',
      onPressed: () => Navigator.pop(context, 1),
      isPrimary: true,
    ),
  ],
);
```

### Confirmation
```dart
final confirmed = await ConfirmationDialog.show(
  context: context,
  title: 'Profili Sil',
  message: 'Profilinizi silmek istediğinizden emin misiniz?',
  isDestructive: true,
);

if (confirmed) {
  // Delete profile
}
```

### SnackBar
```dart
// Success
FriendlySnackBar.success(context, message: 'Kaydedildi!');

// Error
FriendlySnackBar.error(context, message: 'Bir hata oluştu!');

// Warning
FriendlySnackBar.warning(context, message: 'Dikkat!');

// Info
FriendlySnackBar.info(context, message: 'Bilgi');
```

---

## 🔄 Migration Kılavuzu

### Eski AppRouter → Yeni ImprovedAppRouter

```dart
// Eski
Navigator.pushNamed(context, AppRoutes.home);

// Yeni (kurulu switch-case ile)
Navigator.pushNamed(context, AppRoutesV2.appHome);

// Hatta daha kolay
Navigator.of(context).toAppRoute('home');
```

### Eski Scaffold → Yeni UIFriendlyBasePage

```dart
// Eski
Scaffold(
  appBar: AppBar(title: Text('Sayfa')),
  body: SingleChildScrollView(child: content),
)

// Yeni
UIFriendlyBasePage(
  title: 'Sayfa',
  body: content,
  // Scrollable zaten true
)
```

---

## 🧪 Testing

### Navigation Tests

```dart
testWidgets('Navigation to quiz requires authentication', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Try to navigate to quiz (should be blocked)
  expect(
    () => navService.pushNamed(AppRoutesV2.appQuiz),
    throwsException,
  );
});

testWidgets('2FA verification redirects correctly', (tester) async {
  // Setup: User is authenticated but needs 2FA
  await tester.pumpWidget(const MyApp());
  
  // Navigate to home (should redirect to 2FA)
  await tester.tap(find.byIcon(Icons.home));
  await tester.pumpAndSettle();
  
  expect(find.byType(Comprehensive2FAVerificationPage), findsOneWidget);
});
```

---

## 📈 Performance Tips

1. **Lazy Loading**: Sayfaları lazy load et
2. **Memory Management**: Dispose anim asyonları doğru
3. **Build Optimization**: const widgetleri kullan
4. **Navigation History**: Gerekli yerde history'i temizle

```dart
// Memory leak önlemek için
_navigationService.clearHistory(); // Logout da çağır
```

---

## 🐛 Debugging

```dart
// Navigation hareketlerini izle
_navigationService.addListener((event) {
  debugPrint('Event: $event');
});

// Current route'u kontrol et
print(_navigationService.currentRoute);

// Navigation stack'i göster
print(_navigationService.getNavigationStack());

// Analytics al
final analytics = _navigationService.getAnalytics();
print(analytics);
```

---

## ✅ Checklist

- [ ] Yeni routing sistemini main.dart'a entegre et
- [ ] Tüm sayfaları UIFriendlyBasePage'e migrate et
- [ ] Navigation guards'ı test et
- [ ] Analytics listener'ı setup et
- [ ] Deep linking'i güncelle
- [ ] Dialog'ları yeni sistemle değiştir
- [ ] SnackBar'ları yeni sistemle değiştir
- [ ] Unit tests yaz
- [ ] Integration tests yaz
- [ ] Performance test et
- [ ] Production'a deploy et

---

## 📞 Destek

Sorunlar için:
1. Navigation logs'u kontrol et
2. Guard kontrol et
3. Route adını kontrol et
4. Tests çalıştır
5. Debug konsol'u kontrol et

