# Arkadaş Ekleme Mekanizması - TODO Listesi

## Aşama 1: Modeller (Day 1)

### 1.1 blocked_user.dart
- [ ] BlockedUser sınıfı oluştur
- [ ] fromMap/toMap metodları
- [ ] copyWith metodu
- [ ] Enum: BlockReason

### 1.2 friend_suggestion.dart  
- [ ] FriendSuggestion sınıfı oluştur
- [ ] fromMap/toMap metodları
- [ ] SuggestionReason enum

### 1.3 deep_link_data.dart
- [ ] DeepLinkType enum
- [ ] DeepLinkData sınıfı oluştur
- [ ] fromMap/toMap metodları

### 1.4 friendship_data.dart güncelleme
- [ ] PresenceStatus enum güncelle
- [ ] Friend sınıfına presence alanları ekle
- [ ] FriendRequest sınıfına yeni alanlar

---

## Aşama 2: QR Kod Servisi (Day 2)

### 2.1 qr_code_service.dart
- [ ] QR kod oluşturma (qr_flutter veya qrcode)
- [ ] QR kod tarama entegrasyonu (mobile_scanner)
- [ ] Generate QR for user ID
- [ ] Validate QR code

### 2.2 qr_code_display_widget.dart
- [ ] QR kod görüntüleme widget
- [ ] Share butonu
- [ ] Save to gallery

### 2.3 qr_code_scanner_widget.dart
- [ ] QR kod tarama widget
- [ ] Camera integration
- [ ] Result handling
- [ ] Error handling

---

## Aşama 3: Engelleme Servisi (Day 3)

### 3.1 block_service.dart
- [ ] blockUser() metodu
- [ ] unblockUser() metodu  
- [ ] getBlockedUsers() metodu
- [ ] isUserBlocked() metodu
- [ ] getBlockReason() metodu

### 3.2 friendship_service.dart güncelleme
- [ ] blockUser() wrapper
- [ ] unblockUser() wrapper
- [ ] getBlockedUsers() wrapper
- [ ] isUserBlocked() wrapper
- [ ] checkBlockStatusBeforeRequest()

### 3.3 firestore_service.dart güncelleme
- [ ] blocked_users collection queries
- [ ] Block/unblock atomic operations
- [ ] Block list indices

### 3.4 block_user_dialog.dart
- [ ] Block confirmation dialog
- [ ] Reason selection
- [ ] Report option

---

## Aşama 4: Arkadaş Önerileri (Day 4)

### 4.1 friend_suggestion_service.dart
- [ ] getSuggestionsByCommonFriends()
- [ ] getSuggestionsByRecentGames()
- [ ] getSuggestionsByLeaderboard()
- [ ] calculateSuggestionScore()
- [ ] filterAndRankSuggestions()

### 4.2 friend_suggestion_card.dart
- [ ] UI design
- [ ] Accept/Reject actions
- [ ] Reason display
- [ ] Profile preview

### 4.3 friends_page.dart entegrasyonu
- [ ] Suggestions tab
- [ ] Swipe actions
- [ ] Loading states

---

## Aşama 5: Presence Servisi (Day 5)

### 5.1 presence_service.dart güncelleme
- [ ] updateOnlineStatus()
- [ ] updateLastSeen()
- [ ] listenToFriendsPresence()
- [ ] getOnlineFriends()
- [ ] Presence status enum

### 5.2 presence_indicator_widget.dart
- [ ] Online/offline indicator
- [ ] Status color coding
- [ ] Tooltip with last seen

### 5.3 friends_list.dart entegrasyonu
- [ ] Online indicators on friend items
- [ ] Status text
- [ ] Sort by online status option

### 5.4 profile_page.dart entegrasyonu
- [ ] Show online status
- [ ] Last seen display
- [ ] Privacy settings integration

---

## Aşama 6: Deep Link Servisi (Day 6)

### 6.1 deep_link_service.dart güncelleme
- [ ] handleAddFriendDeepLink()
- [ ] generateAddFriendLink()
- [ ] parseDeepLink()
- [ ] Navigate to FriendsPage with pre-filled user

### 6.2 deep_link_utils.dart
- [ ] URL builder
- [ ] URL parser
- [ ] Validation
- [ ] Fallback handling

### 6.3 main.dart entegrasyonu
- [ ] Initialize deep link handling
- [ ] Handle background links
- [ ] Handle foreground links

### 6.4 friends_page.dart yönlendirme
- [ ] Deep link navigation handler
- [ ] Show friend request dialog
- [ ] Auto-send request option

---

## Aşama 7: UI/UX İyileştirmeleri (Day 7)

### 7.1 add_friend_bottom_sheet.dart
- [ ] QR Code scan option
- [ ] User ID input option
- [ ] Nickname search option
- [ ] Suggestions quick access

### 7.2 user_id_share_widget.dart
- [ ] User ID display
- [ ] Copy button
- [ ] Share link button
- [ ] QR code button

### 7.3 friends_page.dart redesign
- [ ] Modern header design
- [ ] Quick actions bar
- [ ] Improved tabs
- [ ] Better search UI
- [ ] Empty states
- [ ] Pull to refresh

### 7.4 Animations
- [ ] Friend request accepted animation
- [ ] Friend added celebration
- [ ] Swipe to accept/reject
- [ ] Loading skeletons

---

## Aşama 8: Testing (Day 8)

### 8.1 Unit Tests
- [ ] BlockService tests
- [ ] FriendSuggestionService tests
- [ ] QRCodeService tests
- [ ] PresenceService tests

### 8.2 Integration Tests
- [ ] Full friend request flow
- [ ] Block/unblock flow
- [ ] QR code scan flow
- [ ] Deep link handling

### 8.3 UI Tests
- [ ] FriendsPage widget tests
- [ ] Bottom sheet tests
- [ ] Dialog tests
- [ ] Animation tests

---

## Aşama 9: Documentation (Day 9)

### 9.1 API Documentation
- [ ] Service method docs
- [ ] Model docs
- [ ] Widget docs

### 9.2 User Guide
- [ ] How to add friends
- [ ] QR code usage
- [ ] Block feature
- [ ] Privacy settings

### 9.3 Developer Guide
- [ ] Architecture overview
- [ ] Integration guide
- [ ] Testing guide

---

## 📊 Progress Tracking

| Aşama | Durum | Tamamlanan | Toplam |
|-------|-------|------------|--------|
| 1. Modeller | ⏳ | 0 | 10 |
| 2. QR Kod | ⏳ | 0 | 6 |
| 3. Engelleme | ⏳ | 0 | 8 |
| 4. Öneriler | ⏳ | 0 | 6 |
| 5. Presence | ⏳ | 0 | 7 |
| 6. Deep Link | ⏳ | 0 | 7 |
| 7. UI/UX | ⏳ | 0 | 11 |
| 8. Testing | ⏳ | 0 | 9 |
| 9. Documentation | ⏳ | 0 | 3 |

**Toplam: 67 görev**

---

## 🚀 Hızlı Başlangıç

```bash
# Gerekli paketler
flutter pub add qr_flutter mobile_scanner
flutter pub add json_annotation json_serializable
flutter pub add provider firebase_core

# Test çalıştırma
flutter test test/friendship_test_runner.dart

# Uygulama başlatma
flutter run
```

---

**Son Güncelleme:** 2025-11-25  
**Başlangıç:** 2025-11-25  
**Tahmini Süre:** 9 gün
