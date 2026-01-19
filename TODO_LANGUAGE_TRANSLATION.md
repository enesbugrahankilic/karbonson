# Dil Çeviri Sistemi İyileştirme - TODO Listesi

## Hedef
Dil değişikliği anında tüm sayfaların anında çevrilmesi için merkezi dil dosyası sistemi oluşturmak.

---

## 📋 Yapılacaklar

### ✅ Aşama 1: AppLocalizations Servisini Genişletme
- [x] 1.1 Home Dashboard string'leri eklendi (~80 string)
- [x] 1.2 Quiz System string'leri eklendi
- [x] 1.3 Duel System string'leri eklendi
- [x] 1.4 Multiplayer string'leri eklendi
- [x] 1.5 Statistics & Progress string'leri eklendi
- [x] 1.6 Daily Challenges string'leri eklendi
- [x] 1.7 Achievements string'leri eklendi
- [x] 1.8 Friends & Social string'leri eklendi
- [x] 1.9 Settings string'leri eklendi

### ✅ Aşama 2: Home Dashboard Güncelleme
- [x] 2.1 Consumer<LanguageProvider> wrapper eklendi
- [x] 2.2 Temel string'ler çevrildi (loadingData, homePageTitle)
- [ ] 2.3 Tüm hardcoded string'ler AppLocalizations ile değiştirilecek
- [ ] 2.4 LanguageProvider listener'ları eklenecek

### 🔄 Aşama 3: Quiz Page Güncelleme
- [ ] 3.1 Hardcoded string'leri değiştir
- [ ] 3.2 Language listener ekle

### 🔄 Aşama 4: Duel Page Güncelleme
- [ ] 4.1 Hardcoded string'leri değiştir
- [ ] 4.2 Language listener ekle

### 🔄 Aşama 5: Multiplayer Lobby Güncelleme
- [ ] 5.1 Hardcoded string'leri değiştir
- [ ] 5.2 Language listener ekle

### 🔄 Aşama 6: Daily Challenge Page Güncelleme
- [ ] 6.1 Hardcoded string'leri değiştir
- [ ] 6.2 Language listener ekle

### 🔄 Aşama 7: Achievements Page Güncelleme
- [ ] 7.1 Hardcoded string'leri değiştir
- [ ] 7.2 Language listener ekle

### 🔄 Aşama 8: Friends Page Güncelleme
- [ ] 8.1 Hardcoded string'leri değiştir
- [ ] 8.2 Language listener ekle

### 🔄 Aşama 9: Settings Page Güncelleme
- [ ] 9.1 Hardcoded string'leri değiştir
- [ ] 9.2 Language listener ekle

### 🔄 Aşama 10: Diğer Widget'ları Güncelleme
- [ ] 10.1 Quick Menu Widget
- [ ] 10.2 Dialog'lar
- [ ] 10.3 Cards ve list items

---

## 📊 İlerleme

| Aşama | Durum | Tamamlanan |
|-------|-------|------------|
| Aşama 1: AppLocalizations | 🔄 Devam Ediyor | 0/9 |
| Aşama 2: Home Dashboard | ⏳ Bekliyor | 0/3 |
| Aşama 3: Quiz Page | ⏳ Bekliyor | 0/2 |
| Aşama 4: Duel Page | ⏳ Bekliyor | 0/2 |
| Aşama 5: Multiplayer | ⏳ Bekliyor | 0/2 |
| Aşama 6: Daily Challenge | ⏳ Bekliyor | 0/2 |
| Aşama 7: Achievements | ⏳ Bekliyor | 0/2 |
| Aşama 8: Friends | ⏳ Bekliyor | 0/2 |
| Aşama 9: Settings | ⏳ Bekliyor | 0/2 |
| Aşama 10: Widgets | ⏳ Bekliyor | 0/3 |

---

## 📝 Eklenecek String Kategorileri

### Home Dashboard String'leri
```dart
// Welcome Section
static String get welcomeBack => _isTurkish ? 'Hoş Geldiniz' : 'Welcome Back';
static String get helloEmoji => _isTurkish ? 'Merhaba 👋' : 'Hello 👋';
static String get loadingData => _isTurkish ? 'Veriler yükleniyor...' : 'Loading data...';

// Stats
static String get points => _isTurkish ? 'Puan' : 'Points';
static String get badges => _isTurkish ? 'Rozet' : 'Badges';
static String get totalPoints => _isTurkish ? 'Toplam Puan' : 'Total Points';
static String get achievementCount => _isTurkish ? 'Başarı Sayısı' : 'Achievement Count';

// Sections
static String get quickAccess => _isTurkish ? 'Hızlı Erişim' : 'Quick Access';
static String get progressAchievements => _isTurkish ? 'İlerleme & Başarılar' : 'Progress & Achievements';
static String get quickQuiz => _isTurkish ? 'Hızlı Quiz' : 'Quick Quiz';
static String get startQuiz => _isTurkish ? 'Quiz Başlat' : 'Start Quiz';
static String get duelMode => _isTurkish ? 'Düello Modu' : 'Duel Mode';
static String get multiplayer => _isTurkish ? 'Çoklu Oynama' : 'Multiplayer';
static String get dailyChallenges => _isTurkish ? 'Günlük Görevler' : 'Daily Challenges';
static String get statisticsSummary => _isTurkish ? 'İstatistik Özeti' : 'Statistics Summary';
static String get recentActivity => _isTurkish ? 'Son Aktiviteler' : 'Recent Activity';
static String get teamPlay => _isTurkish ? 'Takım Oyunu' : 'Team Play';

// Buttons & Actions
static String get settings => _isTurkish ? 'Ayarlar' : 'Settings';
static String get profile => _isTurkish ? 'Profil' : 'Profile';
static String get play => _isTurkish ? 'Oyna' : 'Play';
static String get start => _isTurkish ? 'Başlat' : 'Start';
static String get create => _isTurkish ? 'Oluştur' : 'Create';
static String get join => _isTurkish ? 'Katıl' : 'Join';
static String get cancel => _isTurkish ? 'İptal' : 'Cancel';
```

### Quiz String'leri
```dart
static String get selectQuizTheme => _isTurkish ? 'Quiz Teması Seç' : 'Select Quiz Theme';
static String get allTopics => _isTurkish ? 'Tümü' : 'All';
static String get energy => _isTurkish ? 'Enerji' : 'Energy';
static String get water => _isTurkish ? 'Su' : 'Water';
static String get forest => _isTurkish ? 'Orman' : 'Forest';
static String get recycling => _isTurkish ? 'Geri Dönüşüm' : 'Recycling';
static String get transportation => _isTurkish ? 'Ulaşım' : 'Transportation';
static String get consumption => _isTurkish ? 'Tüketim' : 'Consumption';
static String get themeDescription => _isTurkish ? 'Tema Açıklaması' : 'Theme Description';
static String get rememberTheme => _isTurkish ? 'Bu temayı hatırla' : 'Remember this theme';
static String get quizCompleted => _isTurkish ? 'Quiz Tamamlandı!' : 'Quiz Completed!';
static String get scoreFormat => _isTurkish ? '$score/15' : '$score/15';
static String get keepTheme => _isTurkish ? 'Tema Değiştir' : 'Change Theme';
static String get playAgain => _isTurkish ? 'Tekrar Oyna' : 'Play Again';
static String get home => _isTurkish ? 'Ana Sayfa' : 'Home';
```

### Duel String'leri
```dart
static String get duelOptions => _isTurkish ? 'Düello Seçenekleri' : 'Duel Options';
static String get quickDuel => _isTurkish ? 'Hızlı Düello' : 'Quick Duel';
static String get roomDuel => _isTurkish ? 'Oda Düellosu' : 'Room Duel';
static String get duelDescription => _isTurkish ? 'Düello Açıklaması' : 'Duel Description';
static String get questionsCount => _isTurkish ? 'soru' : 'questions';
static String get timeLimit => _isTurkish ? 'saniye süre' : 'seconds time';
static String get permanentRoom => _isTurkish ? 'Kalıcı oda' : 'Permanent room';
static String get playWithFriend => _isTurkish ? 'Arkadaşınla oyna' : 'Play with friend';
```

### Multiplayer String'leri
```dart
static String get createRoom => _isTurkish ? 'Oda Oluştur' : 'Create Room';
static String get joinWithCode => _isTurkish ? 'Koda Katıl' : 'Join with Code';
static String get activeRooms => _isTurkish ? 'Aktif Odalar' : 'Active Rooms';
static String get upToPlayers => _isTurkish ? 'kişiye kadar oyna' : 'players max';
```

### Statistics String'leri
```dart
static String get totalTime => _isTurkish ? 'Toplam Süre' : 'Total Time';
static String get longestStreak => _isTurkish ? 'En Uzun Seri' : 'Longest Streak';
static String get loginStreak => _isTurkish ? 'Giriş Serisi' : 'Login Streak';
static String get highestScore => _isTurkish ? 'En Yüksek Skor' : 'Highest Score';
static String get quizScore => _isTurkish ? 'Quiz skoru' : 'Quiz score';
static String get duelWinRate => _isTurkish ? 'Düello Kazanma' : 'Duel Win Rate';
static String get totalDuels => _isTurkish ? 'düello' : 'duels';
static String get weeklyActivity => _isTurkish ? 'Haftalık Aktivite' : 'Weekly Activity';
static String get levelProgress => _isTurkish ? 'Seviye İlerlemesi' : 'Level Progress';
static String get quizStatistics => _isTurkish ? 'Quiz İstatistikleri' : 'Quiz Statistics';
static String get totalQuizzes => _isTurkish ? 'Toplam Quiz' : 'Total Quizzes';
static String get correctRate => _isTurkish ? 'Doğru Oran' : 'Correct Rate';
static String get averageTime => _isTurkish ? 'Ort. Süre' : 'Avg. Time';
static String get recentAchievements => _isTurkish ? 'Son Başarılar' : 'Recent Achievements';
static String get noAchievements => _isTurkish ? 'Henüz başarı yok' : 'No achievements yet';
static String get achievementsHint => _isTurkish ? 'Quiz çözerek başarı kazanın!' : 'Earn achievements by taking quizzes!';
```

### Daily Challenges String'leri
```dart
static String get noDailyChallenges => _isTurkish ? 'Bugün için görev yok' : 'No challenges for today';
static String get newChallengesTomorrow => _isTurkish ? 'Yarın yeni görevler!' : 'New challenges tomorrow!';
static String get challengeReward => _isTurkish ? 'Ödül:' : 'Reward:';
static String get challengePoints => _isTurkish ? 'Puan' : 'Points';
```

### Help & Info String'leri
```dart
static String get helpInfo => _isTurkish ? 'Yardım & Bilgi' : 'Help & Info';
static String get aboutApp => _isTurkish ? 'Uygulama Hakkında' : 'About App';
static String get appDescription => _isTurkish ? 'Uygulama açıklaması' : 'App description';
static String get quizMode => _isTurkish ? 'Quiz Modu' : 'Quiz Mode';
static String get duelModeInfo => _isTurkish ? 'Düello Modu' : 'Duel Mode';
static String get teamGame => _isTurkish ? 'Takım Oyunu' : 'Team Game';
static String get achievementsBadges => _isTurkish ? 'Başarılar & Rozetler' : 'Achievements & Badges';
static String get understood => _isTurkish ? 'Anladım' : 'Understood';
static String get supportEmail => _isTurkish ? 'Destek:' : 'Support:';
```

### Activity String'leri
```dart
static String get noActivities => _isTurkish ? 'Henüz aktivite yok' : 'No activities yet';
static String get activityHint => _isTurkish ? 'Aktivitelerini gör' : 'See your activities';
static String get daysAgo => _isTurkish ? 'gün önce' : 'days ago';
static String get hoursAgo => _isTurkish ? 'saat önce' : 'hours ago';
static String get minutesAgo => _isTurkish ? 'dakika önce' : 'minutes ago';
static String get justNow => _isTurkish ? 'Az önce' : 'Just now';
```

### Quick Menu String'leri
```dart
static String get quickMenu => _isTurkish ? 'Hızlı Menü' : 'Quick Menu';
static String get featuresCount => _isTurkish ? 'özellik keşfet' : 'features to explore';
```

### Profile Dialog String'leri
```dart
static String get selectProfilePicture => _isTurkish ? 'Profil Resmi Seç' : 'Select Profile Picture';
static String get takePhoto => _isTurkish ? 'Fotoğraf Çek' : 'Take Photo';
```

### Theme Names
```dart
static String get energyDescription => _isTurkish 
    ? 'Enerji tasarrufu ve sürdürülebilir enerji' 
    : 'Energy conservation and sustainable energy';
static String get waterDescription => _isTurkish 
    ? 'Su tasarrufu ve su kaynakları yönetimi' 
    : 'Water conservation and water resources management';
static String get forestDescription => _isTurkish 
    ? 'Orman koruma ve ağaçlandırma' 
    : 'Forest protection and afforestation';
static String get recyclingDescription => _isTurkish 
    ? 'Atık yönetimi ve geri dönüşüm' 
    : 'Waste management and recycling';
static String get transportationDescription => _isTurkish 
    ? 'Çevre dostu ulaşım' 
    : 'Eco-friendly transportation';
static String get consumptionDescription => _isTurkish 
    ? 'Sürdürülebilir tüketim' 
    : 'Sustainable consumption';
```

---

## 🎯 Başarı Kriterleri
1. Tüm hardcoded string'ler AppLocalizations ile değiştirilmeli
2. Dil değişikliği anında tüm UI güncellenmeli
3. Consumer veya Listener pattern tüm sayfalarda uygulanmalı
4. Hiçbir metin Türkçe hardcoded kalmamalı
5. Yeni string'ler kolayca eklenebilmeli

---

**Son Güncelleme:** $(date +"%Y-%m-%d %H:%M")
**Toplam String Sayısı:** ~145+

