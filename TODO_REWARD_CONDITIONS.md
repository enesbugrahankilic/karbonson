# Ödül Mağazası Koşul Gösterimi - TODO Listesi

## ✅ Dosya 1: lib/models/reward_item.dart
### Yapılanlar:
- [x] `RewardUnlockType` enum eklendi (rozet, puan, seviye, düello, arkadaş, giriş serisi, quiz, mevsimlik)
- [x] `RewardUnlockStatus` enum eklendi (unlocked, available, inProgress, locked)
- [x] `RewardUnlockProgress` sınıfı eklendi
- [x] `canUserUnlock(UserProgress progress)` metodu eklendi
- [x] `getUnlockProgress(UserProgress progress)` metodu eklendi
- [x] `getUnlockType()` - Her ödül için kilit açma türünü belirler
- [x] `_getCurrentValue()` - Kullanıcının mevcut değerini hesaplar
- [x] `_getRequirementDescription()` - Koşul açıklamasını Türkçe döndürür
- [x] `_getRemainingText()` - Kalan miktar metnini döndürür

## ✅ Dosya 2: lib/widgets/reward_card.dart
### Yapılanlar:
- [x] `UserProgress? userProgress` parametresi eklendi
- [x] `_buildStatusBadge()` - Dinamik durum rozeti (yeşil/mavi/turuncu/kırmızı)
- [x] `_buildProgressBar()` - Görsel ilerleme çubuğu
- [x] `_getProgressColor()` - Duruma göre renk belirleme
- [x] `_buildTypeAndStatus()` - Koşul durumu gösterimi güncellendi
- [x] Progress bar ile kullanıcının durumu vs gereksinim gösterimi

## ✅ Dosya 3: lib/pages/rewards_shop_page.dart
### Yapılanlar:
- [x] `UserProgressService` import edildi
- [x] `UserProgress?` state eklendi
- [x] `_loadData()` metodu eklendi (ödüller + kullanıcı ilerlemesi)
- [x] `RewardCard` widget'larına progress aktarıldı

## ✅ Yeni Özellikler:
- [x] Kullanıcının rozet sayısı, puanı, seviyesi gösteriliyor
- [x] Her ödül için gereksinim detaylı gösteriliyor
- [x] Progress bar ile görsel geri bildirim
- [x] Renk kodlaması:
  - 🟢 Yeşil: Koşul karşılandı (Açık)
  - 🔵 Mavi: Alınabilir!
  - 🟠 Turuncu: İlerleme var (X kaldı)
  - 🔴 Kırmızı: Kilitlede

## ✅ RewardUnlockStatus Durumları:
| Durum | Renk | Açıklama |
|-------|------|----------|
| unlocked | 🟢 Yeşil | Ödül zaten açıldı |
| available | 🔵 Mavi | Koşullar karşılandı, alınabilir |
| inProgress | 🟠 Turuncu | Kısmen karşılandı, X kaldı |
| locked | 🔴 Kırmızı | Koşullar karşılanmadı |

## Test Edilecekler:
- [ ] Kullanıcı puanı yeterli olduğunda buton aktif
- [ ] Kullanıcı puanı yetersiz olduğunda buton pasif
- [ ] Neden alınamadığı mesajı doğru gösteriliyor
- [ ] Progress bar doğru hesaplanıyor
- [ ] Detay sayfasında koşullar doğru gösteriliyor

## Örnek Kullanım:
```dart
// RewardItem'dan ilerleme bilgisi alma
final progress = rewardItem.getUnlockProgress(userProgress);

// Durum kontrolü
if (progress.canUnlock) {
  // Buton aktif
} else {
  // Neden alınamadığını göster
  print(progress.statusMessage); //örn: "5 rozet kaldı"
}
```

## Eklenen Enum ve Sınıflar:
```dart
enum RewardUnlockType {
  achievements,  // Rozet sayısı
  points,        // Puan
  level,         // Seviye
  duelWins,      // Düello kazanma
  friends,       // Arkadaş sayısı
  loginStreak,   // Günlük giriş serisi
  quizzes,       // Quiz tamamlama
  seasonal,      // Mevsimlik etkinlik
}

enum RewardUnlockStatus {
  unlocked,   // Açıldı
  available,  // Alınabilir
  inProgress, // İlerlemede
  locked,     // Kilitlede
}

class RewardUnlockProgress {
  final RewardUnlockStatus status;
  final int currentValue;      // Kullanıcının mevcut değeri
  final int requiredValue;     // Gerekli değer
  final double progressPercentage; // İlerleme yüzdesi
  final String statusMessage;  // Durum mesajı
  final String requirementDescription; // Koşul açıklaması
}
```

