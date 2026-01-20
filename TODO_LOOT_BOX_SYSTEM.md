# Loot Box Sistemi TODO Listesi

## 1. Modeller (lib/models/)
- [ ] `loot_box.dart` - LootBox modeli
- [ ] `loot_box_reward.dart` - LootBoxReward modeli
- [ ] `user_loot_box_inventory.dart` - UserLootBoxInventory modeli

## 2. Servisler (lib/services/)
- [ ] `loot_box_service.dart` - Ana loot box servisi
  - [ ] Kutu verme (grantLootBox)
  - [ ] Kutu açma (openLootBox)
  - [ ] Şans hesaplaması
  - [ ] Entegrasyon noktaları

## 3. Widgetlar (lib/widgets/)
- [ ] `loot_box_widget.dart` - Loot box görsel widget
- [ ] `loot_box_inventory_widget.dart` - Envanter widget
- [ ] `loot_box_opening_dialog.dart` - Kutu açma dialog
- [ ] `loot_box_card.dart` - Kutu kartı

## 4. Sayfalar (lib/pages/)
- [ ] `loot_box_page.dart` - Loot box sayfası
- [ ] `loot_box_collection_page.dart` - Koleksiyon sayfası

## 5. Entegrasyonlar
- [ ] AchievementService entegrasyonu
- [ ] ChallengeService entegrasyonu
- [ ] QuizService entegrasyonu
- [ ] Daily Challenge entegrasyonu

## 6. Animasyonlar
- [ ] Kutu açılış animasyonu
- [ ] Işık efekti animasyonu
- [ ] Reward reveal animasyonu

## 7. Localization
- [ ] Türkçe localization
- [ ] İngilizce localization

## 8. Dokümantasyon
- [ ] Loot box kullanım kılavuzu
- [ ] API dokümantasyonu

## 9. Testler
- [ ] Unit testler
- [ ] Widget testleri

---

## Detaylı Plan

### Loot Box Türleri:
1. **Quiz Kutusu** - Quiz tamamlama ödülü
2. **Görev Kutusu** - Günlük görev ödülü
3. **Başarı Kutusu** - Achievement ödülü
4. **Geri Dönüş Kutusu** - Return reward
5. **Mevsimlik Kutu** - Seasonal event

### Nadirlik Sistemi:
- Sıradan (Common) - 60%
- Nadir (Rare) - 25%
- Destansı (Epic) - 10%
- Efsanevi (Legendary) - 5%

### İçerik Olasılıkları:
- Puan: 40%
- Avatar: 25%
- Tema: 20%
- Özellik: 10%
- Rozet: 5%

---

## Öncelik Sırası:
1. Modeller ve Service (Temel yapı)
2. Widgetlar (UI)
3. Entegrasyonlar (Diğer sistemlerle bağlantı)
4. Animasyonlar (Kullanıcı deneyimi)
5. Testler ve Dokümantasyon

