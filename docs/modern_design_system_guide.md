# Modern Design System - Kullanım Rehberi

## 📋 Genel Bakış

Bu doküman, uygulamada kullanılan modern tasarım sistemi ve UI bileşenlerinin kapsamlı rehberidir. Tüm bileşenler Material Design 3 standartlarına uygun olarak geliştirilmiştir.

## 🎨 Tasarım Dosyaları

### 1. Modern UI Components (`lib/theme/modern_ui_components.dart`)
- **ModernUI.animatedButton()**: Animasyonlu butonlar
- **ModernUI.animatedCard()**: Slide-in animasyonlu kartlar
- **ModernUI.shimmerCard()**: Skeleton loading efektleri
- **ModernUI.showModernToast()**: Gelişmiş bildirim sistemi
- **ModernUI.pulseFAB()**: Pulse animasyonlu floating action button
- **ModernUI.statusIndicator()**: Online/offline durum göstergeleri

### 2. Responsive Design (`lib/theme/responsive_design.dart`)
- **ResponsiveDesign.getScreenType()**: Ekran tipi algılama
- **ResponsiveDesign.responsiveGrid()**: Responsive grid sistemi
- **ResponsiveDesign.responsiveText()**: Responsive metin boyutları
- **ResponsiveDesign.responsiveButton()**: Responsive butonlar

### 3. Enhanced Colors (`lib/theme/enhanced_colors.dart`)
- **EnhancedColors**: Modern renk paleti sistemi
- **EnhancedTypography**: Gelişmiş tipografi sistemi
- **Color Extensions**: Lighten, darken, luminance utilities

### 4. Animations (`lib/theme/animations.dart`)
- **AppAnimations**: Fade, slide, scale, bounce animasyonları
- **MicroInteractions**: Button press, ripple, hover efektleri
- **Loading Animations**: Spinner, pulsing, typing indicators

### 5. Accessibility (`lib/theme/accessibility.dart`)
- **AccessibilityHelper**: WCAG AA standartları
- **AccessibleButton**: Erişilebilir buton bileşeni
- **AccessibleText**: Erişilebilir metin bileşeni

## 🚀 Kullanım Örnekleri

### Modern Button Kullanımı
```dart
ModernUI.animatedButton(
  context,
  text: 'Giriş Yap',
  onPressed: _handleLogin,
  icon: Icons.login,
  backgroundColor: ThemeColors.getPrimaryButtonColor(context),
)
```

### Responsive Grid Kullanımı
```dart
ResponsiveDesign.responsiveGrid(
  context: context,
  children: [
    FeatureCard(),
    FeatureCard(),
    FeatureCard(),
  ],
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
)
```

### Animasyonlu Kart Kullanımı
```dart
ModernUI.animatedCard(
  context,
  child: Column(
    children: [
      Text('Quiz Soru'),
      // Soru içeriği
    ],
  ),
  onTap: () => _handleCardTap(),
)
```

### Erişilebilir Button Kullanımı
```dart
AccessibleButton(
  text: 'Kaydet',
  onPressed: _handleSave,
  semanticLabel: 'Ayarları kaydet',
  hint: 'Tüm değişiklikleri kaydeder',
)
```

## 🎯 Tasarım Prensipleri

### 1. Tutarlılık
- Tüm bileşenler aynı spacing sistemi kullanır
- Renk paleti tutarlı şekilde uygulanır
- Tipografi hiyerarşisi korunur

### 2. Erişilebilirlik
- WCAG AA kontrast standartları
- Minimum 48px touch target'ları
- Screen reader desteği

### 3. Responsive Tasarım
- Mobile First yaklaşım
- Ekran boyutuna göre otomatik uyarlama
- Touch-friendly interface

### 4. Modern Animasyonlar
- 60fps smooth animasyonlar
- Meaningful motion design
- Performance optimized

## 📱 Responsive Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 1024px
- **Desktop**: > 1024px

## 🎨 Renk Sistemi

### Primary Colors
- Primary 500: `#8BC34A` (Ana renk)
- Secondary 500: `#2196F3` (İkinci renk)
- Accent 500: `#9C27B0` (Vurgu rengi)

### Semantic Colors
- Success: `#4CAF50` (Başarı)
- Warning: `#FF9800` (Uyarı)
- Error: `#F44336` (Hata)
- Info: `#2196F3` (Bilgi)

## 🔤 Tipografi Sistemi

### Font Hierarchy
- **Display**: 48px - 96px (Başlıklar)
- **Headline**: 32px - 56px (Alt başlıklar)
- **Title**: 22px - 32px (Bölüm başlıkları)
- **Body**: 14px - 20px (Normal metin)
- **Label**: 11px - 16px (Etiketler)

## ♿ Erişilebilirlik Özellikleri

- WCAG AA kontrast oranları (4.5:1)
- Semantic labels ve hints
- Keyboard navigation desteği
- Screen reader uyumluluğu
- High contrast tema seçeneği

## 🚀 Performans

- Optimized animations (60fps)
- Efficient widget building
- Minimal repaints
- Memory conscious design

## 🔧 Customization

Tüm bileşenler theme-aware'dır ve context üzerinden renkler alır. Customization için:

1. `ThemeColors` sınıfını genişletin
2. `DesignSystem` değerlerini değiştirin
3. Responsive breakpoints'i ayarlayın

## 📋 Best Practices

### Do's ✅
- Semantic labels kullanın
- Accessible font sizes tercih edin
- Touch target minimum 48px
- Consistent spacing kullanın
- Performance'a dikkat edin

### Don'ts ❌
- Hard-coded colors kullanmayın
- Çok fazla animasyon eklemeyin
- Text overflow'u ignore etmeyin
- Touch target'ları küçültmeyin

## 🔄 Migration Guide

Eski bileşenleri yeni sisteme migrate etmek için:

1. Import'ları ekleyin: `import '../theme/modern_ui_components.dart';`
2. Eski widget'ları yeni bileşenlerle değiştirin
3. Theme-aware renkleri kullanın
4. Responsive behavior ekleyin

## 📞 Support

Sorularınız için:
- Design system documentation
- Code comments
- Flutter Material Design guidelines

---

**Not**: Bu tasarım sistemi sürekli geliştirilmektedir. Güncellemeler için bu dokümanı takip edin.