# QUIZ TASARIM SISTEMI - KAPSAMLI UYGULAMA PLANI

## Referans Tasarim
Quiz Olustur Sayfasi (`quiz_settings_page.dart`) - Modern gradient kart yapisi, yatay kaydirma kategorisi, renkli zorluk secenekleri

---

## Mevcut Durum Analizi

### Zaten Mevcut Bilesenler
| Bilesen | Dosya | Durum |
|---------|-------|-------|
| QuizLayout | `lib/widgets/quiz_layout.dart` | VAR |
| QuizCard | `lib/widgets/quiz_card.dart` | VAR |
| DesignSystem | `lib/theme/design_system.dart` | VAR |
| ThemeColors | `lib/theme/theme_colors.dart` | VAR |

### Donusturulmesi Gereken Sayfalar
| # | Sayfa | Dosya | Oncelik |
|---|-------|-------|---------|
| 1 | Quiz Settings | `lib/pages/quiz_settings_page.dart` | REFERANS |
| 2 | Daily Challenge | `lib/pages/daily_challenge_page.dart` | YUKSEK |
| 3 | Achievement | `lib/pages/achievement_page.dart` | YUKSEK |
| 4 | Spectator Mode | `lib/pages/spectator_mode_page.dart` | ORTA |
| 5 | Multiplayer Lobby | `lib/pages/multiplayer_lobby_page.dart` | ORTA |
| 6 | Duel Invitation | `lib/pages/duel_invitation_page.dart` | ORTA |
| 7 | Quiz Results | `lib/pages/quiz_results_page.dart` | ORTA |

---

## Tasarim Kurallari

### Renk Paleti
- Ana (Yesil): #4CAF50 -> Primary Button, Success
- Destek (Mavi): #2196F3 -> Secondary, Info
- Vurgu (Mor): #9C27B0 -> Accent, Spectator

### Yapisal Kurallar
- Her sey kart icinde (glass/cam effect)
- Yumsak gecisler (scale + opacity animasyonlari)
- Goy yormayan kontrast

### Component Standartlari
- Card Radius: 16px
- Button Height: 56px
- Padding: 16px (spacingM), 24px (spacingL)
- Header: Gradient arka plan + geri butonu + baslik

---

## Uygulanacak Yerler

### 1. Quiz Ayarlari
- Zaten referans tasarim

### 2. Gunluk Görevler
- QuizLayout kullan
- Gradient header
- Glass card ile icerik

### 3. Basarimlar
- QuizLayout kullan
- Gradient header
- Glass card ile achievement kartlari
- TabBar: Tumü / Kazanilan / Kazanilmamis

### 4. Izleyici Modu
- QuizLayout kullan
- Canli oyun listesi -> Glass card
- Tekrarlar -> Glass card

### 5. Cok Oyunculu Lobi
- QuizLayout kullan
- Profil karti -> Glass card
- Oda olustur/katil -> Glass card

### 6. Düello Davetleri
- QuizLayout kullan
- Davet listesi -> Glass card

### 7. Quiz Sonuclari
- QuizLayout kullan
- Skor karti -> Glass card

---

## Implementasyon Adimlari

### Adim 1: QuizDesignSystem Olustur
- `lib/theme/quiz_design_system.dart` dosyasi olustur
- Quiz-specific stiller
- Animasyon kurallari

### Adim 2: Sayfa Donusumleri
- Daily Challenge Page
- Achievement Page
- Spectator Mode Page
- Multiplayer Lobby Page
- Duel Invitation Page
- Quiz Results Page

### Adim 3: Test ve Dogrulama
- Light mode testi
- Dark mode testi
- Responsive test

---

## Dosya Yapisi

```
lib/
├── theme/
│   ├── theme_colors.dart
│   ├── design_system.dart
│   └── quiz_design_system.dart
├── widgets/
│   ├── quiz_layout.dart
│   ├── quiz_card.dart
│   └── page_templates.dart
└── pages/
    ├── quiz_settings_page.dart
    ├── daily_challenge_page.dart
    ├── achievement_page.dart
    ├── spectator_mode_page.dart
    ├── multiplayer_lobby_page.dart
    ├── duel_invitation_page.dart
    └── quiz_results_page.dart
```

---

**Olusturulma**: Bugun

