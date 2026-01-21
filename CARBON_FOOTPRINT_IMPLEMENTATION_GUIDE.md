# Karbon Ayak İzi Sistemi - Uygulama Entegrasyonu

## 📋 Sistem Genel Bakış

Bu dokümantasyon, Karbonson uygulamasında uygulanmış olan **Karbon Ayak İzi** sisteminin tüm bileşenlerini açıklamaktadır.

### Temel Özellikler
- ✅ Sınıf/Şube bazlı karbon ölçümü
- ✅ Dinamik Firebase entegrasyonu
- ✅ Sınıf düzeyine göre bitkiler (9-10. sınıflar)
- ✅ Kuzey/Güney konum analizi
- ✅ Karbon raporları (PNG, PDF, Excel)
- ✅ AI önerileri ve görevler
- ✅ Sınıf karşılaştırması ve liderlik tablosu entegrasyonu

---

## 🗂️ Dosya Yapısı

### Models
```
lib/models/
├── carbon_footprint_data.dart    # Karbon veri modelleri
```

### Services
```
lib/services/
├── carbon_footprint_service.dart          # Firebase entegrasyonu
├── carbon_report_service.dart             # Rapor oluşturma
└── carbon_ai_recommendation_service.dart  # AI önerileri
```

### Pages
```
lib/pages/
└── carbon_footprint_page.dart            # Ana ekran
```

### Widgets
```
lib/widgets/
└── carbon_class_selection_widget.dart    # Sınıf seçim widget'ı
```

### Extensions
```
lib/extensions/
└── user_data_carbon_extension.dart       # UserData uzantıları
```

### Tests
```
lib/tests/
└── carbon_footprint_data_test.dart       # Birim testleri
```

---

## 📊 Veri Modelleri

### CarbonFootprintData

Temel karbon ölçüm veri modelidir.

**Alanlar:**
```dart
- id: String                           // Belge ID (örn: "9A")
- classLevel: int                      // Sınıf düzeyi (9-12)
- classSection: String                 // Şube (A-F)
- classOrientation: ClassOrientation   // Konum (north/south)
- hasPlants: bool                      // Bitkili mi? (9-10. sınıflara özel)
- carbonValue: int                     // Karbon değeri (400-4000)
- measuredAt: DateTime?                // Ölçüm tarihi
- updatedAt: DateTime?                 // Güncellenme tarihi
- isActive: bool                       // Aktif mi?
```

**Doğrulama Kuralları:**
```
✓ Sınıf kuralları:
  - 9. sınıf: A, B, C, D şubeleri
  - 10-12. sınıf: A, B, C, D, E, F şubeleri

✓ Bitki durumu:
  - 9-10. sınıflarda: true/false mümkün
  - 11-12. sınıflarda: her zaman false

✓ Karbon değerleri:
  - Aralık: 400 - 4000 g CO₂/gün

✓ Konum:
  - north: Kuzey yönlü (karbon değeri daha yüksek)
  - south: Güney yönlü (karbon değeri daha düşük)
```

### CarbonReport

Rapor sunumu için kullanılan model.

```dart
- carbonData: CarbonFootprintData
- percentage: double
- averageCarbonForClassLevel: int?
- averageCarbonForClassSection: int?
- isAboveAverage: bool
```

### CarbonStatistics

İstatistiksel veriler.

```dart
- allData: List<CarbonFootprintData>
- totalCarbon: double
- averageCarbon: double
- maxCarbon: int
- minCarbon: int
```

---

## 🔧 Hizmetler (Services)

### CarbonFootprintService

**Ana Firebse işlemleri:**

```dart
// Belirli bir sınıfın karbon verilerini al
getCarbonDataByClass(int classLevel, String classSection)

// Sınıf düzeyine göre tüm verileri al
getCarbonDataByClassLevel(int classLevel)

// Tüm karbon verilerini al
getAllCarbonData()

// Bitki durumuna göre verileri al
getCarbonDataByPlantStatus(bool hasPlants)

// Konum (kuzey/güney) göre verileri al
getCarbonDataByOrientation(String orientation)

// Ortalama karbon hesapla
getAverageCarbonForClassLevel(int classLevel)

// İstatistikler al
getCarbonStatistics()

// Karbon verisi oluştur/güncelle
setCarbonData(CarbonFootprintData data)

// Real-time akışı dinle
streamCarbonData(int classLevel, String classSection)
```

**Örnek Kullanım:**

```dart
final service = CarbonFootprintService();

// 9A sınıfının verilerini al
final data = await service.getCarbonDataByClass(9, 'A');

// 9. sınıfın ortalama karbonunu hesapla
final average = await service.getAverageCarbonForClassLevel(9);

// Tüm istatistikleri al
final stats = await service.getCarbonStatistics();
```

### CarbonReportService

**Rapor oluşturma ve yönetim:**

```dart
// PNG raporu oluştur
generatePNGReport(CarbonFootprintData carbonData, {int? averageCarbon})

// PDF raporu oluştur
generatePDFReport(CarbonFootprintData carbonData, {int? averageCarbon, String schoolName})

// Excel raporu oluştur
generateExcelReport(CarbonFootprintData carbonData, {int? averageCarbon, String filename})

// Rapor dosya adı al
getReportFilename({required String classIdentifier, required String format})

// Rapor görüntü verisi oluştur
createReportDisplayData(CarbonFootprintData carbonData, {int? averageCarbon})

// Paylaşım verisi hazırla
prepareReportForSharing(CarbonFootprintData carbonData, {String schoolName, int? averageCarbon})
```

**Örnek Kullanım:**

```dart
final reportService = CarbonReportService();

// Rapor görüntü verisi oluştur
final displayData = reportService.createReportDisplayData(
  carbonData,
  averageCarbon: 2100,
  allClassLevelData: classLevelData,
);

// Dosya adı al
final filename = reportService.getReportFilename(
  classIdentifier: '9A',
  format: 'pdf',
);
```

### CarbonAIRecommendationService

**AI önerileri ve görevler:**

```dart
// Karbon verilerine dayalı öneriler
generateCarbonRecommendations({
  required CarbonFootprintData carbonData,
  required UserData userData,
  required int? averageCarbon,
})

// Günlük mikro görevler
generateCarbonMicroTasks({
  required CarbonFootprintData carbonData,
  required UserData userData,
})

// Sınıf karşılaştırma analizi
getClassComparisonInsights({
  required CarbonFootprintData userClass,
  required List<CarbonFootprintData> allClassData,
  required int averageCarbon,
})

// Başarı önerileri
getCarbonAchievementSuggestions({
  required CarbonFootprintData carbonData,
  required UserData userData,
  required int? averageCarbon,
})
```

**Örnek Kullanım:**

```dart
final aiService = CarbonAIRecommendationService();

// Öneriler al
final recommendations = await aiService.generateCarbonRecommendations(
  carbonData: userClassData,
  userData: userData,
  averageCarbon: 2100,
);

// Günlük görevler al
final tasks = await aiService.generateCarbonMicroTasks(
  carbonData: userClassData,
  userData: userData,
);
```

---

## 📱 UI Ekranlar

### CarbonFootprintPage

Ana karbon ekranı.

**Sekmeleri:**
1. **Özet (Summary Tab)**
   - Sınıf bilgi kartı
   - Karbon değeri göstergesi
   - Karşılaştırma kartı
   - Durum göstergeleri

2. **Detaylar (Details Tab)**
   - Sınıf düzeyi dağılımı
   - Tüm veriler tablosu

3. **Rapor (Report Tab)**
   - İndirme butonları (PNG, PDF, Excel)
   - Paylaş butonu
   - Rapor özeti

**Özellikleri:**
- Real-time veri yükleme
- Hata yönetimi
- Boş durum görüntüleme
- Yenileme butonu

---

## 🗑️ Örnek Veriler

Sistem başlatıldığında aşağıdaki örnek veriler otomatik olarak yüklenir:

### 9. Sınıf
```
9A (güney, bitkili): 620 g CO₂
9B (kuzey, bitkili): 740 g CO₂
9C (güney, bitkili): 580 g CO₂
9D (kuzey, bitkili): 810 g CO₂
```

### 10. Sınıf
```
10A (güney, bitkili): 900 g CO₂
10B (kuzey, bitkili): 1050 g CO₂
10C (güney, bitkili): 880 g CO₂
10D (kuzey, bitkili): 1120 g CO₂
10E (güney, bitkili): 960 g CO₂
10F (kuzey, bitkili): 1180 g CO₂
```

### 11. Sınıf
```
11A (güney, bitkisiz): 2100 g CO₂
11B (kuzey, bitkisiz): 2350 g CO₂
11C (güney, bitkisiz): 1980 g CO₂
11D (kuzey, bitkisiz): 2600 g CO₂
11E (güney, bitkisiz): 2250 g CO₂
11F (kuzey, bitkisiz): 2750 g CO₂
```

### 12. Sınıf
```
12A (güney, bitkisiz): 3000 g CO₂
12B (kuzey, bitkisiz): 3200 g CO₂
12C (güney, bitkisiz): 2900 g CO₂
12D (kuzey, bitkisiz): 3400 g CO₂
12E (güney, bitkisiz): 3100 g CO₂
12F (kuzey, bitkisiz): 3600 g CO₂
```

---

## 🔐 Login & Sınıf Seçimi Entegrasyonu

### Kayıt Sırasında Sınıf Seçimi

`CarbonClassSelectionWidget` kullanılarak:

```dart
CarbonClassSelectionWidget(
  initialClassLevel: null,
  initialClassSection: null,
  onClassSelected: (classInfo) {
    // classInfo.classLevel
    // classInfo.classSection
  },
  isRequired: true,
  helperText: 'Sınıf bilgisi karbon raporlarında kullanılacaktır',
)
```

### UserData'ya Sınıf Bilgisi Ekleme

```dart
// UserData modeline zaten entegre
final userData = UserData(
  uid: uid,
  nickname: nickname,
  classLevel: 9,      // Yeni alan
  classSection: 'A',  // Yeni alan
);
```

### Extension Kullanımı

```dart
// UserData üzerinde kullanılabilir
if (userData.hasValidClassSelection()) {
  // Geçerli bir sınıf seçimi var
}

final sections = userData.getValidSections(); // Bu sınıf düzeyinin şubeleri
final identifier = userData.getClassIdentifier(); // "9A"
final displayName = userData.getClassDisplayName(); // "Dokuzuncu Sınıf A Şubesi"
```

---

## 🎯 Akış ve Kullanıcı Deneyimi

### 1. İlk Kayıt
```
1. Kullanıcı kaydı yapar
2. Sınıf düzeyi ve şubesi seçilir
3. Bilgiler UserData'ya kaydedilir
```

### 2. Login Sonrası
```
1. Kullanıcı login olur
2. Sınıf bilgisine göre karbon verisi otomatik yüklenir
3. (İsteğe bağlı) Karbon Ayak İzi ekranına yönlendirme
```

### 3. Karbon Ekranı
```
1. Kendi sınıfının karbon verisi gösterilir
2. Sınıf düzeyindeki ortalamayla karşılaştırılır
3. AI önerileri ve görevler sunulur
```

### 4. Rapor İndirme
```
1. PNG, PDF, veya Excel formatında rapor oluştur
2. Dosya cihaza indir
3. (İsteğe bağlı) Paylaş
```

---

## 📊 Firebase Koleksiyonu Yapısı

```
Firestore
├── carbon_footprints (collection)
│   ├── 9A (document)
│   │   ├── classLevel: 9
│   │   ├── classSection: "A"
│   │   ├── classOrientation: "south"
│   │   ├── hasPlants: true
│   │   ├── carbonValue: 620
│   │   ├── measuredAt: timestamp
│   │   ├── updatedAt: timestamp
│   │   └── isActive: true
│   ├── 9B (document)
│   │   └── ... (similar structure)
│   └── ... (all classes)
└── users (existing collection)
    └── [uid] (document)
        ├── classLevel: 9
        ├── classSection: "A"
        └── ... (other user fields)
```

---

## 🤖 AI Önerileri Örnekleri

### Karbona Dayalı Öneriler

1. **Yüksek Karbon Değeri:**
   > "⚠️ Sınıfınızın karbon ayak izi ortalamanın 15% üzerinde. Enerji tasarrufu önlemleri alınması önerilir."

2. **Bitkisiz Sınıf (9-10. sınıf):**
   > "🌿 Bitkisiz bir sınıf. İçeride bitkiler yetiştirilmesi karbon absorpsiyonunu artırabilir."

3. **Kuzey Yönlü Sınıf:**
   > "🧭 Kuzey yönlü sınıflar daha az doğal ışık alır. LED ışıklandırmaya geçiş yapılması önerilir."

### Sınıf Düzeyine Göre Görevler

- **9. Sınıf:** Enerji tasarrufu quizi
- **10. Sınıf:** Laboratuvar atık yönetimi
- **11. Sınıf:** Yenilenebilir enerji araştırması
- **12. Sınıf:** Iklim değişikliği projesi

---

## ✅ Testler

### Çalıştırma

```bash
flutter test lib/tests/carbon_footprint_data_test.dart
```

### Test Kapsamı

- ✅ Veri modeli doğrulama
- ✅ Sınıf kuralları
- ✅ Karbon değer aralığı
- ✅ Bitki durumu doğrulaması
- ✅ Firestore serileştirme
- ✅ İstatistik hesaplamaları
- ✅ Raporlama

---

## 🔄 Gelecek Adımlar

### Phase 2
- [ ] PDF/PNG/Excel rapor oluşturma kütüphaneleri
- [ ] Grafiksel pasta gösterim (fl_chart)
- [ ] Rapor paylaşım entegrasyonu
- [ ] Sınıflar arası çevreci yarış

### Phase 3
- [ ] Öğretmen paneli
- [ ] Okulun toplam karbon raporu
- [ ] Tarihsel karbon trendi
- [ ] Karbon ödül sistemi

### Phase 4
- [ ] Mobil uygulama dışı web paneli
- [ ] Yapay zeka ile geliştirilmiş öneriler
- [ ] Karbon nötralizasyon hedefleri
- [ ] Çevreci sertifikasyonlar

---

## 🆘 Sorun Giderme

### Sınıf Seçimi Görüntülenmiyor
1. UserData modeline sınıf alanları eklenmiş mi?
2. Widget'ta `isRequired` ayarları kontrol et

### Karbon Verileri Yüklenmüyor
1. Firebase bağlantısı kontrol et
2. `initializeSeedData()` çağrıldı mı?
3. Firestore güvenlik kuralları kontrol et

### Rapor İndirmesi Çalışmıyor
1. `file_picker` ve `pdf` paketleri yüklenmiş mi?
2. Dosya yazma izinleri kontrol et

---

## 📚 Referanslar

- Flutter Documentation: https://flutter.dev
- Cloud Firestore: https://firebase.google.com/docs/firestore
- Dart Documentation: https://dart.dev/guides

---

**Versiyon:** 1.0.0  
**Son Güncellenme:** 2026  
**Katkıda Bulunanlar:** Karbonson Development Team
