# Friends Page Enhancements - Implementation Plan

## Tasks

### 1. Add permission_handler to pubspec.yaml
- [x] Add `permission_handler: ^11.3.0` to dependencies
- [ ] Run `flutter pub get`

### 2. Update deep_link_service.dart with addfriend/{userId} route
- [x] Add 'addfriend' route handling in `_handleBuiltInRoute` method
- [x] Add 'addfriend' to DeepLinkPatterns class
- [x] Add `DeepLinkUtils.addFriend(userId)` generator method

### 3. Integrate friend suggestions tab into friends_page.dart
- [x] Add 5th tab for "Öneriler" (Suggestions)
- [x] Import FriendSuggestionService
- [x] Add list of friend suggestions state variable
- [x] Create method to load friend suggestions
- [x] Implement UI for displaying suggestions with reason badges
- [x] Add send friend request functionality from suggestions

### 4. Add online status indicators to friends list
- [x] Import PresenceService
- [x] Create presence subscription in initState
- [x] Create Map<String, PresenceStatus> for friend presence
- [x] Update friend list UI to show online/offline status
- [x] Add green dot for online, gray for offline
- [x] Add status text label

### 5. Add QR scanner button to friends page
- [x] Add QR icon button in AppBar actions
- [x] Navigate to QRCodeScannerWidget when pressed
- [x] Handle the scanned result to send friend request

## Files to Modify
1. `pubspec.yaml` - Add permission_handler dependency
2. `lib/core/navigation/deep_link_service.dart` - Add addfriend route
3. `lib/pages/friends_page.dart` - Add suggestions tab, online status, QR button

## Testing
- [ ] Test permission_handler integration
- [ ] Test deep link for addfriend route
- [ ] Test friend suggestions loading and display
- [ ] Test online status indicators
- [ ] Test QR scanner navigation and friend request

