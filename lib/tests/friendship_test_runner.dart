// lib/tests/friendship_test_runner.dart

import 'package:flutter/foundation.dart';
import '../utils/friendship_test_utils.dart';
import '../services/firestore_service.dart';

/// Test Runner for Friendship Logic
/// Bu sınıf friendship logic testlerini çalıştırmak için kullanılır
class FriendshipTestRunner {
  static final FirestoreService _firestoreService = FirestoreService();

  /// Tüm testleri çalıştır
  static Future<void> runAllTests() async {
    if (kDebugMode) {
      debugPrint('🧪 Arkadaşlık Logic Testleri Başlatılıyor...\n');
    }

    // Test 1: Normal akış testi
    if (kDebugMode) debugPrint('Test 1: Normal kabul akışı');
    final test1Result = await FriendshipTestUtils.testNormalAcceptFlow();
    debugPrint('${test1Result.toString()}\n');

    // Test 2: Double-click koruması
    if (kDebugMode) debugPrint('Test 2: Double-click koruması');
    final test2Result = await FriendshipTestUtils.testDoubleClickProtection();
    debugPrint('${test2Result.toString()}\n');

    // Test 3: Yetkisiz erişim koruması
    if (kDebugMode) debugPrint('Test 3: Yetkisiz erişim koruması');
    final test3Result = await FriendshipTestUtils.testUnauthorizedAccess();
    debugPrint('${test3Result.toString()}\n');

    // Sonuçlar
    final allTests = [test1Result, test2Result, test3Result];
    final successfulTests = allTests.where((test) => test.success).length;
    final totalTests = allTests.length;

    if (kDebugMode) {
      debugPrint('📊 TEST SONUÇLARI:');
      debugPrint('Başarılı: $successfulTests/$totalTests');

      if (successfulTests == totalTests) {
        debugPrint('🎉 Tüm testler başarılı! Implementation hazır.');
      } else {
        debugPrint(
            '⚠️ Bazı testler başarısız. Lütfen implementation kontrol edin.');
      }
    }
  }

  /// Belirli bir testi çalıştır
  static Future<void> runSpecificTest(TestType testType) async {
    TestScenarioResult? result;

    switch (testType) {
      case TestType.normalAcceptFlow:
        if (kDebugMode) {
          debugPrint('Normal Kabul Akışı Testi çalıştırılıyor...');
        }
        result = await FriendshipTestUtils.testNormalAcceptFlow();
        break;
      case TestType.doubleClickProtection:
        if (kDebugMode) {
          debugPrint('Double-click Koruması Testi çalıştırılıyor...');
        }
        result = await FriendshipTestUtils.testDoubleClickProtection();
        break;
      case TestType.unauthorizedAccess:
        if (kDebugMode) {
          debugPrint('Yetkisiz Erişim Koruması Testi çalıştırılıyor...');
        }
        result = await FriendshipTestUtils.testUnauthorizedAccess();
        break;
    }

    debugPrint(result.toString());
    }

  /// Manuel test senaryoları için utility fonksiyonlar
  static Future<void> demonstrateUsage() async {
    if (kDebugMode) {
      debugPrint('📚 Kullanım Örnekleri:\n');

      debugPrint('1. Arkadaşlık isteği gönderme:');
      debugPrint('''
final success = await firestoreService.sendFriendRequest(
  "user_a_id",
  "UserA", 
  "user_b_id",
  "UserB",
);
''');

      debugPrint('2. Arkadaşlık isteği kabul etme (Atomik):');
      debugPrint('''
final success = await firestoreService.acceptFriendRequest(
  "request_id",
  "recipient_user_id", // Sadece alıcı kabul edebilir
);
''');

      debugPrint('3. Arkadaşlık isteği reddetme (Atomik):');
      debugPrint('''
final success = await firestoreService.rejectFriendRequest(
  "request_id",
  "recipient_user_id",
  sendNotification: true, // Opsiyonel bildirim
);
''');

      debugPrint('4. Arkadaşları getirme:');
      debugPrint('''
final friends = await firestoreService.getFriends("user_id");
''');

      debugPrint('5. Bildirimleri getirme:');
      debugPrint('''
final notifications = await firestoreService.getNotifications("user_id");
''');
    }
  }
}

enum TestType {
  normalAcceptFlow,
  doubleClickProtection,
  unauthorizedAccess,
}

/// Quick test fonksiyonu - Development sırasında kullanılabilir
///
/// Bu fonksiyonu main.dart'ta veya herhangi bir yerde çağırarak
/// hızlıca test edebilirsiniz:
///
/// ```dart
/// // Development modunda test çalıştır
/// if (kDebugMode) {
///   FriendshipTestRunner.quickTest();
/// }
/// ```
Future<void> quickTest() async {
  await FriendshipTestRunner.runAllTests();
}

/// Interactive test menu
Future<void> interactiveTestMenu() async {
  if (kDebugMode) {
    debugPrint('🧪 Arkadaşlık Logic Test Menu:');
    debugPrint('1. Tüm testleri çalıştır');
    debugPrint('2. Normal kabul akışı');
    debugPrint('3. Double-click koruması');
    debugPrint('4. Yetkisiz erişim koruması');
    debugPrint('5. Kullanım örneklerini göster');
    debugPrint('6. Çık');
    debugPrint('Seçiminizi yapın (1-6): ');

    // Bu kısım gerçek bir input sistemi gerektirir
    // Şimdilik sadece tüm testleri çalıştıralım
    await FriendshipTestRunner.runAllTests();
  }
}
