# Kapsamlı Karbon Ayak İzi Entegrasyon Planı

## Problem Tanımı
1. Login sırasında sınıf bilgisi istenmiyor
2. Home dashboard'da sadece buton var, gerçek veri yok
3. Sınıf bilgisi olmayan kullanıcılar rastgele demo veri görüyor

## Çözüm Planı

### Adım 1: Login Page'de Sınıf Seçimi Entegrasyonu
- [ ] Login成功后 kullanıcının sınıf bilgisi kontrol edilecek
- [ ] Sınıf bilgisi yoksa dialog ile seçim istenecek
- [ ] Seçim Firestore'a kaydedilecek

### Adım 2: Home Dashboard'da Karbon Verisi Gösterimi
- [ ] CarbonFootprintService'den gerçek veriler çekilecek
- [ ] Özet kartı oluşturulacak (karbon değeri, durum)
- [ ] Sınıf bilgisi yoksa uyarı gösterilecek

### Adım 3: Profile Page Güncellemesi
- [ ] Sınıf bilgisi düzenleme özelliği eklenecek

## Dosyalar
1. lib/pages/login_page.dart
2. lib/pages/home_dashboard.dart  
3. lib/services/carbon_footprint_service.dart
4. lib/services/profile_service.dart
5. lib/widgets/carbon_class_selection_widget.dart

## Test Edilecek Senaryolar
- ✅ Yeni kullanıcı login -> sınıf seçimi dialog
- ✅ Mevcut kullanıcı login -> direkt home dashboard
- ✅ Sınıf bilgisi ile karbon verisi gösterimi
- ✅ Sınıf bilgisi yoksa uyarı mesajı

## Tamamlanma Durumu
- Status: BAŞLAMADI
- Başlangıç: -
- Bitiş: -

