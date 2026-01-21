# Günlük Görev Ödül Sistemi Implementasyon Planı

## Özet
Günlük görev tamamlandığında anında ödül (loot box) verilmesi ve UI-backend senkronizasyonu.

## Bileşenler

### 1. DailyTaskRewardService (YENİ)
- `lib/services/daily_task_reward_service.dart`
- Görev tamamlama -> Loot box grant entegrasyonu
- Reward grant sonuçlarını stream'leme
- UI notification entegrasyonu

### 2. ChallengeService Güncellemesi
- `lib/services/challenge_service.dart`
- `completeDailyChallenge()` metoduna loot box grant ekle
- Haftalık görevler için de loot box desteği
- Atomic transaction ile veritabanı güncellemesi

### 3. DailyTaskEventService Güncellemesi
- `lib/services/daily_task_event_service.dart`
- Challenge completion event'lerinde reward trigger
- `onChallengeCompleted()` metodu eklenecek

### 4. UI Güncellemeleri
- `lib/widgets/daily_task_card.dart`
- Reward animation ve notification
- Loot box opening dialog entegrasyonu

### 5. State Refresh Entegrasyonu
- `lib/services/state_refresh_service.dart`
- Reward grant event'leri için refresh trigger

---

## Detaylı Adımlar

### Adım 1: DailyTaskRewardService Oluştur
- [ ] Reward grant model sınıfları
- [ ] Loot box grant metodları
- [ ] Stream controller'lar
- [ ] UI notification callback'leri

### Adım 2: ChallengeService Güncelle
- [ ] `completeDailyChallenge()` loot box grant ile
- [ ] `completeWeeklyChallenge()` loot box grant ile
- [ ] Rarity calculation (difficulty bazlı)
- [ ] Transaction-based updates

### Adım 3: DailyTaskEventService Güncelle
- [ ] Challenge completion event'lerinde reward trigger
- [ ] Integration with LootBoxService
- [ ] Audit logging

### Adım 4: UI Güncellemeleri
- [ ] Completion animation
- [ ] Reward notification widget
- [ ] Loot box opening dialog trigger
- [ ] Sound effects integration

### Adım 5: Test ve Entegrasyon
- [ ] Unit test'ler
- [ ] Integration test'ler
- [ ] Performance validation

---

## Loot Box Rarity Dağılımı

| Challenge Difficulty | Loot Box Rarity | Chance |
|---------------------|-----------------|--------|
| Easy | Common | 100% |
| Medium | Common (70%) / Rare (30%) | 100% |
| Hard | Rare (60%) / Epic (30%) / Legendary (10%) | 100% |
| Expert | Epic (50%) / Legendary (40%) / Mythic (10%) | 100% |

---

## UI-Backend Senkronizasyon Akışı

```
1. User completes challenge action
   ↓
2. ChallengeService.updateDailyChallengeProgress()
   ↓
3. Check if target reached (isCompleted)
   ↓
4. DailyTaskRewardService.grantReward()
   - Calculate rarity based on difficulty
   - Call LootBoxService.grantLootBox()
   - Save to Firestore
   ↓
5. StateRefreshService.triggerRewardsRefresh()
   ↓
6. UI receives refresh event via Stream
   ↓
7. Show reward animation/notification
   ↓
8. User can open loot box from inventory
```

---

## Dosyalar

### Oluşturulacak:
- `lib/services/daily_task_reward_service.dart` (YENİ)

### Düzenlenecek:
- `lib/services/challenge_service.dart`
- `lib/services/daily_task_event_service.dart`
- `lib/services/loot_box_service.dart`
- `lib/services/state_refresh_service.dart`
- `lib/widgets/daily_task_card.dart`
- `lib/l10n/app_en.arb` (i18n)
- `lib/l10n/app_localizations_tr.dart` (i18n)

