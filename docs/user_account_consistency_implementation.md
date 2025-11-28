# Kullanıcı Hesap Adı Tutarlılığı Uygulaması

## Genel Bakış
Bu doküman, kullanıcıların profil sayfasından hesaplarına giriş yaptıktan sonra tüm oyun türlerinde kendi hesap adlarının tutarlı bir şekilde kullanılmasını sağlayan sistemin implementasyonunu açıklamaktadır.

## Uygulanan Özellikler

### 1. AuthenticationStateService
- **Dosya**: `lib/services/authentication_state_service.dart`
- **Amaç**: Global kimlik doğrulama durumu yönetimi
- **Özellikler**:
  - Kullanıcının giriş yapıp yapmadığını takip eder
  - Kimlik doğrulanmış kullanıcı adını tüm oyun türlerinde tutarlı şekilde sağlar
  - Çıkış yapana kadar kimlik doğrulama durumunu korur
  - Anonim kullanıcılar için geri dönüş (fallback) mekanizması

### 2. Profil Sayfası Entegrasyonu
- **Dosya**: `lib/pages/profile_page.dart`
- **Güncellemeler**:
  - AuthenticationStateService başlatılır ve mevcut Firebase kullanıcısı kontrol edilir
  - Giriş yapıldığında kimlik doğrulama durumu ayarlanır
  - Çıkış yapıldığında kimlik doğrulama durumu temizlenir

### 3. Giriş Sayfası Güncellemeleri
- **Dosya**: `lib/pages/login_page.dart`
- **Değişiklikler**:
  - Giriş başarılı olduğunda AuthenticationStateService güncellenir
  - Oyun navigasyonu global kimlik doğrulama durumunu kullanır
  - Tüm oyun türleri (tek oyuncu, çok oyuncu, düello) global durumu kullanır

### 4. Oyun Sayfaları Güncellemeleri

#### Quiz Sayfası
- **Dosya**: `lib/pages/quiz_page.dart`
- **Değişiklikler**:
  - `userNickname` parametresi kaldırıldı
  - Global AuthenticationStateService'den kullanıcı adı alınır

#### Düello Sayfası
- **Dosya**: `lib/pages/duel_page.dart`
- **Değişiklikler**:
  - `playerId` ve `playerNickname` parametreleri kaldırıldı
  - Tüm oyun işlevleri global AuthenticationStateService'i kullanır
  - Async yöntemlerle kimlik doğrulama bilgileri alınır

#### Tahta Oyun Sayfası
- **Dosya**: `lib/pages/board_game_page.dart`
- **Değişiklikler**:
  - `userNickname` parametresi opsiyonel yapıldı
  - Parametre verilmezse global AuthenticationStateService'den alınır
  - Hem tek oyuncu hem çok oyuncu modu için güncellenmiştir

### 5. Ana Uygulama Güncellemeleri
- **Dosya**: `lib/main.dart`
- **Değişiklikler**:
  - AuthenticationStateService app providers'a eklendi
  - Global erişim için Provider pattern kullanıldı

## Kullanıcı Akışı

### Yeni Kullanıcı (Anonim)
1. Kullanıcı uygulamayı açar
2. Takma ad girer ve "Tek Oyun" butonuna basar
3. Sistem anonim hesap oluşturur ve oyunu başlatır
4. Kullanıcı adı yerel olarak cache'lenir

### Kayıtlı Kullanıcı Girişi
1. Kullanıcı "Giriş Yap" butonuna basar
2. Email/şifre ile giriş yapar
3. AuthenticationStateService güncellenir
4. Profil sayfasına yönlendirilir
5. **ÖNEMLİ**: Bu noktadan sonra tüm oyunlarda kayıtlı hesap adı kullanılır

### Oyun Oynama (Giriş Yapılmış)
1. Kullanıcı herhangi bir oyun türünü seçer
2. Sistem global AuthenticationStateService'den kullanıcı adını alır
3. Aynı kullanıcı adı tüm oyun türlerinde kullanılır
4. Bu durum çıkış yapana kadar devam eder

### Çıkış İşlemi
1. Kullanıcı profil sayfasında "Çıkış Yap" butonuna basar
2. AuthenticationStateService temizlenir
3. Firebase oturumu sonlandırılır
4. Kullanıcı giriş sayfasına yönlendirilir

## Teknik Detaylar

### AuthenticationStateService Metodları
- `setAuthenticatedUser()`: Kullanıcı girişi yapıldığında çağrılır
- `clearAuthenticationState()`: Çıkış yapıldığında çağrılır
- `getGameNickname()`: Oyunlar için kullanıcı adı döner
- `getGamePlayerId()`: Oyunlar için oyuncu ID'si döner
- `initializeAuthState()`: Mevcut durumu başlatır

### Fallback Mekanizması
- Kimlik doğrulanmamış kullanıcılar için cache'lenmiş kullanıcı adı kullanılır
- Cache'de de yoksa "Oyuncu" varsayılan adı kullanılır

## Test Senaryoları

### Test 1: Yeni Anonim Kullanıcı
1. Uygulamayı açın
2. Takma ad girin ve oyun başlatın
3. Kullanıcı adının oyun boyunca tutarlı olduğunu doğrulayın

### Test 2: Kayıtlı Kullanıcı Girişi
1. Kayıt olun veya mevcut hesapla giriş yapın
2. Profil sayfasına gidin
3. Farklı oyun türlerini deneyin (tek oyuncu, çok oyuncu, düello)
4. Tüm oyunlarda aynı hesap adının kullanıldığını doğrulayın

### Test 3: Çıkış ve Yeniden Giriş
1. Giriş yaptıktan sonra çıkış yapın
2. Yeni takma ad ile oyun başlatın
3. Tekrar giriş yapın
4. Hesap adının değiştiğini doğrulayın

## Faydalar

1. **Tutarlılık**: Kullanıcı adı tüm oyun türlerinde aynı kalır
2. **Kimlik Doğrulama**: Sadece profil sayfasından giriş/çıkış mümkündür
3. **Kullanıcı Deneyimi**: Kullanıcılar hangi oyunu oynarsa oynasın kendi hesap adlarını görürler
4. **Güvenlik**: Çıkış yapana kadar kimlik doğrulama durumu korunur

## Notlar

- Sistem Firebase Authentication kullanır
- Cache mekanizması SharedPreferences ile çalışır
- Tüm oyun sayfaları global durumu otomatik olarak kullanır
- Geriye uyumluluk korunmuştur (anonim kullanıcılar için)