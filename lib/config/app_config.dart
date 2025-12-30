/// Uygulama yapılandırma ayarları
class AppConfig {
  /// Uygulama temel bilgileri
  static const String appName = 'KarbonSon';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'KarbonSon Quiz ve Dostluk Uygulaması';

  /// API yapılandırması
  static const String baseApiUrl = 'https://api.karbonson.com';
  static const String firebaseProjectId = 'karbonson-app';
  static const String firebaseApiKey = 'your-api-key';
  static const String firebaseAppId = 'your-app-id';
  static const String firebaseMessagingSenderId = 'your-sender-id';
  static const String firebaseStorageBucket = 'karbonson-app.appspot.com';

  /// Quiz sistemi ayarları
  static const int defaultQuizQuestions = 10;
  static const int maxQuizQuestions = 50;
  static const int minQuizQuestions = 5;
  static const Duration quizTimeLimit = Duration(minutes: 10);
  static const Duration questionTimeLimit = Duration(seconds: 30);

  /// Bildirim ayarları
  static const String notificationChannelId = 'karbonson_channel';
  static const String notificationChannelName = 'KarbonSon Bildirimleri';
  static const String notificationChannelDescription = 'Quiz ve dostluk bildirimleri';

  /// Friend sistemi ayarları
  static const int maxFriends = 100;
  static const int maxFriendRequests = 50;

  /// Cache ayarları
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  /// Debug ayarları
  static const bool enableDebugLogs = true;
  static const bool enableNetworkLogs = false;
  static const bool enablePerformanceLogs = false;

  /// Environment constants
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';

  static String get currentEnvironment => 
    const bool.fromEnvironment('dart.vm.product') ? production : development;

  /// Feature flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}