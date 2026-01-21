# 📝 SAYFALARI REDESIGN ETME PLANI

## ✅ TAMAMLANDI
1. DailyChallengePage ✅
2. HowToPlayPage ✅ (partial)
3. ResponsivePageWrapper widget ✅
4. PageTemplates widget ✅

## ⏳ YAPILACAK (Priority Order)

### TIER 1 - KRITIK (Bu gün)
1. **SettingsPage** - Basit, geri butonu ekle
2. **NotificationsPage** - List layout, geri butonu
3. **AchievementsGalleryPage** - Grid layout, geri butonu
4. **DuelInvitationPage** - List, geri butonu
5. **RewardsMainPage** - Simple layout

### TIER 2 - YÜKSEK ÖNCELİK (Yarın)
6. **ProfilePage** - Complex, many sections
7. **LeaderboardPage** - Complex, multiple tabs
8. **RewardsShopPage** - Complex, scroll, filters
9. **QuizResultsPage** - Display results with scroll
10. **AIRecommendationsPage** - Cards with scroll

### TIER 3 - ORTA (2 gün)
11. **FriendsPage** - List layout
12. **MultiplayerLobbyPage** - List + create button
13. **RoomManagementPage** - List + settings
14. **AchievementPage** - Simple display
15. **SpectatorModePage** - View only

### TIER 4 - GERİ KALAN (Sonra)
16. **QuizPage** - Very complex
17. **QuizSettingsPage** - Dialog changes
18. **DuelPage** - Very complex
19. **BoardGamePage** - Special layout
20. **LoginPage** - Auth flow (careful)
21. **RegisterPage** - Auth flow
22. Rest of auth pages

## 🎨 TEMPLATE KULLANIŞ

Tüm TIER 1 sayfalar için pattern:

```dart
// ÖNCESİ:
Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: ListView(...),
)

// SONRASİ:
Scaffold(
  appBar: StandardAppBar(
    title: 'Title',
    onBackPressed: () => Navigator.pop(context),
  ),
  body: PageBody(
    scrollable: true,
    child: Column(...),
  ),
)
```

## 📦 YAPILACAKLAR

- [ ] Tier 1 sayfaları güncelle (5 sayfa)
- [ ] Tier 2 sayfaları güncelle (5 sayfa)
- [ ] Tier 3 sayfaları güncelle (5 sayfa)
- [ ] Tier 4 sayfaları güncelle (7 sayfa)
- [ ] Test - Tüm sayfaları kontrol et
- [ ] Responsive test - Tablet, mobile, desktop
- [ ] Performance test - Scroll performance

