import 'package:flutter/material.dart';
import '../services/language_service.dart';

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
}
