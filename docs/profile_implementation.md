# Profilim (My Profile) Sayfası Implementation

## Özellikler

Bu implementasyon, **UID merkezli mimari** kullanarak lokal ve sunucu verilerini zarif bir şekilde birleştiren, yüksek performanslı bir "Profilim" sekmesi oluşturur.

## 🚀 Yükleme Önceliği (UX)

Profil sekmesi iki aşamalı yükleme stratejisi kullanır:

### 1. Anında Görüntüleme (Lokal Veri)
- Sekme açılır açılmaz lokal depodan çekilen veriler **anında** yüklenir
- Oyun Skorları, İstatistikler, Geçmiş skorlar sıfır gecikme ile gösterilir
- Kullanıcıya **sıfır gecikme hissi** verilir

### 2. Senkronize Güncelleme (Sunucu Verisi)
- Aynı anda arka planda Firebase'den **UID, Nickname ve Profil Resmi** çekilir
- Bu veriler geldikçe ilgili alanlar **yumuşak animasyonla** güncellenir
- Kullanıcı deneyimi kesintisiz kalır

## 📁 Dosya Yapısı

```
lib/
├── models/
│   └── profile_data.dart          # Veri modelleri
├── services/
│   └── profile_service.dart       # Lokal ve sunucu veri yönetimi
├── provides/
│   └── profile_bloc.dart          # Durum yönetimi (Bloc pattern)
├── pages/
│   └── profile_page.dart          # Ana profil sayfası UI
└── main.dart                       # BlocProvider entegrasyonu
```

## 🎨 UI Bileşenleri

### A. Üst Bölüm: Kimlik Kartı (Sunucu Verisi)
- **Profil Resmi**: Büyük, dairesel avatar (seviye halkası ile)
- **Nickname**: Profil resminin altında büyük, kalın fontla
- **UID**: Gri/düşük kontrastlı, tek tıkla kopyalama butonu ile
- **Son Giriş**: Zaman bazlı format (Az önce, 2 saat önce, vb.)

### B. Orta Bölüm: Oyun İstatistikleri (Lokal Veri)
- **2x2 Grid Layout** ile renkli kartlar
- **Kazanma Oranı**: Yüzde formatında
- **Toplam Oynanan Oyun**: Sayaç
- **En Yüksek Skor**: Rekor gösterimi
- **Ortalama Puan**: Hesaplanmış ortalama

### C. Alt Bölüm: Oyun Geçmişi (Lokal Veri)
- **Son 10 oyunun** detaylı listesi
- Her liste öğesi: skor, tarih, oyun tipi, sonuç (Kazandın/Kaybettin)
- **Renkli ikonlar**: Yeşil checkmark (kazanma), kırmızı X (kaybetme)
- **Boş durum**: Henüz oyun oynanmamışsa özel mesaj

## 🛠️ Geliştirici Kullanımı

### Profil Sayfasına Gitme
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProfilePage(userNickname: 'KullaniciAdi'),
  ),
);
```

### Oyun Sonucu Ekleme
```dart
// ProfileBloc üzerinden oyun sonucu ekleme
context.read<ProfileBloc>().add(AddGameResult(
  score: 150,          // Alınan skor
  isWin: true,         // Kazanma durumu
  gameType: 'single',  // 'single' veya 'multiplayer'
));
```

### Takma Ad Güncelleme
```dart
// Takma adı güncelleme
context.read<ProfileBloc>().add(UpdateNickname('YeniTakmaAd'));
```

## 📊 Veri Modelleri

### ServerProfileData
```dart
class ServerProfileData {
  final String uid;
  final String nickname;
  final String? profilePictureUrl;
  final DateTime? lastLogin;
  final DateTime? createdAt;
}
```

### LocalStatisticsData
```dart
class LocalStatisticsData {
  final double winRate;              // 0.0 - 1.0
  final int totalGamesPlayed;
  final int highestScore;
  final int averageScore;
  final List<GameHistoryItem> recentGames;  // Son 10 oyun
  final DateTime lastUpdated;
}
```

## 🔄 Durum Yönetimi

### ProfileEvents
- `LoadProfile(userNickname)` - Profili yükle
- `RefreshServerData()` - Sunucu verilerini yenile
- `UpdateNickname(newNickname)` - Takma ad güncelle
- `AddGameResult(score, isWin, gameType)` - Oyun sonucu ekle

### ProfileStates
- `ProfileInitial` - Başlangıç durumu
- `ProfileLoading` - Yükleme durumu
- `ProfileLoaded` - Başarılı yükleme (ProfileData + currentNickname)
- `ProfileError` - Hata durumu

## 💾 Veri Depolama

### Lokal Depolama (SharedPreferences)
```dart
// Otomatik olarak şu veriler saklanır:
{
  "user_game_statistics": LocalStatisticsData.toMap(),
  "cached_nickname": "KullaniciAdi"
}
```

### Sunucu Depolama (Firebase Firestore)
```dart
// Koleksiyon: users
{
  "nickname": "KullaniciAdi",
  "profilePictureUrl": "https://...",
  "lastLogin": Timestamp,
  "createdAt": Timestamp,
  "isAnonymous": true
}
```

## 🎯 Performans Özellikleri

1. **İki Aşamalı Yükleme**: Lokal veri anında, sunucu verisi arka planda
2. **Animasyonlar**: Fade ve slide animasyonları ile yumuşak geçişler
3. **Lazy Loading**: Oyun geçmişi sadece gerektiğinde yüklenir
4. **Cache Sistemi**: Nickname ve istatistikler lokal olarak cache'lenir
5. **Error Handling**: Graceful error handling ile kullanıcı deneyimi korunur

## 🚨 Önemli Notlar

1. **Firebase Auth Gerekli**: UID için Firebase Authentication kullanılır
2. **Offline First**: Lokal veri her zaman mevcuttur
3. **Synchronization**: Sunucu verisi arka planda güncellenir
4. **Data Consistency**: Batch writes ile tutarlı veri güncellemeleri

## 🔧 Konfigürasyon

### main.dart'ta Provider Ekleme
```dart
BlocProvider(create: (_) => ProfileBloc(profileService: ProfileService())),
```

### Login Sayfasında Navigasyon
```dart
TextButton.icon(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(userNickname: nickname),
    ),
  ),
  icon: const Icon(Icons.person),
  label: const Text('Profilim'),
),
```

Bu implementasyon modern Flutter best practices'i takip eder ve production-ready bir profil yönetimi sistemi sağlar.