# Email Usage Limitation Implementation

## Overview

This implementation adds a limitation where each email address can be used at most 2 times for registration in the system. The solution tracks email usage across all user registrations and prevents third or subsequent registrations with the same email address.

## Implementation Details

### 1. EmailUsageService (`lib/services/email_usage_service.dart`)

**Core Features:**
- Tracks email usage count (maximum 2 uses per email)
- Normalizes email addresses (lowercase, trim whitespace)
- Records which user IDs have used each email
- Provides validation before registration
- Records usage automatically after successful registration

**Key Methods:**
- `canEmailBeUsed(String email)` - Validates if email can be used (less than 2 uses)
- `recordEmailUsage(String email, String userId)` - Records email usage after successful registration
- `getEmailUsage(String email)` - Gets current usage information
- `resetEmailUsage(String email)` - Admin function to reset usage (for testing/manual cleanup)

### 2. Firestore Collection Structure

**Collection:** `email_usage`
**Document ID:** Normalized email address (lowercase, trimmed)

**Document Structure:**
```json
{
  "email": "user@example.com",
  "usageCount": 2,
  "lastUsed": "2025-11-26T19:32:50.148Z",
  "usedUserIds": ["uid1", "uid2"],
  "createdAt": "2025-11-26T19:32:50.148Z",
  "updatedAt": "2025-11-26T19:32:50.148Z"
}
```

### 3. Security Rules (`firebase/firestore.rules`)

Added comprehensive Firestore security rules for the `email_usage` collection:

- **Read Access:** All authenticated users can read email usage for validation
- **Create Access:** Authenticated users can create usage records during registration
- **Update Access:** Authenticated users can increment usage count (max 2)
- **Validation:** Ensures usage count doesn't exceed maximum limit

### 4. Registration Integration

#### RegistrationService (`lib/services/registration_service.dart`)
- Added email usage validation step (Step 1)
- Records email usage after successful profile creation (Step 5)
- Uses fail-open approach: if validation fails, registration is blocked

#### RegisterPage (`lib/pages/register_page.dart`)
- Added email usage validation before Firebase Auth
- Records email usage after profile initialization
- Shows user-friendly error messages

#### RegisterPageRefactored (`lib/pages/register_page_refactored.dart`)
- Inherits validation through RegistrationService
- Automatically includes email usage limitation

## Usage Flow

### 1. User Attempts Registration
```
1. User fills registration form
2. System validates email format
3. **NEW:** Check email usage count
   - If usageCount < 2: Continue to registration
   - If usageCount >= 2: Show error "This email has reached maximum usage limit"
4. Continue with existing validation (nickname uniqueness, etc.)
5. Create Firebase Auth user
6. Initialize user profile
7. **NEW:** Record email usage with user ID
```

### 2. Email Usage Tracking
```
First Registration:
- email_usage count: 0 → 1
- usedUserIds: ["uid1"]

Second Registration:
- email_usage count: 1 → 2  
- usedUserIds: ["uid1", "uid2"]

Third Registration Attempt:
- Validation fails: "This email has been used 2 times. Maximum usage limit reached."
```

## Error Messages

### Turkish Error Messages
- `Bu e-posta adresi zaten 2 kez kullanılmış. Maksimum kullanım sayısına ulaşıldı.` - When email limit is reached
- `E-posta adresi boş olamaz` - When email is empty
- `Bu e-posta adresi kullanılamıyor` - Generic usage error

## Configuration

### Constants (EmailUsageService)
```dart
static const int MAX_EMAIL_USES = 2;
static const String COLLECTION_NAME = 'email_usage';
```

### Changing the Limit
To change the maximum usage limit:
1. Update `MAX_EMAIL_USES` constant in `EmailUsageService`
2. Update Firestore security rules to reflect new limit
3. Update error messages if needed

## Testing

### Test Coverage (`lib/tests/email_usage_test.dart`)
- Email usage validation for 1st, 2nd, and 3rd uses
- Email usage recording functionality
- Edge cases (empty email, normalization, duplicate users)
- Admin functions (statistics, reset)
- Integration with RegistrationService
- Real-world usage scenarios

### Running Tests
```bash
flutter test test/email_usage_test.dart
# or
flutter test lib/tests/email_usage_test.dart
```

## Database Setup

### Firestore Collection
The `email_usage` collection will be created automatically when first used. No manual setup required.

### Indexes
No additional Firestore indexes required for this implementation.

## Security Considerations

1. **Firestore Rules:** Strict access control for email usage collection
2. **Data Integrity:** Usage count is validated on both client and server side
3. **Fail-Open:** Network errors don't block registration (graceful degradation)
4. **Atomic Operations:** Firestore transactions ensure consistency

## Performance Impact

- **Minimal:** Email usage check is a simple document read
- **Efficient:** Uses email as document ID (direct lookup)
- **Scalable:** No complex queries or aggregations required

## Monitoring and Analytics

### Admin Functions
- `getAllEmailUsage()` - Get usage statistics for all emails
- `cleanupOrphanedRecords()` - Clean up invalid usage records

### Potential Metrics
- Email usage distribution
- Registration attempts blocked by email limit
- Most commonly reused emails

## Future Enhancements

1. **Admin Dashboard:** Web interface to view email usage statistics
2. **Automated Cleanup:** Remove usage records for deleted users
3. **Email Verification:** Additional validation for email ownership
4. **Rate Limiting:** Prevent rapid registration attempts
5. **Analytics Dashboard:** Real-time email usage monitoring

## Deployment Steps

1. Deploy updated `firebase/firestore.rules`
2. Deploy updated Flutter application
3. Run tests to verify functionality
4. Monitor logs for any email usage tracking errors

## Rollback Plan

If issues arise:
1. Disable email usage service (comment out calls)
2. Remove Firestore rules (optional)
3. The system will revert to unlimited email usage
4. No data loss - email usage collection can be safely deleted

## Migration Notes

- Existing users: No impact on current registrations
- New registrations: Automatically start tracking email usage
- Backward compatibility: System works even if email usage collection is empty

## Troubleshooting

### Common Issues
1. **"Email already in use" error:** Check Firebase Auth error vs email usage limit error
2. **Registration fails silently:** Check Firestore rules and network connectivity
3. **Usage count incorrect:** Verify Firestore transaction logic

### Debug Mode
Enable debug logging:
```dart
if (kDebugMode) {
  debugPrint('Email usage validation passed: ${emailUsageValidation.emailUsage?.usageCount} uses');
}