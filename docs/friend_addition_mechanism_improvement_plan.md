# Arkadaş Ekleme Mekanizması Geliştirme Planı

## 📋 Genel Bakış

Bu dokümantasyon, Flutter/Firebase uygulamasında arkadaş ekleme mekanizmasının kapsamlı geliştirmesini açıklar.

## 🎯 Yeni Özellikler

### 1. QR Kod ile Arkadaş Ekleme
- Kullanıcının benzersiz QR kodu oluşturma
- QR kod tarayarak hızlı arkadaş ekleme
- QR kod paylaşımı

### 2. Kullanıcı ID Paylaşımı
- Profil sayfasında User ID görüntüleme
- ID kopyalama özelliği
- ID paylaşım linki oluşturma

### 3. Kullanıcı Engelleme (Block)
- Kullanıcı engelleme mekanizması
- Engellenen kullanıcılardan istek alma
- Engelleme listesi yönetimi

### 4. Arkadaş Önerileri
- Ortak arkadaşlardan öneriler
- "Seninle oynayanlar" önerileri
- Öneri algoritması

### 5. Online Durumu İyileştirme
- Arkadaşların online durumunu gösterme
- Son görülme zamanı
- Realtime presence

### 6. Deep Link Desteği
- Arkadaşlık davet linkleri
- Uygulama içi yönlendirme
- Dynamic Links entegrasyonu

### 7. UI/UX İyileştirmeleri
- Modern arayüz tasarımı
- Hızlı aksiyonlar
- Görsel geri bildirimler
- Animasyonlar

---

## 📁 Dosya Yapısı

```
lib/
├── models/
│   ├── blocked_user.dart          # Engellenen kullanıcı modeli
│   ├── friend_suggestion.dart     # Arkadaş önerisi modeli
│   └── deep_link_data.dart        # Deep link veri modeli
├── services/
│   ├── qr_code_service.dart       # QR kod oluşturma/tarama
│   ├── block_service.dart         # Engelleme yönetimi
│   ├── friend_suggestion_service.dart  # Öneri servisi
│   ├── presence_service.dart      # Online durum servisi (güncelleme)
│   └── deep_link_service.dart     # Deep link servisi (güncelleme)
├── widgets/
│   ├── qr_code_display_widget.dart    # QR kod gösterimi
│   ├── qr_code_scanner_widget.dart    # QR kod tarayıcı
│   ├── user_id_share_widget.dart      # ID paylaşım widget
│   ├── block_user_dialog.dart         # Engelleme dialog
│   ├── friend_suggestion_card.dart    # Öneri kartı
│   ├── presence_indicator_widget.dart # Online durum göstergesi
│   └── add_friend_bottom_sheet.dart   # Arkadaş ekleme bottom sheet
├── pages/
│   └── friends_page.dart          # Arkadaşlar sayfası (güncelleme)
└── utils/
    └── deep_link_utils.dart       # Deep link yardımcı metodları
```

---

## 🔄 Güncellenecek Dosyalar

### 1. `lib/models/friendship_data.dart`
- `BlockedUser` sınıfı eklenecek
- `FriendSuggestion` sınıfı eklenecek
- `PresenceStatus` enum güncellenecek

### 2. `lib/services/friendship_service.dart`
- `sendFriendRequestByUserId()` metodu
- `blockUser()` metodu
- `unblockUser()` metodu
- `getBlockedUsers()` metodu
- `getFriendSuggestions()` metodu
- `isUserBlocked()` metodu

### 3. `lib/services/firestore_service.dart`
- `blocked_users` collection desteği
- `getBlockedUsers()` metodu
- `isUserBlocked()` metodu
- Query/update'ler

### 4. `lib/pages/friends_page.dart`
- QR kod butonu
- ID paylaşım butonu
- Engelleme seçeneği
- Arkadaş önerileri tab'ı
- Online durum göstergeleri
- Bottom sheet entegrasyonu

---

## 📊 Veri Modelleri

### BlockedUser
```dart
class BlockedUser {
  final String id;
  final String blockedUserId;
  final String blockedUserNickname;
  final DateTime blockedAt;
  final String? reason;
}
```

### FriendSuggestion
```dart
class FriendSuggestion {
  final String userId;
  final String nickname;
  final String? profilePictureUrl;
  final String reason; // "common_friends" | "recently_played" | "nearby"
  final int commonFriendsCount;
  final DateTime? lastPlayedTogether;
}
```

### PresenceStatus
```dart
enum PresenceStatus {
  online,
  offline,
  away,
  inGame,
  inMenu,
}
```

---

## 🔗 Deep Link Yapısı

```
karbonson://addfriend/{userId}
https://karbonson.app/addfriend/{userId}
```

### Deep Link İşleme Akışı:
1. Link tıklanır
2. Uygulama açılır veya foreground olur
3. `DeepLinkService` link'i işler
4. Kullanıcı doğrulanır
5. Arkadaş ekleme dialog'u gösterilir
6. İşlem tamamlanır

---

## 🚀 Uygulama Adımları

### Aşama 1: Temel Modeller
- [ ] `blocked_user.dart` oluşturma
- [ ] `friend_suggestion.dart` oluşturma
- [ ] `deep_link_data.dart` oluşturma
- [ ] `friendship_data.dart` güncelleme

### Aşama 2: QR Kod Servisi
- [ ] `qr_code_service.dart` oluşturma
- [ ] QR kod oluşturma
- [ ] QR kod tarama entegrasyonu
- [ ] `qr_code_display_widget.dart`
- [ ] `qr_code_scanner_widget.dart`

### Aşama 3: Engelleme Servisi
- [ ] `block_service.dart` oluşturma
- [ ] `friendship_service.dart` güncelleme
- [ ] Firestore query'leri
- [ ] `block_user_dialog.dart`

### Aşama 4: Arkadaş Önerileri
- [ ] `friend_suggestion_service.dart` oluşturma
- [ ] Öneri algoritması
- [ ] `friend_suggestion_card.dart`
- [ ] Friends page entegrasyonu

### Aşama 5: Presence (Online Durum)
- [ ] `presence_service.dart` güncelleme
- [ ] `presence_indicator_widget.dart`
- [ ] Friends list'te gösterme
- [ ] Profile page entegrasyonu

### Aşama 6: Deep Link
- [ ] `deep_link_service.dart` güncelleme
- [ ] `deep_link_utils.dart`
- [ ] Main.dart entegrasyonu
- [ ] Friends page yönlendirme

### Aşama 7: UI/UX
- [ ] `add_friend_bottom_sheet.dart`
- [ ] `user_id_share_widget.dart`
- [ ] Friends page redesign
- [ ] Animasyonlar ve geçişler
- [ ] Loading states

### Aşama 8: Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] UI tests
- [ ] Documentation

---

## 🔒 Güvenlik

### 1. Engelleme Kontrolü
```dart
// Her arkadaşlık işlemi öncesi
Future<bool> isUserBlocked(String userId) async {
  final blocked = await _blockService.isUserBlocked(userId);
  if (blocked) {
    throw BlockedUserException('Bu kullanıcı engellenmiş');
  }
}
```

### 2. Privacy Settings Entegrasyonu
- [x] Gizlilik ayarlarına saygı
- [x] Online durum kontrolü
- [x] Profile görünürlük

### 3. Rate Limiting
- İstek spam'ı önleme
- QR kod tarama limiti
- Block/unblock rate limiting

---

## 📱 UI Senaryoları

### Senaryo 1: Yeni Arkadaş Ekleme
1. Kullanıcı "+" butonuna tıklar
2. Bottom sheet açılır
3. Seçenekler:
   - QR Kod Tara
   - ID ile Ekle
   - Önerilenler
4. Kullanıcı seçim yapar
5. İşlem tamamlanır

### Senaryo 2: QR Kod ile Ekleme
1. Kullanıcı "QR Kodum" butonuna tıklar
2. QR kod dialog'u açılır
3. Diğer kullanıcı tarar
4. Otomatik arkadaşlık isteği gönderilir

### Senaryo 3: Engelleme
1. Kullanıcı arkadaş listesinde birine tıklar
2. Profil dialog'u açılır
3. "Engelle" butonuna tıklar
4. Onay dialog'u gösterilir
5. Kullanıcı engellenir

### Senaryo 4: Deep Link
1. Kullanıcı davet link'ine tıklar
2. Uygulama açılır
3. Otomatik arkadaşlık isteği dialog'u
4. Kabul/Red seçenekleri

---

## 🔄 Geriye Dönük Uyumluluk

- Mevcut veri yapısı korunacak
- Yeni alanlar opsiyonel olacak
- Migration script hazırlanacak
- Test ortamında doğrulanacak

---

## 📈 Performans

### 1. Query Optimizasyonu
- Index tanımları
- Pagination
- Caching

### 2. Realtime Updates
- Snapshot listeners
- Debouncing
- Throttling

### 3. Offline Support
- Local cache
- Queue system
- Sync strategy

---

## ✅ Checklist

- [ ] Modeller oluşturuldu
- [ ] Servisler yazıldı
- [ ] Widget'lar tasarlandı
- [ ] UI implementasyonu yapıldı
- [ ] Deep link entegrasyonu tamamlandı
- [ ] Güvenlik kontrolleri eklendi
- [ ] Testing yapıldı
- [ ] Documentation tamamlandı

---

**Son Güncelleme:** 2025-11-25  
**Versiyon:** 1.0.0  
**Durum:** 📋 Planlama
