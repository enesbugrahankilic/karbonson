# Firebase Authentication Düzeltme Rehberi

## Sorun
"internal-error" Firebase Authentication hatası alıyorsunuz. Bu genellikle Firebase projesinde Email/Şifre kimlik doğrulaması etkinleştirilmemiş olduğunda oluşur.

## Çözüm

### 1. Firebase Console'da Authentication'ı Etkinleştirin

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. **karbon2-c39e7** projesini seçin (veya proje adınızı)
3. Sol menüden **"Authentication"** seçeneğine tıklayın
4. **"Get started"** butonuna tıklayın
5. **"Sign-in method"** sekmesine gidin
6. **"Email/Password"** seçeneğini bulun ve tıklayın
7. **"Enable"** anahtarını aktif hale getirin
8. **"Save"** butonuna tıklayın

### 2. Firebase Proje Ayarlarını Kontrol Edin

1. Firebase Console'da proje ayarlarına gidin (⚙️ simgesi)
2. **"General"** sekmesinde **"Your apps"** bölümünü kontrol edin
3. Web app, Android app ve iOS app'lerin doğru şekilde yapılandırıldığından emin olun

### 3. API Key'leri Kontrol Edin

1. Proje ayarları → **"General"** sekmesi
2. **"Project configuration"** altında **"API key"** değerini kopyalayın
3. Bu API key'in android/app/google-services.json ve ios/Runner/GoogleService-Info.plist dosyalarındaki key ile eşleştiğinden emin olun

### 4. Servisleri Etkinleştirin

Firebase Console'da aşağıdaki servislerin etkinleştirildiğinden emin olun:
- ✅ Authentication
- ✅ Firestore Database
- ✅ (Opsiyonel) Cloud Messaging

### 5. Test Edin

Firebase Authentication ayarlarını yaptıktan sonra:
1. Uygulamayı yeniden başlatın
2. Kayıt ol butonunu test edin
3. Farklı bir email adresi ile deneyin

## Hata Durumları

Eğer hala sorun yaşıyorsanız:

### A) API Key Sorunu
- google-services.json dosyasını yeniden indirin
- Dosyayı android/app/ klasörüne yerleştirin
- GoogleService-Info.plist dosyasını ios/Runner/ klasörüne yerleştirin

### B) Firebase Projesi Sorunu
- Yeni bir Firebase projesi oluşturmayı deneyin
- Tüm yapılandırmaları sıfırdan yapın

### C) Bağlantı Sorunu
- İnternet bağlantınızı kontrol edin
- Firewall ayarlarını kontrol edin

## Başarı Göstergeleri

Kayıt işlemi başarılı olduğunda şunları görmelisiniz:
```
flutter: Starting registration for: [email]
flutter: Checking nickname uniqueness: [nickname]
flutter: ✅ Nickname "[nickname]" is available
flutter: Nickname uniqueness confirmed
flutter: Firebase user created: [user_id]
flutter: User profile created in Firestore
flutter: Kayıt başarılı! Hoş geldiniz!
```

## Destek

Sorun devam ederse, Firebase Console'dan Authentication sekmesindeki "Usage" bölümünü kontrol edin. Firebase ücretsiz planının günlük limitlerini aşmış olabilirsiniz.