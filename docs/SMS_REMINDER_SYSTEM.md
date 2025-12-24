# SMS Reminder System Dokümantasyonu

## 📋 Genel Bakış

SMS Reminder sistemi, kullanıcıların günlük görevlerini takip etmelerine ve tamamlamalarına yardımcı olan kapsamlı bir SMS hatırlatma sistemidir. Twilio entegrasyonu ile Türkçe SMS mesajları göndererek kullanıcıları motive eder ve görev tamamlama oranlarını artırır.

## 🏗️ Sistem Mimarisi

### Temel Bileşenler

1. **SMS Reminder Service** (`lib/services/sms_reminder_service.dart`)
   - Ana iş mantığı ve SMS gönderimi
   - Kullanıcı tercihleri yönetimi
   - Görev takip ve seri hesaplama

2. **SMS Template Service** (`lib/services/sms_template_service.dart`)
   - Türkçe SMS şablonları
   - Dinamik mesaj oluşturma
   - Kategori bazlı özel mesajlar

3. **SMS Reminder Scheduler** (`lib/services/sms_reminder_scheduler.dart`)
   - Otomatik zamanlama mekanizması
   - Günlük, haftalık ve seri hatırlatmaları
   - Manuel hatırlatma tetikleme

4. **Veri Modelleri**
   - `TaskReminder` - Görev veri modeli
   - `UserPreferences` - Kullanıcı tercihleri
   - `WeeklyReport` - Haftalık rapor verisi

## 🚀 Kurulum ve Yapılandırma

### 1. Twilio Konfigürasyonu

`docs/TWILIO_SETUP.md` dosyasındaki talimatları takip ederek Twilio hesabınızı kurun:

```bash
# Environment Variables (macOS/Linux)
export TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export TWILIO_AUTH_TOKEN="your_auth_token_here"
export TWILIO_FROM_NUMBER="+1234567890"
```

### 2. Firestore Koleksiyonları

Sistem aşağıdaki koleksiyonları kullanır:

```javascript
// user_preferences - Kullanıcı tercihleri
{
  userId: "user123",
  smsNotificationsEnabled: true,
  dailyRemindersEnabled: true,
  weeklyReportsEnabled: true,
  streakRemindersEnabled: true,
  preferredReminderTime: "20:00",
  reminderCategories: ["exercise", "study"],
  snoozeDuration: 30,
  weekendReminders: false,
  missedTaskReminders: true,
  language: "tr"
}

// task_reminders - Görev verileri
{
  id: "task123",
  userId: "user123",
  title: "Egzersiz Yap",
  description: "30 dakika cardio",
  category: "exercise",
  scheduledTime: 1703123456789,
  status: "pending",
  reminderType: "daily",
  isRecurring: true,
  streakCount: 5,
  createdAt: 1703123456789
}

// sms_reminder_logs - Gönderim logları
{
  userId: "user123",
  phoneNumber: "+905551234567",
  taskId: "task123",
  reminderType: "daily",
  message: "🎯 Günlük hatırlatma:...",
  sentAt: 1703123456789,
  status: "sent"
}
```

## 📱 Kullanım Örnekleri

### 1. Günlük Hatırlatma Gönderme

```dart
import 'package:karbonson/services/sms_reminder_service.dart';

// Günlük hatırlatma gönder
final result = await SmsReminderService.sendDailyReminder(
  userId: 'user123',
  phoneNumber: '+905551234567',
);

if (result.isSuccess) {
  print('✅ ${result.message}');
} else {
  print('❌ ${result.message}');
}
```

### 2. Seri Hatırlatması

```dart
// Mevcut seri hatırlatması gönder
final result = await SmsReminderService.sendStreakReminder(
  userId: 'user123',
);

print('Seri: ${await SmsReminderService.getCurrentStreak('user123')} gün');
```

### 3. Haftalık Rapor

```dart
// Haftalık rapor oluştur ve gönder
final report = await SmsReminderService.generateWeeklyReport('user123');
print('Başarı oranı: %${report.completionRate.toStringAsFixed(0)}');

final result = await SmsReminderService.sendWeeklyReport(userId: 'user123');
```

### 4. Zamanlayıcıları Başlatma

```dart
import 'package:karbonson/services/sms_reminder_scheduler.dart';

// Uygulama başlatıldığında
void initializeSMSReminders() {
  // Günlük hatırlatmalar (20:00)
  SmsReminderScheduler.startDailyReminderScheduler();
  
  // Haftalık raporlar (Pazar 21:00)
  SmsReminderScheduler.startWeeklyReportScheduler();
  
  // Seri hatırlatmaları (09:00)
  SmsReminderScheduler.startStreakReminderScheduler();
}

// Uygulama kapatıldığında
void cleanupSMSReminders() {
  SmsReminderScheduler.stopAllSchedulers();
}
```

### 5. Manuel Hatırlatma

```dart
// Belirli bir kullanıcı için manuel hatırlatma
final result = await SmsReminderScheduler.sendManualReminder(
  userId: 'user123',
  reminderType: 'missed', // 'daily', 'missed', 'streak', 'weekly'
);

if (result.isSuccess) {
  print('Manuel hatırlatma gönderildi!');
}
```

## ⚙️ Kullanıcı Tercihleri

### Tercihleri Güncelleme

```dart
import 'package:karbonson/models/user_preferences.dart';

// Varsayılan tercihleri al
final preferences = await SmsReminderService.getUserPreferences('user123');

// Tercihleri güncelle
final updatedPreferences = preferences.copyWith(
  smsNotificationsEnabled: true,
  dailyRemindersEnabled: true,
  preferredReminderTime: TimeOfDay(hour: 20, minute: 0),
  weekendReminders: false,
);

// Firestore'a kaydet
await FirebaseFirestore.instance
    .collection('user_preferences')
    .doc('user123')
    .set(updatedPreferences.toMap());
```

### Desteklenen Tercihler

| Tercih | Açıklama | Varsayılan |
|--------|----------|------------|
| `smsNotificationsEnabled` | SMS bildirimlerini aç/kapat | `true` |
| `dailyRemindersEnabled` | Günlük hatırlatmaları aç/kapat | `true` |
| `weeklyReportsEnabled` | Haftalık raporları aç/kapat | `true` |
| `streakRemindersEnabled` | Seri hatırlatmalarını aç/kapat | `true` |
| `preferredReminderTime` | Tercih edilen hatırlatma saati | `20:00` |
| `weekendReminders` | Hafta sonu hatırlatmaları | `false` |
| `missedTaskReminders` | Kaçırılan görev hatırlatmaları | `true` |
| `snoozeDuration` | Erteleme süresi (dakika) | `30` |
| `language` | Mesaj dili | `'tr'` |

## 📊 SMS Şablonları

### Günlük Hatırlatma
```
🎯 Günlük hatırlatma: "Egzersiz Yap" görevin 20:00'da başlıyor! Hemen başla ve serini devam ettir. 💪
```

### Kaçırılan Görev
```
❌ Kaçırdığın görev: "Kitap Oku". Bugün yeni bir görev al ve tekrar başla! 🔄
```

### Seri Hatırlatması
```
🔥 Harika! 5 günlük serin var. Bir sonraki görevi tamamla ve serini uzat! 💪
```

### Haftalık Rapor
```
📊 Haftalık Raporun:
✅ Tamamlanan: 15/20
📈 Başarı oranı: %75
🔥 Mevcut seri: 8 gün
🏆 En uzun seri: 12 gün

Harika iş çıkarıyorsun! 💪
```

### Teşvik Mesajı
```
🎉 Tüm görevler tamamlandı! Sen harikasın! ✨
```

## 🕒 Zamanlama

### Otomatik Zamanlama

| Hatırlatma Türü | Varsayılan Zaman | Frekans |
|------------------|------------------|---------|
| Günlük Hatırlatma | 20:00 | Her gün |
| Seri Hatırlatması | 09:00 | Her gün |
| Haftalık Rapor | Pazar 21:00 | Haftalık |
| Kaçırılan Görev | Otomatik | İhtiyaç halinde |

### Özel Zamanlama

```dart
// Kullanıcı tercihine göre özel zamanlama
final preferences = await SmsReminderService.getUserPreferences('user123');
final customTime = preferences.preferredReminderTime;

// Bu zamanı kullanarak özel hatırlatma gönder
final customReminder = await SmsReminderService.sendDailyReminder(
  userId: 'user123',
  phoneNumber: '+905551234567',
);
```

## 🔧 Hata Ayıklama

### Debug Modu

```dart
// Debug modunda SMS'ler simüle edilir, gerçek Twilio çağrısı yapılmaz
const bool kDebugMode = true;

final result = await SmsReminderService.sendDailyReminder(
  userId: 'user123',
);

// Debug çıktısı:
// 📱 SMS Gönderildi: +905551234567
// 💬 Mesaj: 🎯 Günlük hatırlatma:...
```

### Log İzleme

```dart
// SMS gönderim loglarını kontrol et
final logs = await FirebaseFirestore.instance
    .collection('sms_reminder_logs')
    .where('userId', isEqualTo: 'user123')
    .orderBy('sentAt', descending: true)
    .limit(10)
    .get();

for (final doc in logs.docs) {
  final log = doc.data();
  print('${log['reminderType']}: ${log['status']} - ${log['sentAt']}');
}
```

### Zamanlayıcı Durumu

```dart
// Zamanlayıcıların çalışıp çalışmadığını kontrol et
final status = SmsReminderScheduler.getSchedulerStatus();
print('Günlük: ${status['daily']}');
print('Haftalık: ${status['weekly']}');
print('Seri: ${status['streak']}');
```

## 🚨 Hata Durumları

### Yaygın Hatalar ve Çözümleri

1. **Telefon Numarası Bulunamadı**
   ```dart
   // Çözüm: Kullanıcı profilinde telefon numarası olduğundan emin olun
   final phoneNumber = await SmsReminderService.getUserPhoneNumber('user123');
   if (phoneNumber == null) {
     print('Kullanıcı telefon numarası eksik!');
   }
   ```

2. **SMS Gönderilemedi**
   ```dart
   // Çözüm: Twilio konfigürasyonunu kontrol edin
   final result = await SmsReminderService.sendDailyReminder(userId: 'user123');
   if (!result.isSuccess) {
     print('Hata: ${result.message}');
     // Twilio loglarını kontrol edin
   }
   ```

3. **Kullanıcı Tercihleri Eksik**
   ```dart
   // Çözüm: Varsayılan tercihler otomatik oluşturulur
   final preferences = await SmsReminderService.getUserPreferences('user123');
   print('SMS Aktif: ${preferences.smsNotificationsEnabled}');
   ```

## 📈 Performans ve Optimizasyon

### Firestore Indexleri

Aşağıdaki indexleri oluşturun:

```javascript
// task_reminders collection
{
  fields: [
    {fieldPath: "userId", order: "ASCENDING"},
    {fieldPath: "scheduledTime", order: "ASCENDING"}
  ]
}

// sms_reminder_logs collection  
{
  fields: [
    {fieldPath: "userId", order: "ASCENDING"},
    {fieldPath: "sentAt", order: "DESCENDING"}
  ]
}
```

### Rate Limiting

```dart
// Kullanıcı başına saatlik SMS limiti
final userSmsCount = await FirebaseFirestore.instance
    .collection('sms_reminder_logs')
    .where('userId', isEqualTo: 'userId')
    .where('sentAt', isGreaterThan: DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch)
    .get();

if (userSmsCount.docs.length >= 10) {
  print('Rate limit aşıldı! SMS gönderilemedi.');
  return;
}
```

## 🔐 Güvenlik

### Veri Koruma

- SMS içerikleri kısa tutulur (gizlilik)
- Telefon numaraları Firestore'da güvenli şekilde saklanır
- SMS logları sadece gönderim durumu için kullanılır

### Yetkilendirme

```dart
// Sadece yetkili kullanıcılar hatırlatma gönderebilir
final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser?.uid != userId) {
  throw Exception('Yetkisiz erişim!');
}
```

## 🧪 Test

### Birim Testleri

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SMS Reminder Service Tests', () {
    test('Günlük hatırlatma gönderme', () async {
      final result = await SmsReminderService.sendDailyReminder(
        userId: 'test_user',
        phoneNumber: '+905551234567',
      );
      expect(result.isSuccess, true);
    });

    test('Haftalık rapor oluşturma', () async {
      final report = await SmsReminderService.generateWeeklyReport('test_user');
      expect(report.totalTasks, greaterThanOrEqualTo(0));
      expect(report.completionRate, greaterThanOrEqualTo(0.0));
    });
  });
}
```

### Entegrasyon Testleri

```dart
// Twilio entegrasyonu testi
test('Twilio SMS gönderimi', () async {
  const kDebugMode = false; // Production mod
  
  final success = await SmsReminderService._sendSms(
    '+905551234567', 
    'Test mesajı'
  );
  
  expect(success, true);
});
```

## 📚 API Referansı

### SmsReminderService

#### `sendDailyReminder({required String userId, String? phoneNumber})`
Günlük hatırlatma gönderir.

#### `sendMissedTaskReminder({required String userId, String? phoneNumber})`
Kaçırılan görev hatırlatması gönderir.

#### `sendStreakReminder({required String userId, String? phoneNumber})`
Seri hatırlatması gönderir.

#### `sendWeeklyReport({required String userId, String? phoneNumber})`
Haftalık rapor gönderir.

#### `markTaskAsCompleted({required String taskId, required String userId})`
Görevi tamamlandı olarak işaretler.

#### `snoozeTask({required String taskId, required String userId, Duration? snoozeDuration})`
Görevi erteler.

### SmsReminderScheduler

#### `startDailyReminderScheduler()`
Günlük hatırlatma zamanlayıcısını başlatır.

#### `startWeeklyReportScheduler()`
Haftalık rapor zamanlayıcısını başlatır.

#### `startStreakReminderScheduler()`
Seri hatırlatma zamanlayıcısını başlatır.

#### `stopAllSchedulers()`
Tüm zamanlayıcıları durdurur.

#### `sendManualReminder({required String userId, required String reminderType})`
Manuel hatırlatma gönderir.

## 🎯 Gelecek Geliştirmeler

1. **Push Notification Entegrasyonu**
   - SMS'e ek olarak push bildirimleri
   - Çok kanallı hatırlatma sistemi

2. **AI Destekli Öneriler**
   - Görev zamanı optimizasyonu
   - Kişiselleştirilmiş mesajlar

3. **Grup Hatırlatmaları**
   - Takım görevleri için grup SMS'leri
   - Sosyal motivasyon

4. **Gelişmiş Analitik**
   - Detaylı başarı metrikleri
   - Motivasyon pattern analizi

5. **Sesli Hatırlatmalar**
   - Twilio Voice API entegrasyonu
   - Sesli mesaj gönderimi

---

Bu dokümantasyon, SMS Reminder sisteminin tüm özelliklerini ve kullanımını kapsamaktadır. Herhangi bir sorun veya ek özellik talebi için lütfen geliştirme ekibi ile iletişime geçin.