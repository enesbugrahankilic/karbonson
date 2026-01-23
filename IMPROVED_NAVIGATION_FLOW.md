# 🎯 KARBONSON - İMPROVED NAVIGATION FLOW

> Daha mantıklı, daha UI-odaklı ve daha normal bir kullanıcı deneyimi için yeniden tasarlanmış navigasyon akışı

---

## 📊 VİZUEL AKIŞ HARİTASI

### 1️⃣ **SPLASH & APP INITIALIZATION**

```
┌──────────────────────────────────────────────────┐
│                  APP STARTS                       │
│         (Firebase Auth Check)                     │
└──────────────────────────────────┬────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ↓              ↓              ↓
           [Authenticated]  [Not Auth]     [2FA Required]
                    ↓              ↓              ↓
              [HOME PAGE]  [LOGIN PAGE]  [2FA VERIFY]
```

---

### 2️⃣ **AUTHENTICATION FLOW** (Giriş/Kayıt)

```
┌─────────────────────────────────────────────────────────┐
│                    LOGIN PAGE                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  📧 E-posta        [input]                       │  │
│  │  🔐 Şifre          [input]                       │  │
│  │  [GİRİŞ YAP] [Şifremi Unuttum] [KAYDOL]        │  │
│  │  [Misafir Olarak Giriş]                         │  │
│  └──────────────────────────────────────────────────┘  │
└───────────┬────────────────┬─────────────┬──────────────┘
            │                │             │
        ✅ Giriş        ❌ Şifre       📝 Kayıt
            │           Unuttum            │
            ↓                ↓              ↓
    [2FA CHECK]    [EMAIL RESET]    [REGISTER PAGE]
            │           PAGE              │
            │           │                 ↓
            │           │          [CLASS SELECTION]
            │           │                 │
            │           │                 ↓
            │           │          [EMAIL VERIFY]
            │           │                 │
            ↓           ↓                 ↓
        ┌─────────────────────────────────┐
        │     [2FA SETUP/VERIFY]          │
        │  ✓ SMS ✓ Email ✓ TOTP/Google   │
        └─────────────────────────────────┘
                      ↓
           [WELCOME & TUTORIAL PAGE]
           (First time users only)
                      ↓
           ✅ [HOME DASHBOARD]
```

---

### 3️⃣ **HOME DASHBOARD** (Central Hub)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          HOME DASHBOARD                                │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  👤 Profile Card  |  🔔 Notifications  |  ⚙️ Quick Settings    │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                        │
│  ┌─────────┬──────────┬──────────┬──────────┬──────────┬──────────┐  │
│  │   📚    │    ⚔️     │    🏆    │    👥    │    🎁    │    💚    │  │
│  │  QUIZ   │   DUEL   │ LEADER   │ FRIENDS  │ REWARDS  │ CARBON   │  │
│  └────┬────┴────┬─────┴────┬─────┴────┬─────┴────┬─────┴────┬─────┘  │
│       │         │          │          │          │          │         │
│  ┌────↓──┐ ┌───↓──┐ ┌────↓──┐ ┌────↓──┐ ┌────↓──┐ ┌────↓──┐ │     │
│  │Quick  │ │Quick │ │ Stats │ │ Find  │ │ Shop  │ │Report │ │     │
│  │Stats  │ │Play  │ │ View  │ │Friends│ │Browse │ │ View  │ │     │
│  └───────┘ └──────┘ └───────┘ └───────┘ └───────┘ └───────┘ │     │
│                                                                │     │
│  [Daily Challenge Banner] [Achievement Notification] [Rewards] │     │
│                                                                │     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### 4️⃣ **QUIZ FLOW** (Bilgi Testi)

```
HOME DASHBOARD
      │
      ↓
[QUIZ SELECTION]
      │
      ├─ Category: All/Energy/Water/Forest/Recycling
      ├─ Difficulty: Easy/Medium/Hard
      ├─ Questions: 5/10/15/20/25
      └─ Language: Turkish/English
      │
      ↓
[QUIZ IN PROGRESS]
  Question [3/15]
  │
  ├─ Display Question
  ├─ Show 4 Options
  ├─ Timer (if enabled)
  └─ Progress Bar
      │
      ├─ Answer Selected
      ├─ Check (Correct/Wrong)
      └─ Next Question
      │
      ↓
[QUIZ COMPLETED]
      │
      ├─ Score: 1200 pts
      ├─ Accuracy: 80%
      ├─ Time: 5:30
      ├─ Rewards: +50 coins
      └─ [SHARE] [TRY AGAIN] [HOME]
      │
      ↓
[HOME DASHBOARD]
```

---

### 5️⃣ **DUEL/MULTIPLAYER FLOW** (Karşılaşma)

```
HOME DASHBOARD
      │
      ↓
[DUEL SELECTION]
      │
      ├─ [CREATE ROOM]          │ [JOIN ROOM]
      │                         │
      ├─ Difficulty: Easy/Med   │ [Enter 4-digit code]
      └─ Questions: 5/10/15     │
      │                         │
      ↓                         ↓
[WAITING FOR PLAYERS]  [JOINING ROOM]
      │                         │
      └──────────┬──────────────┘
                 ↓
      [MULTIPLAYER LOBBY]
      │ Player 1: John (Ready)
      │ Player 2: Jane (Ready)
      │ [START GAME] [ROOM CODE: 1234]
      │
      ↓
      [DUEL IN PROGRESS]
      │ P1 Score: 300  │  P2 Score: 250
      │ Q3/10
      │
      ├─ Both see same question
      ├─ First to answer wins points
      └─ Real-time scoring
      │
      ↓
      [DUEL RESULTS]
      │ 🥇 Player 1 Wins!
      │ Score: 1500 vs 1200
      │ Rewards: +100 coins
      │ [REMATCH] [SHARE] [HOME]
      │
      ↓
      [HOME DASHBOARD]
```

---

### 6️⃣ **SOCIAL FLOW** (Sosyal Ağ)

```
HOME DASHBOARD
      │
      ├─ [FRIENDS PAGE]        [LEADERBOARD PAGE]
      │         │                       │
      │    ┌────┴────┬─────────┐       └─ Global
      │    ↓         ↓         ↓       └─ Friends
      │  [FRIENDS] [REQUESTS] [ADD]    └─ Categories
      │         │         │         │
      │    List │ Pending │ QR Code │
      │    with │ Requests│ / Search│
      │  status │ +Handle │         │
      │         │         │         │
      ↓
      [FRIEND DETAIL]
      │ Name: John
      │ Level: 5
      │ Quizzes: 45
      │ [MESSAGE] [CHALLENGE] [UNFOLLOW]
      │
      └─ → [DUEL WITH FRIEND]
```

---

### 7️⃣ **PROFILE & SETTINGS FLOW**

```
HOME DASHBOARD
      │
      ↓
[PROFILE PAGE]
  ┌──────────────────┐
  │ 👤 Avatar        │
  │ Name: @username  │
  │ Level: 10        │
  │ Quizzes: 150     │
  │ Friends: 45      │
  └──────────────────┘
      │
      ├─ [ACHIEVEMENTS]  →  Gallery view of all achievements
      │
      ├─ [STATISTICS]    →  Detailed stats/analytics
      │
      ├─ [EDIT PROFILE]  →  Update name, avatar, bio
      │
      ├─ [SETTINGS]      →  App preferences
      │                      ├─ Language
      │                      ├─ Notifications
      │                      ├─ Privacy
      │                      ├─ Dark/Light Mode
      │                      └─ About
      │
      └─ [LOGOUT]        →  Sign out
            │
            ↓
      [LOGIN PAGE]
```

---

### 8️⃣ **REWARDS & SHOP FLOW**

```
HOME DASHBOARD
      │
      ↓
[REWARDS HUB]
  ┌──────────────┬──────────────┬──────────────┐
  │   🛍️ SHOP    │   🎁 WON     │  💰 BALANCE  │
  │              │  BOXES       │              │
  └────┬─────────┴────┬─────────┴────┬─────────┘
       │               │              │
       ↓               ↓              ↓
   [ITEMS]        [OPENED]        [Coins: 500]
   ├─ Badges      ├─ Loot         [Gems: 25]
   ├─ Emotes      │   Contents:    [Chest: 12]
   ├─ Themes      │   - Coins
   └─ Skins       │   - Gems
                  │   - Items
                  └─ [OPEN NEXT]
```

---

## 📋 IMPROVED FLOW RULES

### ✅ DO:
- ✔️ **Clear State Feedback** - Her sayfada nerede olduğunu bil
- ✔️ **Bottom Navigation** - Tahmin edilebilir ana menü
- ✔️ **Back Button** - Her zaman önceki sayfaya dön
- ✔️ **Progress Indication** - Quiz/Duel progresini göster
- ✔️ **Quick Actions** - En sık kullanılanlar hızlı erişim
- ✔️ **Deep Linking** - Direct access to sub-pages
- ✔️ **State Preservation** - Geri dönüşte state korunur

### ❌ DON'T:
- ❌ **Nested Navigators** - Çok karmaşık yapı
- ❌ **Dead Ends** - Bırakılmış sayfalar
- ❌ **Unclear Transitions** - Karmaşık sayfa geçişleri
- ❌ **Lost in Navigation** - Nerede olduğu belli değil
- ❌ **Too Many Back Steps** - 3+ step back gerekmiyor
- ❌ **Inconsistent Patterns** - Farklı sayfalarda farklı kurallar

---

## 🔄 BOTTOM NAVIGATION (Ana Menu)

```
┌────────────────────────────────────────────┐
│  🏠    📚    ⚔️     🏆    👤              │
│ HOME  QUIZ  DUEL  SOCIAL  PROFILE         │
│  ⭐    ⭐                                  │
└────────────────────────────────────────────┘
```

**Neden Bottom Navigation?**
- ✅ Mobile-first approach
- ✅ Thumb-friendly navigation
- ✅ Always visible
- ✅ Clear app structure
- ✅ Quick access to main features

---

## 🎨 PAGE HIERARCHY

```
TIER 0 (Splash)
  ↓
TIER 1 (Auth)
  ├─ LoginPage
  ├─ RegisterPage
  ├─ 2FA Pages
  └─ ForgotPassword
  ↓
TIER 2 (Onboarding)
  ├─ WelcomePage
  ├─ TutorialPage
  └─ ProfileSetup
  ↓
TIER 3 (Main App)
  ├─ HomeDashboard (Hub)
  ├─ QuizFlow
  ├─ DuelFlow
  ├─ SocialFlow
  ├─ ProfileFlow
  └─ RewardsFlow
  ↓
TIER 4 (Settings)
  ├─ SettingsPage
  ├─ AchievementsGallery
  ├─ NotificationsPage
  └─ AboutPage
```

---

## 🚀 IMPLEMENTATION CHECKLIST

### Navigation Structure:
- [ ] BottomNavigationBar in HomeDashboard
- [ ] Named Routes for all pages
- [ ] DeepLink support
- [ ] Navigator state preservation

### Auth Flow:
- [ ] Splash screen with auth check
- [ ] Proper 2FA flow
- [ ] Session management
- [ ] Logout handling

### Quiz Flow:
- [ ] Settings → Quiz
- [ ] In-game pause
- [ ] Results sharing
- [ ] Retry option

### Duel Flow:
- [ ] Room creation/joining
- [ ] Real-time sync
- [ ] Graceful disconnect
- [ ] Rematch option

### Profile Flow:
- [ ] Edit capabilities
- [ ] Achievement details
- [ ] Stats visualization
- [ ] Settings integration

### Error Handling:
- [ ] Lost connection → Home
- [ ] Timeout → Retry
- [ ] Invalid state → Reset
- [ ] 404 pages → Home

---

## 📱 RESPONSIVE DESIGN

```
MOBILE (< 600px)
├─ Bottom Navigation
├─ Full-width cards
├─ Stack layout
└─ Touch-friendly

TABLET (600px - 1000px)
├─ Side Navigation (Optional)
├─ 2-column grid
├─ More spacious
└─ Larger touch targets

DESKTOP (> 1000px)
├─ Side Navigation
├─ 3+ column grid
├─ Horizontal scrolling
└─ Keyboard shortcuts
```

---

## 🎯 USER JOURNEY MAPPING

### **New User:**
1. Splash → Login
2. Login → Register
3. Register → Email Verify
4. Email Verify → 2FA Setup
5. 2FA Setup → Welcome Page
6. Welcome Page → Tutorial
7. Tutorial → Home Dashboard
8. Home Dashboard → First Quiz

### **Returning User:**
1. Splash → Auth Check
2. Auth Check → 2FA (if enabled)
3. 2FA → Home Dashboard
4. Home Dashboard → Last Activity

### **Power User:**
1. Splash → Auth Check
2. Auth Check → Home Dashboard
3. Home Dashboard → Custom Flow (Depends on tab)

---

## 🔐 SESSION MANAGEMENT

```
App Lifecycle:
┌─────────────┬─────────────┬──────────────┐
│   CREATED   │  RESUMED    │ PAUSED/STOP  │
└─────────────┴─────────────┴──────────────┘
    ↓             ↓              ↓
Check Auth    Resume Last   Save State
    │          Activity        │
    ↓             ↓            ↓
Load User      Validate      Clear Sensitive
Profile        Session       Data
    ↓             ↓            ↓
Ready to       Return to     Ready for
Navigate       Last Page     Background
```

---

## ✨ FUTURE IMPROVEMENTS

- [ ] Gesture-based navigation (swipe back)
- [ ] Animated transitions between pages
- [ ] Breadcrumb navigation
- [ ] Tab-based routing
- [ ] History stack management
- [ ] Deep linking with URL scheme
- [ ] Navigation analytics
- [ ] Predictive preloading

