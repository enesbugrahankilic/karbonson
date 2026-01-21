# ✅ Karbon Ayak İzi Sistemi - Uygulama Yapılacaklar & Checklist

## 🎯 Phase 1: Temel Sistem (✅ TAMAMLANDI)

### ✅ Veri Modelleri
- [x] **CarbonFootprintData model oluştur**
  - Alanlar: id, classLevel, classSection, orientation, hasPlants, carbonValue
  - Doğrulama: isValid(), isValidClassSection(), isValidCarbonValue(), isValidPlantStatus()
  - Serialization: toFirestore(), fromFirestore(), toMap(), fromMap()

- [x] **Enums tanımla**
  - ClassLevel (9, 10, 11, 12)
  - ClassSection (A-F)
  - ClassOrientation (north, south)

- [x] **CarbonReport model oluştur**
  - carbonData, percentage, averageCarbon, isAboveAverage

- [x] **CarbonStatistics model oluştur**
  - fromList(), totalCarbon, averageCarbon, maxCarbon, minCarbon

### ✅ Services
- [x] **CarbonFootprintService**
  - getCarbonDataByClass()
  - getAllCarbonData()
  - getCarbonDataByClassLevel()
  - getCarbonDataByPlantStatus()
  - getCarbonDataByOrientation()
  - getAverageCarbonForClassLevel()
  - getCarbonStatistics()
  - setCarbonData()
  - updateCarbonData()
  - deleteCarbonData()
  - streamCarbonData()
  - streamAllCarbonData()
  - initializeSeedData()

- [x] **CarbonReportService**
  - generatePNGReport()
  - generatePDFReport()
  - generateExcelReport()
  - generateBulkExcelReport()
  - getReportFilename()
  - createReportDisplayData()
  - prepareReportForSharing()
  - getReportComparison()
  - Durum emoji'leri ve önerileri

- [x] **CarbonAIRecommendationService**
  - generateCarbonRecommendations()
  - generateCarbonMicroTasks()
  - getClassComparisonInsights()
  - getCarbonAchievementSuggestions()
  - getSchoolCarbonContext()
  - formatRecommendationsForDisplay()

### ✅ UI Components
- [x] **CarbonFootprintPage (Ana Ekran)**
  - TabBarView ile 3 sekme
  - Özet sekmesi: Sınıf bilgisi, Karbon değeri, Karşılaştırma, Durum göstergeleri
  - Detaylar sekmesi: Sınıf dağılımı, Veri tablosu
  - Rapor sekmesi: İndirme, Paylaşım, Rapor özeti
  - Yükleme durumu, Hata yönetimi, Boş durum

- [x] **CarbonClassSelectionWidget**
  - Sınıf seviyesi dropdown
  - Şube dropdown (dinamik)
  - Doğrulama
  - İnfo kartı
  - Public methods

### ✅ Extensions
- [x] **UserDataCarbonExtension**
  - hasValidClassSelection()
  - getValidSections()
  - getClassIdentifier()
  - classLevelAllowsPlants()
  - getClassDisplayName()

### ✅ Tests
- [x] **Carbon Footprint Data Tests (30+ test)**
  - Model oluşturma testleri
  - Doğrulama testleri
  - Sınıf kuralı testleri
  - Firestore testleri
  - İstatistik testleri
  - Equality testleri

### ✅ Documentation
- [x] CARBON_SYSTEM_README.md
- [x] CARBON_FOOTPRINT_IMPLEMENTATION_GUIDE.md
- [x] CARBON_FOOTPRINT_INTEGRATION_GUIDE.md
- [x] CARBON_QUICKREF.md
- [x] CARBON_FOOTPRINT_SUMMARY.md
- [x] CARBON_FILES_INDEX.md

---

## 🔧 Phase 1.5: Entegrasyon (⏳ HAZIR)

### 🟢 Yapılacaklar (Bu Aşamada)

#### Adım 1: UserData Modeline Ekleme
```dart
// lib/models/user_data.dart
// Aşağıdaki alanları ekle:

class UserData {
  // ... existing fields ...
  
  // Class and Section Information
  final int? classLevel;           // 9, 10, 11, 12
  final String? classSection;      // A, B, C, D, E, F
  
  const UserData({
    // ... existing params ...
    this.classLevel,
    this.classSection,
  });
}
```

**Checklist:**
- [ ] classLevel alanı ekle
- [ ] classSection alanı ekle
- [ ] toMap() metodunu güncelle
- [ ] fromMap() metodunu güncelle
- [ ] copyWith() metodunu güncelle
- [ ] Dokümantasyon güncelle

#### Adım 2: Register Sayfasına Entegrasyon
```dart
// lib/pages/register_page.dart veya register_page_refactored.dart
// CarbonClassSelectionWidget ekle

import 'package:karbonson/widgets/carbon_class_selection_widget.dart';

// Form içinde
CarbonClassSelectionWidget(
  onClassSelected: (classInfo) {
    // Seçilen sınıf bilgisini sakla
    selectedClassLevel = classInfo.classLevel;
    selectedClassSection = classInfo.classSection;
  },
  isRequired: true,
)

// Kayıt sırasında UserData'ya ekle
final userData = UserData(
  uid: firebaseUser.uid,
  nickname: nicknameController.text,
  classLevel: selectedClassLevel,      // ← YENİ
  classSection: selectedClassSection,  // ← YENİ
  // ... diğer alanlar
);
```

**Checklist:**
- [ ] Import ekle
- [ ] Widget'ı form içine ekle
- [ ] State'da classLevel ve classSection değişkenleri oluştur
- [ ] onClassSelected callback'i yaz
- [ ] userData oluştururken yeni alanları ekle
- [ ] Doğrulama kurallarını kontrol et

#### Adım 3: Home Dashboard'a Link Ekle
```dart
// lib/pages/home_dashboard.dart veya optimized version
// Carbon sayfasına link ekle

import 'package:karbonson/pages/carbon_footprint_page.dart';

// Navigation widget'ında
ListTile(
  leading: const Icon(Icons.eco),
  title: const Text('Karbon Ayak İzi'),
  subtitle: const Text('Sınıfınızın karbon ölçümü'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonFootprintPage(
          userData: userData,
        ),
      ),
    );
  },
)
```

**Checklist:**
- [ ] Import ekle
- [ ] Navigation widget'ı ekle
- [ ] Tıklama fonksiyonunu yaz
- [ ] userData parametresi geç

#### Adım 4: Profile Sayfasında Sınıf Bilgisi Göster
```dart
// lib/pages/profile_page.dart
// Sınıf bilgisini profil sayfasında göster

import 'package:karbonson/extensions/user_data_carbon_extension.dart';

// Profil bilgilerinde
ListTile(
  leading: const Icon(Icons.school),
  title: const Text('Sınıf'),
  subtitle: Text(userData.getClassDisplayName()),
  trailing: const Icon(Icons.edit),
  onTap: () {
    // Sınıf bilgisini düzenle (opsiyonel)
  },
)
```

**Checklist:**
- [ ] Import ekle
- [ ] ListTile ekle
- [ ] getClassDisplayName() kullan
- [ ] Düzenleme seçeneği ekle (isteğe bağlı)

#### Adım 5: Firebase Seed Data İnitialize Et
```dart
// lib/services/app_initialization_service.dart veya main.dart
// Seed data'yı yükle

import 'package:karbonson/services/carbon_footprint_service.dart';

Future<void> initializeApp() async {
  // ... diğer initialization işlemleri ...
  
  final carbonService = CarbonFootprintService();
  
  try {
    // Seed data'yı bir kez yükle
    await carbonService.initializeSeedData();
    print('✅ Carbon seed data initialized');
  } catch (e) {
    print('⚠️ Error initializing carbon seed data: $e');
    // Hata olsa da devam et (fallback var)
  }
}
```

**Checklist:**
- [ ] Service oluştur
- [ ] initializeSeedData() çağrı
- [ ] Error handling ekle
- [ ] Logging ekle

#### Adım 6: Existing Services ile Entegrasyon

**AIService Güncellemesi:**
```dart
// lib/services/ai_service.dart
Future<Map<String, dynamic>> getPersonalizedQuizRecommendations(
  String userId, 
  int? classLevel, // Zaten var, karbon da buna bakacak
) async {
  // classLevel'ı kullanarak karbon verilerini de getir
  // AI recommendations'a karbon verisi ekle
}
```

**DailyTaskService Güncellemesi:**
```dart
// lib/services/daily_task_event_service.dart
Future<void> generateDailyTasksWithCarbon(
  String userId,
  UserData userData,
) async {
  if (userData.hasValidClassSelection()) {
    // Karbon bazlı görevler oluştur
    final aiService = CarbonAIRecommendationService();
    final tasks = await aiService.generateCarbonMicroTasks(
      carbonData: carbonData,
      userData: userData,
    );
  }
}
```

**Checklist:**
- [ ] AIService'de classLevel kullanım kontrol et
- [ ] DailyTaskService'de karbon görevlerini entegre et
- [ ] RewardService'de karbon ödüllerini ekle
- [ ] LeaderboardService'de çevreci kategorisini ekle

---

## 🚀 Phase 2: Rapor Oluşturma (⏳ SONRAKI)

### Yapılacaklar
- [ ] PDF rapor oluşturma (pdf paketi)
- [ ] PNG rapor oluşturma (fl_chart)
- [ ] Excel dosya oluşturma (excel paketi)
- [ ] Rapor paylaşım (share_plus)
- [ ] Dosya indirme (file_picker)

### Checklist
- [ ] Paketleri pubspec.yaml'a ekle
- [ ] PDF oluşturma kodunu yaz
- [ ] PNG render'lama kodunu yaz
- [ ] Excel yazıcı kodunu yaz
- [ ] İndirme fonksiyonunu yaz
- [ ] Paylaşım fonksiyonunu yaz
- [ ] Tests yaz

---

## 🏆 Phase 3: İleri Özellikler (⏳ SONRAKI)

### Yapılacaklar
- [ ] Tarihsel karbon verileri
- [ ] Sınıflar arası çevreci yarış
- [ ] Karbon ödül sistemi (loot box entegrasyonu)
- [ ] Öğretmen paneli
- [ ] Analytics dashboard

---

## 📋 Deployment Checklist

### Kod Entegrasyonu
- [ ] Tüm dosyalar doğru klasörlere yerleştirildi
- [ ] İmports kontrol edildi
- [ ] Syntax hatası yok
- [ ] Flutter analyze pass etmek
- [ ] Build başarılı oldu

### Konfigürasyon
- [ ] pubspec.yaml güncellendi
- [ ] Firebase rules güncellendi
- [ ] Environment variables ayarlandı

### Testing
- [ ] Unit testler pass ediyor
- [ ] Widget testler pass ediyor (opsiyonel)
- [ ] Manual testing tamamlandı
- [ ] Integration test pass ediyor (opsiyonel)

### Dokümantasyon
- [ ] API dokümantasyonu güncellendi
- [ ] README güncelleştirildi
- [ ] Code comments eklendi
- [ ] Changelog güncellendi

### Backend
- [ ] Firebase Firestore collections oluşturuldu
- [ ] Security rules ayarlandı
- [ ] Seed data yüklendi
- [ ] Backup yapıldı

### DevOps
- [ ] Staging'de test edildi
- [ ] Production öncesi review yapıldı
- [ ] Deployment planlandı
- [ ] Rollback stratejisi belirlendi

---

## 📊 İlerleme Özeti

```
Phase 1: Temel Sistem
████████████████████████████████ 100% ✅

Phase 1.5: Entegrasyon
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0% (Hazır)

Phase 2: Rapor Oluşturma
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0% (Planlı)

Phase 3: İleri Özellikler
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0% (Planlı)
```

---

## 🎯 Hedefler

### ✅ Tamamlandı
- [x] Sistem tasarımı
- [x] Model geliştirme
- [x] Service implementasyonu
- [x] UI/UX geliştirme
- [x] Test yazma
- [x] Dokümantasyon

### 🔄 Devam Ediyor
- [ ] Entegrasyon çalışmaları
- [ ] Deployment hazırlığı

### 📅 Yakında
- [ ] Rapor oluşturma
- [ ] Advanced features

---

## 🆘 Yardım ve Destek

**Soru?** → CARBON_QUICKREF.md
**Hatanız?** → CARBON_FOOTPRINT_INTEGRATION_GUIDE.md
**API?** → CARBON_FOOTPRINT_IMPLEMENTATION_GUIDE.md
**Genel?** → CARBON_SYSTEM_README.md

---

**Status:** Phase 1 ✅ Complete | Phase 1.5 ⏳ Ready
**Last Update:** 2026
**Maintained By:** Karbonson Development Team
