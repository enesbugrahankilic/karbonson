# Kapsamlı Uygulama Planı

## 📱 BÖLÜM 1: QR Kod Paylaşım Özelliği

### 1.1 Paket Entegrasyonu
- [ ] `share_plus` paketini pubspec.yaml'a ekle
- [ ] iOS configuration (Info.plist güncelle)
- [ ] Android configuration (AndroidManifest.xml güncelle)

### 1.2 QR Görseli Oluşturma Servisi
- [ ] `QRImageService` sınıfı oluştur
- [ ] QR kodunu PNG byte'larına dönüştür
- [ ] MemoryImage desteği ekle
- [ ] Widget'tan görsel yakalama desteği

### 1.3 Paylaşım Servisi (QRShareService)
- [ ] WhatsApp paylaşım desteği (text + image)
- [ ] Gmail paylaşım desteği (mailto: link)
- [ ] Sistem paylaşım menüsü entegrasyonu
- [ ] Platform-specific URL şemaları
- [ ] Hata yönetimi ve fallback

### 1.4 UI Güncellemeleri (UserIdShareWidget)
- [ ] Paylaşım butonları ekle (WhatsApp, Gmail, Paylaş)
- [ ] Animasyonlu buton tasarımı
- [ ] Loading state'leri
- [ ] Success/error feedback
- [ ] Responsive tasarım

### 1.5 Localization
- [ ] Türkçe localization strings ekle
- [ ] İngilizce localization strings ekle
- [ ] Dynamic string keys

---

## 🔄 BÖLÜM 2: Dinamik Veri Sistemi (Backend Entegrasyonu)

### 2.1 Firestore Schema Tasarımı

#### 2.1.1 Achievements Collection
```
/app_config/achievements/{achievement_id}
- id: string
- title: string
- description: string
- icon: string
- category: string (quiz, duel, multiplayer, social, streak, special)
- points: number
- requirements: map
- rarity: string (common, rare, epic, legendary)
- version: number
- isActive: boolean
- order: number
- metadata: map
```

#### 2.1.2 Rewards Collection
```
/app_config/rewards/{reward_id}
- id: string
- name: string
- description: string
- icon: string
- type: string (avatar, theme, feature)
- rarity: string (common, rare, epic, legendary)
- unlockRequirement: number
- unlockType: string (achievements, points, level, duelWins, friends, loginStreak, quizzes, seasonal)
- assetPath: string
- properties: map
- version: number
- isActive: boolean
- order: number
```

#### 2.1.3 Daily Tasks Collection
```
/app_config/daily_tasks/{task_id}
- id: string
- title: string
- description: string
- category: string
- type: string (quiz, duel, multiplayer, social, special, weekly, seasonal, etc.)
- targetValue: number
- rewardPoints: number
- rewardType: string (points, avatar, theme, feature, badge, title, lootbox)
- rewardItem: string
- difficulty: string (easy, medium, hard, expert, legendary)
- icon: string
- tips: array
- environmentalImpact: string
- estimatedTime: number
- version: number
- isActive: boolean
- order: number
```

### 2.2 Veri Servisleri (Backend Integration)

#### 2.2.1 AchievementBackendService
- [ ] Firestore'dan achievements çek
- [ ] Version kontrolü
- [ ] Cache mechanism
- [ ] Static fallback
- [ ] Real-time update listener

#### 2.2.2 RewardBackendService
- [ ] Firestore'dan rewards çek
- [ ] Version kontrolü
- [ ] Cache mechanism
- [ ] Static fallback
- [ ] Real-time update listener

#### 2.2.3 TaskBackendService
- [ ] Firestore'dan tasks çek
- [ ] Version kontrolü
- [ ] Cache mechanism
- [ ] Static fallback
- [ ] Real-time update listener

### 2.3 Ana Servis Güncellemeleri

#### 2.3.1 AchievementService Güncellemesi
- [ ] Backend fetch methodları ekle
- [ ] Combined data source (Firestore + Static)
- [ ] Priority: Firestore > Static
- [ ] Offline support
- [ ] Cache invalidation logic

#### 2.3.2 RewardService Güncellemesi
- [ ] Backend fetch methodları ekle
- [ ] Combined data source (Firestore + Static)
- [ ] Priority: Firestore > Static
- [ ] Offline support
- [ ] Cache invalidation logic

#### 2.3.3 DailyTaskContent Güncellemesi
- [ ] Backend fetch methodları ekle
- [ ] Combined data source (Firestore + Static)
- [ ] Priority: Firestore > Static
- [ ] Offline support
- [ ] Cache invalidation logic

### 2.4 Admin/Data Management

#### 2.4.1 Seed Script
- [ ] Achievements seed data scripti
- [ ] Rewards seed data scripti
- [ ] Daily tasks seed data scripti
- [ ] Version management scripti

#### 2.4.2 Data Sync Service
- [ ] Periodic version check
- [ ] Auto-update cache on version change
- [ ] Background sync support

---

## 🗃️ BÖLÜM 3: Cache & Storage

### 3.1 SharedPreferences Cache
- [ ] Cache key constants
- [ ] Cache expiry management
- [ ] Serialization/deserialization

### 3.2 Local Storage Models
- [ ] AppConfig model
- [ ] CachedData wrapper
- [ ] Version tracking

---

## 🧪 BÖLÜM 4: Testing

### 4.1 Unit Tests
- [ ] QRShareService tests
- [ ] Backend service tests
- [ ] Cache logic tests

### 4.2 Integration Tests
- [ ] Firestore connection tests
- [ ] Fallback mechanism tests
- [ ] Share feature tests

---

## 📦 BÖLÜM 5: Deployment Scripts

### 5.1 Firestore Setup Script
- [ ] Seed achievements
- [ ] Seed rewards
- [ ] Seed daily tasks
- [ ] Security rules validation

### 5.2 Version Management
- [ ] Current version tracking
- [ ] Update trigger mechanism
- [ ] Migration support

---

## 📋 Uygulama Öncelik Sırası

### Aşama 1: Temel Altyapı (Bu aşama)
1. [ ] share_plus paket ekle
2. [ ] QRImageService oluştur
3. [ ] QRShareService oluştur
4. [ ] UserIdShareWidget güncelle

### Aşama 2: Backend Servisleri
5. [ ] Firestore schema dokümantasyonu
6. [ ] Backend service base class
7. [ ] AchievementBackendService
8. [ ] RewardBackendService
9. [ ] TaskBackendService

### Aşama 3: Ana Servis Entegrasyonu
10. [ ] AchievementService güncelle
11. [ ] RewardService güncelle
12. [ ] DailyTaskContent güncelle

### Aşama 4: Cache & Offline Support
13. [ ] SharedPreferences cache
14. [ ] Offline fallback logic
15. [ ] Version checking

### Aşama 5: Seed Data & Scripts
16. [ ] Firestore seed script
17. [ ] Seed data hazırla
18. [ ] Test deployment

### Aşama 6: Testing & Polish
19. [ ] Unit tests
20. [ ] Integration tests
21. [ ] UI polish
22. [ ] Documentation

---

## 🔧 Teknik Notlar

### WhatsApp Paylaşım
```dart
// Text paylaşımı
whatsapp://send?text={text}

// Image paylaşımı (iOS için sınırlı)
whatsapp://send?text={text}

// Tam image desteği için base64 veya dosya yolu gerekli
```

### Gmail Paylaşımı
```dart
mailto:?subject={subject}&body={body}
// QR image için attachment desteklenmez
// Alternatif: Deep link ile uygulama açma
```

### Sistem Paylaşımı (share_plus)
```dart
Share.shareXFiles([XFile(imagePath, mimeType: 'image/png')]);
// Text ile birlikte
Share.shareWithResult(text, sharePositionOrigin: rect);
```

### Firestore Versioning
```javascript
// app_config/versions/current
{
  achievements: 1,
  rewards: 1,
  daily_tasks: 1,
  lastUpdated: timestamp
}
```

---

## 📁 Oluşturulacak Dosyalar

### Yeni Dosyalar:
1. `lib/services/qr_image_service.dart` - QR görsel oluşturma
2. `lib/services/qr_share_service.dart` - Paylaşım servisi
3. `lib/services/achievement_backend_service.dart` - Achievement Firestore
4. `lib/services/reward_backend_service.dart` - Reward Firestore
5. `lib/services/task_backend_service.dart` - Task Firestore
6. `lib/models/app_config.dart` - Cache model
7. `scripts/seed_firestore_data.js` - Seed script
8. `scripts/update_versions.js` - Version update script

### Güncellenecek Dosyalar:
1. `pubspec.yaml` - share_plus paketi
2. `ios/Runner/Info.plist` - URL schemes
3. `android/app/src/main/AndroidManifest.xml` - Share activity
4. `lib/widgets/user_id_share_widget.dart` - Paylaşım butonları
5. `lib/services/achievement_service.dart` - Backend entegrasyonu
6. `lib/services/reward_service.dart` - Backend entegrasyonu
7. `lib/services/daily_task_content.dart` - Backend entegrasyonu
8. `lib/l10n/app_*.arb` - Localization strings

