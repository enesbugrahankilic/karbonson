# Profil Fotoğrafı Yükleme Sistemi - TODO

## Hedef
Profil fotoğrafı yükleme sistemini sıfırdan daha doğru bir mantıkla yeniden yazmak.

## Görevler

### 1. ProfilePictureService Yeniden Yazımı
- [x] Basit ve temiz upload mantığı oluştur
- [x] Doğru metadata ayarları ekle
- [x] İlerleme takibi ekle
- [x] Hata yönetimi iyileştir
- Dosya: `lib/services/profile_picture_service.dart`

### 2. ProfilePictureChangeDialog İyileştirme
- [x] Daha iyi loading durumları
- [x] Hata durumunda kullanıcıya bilgi
- [x] Retry mekanizması
- Dosya: `lib/widgets/profile_picture_change_dialog.dart`

### 3. ProfileService Güncelleme
- [x] Profil fotoğrafı güncelleme mantığı iyileştirildi
- Dosya: `lib/services/profile_service.dart`

### 4. Firebase Storage Kuralları Basitleştirme
- [x] Metadata gereksinimi kaldırıldı
- [x] Basit ve etkili kurallar
- Dosya: `firebase/storage.rules`

## Uygulama Sırası
1. TODO dosyası oluştur
2. ProfilePictureService'i yeniden yaz
3. ProfilePictureChangeDialog'u iyileştir
4. ProfileService'i güncelle
5. Storage kurallarını basitleştir
6. Test et

## Notlar
- Kullanıcı deneyimi öncelikli olmalı
- Hata mesajları açık olmalı
- Loading durumları net olmalı

