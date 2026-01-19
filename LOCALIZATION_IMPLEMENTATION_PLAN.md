# Localization Implementation Plan

## 📋 Analysis Summary

**Current State:**
- ✅ AppLocalizations files have ~145+ strings (EN/TR)
- ✅ HomeDashboard has Consumer<LanguageProvider> wrapper
- ❌ Many hardcoded Turkish strings in Home Dashboard, Quiz Page, Duel Page, Quick Menu Widget

## 🎯 Plan

### Step 1: Add Missing Strings to ARB Files
Add ~60 new strings needed for hardcoded text in pages:
- Home Dashboard strings (~25)
- Quiz Page strings (~15)
- Duel Page strings (~10)
- Quick Menu Widget strings (~10)

### Step 2: Update app_localizations.dart
Add getter methods for all new strings

### Step 3: Update app_localizations_en.dart and tr.dart
Add implementations for all new strings

### Step 4: Update Home Dashboard
Replace all hardcoded Turkish strings with AppLocalizations

### Step 5: Update Quiz Page
Replace all hardcoded Turkish strings with AppLocalizations

### Step 6: Update Duel Page
Replace all hardcoded Turkish strings with AppLocalizations

### Step 7: Update Quick Menu Widget
Replace all hardcoded Turkish strings with AppLocalizations

## 📝 New Strings to Add

### Home Dashboard
- `welcomeBack` - "Hoş Geldiniz" / "Welcome Back"
- `helloEmoji` - "Merhaba 👋" / "Hello 👋"
- `loadingData` - "Veriler yükleniyor..." / "Loading data..."
- `totalPoints` - "Toplam Puan" / "Total Points"
- `achievementCount` - "Başarı Sayısı" / "Achievement Count"
- `quickAccess` - "Hızlı Erişim" / "Quick Access"
- `progressAchievements` - "İlerleme & Başarılar" / "Progress & Achievements"
- `quickQuiz` - "Hızlı Quiz" / "Quick Quiz"
- `startQuiz` - "Quiz Başlat" / "Start Quiz"
- `duelMode` - "Düello Modu" / "Duel Mode"
- `multiplayer` - "Çoklu Oynama" / "Multiplayer"
- `dailyChallenges` - "Günlük Görevler" / "Daily Challenges"
- `statisticsSummary` - "İstatistik Özeti" / "Statistics Summary"
- `recentActivity` - "Son Aktiviteler" / "Recent Activity"
- `teamPlay` - "Takım Oyunu" / "Team Play"
- `play` - "Oyna" / "Play"
- `start` - "Başlat" / "Start"
- `create` - "Oluştur" / "Create"
- `join` - "Katıl" / "Join"
- `badges` - "Rozet" / "Badges"
- `homePageTitle` - "Ana Sayfa" / "Home"
- `quickAccessTitle` - "Hızlı Erişim" / "Quick Access"
- `quizInfoTitle` - "Hızlı Quiz Başlat" / "Start Quick Quiz"
- `ecoQuizTitle` - "Çevre Bilgisi Quiz'i" / "Eco Knowledge Quiz"
- `startQuizAction` - "Şimdi Başlat" / "Start Now"
- `increaseAwareness` - "Çevre bilincini artır, puan kazan!" / "Increase eco awareness, earn points!"

### Quiz Page
- `quizSettings` - "Quiz Ayarları" / "Quiz Settings"
- `selectCategory` - "Kategori Seçin:" / "Select Category:"
- `selectDifficulty` - "Zorluk Seviyesi Seçin:" / "Select Difficulty Level:"
- `selectQuestionCount` - "Soru Sayısı Seçin:" / "Select Question Count:"
- `questionCount` - "Soru Sayısı" / "Question Count"
- `fiveQuestions` - "5 Soru (2-3 dakika)" / "5 Questions (2-3 minutes)"
- `tenQuestions` - "10 Soru (~5 dakika)" / "10 Questions (~5 minutes)"
- `fifteenQuestions` - "15 Soru (~7-8 dakika)" / "15 Questions (~7-8 minutes)"
- `twentyQuestions` - "20 Soru (~10-12 dakika)" / "20 Questions (~10-12 minutes)"
- `twentyFiveQuestions` - "25 Soru (~12-15 dakika)" / "25 Questions (~12-15 minutes)"
- `pleaseSelectCategory` - "Lütfen bir kategori seçin" / "Please select a category"
- `begin` - "Başla" / "Begin"
- `quizExit` - "Quizden Çıkış" / "Exit Quiz"
- `exitWarning` - "Quizden çıkarsanız, ilerlemeniz kaydedilmeyecek." / "If you exit the quiz, your progress will not be saved."
- `continueQuestion` - "Devam etmek istiyor musunuz?" / "Do you want to continue?"
- `yesExit` - "Evet, Çık" / "Yes, Exit"
- `progress` - "İlerleme" / "Progress"
- `points` - "Puan" / "Points"
- `questionNumber` - "Soru" / "Question"
- `finish` - "Bitir" / "Finish"
- `quizCompletedTitle` - "Quiz Tamamlandı" / "Quiz Completed"
- `totalScore` - "Toplam Puan" / "Total Score"
- `backToHome` - "Ana Sayfaya Dön" / "Back to Home"
- `gameProgress` - "İlerleme" / "Progress"
- `errorLoading` - "Hata: " / "Error: "

### Duel Page
- `duelModeTitle` - "Düello Modu" / "Duel Mode"
- `createRoom` - "Oda Oluştur" / "Create Room"
- `joinRoom` - "Odaya Katıl" / "Join Room"
- `roomCreated` - "Oda oluşturuldu! Oda Kodu: " / "Room created! Room Code: "
- `roomCodeCopied` - "Oda kodu kopyalandı!" / "Room code copied!"
- `enterRoomCode` - "Oda Kodu" / "Enter Room Code"
- `join` - "Katıl" / "Join"
- `inviteFriends` - "Arkadaşlarını Davet Et" / "Invite Friends"
- `howToPlay` - "Nasıl Oynanır?" / "How to Play?"
- `twoPlayersRequired` - "2 oyuncu gereklidir" / "2 players required"
- `fiveQuestionsPrompt` - "5 soru sorulacak" / "5 questions will be asked"
- `mostCorrectWins` - "En çok doğru cevap kazanır" / "Most correct answers win"
- `speedBonus` - "Hız bonusu ile puan kazanın" / "Earn points with speed bonus"
- `timeLimit` - "15 saniye süre sınırı" / "15 second time limit"
- `duelOptions` - "Düello Seçenekleri" / "Duel Options"
- `chooseDuelType` - "Hangi düello türünü tercih edersiniz?" / "Which duel type do you prefer?"
- `quickDuelDesc` - "5 soru, 15 saniye süre" / "5 questions, 15 seconds time"
- `roomDuelDesc` - "Kalıcı oda ile arkadaşınla oyna" / "Play with friend in permanent room"
- `time` - "Süre" / "Time"
- `yourAnswer` - "Cevabınız" / "Your Answer"
- `send` - "Gönder" / "Send"
- `scoreboard` - "Skor Tablosu" / "Scoreboard"
- `pointsValue` - "puan" / "points"
- `roomJoinFeature` - "Oda katılma özelliği geliştiriliyor..." / "Room join feature under development..."

### Quick Menu Widget
- `featuresCount` - "özellik keşfet" / "features to explore"
- `boardGameSubtitle` - "Strateji tabanlı" / "Strategy based"
- `multiplayerSubtitle` - "4 kişiye kadar" / "Up to 4 players"
- `friendsSubtitle` - "Arkadaş ekle ve gör" / "Add and see friends"
- `leaderboardSubtitle` - "En iyi oyuncular" / "Top players"
- `dailySubtitle` - "Bugünün görevleri" / "Today's challenges"
- `achievementsSubtitle` - "Rozetlerini gör" / "See your badges"
- `rewardsSubtitle` - "Sana özel hediyeler" / "Gifts for you"
- `aiSubtitle` - "Kişiselleştirilmiş" / "Personalized"
- `howToPlaySubtitle` - "Kurallar ve ipuçları" / "Rules and tips"
- `settingsSubtitle` - "Uygulama ayarları" / "App settings"
- `profileSubtitle` - "Kullanıcı bilgileri" / "User info"
- `featured` - "ÖNE ÇIKAN" / "FEATURED"
- `gameModesCategory` - "Oyun Modları" / "Game Modes"
- `socialCategory` - "Sosyal" / "Social"
- `toolsCategory` - "Araçlar" / "Tools"
- `statsPoints` - "Puan" / "Points"
- `statsDays` - "Gün" / "Days"

---

## 🚀 Execution Order

1. Add new strings to `app_en.arb` and `app_tr.arb`
2. Update `app_localizations.dart` abstract class
3. Update `app_localizations_en.dart` and `app_localizations_tr.dart`
4. Update `home_dashboard.dart`
5. Update `quiz_page.dart`
6. Update `duel_page.dart`
7. Update `quick_menu_widget.dart`

---

**Last Updated:** $(date +"%Y-%m-%d %H:%M")

