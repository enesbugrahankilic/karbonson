# Navigation Akışı Yeniden Düzenleme Planı

## Mevcut Durum
- **Toplam Sayfa:** 55+ page sınıfı
- **Mevcut Router:** app_router.dart ve improved_app_router.dart
- **Eksik/Sıra Dışı Sayfalar:** RewardsShopPage, password_change_page, new_password_page, uid_debug_page

## Önerilen Yeni Yapı

### Kategori 1: Authentication Routes (/auth/)
- `/auth/login` → LoginPage
- `/auth/register` → RegisterPageRefactored
- `/auth/tutorial` → TutorialPage
- `/auth/forgot-password` → ForgotPasswordPageEnhanced
- `/auth/email-verification` → EmailVerificationPage
- `/auth/email-otp` → EmailOtpVerificationPage
- `/auth/password-reset-info` → EmailVerificationAndPasswordResetInfoPage
- `/auth/spam-safe-password-reset` → SpamSafePasswordResetPage
- `/auth/2fa-setup` → ComprehensiveTwoFactorAuthSetupPage
- `/auth/2fa-verify` → Comprehensive2FAVerificationPage
- `/auth/2fa-enhanced-setup` → EnhancedTwoFactorAuthSetupPage
- `/auth/2fa-enhanced-verify` → EnhancedTwoFactorAuthVerificationPage
- `/auth/email-verification-redirect` → EmailVerificationRedirectPage
- `/auth/enhanced-email-verification-redirect` → EnhancedEmailVerificationRedirectPage

### Kategori 2: Main App Routes (/app/)
- `/app/home` → HomeDashboard (ANA SAYFA)
- `/app/quiz` → QuizPage
- `/app/board-game` → BoardGamePage
- `/app/duel` → DuelPage
- `/app/duel/invite` → DuelInvitationPage
- `/app/multiplayer/lobby` → MultiplayerLobbyPage
- `/app/multiplayer/room` → RoomManagementPage
- `/app/friends` → FriendsPage
- `/app/leaderboard` → LeaderboardPage
- `/app/daily-challenge` → DailyChallengePage
- `/app/achievements` → AchievementsGalleryPage
- `/app/achievement` → AchievementPage
- `/app/ai-recommendations` → AIRecommendationsPage
- `/app/rewards-shop` → RewardsShopPage
- `/app/how-to-play` → HowToPlayPage
- `/app/profile` → ProfilePage

### Kategori 3: User Routes (/user/)
- `/user/settings` → SettingsPage
- `/user/password-change` → PasswordChangePage
- `/user/new-password` → NewPasswordPage

### Kategori 4: Debug Routes (/debug/) - Sadece Debug Mode
- `/debug/uid` → UidDebugPage

## Bottom Navigation Yapısı
Ana sekmeler:
1. **Ana Sayfa** (/app/home) - HomeDashboard
2. **Quiz** (/app/quiz) - QuizPage
3. **Düello** (/app/duel) - DuelPage
4. **Liderlik** (/app/leaderboard) - LeaderboardPage
5. **Profil** (/app/profile) - ProfilePage

## Ek Menü Öğeleri
- Arkadaşlar → /app/friends
- Günlük Görev → /app/daily-challenge
- Başarılar → /app/achievements
- Ödül Mağazası → /app/rewards-shop
- Nasıl Oynanır → /app/how-to-play
- Ayarlar → /user/settings

## Uygulama Adımları

### Adım 1: Comprehensive App Router Oluştur
- Yeni `app_router_complete.dart` dosyası oluştur
- Tüm route'ları kategorize et
- Authentication guard'ları entegre et

### Adım 2: Bottom Navigation Güncelle
- Ana sekmeleri tanımla
- Quick access menüsünü güncelle
- Dynamic badge desteği ekle

### Adım 3: Home Dashboard Entegrasyonu
- Tüm sayfalara erişim linkleri ekle
- Quick access menüsünü güncelle
- Navigation drawer'ı güncelle

### Adım 4: Route Constants Güncelle
- AppRoutes sınıfını güncelle
- Legacy route desteğini koru
- Route grouping ekle

## Dosyalar
- `lib/core/navigation/app_router_complete.dart` - Yeni comprehensive router
- `lib/core/navigation/bottom_navigation.dart` - Güncellenmiş bottom nav
- `lib/main.dart` - Router entegrasyonu
- `lib/pages/*_page.dart` - Page import'ları

