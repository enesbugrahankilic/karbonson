# Arkadaş Ekleme Mekanizması - Kapsamlı Geliştirme Planı

## 📋 Genel Bakış

Bu dokümantasyon, Flutter/Firebase uygulamasında arkadaş ekleme mekanizmasının kapsamlı geliştirmesini ve mevcut mantık hatalarının düzeltmesini açıklar.

---

## 🔧 Düzeltilecek Mantık Hataları

### 1.1 Race Condition ve Double-Click Koruması
**Sorun:** `_acceptFriendRequest` ve `_rejectFriendRequest` metodlarında yarış durumu riski var.

**Çözüm:**
- ✅ İstek geçerliliği kontrolü atomik işlemden önce yapılmalı
- ✅ Processing set kullanarak tekrar eden tıklamalar engellenmeli
- ✅ Başarılı işlem sonrası tek bir `_loadFriendsData()` çağrısı yapılmalı

### 1.2 Çift İstek Gönderme Koruması
**Sorun:** `_sendFriendRequest` metodunda spam kontrolü eksik.

**Çözüm:**
- ✅ Gönderilmiş istek var mı kontrolü yapılmalı
- ✅ Mevcut arkadaş kontrolü yapılmalı
- ✅ Privacy settings kontrolü yapılmalı

### 1.3 QR Scanner Deep Link Entegrasyonu
**Sorun:** QR kod tarandığında deep link formatı düzgün işlenmiyor.

**Çözüm:**
- ✅ `karbonson://addfriend/{userId}` formatı desteklenmeli
- ✅ HTTPS linkler desteklenmeli
- ✅ Doğrudan user ID formatı desteklenmeli

---

## 🚀 Yeni Özellikler

### 2. Add Friend Bottom Sheet
Modern bottom sheet ile arkadaş ekleme seçenekleri:

```dart
// lib/widgets/add_friend_bottom_sheet.dart
class AddFriendBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Kod Tara
            ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text('QR Kod Tara'),
              onTap: () => _openQRScanner(context),
            ),
            // Kullanıcı ID ile Ekle
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Kullanıcı ID ile Ekle'),
              onTap: () => _showUserIdInputDialog(context),
            ),
            // Önerilenlere Git
            ListTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('Önerilenler'),
              onTap: () => _goToSuggestions(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. User ID Görüntüleme ve Paylaşım
Profil sayfasında user ID gösterimi ve paylaşım:

```dart
// lib/widgets/user_id_share_widget.dart
class UserIdShareWidget extends StatelessWidget {
  final String userId;
  final String? nickname;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('Kullanıcı ID', style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  userId,
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyUserId(context),
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareUserId(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 4. QR Kod Görüntüleme Widget'ı
Kişisel QR kod oluşturma ve paylaşma:

```dart
// lib/widgets/qr_code_display_widget.dart
class QRCodeDisplayWidget extends StatelessWidget {
  final String userId;
  final String? nickname;

  @override
  Widget build(BuildContext context) {
    final qrData = 'karbonson://addfriend/$userId';
    
    return Column(
      children: [
        QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 200.0,
          backgroundColor: Colors.white,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.save),
          label: Text('Galeriye Kaydet'),
          onPressed: () => _saveToGallery(context),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.share),
          label: Text('Paylaş'),
          onPressed: () => _shareQRCode(context),
        ),
      ],
    );
  }
}
```

### 5. Kullanıcı Engelleme Özelliği
Arkadaş listesinden engelleme seçeneği:

```dart
// lib/widgets/block_user_dialog.dart
class BlockUserDialog extends StatelessWidget {
  final String userId;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$nickname Engelle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bu kullanıcıyı engellemek istiyor musunuz?'),
          SizedBox(height: 16),
          // Engelleme nedeni seçimi
          DropdownButton<BlockReason>(
            items: BlockReason.values.map((reason) {
              return DropdownMenuItem(
                value: reason,
                child: Text(reason.displayName),
              );
            }).toList(),
            onChanged: (value) {},
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('İptal'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Engelle'),
          onPressed: () => _blockUser(context),
        ),
      ],
    );
  }
}
```

### 6. Deep Link Entegrasyonu
Arkadaş ekleme deep link desteği:

```dart
// lib/core/navigation/deep_link_service.dart güncelleme
void _handleAddFriendDeepLink(String userId) {
  // Navigate to friends page with pre-filled user
  Navigator.pushNamed(
    context,
    '/friends',
    arguments: {'pendingFriendId': userId},
  );
  
  // Show add friend dialog
  showAddFriendDialog(context, userId);
}
```

---

## 📁 Dosya Yapısı

```
lib/
├── widgets/
│   ├── add_friend_bottom_sheet.dart    # YENİ
│   ├── user_id_share_widget.dart       # YENİ
│   ├── qr_code_display_widget.dart     # YENİ
│   ├── block_user_dialog.dart          # YENİ
│   ├── qr_code_scanner_widget.dart     # GÜNCELLEME
│   └── friends_page.dart               # GÜNCELLEME
├── services/
│   ├── firestore_service.dart          # GÜNCELLEME (mantık hataları)
│   ├── friendship_service.dart         # GÜNCELLEME
│   └── qr_code_service.dart            # GÜNCELLEME
├── pages/
│   └── friends_page.dart               # GÜNCELLEME
├── models/
│   └── blocked_user.dart               # GÜNCELLEME
└── core/
    └── navigation/
        └── deep_link_service.dart      # GÜNCELLEME
```

---

## 🔄 Güncellenecek Dosyalar

### 1. `lib/services/firestore_service.dart`
- [ ] `sendFriendRequest()` - Spam kontrolü eklenecek
- [ ] `canSendFriendRequest()` - Privacy kontrolü iyileştirilecek
- [ ] `acceptFriendRequest()` - Race condition düzeltilecek
- [ ] `rejectFriendRequest()` - Race condition düzeltilecek

### 2. `lib/pages/friends_page.dart`
- [ ] Add Friend Floating Button
- [ ] Bottom Sheet entegrasyonu
- [ ] Context menu for friends (block option)
- [ ] Duplicate request check before sending
- [ ] Celebration animation on new friend

### 3. `lib/widgets/qr_code_scanner_widget.dart`
- [ ] Deep link format support
- [ ] Better error handling
- [ ] User ID validation

### 4. `lib/core/navigation/deep_link_service.dart`
- [ ] `addfriend/{userId}` route handling
- [ ] Auto-send friend request from deep link

### 5. `pubspec.yaml`
- [ ] `permission_handler: ^11.3.0` eklenecek
- [ ] `qr_flutter` veya `qrcodegen` eklenecek

---

## 📊 Veri Modelleri

### BlockUser
```dart
class BlockedUser {
  final String id;
  final String blockedUserId;
  final String blockedUserNickname;
  final DateTime blockedAt;
  final BlockReason reason;
  final String? customReason;
  final bool isReported;
}
```

### QRFriendData
```dart
class QRFriendData {
  final String userId;
  final String? nickname;
  final String? profilePictureUrl;
}
```

---

## 🔗 Deep Link Yapısı

```
karbonson://addfriend/{userId}
https://karbonson.app/addfriend/{userId}
```

---

## ✅ Yapılacaklar Listesi

### Aşama 1: Mantık Hataları Düzeltme
- [ ] Race condition düzeltmesi (firestore_service.dart)
- [ ] Spam önleme (friendship_service.dart)
- [ ] Duplicate request kontrolü
- [ ] Test yazımı

### Aşama 2: UI/UX İyileştirmeleri
- [ ] Add Friend Bottom Sheet
- [ ] User ID Share Widget
- [ ] QR Code Display Widget
- [ ] Celebration animation

### Aşama 3: Blocking Özelliği
- [ ] Block User Dialog
- [ ] Block Service
- [ ] Unblock functionality
- [ ] Blocked users list

### Aşama 4: Deep Link & QR
- [ ] Deep link entegrasyonu
- [ ] QR scanner iyileştirme
- [ ] QR code display
- [ ] Share functionality

---

## 🧪 Test Planı

### Unit Tests
- [ ] `sendFriendRequest` spam kontrolü testi
- [ ] `acceptFriendRequest` race condition testi
- [ ] `rejectFriendRequest` race condition testi
- [ ] `canSendFriendRequest` privacy kontrolü testi

### Widget Tests
- [ ] AddFriendBottomSheet render testi
- [ ] QRCodeDisplayWidget testi
- [ ] BlockUserDialog testi

### Integration Tests
- [ ] Tam arkadaş ekleme akışı
- [ ] QR kod ile ekleme akışı
- [ ] Deep link ile ekleme akışı
- [ ] Block/unblock akışı

---

## 📈 Performans

### 1. Query Optimizasyonu
- Index tanımları
- Pagination
- Caching

### 2. Realtime Updates
- Snapshot listeners
- Debouncing

---

## 🔒 Güvenlik

### 1. Privacy Settings
- Friend request privacy
- Profile visibility
- Online status privacy

### 2. Spam Prevention
- Rate limiting
- Duplicate request check
- Blocked user check

---

**Son Güncelleme:** 2025-11-25  
**Başlangıç:** 2025-11-25  
**Tahmini Süre:** 4 gün

