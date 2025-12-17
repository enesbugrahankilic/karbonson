# Kapsamlı Kimlik Doğrulama Rehberi

## Giriş Yöntemleri

Karbonson uygulaması, güvenliğinizi ve kullanım kolaylığını sağlamak için birden fazla giriş yöntemini destekler:

### 1. Email & Şifre ile Giriş
**En geleneksel ve güvenilir yöntem**
- Kayıt olurken kullandığınız email adresi ve şifrenizle giriş yapın
- İki faktörlü doğrulama (2FA) desteği
- Şifre sıfırlama özelliği

### 2. Biyometrik Giriş
**Hızlı ve güvenli giriş**
- Parmak izi veya yüz tanıma ile anında giriş
- Cihazınızın güvenlik özelliklerini kullanır
- Ek parola gerektirmez

### 3. SMS OTP ile Giriş
**Telefon numaranızla doğrulama**
- Telefonunuza gönderilen 6 haneli kod ile giriş
- İnternet bağlantısı gerektirmez
- Her giriş için yeni kod

### 4. Email OTP ile Giriş
**Email ile doğrulama**
- Email adresinize gönderilen 6 haneli kod ile giriş
- SMS alternatifi
- Güvenli ve kullanışlı

## Kurulum ve Kullanım

### Biyometrik Giriş Kurulumu

1. **Cihazınızın biyometrik özelliklerini kontrol edin:**
   - iOS: Face ID veya Touch ID
   - Android: Parmak izi veya yüz tanıma

2. **Biyometri kurulumunu etkinleştirin:**
   - Ana sayfadaki "Biyometrik Giriş" kartında switch'i açın
   - Biyometrik kimlik doğrulamanızı sağlayın
   - Kurulum tamamlandıktan sonra hızlı giriş kullanılabilir

3. **Biyometrik girişi kullanın:**
   - "Gelişmiş Giriş" butonuna tıklayın
   - "Biyometrik Giriş" seçeneğini seçin
   - Biyometrik kimlik doğrulamanızı sağlayın

### SMS OTP Kurulumu

1. **Twilio hesabınızı hazırlayın:**
   - [twilio.com](https://www.twilio.com) adresinden hesap oluşturun
   - SMS gönderme yetkili bir telefon numarası satın alın
   - Account SID, Auth Token ve telefon numarasını alın

2. **Uygulamada SMS kimlik bilgilerini ayarlayın:**
   ```dart
   // lib/services/sms_provider_config.dart dosyasında
   class SmsProviderConfig {
     static const String? twilioAccountSid = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
     static const String? twilioAuthToken = 'your_auth_token_here';
     static const String? twilioFromNumber = '+1234567890';
   }
   ```

3. **SMS ile giriş yapın:**
   - "Gelişmiş Giriş" butonuna tıklayın
   - "SMS ile Giriş" seçeneğini seçin
   - Telefon numaranızı girin
   - Gelen SMS kodunu girin

### Email OTP Kurulumu

Email OTP, Firebase Authentication ile otomatik olarak çalışır. Ek kurulum gerektirmez.

1. **Email ile giriş yapın:**
   - "Gelişmiş Giriş" butonuna tıklayın
   - "Email ile Giriş" seçeneğini seçin
   - Email adresinizi girin
   - Gelen email kodunu girin

## Güvenlik Özellikleri

### OTP Kodları
- **6 haneli sayısal kodlar**
- **5 dakika geçerlilik süresi**
- **Tek kullanımlık** (bir kez kullanıldıktan sonra geçersiz)
- **Otomatik temizleme** (süresi dolan kodlar silinir)

### Biyometrik Güvenlik
- **Cihaz seviyesinde şifreleme**
- **Yetkisiz erişim koruması**
- **Fallback parola seçeneği**
- **Biyometrik veriler cihazda kalır**

### Hesap Güvenliği
- **Şifre karmaşıklığı gereksinimleri**
- **Hesap kilitleme** (çok fazla başarısız giriş denemesi)
- **Oturum yönetimi**
- **Güvenli çıkış**

## Sorun Giderme

### Biyometrik Giriş Çalışmıyor

**Olası Nedenler:**
1. Cihazınızda biyometrik özellik mevcut değil
2. Biyometrik veri kaydedilmemiş
3. Biyometrik özellik devre dışı bırakılmış

**Çözümler:**
1. **Cihaz ayarlarını kontrol edin:**
   - iOS: Ayarlar > Face ID & Parola / Touch ID & Parola
   - Android: Ayarlar > Güvenlik > Biyometrik

2. **Biyometrik verilerinizi kaydedin:**
   - Cihaz ayarlarından biyometrik kurulumunu tamamlayın

3. **Uygulama içi biyometriyi etkinleştirin:**
   - Ana sayfadaki biyometrik kartında switch'i açın

### SMS Kodu Gelmiyor

**Olası Nedenler:**
1. Twilio kimlik bilgileri yanlış
2. Telefon numarası formatı hatalı
3. Twilio hesabında yeterli bakiye yok

**Çözümler:**
1. **Kimlik bilgilerini kontrol edin:**
   ```dart
   // sms_provider_config.dart dosyasını kontrol edin
   static const String? twilioAccountSid = 'DOĞRU_SID';
   static const String? twilioAuthToken = 'DOĞRU_TOKEN';
   static const String? twilioFromNumber = '+DOĞRU_NUMARA';
   ```

2. **Telefon numarasını kontrol edin:**
   - E.164 formatında olmalı (+905551234567)
   - Ülke kodu ile başlamalı

3. **Twilio hesabını kontrol edin:**
   - Bakiye yeterli mi?
   - Telefon numarası SMS gönderme yetkili mi?

### Email Kodu Gelmiyor

**Olası Nedenler:**
1. Email adresi yanlış
2. Spam klasörü kontrol edilmemiş
3. Firebase konfigürasyonu hatalı

**Çözümler:**
1. **Email adresini kontrol edin:**
   - Doğru yazıldığından emin olun
   - Spam klasörünü kontrol edin

2. **Firebase konfigürasyonunu kontrol edin:**
   - Firebase Console'da Authentication > Sign-in method
   - Email/Password etkin mi?

## Gelişmiş Özellikler

### Çok Faktörlü Doğrulama (2FA)
- Email/şifre girişinden sonra SMS veya email ile ek doğrulama
- Hesap güvenliğini artırır
- İsteğe bağlı olarak etkinleştirilebilir

### Oturum Yönetimi
- Otomatik oturum yenileme
- Güvenli çıkış
- Çoklu cihaz desteği

### Kurtarma Seçenekleri
- Şifre sıfırlama
- Hesap kurtarma
- Destek ekibi iletişimi

## API Referansı

### UnifiedAuthService Sınıfı

```dart
// Email ve şifre ile giriş
AuthResult result = await UnifiedAuthService.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Biyometrik giriş
AuthResult result = await UnifiedAuthService.signInWithBiometric();

// SMS OTP ile giriş
AuthResult result = await UnifiedAuthService.signInWithSmsOtp(
  phoneNumber: '+905551234567',
  otpCode: '123456',
);

// Email OTP ile giriş
AuthResult result = await UnifiedAuthService.signInWithEmailOtp(
  email: 'user@example.com',
  otpCode: '123456',
);

// SMS kodu gönderme
AuthResult result = await UnifiedAuthService.sendSmsOtp(
  phoneNumber: '+905551234567',
);

// Email kodu gönderme
AuthResult result = await UnifiedAuthService.sendEmailOtp(
  email: 'user@example.com',
);

// Biyometrik kurulum
AuthResult result = await UnifiedAuthService.setupBiometric();

// Biyometri kontrolü
bool isEnabled = await UnifiedAuthService.isBiometricEnabled();
bool isAvailable = await UnifiedAuthService.isBiometricAvailable();
```

### AuthResult Kullanımı

```dart
AuthResult result = await UnifiedAuthService.signInWithEmailAndPassword(
  email: email,
  password: password,
);

if (result.isSuccess) {
  // Giriş başarılı
  print('Başarılı: ${result.message}');
  // result.userCredential ile kullanıcı bilgilerine erişebilirsiniz
} else {
  // Giriş başarısız
  print('Hata: ${result.message}');

  // Hata türüne göre özel işlem
  if (result.error == AuthError.userNotFound) {
    // Kullanıcı bulunamadı, kayıt sayfasına yönlendir
  } else if (result.error == AuthError.wrongPassword) {
    // Şifre yanlış, şifre sıfırlama öner
  }

  // Kullanıcı dostu hata mesajı
  String displayMessage = result.error?.displayMessage ?? result.message;
  String suggestion = result.error?.recoverySuggestion ?? 'Tekrar deneyin';
}
```

## Destek

Herhangi bir sorun yaşarsanız:

1. Bu rehberi tekrar inceleyin
2. Hata mesajlarını not alın
3. Destek ekibiyle iletişime geçin
4. GitHub issues sayfasında rapor oluşturun

---

**Son Güncelleme:** Aralık 2025
**Versiyon:** 2.0.0