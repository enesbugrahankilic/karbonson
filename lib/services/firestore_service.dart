// lib/services/firestore_service.dart
// Updated with Identity Management and UID Centrality (Specification I.1-I.4)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_board.dart';
import '../models/notification_data.dart';
import '../models/user_data.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections with UID Centrality (Specification I.2)
  // Legacy collection name for backward compatibility - now uses UID as document ID 
  static const String _roomsCollection = 'game_rooms';

  /// Yeni bir kullanıcının skorunu Firestore'a kaydeder.
  Future<String> saveUserScore(String nickname, int score) async {
    if (score < 10) {
      return 'Skorunuz düşük olduğu için kaydedilmeyecek.';
    }
    try {
      await _db.collection(_usersCollection).doc().set({
        'nickname': nickname, // Oyuncu takma adı
        'score': score,       // Oyun sonu skoru
        'timestamp': FieldValue.serverTimestamp(), // Kayıt zamanı
      });
      if (kDebugMode) debugPrint('Başarılı: Skor $nickname için kaydedildi: $score');
      return 'Skor kaydedildi.';
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Skor kaydederken hata oluştu: $e');
      return 'Skor kaydedilirken hata oluştu.';
    }
  }

  /// Tüm skorları puana göre azalan sırada (en yüksekten en düşüğe) çeker.
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .orderBy('score', descending: true) // Skora göre sırala
          // .limit(10) kaldırılmıştır, tüm kayıtlar çekilir.
          .get();

      // Dokümanlardan veri haritalarını listeye dönüştür.
      return querySnapshot.docs.map((doc) => doc.data()).toList();

    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Liderlik tablosu getirilirken hata oluştu: $e');
      return [];
    }
  }

  // Multiplayer Methods

  /// Yeni bir oyun odası oluşturur
  Future<GameRoom?> createRoom(String hostId, String hostNickname, List<Map<String, dynamic>> boardTiles) async {
    try {
      if (kDebugMode) debugPrint('Creating room for host: $hostNickname ($hostId)');
      
      final roomId = _db.collection(_roomsCollection).doc().id;
      if (kDebugMode) debugPrint('Generated room ID: $roomId');
      
      final room = GameRoom(
        id: roomId,
        hostId: hostId,
        hostNickname: hostNickname,
        players: [],
        boardTiles: boardTiles,
        createdAt: DateTime.now(),
      );

      final roomData = room.toMap();
      if (kDebugMode) debugPrint('Room data to save: ${roomData.toString()}');

      await _db.collection(_roomsCollection).doc(roomId).set(roomData);
      if (kDebugMode) debugPrint('✅ Room created successfully: $roomId');
      return room;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🚨 ERROR: Failed to create room: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Bir odaya katılır
  Future<bool> joinRoom(String roomId, MultiplayerPlayer player) async {
    try {
      if (kDebugMode) debugPrint('Attempting to join room: $roomId with player: ${player.nickname}');
      
      final roomRef = _db.collection(_roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) {
        if (kDebugMode) debugPrint('❌ Room not found: $roomId');
        return false;
      }

      final roomData = roomDoc.data()!;
      if (kDebugMode) debugPrint('Room data found: ${roomData.toString()}');
      
      final players = (roomData['players'] as List<dynamic>?)
          ?.map((p) => MultiplayerPlayer.fromMap(p as Map<String, dynamic>))
          .toList() ?? [];

      if (kDebugMode) debugPrint('Current players in room: ${players.length}');

      // Oyuncu zaten odada mı kontrol et
      if (players.any((p) => p.id == player.id)) {
        if (kDebugMode) debugPrint('✅ Player already in room');
        return true; // Zaten odada
      }

      // Maksimum oyuncu sayısı kontrolü (örneğin 4)
      if (players.length >= 4) {
        if (kDebugMode) debugPrint('❌ Room is full (${players.length}/4 players)');
        return false;
      }

      players.add(player);
      final updatedPlayers = players.map((p) => p.toMap()).toList();
      
      if (kDebugMode) debugPrint('Adding player to room. Updated player count: ${players.length}');
      
      await roomRef.update({'players': updatedPlayers});

      if (kDebugMode) debugPrint('✅ Player ${player.nickname} joined room $roomId successfully');
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🚨 ERROR: Failed to join room: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// Oyunu başlatır (host için)
  Future<bool> startGame(String roomId) async {
    try {
      await _db.collection(_roomsCollection).doc(roomId).update({
        'status': GameStatus.playing.toString().split('.').last,
      });
      if (kDebugMode) debugPrint('Oyun başlatıldı: $roomId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Oyun başlatmada hata: $e');
      return false;
    }
  }

  /// Oyuncu hazır durumunu günceller
  Future<bool> updatePlayerReady(String roomId, String playerId, bool isReady) async {
    try {
      final roomRef = _db.collection(_roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) return false;

      final roomData = roomDoc.data()!;
      final players = (roomData['players'] as List<dynamic>)
          .map((p) => MultiplayerPlayer.fromMap(p as Map<String, dynamic>))
          .toList();

      final playerIndex = players.indexWhere((p) => p.id == playerId);
      if (playerIndex == -1) return false;

      players[playerIndex].isReady = isReady;
      await roomRef.update({'players': players.map((p) => p.toMap()).toList()});

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Oyuncu hazır durumu güncellenirken hata: $e');
      return false;
    }
  }

  /// Oyun durumunu günceller
  Future<bool> updateGameState(String roomId, {
    int? currentPlayerIndex,
    int? timeElapsedInSeconds,
    List<MultiplayerPlayer>? players,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (currentPlayerIndex != null) updates['currentPlayerIndex'] = currentPlayerIndex;
      if (timeElapsedInSeconds != null) updates['timeElapsedInSeconds'] = timeElapsedInSeconds;
      if (players != null) updates['players'] = players.map((p) => p.toMap()).toList();

      if (updates.isNotEmpty) {
        await _db.collection(_roomsCollection).doc(roomId).update(updates);
      }
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Oyun durumu güncellenirken hata: $e');
      return false;
    }
  }

  /// Oyunu bitirir
  Future<bool> endGame(String roomId) async {
    try {
      await _db.collection(_roomsCollection).doc(roomId).update({
        'status': GameStatus.finished.toString().split('.').last,
      });
      if (kDebugMode) debugPrint('Oyun bitti: $roomId');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Oyun bitirilirken hata: $e');
      return false;
    }
  }

  /// Odadan ayrılır
  Future<bool> leaveRoom(String roomId, String playerId) async {
    try {
      final roomRef = _db.collection(_roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) return false;

      final roomData = roomDoc.data()!;
      final players = (roomData['players'] as List<dynamic>)
          .map((p) => MultiplayerPlayer.fromMap(p as Map<String, dynamic>))
          .toList();

      players.removeWhere((p) => p.id == playerId);

      if (players.isEmpty) {
        // Oda boşsa sil
        await roomRef.delete();
        if (kDebugMode) debugPrint('Oda silindi: $roomId');
      } else {
        await roomRef.update({'players': players.map((p) => p.toMap()).toList()});
        if (kDebugMode) debugPrint('Oyuncu odadan ayrıldı: $playerId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Odadan ayrılırken hata: $e');
      return false;
    }
  }

  /// Oda değişikliklerini dinler
  Stream<GameRoom?> listenToRoom(String roomId) {
    return _db.collection(_roomsCollection).doc(roomId).snapshots().map((doc) {
      if (doc.exists) {
        return GameRoom.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Aktif odaları listeler
  Future<List<GameRoom>> getActiveRooms() async {
    try {
      final querySnapshot = await _db
          .collection(_roomsCollection)
          .where('status', isEqualTo: GameStatus.waiting.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => GameRoom.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Aktif odalar getirilirken hata: $e');
      return [];
    }
  }

  // === IDENTITY MANAGEMENT AND DATA INTEGRITY (Specification I.1-I.4) ===
  
  /// Get current authenticated user ID (Specification I.1)
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Get current authenticated user (Specification I.1)
  User? get currentUser => _auth.currentUser;
  
  /// Check if user is currently authenticated (Specification I.1)
  bool get isUserAuthenticated => _auth.currentUser != null;

  /// Create or update user profile with UID centrality (Specification I.1 & I.2)
  /// Document ID MUST be Firebase Auth UID for data integrity
  Future<UserData?> createOrUpdateUserProfile({
    required String nickname,
    String? profilePictureUrl,
    PrivacySettings? privacySettings,
    String? fcmToken,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ User not authenticated');
        return null;
      }

      // Specification I.1: Always use Auth UID as document ID
      final userDocRef = _db.collection(_usersCollection).doc(user.uid);
      
      // Check if user profile already exists
      final existingDoc = await userDocRef.get();
      
      // Validate nickname (Specification I.4)
      final validation = NicknameValidator.validate(nickname);
      if (!validation.isValid) {
        if (kDebugMode) debugPrint('❌ Nickname validation failed: ${validation.error}');
        return null;
      }

      final userData = UserData(
        uid: user.uid, // Always use document ID as UID
        nickname: nickname,
        profilePictureUrl: profilePictureUrl,
        lastLogin: DateTime.now(),
        createdAt: existingDoc.exists ? null : DateTime.now(),
        updatedAt: DateTime.now(),
        isAnonymous: user.isAnonymous,
        privacySettings: privacySettings ?? const PrivacySettings.defaults(),
        fcmToken: fcmToken,
      );

      await userDocRef.set(userData.toMap(), SetOptions(merge: true));
      
      if (kDebugMode) {
        debugPrint('✅ User profile created/updated with UID centrality: ${user.uid}');
      }
      
      return userData;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error creating/updating user profile: $e');
      return null;
    }
  }

  /// Get user profile by UID (Specification I.2: Document ID = UID)
  Future<UserData?> getUserProfile(String uid) async {
    try {
      final userDoc = await _db.collection(_usersCollection).doc(uid).get();
      
      if (!userDoc.exists) {
        if (kDebugMode) debugPrint('❌ User profile not found for UID: $uid');
        return null;
      }

      final userData = UserData.fromMap(userDoc.data()!, userDoc.id);
      
      if (kDebugMode) {
        debugPrint('✅ User profile retrieved with UID centrality: ${userData.nickname}');
      }
      
      return userData;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting user profile: $e');
      return null;
    }
  }

  /// Update user nickname with validation (Specification I.4)
  Future<bool> updateUserNickname(String newNickname) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Validate nickname (Specification I.4)
      final validation = NicknameValidator.validate(newNickname);
      if (!validation.isValid) {
        if (kDebugMode) debugPrint('❌ Nickname validation failed: ${validation.error}');
        return false;
      }

      // Check cooldown period (Specification I.4)
      final canChange = await NicknameValidator.canChangeNickname(user.uid);
      if (!canChange) {
        if (kDebugMode) debugPrint('❌ Nickname change cooldown active');
        return false;
      }

      await _db.collection(_usersCollection).doc(user.uid).update({
        'nickname': newNickname,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Nickname updated successfully for UID: ${user.uid}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating nickname: $e');
      return false;
    }
  }

  /// Update user privacy settings (Specification II.3)
  Future<bool> updatePrivacySettings(PrivacySettings privacySettings) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _db.collection(_usersCollection).doc(user.uid).update({
        'privacySettings': privacySettings.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Privacy settings updated for UID: ${user.uid}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating privacy settings: $e');
      return false;
    }
  }

  /// Search users by nickname (Specification I.3)
  /// Returns user data while respecting privacy settings
  Future<List<UserData>> searchUsersByNickname(String query, {int limit = 10}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThan: '$query\uf8ff')
          .limit(limit)
          .get();

      final List<UserData> results = [];

      for (final doc in querySnapshot.docs) {
        try {
          final userData = UserData.fromMap(doc.data(), doc.id);
          
          // Skip current user
          if (userData.uid == currentUser.uid) continue;
          
          // Respect privacy settings (Specification II.3)
          if (!userData.privacySettings.allowSearchByNickname) continue;
          
          results.add(userData);
        } catch (e) {
          if (kDebugMode) debugPrint('⚠️ Error parsing user data for UID: ${doc.id}');
          continue;
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Found ${results.length} users matching query: $query');
      }

      return results;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error searching users: $e');
      return [];
    }
  }

  /// Verify if a friend request can be sent (Specification II.3 & I.3)
  /// Checks privacy settings and prevents duplicate requests
  Future<bool> canSendFriendRequest(String targetUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid == targetUserId) return false;

      // Get target user's privacy settings
      final targetUser = await getUserProfile(targetUserId);
      if (targetUser == null) return false;

      // Check privacy settings
      if (!targetUser.privacySettings.allowFriendRequests) {
        if (kDebugMode) debugPrint('❌ Target user does not allow friend requests');
        return false;
      }

      // Check if already friends
      final friends = await getFriends(currentUser.uid);
      if (friends.any((friend) => friend.id == targetUserId)) {
        if (kDebugMode) debugPrint('❌ Users are already friends');
        return false;
      }

      // Check if request already exists
      final sentRequests = await getSentFriendRequests(currentUser.uid);
      if (sentRequests.any((request) => request.toUserId == targetUserId)) {
        if (kDebugMode) debugPrint('❌ Friend request already sent');
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error checking friend request eligibility: $e');
      return false;
    }
  }

  /// Get all users for admin/debug purposes (with UID centrality)
  /// Warning: This should be restricted in production
  Future<List<UserData>> getAllUsers({int limit = 100}) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        return UserData.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error getting all users: $e');
      return [];
    }
  }

  /// Clean up invalid or orphaned data (Specification I.2)
  /// Removes user data that doesn't correspond to valid Auth UIDs
  Future<int> cleanupInvalidUserData() async {
    try {
      final querySnapshot = await _db.collection(_usersCollection).get();
      int cleanedCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          // Check if this UID corresponds to an actual Auth user
          final userData = UserData.fromMap(doc.data(), doc.id);
          
          // This is a simple check - in production, you'd want to verify against Auth
          if (userData.uid != doc.id) {
            // Data integrity issue - document ID doesn't match stored UID
            await doc.reference.delete();
            cleanedCount++;
            
            if (kDebugMode) {
              debugPrint('🧹 Cleaned invalid user data with UID: ${userData.uid}');
            }
          }
        } catch (e) {
          // Invalid data format - clean it up
          await doc.reference.delete();
          cleanedCount++;
          
          if (kDebugMode) {
            debugPrint('🧹 Cleaned malformed user data: ${doc.id}');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Cleanup completed: $cleanedCount invalid records removed');
      }

      return cleanedCount;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error during cleanup: $e');
      return 0;
    }
  }

  // Friends Collections - Updated structure per specification
  static const String _usersCollection = 'users';
  static const String _friendsCollection = 'friends';
  static const String _friendRequestsCollection = 'friend_requests';
  static const String _notificationsCollection = 'notifications';

  /// Arkadaşlık isteği gönder
  Future<bool> sendFriendRequest(String fromUserId, String fromNickname, String toUserId, String toNickname) async {
    try {
      final requestId = _db.collection(_friendRequestsCollection).doc().id;
      final request = FriendRequest(
        id: requestId,
        fromUserId: fromUserId,
        fromNickname: fromNickname,
        toUserId: toUserId,
        toNickname: toNickname,
        createdAt: DateTime.now(),
      );

      await _db.collection(_friendRequestsCollection).doc(requestId).set(request.toMap());
      if (kDebugMode) debugPrint('Arkadaşlık isteği gönderildi: $fromNickname -> $toNickname');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Arkadaşlık isteği gönderilirken hata: $e');
      return false;
    }
  }

  /// Arkadaşlık isteğini atomik olarak kabul et
  /// Specification: Batch Write içinde 4 işlem:
  /// 1. İstek belgesini sil
  /// 2. Alıcının arkadaş listesini güncelle
  /// 3. Gönderenin arkadaş listesini güncelle
  /// 4. Gönderene bildirim gönder
  Future<bool> acceptFriendRequest(String requestId, String recipientId) async {
    try {
      final requestRef = _db.collection(_friendRequestsCollection).doc(requestId);
      final requestDoc = await requestRef.get();

      // Adım 1: İstek Durumunun Kontrolü
      if (!requestDoc.exists) {
        if (kDebugMode) debugPrint('İstek belgesi bulunamadı: $requestId');
        return false;
      }

      final request = FriendRequest.fromMap(requestDoc.data()!);

      // İsteği kabul eden kişi gerçekten alıcı mı kontrol et
      if (request.toUserId != recipientId) {
        if (kDebugMode) debugPrint('Yetkisiz işlem denemesi: $recipientId, istek alıcısı: ${request.toUserId}');
        return false;
      }

      // İsteğin hala pending durumda olup olmadığını kontrol et
      if (request.status != FriendRequestStatus.pending) {
        if (kDebugMode) debugPrint('İstek zaten işlenmiş: ${request.status}');
        return false;
      }

      // Adım 2: Batch Write ile atomik işlem
      final batch = _db.batch();

      // İşlem 1: İstek Belgesini Sil (/friend_requests/{request_document_id})
      batch.delete(requestRef);

      // İşlem 2: Alıcının Arkadaş Listesini Güncelle (/users/{RecipientUID}/friends)
      final recipientFriendDoc = _db
          .collection(_usersCollection)
          .doc(recipientId)
          .collection('friends')
          .doc(request.fromUserId);
      
      batch.set(recipientFriendDoc, {
        'uid': request.fromUserId,
        'nickname': request.fromNickname,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // İşlem 3: Gönderenin Arkadaş Listesini Güncelle (/users/{SenderUID}/friends)
      final senderFriendDoc = _db
          .collection(_usersCollection)
          .doc(request.fromUserId)
          .collection('friends')
          .doc(recipientId);
      
      batch.set(senderFriendDoc, {
        'uid': recipientId,
        'nickname': request.toNickname,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // İşlem 4: Gönderene Bildirim Gönder (/notifications/{SenderUID}/...)
      final notificationDoc = _db
          .collection(_notificationsCollection)
          .doc(request.fromUserId)
          .collection('notifications')
          .doc();

      final notification = NotificationData.friendRequestAccepted(
        senderId: recipientId,
        senderNickname: request.toNickname,
        recipientNickname: request.fromNickname,
      );

      final notificationWithId = notification.copyWith(id: notificationDoc.id);
      batch.set(notificationDoc, notificationWithId.toMap());

      // Tüm işlemleri atomik olarak commit et
      await batch.commit();

      if (kDebugMode) {
        debugPrint('✅ Arkadaşlık isteği atomik olarak kabul edildi: ${request.fromNickname} -> ${request.toNickname}');
      }
      return true;

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 HATA: Arkadaşlık isteği kabul edilirken kritik hata: $e');
      return false;
    }
  }

  /// Arkadaşlık isteğini atomik olarak reddet
  /// Specification: Batch Write içinde işlem:
  /// 1. İstek belgesini sil
  /// 2. Opsiyonel: Gönderene bildirim gönder
  Future<bool> rejectFriendRequest(
    String requestId, 
    String recipientId, {
    bool sendNotification = true,
  }) async {
    try {
      final requestRef = _db.collection(_friendRequestsCollection).doc(requestId);
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) {
        if (kDebugMode) debugPrint('İstek belgesi bulunamadı: $requestId');
        return false;
      }

      final request = FriendRequest.fromMap(requestDoc.data()!);

      // İsteği reddeden kişi gerçekten alıcı mı kontrol et
      if (request.toUserId != recipientId) {
        if (kDebugMode) debugPrint('Yetkisiz işlem denemesi: $recipientId, istek alıcısı: ${request.toUserId}');
        return false;
      }

      // İsteğin hala pending durumda olup olmadığını kontrol et
      if (request.status != FriendRequestStatus.pending) {
        if (kDebugMode) debugPrint('İstek zaten işlenmiş: ${request.status}');
        return false;
      }

      // Atomik Batch Write işlemi
      final batch = _db.batch();

      // İşlem 1: İstek Belgesini Sil
      batch.delete(requestRef);

      // İşlem 2: Opsiyonel - Gönderene Bildirim Gönder
      if (sendNotification) {
        final notificationDoc = _db
            .collection(_notificationsCollection)
            .doc(request.fromUserId)
            .collection('notifications')
            .doc();

        final notification = NotificationData.friendRequestRejected(
          senderId: recipientId,
          senderNickname: request.toNickname,
          recipientNickname: request.fromNickname,
        );

        final notificationWithId = notification.copyWith(id: notificationDoc.id);
        batch.set(notificationDoc, notificationWithId.toMap());
      }

      // Tüm işlemleri atomik olarak commit et
      await batch.commit();

      if (kDebugMode) {
        debugPrint('✅ Arkadaşlık isteği atomik olarak reddedildi: ${request.fromNickname} -> ${request.toNickname}');
      }
      return true;

    } catch (e) {
      if (kDebugMode) debugPrint('🚨 HATA: Arkadaşlık isteği reddedilirken kritik hata: $e');
      return false;
    }
  }

  /// Kullanıcının arkadaşlarını getir
  /// Updated: Uses users/{UID}/friends structure per specification
  Future<List<Friend>> getFriends(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_usersCollection)
          .doc(userId)
          .collection('friends')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Friend(
          id: data['uid'],
          nickname: data['nickname'],
          addedAt: (data['addedAt'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Arkadaşlar getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının aldığı arkadaşlık isteklerini getir
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_friendRequestsCollection)
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: FriendRequestStatus.pending.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FriendRequest.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Alınan arkadaşlık istekleri getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının gönderdiği arkadaşlık isteklerini getir
  Future<List<FriendRequest>> getSentFriendRequests(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_friendRequestsCollection)
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: FriendRequestStatus.pending.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FriendRequest.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Gönderilen arkadaşlık istekleri getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcı adına göre arama yap
  Future<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId) async {
    try {
      // Bu basit bir arama - gerçek uygulamada daha sofistike arama algoritmaları kullanılabilir
      final querySnapshot = await _db
          .collection(_usersCollection)
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThan: '$query\uf8ff')
          .limit(10)
          .get();

      final users = querySnapshot.docs
          .map((doc) => doc.data())
          .where((user) => user['nickname'] != null && user['nickname'].toString().toLowerCase().contains(query.toLowerCase()))
          .where((user) => user['nickname'] != null) // Null kontrolü
          .toList();

      // Mevcut kullanıcıyı ve arkadaşları filtrele
      final friends = await getFriends(currentUserId);
      final friendIds = friends.map((f) => f.id).toSet();

      return users.where((user) {
        final userId = user['nickname'] as String?;
        return userId != null && userId != currentUserId && !friendIds.contains(userId);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Kullanıcı arama yapılırken hata: $e');
      return [];
    }
  }

  /// Kullanıcının bildirimlerini getir
  Future<List<NotificationData>> getNotifications(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        return NotificationData.fromMap(doc.data());
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Bildirimler getirilirken hata: $e');
      return [];
    }
  }

  /// Bildirim okundu olarak işaretle
  Future<bool> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _db
          .collection(_notificationsCollection)
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Bildirim işaretlenirken hata: $e');
      return false;
    }
  }

  /// Arkadaşlık isteğinin geçerliliğini kontrol et
  /// Specification: Race condition ve double-click koruması için
  Future<bool> isFriendRequestValid(String requestId, String recipientId) async {
    try {
      final requestRef = _db.collection(_friendRequestsCollection).doc(requestId);
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) return false;

      final request = FriendRequest.fromMap(requestDoc.data()!);
      
      // İsteğin hedef kişisi doğru mu?
      if (request.toUserId != recipientId) return false;
      
      // İstek hala pending durumda mı?
      if (request.status != FriendRequestStatus.pending) return false;

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: İstek geçerliliği kontrol edilirken hata: $e');
      return false;
    }
  }

  /// Arkadaşlık ilişkisini kaldır (gelecekte gerekirse)
  Future<bool> removeFriend(String userId, String friendId) async {
    try {
      final batch = _db.batch();

      // Kullanıcının arkadaş listesinden kaldır
      batch.delete(_db
          .collection(_usersCollection)
          .doc(userId)
          .collection('friends')
          .doc(friendId));

      // Arkadaşın listesinden kullanıcıyı kaldır
      batch.delete(_db
          .collection(_usersCollection)
          .doc(friendId)
          .collection('friends')
          .doc(userId));

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Arkadaş kaldırılırken hata: $e');
      return false;
    }
  }
}