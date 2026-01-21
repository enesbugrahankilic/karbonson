# Karbon Ayak İzi Sistemi - Entegrasyon Rehberi

## 📌 Hızlı Başlangıç

### 1. Ana Ekrana Carbon Linkini Ekle

`lib/pages/home_dashboard.dart` veya `lib/pages/home_dashboard_optimized.dart` içinde:

```dart
import 'package:karbonson/pages/carbon_footprint_page.dart';

// Navigation button
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarbonFootprintPage(
          userData: userData, // Mevcut kullanıcı verisi
        ),
      ),
    );
  },
  child: const Text('Karbon Ayak İzi'),
)
```

### 2. Kayıt Sayfasına Sınıf Seçimi Ekle

`lib/pages/register_page.dart` veya `lib/pages/register_page_refactored.dart` içinde:

```dart
import 'package:karbonson/widgets/carbon_class_selection_widget.dart';

// Form içinde
CarbonClassSelectionWidget(
  onClassSelected: (classInfo) {
    setState(() {
      selectedClassLevel = classInfo.classLevel;
      selectedClassSection = classInfo.classSection;
    });
  },
  isRequired: true,
  helperText: 'Sınıf bilgisi karbon raporlarında kullanılacaktır',
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

### 3. Profil Sayfasında Sınıf Bilgisi Göster

`lib/pages/profile_page.dart` içinde:

```dart
import 'package:karbonson/extensions/user_data_carbon_extension.dart';

// Profil bilgilerinde ekle
ListTile(
  leading: const Icon(Icons.school),
  title: const Text('Sınıf'),
  subtitle: Text(userData.getClassDisplayName()),
  onTap: () {
    // Edit dialog aç
  },
)
```

### 4. Firebase Seed Data İnitialize Et

`lib/services/app_initialization_service.dart` veya `main.dart` içinde:

```dart
import 'package:karbonson/services/carbon_footprint_service.dart';

// App başlangıcında (bir kez)
Future<void> initializeApp() async {
  final carbonService = CarbonFootprintService();
  
  // Seed data'yı yükle (ilk kurulumda)
  try {
    await carbonService.initializeSeedData();
    print('Carbon seed data initialized');
  } catch (e) {
    print('Error initializing carbon seed data: $e');
  }
  
  // ... diğer initialization işlemleri
}
```

### 5. AI Recommendation'ları Göster

`lib/pages/ai_recommendations_page.dart` veya yeni bir widget içinde:

```dart
import 'package:karbonson/services/carbon_ai_recommendation_service.dart';
import 'package:karbonson/services/carbon_footprint_service.dart';

Future<void> showCarbonRecommendations(UserData userData) async {
  if (!userData.hasValidClassSelection()) {
    print('User has no valid class selection');
    return;
  }

  final carbonService = CarbonFootprintService();
  final aiService = CarbonAIRecommendationService();

  // Karbon verileri al
  final carbonData = await carbonService.getCarbonDataByClass(
    userData.classLevel!,
    userData.classSection!,
  );

  final average = await carbonService.getAverageCarbonForClassLevel(
    userData.classLevel!,
  );

  // AI önerileri oluştur
  final recommendations = await aiService.generateCarbonRecommendations(
    carbonData: carbonData!,
    userData: userData,
    averageCarbon: average,
  );

  // Gösterim
  for (final recommendation in recommendations) {
    print(recommendation);
  }
}
```

---

## 🔌 Existing Services ile Entegrasyon

### AIService ile Entegrasyon

`lib/services/ai_service.dart` içinde karbon verilerini kullan:

```dart
Future<Map<String, dynamic>> getPersonalizedQuizRecommendations(
  String userId, 
  int? classLevel,  // Zaten var!
) async {
  // Karbon verilerini de dahil et
  final carbonService = CarbonFootprintService();
  
  if (classLevel != null) {
    final carbonData = await carbonService
        .getCarbonDataByClassLevel(classLevel);
    // Recommendations'a karbon verisi ekle
  }
  
  // ... rest of implementation
}
```

### Reward Service ile Bağlantı

`lib/services/reward_service.dart` içinde:

```dart
// Karbon raporu indirildiğinde ödül ver
Future<void> rewardCarbonReportDownload(String userId) async {
  final reward = RewardItem(
    id: 'carbon_report_download',
    points: 25,
    description: 'Karbon raporu indirildi',
  );
  
  await addReward(userId, reward);
}
```

### Daily Task Service ile Entegrasyon

`lib/services/daily_task_event_service.dart` içinde:

```dart
import 'package:karbonson/services/carbon_ai_recommendation_service.dart';

Future<void> generateDailyTasksWithCarbon(
  String userId, 
  UserData userData,
) async {
  if (userData.hasValidClassSelection()) {
    final carbonService = CarbonFootprintService();
    final aiService = CarbonAIRecommendationService();
    
    final carbonData = await carbonService.getCarbonDataByClass(
      userData.classLevel!,
      userData.classSection!,
    );
    
    // Karbon bazlı görevler oluştur
    final tasks = await aiService.generateCarbonMicroTasks(
      carbonData: carbonData!,
      userData: userData,
    );
    
    // Görevleri daily tasks'a ekle
    for (final task in tasks) {
      await addDailyTask(userId, task);
    }
  }
}
```

### Leaderboard Service ile Entegrasyon

`lib/pages/leaderboard_page.dart` içinde:

```dart
// Çevreci Sınıf kategorisini ekle
class LeaderboardCategory {
  static const String normal = 'overall';
  static const String ecoFriendly = 'eco_friendly'; // YENİ
  
  // ... existing categories
}

// Çevreci sınıflar için sıralamayı hesapla
Future<List<UserData>> getEcoFriendlyLeaderboard() async {
  final carbonService = CarbonFootprintService();
  final allUsers = await getAllUsers();
  
  final ecoRanked = <UserData>[];
  
  for (final user in allUsers) {
    if (user.hasValidClassSelection()) {
      final carbonData = await carbonService.getCarbonDataByClass(
        user.classLevel!,
        user.classSection!,
      );
      
      if (carbonData != null && carbonData.carbonValue < 1500) {
        ecoRanked.add(user);
      }
    }
  }
  
  // Karbon değerine göre sırala (düşük daha iyi)
  ecoRanked.sort((a, b) {
    // ... sorting logic
  });
  
  return ecoRanked;
}
```

---

## 🎨 UI Customization

### Theme Entegrasyonu

`lib/theme/` veya `lib/themes/` dosyaları içinde:

```dart
// Carbon ekranı için renkler
const carbonPrimaryColor = Color(0xFF2E7D32);    // Koyu yeşil
const carbonAccentColor = Color(0xFF81C784);     // Açık yeşil
const carbonBackgroundColor = Color(0xFFF1F8E9); // Çok açık yeşil

// Existing theme'e ekle
final carbonTheme = ThemeData(
  primaryColor: carbonPrimaryColor,
  chipTheme: ChipThemeData(
    backgroundColor: carbonBackgroundColor,
  ),
);
```

### Localization Entegrasyonu

`lib/l10n/` dosyaları içinde:

```yaml
# arb dosyalarına ekle
{
  "carbonFootprint": "Karbon Ayak İzi",
  "carbonValue": "Karbon Değeri",
  "classLevel": "Sınıf Düzeyi",
  "classSection": "Şube",
  "ecoFriendly": "Çevreci",
  "downloadReport": "Rapor İndir"
}
```

---

## 🔄 Data Flow Diyagramı

```
┌─────────────┐
│   Kullanıcı │
└──────┬──────┘
       │
       ├─► Login/Register
       │      │
       │      └─► Sınıf Seçimi (CarbonClassSelectionWidget)
       │           │
       │           └─► UserData'ya Kaydet
       │
       ├─► Home Dashboard
       │      │
       │      └─► "Karbon Ayak İzi" Butonu
       │           │
       │           ├─► CarbonFootprintPage
       │           │      │
       │           │      ├─► CarbonFootprintService
       │           │      │      │
       │           │      │      └─► Firebase (carbon_footprints)
       │           │      │
       │           │      ├─► CarbonReportService
       │           │      │
       │           │      └─► CarbonAIRecommendationService
       │           │
       │           └─► Report Oluştur & İndir
       │
       └─► Daily Tasks & Rewards
              │
              └─► Carbon-based Tasks
```

---

## 📦 Gerekli Paketler

Mevcut `pubspec.yaml` dosyasına aşağıdaki paketleri ekle (zaten varsa kontrol et):

```yaml
dependencies:
  # Mevcut paketler
  flutter:
    sdk: flutter
  firebase_core: ^3.15.2
  cloud_firestore: ^5.6.12
  
  # Rapor oluşturma için (isteğe bağlı - Phase 2)
  pdf: ^3.10.0              # PDF raporu oluşturma
  image: ^4.1.7             # Image işlemleri (zaten var)
  fl_chart: ^0.62.0         # Grafik gösterimi
  excel: ^2.1.0             # Excel dosyası oluşturma
  
  # Paylaşım için (isteğe bağlı)
  share_plus: ^10.1.0       # (zaten var)
```

---

## 🧪 Testing

### Widget Test Örneği

```dart
// test/carbon_class_selection_widget_test.dart
void main() {
  testWidgets('CarbonClassSelectionWidget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CarbonClassSelectionWidget(
            onClassSelected: (_) {},
            isRequired: true,
          ),
        ),
      ),
    );

    expect(find.text('Sınıf Seviyesi'), findsOneWidget);
    expect(find.text('Şube'), findsNothing); // İlk başta görünmez
  });
}
```

### Integration Test Örneği

```dart
// test_driver/carbon_flow_test.dart
void main() {
  group('Carbon Footprint Flow', () {
    setUpAll(() async {
      // Setup
    });

    test('User can select class and view carbon data', () async {
      // Test steps
    });
  });
}
```

---

## 🚀 Deployment Checklist

- [ ] `carbon_footprint_data.dart` models içinde
- [ ] `carbon_footprint_service.dart` services içinde
- [ ] `carbon_report_service.dart` services içinde
- [ ] `carbon_ai_recommendation_service.dart` services içinde
- [ ] `carbon_footprint_page.dart` pages içinde
- [ ] `carbon_class_selection_widget.dart` widgets içinde
- [ ] `user_data_carbon_extension.dart` extensions içinde
- [ ] `carbon_footprint_data_test.dart` tests içinde
- [ ] UserData modeline `classLevel` ve `classSection` alanları eklendi
- [ ] Register sayfasında sınıf seçimi eklendi
- [ ] Home dashboard'a Carbon Ayak İzi linki eklendi
- [ ] Profile sayfasında sınıf bilgisi gösteriliyor
- [ ] Firebase seed data initialize ediliyor
- [ ] Tests çalışıyor: `flutter test`
- [ ] Lint hatası yok: `flutter analyze`

---

## 🐛 Hata Ayıklama

### Debug Mode'da Seed Data Yükle

```dart
// main.dart veya initializeApp() içinde
if (kDebugMode) {
  final carbonService = CarbonFootprintService();
  await carbonService.initializeSeedData();
  print('DEBUG: Carbon seed data loaded');
}
```

### Firebase Rules

```json
{
  "rules": {
    "carbon_footprints": {
      ".read": true,
      ".write": false  // Sadece backend
    }
  }
}
```

### Logging

```dart
import 'package:firebase_core/firebase_core.dart';

// Enable logging
FirebaseCore.debugLoggingEnabled = true;
```

---

## 📞 Support

Sorularınız için:
1. `CARBON_FOOTPRINT_IMPLEMENTATION_GUIDE.md` dökümentasyonunu kontrol edin
2. Test dosyalarını inceleyip referans alın
3. Firebase Firestore console'dan verileri kontrol edin

---

**Versiyon:** 1.0.0  
**Durum:** ✅ Production Ready  
**Son Update:** 2026
