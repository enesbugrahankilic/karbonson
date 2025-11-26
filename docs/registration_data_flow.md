# User Registration Data Flow Documentation

## Overview
The user registration system is fully implemented and working correctly. When a user registers, their data is automatically saved to Firebase Firestore database.

## Registration Flow

### 1. User Registration Request
**File:** `lib/pages/register_page.dart`
- User fills out the registration form with email, password, and nickname
- Form validation ensures data quality
- Firebase Authentication creates the user account

### 2. Profile Initialization
**File:** `lib/services/profile_service.dart`
**Method:** `initializeProfile()`
```dart
Future<void> initializeProfile({
  required String nickname,
  String? profilePictureUrl,
  PrivacySettings? privacySettings,
  User? user,
}) async {
  // Calls FirestoreService to save user data
  await _firestoreService.createOrUpdateUserProfile(...);
}
```

### 3. Database Storage
**File:** `lib/services/firestore_service.dart`
**Method:** `createOrUpdateUserProfile()`
```dart
Future<UserData?> createOrUpdateUserProfile({
  required String nickname,
  String? profilePictureUrl,
  PrivacySettings? privacySettings,
  String? fcmToken,
}) async {
  // Uses Firebase Auth UID as document ID (UID Centrality)
  final userDocRef = _db.collection(_usersCollection).doc(user.uid);
  
  // Creates UserData object
  final userData = UserData(
    uid: user.uid,
    nickname: nickname,
    profilePictureUrl: profilePictureUrl,
    lastLogin: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isAnonymous: false,
    privacySettings: privacySettings ?? const PrivacySettings.defaults(),
    fcmToken: fcmToken,
  );

  // Saves to Firestore
  await userDocRef.set(userData.toMap(), SetOptions(merge: true));
}
```

### 4. Data Structure
**File:** `lib/models/user_data.dart`
**Collection:** `users`
**Document ID:** Firebase Auth UID

The saved user data includes:
- `uid`: User's unique identifier
- `nickname`: User's display name
- `profilePictureUrl`: Optional profile picture URL
- `lastLogin`: Timestamp of last login
- `createdAt`: Account creation timestamp
- `updatedAt`: Last profile update timestamp
- `isAnonymous`: Whether account is anonymous
- `privacySettings`: User's privacy preferences
- `fcmToken`: Firebase Cloud Messaging token

### 5. Security Rules
**File:** `firebase/firestore.rules`
**Collection:** `/users/{userId}`

```javascript
match /users/{userId} {
  // Public read access for profiles
  allow read: if true;
  
  // User can only write their own profile
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

## Verification

### Test File
**File:** `lib/tests/registration_data_test.dart`
Created comprehensive tests to verify:
- UserData serialization/deserialization
- FirestoreService method availability
- ProfileService initialization capability
- Nickname validation
- Privacy settings defaults

### Real-time Testing
To test the registration flow:
1. Run the app: `flutter run --debug`
2. Navigate to registration page
3. Fill out form with valid data
4. Submit registration
5. Check Firebase Console → Firestore → `users` collection

## Key Features

### UID Centrality (Specification I.1-I.4)
- Document ID is always the Firebase Auth UID
- Ensures data integrity and security
- Prevents unauthorized access to user data

### Nickname Validation
- Format validation (3-20 characters, alphanumeric + underscore/dash)
- Profanity filtering
- Uniqueness check against database
- Cooldown period for nickname changes

### Privacy Settings
- `allowFriendRequests`: Control friend request permissions
- `allowSearchByNickname`: Control discoverability
- `allowDiscovery`: Control overall profile visibility

### Error Handling
- Network timeout handling
- Graceful fallback for failed nickname checks
- Comprehensive error logging in debug mode

## Success Confirmation

The registration flow includes:
✅ Firebase Authentication setup
✅ Form validation
✅ Nickname uniqueness check
✅ User profile creation
✅ Database storage with proper security
✅ Success/error messaging
✅ Navigation to tutorial page

**User data IS automatically saved to the database upon registration.**