# Kapsamlı Günlük Görev Sistemi Genişletme

## 📋 Görev Listesi

### 1. Servis Dosyaları
- [ ] `lib/services/daily_task_refresh_service.dart` - Otomatik yenileme servisi
- [ ] `lib/services/daily_task_service.dart` - Ana görev servisi (genişletilmiş)
- [ ] `lib/services/daily_task_integration_service.dart` - Entegrasyon servisi (friendship, game)

### 2. Model Dosyaları
- [ ] `lib/models/daily_task_models.dart` - Gelişmiş görev modelleri

### 3. Widget Dosyaları
- [ ] `lib/widgets/daily_task_card.dart` - Gelişmiş görev kartı
- [ ] `lib/widgets/daily_task_detail_sheet.dart` - Görev detay sayfası
- [ ] `lib/widgets/daily_task_progress_widget.dart` - İlerleme göstergesi

### 4. Sayfa Dosyaları
- [ ] `lib/pages/daily_tasks_page.dart` - Ana görev sayfası
- [ ] `lib/pages/daily_task_detail_page.dart` - Görev detay sayfası

### 5. Güncellemeler
- [ ] `lib/services/challenge_service.dart` - ChallengeService entegrasyonu
- [ ] `lib/services/friendship_service.dart` - FriendshipService entegrasyonu
- [ ] `lib/services/daily_task_content.dart` - Görev içerik güncellemesi
- [ ] `lib/main.dart` - Servis başlatma

### 6. Test Dosyaları
- [ ] `test/daily_task_system_test.dart` - Kapsamlı testler

---

## 🎯 Görev Tipleri

### Quiz Görevleri
- Günlük Quiz (3 soru)
- Quiz Uzmanı (5 soru)
- Bilgi Maratonu (10 soru)
- Mükemmel Gün (%80 doğruluk)

### Düello Görevleri
- Arena Meydan Okuma (1 kazanç)
- Arena Şampiyonu (3 kazanç)
- Düello Ustası (5 kazanç)

### Sosyal Görevler
- Sosyal Bağ (1 arkadaş ekle)
- Ağ Genişletme (3 arkadaş ekle)
- Çevre Elçisi (5 arkadaş ekle)

### Oyun Görevleri
- Masa Başında (1 board game)
- Strateji Ustası (3 board game)
- Oyun Gurusu (5 board game)

### Haftalık Görevler
- Haftalık Quiz Maratonu (20 soru)
- Haftalık Düello Şampiyonu (10 kazanç)
- Haftalık Sosyal Ağ (5 arkadaş)

---

## 🔄 Otomatik Yenileme

- Her gün saat 00:00'da yeni görevler
- Uygulama açılışında kontrol
- Arka planda periyodik kontrol
- Bildirim ile kullanıcıyı bilgilendirme

---

## 📊 İlerleme Takibi

- Anlık ilerleme güncellemesi
- Tamamlanan görevler için ödül
- Seri (streak) takibi
- İstatistikler ve başarımlar

