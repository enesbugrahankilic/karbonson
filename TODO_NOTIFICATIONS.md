# Hesap Bazlı Bildirim Sistemi (Account-Based Notification System)

## Görev Listesi

### ✅ Tamamlanan Görevler
- [x] 1. NotificationService'i Firestore entegrasyonu ile güncelle
- [x] 2. Real-time notification stream ekle
- [x] 3. Tüm bildirim türleri için Firestore kayıt metodları ekle
- [x] 4. NotificationsPage'i real-time updates ile güncelle
- [x] 5. Unread notification count badge ekle
- [x] 6. Arkadaşlık isteği bildirimlerini güncelle
- [x] 7. Duel/game davet bildirimlerini güncelle
- [x] 8. Achievement/Reward bildirimlerini güncelle
- [x] 9. Static helper methods for backward compatibility

## Detaylı Plan

### 1. NotificationService Güncelleme
- Firestore bağlantısı ekle
- `saveNotification()` metodu - bildirimi Firestore'a kaydet
- `listenToNotifications()` metodu - real-time dinleme
- `getUnreadCount()` metodu - okunmamış sayısı
- Tüm notification type'lar için create metodları

### 2. NotificationsPage Güncelleme
- StreamBuilder ile real-time updates
- Unread badge gösterimi
- Pull-to-refresh özelliği

### 3. Bildirim Türleri
- friend_request
- friend_request_accepted
- friend_request_rejected
- game_invite
- duel_invite
- achievement_unlocked
- reward_unlocked
- level_up
- daily_challenge
- high_score

## Firebase Yapısı
```
notifications/{userId}/
  └── notifications/{notificationId}/
      ├── id: string
      ├── type: string
      ├── title: string
      ├── message: string
      ├── senderId: string
      ├── senderNickname: string
      ├── additionalData: map
      ├── createdAt: timestamp
      └── isRead: boolean
```

## Notlar
- Bildirimler hesap bazlı (userId) saklanır
- Farklı cihazlardan erişim mümkün
- Real-time sync ile anlık güncelleme

