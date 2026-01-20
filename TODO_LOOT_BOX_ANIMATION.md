# Loot Box Açılma Animasyonu - Görev Listesi

## Genel Bakış
Ödül kutusu için kapsamlı bir açılma animasyonu sistemi oluşturulacak.

## Dosyalar

### 1. Animation Utilities
- [x] Dosya oluşturma: `lib/utils/loot_box_animations.dart`
- [x] Particle system (partikül efektleri)
- [x] Confetti sistemi
- [x] Glow effects (parlama efektleri)
- [x] Rarity color helpers

### 2. Loot Box Widget
- [x] Dosya oluşturma: `lib/widgets/loot_box_widget.dart`
- [x] Box visual design (kutu görsel tasarımı)
- [x] Shake/wobble animation (sallanma animasyonu)
- [x] Click handler
- [x] Rarity-based styling (nadirlik bazlı stil)

### 3. Opening Dialog
- [x] Dosya oluşturma: `lib/widgets/loot_box_opening_dialog.dart`
- [x] Full-screen dialog design
- [x] Box opening sequence animation
- [x] Reward reveal animation
- [x] Particle effects integration
- [x] Rarity-based animation intensity
- [x] Close button and callback

## Nadirlik Seviyeleri ve Animasyonlar

### Common (Sıradan) - Gri
- Temel shake animasyonu
- Gri partiküller
- Basit fade etkisi

### Rare (Nadir) - Mavi
- Orta şiddet shake
- Mavi glow efekti
- Mavi partiküller
- Orta yoğunlukta confetti

### Epic (Destansı) - Mor
- Yoğun shake
- Mor glow ve sparkle
- Mor partiküller
- Yoğun confetti

### Legendary (Efsanevi) - Altın
- Çok yoğun shake
- Altın shimmer efekti
- Altın partiküller ve yıldızlar
- En yoğun confetti

### Mythic (Mitolojik) - Kırmızı
- En yoğun shake + titreme
- Ateş efekti (kırmızı-turuncu)
- Kırmızı partiküller
- Patlayıcı confetti
- Özel mythic sparkle

## Kullanım

```dart
// Basit kutu widget'ı
LootBoxWidget(
  lootBox: userLootBox,
  onTap: () async {
    final result = await LootBoxService().openLootBox(lootBox.id);
    if (result.success) {
      showLootBoxOpeningDialog(
        context,
        lootBox: lootBox,
        reward: result.rewards.first,
        onClose: () {
          // Ödül alındıktan sonra yapılacak işlemler
        },
      );
    }
  },
)

// Doğrudan açılma dialog'u
showLootBoxOpeningDialog(
  context,
  lootBox: userLootBox,
  reward: openedReward,
  onClose: () => Navigator.pop(context),
);
```

## Sonraki Adımlar
- [ ] LootBoxService'e animation callback entegrasyonu
- [ ] Rewards shop page'de kullanım
- [ ] Test senaryoları yazma

