# Dil Çeviri Sayfa Çevirme Sorunu Çözümü

## Görev Listesi

### Adım 1: Localization String'leri Ekleme
- [ ] `app_en.arb` dosyasına eksik string'ler ekle
- [ ] `app_tr.arb` dosyasına eksik string'ler ekle

### Adım 2: Flutter gen-l10n Çalıştırma
- [ ] `flutter gen-l10n` komutunu çalıştır

### Adım 3: Settings Page Dialog'larını Güncelleme
- [ ] `_showAccessibilitySettings` dialog'unu düzelt
- [ ] `_showNotificationSettings` dialog'unu düzelt
- [ ] `_showSecuritySettings` dialog'unu düzelt
- [ ] `_showThemePreview` dialog'unu düzelt

### Adım 4: Test
- [ ] `flutter analyze` çalıştır
- [ ] Uygulamayı test et

## Eklenen String'ler

### Developer Tools
- `developerTools`: "Developer Tools"
- `debugAndTestTools`: "Debug and test tools"

### Accessibility
- `accessibilitySettings`: "Accessibility Settings"
- `highContrastMode`: "High Contrast"
- `textScaling`: "Text Scaling"
- `touchTargets`: "Touch Targets"
- `followSystemSettings`: "Follow system settings"
- `activeWCAGCompliant`: "Active - WCAG AA compliant colors"
- `inactiveStandardColors`: "Inactive - Standard colors"
- `minTouchArea`: "48dp minimum touch area"

### Notification Settings
- `notificationSettings`: "Notification Settings"
- `gameStartNotifications`: "Game start"
- `turnNotifications`: "Turn notifications"
- `friendRequests`: "Friend requests"
- `dailyReminders`: "Daily reminders"
- `close`: "Close"

### Security Settings
- `securitySettings`: "Security Settings"
- `twoFactorAuthTitle`: "Two-Factor Authentication"
- `addSecurityLayer`: "Add an extra layer of security to your account"
- `securityTips`: "Security tips:"
- `useStrongPasswords`: "Use strong passwords"
- `updatePasswordRegularly`: "Update your password regularly"
- `enableTwoFactor`: "Enable two-factor authentication"
- `reportSuspiciousActivity`: "Report suspicious activity"

