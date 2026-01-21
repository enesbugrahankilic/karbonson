# TODO: Force Refresh After Quiz/Game Completion

## Task
Quiz veya oyun bittikten sonra görevler, başarımlar, puan ve ödül verileri için force refresh yap.
UI eski veriyi göstermesin.

## Implementation Plan

### Phase 1: Create StateRefreshService
- [ ] Create `lib/services/state_refresh_service.dart`
  - Centralized stream for refresh events
  - Methods to trigger refresh for all services
  - Enum for refresh types (achievements, rewards, lootboxes, progress)

### Phase 2: Update GameCompletionService
- [ ] Import and integrate StateRefreshService
- [ ] Trigger refresh after successful completion events

### Phase 3: Update Quiz Completion Handler
- [ ] Update `_sendQuizCompletionEvent` in quiz_page.dart
- [ ] Trigger refresh after quiz completion

### Phase 4: Update Affected Services with Refresh Methods
- [ ] Add `refreshUserData()` to AchievementService
- [ ] Add `refreshInventory()` to RewardService
- [ ] Add `refreshUnopenedBoxes()` to LootBoxService

### Phase 5: Update Pages to Listen to Refresh Events
- [ ] Update `WonBoxesPage` to listen to refresh stream
- [ ] Update `AchievementsGalleryPage` to listen to refresh stream
- [ ] Update `RewardsShopPage` to listen to refresh stream
- [ ] Update `HomeDashboard` pages to listen to refresh stream

### Phase 6: Testing
- [ ] Verify force refresh works on quiz completion
- [ ] Verify UI updates immediately after completion
- [ ] Verify all data types refresh (achievements, rewards, points, boxes)

## Files to Modify
1. `lib/services/state_refresh_service.dart` (new)
2. `lib/services/game_completion_service.dart`
3. `lib/services/achievement_service.dart`
4. `lib/services/reward_service.dart`
5. `lib/services/loot_box_service.dart`
6. `lib/pages/quiz_page.dart`
7. `lib/pages/won_boxes_page.dart`
8. `lib/pages/achievements_gallery_page.dart`
9. `lib/pages/rewards_shop_page.dart`

## Files to Create
1. `lib/services/state_refresh_service.dart`

## Refresh Flow
1. Quiz/Game completion detected
2. GameCompletionService sends completion event to Firestore
3. StateRefreshService.triggerRefresh() called
4. All subscribed services refresh their data
5. UI widgets automatically update via streams

