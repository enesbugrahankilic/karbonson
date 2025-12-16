# SMS 2FA Production Setup Guide

## Twilio Configuration

### 1. Create Twilio Account
- Go to [https://www.twilio.com/console](https://www.twilio.com/console)
- Sign up or log in
- Get your **Account SID** and **Auth Token** from the console dashboard

### 2. Provision SMS-enabled Phone Number
- In Twilio Console → Phone Numbers → Manage Numbers
- Buy or activate a phone number capable of sending SMS
- Example: `+1234567890` (US) or `+905551234567` (Turkey)
- This will be your `TWILIO_FROM_NUMBER`

### 3. Add Credentials to Project

#### Option A: Environment Variables (Recommended for CI/CD)

**macOS / Linux:**
```bash
export TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TWILIO_AUTH_TOKEN="your_auth_token_here"
export TWILIO_FROM_NUMBER="+1234567890"
```

**Windows (PowerShell):**
```powershell
$env:TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$env:TWILIO_AUTH_TOKEN="your_auth_token_here"
$env:TWILIO_FROM_NUMBER="+1234567890"
```

#### Option B: Update Config File (Development Only)
Edit `lib/services/sms_provider_config.dart`:

```dart
class SmsProviderConfig {
  static const String? twilioAccountSid = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  static const String? twilioAuthToken = 'your_auth_token_here';
  static const String? twilioFromNumber = '+1234567890';

  static bool get isConfigured =>
      twilioAccountSid != null && 
      twilioAuthToken != null && 
      twilioFromNumber != null;
}
```

**⚠️ WARNING:** Never commit real credentials to Git! Add to `.gitignore`:
```
# Credentials (NEVER commit these!)
lib/services/sms_provider_config.dart
.env
*.env
```

### 4. Test SMS Sending

**Debug Mode (Simulated):**
```dart
// Runs mock SMS, no Twilio call
final result = await EmailOtpService.sendSmsOtpCode(
  phoneNumber: "05551234567",
  purpose: "two_factor",
);
// Output: ✅ SMS gönderildi: ...
// In debug console: SMS OTP: SMS gönderildi (telefon: +905551234567)
```

**Production Mode (Real Twilio):**
Once credentials are configured, same code calls real Twilio API:
```dart
// Calls Twilio HTTP API
final result = await EmailOtpService.sendSmsOtpCode(
  phoneNumber: "05551234567",
  purpose: "two_factor",
);
// Output: ✅ Twilio SMS sent successfully to +905551234567
```

### 5. Twilio Pricing & Limits

- **Outbound SMS:** ~$0.0075 per message (varies by country)
- **Rate Limits:** Default 100 msgs/second per account
- **Message Validity:** SMS typically delivered within seconds
- **Regions:** Supports 200+ countries including Turkey

### 6. Firestore Indexes

Create these indexes for optimal query performance:

**Collection: `sms_otp_codes`**
```
Index 1: email (Ascending) + status (Ascending)
Index 2: createdAt (Descending)
```

**Collection: `sms_logs`**
```
Index 1: phoneNumber (Ascending) + sentAt (Descending)
Index 2: status (Ascending) + sentAt (Descending)
```

### 7. Security Best Practices

✅ **DO:**
- Store credentials in environment variables
- Use separate credentials for dev/staging/production
- Enable IP whitelisting in Twilio console
- Monitor logs for failed SMS attempts
- Rate limit SMS per user (max 3 attempts/15 min)
- Use HTTPS for all API calls

❌ **DON'T:**
- Hardcode credentials in source code
- Commit `.env` files to Git
- Share credentials with team via email/Slack
- Use same Twilio number for marketing & auth SMS
- Skip Firestore rate limiting rules

### 8. Monitoring & Alerts

Track SMS metrics in Firestore:

```dart
// Query failed SMS attempts
final failedSms = await FirebaseFirestore.instance
    .collection('sms_logs')
    .where('status', isEqualTo: 'failed')
    .where('sentAt', isGreaterThan: DateTime.now().subtract(Duration(hours: 1)))
    .get();

if (failedSms.docs.length > 10) {
  // Alert: High SMS failure rate
}
```

### 9. Alternative SMS Providers

If Twilio doesn't work for your region:

| Provider | Coverage | API Type | Price |
|----------|----------|----------|-------|
| **Firebase SMS** | 200+ countries | REST API | ~$0.01-0.05 |
| **AWS SNS** | 200+ countries | SDK/REST API | ~$0.0075 |
| **Google Cloud SMS** | Limited regions | REST API | ~$0.02 |
| **Vonage (Nexmo)** | 200+ countries | REST API | ~$0.0068 |

### 10. Production Rollout Checklist

- [ ] Twilio account created and verified
- [ ] SMS-capable phone number provisioned
- [ ] Account SID & Auth Token obtained
- [ ] Credentials added via environment variables
- [ ] `sms_provider_config.dart` updated
- [ ] Firestore indexes created
- [ ] Rate limiting implemented in backend
- [ ] SMS logs monitoring set up
- [ ] Test SMS sent successfully
- [ ] Load tested with 100+ SMS messages
- [ ] Monitoring and alerts configured
- [ ] Documentation for team updated
- [ ] Gradual rollout plan created (5% → 25% → 50% → 100%)

---

## Code Examples

### Send 2FA SMS with Error Handling
```dart
try {
  final result = await EmailOtpService.sendSmsOtpCode(
    phoneNumber: "+905551234567",
    purpose: "two_factor",
  );
  
  if (result.isSuccess) {
    print("✅ ${result.message}");
    // Show UI: countdown timer, code input field
  } else {
    print("❌ ${result.message}");
    // Show error UI: retry button
  }
} catch (e) {
  print("❌ Exception: $e");
  // Show critical error UI
}
```

### Verify User's SMS Code
```dart
final verification = await EmailOtpService.verifySmsOtpCode(
  phoneNumber: "+905551234567",
  code: userEnteredCode,
);

if (verification.isValid) {
  print("✅ 2FA verification successful!");
  // Grant access to account
} else if (verification.isExpired) {
  print("❌ Code expired. Request new code.");
} else {
  print("❌ Invalid code. Try again.");
}
```

---

## Support & Troubleshooting

### SMS Not Sending?
1. Check Twilio credentials in `SmsProviderConfig`
2. Verify `kDebugMode` == false for real API calls
3. Check Firestore `sms_logs` for error details
4. Verify phone number is valid E.164 format
5. Check Twilio account balance & rate limits

### High Failure Rate?
- Monitor `sms_logs` collection failures
- Check Twilio dashboard for errors
- Verify network connectivity
- Review Twilio pricing/limits for region

### Need Help?
- Twilio Docs: https://www.twilio.com/docs/sms
- Karbonson 2FA Docs: `docs/sms_2fa_implementation.md`
- Firebase Docs: https://firebase.google.com/docs
