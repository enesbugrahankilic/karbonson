# Hesap → Cihaz Bildirimi Köprüsü Implementasyon Planı

## 📋 Genel Bakış
Bu proje, hesap bazlı bildirimleri (Firestore'da saklanan) kullanıcının aktif olduğu cihazlara push notification olarak yansıtmayı amaçlar.

## 🎯 Temel Prensip
- **Ana Kaynak**: Firestore'daki hesap bildirimi (Account Notification)
- **Yansıma**: Sadece online cihazlara FCM push (Device Notification)
- **Çoklu Cihaz**: Bir kullanıcının birden fazla cihazını destekle

---

## 📦 Modül 1: Device Token Management
**Dosya**: `lib/services/device_token_service.dart`

### Görevler:
- [ ] DeviceToken model sınıfı oluştur
- [ ] DeviceTokenService singleton implementasyonu
- [ ] saveDeviceToken() - Token kaydetme
- [ ] updateDeviceToken() - Token güncelleme
- [ ] removeDeviceToken() - Token silme
- [ ] getUserDeviceTokens() - Kullanıcının tüm tokenlarını getir
- [ ] cleanupStaleTokens() - Eski tokenları temizle
- [ ] Firestore collection: `users/{uid}/devices/{deviceId}`

### Model Alanları:
```dart
class DeviceToken {
  final String deviceId;
  final String token;
  final String platform; // 'ios' | 'android'
  final String appVersion;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final bool isActive;
}
```

---

## 📦 Modül 2: FCM Service
**Dosya**: `lib/services/fcm_service.dart`

### Görevler:
- [ ] FCM Service singleton implementasyonu
- [ ] initialize() - Firebase Messaging setup
- [ ] getCurrentToken() - Mevcut FCM token alma
- [ ] onTokenRefresh listener - Token değişikliği handling
- [ ] setupMessageHandlers() - Foreground/background message handling
- [ ] showLocalNotification() - Local notification gösterimi
- [ ] updateAppBadge() - Badge sayısını güncelle
- [ ] subscribeToTopic() - Topic subscription
- [ ] unsubscribeFromTopic() - Topic unsubscription

### Message Handler Yapısı:
```dart
// Foreground: showLocalNotification()
// Background: System tray'e düşer
// Terminated: wake up app
```

---

## 📦 Modül 3: Notification Bridge Service
**Dosya**: `lib/services/notification_bridge_service.dart`

### Görevler:
- [ ] NotificationBridgeService singleton implementasyonu
- [ ] sendAccountNotification() - Ana metot
  - [ ] Adım 1: Firestore'a kaydet (notification_service)
  - [ ] Adım 2: Presence kontrolü yap (presence_service)
  - [ ] Adım 3: Online cihaz tokenlarını getir
  - [ ] Adım 4: FCM push gönder
  - [ ] Adım 5: Delivery status update
- [ ] sendNotificationToDevice() - Tek cihaza push
- [ ] sendNotificationToMultipleDevices() - Çoklu cihaza push
- [ ] retryFailedDeliveries() - Başarısız gönderimleri yenile
- [ ] getNotificationDeliveryStatus() - Gönderim durumu sorgula

### Akış:
```
createAccountNotification(recipientId, notification)
        ↓
   [1] Save to Firestore (notifications/{uid}/notifications/{id})
        ↓
   [2] Check user presence via PresenceService
        ↓
   [3] If online: Get device tokens
        ↓
   [4] Send FCM push to online devices
        ↓
   [5] Update delivery status in Firestore
```

---

## 📦 Modül 4: Notification Models
**Dosya**: `lib/models/notification_models.dart`

### Model Sınıfları:
- [ ] **NotificationPreferences** - Kullanıcı bildirim tercihleri
  - [ ] enablePushNotifications
  - [ ] enableInAppNotifications
  - [ ] quietHours (startHour, endHour)
  - [ ] notificationChannels (friendRequests, gameInvites, achievements, etc.)
  
- [ ] **NotificationDeliveryStatus** - Gönderim durumu
  - [ ] notificationId
  - [ ] deviceId
  - [ ] status (pending, sent, delivered, read, failed)
  - [ ] sentAt
  - [ ] deliveredAt
  - [ ] readAt
  - [ ] errorReason

- [ ] **NotificationTemplate** - Bildirim şablonları
  - [ ] friendRequest
  - [ ] gameInvite
  - [ ] achievement
  - [ ] dailyChallenge
  - [ ] reward
  - [ ] levelUp

---

## 📦 Modül 5: Entegrasyon
**Dosya**: `lib/main.dart` güncellemeleri

### Görevler:
- [ ] FCM Service initialization
- [ ] Device Token Service initialization
- [ ] Token registration on login
- [ ] Token cleanup on logout
- [ ] App lifecycle handling (background/foreground)

---

## 📦 Modül 6: Firestore Rules Güncelleme
**Dosya**: `firebase/firestore.rules`

### Görevler:
- [ ] users/{uid}/devices collection için rules
- [ ] notifications/{uid}/notifications delivery status rules
- [ ] NotificationPreferences okuma/yazma rules

---

## 📦 Modül 7: Test ve Dokümantasyon
**Dosya**: `test/notification_bridge_test.dart`

### Görevler:
- [ ] Device token service unit tests
- [ ] FCM service mock tests
- [ ] Notification bridge integration tests
- [ ] Cross-device notification sync test

---

## 🚀 Geliştirme Sırası

### Sprint 1: Temel Altyapı
1. [ ] Device Token Service
2. [ ] Notification Models (DeviceToken, NotificationPreferences)
3. [ ] Basic FCM Service

### Sprint 2: Core Bridge Logic
1. [ ] Notification Bridge Service (presence + push)
2. [ ] NotificationDeliveryStatus model
3. [ ] Bridge entegrasyonu

### Sprint 3: Entegrasyon & UI
1. [ ] Main.dart initialization
2. [ ] Settings page notification preferences UI
3. [ ] Firestore rules

### Sprint 4: Test & Polish
1. [ ] Unit tests
2. [ ] Integration tests
3. [ ] Dokümantasyon

---

## 📁 Dosya Yapısı

```
lib/
├── models/
│   ├── notification_models.dart    # Preferences, Templates, DeliveryStatus
│   └── device_token.dart           # DeviceToken model
├── services/
│   ├── device_token_service.dart   # Çoklu cihaz token yönetimi
│   ├── fcm_service.dart            # Firebase Messaging service
│   ├── notification_bridge_service.dart  # Ana bridge logic
│   └── notification_service.dart   # Mevcut (güncellenecek)
├── main.dart                        # Initialization
test/
└── notification_bridge_test.dart   # Tests

firebase/
└── firestore.rules                  # Güncellenecek
```

---

## 🔑 Önemli Notlar

### Multi-Device Stratejisi
- Her cihaz için benzersiz `deviceId` (UUID + platform kombinasyonu)
- Token yenilendiğinde eski token'ı günceller, yenisini eklemez
- Eski token'ları `lastUsedAt` bazında temizle (30 gün)

### Presence Entegrasyonu
- Kullanıcı online ise: Tüm cihazlara push gönder
- Kullanıcı offline ise: Sadece Firestore'da sakla
- Kullanıcı tekrar online olduğunda: Son bildirimleri gönder (optional)

### Error Handling
- Token geçersiz/hükümsüz: Token'ı inactive olarak işaretle
- FCM error: Retry mekanizması (3 deneme, exponential backoff)
- Rate limiting: FCM quota aşımına karşı önlem

---

## ✅ Tamamlanan Görevler

- [ ] Plan oluşturuldu
- [ ] Analiz tamamlandı
- [ ] Kullanıcı onayı alındı

