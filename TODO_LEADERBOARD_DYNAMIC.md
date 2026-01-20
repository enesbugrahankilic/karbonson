# Lider Tablosu Dinamik Kategoriler - TODO Listesi

## Genel Bakış
Liderlik tablosundaki kategorilerin dinamik olarak veritabanından gelen verilere göre sıralanması.

## Görevler

### 1. UserData Model Güncellemesi
- [x] `friendCount` alanı ekle (arkadaş sayısı)
- [x] `duelWins` alanı ekle (düello kazanma sayısı)
- [x] `longestStreak` alanı ekle (en uzun seri)
- [x] `quizCount` alanı ekle (quiz tamamlama sayısı)

### 2. FirestoreService Güncellemesi
- [x] `getQuizMastersLeaderboard()` - Quiz ustaları için
- [x] `getDuelChampionsLeaderboard()` - Düello şampiyonları için
- [x] `getSocialButterfliesLeaderboard()` - Sosyal kelebekler için
- [x] `getStreakKingsLeaderboard()` - Seri kralları için
- [x] `updateUserStats()` - Kullanıcı istatistiklerini güncellemek için

### 3. LeaderboardPage Güncellemesi
- [x] Kategori verilerini dinamik yükle
- [x] Her kategori için farklı sıralama mantığı
- [x] Sosyal kelebek için arkadaş sayısına göre sırala
- [x] Görsel iyileştirmeler ve kart tasarımları

### 4. FriendshipService Güncellemesi
- [x] `getFriendsCount()` - Arkadaş sayısını getir

## Tamamlanan Görevler
- [x] Tüm görevler tamamlandı!

## Notlar
- Kategoriler artık Firestore'dan dinamik olarak yükleniyor
- Her kategori kendi kriterine göre sıralanıyor:
  - Quiz Uzmanları: quizCount (en çok quiz tamamlayanlar)
  - Düello Şampiyonları: duelWins (en çok düello kazananlar)
  - Sosyal Kelebekler: friendCount (en çok arkadaşı olanlar)
  - Seri Kralları: longestStreak (en uzun seri yakalayanlar)

