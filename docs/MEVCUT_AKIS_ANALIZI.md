# Karbonson Uygulaması - Mevcut Akış Analizi

## 📊 Genel Bakış

Bu doküman, Karbonson Flutter uygulamasının mevcut akış yapısını detaylı olarak analiz etmektedir.

---

## 🔄 Genel Uygulama Akışı

```
┌─────────────────────────────────────────────────────────────────────┐
│                    UYGULAMA BAŞLANGICI                              │
└─────────────────────────────────────────────────────────────────────┘
                              ↓
              ┌───────────────────────────────┐
              │   AppRoot (main.dart)         │
              │   - Firebase init             │
              │   - Auth state restore        │
              │   - Deep linking init         │
              │   - Services init             │
              └───────────────────────────────┘
                              ↓
              ┌───────────────────────────────┐
              │   Karbon2App                  │
              │   - Theme/Language setup      │
              │   - Route config              │
              └───────────────────────────────┘
                              ↓
         ┌────────────────────┴────────────────────┐
         ↓                                         ↓
   [Oturum Açık?]                            [Oturum Yok]
         ↓                                         ↓
   /home (HomeDashboard)                   /login (LoginPage)
         ↓                                         ↓
                                              ├─→ /register
                                              ├─→ /forgot-password
                                              └─→ 2FA flow
                                                      ↓
                                              [Doğrulama Başarılı]
                                                      ↓
                                              /tutorial (First time)
                                                      ↓
                                              /home (HomeDashboard)
```

---

## 📁 Proje Yapısı Analizi

### Sayfa Kategorileri

| Kategori | Sayfa Sayısı | Durum |
|----------|--------------|-------|
| Kimlik Doğrulama (Auth) | 8 | ✅ Oluşturuldu |
| Quiz Modülü | 6 | ✅ Oluşturuldu |
| Düello/Multiplayer | 5 | ✅ Oluşturuldu |
| Sosyal | 4 | ✅ Oluşturuldu |
| Kullanıcı Profili | 3 | ✅ Oluşturuldu |
| Ödüller/Shop | 4 | ✅ Oluşturuldu |
| Yardım/Diğer | 2 | ✅ Oluşturuldu |
| **TOPLAM** | **37** | **✅ 100%** |

### Mevcut Route Sayısı: 50+

---

## 🏠 Ana Sayfa (HomeDashboard) Merkezli Akış

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HOME DASHBOARD (Merkezi Hub)                     │
└─────────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────┬─────────┬─┴─────────┬──────────┬───────────────┐
        ↓         ↓         ↓           ↓          ↓               ↓
   ┌────────┐ ┌────────┐ ┌────────┐ ┌─────────┐ ┌───────────┐ ┌──────────┐
   │  Quiz  │ │  Duel  │ │Friends │ │Leader-  │ │Profile    │ │ Settings │
   │  🎮    │ │   ⚔️   │ │   👥   │ │ board🏆 │ │    👤     │ │    ⚙️    │
   └────────┘ └────────┘ └────────┘ └─────────┘ └───────────┘ └──────────┘
        │         │         │           │          │               │
        ↓         ↓         ↓           ↓          ↓               ↓
   QuizPage  DuelPage  FriendsPage  Leader-    ProfilePage    SettingsPage
   Settings   Lobby    Requests    boardPage
   Results    Invite   Add Friend  Achievements
   DailyCh.   RoomMgmt  Invitations
        │         │         │           │          │               │
        └─────────┴─────────┴───────────┴──────────┴───────────────┘
                                    │
                            ┌───────┴───────┐
                            ↓               ↓
                     ┌────────────┐  ┌────────────┐
                     │ Rewards 🛒  │  │Notif-      │
                     │   Shop     │  │ ications🔔 │
                     │ Won Boxes  │  │            │
                     └────────────┘  └────────────┘
```

---

## 🔐 Kimlik Doğrulama Akışı

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                              │
└─────────────────────────────────────────────────────────────────────┘

LOGIN PAGE (/login)
     │
     ├─→ Email/Şifre girişi
     │
     ├─→ [Şifremi Unuttum] → /forgot-password-enhanced
     │        │
     │        └─→ Email link → /password-reset-information
     │
     ├─→ [Kayıt Ol] → /register-refactored
     │        │
     │        └─→ Email doğrulama → EmailVerificationPage
     │                  │
     │                  └─→ /tutorial (First time only)
     │
     └─→ [2FA Gerekli mi?]
               │
               ├─→ Hayır → /home
               │
               └─→ Evet → 2FA Verification
                         │
                         ├─→ /2fa-verification (Basic)
                         ├─→ /enhanced-2fa-verification
                         └─→ /comprehensive-2fa-verification
                                   │
                                   └─→ /home
```

### Auth Route'ları

| Route | Sayfa | Açıklama |
|-------|-------|----------|
| `/login` | LoginPage | Ana giriş sayfası |
| `/register` | RegisterPage | Eski kayıt sayfası |
| `/register-refactored` | RegisterPageRefactored | Yeni kayıt sayfası |
| `/email-verification` | EmailVerificationPage | E-posta doğrulama |
| `/forgot-password` | ForgotPasswordPage | Eski şifre sıfırlama |
| `/forgot-password-enhanced` | ForgotPasswordPageEnhanced | Gelişmiş şifre sıfırlama |
| `/2fa-setup` | TwoFactorAuthSetupPage | 2FA kurulumu |
| `/2fa-verification` | TwoFactorAuthVerificationPage | 2FA doğrulama |
| `/tutorial` | TutorialPage | Uygulama tanıtımı |

---

## 🎮 Quiz Akışı

```
┌─────────────────────────────────────────────────────────────────────┐
│                         QUIZ FLOW                                   │
└─────────────────────────────────────────────────────────────────────┘

HomeDashboard → QuizCard/[Quiz'e Başla] → QuizPage
                                            │
                                            ├─→ Quiz Ayarları (/quiz-settings)
                                            │        │
                                            │        └─→ Kategori, Zorluk, Soru Sayısı
                                            │
                                            ↓
                                    ┌──────────────┐
                                    │  QUIZ BAŞLAT │
                                    └──────────────┘
                                            │
                                            ↓
                                    ┌──────────────┐
                                    │ Soru 1..15   │
                                    │ ⏱️ Timer     │
                                    └──────────────┘
                                            │
                                            ↓
                                    ┌──────────────┐
                                    │ Quiz Bitti!  │
                                    └──────────────┘
                                            │
                                            ↓
                                    ┌──────────────┐
                                    │QuizResults   │
                                    │ (/quiz-      │
                                    │ results)     │
                                    └──────────────┘
                                            │
                              ┌─────────────┴─────────────┐
                              ↓                           ↓
                       [Tekrar Dene]              [Ana Sayfaya Dön]
                                                            │
                          (QuizPage)                  (HomeDashboard)
```

### Quiz Route'ları

| Route | Sayfa | Açıklama |
|-------|-------|----------|
| `/quiz` | QuizPage | Ana quiz sayfası |
| `/quiz-settings` | QuizSettingsPage | Quiz ayarları |
| `/quiz-results` | QuizResultsPage | Quiz sonuçları |
| `/daily-challenge` | DailyChallengePage | Günlük meydan okuma |

---

## ⚔️ Düello/Multiplayer Akışı

```
┌─────────────────────────────────────────────────────────────────────┐
│                      DUEL / MULTIPLAYER FLOW                        │
└─────────────────────────────────────────────────────────────────────┘

HomeDashboard → [Düello Başlat] → DuelPage
                                        │
                                        ├─→ [Oda Oluştur] → RoomManagementPage
                                        │                              │
                                        │                              ↓
                                        │                      MultiplayerLobbyPage
                                        │                              │
                                        │                      [Oyun Başla]
                                        │                              ↓
                                        │                      DuelPage (Game)
                                        │
                                        └─→ [Düello Davet Et] → DuelInvitationPage
                                                                         │
                                                                         ↓
                                                                 Duvarlıdan Kabul
                                                                         │
                                                                         ↓
                                                                 DuelPage (Game)

OYUN SONUCU:
    ↓
┌─────────────────────────────────────┐
│ Kazanan → Ödül + XP                 │
│ Kaybeden → XP (az)                  │
└─────────────────────────────────────┘
```

### Düello Route'ları

| Route | Sayfa | Açıklama |
|-------|-------|----------|
| `/duel` | DuelPage | Düello oyunu |
| `/duel-invitation` | DuelInvitationPage | Düello daveti |
| `/multiplayer-lobby` | MultiplayerLobbyPage | Çok oyunculu lobisi |
| `/room-management` | RoomManagementPage | Oda yönetimi |
| `/spectator-mode` | SpectatorModePage | İzleyici modu |

---

## 👥 Sosyal Akış

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SOCIAL FLOW                                 │
└─────────────────────────────────────────────────────────────────────┘

HomeDashboard → Friends (/friends)
                        │
                        ├─→ Arkadaş Listesi
                        │       │
                        │       └─→ [Düello Davet Et] → DuelInvitationPage
                        │       └─→ [Profili Gör] → ProfilePage
                        │
                        ├─→ Arkadaş İstekleri (Gelen)
                        │       │
                        │       └─→ [Kabul Et] / [Reddet]
                        │
                        └─→ Arkadaş Ekle
                                │
                                └─→ Kullanıcı ID / QR Kod

HomeDashboard → Leaderboard (/leaderboard)
                        │
                        └─→ Kategori Seçimi
                                │
                                ├─→ Haftalık
                                ├─→ Aylık
                                └─→ Tüm Zamanlar

HomeDashboard → Achievements (/achievement)
                        │
                        └─→ AchievementsGallery (/achievements-gallery)
```

### Sosyal Route'ları

| Route | Sayfa | Açıklama |
|-------|-------|----------|
| `/friends` | FriendsPage | Arkadaşlar sayfası |
| `/leaderboard` | LeaderboardPage | Liderlik tablosu |
| `/achievement` | AchievementPage | Başarımlar |
| `/achievements-gallery` | AchievementsGalleryPage | Başarımlar galerisi |

---

## 🎁 Ödül/Shop Akışı

```
┌─────────────────────────────────────────────────────────────────────┐
│                      REWARDS / SHOP FLOW                            │
└─────────────────────────────────────────────────────────────────────┘

HomeDashboard → Rewards (/rewards)
                        │
                        ├─→ Kazanılan Kutular (/won-boxes)
                        │       │
                        │       └─→ [Kutu Aç] → LootBox Animation
                        │                        │
                        │                        └─→ Ödül Kazanıldı!
                        │
                        └─→ Rewards Shop (/rewards-shop)
                                │
                                └─→ Ödül Seç → Satın Al

ÖDÜLLER:
┌─────────────────────────────────────────────────┐
│ 💎 Nadir Kutu    │  500 Jetón                  │
│ 🎫 Bilet         │  100 Jetón                  │
│ 🪙 Jetón         │  VIP Abonelik               │
└─────────────────────────────────────────────────┘
```

### Ödül Route'ları

| Route | Sayfa | Açıklama |
|-------|-------|----------|
| `/rewards` | RewardsMainPage | Ana ödül sayfası |
| `/rewards-shop` | RewardsShopPage | Ödül mağazası |
| `/won-boxes` | WonBoxesPage | Kazanılan kutular |

---

## 📱 Mevcut Navigasyon Yapısı (Sorunlu Noktalar)

### ❌ Tespit Edilen Sorunlar

1. **Birden Fazla Home Dashboard:**
   - `home_dashboard.dart` ✅ (kullanılan)
   - `home_dashboard_clean.dart` ❌ (duplicate)
   - `home_dashboard_fixed.dart` ❌ (duplicate)
   - `home_dashboard_optimized.dart` ❌ (duplicate)
   - `home_dashboard_premium.dart` ❌ (duplicate)

2. **Birden Fazla Router:**
   - `app_router.dart` ✅ (kullanılan)
   - `app_router_complete.dart` ❌ (duplicate)
   - `simplified_app_router.dart` ❌ (unused)
   - `improved_app_router.dart` ❌ (unused)

3. **50+ Route (Çok Fazla):**
   - Birçok route tek sayfaya yönlendiriyor
   - Bazı route'lar aynı sayfayı gösteriyor
   - Örnek: `/spam-safe-password-reset` → `ForgotPasswordPageEnhanced`
   - Örnek: `/password-change` → `ForgotPasswordPage`
   - Örnek: `/new-password` → `ForgotPasswordPage`

4. **Feature-Based Navigation Eksik:**
   - 5 tab'lı bottom navigation yerine
   - Her sayfaya ayrı route ile erişim
   - Kullanıcı akışı karmaşık

---

## 📊 Özet İstatistikler

```
┌────────────────────────────────────────────────────────────┐
│                   PROJE İSTATİSTİKLERİ                     │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  📁 Toplam Sayfa:          37                              │
│  📁 Toplam Route:          50+                             │
│  📁 Duplicate Home Pages:   5 (sadece 1 kullanılıyor)     │
│  📁 Duplicate Routers:      4 (sadece 1 kullanılıyor)     │
│  📁 Service:               40+                             │
│                                                             │
│  🔄 Auth Flow:             8 sayfa                         │
│  🎮 Quiz Flow:             6 sayfa                         │
│  ⚔️  Duel/Multiplayer:     5 sayfa                         │
│  🏆 Social:                4 sayfa                         │
│  👤 User/Profile:          3 sayfa                         │
│  🎁 Rewards:               4 sayfa                         │
│  ℹ️  Help/Other:           2 sayfa                         │
│                                                             │
│  ✅ Tüm Sayfalar Oluşturuldu                               │
│  ⚠️  Navigation Karmaşık                                  │
│  🔴 Feature-Based Navigation Yok                           │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## 🎯 Önerilen İyileştirme (NEW_FLOW_REDESIGN_PLAN.md)

```
┌────────────────────────────────────────────────────────────┐
│            ÖNERİLEN YENİ NAVİGASYON (5 Tab)               │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐      │
│  │   🏠    │    🎮   │    🏆   │    👥   │    👤   │      │
│  │ AnaSayfa│  Oyunlar │ Sosyal  │Arkadaş  │  Profil │      │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘      │
│                                                             │
│  📉 37 Sayfa → 8 Ana Sayfa (%80 azaltma)                   │
│  📉 50+ Route → 15 Route (%70 azaltma)                     │
│  ✅ Feature-based navigation                                │
│  ✅ Temiz ve anlaşılır akış                                 │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### Yeni Sayfa Yapısı Önerisi

| Kategori | Yeni Sayfa | Açıklama |
|----------|------------|----------|
| **Oyun Modları** | `game_modes_page.dart` | Quiz, Duel, Turnuva, Hızlı Oyun, Board Game |
| **Sosyal** | `social_page.dart` | Liderlik Tablosu, Başarılar, Ödüller |
| **Arkadaşlar** | `friends_page.dart` | Arkadaş Listesi, Davetler, İstekler |
| **Profil** | `profile_page.dart` | İstatistikler, Rozetler, Başarımlar |
| **Ayarlar** | `settings_page.dart` | Tema, Dil, Güvenlik/2FA |

---

## 🔄 Akış Diyagramları

### Uygulama Başlangıç Akışı

```
[App Launch]
     │
     ├─→ Firebase Initialize
     │
     ├─→ Auth State Restore
     │
     ├─→ Deep Linking Init
     │
     ├─→ Services Init
     │
     └─→ [Auth Check]
            │
            ├─→ [Authenticated] → /home
            │
            └─→ [Not Authenticated] → /login
```

### Ana Navigasyon Akışı

```
[HomeDashboard]
     │
     ├─→ Quiz Module ───────────────────────────┐
     │         ├─→ QuizPage                     │
     │         ├─→ QuizSettings                 │
     │         └─→ DailyChallenge               │
     │                                            │
     ├─→ Gaming Module ──────────────────────────┤
     │         ├─→ DuelPage                     │
     │         ├─→ MultiplayerLobby             │
     │         └─→ BoardGame                    │
     │                                            │
     ├─→ Social Module ──────────────────────────┤
     │         ├─→ Leaderboard                  │
     │         ├─→ Friends                      │
     │         └─→ Achievements                 │
     │                                            │
     └─→ User Module ───────────────────────────┤
              ├─→ Profile                       │
              ├─→ Settings                      │
              └─→ Notifications
```

---

## 📝 Sonuç

Karbonson uygulamasının mevcut akış yapısı:

1. **Güçlü Yönler:**
   - Tüm 37 sayfa oluşturulmuş ve çalışır durumda
   - Firebase entegrasyonu tamamlanmış
   - Authentication flow'u kapsamlı
   - Quiz ve multiplayer sistemleri aktif

2. **İyileştirme Alanları:**
   - Feature-based navigation eksik
   - Birçok duplicate dosya var
   - Route sayısı çok yüksek (50+)
   - Navigation karmaşıklaşmış

3. **Önerilen Çözüm:**
   - NEW_FLOW_REDESIGN_PLAN.md dokümanındaki önerileri uygula
   - 5 tab'lı bottom navigation sistemine geç
   - Duplicate dosyaları temizle
   - Route sayısını azalt

---

**Doküman Tarihi:** 21 Ocak 2026  
**Durum:** ✅ Mevcut Akış Analizi Tamamlandı

