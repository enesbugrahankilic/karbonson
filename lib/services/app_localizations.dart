import 'package:flutter/material.dart';

enum AppLanguage { turkish, english }

class AppLocalizations extends ChangeNotifier {
  static AppLanguage _currentLanguage = AppLanguage.turkish;
  static final AppLocalizations _instance = AppLocalizations._internal();

  factory AppLocalizations() {
    return _instance;
  }

  AppLocalizations._internal();

  static void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    _instance.notifyListeners();
  }

  static bool get _isTurkish => _currentLanguage == AppLanguage.turkish;

  // ==================== Common Strings ====================
  static String get appTitle => _isTurkish ? 'Karbonson' : 'Karbonson';
  static String get ok => _isTurkish ? 'Tamam' : 'OK';
  static String get cancel => _isTurkish ? 'İptal' : 'Cancel';
  static String get save => _isTurkish ? 'Kaydet' : 'Save';
  static String get delete => _isTurkish ? 'Sil' : 'Delete';
  static String get edit => _isTurkish ? 'Düzenle' : 'Edit';
  static String get search => _isTurkish ? 'Ara' : 'Search';
  static String get loading => _isTurkish ? 'Yükleniyor...' : 'Loading...';
  static String get error => _isTurkish ? 'Hata' : 'Error';
  static String get success => _isTurkish ? 'Başarılı' : 'Success';
  static String get noData => _isTurkish ? 'Veri Bulunamadı' : 'No Data';
  static String get back => _isTurkish ? 'Geri' : 'Back';

  // ==================== Authentication ====================
  static String get login => _isTurkish ? 'Giriş Yap' : 'Login';
  static String get register => _isTurkish ? 'Kayıt Ol' : 'Register';
  static String get logout => _isTurkish ? 'Çıkış Yap' : 'Logout';
  static String get forgotPassword =>
      _isTurkish ? 'Şifremi Unuttum' : 'Forgot Password';
  static String get resetPassword =>
      _isTurkish ? 'Şifreyi Sıfırla' : 'Reset Password';
  static String get email => _isTurkish ? 'E-posta' : 'Email';
  static String get password => _isTurkish ? 'Şifre' : 'Password';
  static String get confirmPassword =>
      _isTurkish ? 'Şifreyi Onayla' : 'Confirm Password';
  static String get username => _isTurkish ? 'Kullanıcı Adı' : 'Username';
  static String get nickname => _isTurkish ? 'Takma Ad' : 'Nickname';
  static String get name => _isTurkish ? 'Ad' : 'Name';
  static String get emailVerification =>
      _isTurkish ? 'E-posta Doğrulaması' : 'Email Verification';
  static String get verifyEmail =>
      _isTurkish ? 'E-postayı Doğrula' : 'Verify Email';
  static String get verificationCodeSent => _isTurkish
      ? 'Doğrulama kodu e-postanıza gönderildi'
      : 'Verification code sent to your email';

  // ==================== Biometric ====================
  static String get biometric => _isTurkish ? 'Biyometrik' : 'Biometric';
  static String get biometricSetup =>
      _isTurkish ? 'Biyometrik Kurulum' : 'Biometric Setup';
  static String get enableBiometric =>
      _isTurkish ? 'Biyometriği Etkinleştir' : 'Enable Biometric';
  static String get disableBiometric =>
      _isTurkish ? 'Biyometriği Devre Dışı Bırak' : 'Disable Biometric';
  static String get biometricEnabled =>
      _isTurkish ? 'Biyometrik Etkinleştirildi' : 'Biometric Enabled';
  static String get biometricDisabled =>
      _isTurkish ? 'Biyometrik Devre Dışı' : 'Biometric Disabled';
  static String get authenticateWithBiometric => _isTurkish
      ? 'Biyometrik ile Kimlik Doğrula'
      : 'Authenticate with Biometric';

  // ==================== Two Factor Auth ====================
  static String get twoFactorAuth => _isTurkish
      ? 'İki Faktörlü Kimlik Doğrulama'
      : 'Two-Factor Authentication';
  static String get enable2FA =>
      _isTurkish ? '2FA\'yı Etkinleştir' : 'Enable 2FA';
  static String get disable2FA =>
      _isTurkish ? '2FA\'yı Devre Dışı Bırak' : 'Disable 2FA';
  static String get verificationCode =>
      _isTurkish ? 'Doğrulama Kodu' : 'Verification Code';
  static String get enterVerificationCode =>
      _isTurkish ? 'Doğrulama Kodunu Girin' : 'Enter Verification Code';
  static String get backupCodes =>
      _isTurkish ? 'Yedek Kodları' : 'Backup Codes';
  static String get saveBackupCodes =>
      _isTurkish ? 'Yedek Kodları Kaydet' : 'Save Backup Codes';

  // ==================== Messages ====================
  static String get welcomeMessage =>
      _isTurkish ? 'Karbonson\'a Hoş Geldiniz!' : 'Welcome to Karbonson!';
  static String get loadingMessage =>
      _isTurkish ? 'Yükleniyor, lütfen bekleyin...' : 'Loading, please wait...';
  static String get errorMessage => _isTurkish
      ? 'Bir hata oluştu. Lütfen tekrar deneyin.'
      : 'An error occurred. Please try again.';
  static String get successMessage => _isTurkish
      ? 'İşlem başarıyla tamamlandı.'
      : 'Operation completed successfully.';
  static String get confirmAction => _isTurkish
      ? 'Bu işlemi onaylamak istediğinize emin misiniz?'
      : 'Are you sure you want to confirm this action?';
  static String get areYouSure =>
      _isTurkish ? 'Emin misiniz?' : 'Are you sure?';

  // ==================== Duel ====================
  static String get duel => _isTurkish ? 'Düello' : 'Duel';
  static String get createDuel => _isTurkish ? 'Düello Oluştur' : 'Create Duel';
  static String get joinDuel => _isTurkish ? 'Düelloya Katıl' : 'Join Duel';
  static String get duelRequests =>
      _isTurkish ? 'Düello İstekleri' : 'Duel Requests';
  static String get invitePlayer =>
      _isTurkish ? 'Oyuncuyu Davet Et' : 'Invite Player';
  static String get waitingForOpponent =>
      _isTurkish ? 'Rakip Bekleniyor...' : 'Waiting for Opponent...';

  // ==================== Errors ====================
  static String get networkError =>
      _isTurkish ? 'Ağ bağlantısı hatası' : 'Network connection error';
  static String get timeoutError =>
      _isTurkish ? 'Bağlantı zaman aşımına uğradı' : 'Connection timeout';
  static String get authenticationError =>
      _isTurkish ? 'Kimlik doğrulama hatası' : 'Authentication error';
  static String get invalidInput =>
      _isTurkish ? 'Geçersiz giriş' : 'Invalid input';
  static String get requiredField =>
      _isTurkish ? 'Bu alan gereklidir' : 'This field is required';

  // ==================== Default Avatar ====================
  static String get selectDefaultAvatar =>
      _isTurkish ? 'Varsayılan Avatar Seç' : 'Select Default Avatar';

  // ==================== Drawing ====================
  static String get drawing => _isTurkish ? 'Çizim' : 'Drawing';
  static String get draw => _isTurkish ? 'Çiz' : 'Draw';
  static String get clear => _isTurkish ? 'Temizle' : 'Clear';
  static String get undo => _isTurkish ? 'Geri Al' : 'Undo';
  static String get redo => _isTurkish ? 'İleri Al' : 'Redo';
  static String get brushSize => _isTurkish ? 'Fırça Boyutu' : 'Brush Size';
  static String get color => _isTurkish ? 'Renk' : 'Color';
  static String get saveDrawing =>
      _isTurkish ? 'Çizimi Kaydet' : 'Save Drawing';
  static String get drawingSaved =>
      _isTurkish ? 'Çizim kaydedildi' : 'Drawing saved';
  static String get drawingSaveFailed =>
      _isTurkish ? 'Çizim kaydedilemedi' : 'Drawing save failed';

  // ==================== Settings ====================
  static String get settings => _isTurkish ? 'Ayarlar' : 'Settings';
  static String get language => _isTurkish ? 'Dil' : 'Language';
  static String get turkish => _isTurkish ? 'Türkçe' : 'Turkish';
  static String get english => _isTurkish ? 'İngilizce' : 'English';
  static String get notifications =>
      _isTurkish ? 'Bildirimler' : 'Notifications';
  static String get privacy => _isTurkish ? 'Gizlilik' : 'Privacy';
  static String get security => _isTurkish ? 'Güvenlik' : 'Security';
  static String get theme => _isTurkish ? 'Tema' : 'Theme';
  static String get lightTheme => _isTurkish ? 'Açık Tema' : 'Light Theme';
  static String get darkTheme => _isTurkish ? 'Koyu Tema' : 'Dark Theme';
  static String get systemTheme =>
      _isTurkish ? 'Sistem Teması' : 'System Theme';

  // ==================== Home Dashboard ====================
  static String get home => _isTurkish ? 'Ana Sayfa' : 'Home';
  static String get welcome => _isTurkish ? 'Hoş Geldiniz' : 'Welcome';
  static String get quickAccess => _isTurkish ? 'Hızlı Erişim' : 'Quick Access';
  static String get progressAchievements =>
      _isTurkish ? 'İlerleme & Başarılar' : 'Progress & Achievements';
  static String get dailyChallenges =>
      _isTurkish ? 'Günlük Görevler' : 'Daily Challenges';
  static String get recentActivity =>
      _isTurkish ? 'Son Aktiviteler' : 'Recent Activity';
  static String get level => _isTurkish ? 'Seviye' : 'Level';
  static String get experience => _isTurkish ? 'Deneyim' : 'Experience';
  static String get xp => _isTurkish ? 'XP' : 'XP';
  static String get toNextLevel =>
      _isTurkish ? 'Sonraki seviyeye' : 'To next level';
  static String get recentAchievements =>
      _isTurkish ? 'Son Başarılar' : 'Recent Achievements';
  static String get reward => _isTurkish ? 'Ödül' : 'Reward';
  static String get points => _isTurkish ? 'Puan' : 'Points';

  // ==================== Games ====================
  static String get quiz => _isTurkish ? 'Quiz' : 'Quiz';
  static String get leaderboard =>
      _isTurkish ? 'Liderlik Tablosu' : 'Leaderboard';
  static String get friends => _isTurkish ? 'Arkadaşlar' : 'Friends';
  static String get boardGame => _isTurkish ? 'Masa Oyunu' : 'Board Game';
  static String get multiplayer => _isTurkish ? 'Çok Oyunculu' : 'Multiplayer';
  static String get game => _isTurkish ? 'Oyun' : 'Game';
  static String get games => _isTurkish ? 'Oyunlar' : 'Games';
  static String get play => _isTurkish ? 'Oyna' : 'Play';
  static String get score => _isTurkish ? 'Skor' : 'Score';
  static String get highScore => _isTurkish ? 'En Yüksek Skor' : 'High Score';
  static String get time => _isTurkish ? 'Zaman' : 'Time';
  static String get difficulty => _isTurkish ? 'Zorluk' : 'Difficulty';
  static String get easy => _isTurkish ? 'Kolay' : 'Easy';
  static String get medium => _isTurkish ? 'Orta' : 'Medium';
  static String get hard => _isTurkish ? 'Zor' : 'Hard';

  // ==================== Achievements ====================
  static String get achievements => _isTurkish ? 'Başarılar' : 'Achievements';
  static String get achievement => _isTurkish ? 'Başarı' : 'Achievement';
  static String get unlocked => _isTurkish ? 'Kilidi Açıldı' : 'Unlocked';
  static String get locked => _isTurkish ? 'Kilitli' : 'Locked';
  static String get progress => _isTurkish ? 'İlerleme' : 'Progress';
  static String get completed => _isTurkish ? 'Tamamlandı' : 'Completed';
  static String get incomplete => _isTurkish ? 'Tamamlanmadı' : 'Incomplete';
  static String get rarity => _isTurkish ? 'Nadirlik' : 'Rarity';
  static String get common => _isTurkish ? 'Sıradan' : 'Common';
  static String get rare => _isTurkish ? 'Nadir' : 'Rare';
  static String get epic => _isTurkish ? 'Destansı' : 'Epic';
  static String get legendary => _isTurkish ? 'Efsanevi' : 'Legendary';

  // ==================== Social ====================
  static String get addFriend => _isTurkish ? 'Arkadaş Ekle' : 'Add Friend';
  static String get removeFriend =>
      _isTurkish ? 'Arkadaşı Kaldır' : 'Remove Friend';
  static String get friendRequest =>
      _isTurkish ? 'Arkadaşlık İsteği' : 'Friend Request';
  static String get accept => _isTurkish ? 'Kabul Et' : 'Accept';
  static String get reject => _isTurkish ? 'Reddet' : 'Reject';
  static String get online => _isTurkish ? 'Çevrimiçi' : 'Online';
  static String get offline => _isTurkish ? 'Çevrimdışı' : 'Offline';
  static String get lastSeen => _isTurkish ? 'Son görülme' : 'Last seen';
  static String get ago => _isTurkish ? 'önce' : 'ago';
  static String get justNow => _isTurkish ? 'Şimdi' : 'Just now';
  static String get minutes => _isTurkish ? 'dakika' : 'minutes';
  static String get hours => _isTurkish ? 'saat' : 'hours';
  static String get days => _isTurkish ? 'gün' : 'days';

  // ==================== Permissions ====================
  static String get cameraPermission =>
      _isTurkish ? 'Kamera İzni' : 'Camera Permission';
  static String get galleryPermission =>
      _isTurkish ? 'Galeri İzni' : 'Gallery Permission';
  static String get storagePermission =>
      _isTurkish ? 'Depolama İzni' : 'Storage Permission';
  static String get cameraPermissionRequired => _isTurkish
      ? 'Fotoğraf çekmek için kamera iznine ihtiyacımız var'
      : 'Camera permission is required to take photos';
  static String get galleryPermissionRequired => _isTurkish
      ? 'Fotoğraf seçmek için galeri iznine ihtiyacımız var'
      : 'Gallery permission is required to select photos';
  static String get goToSettings =>
      _isTurkish ? 'Ayarlara Git' : 'Go to Settings';
  static String get permissionDenied =>
      _isTurkish ? 'İzin Reddedildi' : 'Permission Denied';

  // ==================== Profile ====================
  static String get profile => _isTurkish ? 'Profil' : 'Profile';

  // ==================== Board Game ====================
  static String get exitGame => _isTurkish ? 'Oyundan Çık' : 'Exit Game';
  static String get exitGameConfirmation => _isTurkish
      ? 'Oyundan çıkmak istediğinize emin misiniz?'
      : 'Are you sure you want to exit the game?';
  static String get yes => _isTurkish ? 'Evet' : 'Yes';
  static String get endGameScore =>
      _isTurkish ? 'Oyun Sonu Skoru' : 'End Game Score';
  static String get playerScores =>
      _isTurkish ? 'Oyuncu Skorları' : 'Player Scores';
  static String get gameOver => _isTurkish ? 'Oyun Bitti' : 'Game Over';
  static String get player => _isTurkish ? 'Oyuncu' : 'Player';
  static String get rollDiceEllipsis =>
      _isTurkish ? 'Zar At...' : 'Roll Dice...';
  static String get quizOpen => _isTurkish ? 'Quiz Açık' : 'Quiz Open';
  static String get skipTurns => _isTurkish ? 'Tur Atla' : 'Skip Turns';

  // ==================== Home Dashboard ====================
  // Loading & Data
  static String get loadingData =>
      _isTurkish ? 'Veriler yükleniyor...' : 'Loading data...';
  static String get noDataAvailable =>
      _isTurkish ? 'Veri bulunamadı' : 'No data available';

  // Welcome Section
  static String get helloEmoji => _isTurkish ? 'Merhaba 👋' : 'Hello 👋';
  static String get user => _isTurkish ? 'Kullanıcı' : 'User';
  static String get pointsAbbrev =>
      _isTurkish ? 'Puan' : 'Points'; // Short for points
  static String get badgesAbbrev =>
      _isTurkish ? 'Rozet' : 'Badges'; // Short for badges
  static String get totalPoints => _isTurkish ? 'Toplam Puan' : 'Total Points';
  static String get achievementCount =>
      _isTurkish ? 'Başarı Sayısı' : 'Achievement Count';

  // Section Titles - Dashboard specific
  static String get dashboardQuickAccess => _isTurkish ? 'Hızlı Erişim' : 'Quick Access';
  static String get dashboardProgressAchievements =>
      _isTurkish ? 'İlerleme & Başarılar' : 'Progress & Achievements';
  static String get quickQuizStart =>
      _isTurkish ? 'Hızlı Quiz Başlat' : 'Quick Quiz Start';
  static String get duelModeMain =>
      _isTurkish ? '⚔️ Düello Modu - Ana Özellik' : '⚔️ Duel Mode - Main Feature';
  static String get multiplayerPlay =>
      _isTurkish ? 'Çoklu Oynama' : 'Multiplayer';
  static String get dailyChallengesSection =>
      _isTurkish ? 'Günlük Görevler' : 'Daily Challenges';
  static String get statisticsSummary =>
      _isTurkish ? 'İstatistik Özeti' : 'Statistics Summary';
  static String get dashboardRecentActivity =>
      _isTurkish ? 'Son Aktiviteler' : 'Recent Activity';
  static String get teamPlay => _isTurkish ? 'Takım Oyunu' : 'Team Play';

  // Quiz Section
  static String get ecoKnowledgeQuiz =>
      _isTurkish ? 'Çevre Bilgisi Quiz\'i' : 'Eco Knowledge Quiz';
  static String get increaseEcoAwareness =>
      _isTurkish ? 'Çevre bilincini artır, puan kazan!' : 'Increase eco awareness, earn points!';
  static String get startNow => _isTurkish ? 'Şimdi Başlat' : 'Start Now';

  // Duel Section
  static String get quickDuelButton =>
      _isTurkish ? 'Hızlı Düello' : 'Quick Duel';
  static String get competeWithFriend =>
      _isTurkish ? 'Arkadaşınla hızlı yarış!' : 'Compete with your friend quickly!';
  static String get duelStart => _isTurkish ? 'Başlat' : 'Start';
  static String get createRoom =>
      _isTurkish ? 'Oda Oluştur' : 'Create Room';
  static String get permanentRoom =>
      _isTurkish ? 'Kalıcı düello odası' : 'Permanent duel room';
  static String get duelCreate => _isTurkish ? 'Oluştur' : 'Create';

  // Multiplayer Section
  static String get playUpToPlayers =>
      _isTurkish ? '4 kişiye kadar oyna!' : 'Play with up to 4 players!';
  static String get multiplayerCreateRoom =>
      _isTurkish ? 'Oda Oluştur' : 'Create Room';
  static String get joinWithCode =>
      _isTurkish ? 'Koda Katıl' : 'Join with Code';
  static String get activeRooms =>
      _isTurkish ? 'Aktif Odalar' : 'Active Rooms';
  static String get multiplayerPlayButton =>
      _isTurkish ? 'Oyna' : 'Play';



  // Quiz Statistics
  static String get quizStatistics =>
      _isTurkish ? 'Quiz İstatistikleri' : 'Quiz Statistics';
  static String get totalQuizzes =>
      _isTurkish ? 'Toplam Quiz' : 'Total Quizzes';
  static String get correctRate =>
      _isTurkish ? 'Doğru Oran' : 'Correct Rate';
  static String get averageTime =>
      _isTurkish ? 'Ort. Süre' : 'Avg. Time';

  // Recent Achievements - Dashboard specific
  static String get dashboardRecentAchievements =>
      _isTurkish ? 'Son Başarılar' : 'Recent Achievements';
  static String get noAchievementsYet =>
      _isTurkish ? 'Henüz başarı kazanmadınız' : 'No achievements yet';
  static String get achievementsHint =>
      _isTurkish ? 'Quiz çözerek başarı kazanmaya başlayın!' : 'Start earning achievements by taking quizzes!';

  // Statistics Cards
  static String get totalTime => _isTurkish ? 'Toplam Süre' : 'Total Time';
  static String get gameTime => _isTurkish ? 'Oyun süresi' : 'Game time';
  static String get longestStreak =>
      _isTurkish ? 'En Uzun Seri' : 'Longest Streak';
  static String get loginStreak =>
      _isTurkish ? 'Giriş Serisi' : 'Login Streak';
  static String get highestScore =>
      _isTurkish ? 'En Yüksek Skor' : 'Highest Score';
  static String get quizScore =>
      _isTurkish ? 'Quiz skoru' : 'Quiz score';
  static String get duelWins =>
      _isTurkish ? 'Düello Kazanma' : 'Duel Wins';
  static String get totalDuels =>
      _isTurkish ? 'düello' : 'duels';

  // Weekly Activity
  static String get weeklyActivity =>
      _isTurkish ? 'Haftalık Aktivite' : 'Weekly Activity';

  // Daily Challenges
  static String get noDailyChallenges =>
      _isTurkish ? 'Bugün için görev bulunamadı' : 'No challenges for today';
  static String get newChallengesTomorrow =>
      _isTurkish ? 'Yarın yeni günlük görevler sizi bekliyor!' : 'New daily challenges await you tomorrow!';

  // Activity
  static String get noActivities =>
      _isTurkish ? 'Henüz aktivite bulunmuyor' : 'No activities yet';
  static String get activitiesHint =>
      _isTurkish ? 'Quiz çözerek, düello yaparak aktivitelerinizi görün!' : 'See your activities by taking quizzes and duels!';

  // Time Ago - Dashboard specific
  static String get daysAgo => _isTurkish ? 'gün önce' : 'days ago';
  static String get hoursAgo => _isTurkish ? 'saat önce' : 'hours ago';
  static String get minutesAgo => _isTurkish ? 'dakika önce' : 'minutes ago';
  static String get dashboardJustNow => _isTurkish ? 'Az önce' : 'Just now';

  // Quick Menu
  static String get quickMenu => _isTurkish ? 'Hızlı Menü' : 'Quick Menu';
  static String get featuresDiscover =>
      _isTurkish ? 'özellik keşfet' : 'features to discover';

  // Help Dialog
  static String get helpInfo => _isTurkish ? 'Yardım & Bilgi' : 'Help & Info';
  static String get aboutApp =>
      _isTurkish ? 'Uygulama Hakkında' : 'About App';
  static String get appDescription =>
      _isTurkish ? 'Quiz çözerek çevre bilginizi test edin!' : 'Test your environmental knowledge by taking quizzes!';
  static String get quizModeInfo =>
      _isTurkish ? 'Quiz Modu' : 'Quiz Mode';
  static String get quizModeDescription => _isTurkish
      ? 'Farklı çevre temalarından sorular çözün'
      : 'Solve questions from different environmental themes';
  static String get duelModeInfo =>
      _isTurkish ? 'Düello Modu' : 'Duel Mode';
  static String get duelModeDescription => _isTurkish
      ? 'Arkadaşlarınızla yarışın!'
      : 'Compete with your friends!';
  static String get teamGameInfo =>
      _isTurkish ? 'Takım Oyunu' : 'Team Game';
  static String get teamGameDescription => _isTurkish
      ? 'Birlikte oynayın!'
      : 'Play together!';
  static String get achievementsBadgesInfo =>
      _isTurkish ? 'Başarılar & Rozetler' : 'Achievements & Badges';
  static String get achievementsDescription => _isTurkish
      ? 'Rozetler kazanın!'
      : 'Earn badges!';
  static String get understood => _isTurkish ? 'Anladım' : 'Understood';
  static String get supportEmail =>
      _isTurkish ? 'Destek için:' : 'Support:';
  static String get supportAddress =>
      _isTurkish ? 'support@ecogame.app' : 'support@ecogame.app';

  // Quick Access Buttons
  static String get settingsBtn =>
      _isTurkish ? 'Ayarlar' : 'Settings';
  static String get profileBtn =>
      _isTurkish ? 'Profil' : 'Profile';

  // Quick Stats
  static String get statLevel =>
      _isTurkish ? 'Seviye' : 'Level';
  static String get statStreak =>
      _isTurkish ? 'Seri' : 'Streak';

  // Challenge Reward - Dashboard specific
  static String get dashboardReward => _isTurkish ? 'Ödül:' : 'Reward:';
  static String get rewardPoints =>
      _isTurkish ? 'Puan' : 'Points';

  // Multiplayer Features
  static String get featureCreateRoom =>
      _isTurkish ? 'Oda Oluştur' : 'Create Room';
  static String get featureJoinCode =>
      _isTurkish ? 'Koda Katıl' : 'Join with Code';
  static String get featureActiveRooms =>
      _isTurkish ? 'Aktif Odalar' : 'Active Rooms';

  // Profile Picture Dialog
  static String get selectProfilePicture =>
      _isTurkish ? 'Profil Resmi Seç' : 'Select Profile Picture';
  static String get takePhoto =>
      _isTurkish ? 'Fotoğraf Çek' : 'Take Photo';

  // Theme Selection Dialog
  static String get selectQuizTheme =>
      _isTurkish ? 'Quiz Teması Seç' : 'Select Quiz Theme';
  static String get chooseTheme =>
      _isTurkish ? 'Hangi çevre temasında yarışmak istersiniz?' : 'Which environmental theme would you like to compete in?';
  static String get allTopics =>
      _isTurkish ? 'Tümü' : 'All';
  static String get allTopicsDescription => _isTurkish
      ? 'Tüm çevre konularından karışık sorular'
      : 'Mixed questions from all environmental topics';
  static String get energyTopic =>
      _isTurkish ? 'Enerji' : 'Energy';
  static String get energyDescription => _isTurkish
      ? 'Enerji tasarrufu ve sürdürülebilir enerji'
      : 'Energy conservation and sustainable energy';
  static String get waterTopic =>
      _isTurkish ? 'Su' : 'Water';
  static String get waterDescription => _isTurkish
      ? 'Su tasarrufu ve su kaynakları yönetimi'
      : 'Water conservation and water resources management';
  static String get forestTopic =>
      _isTurkish ? 'Orman' : 'Forest';
  static String get forestDescription => _isTurkish
      ? 'Orman koruma ve ağaçlandırma çalışmaları'
      : 'Forest protection and afforestation';
  static String get recyclingTopic =>
      _isTurkish ? 'Geri Dönüşüm' : 'Recycling';
  static String get recyclingDescription => _isTurkish
      ? 'Atık yönetimi ve geri dönüşüm'
      : 'Waste management and recycling';
  static String get transportationTopic =>
      _isTurkish ? 'Ulaşım' : 'Transportation';
  static String get transportationDescription => _isTurkish
      ? 'Çevre dostu ulaşım alternatifleri'
      : 'Eco-friendly transportation alternatives';
  static String get consumptionTopic =>
      _isTurkish ? 'Tüketim' : 'Consumption';
  static String get consumptionDescription => _isTurkish
      ? 'Sürdürülebilir tüketim alışkanlıkları'
      : 'Sustainable consumption habits';
  static String get rememberThemeChoice =>
      _isTurkish ? 'Bu temayı hatırla' : 'Remember this theme';
  static String get rememberThemeSubtitle => _isTurkish
      ? '(sonraki quiz\'lerde otomatik seçilsin)'
      : '(automatically selected in next quizzes)';

  // Duel Options Dialog
  static String get duelOptions =>
      _isTurkish ? 'Düello Seçenekleri' : 'Duel Options';
  static String get duelQuestion =>
      _isTurkish ? 'Hangi düello türünü tercih edersiniz?' : 'Which duel type do you prefer?';
  static String get fastDuel =>
      _isTurkish ? 'Hızlı Düello' : 'Fast Duel';
  static String get fastDuelDescription =>
      _isTurkish ? '5 soru, 15 saniye süre' : '5 questions, 15 seconds each';
  static String get roomDuelOption =>
      _isTurkish ? 'Oda Düellosu' : 'Room Duel';
  static String get roomDuelDescription =>
      _isTurkish ? 'Kalıcı oda ile arkadaşınla oyna' : 'Play with your friend in a permanent room';

  // Quiz Completion Dialog
  static String get quizCompletedTitle =>
      _isTurkish ? 'Quiz Tamamlandı!' : 'Quiz Completed!';
  static String get scoreFormat =>
      _isTurkish ? '$score/15' : '$score/15';
  static String get greatPerformance => _isTurkish
      ? 'Harika! Çevre konusunda çok bilgilisiniz!'
      : 'Great! You are very knowledgeable about environmental topics!';
  static String get goodPerformance => _isTurkish
      ? 'Güzel! Daha fazla öğrenebilirsiniz.'
      : 'Good! You can learn more.';
  static String get keepLearning => _isTurkish
      ? 'Çalışmaya devam edin, çevre bilinciniz artacak!'
      : 'Keep learning, your environmental awareness will increase!';
  static String get learningSuggestion =>
      _isTurkish ? 'Öğrenme Önerisi' : 'Learning Suggestion';
  static String get learningSuggestionText => _isTurkish
      ? 'Bir sonraki quiz\'te yanlış cevapladığınız konulardan daha fazla soru çıkacak.'
      : 'In the next quiz, more questions will appear from the topics you answered incorrectly.';
  static String get homeBtn =>
      _isTurkish ? 'Ana Sayfa' : 'Home';
  static String get changeTheme =>
      _isTurkish ? 'Tema Değiştir' : 'Change Theme';
  static String get playAgainBtn =>
      _isTurkish ? 'Tekrar Oyna' : 'Play Again';

  // Weekly Chart
  static String get monday => _isTurkish ? 'Pzt' : 'Mon';
  static String get tuesday => _isTurkish ? 'Sal' : 'Tue';
  static String get wednesday => _isTurkish ? 'Çar' : 'Wed';
  static String get thursday => _isTurkish ? 'Per' : 'Thu';
  static String get friday => _isTurkish ? 'Cum' : 'Fri';
  static String get saturday => _isTurkish ? 'Cmt' : 'Sat';
  static String get sunday => _isTurkish ? 'Paz' : 'Sun';

  // Challenge Icons (for display)
  static String get brainIcon => _isTurkish ? '🧠' : '🧠';
  static String get swordsIcon => _isTurkish ? '⚔️' : '⚔️';
  static String get peopleIcon => _isTurkish ? '👥' : '👥';
  static String get handshakeIcon => _isTurkish ? '🤝' : '🤝';
  static String get lightningIcon => _isTurkish ? '⚡' : '⚡';
  static String get diamondIcon => _isTurkish ? '💎' : '💎';

  // Challenge Types
  static String get quizChallenge =>
      _isTurkish ? 'Quiz Görevi' : 'Quiz Challenge';
  static String get duelChallenge =>
      _isTurkish ? 'Düello Görevi' : 'Duel Challenge';
  static String get multiplayerChallenge =>
      _isTurkish ? 'Çoklu Oyun Görevi' : 'Multiplayer Game Challenge';
  static String get socialChallenge =>
      _isTurkish ? 'Sosyal Görev' : 'Social Challenge';
  static String get specialChallenge =>
      _isTurkish ? 'Özel Görev' : 'Special Challenge';

  // Error Messages
  static String get errorUpdatingProfile =>
      _isTurkish ? 'Profil güncellenirken hata oluştu' : 'Error updating profile';
  static String get errorUploadingImage =>
      _isTurkish ? 'Resim yüklenirken hata oluştu' : 'Error uploading image';
  static String get profileUpdated =>
      _isTurkish ? 'Profil resmi güncellendi' : 'Profile picture updated';

  // Days of week full names
  static String get mondayFull => _isTurkish ? 'Pazartesi' : 'Monday';
  static String get tuesdayFull => _isTurkish ? 'Salı' : 'Tuesday';
  static String get wednesdayFull => _isTurkish ? 'Çarşamba' : 'Wednesday';
  static String get thursdayFull => _isTurkish ? 'Perşembe' : 'Thursday';
  static String get fridayFull => _isTurkish ? 'Cuma' : 'Friday';
  static String get saturdayFull => _isTurkish ? 'Cumartesi' : 'Saturday';
  static String get sundayFull => _isTurkish ? 'Pazar' : 'Sunday';
}
