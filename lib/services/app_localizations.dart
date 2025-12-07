import 'package:flutter/material.dart';
import '../services/language_service.dart';

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
  static String get forgotPassword => _isTurkish ? 'Şifremi Unuttum' : 'Forgot Password';
  static String get resetPassword => _isTurkish ? 'Şifreyi Sıfırla' : 'Reset Password';
  static String get email => _isTurkish ? 'E-posta' : 'Email';
  static String get password => _isTurkish ? 'Şifre' : 'Password';
  static String get confirmPassword => _isTurkish ? 'Şifreyi Onayla' : 'Confirm Password';
  static String get username => _isTurkish ? 'Kullanıcı Adı' : 'Username';
  static String get nickname => _isTurkish ? 'Takma Ad' : 'Nickname';
  static String get name => _isTurkish ? 'Ad' : 'Name';
  static String get emailVerification => _isTurkish ? 'E-posta Doğrulaması' : 'Email Verification';
  static String get verifyEmail => _isTurkish ? 'E-postayı Doğrula' : 'Verify Email';
  static String get verificationCodeSent => _isTurkish ? 'Doğrulama kodu e-postanıza gönderildi' : 'Verification code sent to your email';

  // ==================== Profile ====================
  static String get profile => _isTurkish ? 'Profil' : 'Profile';
  static String get profileSettings => _isTurkish ? 'Profil Ayarları' : 'Profile Settings';
  static String get editProfile => _isTurkish ? 'Profili Düzenle' : 'Edit Profile';
  static String get profilePicture => _isTurkish ? 'Profil Fotoğrafı' : 'Profile Picture';
  static String get changeProfilePicture => _isTurkish ? 'Profil Fotoğrafını Değiştir' : 'Change Profile Picture';
  static String get uploadPhoto => _isTurkish ? 'Fotoğraf Yükle' : 'Upload Photo';
  static String get selectFromGallery => _isTurkish ? 'Galeri\'den Seç' : 'Select from Gallery';
  static String get selectAvatar => _isTurkish ? 'Avatar Seç' : 'Select Avatar';
  static String get bio => _isTurkish ? 'Biyografi' : 'Bio';
  static String get statistics => _isTurkish ? 'İstatistikler' : 'Statistics';
  static String get friends => _isTurkish ? 'Arkadaşlar' : 'Friends';
  static String get addFriend => _isTurkish ? 'Arkadaş Ekle' : 'Add Friend';
  static String get removeFriend => _isTurkish ? 'Arkadaştan Çıkar' : 'Remove Friend';

  // ==================== Settings ====================
  static String get settings => _isTurkish ? 'Ayarlar' : 'Settings';
  static String get themeSettings => _isTurkish ? 'Tema Ayarları' : 'Theme Settings';
  static String get languageSettings => _isTurkish ? 'Dil Ayarları' : 'Language Settings';
  static String get darkMode => _isTurkish ? 'Karanlık Mod' : 'Dark Mode';
  static String get lightMode => _isTurkish ? 'Açık Mod' : 'Light Mode';
  static String get darkModeActive => _isTurkish ? 'Karanlık Mod Aktif' : 'Dark Mode Active';
  static String get lightModeActive => _isTurkish ? 'Aydınlık Mod Aktif' : 'Light Mode Active';
  static String get selectLanguage => _isTurkish ? 'Dil Seçin' : 'Select Language';
  static String get language => _isTurkish ? 'Dil' : 'Language';
  static String get theme => _isTurkish ? 'Tema' : 'Theme';
  static String get notifications => _isTurkish ? 'Bildirimler' : 'Notifications';
  static String get privacy => _isTurkish ? 'Gizlilik' : 'Privacy';
  static String get security => _isTurkish ? 'Güvenlik' : 'Security';
  static String get about => _isTurkish ? 'Hakkında' : 'About';
  static String get version => _isTurkish ? 'Sürüm' : 'Version';

  // ==================== Game ====================
  static String get game => _isTurkish ? 'Oyun' : 'Game';
  static String get play => _isTurkish ? 'Oyna' : 'Play';
  static String get singlePlayer => _isTurkish ? 'Tek Oyuncu' : 'Single Player';
  static String get multiPlayer => _isTurkish ? 'Çok Oyuncu' : 'Multiplayer';
  static String get leaderboard => _isTurkish ? 'Liderlik Tablosu' : 'Leaderboard';
  static String get score => _isTurkish ? 'Skor' : 'Score';
  static String get highScore => _isTurkish ? 'En Yüksek Skor' : 'High Score';
  static String get totalScore => _isTurkish ? 'Toplam Skor' : 'Total Score';
  static String get gameMode => _isTurkish ? 'Oyun Modu' : 'Game Mode';
  static String get gameOver => _isTurkish ? 'Oyun Bitti' : 'Game Over';
  static String get winner => _isTurkish ? 'Kazanan' : 'Winner';
  static String get quit => _isTurkish ? 'Çık' : 'Quit';
  static String get resume => _isTurkish ? 'Devam Et' : 'Resume';
  static String get newGame => _isTurkish ? 'Yeni Oyun' : 'New Game';
  static String get rollDice => _isTurkish ? 'Zar At' : 'Roll Dice';
  static String get rollDiceEllipsis => _isTurkish ? 'Zar At!' : 'Roll Dice!';
  static String get quizOpen => _isTurkish ? 'Quiz Açık...' : 'Quiz Open...';
  static String get skipTurns => _isTurkish ? 'Pas Geçiliyor' : 'Skipping';
  static String get quiz => _isTurkish ? 'Quiz' : 'Quiz';
  static String get answer => _isTurkish ? 'Cevap' : 'Answer';
  static String get correct => _isTurkish ? 'Doğru' : 'Correct';
  static String get incorrect => _isTurkish ? 'Yanlış' : 'Incorrect';
  static String get nextQuestion => _isTurkish ? 'Sonraki Soru' : 'Next Question';
  static String get exitGame => _isTurkish ? 'Oyundan Çıkış' : 'Exit Game';
  static String get exitGameConfirmation => _isTurkish ? 'Ana sayfaya dönmek istediğinizden emin misiniz? Mevcut oyun skorunuz kaydedilmeyecektir.' : 'Are you sure you want to return to home page? Your current game score will not be saved.';
  static String get yes => _isTurkish ? 'Evet' : 'Yes';
  static String get no => _isTurkish ? 'Hayır' : 'No';
  static String get player => _isTurkish ? 'Oyuncu' : 'Player';
  static String get playerScores => _isTurkish ? 'Oyuncu Skorları' : 'Player Scores';
  static String get scoreSaved => _isTurkish ? 'Skor kaydedildi.' : 'Score saved.';
  static String get endGameScore => _isTurkish ? 'Oyun Sonu Skoru' : 'Final Game Score';

  // ==================== Biometric ====================
  static String get biometric => _isTurkish ? 'Biyometrik' : 'Biometric';
  static String get biometricSetup => _isTurkish ? 'Biyometrik Kurulum' : 'Biometric Setup';
  static String get enableBiometric => _isTurkish ? 'Biyometriği Etkinleştir' : 'Enable Biometric';
  static String get disableBiometric => _isTurkish ? 'Biyometriği Devre Dışı Bırak' : 'Disable Biometric';
  static String get biometricEnabled => _isTurkish ? 'Biyometrik Etkinleştirildi' : 'Biometric Enabled';
  static String get biometricDisabled => _isTurkish ? 'Biyometrik Devre Dışı' : 'Biometric Disabled';
  static String get authenticateWithBiometric => _isTurkish ? 'Biyometrik ile Kimlik Doğrula' : 'Authenticate with Biometric';

  // ==================== Two Factor Auth ====================
  static String get twoFactorAuth => _isTurkish ? 'İki Faktörlü Kimlik Doğrulama' : 'Two-Factor Authentication';
  static String get enable2FA => _isTurkish ? '2FA\'yı Etkinleştir' : 'Enable 2FA';
  static String get disable2FA => _isTurkish ? '2FA\'yı Devre Dışı Bırak' : 'Disable 2FA';
  static String get verificationCode => _isTurkish ? 'Doğrulama Kodu' : 'Verification Code';
  static String get enterVerificationCode => _isTurkish ? 'Doğrulama Kodunu Girin' : 'Enter Verification Code';
  static String get backupCodes => _isTurkish ? 'Yedek Kodları' : 'Backup Codes';
  static String get saveBackupCodes => _isTurkish ? 'Yedek Kodları Kaydet' : 'Save Backup Codes';

  // ==================== Home & Navigation ====================
  static String get home => _isTurkish ? 'Ana Sayfa' : 'Home';
  static String get navigate => _isTurkish ? 'Gezin' : 'Navigate';
  static String get menu => _isTurkish ? 'Menü' : 'Menu';
  static String get more => _isTurkish ? 'Daha Fazla' : 'More';
  static String get close => _isTurkish ? 'Kapat' : 'Close';

  // ==================== Messages ====================
  static String get welcomeMessage => _isTurkish 
    ? 'Karbonson\'a Hoş Geldiniz!' 
    : 'Welcome to Karbonson!';
  static String get loadingMessage => _isTurkish 
    ? 'Yükleniyor, lütfen bekleyin...' 
    : 'Loading, please wait...';
  static String get errorMessage => _isTurkish 
    ? 'Bir hata oluştu. Lütfen tekrar deneyin.' 
    : 'An error occurred. Please try again.';
  static String get successMessage => _isTurkish 
    ? 'İşlem başarıyla tamamlandı.' 
    : 'Operation completed successfully.';
  static String get confirmAction => _isTurkish 
    ? 'Bu işlemi onaylamak istediğinize emin misiniz?' 
    : 'Are you sure you want to confirm this action?';
  static String get areYouSure => _isTurkish 
    ? 'Emin misiniz?' 
    : 'Are you sure?';

  // ==================== Duel ====================
  static String get duel => _isTurkish ? 'Düello' : 'Duel';
  static String get createDuel => _isTurkish ? 'Düello Oluştur' : 'Create Duel';
  static String get joinDuel => _isTurkish ? 'Düelloya Katıl' : 'Join Duel';
  static String get duelRequests => _isTurkish ? 'Düello İstekleri' : 'Duel Requests';
  static String get invitePlayer => _isTurkish ? 'Oyuncuyu Davet Et' : 'Invite Player';
  static String get waitingForOpponent => _isTurkish ? 'Rakip Bekleniyor...' : 'Waiting for Opponent...';

  // ==================== Errors ====================
  static String get networkError => _isTurkish 
    ? 'Ağ bağlantısı hatası' 
    : 'Network connection error';
  static String get timeoutError => _isTurkish 
    ? 'Bağlantı zaman aşımına uğradı' 
    : 'Connection timeout';
  static String get authenticationError => _isTurkish 
    ? 'Kimlik doğrulama hatası' 
    : 'Authentication error';
  static String get invalidInput => _isTurkish 
    ? 'Geçersiz giriş' 
    : 'Invalid input';
  static String get requiredField => _isTurkish 
    ? 'Bu alan gereklidir' 
    : 'This field is required';
}
