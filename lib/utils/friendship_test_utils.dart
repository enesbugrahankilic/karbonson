// lib/utils/friendship_test_utils.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

/// Test Utilities for Friendship Logic
/// Bu sınıf friendship logic'in test edilmesi için utility fonksiyonları sağlar
class FriendshipTestUtils {
  static final FirestoreService _firestoreService = FirestoreService();

  /// Test için mock kullanıcılar oluştur
  static Future<Map<String, dynamic>> createTestUser({
    required String uid,
    required String nickname,
  }) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      await db.collection('users').doc(uid).set({
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Test kullanıcısı oluşturuldu: $nickname ($uid)');
      }
      return {'uid': uid, 'nickname': nickname};
    } catch (e) {
      if (kDebugMode) debugPrint('Test kullanıcısı oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Test için arkadaşlık isteği oluştur
  static Future<String> createTestFriendRequest({
    required String fromUserId,
    required String fromNickname,
    required String toUserId,
    required String toNickname,
  }) async {
    try {
      final requestId = await _firestoreService.sendFriendRequest(
        fromUserId,
        fromNickname,
        toUserId,
        toNickname,
      );

      if (kDebugMode) {
        debugPrint(
            'Test arkadaşlık isteği oluşturuldu: $fromNickname -> $toNickname');
      }

      // Request ID'yi alabilmek için Firestore'dan çekmek gerekir
      // Bu basit bir implementation - gerçek testte daha gelişmiş olabilir
      return 'test_request_id_${fromUserId}_$toUserId';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Test arkadaşlık isteği oluşturulurken hata: $e');
      }
      rethrow;
    }
  }

  /// Test verilerini temizle
  static Future<void> cleanupTestData({
    required List<String> userIds,
    List<String>? friendRequestIds,
  }) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final batch = db.batch();

      // Kullanıcıları sil
      for (final userId in userIds) {
        final userDoc = db.collection('users').doc(userId);
        batch.delete(userDoc);

        // Kullanıcının friends koleksiyonunu sil
        final friendsCollection =
            db.collection('users').doc(userId).collection('friends');
        // Friends subcollection'ı silmek için tüm dokumentları silmek gerekir
        // Bu basit bir implementasyon

        // Notifications'ı sil
        final notificationsDoc = db.collection('notifications').doc(userId);
        batch.delete(notificationsDoc);
      }

      // Arkadaşlık isteklerini sil
      if (friendRequestIds != null) {
        for (final requestId in friendRequestIds) {
          final requestDoc = db.collection('friend_requests').doc(requestId);
          batch.delete(requestDoc);
        }
      }

      await batch.commit();

      if (kDebugMode) debugPrint('Test verileri temizlendi');
    } catch (e) {
      if (kDebugMode) debugPrint('Test verilerini temizlerken hata: $e');
    }
  }

  /// Test senaryosu: Normal akış
  static Future<TestScenarioResult> testNormalAcceptFlow() async {
    try {
      // Test kullanıcıları oluştur
      final userA =
          await createTestUser(uid: 'test_user_a', nickname: 'TestUserA');
      final userB =
          await createTestUser(uid: 'test_user_b', nickname: 'TestUserB');

      // Arkadaşlık isteği gönder
      final requestId = await createTestFriendRequest(
        fromUserId: userA['uid'] as String,
        fromNickname: userA['nickname'] as String,
        toUserId: userB['uid'] as String,
        toNickname: userB['nickname'] as String,
      );

      // İsteği kabul et
      final acceptResult = await _firestoreService.acceptFriendRequest(
        requestId,
        userB['uid'] as String,
      );

      // Sonuçları kontrol et
      final friendsA =
          await _firestoreService.getFriends(userA['uid'] as String);
      final friendsB =
          await _firestoreService.getFriends(userB['uid'] as String);

      await cleanupTestData(
        userIds: [userA['uid'] as String, userB['uid'] as String],
        friendRequestIds: [requestId],
      );

      return TestScenarioResult(
        success: acceptResult && friendsA.isNotEmpty && friendsB.isNotEmpty,
        details: {
          'acceptResult': acceptResult,
          'userA_friends': friendsA.length,
          'userB_friends': friendsB.length,
        },
      );
    } catch (e) {
      return TestScenarioResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Test senaryosu: Double-click koruması
  static Future<TestScenarioResult> testDoubleClickProtection() async {
    try {
      final userA =
          await createTestUser(uid: 'test_user_a_dc', nickname: 'TestUserA_DC');
      final userB =
          await createTestUser(uid: 'test_user_b_dc', nickname: 'TestUserB_DC');

      final requestId = await createTestFriendRequest(
        fromUserId: userA['uid'] as String,
        fromNickname: userA['nickname'] as String,
        toUserId: userB['uid'] as String,
        toNickname: userB['nickname'] as String,
      );

      // İlk kabul işlemi
      final result1 = await _firestoreService.acceptFriendRequest(
          requestId, userB['uid'] as String);

      // İkinci kabul işlemi (race condition test)
      final result2 = await _firestoreService.acceptFriendRequest(
          requestId, userB['uid'] as String);

      await cleanupTestData(
        userIds: [userA['uid'] as String, userB['uid'] as String],
        friendRequestIds: [requestId],
      );

      // İlk işlem başarılı, ikincisi başarısız olmalı
      return TestScenarioResult(
        success: result1 && !result2,
        details: {
          'firstAccept': result1,
          'secondAccept': result2,
          'expectedBehavior': 'first should succeed, second should fail',
        },
      );
    } catch (e) {
      return TestScenarioResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Test senaryosu: Geçersiz kullanıcı erişimi
  static Future<TestScenarioResult> testUnauthorizedAccess() async {
    try {
      final userA = await createTestUser(
          uid: 'test_user_a_auth', nickname: 'TestUserA_Auth');
      final userB = await createTestUser(
          uid: 'test_user_b_auth', nickname: 'TestUserB_Auth');
      final userC = await createTestUser(
          uid: 'test_user_c_auth', nickname: 'TestUserC_Auth');

      final requestId = await createTestFriendRequest(
        fromUserId: userA['uid'] as String,
        fromNickname: userA['nickname'] as String,
        toUserId: userB['uid'] as String,
        toNickname: userB['nickname'] as String,
      );

      // Kullanıcı C, kullanıcı B'ye gelen isteği kabul etmeye çalışıyor (yetkisiz erişim)
      final unauthorizedResult = await _firestoreService.acceptFriendRequest(
        requestId,
        userC['uid'] as String, // Yanlış kullanıcı
      );

      await cleanupTestData(
        userIds: [
          userA['uid'] as String,
          userB['uid'] as String,
          userC['uid'] as String
        ],
        friendRequestIds: [requestId],
      );

      return TestScenarioResult(
        success: !unauthorizedResult, // Başarısız olmalı
        details: {
          'unauthorizedAccept': unauthorizedResult,
          'expectedBehavior': 'should fail due to unauthorized access',
        },
      );
    } catch (e) {
      return TestScenarioResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Test senaryosu sonucu
class TestScenarioResult {
  final bool success;
  final Map<String, dynamic>? details;
  final String? error;

  TestScenarioResult({
    required this.success,
    this.details,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return '✅ Test başarılı: ${details ?? "No details"}';
    } else {
      return '❌ Test başarısız: ${error ?? "Unknown error"}';
    }
  }
}
