// Configuration placeholders for SMS provider credentials.
// IMPORTANT: Do NOT commit real credentials to source control.
// Set these via secure environment variables or platform-specific config.

class SmsProviderConfig {
  // Twilio Account SID
  static const String? twilioAccountSid =
      null; // e.g. 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

  // Twilio Auth Token
  static const String? twilioAuthToken = null; // e.g. 'your_auth_token'

  // Twilio sending phone number (E.164 format)
  static const String? twilioFromNumber = null; // e.g. '+1234567890'

  static bool get isConfigured =>
      twilioAccountSid != null &&
      twilioAuthToken != null &&
      twilioFromNumber != null;
}
