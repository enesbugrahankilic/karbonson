import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
// Eğer arka plan işleyicisinde (handler) başka Firebase servisi kullanıyorsanız
// buraya 'package:firebase_core/firebase_core.dart' eklemeniz ve 
// handler içinde Firebase.initializeApp() yapmanız gerekebilir.

// 🔥 1. KRİTİK: Arka plan mesaj işleyicisi (handler) bir 
// TOP-LEVEL fonksiyon olmalıdır (yani bir sınıfın içinde olmamalıdır).
// @pragma('vm:entry-point') etiketi, Flutter'ın bu fonksiyonu 
// izole bir ortamda bile bulabilmesini sağlar.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Sadece Firestore, Realtime DB vb. kullanıyorsanız ve main.dart'ta başlatma yoksa ekleyin.
  // Bu projede main.dart'ta başlatma var, burada tekrar başlatmaya gerek yok!
  if (kDebugMode) debugPrint('Handling a background message: ${message.messageId}');
}


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kDebugMode) debugPrint('NotificationService: initialize() start');
    FirebaseMessaging? messaging;
    try {
      messaging = FirebaseMessaging.instance;
    } catch (e, st) {
      // If Firebase isn't initialized yet, accessing instance may fail; log and continue.
      if (kDebugMode) debugPrint('NotificationService: FirebaseMessaging.instance not available yet: $e');
      if (kDebugMode) debugPrint('$st');
    }

    try {
      // 1. Firebase izinlerini iste (iOS cihazlar için ana izin kaynağı)
      if (messaging != null) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } else {
        if (kDebugMode) debugPrint('NotificationService: skipping requestPermission (no messaging instance)');
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: requestPermission failed: $e');
      if (kDebugMode) debugPrint('$st');
    }

    // 2. Yerel bildirim ayarlarını başlat
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // 🔥 2. KRİTİK DÜZELTME: Yerel bildirim başlatma ayarlarında 
    // iOS izin isteklerini TRUE yapıyoruz.
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) debugPrint('Notification tapped: ${response.payload}');
        },
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: _notifications.initialize failed: $e');
      if (kDebugMode) debugPrint('$st');
    }

    // 3. Arka plan mesajlarını top-level handler'a yönlendir
    try {
      if (messaging != null) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } else {
        if (kDebugMode) debugPrint('NotificationService: skipping onBackgroundMessage registration');
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: onBackgroundMessage registration failed: $e');
      if (kDebugMode) debugPrint('$st');
    }

    // 4. Ön plan (uygulama açıksa) mesajlarını dinle
    try {
      if (messaging != null) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // FCM bildirimini al, yerel bildirim olarak göster.
          _showNotification(
            title: message.notification?.title ?? 'New Message',
            body: message.notification?.body ?? '',
            payload: message.data.toString(),
          );
        });
      } else {
        if (kDebugMode) debugPrint('NotificationService: skipping onMessage listener (no messaging instance)');
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: onMessage listener failed: $e');
      if (kDebugMode) debugPrint('$st');
    }
    if (kDebugMode) debugPrint('NotificationService: initialize() finished');
  }


  static Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel', // Kanal ID'si
      'Genel Bildirimler', // Kanal Adı
      channelDescription: 'Bu kanal genel uygulama bildirimleri için kullanılır.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true, // Uyarı göster
      presentBadge: true, // Rozet göster
      presentSound: true, // Ses çal
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      // Her bildirim için benzersiz ID
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // --- Yardımcı Metotlar ---

  static Future<String?> getToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      return await messaging.getToken();
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: getToken failed: $e');
      if (kDebugMode) debugPrint('$st');
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.subscribeToTopic(topic);
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: subscribeToTopic failed: $e');
      if (kDebugMode) debugPrint('$st');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.unsubscribeFromTopic(topic);
    } catch (e, st) {
      if (kDebugMode) debugPrint('NotificationService: unsubscribeFromTopic failed: $e');
      if (kDebugMode) debugPrint('$st');
    }
  }

  // --- Yerel Bildirim Zamanlama Metotları ---

  static Future<void> scheduleHighScoreNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'high_score_channel',
      'Yüksek Skor Bildirimleri',
      channelDescription: 'Yeni yüksek skor elde edildiğinde bildirim.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 1,
      '🎉 Yeni Yüksek Skor!',
      'Tebrikler! Quiz puanında yeni bir rekora ulaştınız!',
      details,
    );
  }

  static Future<void> scheduleReminderNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Hatırlatma Bildirimleri',
      channelDescription: 'Uzun süredir oynamadığınızda hatırlatma.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 2,
      '🏃‍♂️ Oyun Zamanı!',
      '12 saattir oynamadınız. Biraz vakit ayırıp quiz oynamaya ne dersiniz?',
      details,
    );
  }

  static Future<void> scheduleDelayedReminderNotification() async {
    // Bu metod şu anda kullanılmıyor - 12 saatlik hatırlatma için farklı bir yaklaşım kullanılacak
    // (örneğin, uygulama açıldığında kontrol etmek)
    await scheduleReminderNotification();
  }

  // --- Oyun Davetiye Bildirimleri ---

  /// Oyun davetiyesi bildirimini göster
  static Future<void> showGameInvitationNotification({
    required String fromNickname,
    required String roomHostNickname,
    required String roomCode,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'game_invitation_channel',
      'Oyun Davetiyeleri',
      channelDescription: 'Arkadaşlarınızın oyun davetiyeleri',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 100,
      '🎮 Oyun Davetiyesi!',
      '$fromNickname size ${roomHostNickname}\'ın odasında oyun oynamak için davet gönderdi! (Kod: $roomCode)',
      details,
      payload: 'game_invitation:$roomCode',
    );
  }

  /// Hızlı oyun davetiyesi bildirimi (2 kişilik düello)
  static Future<void> showDuelInvitationNotification({
    required String fromNickname,
    required String roomCode,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'duel_invitation_channel',
      'Düello Davetiyeleri',
      channelDescription: 'Hızlı düello davetiyeleri',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 101,
      '⚔️ Düello Davetiyesi!',
      '$fromNickname sizi hızlı bir düelloya davet ediyor! (Kod: $roomCode)',
      details,
      payload: 'duel_invitation:$roomCode',
    );
  }

  /// Oyun başladı bildirimi
  static Future<void> showGameStartedNotification({
    required String gameMode,
    required List<String> playerNames,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'game_started_channel',
      'Oyun Başlangıcı',
      channelDescription: 'Oyun başladığında bildirim',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final playersText = playerNames.join(', ');
    await _notifications.show(
      DateTime.now().millisecond + 102,
      '🎯 Oyun Başladı!',
      '$gameMode modunda $playersText ile oyun başladı!',
      details,
      payload: 'game_started:$gameMode',
    );
  }

  /// Oyun bitti bildirimi
  static Future<void> showGameFinishedNotification({
    required String winnerName,
    required String gameMode,
    required int score,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'game_finished_channel',
      'Oyun Sonu',
      channelDescription: 'Oyun bittiğinde bildirim',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 103,
      '🏆 Oyun Bitti!',
      '$gameMode modunda kazanan: $winnerName (Puan: $score)',
      details,
      payload: 'game_finished:$winnerName',
    );
  }

  /// Arkadaşlık isteği bildirimi
  static Future<void> showFriendRequestNotification({
    required String fromNickname,
    required String fromUserId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'friend_request_channel',
      'Arkadaşlık İstekleri',
      channelDescription: 'Yeni arkadaşlık istekleri için bildirim',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 200,
      '👥 Arkadaşlık İsteği!',
      '$fromNickname arkadaşlık isteği gönderdi',
      details,
      payload: 'friend_request:$fromUserId',
    );
  }

  /// Arkadaşlık isteği kabul bildirimi
  static Future<void> showFriendRequestAcceptedNotification({
    required String acceptedByNickname,
    required String acceptedByUserId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'friend_request_accepted_channel',
      'Arkadaşlık Kabul',
      channelDescription: 'Arkadaşlık isteği kabul edildiğinde bildirim',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 201,
      '✅ Arkadaşlık Kabul Edildi!',
      '$acceptedByNickname arkadaşlık isteğinizi kabul etti',
      details,
      payload: 'friend_request_accepted:$acceptedByUserId',
    );
  }

  /// Arkadaşlık isteği red bildirimi
  static Future<void> showFriendRequestRejectedNotification({
    required String rejectedByNickname,
    required String rejectedByUserId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'friend_request_rejected_channel',
      'Arkadaşlık Red',
      channelDescription: 'Arkadaşlık isteği reddedildiğinde bildirim',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond + 202,
      '❌ Arkadaşlık İsteği Reddedildi',
      '$rejectedByNickname arkadaşlık isteğinizi reddetti',
      details,
      payload: 'friend_request_rejected:$rejectedByUserId',
    );
  }
}
