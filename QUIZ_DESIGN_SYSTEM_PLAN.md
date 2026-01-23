# 📋 QUİZ TASARIM SİSTEMİ - UYGULAMA PLANI

## 🎯 Referans Tasarım
**Quiz Oluştur Sayfası** (`quiz_settings_page.dart`) - Modern gradient kart yapısı, yatay kaydırmalı kategori seçimi, renkli zorluk seçenekleri.

---

## 📁 OLUŞTURULACAK BİLEŞENLER

### 1. QuizLayout Component (`lib/widgets/quiz_layout.dart`)
- Header: Geri butonu + başlık (gradient arka plan)
- Content Card: İçerik alanı (beyaz yarı-saydam cam efekt)
- Action Button Area: Alttaki sabit buton alanı
- Page transition animasyonları

### 2. QuizCard Component (`lib/widgets/quiz_card.dart`)
- Seçili/Seçili değil durumları
- Gradient renk desteği
- Hover/press animasyonları
- İkon + başlık + açıklama

### 3. QuizButton Component (`lib/widgets/quiz_button.dart`)
- **Primary**: Yeşil gradient, ana aksiyonlar
- **Secondary**: Mavi gradient, ikincil aksiyonlar
- **Accent**: Mor gradient, özel aksiyonlar
- Tüm butonlar aynı boyut ve yuvarlaklıkta

### 4. QuizOption Component (`lib/widgets/quiz_option.dart`)
- Radio butonlu seçim kartları
- Soru sayısı, zorluk, dil seçimleri için
- Seçili: Renkli gradient, border
- Seçili değil: Beyaz yarı-saydam

### 5. QuizBackground Component (`lib/widgets/quiz_background.dart`)
- Sabit gradient arka plan
- Sayfa değişirken fade animasyonu
- Tüm quiz sayfalarında tutarlı

### 6. QuizSectionHeader Component (`lib/widgets/quiz_section_header.dart`)
- Bölüm başlıkları için
- İkon + başlık + açıklama

---

## 🔄 DÖNÜŞTÜRÜLECEK SAYFALAR

| # | Sayfa | Dosya | Öncelik |
|---|-------|-------|---------|
| 1 | Login | `lib/pages/login_page.dart` | 🔴 YÜKSEK |
| 2 | Register | `lib/pages/register_page.dart` | 🔴 YÜKSEK |
| 3 | Quiz Settings | `lib/pages/quiz_settings_page.dart` | ✅ REFERANS |
| 4 | Achievement | `lib/pages/achievement_page.dart` | 🟡 ORTA |
| 5 | Daily Challenge | `lib/pages/daily_challenge_page.dart` | 🟡 ORTA |
| 6 | Spectator Mode | `lib/pages/spectator_mode_page.dart` | 🟡 ORTA |
| 7 | Multiplayer Lobby | `lib/pages/multiplayer_lobby_page.dart` | 🟡 ORTA |

---

## 🎨 TASARIM KURALLARI (SABİT)

### Renk Paleti
- **Ana**: Yeşil (`#4CAF50`)
- **Destek**: Mavi (`#2196F3`), Mor (`#9C27B0`)
- **Vurgu**: Turkuaz, Sarı
- **Zemin**: Açık beyaz / pastel (Light), Koyu lacivert (Dark)

### Yapısal Kurallar
- ❌ Beyaz düz sayfa yok
- ❌ Farklı buton şekli yok
- ❌ Farklı font boyutu yok
- ✅ Her şey kart içinde
- ✅ Yumuşak geçişler (scale + opacity)
- ✅ Göz yormayan kontrast
- ✅ "Modern quiz app" hissi

### Component Standartları
- **Card Radius**: 16px (radiusL)
- **Button Height**: 56px
- **Padding**: 16px (spacingM), 24px (spacingL)
- **Shadow**: Modern gölge sistemi

---

## 📝 UYGULAMA ADIMLARI

### ADIM 1: Tema Renklerini Güncelle
- [ ] `theme_colors.dart` - Mode-aware renkler ekle
- [ ] `design_system.dart` - Quiz-specific stiller ekle

### ADIM 2: Temel Bileşenleri Oluştur
- [ ] `quiz_layout.dart` - Ana layout component
- [ ] `quiz_card.dart` - Kart bileşeni
- [ ] `quiz_button.dart` - Buton bileşeni
- [ ] `quiz_option.dart` - Seçim kartı bileşeni
- [ ] `quiz_background.dart` - Arka plan bileşeni
- [ ] `quiz_section_header.dart` - Bölüm başlığı

### ADIM 3: Sayfaları Dönüştür
- [ ] Login Page → QuizLayout kullan
- [ ] Register Page → QuizLayout kullan
- [ ] Achievement Page → QuizLayout kullan
- [ ] Daily Challenge Page → QuizLayout kullan
- [ ] Spectator Mode Page → QuizLayout kullan
- [ ] Multiplayer Lobby Page → QuizLayout kullan

### ADIM 4: Test ve Doğrulama
- [ ] Light mode testi
- [ ] Dark mode testi
- [ ] Responsive test
- [ ] Animasyon testi

---

## 🚀 BAŞLANGIÇ KOMUTLARI

```bash
cd /Users/omer/karbonson
# Flutter doctor
flutter doctor

# Analiz çalıştır
flutter analyze

# Widget test
flutter test test/widget_test.dart

# Uygulamayı çalıştır
flutter run -d iphone
```

---

## 📦 DOSYA YAPISI (SONRASI)

```
lib/
├── theme/
│   ├── theme_colors.dart        # ✅ Güncellenecek
│   ├── design_system.dart       # ✅ Güncellenecek
│   ├── quiz_design_system.dart  # 🆕 YENİ - Quiz tasarım sistemi
├── widgets/
│   ├── quiz_layout.dart         # 🆕 YENİ
│   ├── quiz_card.dart           # 🆕 YENİ
│   ├── quiz_button.dart         # 🆕 YENİ
│   ├── quiz_option.dart         # 🆕 YENİ
│   ├── quiz_background.dart     # 🆕 YENİ
│   ├── quiz_section_header.dart # 🆕 YENİ
├── pages/
│   ├── login_page.dart          # 🔄 Güncellenecek
│   ├── register_page.dart       # 🔄 Güncellenecek
│   ├── quiz_settings_page.dart  # ✅ REFERANS
│   ├── achievement_page.dart    # 🔄 Güncellenecek
│   ├── daily_challenge_page.dart# 🔄 Güncellenecek
│   ├── spectator_mode_page.dart # 🔄 Güncellenecek
│   ├── multiplayer_lobby_page.dart# 🔄 Güncellenecek
```

---

## ✅ DURUM TAKİPÇİSİ

| Adım | Durum | Tamamlanma |
|------|-------|------------|
| Plan Oluştur | ✅ | 2024-01-XX |
| Tema Renklerini Güncelle | ⏳ | - |
| Temel Bileşenleri Oluştur | ⏳ | - |
| Sayfaları Dönüştür | ⏳ | - |
| Test ve Doğrulama | ⏳ | - |

---

**Oluşturulma Tarihi**: 2024-01-XX
**Son Güncelleme**: 2024-01-XX
**Sorumlu**: AI Assistant

