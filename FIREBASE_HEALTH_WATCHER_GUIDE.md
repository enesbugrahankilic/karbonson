# Firebase Health Check & Watcher Mode Sistemi

## 📋 Genel Bakış

KarbonSon uygulamasına kapsamlı Firebase sağlık kontrolü ve gelişmiş izleyici modu eklenmiştir.

## 🏥 Firebase Health Check Service

### Özellikleri

1. **Otomatik Sağlık Kontrolü**
   - Firebase Core başlatma durumu
   - Authentication servisi kullanılabilirliği
   - Firestore bağlantı testi
   - Data sync durumu
   - User data erişilebilirliği
   - Performance metrikler

2. **Sağlık Durumları**
   - `healthy` - Tüm sistemler çalışıyor
   - `degraded` - Bazı sorunlar var ama uygulama çalışabiliyor
   - `unhealthy` - Ciddi sorunlar var
   - `offline` - Bağlantı yok
   - `unknown` - Durum belirlenemedi

3. **Fonksiyonlar**

```dart
// Sağlık kontrolü yap
FirebaseHealthCheckService healthCheck = FirebaseHealthCheckService();
final report = await healthCheck.performHealthCheck();

// Raporun özellikleri
report.status                // Sağlık durumu
report.responseTime          // Yanıt süresi
report.issues               // Bulunun sorunlar
report.recommendations      // Öneriler
report.details              // Detaylı bilgiler

// İzlemeyi başlat
await healthCheck.startMonitoring(
  checkInterval: Duration(minutes: 5)
);

// Otomatik kurtarma dene
bool success = await healthCheck.attemptRecovery();

// Hata ayıklama bilgisi al
Map<String, dynamic> debugInfo = await healthCheck.getDebugInfo();
```

### Health Check Parametreleri

```dart
{
  'firebase_core': {
    'initialized': true,
    'app_count': 1,
  },
  'authentication': {
    'available': true,
    'authenticated': false,
    'user_id': null,
  },
  'firestore': {
    'connected': true,
    'latency_ms': 245,
  },
  'data_sync': {
    'syncing': true,
  },
  'user_data': {
    'accessible': true,
    'has_profile': false,
  },
  'performance': {
    'response_healthy': true,
    'response_time_ms': 450,
  }
}
```

## 👁️ Watcher Mode Service (İzleyici Modu)

### Özellikleri

1. **Event Tracking**
   - Firebase olayları
   - UI navigasyon
   - Kullanıcı etkileşimleri
   - Performance sorunları
   - Hatalar

2. **Session Management**
   - Session oluşturma/bitiş
   - Event tamponu (max 1000 olay)
   - Session tarihi

3. **İstatistikler**
   - Event tipine göre sayım
   - Kategori bazlı sayım
   - Operasyon süresi ortalaması
   - Maksimum operasyon süresi

### Kullanım

```dart
final watcher = WatcherModeService();

// Modu aç
await watcher.enable(sessionName: 'my_session');

// Özel event izle
watcher.trackEvent(
  WatcherEventType.custom,
  'Kullanıcı giriş yaptı',
  metadata: {'user_id': '123'},
  category: 'auth',
);

// Firebase olayını izle
watcher.trackFirebaseEvent('user_login', data: {
  'method': 'email',
  'timestamp': DateTime.now().toIso8601String(),
});

// Navigasyonu izle
watcher.trackNavigation('LoginPage', 'HomePage');

// Kullanıcı etkileşimi
watcher.trackUserInteraction('button_clicked', details: {
  'button_id': 'login_btn'
});

// Performance sorunu
watcher.trackPerformanceIssue('Slow query', 2500);

// Hata izle
watcher.trackError(
  'Firebase error',
  stackTrace: stackTrace,
  context: {'operation': 'user_fetch'}
);

// İstatistikleri al
Map<String, dynamic> stats = watcher.getStatistics();

// Session olaylarını fil
List<WatcherEvent> events = watcher.getCurrentSessionEvents(
  filterByCategory: 'firebase',
);

// Modu kapat
await watcher.disable();

// Rapor oluştur
Map<String, dynamic> report = await watcher.generateDetailedReport();
```

### Event Tipleri

```dart
enum WatcherEventType {
  // Firebase events
  firebaseConnect,
  firebaseDisconnect,
  authStateChange,
  dataFetched,
  dataSaved,
  
  // UI events
  navigationChange,
  userInteraction,
  formSubmit,
  
  // Performance events
  performanceIssue,
  slowOperation,
  
  // Error events
  error,
  warning,
  
  // Custom events
  custom,
}
```

## 🔧 Firebase Debug Page

Debug sayfasında tüm modları test edebilirsiniz.

### Sekmeler

1. **Health Check Tab**
   - Sağlık kontrolü çalıştır
   - Status görüntüle
   - Sorunları ve önerileri gör
   - Detaylı bilgiler
   - Otomatik kurtarma dene

2. **Watcher Mode Tab**
   - İzleyici modunu aç/kapat
   - Session durumu
   - İstatistikleri görüntüle
   - Event sayımı

3. **Debug Info Tab**
   - Detaylı debug bilgileri
   - Firebase konfigürasyonu
   - Authentication durumu
   - Firestore bağlantısı
   - Performance metrikleri

### Debug Sayfasına Erişim

```dart
// App'te bir debug menu button'u oluşturun
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const FirebaseDebugPage()),
);
```

## 📊 Performance Tracker

```dart
final tracker = PerformanceTracker('my_operation');

tracker.start();

// İşlem yap
await mySlowOperation();

tracker.end(
  trackIfSlow: true,
  slowThresholdMs: 1000,
);

print('İşlem süresi: ${tracker.elapsedMs}ms');
```

## 🔍 İzleme Örnekleri

### Firebase Login Olayını İzle

```dart
final watcher = WatcherModeService();
await watcher.enable();

try {
  watcher.trackEvent(
    WatcherEventType.authStateChange,
    'User login started',
    category: 'authentication',
  );
  
  // Login işlemi
  await performLogin();
  
  watcher.trackEvent(
    WatcherEventType.authStateChange,
    'User login successful',
    category: 'authentication',
    metadata: {'method': 'email'},
  );
} catch (e) {
  watcher.trackError('Login failed: $e');
}
```

### Quiz Tamamlamayı İzle

```dart
watcher.trackEvent(
  WatcherEventType.custom,
  'Quiz completed',
  category: 'quiz',
  metadata: {
    'quiz_id': '123',
    'score': 85,
    'duration_ms': 45000,
  },
);
```

### Network Sorununu İzle

```dart
if (responseTime > 5000) {
  watcher.trackPerformanceIssue(
    'Firestore query taking too long',
    responseTime,
  );
}
```

## 📈 Sistem Mimarisi

```
┌─────────────────────────────────────────┐
│         Firebase Debug Page             │
│  ┌─────────┬──────────┬──────────────┐  │
│  │ Health  │ Watcher  │ Debug Info   │  │
│  │ Check   │  Mode    │              │  │
│  └────┬────┴────┬─────┴──────┬───────┘  │
└───────┼────────┼──────────┼───────────┘
        │        │          │
        ▼        ▼          ▼
  ┌──────────────────────────────────┐
  │  Firebase Health Check Service   │
  │  Watcher Mode Service            │
  │  Performance Tracker             │
  └──────────────────────────────────┘
        │        │          │
        ▼        ▼          ▼
  ┌──────────────────────────────────┐
  │  Firebase Core                   │
  │  Authentication                  │
  │  Firestore                       │
  │  Real-time Sync                  │
  └──────────────────────────────────┘
```

## ✅ Test Edilen Modlar

- ✅ Firebase Core başlatma
- ✅ Authentication servisi
- ✅ Firestore bağlantısı
- ✅ Data synchronization
- ✅ User data erişimi
- ✅ Performance metrikleri
- ✅ Event tracking
- ✅ Error logging
- ✅ Navigation tracking
- ✅ User interaction tracking

## 🚀 Entegrasyon Adımları

### 1. Import Ekleyin

```dart
import 'lib/services/firebase_health_check_service.dart';
import 'lib/services/watcher_mode_service.dart';
import 'lib/pages/firebase_debug_page.dart';
```

### 2. Health Check'i Başlatın

```dart
// main.dart veya app.dart içinde
final healthCheck = FirebaseHealthCheckService();
await healthCheck.startMonitoring(
  checkInterval: Duration(minutes: 5),
);
```

### 3. Watcher Mode'u Başlatın (Opsiyonel)

```dart
final watcher = WatcherModeService();

// Debug modunda aç
if (kDebugMode) {
  await watcher.enable(sessionName: 'app_session');
}
```

### 4. Debug Sayfasına Erişim Ekleyin

```dart
// Settings veya Debug menüsünde
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const FirebaseDebugPage()),
);
```

## 📝 Loglar ve Hata Ayıklama

### Konsol Çıktıları

```
👁️ Watcher Mode ENABLED - Session: session_1234567890
🏥 Starting Firebase health check...
✅ Health check completed: healthy
   Response time: 245ms
   Issues found: 0
📝 [firebaseConnect] Firebase connected at 2024-01-22T10:30:00.000Z
```

### Debug Mode

```dart
if (kDebugMode) {
  debugPrint('Health Report: ${await healthCheck.getDebugInfo()}');
  debugPrint('Watcher Stats: ${watcher.getStatistics()}');
}
```

## 🛠️ Troubleshooting

### Health Check Başarısız Olursa

1. Firebase Core başlatılmış mı kontrol edin
2. Internet bağlantısını kontrol edin
3. Firestore güvenlik kurallarını kontrol edin
4. Authentication settings'i Firebase Console'da kontrol edin

### Watcher Mode Etkinleştirilemezse

1. Başka bir session çalışıyor mu denetleyin
2. Watcher'ı disable edin ve tekrar aç
3. Session ID'nin unique olduğundan emin olun

## 📞 İletişim & Destek

Sorunlarla karşılaşırsanız:
1. Debug sayfasında Health Check çalıştırın
2. Hata mesajlarını not edin
3. Logs'u kontrol edin
4. Başlangıç modüllerini yeniden başlatmayı deneyin

---

**Durum:** ✅ Tamamlandı
**Son Güncelleme:** 2024-01-22
**Versiyon:** 1.0
