import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Eğer arka plan işleyicisinde (handler) başka Firebase servisi kullanıyorsanız
// buraya 'package:firebase_core/firebase_core.dart' eklemeniz ve 
// handler içinde Firebase.initializeApp() yapmanız gerekebilir.

// 🔥 1. KRİTİK: Arka plan mesaj işleyicisi (handler) bir 
// TOP-LEVEL fonksiyon olmalıdır (yani bir sınıfın içinde olmamalıdır).
// @pragma('vm:entry-point') etiketi, Flutter'ın bu fonksiyonu 
// izole bir ortamda bile bulabilmesini sağlar.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Eğer burada Firestore, Realtime DB vb. kullanacaksanız, 
  // Firebase.initializeApp(); çağrısını eklemelisiniz.
  print('Handling a background message: ${message.messageId}');
  // Arka plan bildirimleri genellikle burada işlenir (veritabanına kaydetme vb.)
}


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Firebase izinlerini iste (iOS cihazlar için ana izin kaynağı)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

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

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Bildirime dokunma olayını ele alın
        print('Notification tapped: ${response.payload}');
        // Burada kullanıcıyı payload'a göre ilgili sayfaya yönlendirebilirsiniz.
      },
    );

    // 3. Arka plan mesajlarını top-level handler'a yönlendir
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Ön plan (uygulama açıksa) mesajlarını dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // FCM bildirimini al, yerel bildirim olarak göster.
      _showNotification(
        title: message.notification?.title ?? 'New Message',
        body: message.notification?.body ?? '',
        // IMPROVEMENT: Bildirim dokunulduğunda kullanılmak üzere payload'ı ekle
        payload: message.data.toString(), 
      );
    });
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
    return await _messaging.getToken();
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}