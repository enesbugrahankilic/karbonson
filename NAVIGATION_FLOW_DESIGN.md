# Karbonson Uygulaması - Yeni Navigasyon Akış Tasarımı

## 📋 İçindekiler
1. [Uygulama Mimarisi](#uygulama-mimarisi)
2. [Sayfa Hiyerarşisi](#sayfa-hiyerarşisi)
3. [Navigasyon Akışları](#navigasyon-akışları)
4. [UI/UX İyileştirmeleri](#uiux-iyileştirmeleri)
5. [Implementasyon Adımları](#implementasyon-adımları)

---

## Uygulama Mimarisi

### Temel Katmanlar
```
┌─────────────────────────────┐
│   UI Layer (Pages/Widgets)  │
├─────────────────────────────┤
│   Navigation Layer          │
├─────────────────────────────┤
│   BLoC/Provider Layer       │
├─────────────────────────────┤
│   Services Layer            │
├─────────────────────────────┤
│   Firebase/Data Layer       │
└─────────────────────────────┘
```

---

## Sayfa Hiyerarşisi

### 1. **Kimlik Doğrulama (Authentication) Akışı**
```
Login Page
  ├── Register Page (Refactored)
  │   ├── Email Verification Page
  │   └── Tutorial Page
  ├── Forgot Password Page (Enhanced)
  └── 2FA Setup Pages
      ├── Basic 2FA Setup
      ├── Enhanced 2FA Setup
      └── Comprehensive 2FA Setup
```

**Sayfalar:**
- `LoginPage` - Giriş
- `RegisterPageRefactored` - Kayıt (Yeniledi)
- `EmailVerificationPage` - E-posta Doğrulama
- `ForgotPasswordPage` - Şifremi Unuttum
- `TwoFactorAuthSetupPage` - Temel 2FA
- `EnhancedTwoFactorAuthSetupPage` - Gelişmiş 2FA
- `Comprehensive2FAVerificationPage` - Kapsamlı 2FA Doğrulama

---

### 2. **Ana Uygulama (Main App) Akışı**

```
Home Dashboard (Central Hub)
├── Quiz Module
│   ├── Quiz Page
│   ├── Daily Challenge Page
│   └── AI Recommendations Page
├── Gaming Module
│   ├── Board Game Page
│   ├── Duel Page
│   └── Duel Invitation Page
├── Social Module
│   ├── Friends Page
│   ├── Leaderboard Page
│   └── Multiplayer Lobby Page
├── User Management
│   ├── Profile Page
│   ├── Settings Page
│   ├── Achievement Page
│   └── Room Management Page
└── Additional Features
    └── Email OTP Verification Page
```

**Sayfalar:**
- `HomeDashboard` - Ana Sayfa
- `QuizPage` - Quiz
- `DailyChallengePages` - Günlük Zorluk
- `AIRecommendationsPage` - AI Önerileri
- `BoardGamePage` - Tahta Oyunu
- `DuelPage` - İkili Oyun
- `DuelInvitationPage` - İkili Davet
- `FriendsPage` - Arkadaşlar
- `LeaderboardPage` - Sıralamalar
- `MultiplayerLobbyPage` - Multiplayer Lobby
- `ProfilePage` - Profil
- `SettingsPage` - Ayarlar
- `AchievementPage` - Başarılar
- `RoomManagementPage` - Oda Yönetimi

---

## Navigasyon Akışları

### **Akış 1: Kimlik Doğrulama Akışı**
```
[Uygulama Başlatılır]
        ↓
[AuthenticationStateService Kontrol]
        ↓
    ┌───┴────┐
    ↓        ↓
 [GİRİŞ]  [KAYITLI]
    ↓        ↓
 [LoginPage] [2FA Kontrol]
    ↓        ↓
 [Şifre? Unuttum]  ┌─────┴─────┐
    ↓              ↓           ↓
 [ForgotPassword]  [2FA      [2FA
   Enhanced]       Yapılı]    Yapılmamış]
    ↓              ↓          ↓
 [Reset Link]   [2FA         [2FA Setup]
    ↓           Verify]       ↓
 [Register]        ↓      [Setup Page]
    ↓           [Home]        ↓
 [Email Verify]             [Verify]
    ↓                        ↓
 [Tutorial]              [Home]
    ↓
 [2FA Setup?]
    ↓
[Home Dashboard]
```

### **Akış 2: Ana Uygulama Navigasyonu**
```
[Home Dashboard] ← Central Hub
├─→ [Quiz Module]
│   ├─→ [Quiz Page]
│   ├─→ [Daily Challenge]
│   └─→ [AI Recommendations]
│
├─→ [Gaming Module]
│   ├─→ [Board Game]
│   ├─→ [Duel]
│   └─→ [Multiplayer Lobby]
│
├─→ [Social Module]
│   ├─→ [Friends]
│   ├─→ [Leaderboard]
│   └─→ [Rooms]
│
└─→ [Settings Panel]
    ├─→ [Profile]
    ├─→ [Achievements]
    └─→ [Settings]
```

### **Akış 3: 2FA Doğrulama Akışı**
```
[Giriş Başarılı]
        ↓
  [2FA Gerekli mi?]
        ↓
    ┌───┴────┐
    ↓        ↓
  [Evet]    [Hayır]
    ↓        ↓
[2FA      [Home
 Verify]   Dashboard]
    ↓
[SMS/Email/TOTP
 Seçimi]
    ↓
[Kod Gir]
    ↓
[Doğrula]
    ↓
┌───┴─────┐
↓         ↓
[Başarılı][Başarısız - Tekrar]
↓
[Home Dashboard]
```

---

## UI/UX İyileştirmeleri

### **1. Sayfa Geçişleri**
- ✅ Smooth Fade Transitions
- ✅ Slide Transitions (Sayfalar arası)
- ✅ Pulse Animations (Loading)
- ✅ Scale Transitions (Modal Dialogs)

### **2. Loading States**
```dart
// Loading Göstergesi
┌──────────────┐
│  ⟳ Loading...│
└──────────────┘

// Progress Indicator
┌──────────────────┐
│ ████░░░░ 40%     │
└──────────────────┘
```

### **3. Error Handling**
```
User Action
    ↓
[Hata Oluşur?]
    ↓
┌───┴─────┐
↓         ↓
[Evet]   [Hayır]
 ↓        ↓
[Error   [Success
 Dialog]  Message]
 ↓        ↓
[Retry/  [Continue]
 Cancel]
```

### **4. Form Validasyon**
- Real-time validation
- Clear error messages (Türkçe)
- Visual feedback (kırmızı border, ikon)
- Disabled submit button (invalid form)

### **5. Accessibility (Erişilebilirlik)**
- Semantic widgets
- Sufficient color contrast
- Touch target size ≥ 48dp
- Screen reader support

---

## Route Constants (Yeni Yapı)

### Kategorize Edilmiş Routes
```dart
class AppRoutes {
  // Authentication
  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authEmailVerify = '/auth/email-verify';
  static const authForgotPassword = '/auth/forgot-password';
  static const auth2FASetup = '/auth/2fa-setup';
  static const auth2FAVerify = '/auth/2fa-verify';

  // Main App
  static const appHome = '/app/home';
  static const appQuiz = '/app/quiz';
  static const appDuel = '/app/duel';
  static const appDuelInvite = '/app/duel-invite';
  static const appFriends = '/app/friends';
  static const appLeaderboard = '/app/leaderboard';
  
  // User
  static const userProfile = '/user/profile';
  static const userSettings = '/user/settings';
  static const userAchievements = '/user/achievements';
}
```

---

## Deep Linking Desteği

### Desteklenen Linkler
```
karbonson://login
karbonson://register
karbonson://forgot-password
karbonson://app/home
karbonson://app/quiz
karbonson://app/duel
karbonson://user/profile
karbonson://user/achievements
karbonson://invite/duel/{userId}
```

---

## Navigation Guards

### Guards (Korunan Yönlendirmeler)
```
Route Requested
    ↓
[AuthGuard Check]
    ├─ Authenticated? ✓ → Continue
    ├─ Authenticated? ✗ → Redirect to Login
    ↓
[TwoFactorGuard Check]
    ├─ 2FA Completed? ✓ → Continue
    ├─ 2FA Completed? ✗ → Redirect to 2FA
    ↓
[Page Loaded]
```

---

## Implementasyon Adımları

### **Phase 1: Core Navigation Setup**
```
✅ 1. Merkezi NavigationService oluştur
✅ 2. AppRouter'ı yeniden yapılandır
✅ 3. Route constants'ı kategorize et
⬜ 4. Navigation guards ekle
```

### **Phase 2: UI/UX Improvements**
```
⬜ 1. Page transitions optimize et
⬜ 2. Loading states standardize et
⬜ 3. Error handling iyileştir
⬜ 4. Form validations güncelle
```

### **Phase 3: Testing & Optimization**
```
⬜ 1. Navigation tests yaz
⬜ 2. Performance optimize et
⬜ 3. Deep linking test et
⬜ 4. Error scenarios test et
```

---

## Error Handling Stratejisi

### Hata Türleri
```
Network Error
    ↓
[Show SnackBar]
├─ "İnternet bağlantısı kontrol edin"
├─ Retry Button
└─ Dismiss Button

Authentication Error
    ↓
[Show Dialog]
├─ Title: "Kimlik Doğrulama Başarısız"
├─ Message: "Lütfen tekrar giriş yapın"
├─ OK Button → Redirect to Login
└─ Cancel Button → Dismiss

Validation Error
    ↓
[Show Inline Error]
├─ Red Border
├─ Error Message
└─ Focus on Field
```

---

## Performance Optimization

### Memory Management
- ✅ Lazy loading for pages
- ✅ Dispose animations properly
- ✅ Cancel ongoing requests on navigation

### State Management
- ✅ BLoC/Provider scoping
- ✅ Proper disposal patterns
- ✅ Avoid memory leaks

---

## Testing Strategy

### Unit Tests
```dart
test('Navigation to home requires authentication');
test('2FA verification redirects correctly');
test('Invalid routes show error page');
```

### Widget Tests
```dart
testWidgets('Navigation drawer works');
testWidgets('Bottom navigation updates correctly');
```

### Integration Tests
```dart
testWidgets('Complete auth flow');
testWidgets('Full app navigation');
```

---

## Monitoring & Logging

### Analytics Events
```
event: 'page_view'
params: {
  'page_name': 'quiz_page',
  'user_id': 'xxx',
  'timestamp': 'xxx'
}

event: 'navigation_error'
params: {
  'from': '/app/home',
  'to': '/app/quiz',
  'error': 'Authentication failed'
}
```

---

## Sonuç

Bu navigasyon tasarımı:
- ✅ Tüm sayfaları merkezi bir noktadan yönetir
- ✅ Açık ve anlaşılır akışlar tanımlar
- ✅ UI/UX iyileştirmelerini içerir
- ✅ Genişletilmesi kolay mimariye sahip
- ✅ Test edilebilirlik sağlar
- ✅ Performans optimizasyonları içerir

