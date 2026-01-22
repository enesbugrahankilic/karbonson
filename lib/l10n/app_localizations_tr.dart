// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get hello => 'Merhaba';

  @override
  String get world => 'Dünya';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get noNotifications => 'Henüz bildirim yok';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get markAllAsRead => 'Tümünü Okundu Olarak İşaretle';

  @override
  String get unreadNotifications => 'Okunmamış Bildirimler';

  @override
  String get allNotifications => 'Tüm Bildirimler';

  @override
  String get friendRequest => 'Arkadaş İsteği';

  @override
  String get friendRequestAccepted => 'Arkadaş İsteği Kabul Edildi';

  @override
  String get friendRequestRejected => 'Arkadaş İsteği Reddedildi';

  @override
  String get gameInvitation => 'Oyun Daveti';

  @override
  String get duelInvitation => 'Düello Daveti';

  @override
  String get viewNotifications => 'Bildirimleri Görüntüle';

  @override
  String notificationDescription(Object count) {
    return '$count adet okunmamış bildiriminiz var';
  }

  @override
  String get noNotificationsDescription => 'Bildirimleriniz burada görünecek';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(Object count) {
    return '$count dakika önce';
  }

  @override
  String hoursAgo(Object count) {
    return '$count saat önce';
  }

  @override
  String daysAgo(Object count) {
    return '$count gün önce';
  }

  @override
  String get welcomeBack => 'Tekrar Hoş Geldiniz';

  @override
  String get helloEmoji => 'Merhaba 👋';

  @override
  String get loadingData => 'Veri yükleniyor...';

  @override
  String get totalPoints => 'Toplam Puan';

  @override
  String get achievementCount => 'Başarım Sayısı';

  @override
  String get quickAccess => 'Hızlı Erişim';

  @override
  String get progressAndAchievements => 'İlerleme ve Başarımlar';

  @override
  String get startQuiz => 'Quiz Başlat';

  @override
  String get duelMode => 'Düello Modu';

  @override
  String get teamPlay => 'Takım Oyunu';

  @override
  String get dailyChallenges => 'Günlük Görevler';

  @override
  String get statisticsSummary => 'İstatistik Özeti';

  @override
  String get recentActivity => 'Son Etkinlikler';

  @override
  String get play => 'Oyna';

  @override
  String get start => 'Başlat';

  @override
  String get create => 'Oluştur';

  @override
  String get join => 'Katıl';

  @override
  String get badges => 'Rozetler';

  @override
  String get homePageTitle => 'Ana Sayfa';

  @override
  String get quickAccessTitle => 'Hızlı Erişim';

  @override
  String get quizInfoTitle => 'Hızlı Quiz Başlat';

  @override
  String get ecoQuizTitle => 'Çevre Bilgi Quiz\'i';

  @override
  String get startQuizAction => 'Şimdi Başla';

  @override
  String get increaseAwareness => 'Çevre bilincini artır, puan kazan!';

  @override
  String get quickAccessSettings => 'Ayarlar';

  @override
  String get quickAccessProfile => 'Profil';

  @override
  String get noActivities => 'Henüz etkinlik yok';

  @override
  String get activityHint => 'Etkinliklerini gör';

  @override
  String get levelProgress => 'Seviye İlerlemesi';

  @override
  String get quizStatistics => 'Quiz İstatistikleri';

  @override
  String get totalQuizzes => 'Toplam Quiz';

  @override
  String get correctRate => 'Doğruluk Oranı';

  @override
  String get averageTime => 'Ortalama Süre';

  @override
  String get recentAchievements => 'Son Başarımlar';

  @override
  String get noAchievements => 'Henüz başarı yok';

  @override
  String get achievementsHint => 'Quiz yaparak başarı kazan!';

  @override
  String get totalTime => 'Toplam Süre';

  @override
  String get longestStreak => 'En Uzun Seri';

  @override
  String get loginStreak => 'Giriş Serisi';

  @override
  String get highestScore => 'En Yüksek Skor';

  @override
  String get quizScore => 'Quiz skoru';

  @override
  String get duelWinRate => 'Düello Kazanma Oranı';

  @override
  String get totalDuels => 'düello';

  @override
  String get weeklyActivity => 'Haftalık Etkinlik';

  @override
  String get noDailyChallenges => 'Bugün için görev yok';

  @override
  String get newChallengesTomorrow => 'Yarın yeni görevler!';

  @override
  String get challengeReward => 'Ödül:';

  @override
  String get challengePoints => 'Puan';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get startupError => 'Başlatma Hatası';

  @override
  String get startupErrorDescription =>
      'Başlatma sırasında bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get appNameHighContrast => 'KarbonSon';

  @override
  String get appName => 'KarbonSon';

  @override
  String get settings => 'Ayarlar';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Koyu Mod';

  @override
  String get lightMode => 'Açık Mod';

  @override
  String get language => 'Dil';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Sürüm';

  @override
  String get twoFactorAuth => 'İki Faktörlü Kimlik Doğrulama';

  @override
  String get close => 'Kapat';

  @override
  String get cancel => 'İptal';
}
