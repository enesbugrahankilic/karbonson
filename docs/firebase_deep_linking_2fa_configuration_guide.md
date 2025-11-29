# Firebase Deep Linking & 2FA Configuration Guide

## 🔥 Firebase Console Configuration

### 1. Authorized Domains Setup

**Firebase Console Path**: Authentication → Settings → Authorized domains

Add the following domains:
```
karbonson.page.link
firebaseapp.com
web.app
your-domain.com (if using custom domain)
```

### 2. Dynamic Links Domain Configuration

**Firebase Console Path**: Dynamic Links → Get started

1. **Create Dynamic Link Domain**:
   - Domain: `https://karbonson.page.link`
   - Custom domain (optional): `https://links.yourdomain.com`

2. **Configure Link Behavior**:
   - **Deep Link URL**: `https://yourapp.com/reset-password`
   - **Android App**: com.example.karbonson
   - **iOS Bundle ID**: com.example.karbonson
   - **Handle Code in App**: ✅ Enabled

### 3. Email Template Configuration

**Firebase Console Path**: Authentication → Templates → Password reset

#### Password Reset Email Template:
```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
    <h2>🔐 Şifre Sıfırlama</h2>
    <p>Merhaba,</p>
    <p>Şifrenizi sıfırlamak için aşağıdaki bağlantıya tıklayın:</p>
    
    <a href="https://karbonson.page.link/reset-password?mode=resetPassword&oobCode={{CODE}}&email={{EMAIL}}"
       style="display: inline-block; padding: 12px 24px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0;">
        Şifremi Sıfırla
    </a>
    
    <p>Bu bağlantı 24 saat içinde süresi dolacaktır.</p>
    <p>Eğer siz şifre sıfırlama talebinde bulunmadıysanız, bu e-postayı görmezden gelin.</p>
</div>
```

### 4. Multi-Factor Authentication Settings

**Firebase Console Path**: Authentication → Settings → Multi-factor settings

1. **Enable Phone Multi-factor**:
   - ✅ Enable phone factor
   - Select regions/countries as needed

2. **SMS Provider Configuration**:
   - Project: Your Firebase Project ID
   - Location: Same as Firebase project
   - Phone verification: ✅ Enabled

### 5. Email Verification Templates

**Firebase Console Path**: Authentication → Templates → Email address verification

```html
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
    <h2>✅ E-posta Doğrulama</h2>
    <p>Merhaba,</p>
    <p>E-posta adresinizi doğrulamak için aşağıdaki bağlantıya tıklayın:</p>
    
    <a href="https://karbonson.page.link/verify-email?mode=verifyEmail&oobCode={{CODE}}&email={{EMAIL}}"
       style="display: inline-block; padding: 12px 24px; background-color: #28a745; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0;">
        E-postamı Doğrula
    </a>
    
    <p>Bu bağlantı 24 saat içinde süresi dolacaktır.</p>
</div>
```

## 📱 Platform-Specific Configuration

### Android Configuration

**Status**: ✅ Already implemented in `android/app/src/main/AndroidManifest.xml`

**Configured Intent Filters**:
1. Firebase Auth Actions: `*.firebaseapp.com`, `*.web.app` → `/__/auth/action`
2. Firebase Dynamic Links: `*.page.link`, `karbonson.page.link` → `/reset-password`
3. Custom URL Scheme: `karbonson://reset-password`

### iOS Configuration

**Status**: ❌ Needs implementation in `ios/Runner/Associated Domains` and `Info.plist`

**Required Changes**:
1. Add Associated Domains in Apple Developer Console
2. Add `applinks:` prefixes to Info.plist
3. Configure URL schemes as fallbacks

## 🔐 2FA Implementation Requirements

### Firebase Console Steps:

1. **Enable Multi-Factor Authentication**:
   - Go to Authentication → Settings → Multi-factor settings
   - Enable Phone factor
   - Configure SMS provider settings

2. **Set Up SMS Templates** (if custom):
   - Authentication → Templates → SMS
   - Customize verification code message

3. **Configure Phone Number Verification**:
   - Authentication → Sign-in method → Phone
   - Enable phone provider
   - Configure supported regions

### Platform-Specific 2FA Setup:

**iOS Requirements**:
- Enable Push Notifications (for background app refresh)
- Configure Associated Domains for deep linking
- Set up app transport security exceptions if needed

**Android Requirements**:
- Ensure Firebase Messaging is properly configured
- Handle background notifications appropriately
- Configure notification channels for SMS verification

## 🧪 Testing Checklist

### Firebase Console Verification:
- [ ] Authorized domains include all required domains
- [ ] Dynamic Links domain is active and configured
- [ ] Email templates are customized with correct deep link URLs
- [ ] Multi-factor authentication is enabled
- [ ] Phone provider is configured and active

### Platform Configuration:
- [ ] Android: Intent filters properly configured in Manifest
- [ ] iOS: Associated Domains configured in Apple Developer Console
- [ ] iOS: URL schemes added as fallbacks
- [ ] Both platforms: Deep linking packages properly installed

### 2FA Testing:
- [ ] Phone number verification works end-to-end
- [ ] Multi-factor sign-in flow is functional
- [ ] SMS codes are received and verified correctly
- [ ] 2FA can be enabled/disabled properly
- [ ] Error handling works for expired/incorrect codes

## 🛠️ Troubleshooting

### Common Issues:

1. **Deep Links Not Opening App**:
   - Verify Associated Domains (iOS)
   - Check Intent filters (Android)
   - Ensure domain verification is complete

2. **2FA SMS Not Sending**:
   - Check Firebase project quota
   - Verify phone number format (+90...)
   - Ensure SMS provider is properly configured

3. **Email Templates Not Working**:
   - Verify authorized domains include Firebase domains
   - Check email template customization
   - Ensure action code settings are correct

### Debug Commands:

```bash
# Verify iOS Associated Domains
xcrun simctl openurl booted "https://karbonson.page.link/reset-password?mode=resetPassword"

# Test Android deep linking
adb shell am start -W -a android.intent.action.VIEW -d "https://karbonson.page.link/reset-password" com.example.karbonson
```

## 📋 Implementation Status

| Component | Android | iOS | Status |
|-----------|---------|-----|---------|
| Firebase Console Config | N/A | N/A | ✅ Ready |
| Deep Linking Intent Filters | ✅ | ❌ | In Progress |
| Email Templates | N/A | N/A | ✅ Ready |
| 2FA Configuration | N/A | N/A | ✅ Ready |
| Platform Integration | ✅ | ❌ | In Progress |

## 🚀 Next Steps

1. **Complete iOS Associated Domains configuration**
2. **Test deep linking on both platforms**
3. **Implement 2FA UI components**
4. **Add comprehensive error handling**
5. **Create end-to-end test scenarios**