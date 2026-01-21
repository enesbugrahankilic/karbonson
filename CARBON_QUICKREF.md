# 🌱 Karbon Ayak İzi Sistemi - Developer Quick Reference

## 📌 Dosya Konumları

```
lib/
├── models/
│   └── carbon_footprint_data.dart ..................... Veri modelleri
├── services/
│   ├── carbon_footprint_service.dart .................. Firebase işlemleri
│   ├── carbon_report_service.dart ..................... Rapor oluşturma
│   └── carbon_ai_recommendation_service.dart .......... AI önerileri
├── pages/
│   └── carbon_footprint_page.dart ..................... Ana ekran
├── widgets/
│   └── carbon_class_selection_widget.dart ............. Sınıf seçim
├── extensions/
│   └── user_data_carbon_extension.dart ............... UserData uzantısı
└── tests/
    └── carbon_footprint_data_test.dart ............... Unit testler
```

---

## ⚡ En Sık Kullanılan Kodlar

### 1️⃣ Karbon Verileri Almak
```dart
final carbonService = CarbonFootprintService();
final data = await carbonService.getCarbonDataByClass(9, 'A');
```

### 2️⃣ Sınıf Seçimini Kontrol Etmek
```dart
if (userData.hasValidClassSelection()) {
  final identifier = userData.getClassIdentifier(); // "9A"
}
```

### 3️⃣ Ortalama Karbon Hesaplamak
```dart
final average = await carbonService
    .getAverageCarbonForClassLevel(9);
```

### 4️⃣ İstatistikler Almak
```dart
final stats = await carbonService.getCarbonStatistics();
print('Toplam: ${stats.totalCarbon}');
print('Ortalama: ${stats.averageCarbon}');
```

### 5️⃣ AI Önerileri Almak
```dart
final aiService = CarbonAIRecommendationService();
final recommendations = await aiService
    .generateCarbonRecommendations(
      carbonData: data,
      userData: userData,
      averageCarbon: average,
    );
```

### 6️⃣ Günlük Görevler Oluşturmak
```dart
final tasks = await aiService.generateCarbonMicroTasks(
  carbonData: data,
  userData: userData,
);
```

### 7️⃣ Rapor Görüntü Verileri Hazırlamak
```dart
final reportService = CarbonReportService();
final displayData = reportService.createReportDisplayData(
  carbonData,
  averageCarbon: 2100,
);
```

### 8️⃣ Real-Time Dinlemek
```dart
carbonService
    .streamCarbonData(9, 'A')
    .listen((data) {
      print('Veri güncellendi: ${data?.carbonValue}');
    });
```

---

## 🎯 Sınıf / Şube Kombinasyonları

```
✅ Geçerli Kombinasyonlar:

9A, 9B, 9C, 9D
10A, 10B, 10C, 10D, 10E, 10F
11A, 11B, 11C, 11D, 11E, 11F
12A, 12B, 12C, 12D, 12E, 12F

❌ Geçersiz:
9E, 9F (9. sınıfta bu şubeler yok)
13A, 8A (Bu sınıf düzeyleri yok)
```

---

## 📊 Örnek Karbon Değerleri

| Sınıf | Min | Max | Ort |
|-------|-----|-----|-----|
| 9 | 580 | 810 | 677 |
| 10 | 880 | 1180 | 1013 |
| 11 | 1980 | 2750 | 2405 |
| 12 | 2900 | 3600 | 3200 |

---

## 🔍 Doğrulama Kuralları

### ✅ Geçerli Model
```dart
final valid = CarbonFootprintData(
  id: '9A',
  classLevel: 9,
  classSection: 'A',
  classOrientation: ClassOrientation.south,
  hasPlants: true,  // 9. sınıf için OK
  carbonValue: 620, // 400-4000 aralığında OK
);
valid.isValid() // true
```

### ❌ Geçersiz Model
```dart
final invalid = CarbonFootprintData(
  id: '11A',
  classLevel: 11,
  classSection: 'A',
  classOrientation: ClassOrientation.north,
  hasPlants: true,  // 11. sınıfta invalid
  carbonValue: 2100,
);
invalid.isValid() // false
```

---

## 🎨 UI Entegrasyonu

### Register Sayfasına Ekle
```dart
CarbonClassSelectionWidget(
  onClassSelected: (classInfo) {
    setState(() {
      classLevel = classInfo.classLevel;
      classSection = classInfo.classSection;
    });
  },
  isRequired: true,
)
```

### Home Dashboard'a Link
```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonFootprintPage(
          userData: userData,
        ),
      ),
    );
  },
  child: const Text('Karbon Ayak İzi'),
)
```

### Profile'da Göster
```dart
Text(userData.getClassDisplayName())
// Output: "Dokuzuncu Sınıf A Şubesi"
```

---

## 🧪 Testler

### Çalıştırmak
```bash
flutter test lib/tests/carbon_footprint_data_test.dart
```

### Test Türleri
- ✅ Model oluşturma
- ✅ Doğrulama kuralları
- ✅ Firestore serileştirme
- ✅ İstatistik hesaplamaları
- ✅ Sınıf kuralları

---

## 🚀 Firebase İşlemleri

### Seed Data Yükleme
```dart
final service = CarbonFootprintService();
await service.initializeSeedData();
```

### Veri Güncelleme
```dart
await service.updateCarbonData(
  '9A',
  {
    'carbonValue': 650,
    'measuredAt': DateTime.now().toIso8601String(),
  },
);
```

### Veri Silme
```dart
await service.deleteCarbonData('9A');
```

---

## 📱 Enum Değerleri

### ClassOrientation
```dart
ClassOrientation.north    // Kuzey (daha yüksek karbon)
ClassOrientation.south    // Güney (daha düşük karbon)
```

### Sınıf Şubeleri
```
9. Sınıf: ['A', 'B', 'C', 'D']
10-12. Sınıf: ['A', 'B', 'C', 'D', 'E', 'F']
```

---

## 💡 İpuçları

### 1. Performans
```dart
// ✅ İyi
final stats = await carbonService.getCarbonStatistics();

// ❌ Kötü - Ayrı ayrı sorgu
for (int i = 0; i < 22; i++) {
  await carbonService.getCarbonDataByClass(9, 'A');
}
```

### 2. Cache Kullanımı
```dart
// Memoization örneği
Map<String, CarbonStatistics> _statsCache = {};

Future<CarbonStatistics> getStatistics() async {
  final service = CarbonFootprintService();
  if (!_statsCache.containsKey('all')) {
    _statsCache['all'] = await service.getCarbonStatistics();
  }
  return _statsCache['all']!;
}
```

### 3. Error Handling
```dart
try {
  final data = await carbonService.getCarbonDataByClass(9, 'A');
} on Exception catch (e) {
  print('Hata: $e');
  // Fallback: seed data kullan
}
```

---

## 🔧 Debugging

### Loglama Ekle
```dart
import 'package:firebase_core/firebase_core.dart';

FirebaseCore.debugLoggingEnabled = true;
```

### Console Kontrol
```dart
print('DEBUG: ${userData.getClassIdentifier()}');
print('DEBUG: Karbon değeri = ${carbonData.carbonValue}');
```

### Firebase Kontrol
1. Firebase Console açın
2. Firestore → carbon_footprints koleksiyonu
3. Verileri inceyin

---

## 📦 Dependencies

```yaml
# Zaten yüklü
cloud_firestore: ^5.6.12
provider: ^6.1.2
intl: ^0.20.2

# Phase 2 (rapor oluşturma)
pdf: ^3.10.0
fl_chart: ^0.62.0
excel: ^2.1.0
```

---

## 📋 Checklist

Yeni bir özellik eklerken:
- [ ] Model oluşturdunuz mu?
- [ ] Doğrulama kuralları eklediniz mi?
- [ ] Firestore operasyonu yazdınız mı?
- [ ] Test yazıp çalıştırdınız mı?
- [ ] Hata yönetimi eklediniz mi?
- [ ] Documentation güncellediniz mi?

---

## 🆘 Yaygın Hatalar

### Hata 1: "Invalid class section"
```
Neden: Sınıf kurallarına uymayan şube
Çözüm: 9. sınıf = A-D, 10-12 = A-F
```

### Hata 2: "Plants in grade 11"
```
Neden: Üst sınıflarda hasPlants = true
Çözüm: Sadece 9-10. sınıflara bitkiler
```

### Hata 3: "Carbon value out of range"
```
Neden: 400-4000 aralığı dışı değer
Çözüm: Karbon değeri 400-4000 arasında olmalı
```

### Hata 4: "Firebase permission denied"
```
Neden: Firestore rules eksik/yanlış
Çözüm: Firestore security rules güncellenmiş mi?
```

---

## 🎓 Öğrenme Kaynakları

1. **CARBON_FOOTPRINT_IMPLEMENTATION_GUIDE.md**
   - Detaylı sistem açıklaması

2. **CARBON_FOOTPRINT_INTEGRATION_GUIDE.md**
   - Entegrasyon örnekleri

3. **carbon_footprint_data_test.dart**
   - Test örnekleri

4. **Service dosyaları**
   - Detaylı comments ve örnekler

---

## 🌟 Best Practices

```dart
// ✅ İyi
final service = CarbonFootprintService();
final data = await service.getCarbonDataByClass(
  userData.classLevel!,
  userData.classSection!,
);

// ❌ Kötü
final data = await CarbonFootprintService()
    .getCarbonDataByClass(9, 'A');
// Her çağrıda yeni instance oluşturuluyor

// ✅ İyi - User ekstansiyonu kullan
if (userData.hasValidClassSelection()) {
  // Sınıf seçimi var
}

// ❌ Kötü - Manuel kontrol
if (userData.classLevel != null && 
    userData.classSection != null) {
  // Sınıf seçimi var
}
```

---

## 📞 Hızlı İletişim

**Sorun mu var?**
1. Bu kılavuzu kontrol et
2. Test dosyalarını incele
3. Firebase console'u kontrol et
4. Logs'u kontrol et

**Ekleme mi yapacaksın?**
1. Dokümantasyonu oku
2. Model tasarla
3. Test yaz
4. Uygula
5. Dokümantasyonu güncelle

---

**Versiyon:** 1.0.0 | **Güncelleme:** 2026 | **Durum:** ✅ Production Ready
