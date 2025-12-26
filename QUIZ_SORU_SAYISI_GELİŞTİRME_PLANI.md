# Quiz Sayfası Soru Sayısı Geliştirme Planı

## 📋 Görev Özeti
Quiz sayfasında kullanıcının zorluk seviyesi ve soru sayısına göre soruların gelmesini sağlamak.

## 🔍 Mevcut Durum Analizi

### ✅ Mevcut Özellikler
- [x] Zorluk seviyesi seçimi (Kolay, Orta, Zor, Karışık)
- [x] Kategori seçimi (Tümü, Enerji, Su, Orman, vb.)
- [x] Zorluk seviyesine göre soru filtreleme sistemi
- [x] Mixed difficulty (1:1:1 oranında karışık)
- [x] QuestionsDatabase'de soru filtreleme method'ları

### ❌ Eksik Özellikler
- [ ] Soru sayısı seçimi
- [ ] Soru sayısına göre dinamik soru getirme
- [ ] Soru sayısı UI'ı

## 📝 Planlanan Geliştirmeler

### 1. Quiz Sayfası UI Güncellemeleri
**Dosya**: `lib/pages/quiz_page.dart`
- Kategori ve zorluk seçimi dialog'una soru sayısı seçenekleri ekle
- Soru sayısı seçenekleri: 5, 10, 15, 20, 25
- Modern ve kullanıcı dostu arayüz

### 2. Quiz Logic Service Güncellemeleri
**Dosya**: `lib/services/quiz_logic.dart`
- `startNewQuiz` method'una soru sayısı parametresi ekle
- Soru sayısına göre dinamik soru seçimi
- Mevcut 15 sabit sayısını değiştir

### 3. Quiz Bloc Güncellemeleri
**Dosya**: `lib/provides/quiz_bloc.dart`
- LoadQuiz event'ine soru sayısı parametresi ekle
- State yönetiminde soru sayısını sakla

### 4. Test Güncellemeleri
**Dosya**: `test/quiz_difficulty_test.dart`
- Soru sayısı test senaryoları ekle
- Farklı soru sayıları için test cases

## 🎯 Beklenen Sonuçlar

### Kullanıcı Deneyimi
- Kullanıcı istediği soru sayısını seçebilecek
- Hızlı quiz (5 soru) ile uzun quiz (25 soru) seçenekleri
- Daha kişiselleştirilmiş quiz deneyimi

### Teknik İyileştirmeler
- Esnek soru sayısı sistemi
- Performans optimizasyonu (az soru = hızlı yükleme)
- Gelecekteki özelliklere hazır altyapı

## 📊 Soru Sayısı Seçenekleri
- **5 Soru**: Hızlı quiz (2-3 dakika)
- **10 Soru**: Standart quiz (5 dakika)
- **15 Soru**: Varsayılan quiz (7-8 dakika)
- **20 Soru**: Uzun quiz (10-12 dakika)
- **25 Soru**: Kapsamlı quiz (12-15 dakika)

## 🔧 Uygulama Adımları

1. **Adım 1**: Quiz Page dialog'una soru sayısı seçimi ekle
2. **Adım 2**: Quiz Logic service'i soru sayısı parametresi ile güncelle
3. **Adım 3**: Quiz Bloc state management güncellemeleri
4. **Adım 4**: Test senaryolarını güncelle
5. **Adım 5**: Test ve doğrulama

## ⚡ Performans Notları
- Az soru = daha hızlı yükleme
- Çok soru = daha kapsamlı değerlendirme
- Database'den gerektiği kadar soru çekme

## 🎨 UI/UX Geliştirmeleri
- Soru sayısı seçimi için slider veya dropdown
- Her seçenek için tahmini süre gösterimi
- Görsel zorluk seviyesi göstergeleri

---
**Not**: Bu geliştirme mevcut quiz sisteminin üzerine eklenmeli ve geriye uyumluluk korunmalı.
