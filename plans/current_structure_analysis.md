# Mevcut Proje Yapısı Analizi

## Genel Bakış
Flutter uygulaması, Firebase ile entegre edilmiş, çok oyunculu quiz ve düello özelliklerine sahip bir oyun uygulamasıdır. Navigasyon AppRouter sınıfı ile yönetilmektedir.

## Mevcut Sayfalar ve Rotalar

### Kimlik Doğrulama Sayfaları
- `/login` → `LoginPage` - Kullanıcı girişi
- `/register` → `RegisterPage` - Kullanıcı kaydı
- `/register-refactored` → `RegisterPageRefactored` - Refaktör edilmiş kayıt sayfası
- `/email-verification` → `EmailVerificationPage` - E-posta doğrulama
- `/forgot-password` → `ForgotPasswordPage` - Şifre sıfırlama
- `/forgot-password-enhanced` → `ForgotPasswordPageEnhanced` - Gelişmiş şifre sıfırlama
- `/tutorial` → `TutorialPage` - Uygulama eğitimi

### İki Faktörlü Doğrulama Sayfaları
- `/2fa-setup` → `TwoFactorAuthSetupPage`
- `/2fa-verification` → `TwoFactorAuthVerificationPage`
- `/enhanced-2fa-setup` → `EnhancedTwoFactorAuthSetupPage`
- `/enhanced-2fa-verification` → `EnhancedTwoFactorAuthVerificationPage`
- `/comprehensive-2fa-setup` → `ComprehensiveTwoFactorAuthSetupPage`
- `/comprehensive-2fa-verification` → `Comprehensive2FAVerificationPage`
- `/2fa-page` → `TwoFactorAuthPage`
- `/email-otp-verification` → `EmailOtpVerificationPage`
- `/email-verification-redirect` → `EmailVerificationRedirectPage`

### Ana Uygulama Sayfaları
- `/home` → `HomeDashboard` - Ana dashboard
- `/profile` → `ProfilePage` - Kullanıcı profili
- `/quiz` → `QuizPage` - Quiz oyunu
- `/leaderboard` → `LeaderboardPage` - Liderlik tablosu
- `/friends` → `FriendsPage` - Arkadaşlar
- `/multiplayer-lobby` → `MultiplayerLobbyPage` - Çok oyunculu lobisi
- `/duel` → `DuelPage` - Düello oyunu
- `/duel-invitation` → `DuelInvitationPage` - Düello daveti
- `/room-management` → `RoomManagementPage` - Oda yönetimi
- `/settings` → `SettingsPage` - Ayarlar
- `/ai-recommendations` → `AIRecommendationsPage` - AI önerileri
- `/achievement` → `AchievementPage` - Başarımlar
- `/achievements-gallery` → `AchievementsGalleryPage` - Başarımlar galerisi
- `/daily-challenge` → `DailyChallengePage` - Günlük challenge
- `/rewards-shop` → `RewardsShopPage` - Ödül mağazası
- `/won-boxes` → `WonBoxesPage` - Kazanılan kutular
- `/notifications` → `NotificationsPage` - Bildirimler
- `/how-to-play` → `HowToPlayPage` - Nasıl oynanır
- `/spectator-mode` → `SpectatorModePage` - Seyirci modu

### Tanımlanmamış Sayfalar (Router'da Yok)
- `QuizSettingsPage` - Quiz ayarları (pages/quiz_settings_page.dart)
- `HomeDashboardOptimized` - Optimize edilmiş dashboard (pages/home_dashboard_optimized.dart)

## Mevcut Navigasyon Akışı
- Uygulama başlangıçta token kontrolü yapar
- Geçerli token varsa `/home`'a, yoksa `/login`'e yönlendirir
- Ana sayfa (`/home`) diğer tüm modüllere geçiş sağlar
- Bazı rotalar korumalıdır (authentication gerektirir)

## Teknik Altyapı
- **Router**: `AppRouter.generateRoute()` ile rota yönetimi
- **Navigation**: `NavigationService` ile merkezi navigasyon
- **Authentication**: `AuthenticationStateService` ile durum yönetimi
- **State Management**: Provider ve Bloc pattern kullanımı
- **Localization**: Flutter'in localization sistemi