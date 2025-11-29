# İsteğe Bağlı İki Adımlı Doğrulama (2FA) Entegrasyon Rehberi

Bu döküman, Flutter uygulamanızda İsteğe Bağlı İki Adımlı Doğrulama (2FA) sisteminin nasıl entegre edildiğini açıklamaktadır.

## 📋 Özellikler

- **İsteğe Bağlı 2FA**: Kullanıcılar istediğinde 2FA'yı etkinleştirebilir
- **Telefon Numarası Doğrulaması**: Firebase Phone Auth ile SMS tabanlı doğrulama
- **Otomatik Giriş Yönetimi**: 2FA etkin kullanıcılar için otomatik SMS doğrulama akışı
- **Güvenli Yönetim**: 2FA'yı açma/kapatma imkanı
- **Türkçe Yerelleştirme**: Tam Türkçe kullanıcı arayüzü ve mesajlar

## 🏗️ Mimari

### Ana Bileşenler

1. **Firebase2FAService** (`lib/services/firebase_2fa_service.dart`)
   - 2FA işlemlerini yöneten ana servis
   - Firebase Multi-Factor Authentication API entegrasyonu
   - Türkçe hata mesajları ve yerelleştirme

2. **TwoFactorAuthSetupPage** (`lib/pages/two_factor_auth_setup_page.dart`)
   - 2FA etkinleştirme/devre dışı bırakma arayüzü
   - Telefon numarası girişi ve SMS doğrulama

3. **TwoFactorAuthVerificationPage** (`lib/pages/two_factor_auth_verification_page.dart`)
   - Giriş sırasında SMS doğrulama sayfası
   - Otomatik kod doğrulama ve yönlendirme

### Veri Modelleri

#### TwoFactorAuthResult
```dart
class TwoFactorAuthResult {
  final bool isSuccess;
  final String message;
  final String? userId;
  final bool requires2FA;
  final dynamic multiFactorResolver;
  final dynamic phoneProvider;
}
```

#### TwoFactorVerificationResult
```dart
class TwoFactorVerificationResult {
  final bool isSuccess;
  final String message;
  final String? userId;
  final dynamic credential;
  final bool isExpired;
}
```

#### TwoFactorManagementResult
```dart
class TwoFactorManagementResult {
  final bool isSuccess;
  final String message;
  final String? phoneNumber;
  final bool wasEnabled;
  final bool wasDisabled;
}
```

## 🚀 Kullanım

### 1. 2FA Etkinleştirme

```dart
// 2FA durumunu kontrol et
bool is2FAEnabled = await Firebase2FAService.is2FAEnabled();

// 2FA'yı etkinleştir
final result = await Firebase2FAService.enable2FA(
  phoneNumber: '+90 555 123 45 67',
);

if (result.isSuccess) {
  // SMS doğrulama kodu gönderildi
  showSuccessMessage(result.getTurkishMessage());
} else {
  // Hata mesajı
  showErrorMessage(result.getTurkishMessage());
}
```

### 2. SMS Doğrulama ile 2FA Kurulumu

```dart
// SMS doğrulama başlat
final verificationResult = await Firebase2FAService.start2FAEnrollment(
  phoneNumber: '+90 555 123 45 67',
);

// Kullanıcıdan SMS kodunu al
String smsCode = await getUserInput();

// 2FA kurulumunu tamamla
final setupResult = await Firebase2FAService.finalize2FASetup(
  verificationId: verificationId,
  smsCode: smsCode,
  phoneNumber: '+90 555 123 45 67',
);
```

### 3. 2FA ile Giriş

```dart
// Normal e-posta/şifre girişi
final authResult = await Firebase2FAService.signInWithEmailAndPasswordWith2FA(
  email: 'user@example.com',
  password: 'password123',
);

if (authResult.requires2FA) {
  // 2FA doğrulama sayfasına yönlendir
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TwoFactorAuthVerificationPage(
        authResult: authResult,
      ),
    ),
  );
} else if (authResult.isSuccess) {
  // Başarılı giriş
  navigateToHome();
}
```

### 4. 2FA Doğrulama İşlemi

```dart
// SMS doğrulama başlat
await Firebase2FAService.startPhoneVerification(
  resolver: multiFactorResolver,
  phoneProvider: phoneProvider,
);

// SMS kodunu çöz
final result = await Firebase2FAService.resolveMultiFactorSignIn(
  resolver: multiFactorResolver,
  phoneProvider: phoneProvider,
  verificationId: verificationId,
  smsCode: smsCode,
);

if (result.isSuccess) {
  // Giriş başarılı
  Navigator.pushReplacementNamed(context, '/profile');
}
```

### 5. 2FA'yı Devre Dışı Bırakma

```dart
final result = await Firebase2FAService.disable2FA();

if (result.isSuccess) {
  showSuccessMessage(result.getTurkishMessage());
  // Kullanıcı arayüzünü güncelle
}
```

## 🔧 Firebase Yapılandırması

### 1. Firebase Console Ayarları

1. **Authentication** sekmesine gidin
2. **Sign-in method** sekmesini açın
3. **Phone** sağlayıcısını etkinleştirin
4. **Multi-factor Authentication**'ı etkinleştirin
5. **Phone** faktörünü multi-faktör için etkinleştirin

### 2. Güvenlik Kuralları

Firebase Firestore kurallarınızda 2FA durumunu saklayabilirsiniz:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar kendi 2FA verilerini okuyabilir/yazabilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // 2FA özellikleri alt koleksiyonu
      match /security/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 📱 Kullanıcı Arayüzü

### 2FA Kurulum Sayfası

Ana özellikler:
- Mevcut 2FA durumunu gösterir
- Telefon numarası girişi
- SMS doğrulama kodu girişi
- 2FA'yı etkinleştirme/devre dışı bırakma

### 2FA Doğrulama Sayfası

Ana özellikler:
- SMS doğrulama kodu girişi
- Otomatik kod doğrulama (6 haneli kod girildiğinde)
- Yeniden gönderme seçeneği
- İptal etme seçeneği

### Ayarlar Sayfası Entegrasyonu

```dart
ListTile(
  leading: Icon(Icons.security),
  title: Text('İki Faktörlü Doğrulama'),
  subtitle: Text('Hesabınıza ek güvenlik katmanı ekleyin'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwoFactorAuthSetupPage(),
      ),
    );
  },
),
```

## 🔒 Güvenlik Özellikleri

### 1. Telefon Numarası Doğrulaması
- Firebase Phone Auth ile güvenli SMS doğrulama
- Otomatik kod doğrulama
- Yeniden gönderme koruması

### 2. Oturum Yönetimi
- Multi-factor resolver ile güvenli oturum devamı
- Otomatik oturum temizleme
- Güvenli yönlendirme

### 3. Hata Yönetimi
- Detaylı hata mesajları
- Güvenlik odaklı hata açıklamaları
- Kullanıcı dostu yerelleştirme

## 🌍 Türkçe Yerelleştirme

Tüm mesajlar Türkçe olarak yerelleştirilmiştir:

- **Başarı Mesajları**: "İki faktörlü doğrulama başarıyla etkinleştirildi."
- **Hata Mesajları**: "Doğrulama kodu geçersiz veya süresi dolmuş."
- **Kullanıcı Yönlendirmeleri**: "SMS doğrulama kodu gönderildi. Lütfen telefonunuza gelen kodu girin."

## 🧪 Test Etme

### Manuel Test Senaryoları

1. **2FA Etkinleştirme Testi**:
   - Ayarlar sayfasından 2FA'yı açma
   - Geçerli telefon numarası ile SMS doğrulama
   - Başarılı kurulum sonrası durum güncellemesi

2. **Giriş Akışı Testi**:
   - 2FA etkin hesap ile giriş denemesi
   - Otomatik SMS doğrulama sayfasına yönlendirme
   - SMS kodu ile giriş tamamlama

3. **2FA Devre Dışı Bırakma Testi**:
   - Mevcut 2FA'yı kapatma
   - Onay dialogu
   - Başarılı devre dışı bırakma

### Unit Test Örnekleri

```dart
void main() {
  group('Firebase2FAService Tests', () {
    test('should enable 2FA successfully', () async {
      final result = await Firebase2FAService.enable2FA(
        phoneNumber: '+90 555 123 45 67',
      );
      expect(result.isSuccess, true);
    });

    test('should check 2FA status correctly', () async {
      final isEnabled = await Firebase2FAService.is2FAEnabled();
      expect(isEnabled, isA<bool>());
    });
  });
}
```

## 🔍 Hata Giderme

### Yaygın Hatalar ve Çözümleri

1. **"Multi-factor auth required" Hatası**:
   - Firebase Console'da MFA'nın etkinleştirildiğinden emin olun
   - Phone provider'ın MFA için yapılandırıldığını kontrol edin

2. **SMS Doğrulama Sorunları**:
   - Telefon numarası formatını kontrol edin (+90 ile başlamalı)
   - Firebase Phone Auth limitlerini kontrol edin

3. **Oturum Sorunları**:
   - Multi-factor resolver'ın doğru şekilde geçirildiğinden emin olun
   - Oturum süresi dolmuş olabilir

## 📚 API Referansı

### Firebase2FAService Metotları

#### signInWithEmailAndPasswordWith2FA
```dart
static Future<TwoFactorAuthResult> signInWithEmailAndPasswordWith2FA({
  required String email,
  required String password,
})
```

#### enable2FA
```dart
static Future<TwoFactorManagementResult> enable2FA({
  required String phoneNumber,
  Duration timeout = const Duration(seconds: 60),
})
```

#### start2FAEnrollment
```dart
static Future<TwoFactorVerificationResult> start2FAEnrollment({
  required String phoneNumber,
})
```

#### finalize2FASetup
```dart
static Future<TwoFactorManagementResult> finalize2FASetup({
  required String verificationId,
  required String smsCode,
  required String phoneNumber,
})
```

#### startPhoneVerification
```dart
static Future<TwoFactorVerificationResult> startPhoneVerification({
  required dynamic resolver,
  required dynamic phoneProvider,
  String? phoneNumber,
  Duration timeout = const Duration(seconds: 60),
})
```

#### resolveMultiFactorSignIn
```dart
static Future<TwoFactorAuthResult> resolveMultiFactorSignIn({
  required dynamic resolver,
  required dynamic phoneProvider,
  required String verificationId,
  required String smsCode,
})
```

#### disable2FA
```dart
static Future<TwoFactorManagementResult> disable2FA()
```

#### is2FAEnabled
```dart
static Future<bool> is2FAEnabled()
```

#### getEnrolledPhoneNumbers
```dart
static Future<List<String>> getEnrolledPhoneNumbers()
```

#### updateUserData2FAStatus
```dart
static Future<void> updateUserData2FAStatus(bool is2FAEnabled, String? phoneNumber)
```

## 🔄 Gelecek Geliştirmeler

- **Email 2FA Desteği**: Alternatif doğrulama yöntemi
- **Authenticator App Entegrasyonu**: TOTP tabanlı doğrulama
- **Backup Kodları**: Kurtarma kodları sistemi
- **Gelişmiş Güvenlik**: Biometrik doğrulama entegrasyonu

## 📞 Destek

Herhangi bir sorunla karşılaştığınızda:
1. Firebase Console loglarını kontrol edin
2. Uygulama debug loglarını inceleyin
3. Telefon numarası formatını ve Firebase yapılandırmasını doğrulayın

---

*Bu döküman Flutter uygulamanızda 2FA entegrasyonu için kapsamlı bir rehberdir. Firebase Authentication ve Flutter geliştirme bilgisi gerektirir.*