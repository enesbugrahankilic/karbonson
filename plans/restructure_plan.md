# Navigasyon Yeniden Yapılandırma Planı

## Genel Yaklaşım
Mevcut AppRouter yapısını koruyarak, diyagram gereksinimlerine uygun şekilde genişleteceğiz. Eksik sayfalar için placeholder'lar oluşturarak navigasyon akışını test edilebilir hale getireceğiz.

## Aşama 1: Mevcut Router Güncellemeleri

### 1.1 Eksik Rotaları AppRoutes'a Ekle
```dart
class AppRoutes {
  // ... mevcut rotalar

  // Quiz sistemi
  static const String quizSettings = '/quiz-settings';
  static const String quizResults = '/quiz-results';

  // Düello sistemi
  static const String duelLobby = '/duel-lobby';
  static const String duelCreateRoom = '/duel-create-room';
  static const String duelWaiting = '/duel-waiting';
  static const String duelResults = '/duel-results';

  // Çok oyunculu sistem
  static const String multiplayerCreateRoom = '/multiplayer-create-room';
  static const String multiplayerWaiting = '/multiplayer-waiting';
  static const String multiplayerResults = '/multiplayer-results';

  // Günlük görevler
  static const String dailyTasks = '/daily-tasks';
  static const String taskDetail = '/task-detail';
  static const String rewardClaim = '/reward-claim';

  // Ödüller sistemi
  static const String rewardsMain = '/rewards-main';
  static const String ownedRewards = '/owned-rewards';
  static const String lootBoxOpen = '/loot-box-open';
  static const String lootBoxAnimation = '/loot-box-animation';
  static const String rewardReveal = '/reward-reveal';
  static const String inventory = '/inventory';

  // Başarımlar
  static const String achievementDetail = '/achievement-detail';
  static const String achievementProgress = '/achievement-progress';

  // Liderlik
  static const String myRank = '/my-rank';
  static const String globalRanking = '/global-ranking';

  // Arkadaşlar
  static const String qrScan = '/qr-scan';
  static const String myQr = '/my-qr';
  static const String qrShare = '/qr-share';

  // Bildirimler
  static const String notificationDetail = '/notification-detail';

  // Profil
  static const String userInfo = '/user-info';
  static const String profileEdit = '/profile-edit';

  // Ayarlar
  static const String notificationSettings = '/notification-settings';

  // Genel durumlar
  static const String errorState = '/error-state';
  static const String emptyState = '/empty-state';
  static const String offline = '/offline';
  static const String confirmExit = '/confirm-exit';
}
```

### 1.2 GenerateRoute Fonksiyonunu Genişlet
Mevcut switch case'e yeni rotalar ekle, placeholder sayfalarla:

```dart
case AppRoutes.quizSettings:
  return _createRoute(QuizSettingsPage());
case AppRoutes.quizResults:
  return _createRoute(QuizResultsPage(quizResult: settings.arguments));
// ... diğerleri
```

## Aşama 2: Sayfa Organizasyonu

### 2.1 Klasör Yapısı
```
lib/pages/
├── auth/           # Kimlik doğrulama
├── game/           # Oyun sayfaları
│   ├── quiz/
│   ├── duel/
│   └── multiplayer/
├── social/         # Sosyal özellikler
├── rewards/        # Ödül sistemi
├── profile/        # Profil yönetimi
├── settings/       # Ayarlar
└── common/         # Genel sayfalar (error, empty, loading)
```

### 2.2 Sayfa İsimlendirme Standartları
- Ana sayfalar: `{Feature}Page` (ör: `QuizSettingsPage`)
- Alt sayfalar: `{Feature}{SubFeature}Page` (ör: `QuizResultsPage`)
- Durum sayfaları: `{State}Page` (ör: `ErrorPage`)

## Aşama 3: Navigasyon Akışı Güncellemeleri

### 3.1 Home Dashboard'dan Geçişler
Mevcut HomeDashboard'u güncelleyerek diyagramdaki tüm geçişleri ekle:

```dart
// Quiz geçişi
Navigator.pushNamed(context, AppRoutes.quizSettings);

// Düello geçişi
Navigator.pushNamed(context, AppRoutes.duelLobby);

// Diğer modüller için benzer şekilde
```

### 3.2 Geri Navigasyon Standartları
- Tüm sayfalarda tutarlı geri tuşu davranışı
- Oyun sırasında çıkış onayı dialog'u
- Derin link desteği

## Aşama 4: Placeholder Sayfa Şablonu

Tüm eksik sayfalar için temel şablon:

```dart
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const PlaceholderPage({
    super.key,
    required this.title,
    this.description = 'Bu sayfa henüz geliştirilmektedir.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Aşama 5: Test ve Doğrulama

### 5.1 Navigasyon Testi
- Tüm rotaların erişilebilir olduğunu doğrula
- Geri navigasyonun çalıştığını test et
- Derin linklerin çalıştığını kontrol et

### 5.2 Akış Testi
- Ana akışları (quiz, düello, multiplayer) test et
- Hata durumlarını simüle et
- Offline senaryolarını test et

## Uygulama Sırası
1. AppRoutes güncellemesi
2. Placeholder sayfalar oluşturma
3. Router güncellemesi
4. Home dashboard güncellemeleri
5. Test ve doğrulama