# Arkadaş Ekleme Geliştirme - TODO Listesi

## Aşama 1: Mantık Hataları Düzeltme

### 1.1 Firestore Service - Race Condition Fix
- [ ] `sendFriendRequest()` - Add duplicate request check
- [ ] `canSendFriendRequest()` - Improve privacy validation
- [ ] `acceptFriendRequest()` - Add atomic validation
- [ ] `rejectFriendRequest()` - Add atomic validation

### 1.2 Friends Page - Spam Prevention
- [ ] Add `_sentRequests` check before sending
- [ ] Add `_friends` check before sending
- [ ] Add loading state during request
- [ ] Add feedback on request result

---

## Aşama 2: UI/UX Widgets

### 2.1 Add Friend Bottom Sheet
- [ ] Create `add_friend_bottom_sheet.dart`
- [ ] QR Scanner option
- [ ] User ID input option
- [ ] Quick access to suggestions
- [ ] Integrate with Friends Page

### 2.2 User ID Share Widget
- [ ] Create `user_id_share_widget.dart`
- [ ] Display user ID
- [ ] Copy button
- [ ] Share button
- [ ] Integrate with Profile Page

### 2.3 QR Code Display Widget
- [ ] Create `qr_code_display_widget.dart`
- [ ] Generate QR with user data
- [ ] Save to gallery option
- [ ] Share QR option
- [ ] Integrate with Profile Page

---

## Aşama 3: Blocking Feature

### 3.1 Block Service
- [ ] Create `block_service.dart` or add to friendship_service
- [ ] `blockUser()` method
- [ ] `unblockUser()` method
- [ ] `getBlockedUsers()` method
- [ ] `isUserBlocked()` method

### 3.2 Block User Dialog
- [ ] Create `block_user_dialog.dart`
- [ ] Reason selection
- [ ] Report option
- [ ] Confirm block action

### 3.3 Unblock Functionality
- [ ] Add blocked users tab
- [ ] Unblock button on each blocked user
- [ ] Empty state for blocked list

---

## Aşama 4: Deep Link & QR

### 4.1 Deep Link Service Update
- [ ] Handle `addfriend/{userId}` route
- [ ] Auto-send friend request
- [ ] Navigate to Friends Page with pre-filled user

### 4.2 QR Scanner Update
- [ ] Better deep link parsing
- [ ] User ID validation
- [ ] Better error handling

### 4.3 QR Code Service
- [ ] Create `qr_code_service.dart` or update existing
- [ ] Generate friend QR format
- [ ] Parse friend QR format

---

## Aşama 5: Friends Page Updates

### 5.1 Add Friend FAB
- [ ] Floating action button
- [ ] Open bottom sheet on tap

### 5.2 Context Menu for Friends
- [ ] Long press menu
- [ ] Block option
- [ ] Remove friend option
- [ ] View profile option

### 5.3 UI Improvements
- [ ] Better empty states
- [ ] Loading skeletons
- [ ] Celebration animation on new friend
- [ ] Swipe to accept/reject requests

---

## 📊 Progress Tracking

| Aşama | Durum | Tamamlanan | Toplam |
|-------|-------|------------|--------|
| 1. Mantık Hataları | ⏳ | 0 | 7 |
| 2. UI/UX Widgets | ⏳ | 0 | 8 |
| 3. Blocking Feature | ⏳ | 0 | 7 |
| 4. Deep Link & QR | ⏳ | 0 | 6 |
| 5. Friends Page | ⏳ | 0 | 7 |

**Toplam: 35 görev**

---

## 🚀 Hızlı Başlangıç

```bash
# Gerekli paketler
flutter pub add qr_flutter
flutter pub add permission_handler
flutter pub get

# Test çalıştırma
flutter test test/friendship_test_runner.dart

# Uygulama başlatma
flutter run
```

---

**Son Güncelleme:** 2025-11-25  
**Başlangıç:** 2025-11-25

