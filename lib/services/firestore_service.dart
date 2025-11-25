// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../models/game_board.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Skorların kaydedildiği koleksiyon adı
  static const String _collectionName = 'users';

  // Multiplayer collections
  static const String _roomsCollection = 'game_rooms';
  static const String _playersSubcollection = 'players';

  /// Yeni bir kullanıcının skorunu Firestore'a kaydeder.
  Future<String> saveUserScore(String nickname, int score) async {
    if (score < 10) {
      return 'Skorunuz düşük olduğu için kaydedilmeyecek.';
    }
    try {
      await _db.collection(_collectionName).doc().set({
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
          .collection(_collectionName)
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
      final roomId = _db.collection(_roomsCollection).doc().id;
      final room = GameRoom(
        id: roomId,
        hostId: hostId,
        hostNickname: hostNickname,
        players: [],
        boardTiles: boardTiles,
        createdAt: DateTime.now(),
      );

      await _db.collection(_roomsCollection).doc(roomId).set(room.toMap());
      if (kDebugMode) debugPrint('Oda oluşturuldu: $roomId');
      return room;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Oda oluştururken hata: $e');
      return null;
    }
  }

  /// Bir odaya katılır
  Future<bool> joinRoom(String roomId, MultiplayerPlayer player) async {
    try {
      final roomRef = _db.collection(_roomsCollection).doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) {
        if (kDebugMode) debugPrint('Oda bulunamadı: $roomId');
        return false;
      }

      final roomData = roomDoc.data()!;
      final players = (roomData['players'] as List<dynamic>?)
          ?.map((p) => MultiplayerPlayer.fromMap(p as Map<String, dynamic>))
          .toList() ?? [];

      // Oyuncu zaten odada mı kontrol et
      if (players.any((p) => p.id == player.id)) {
        if (kDebugMode) debugPrint('Oyuncu zaten odada');
        return true; // Zaten odada
      }

      // Maksimum oyuncu sayısı kontrolü (örneğin 4)
      if (players.length >= 4) {
        if (kDebugMode) debugPrint('Oda dolu');
        return false;
      }

      players.add(player);
      await roomRef.update({'players': players.map((p) => p.toMap()).toList()});

      if (kDebugMode) debugPrint('Oyuncu odaya katıldı: ${player.nickname}');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Odaya katılmada hata: $e');
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

  // Friends Collections
  static const String _friendsCollection = 'friends';
  static const String _friendRequestsCollection = 'friend_requests';

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

  /// Arkadaşlık isteğini kabul et
  Future<bool> acceptFriendRequest(String requestId, String accepterId) async {
    try {
      final requestRef = _db.collection(_friendRequestsCollection).doc(requestId);
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) return false;

      final request = FriendRequest.fromMap(requestDoc.data()!);

      // İsteği kabul eden kişi alıcı mı kontrol et
      if (request.toUserId != accepterId) return false;

      // Arkadaşlığı her iki taraf için de ekle
      final friend1 = Friend(
        id: request.fromUserId,
        nickname: request.fromNickname,
        addedAt: DateTime.now(),
      );
      final friend2 = Friend(
        id: request.toUserId,
        nickname: request.toNickname,
        addedAt: DateTime.now(),
      );

      // Batch write kullanarak her iki arkadaşlığı da ekle
      final batch = _db.batch();
      batch.set(_db.collection(_friendsCollection).doc('${request.fromUserId}_${request.toUserId}'), {
        'userId': request.fromUserId,
        'friend': friend2.toMap(),
      });
      batch.set(_db.collection(_friendsCollection).doc('${request.toUserId}_${request.fromUserId}'), {
        'userId': request.toUserId,
        'friend': friend1.toMap(),
      });

      // İsteği kabul edildi olarak güncelle
      batch.update(requestRef, {'status': FriendRequestStatus.accepted.toString().split('.').last});

      await batch.commit();
      if (kDebugMode) debugPrint('Arkadaşlık isteği kabul edildi: ${request.fromNickname} ve ${request.toNickname}');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Arkadaşlık isteği kabul edilirken hata: $e');
      return false;
    }
  }

  /// Arkadaşlık isteğini reddet
  Future<bool> rejectFriendRequest(String requestId, String rejecterId) async {
    try {
      final requestRef = _db.collection(_friendRequestsCollection).doc(requestId);
      final requestDoc = await requestRef.get();

      if (!requestDoc.exists) return false;

      final request = FriendRequest.fromMap(requestDoc.data()!);

      // İsteği reddeden kişi alıcı mı kontrol et
      if (request.toUserId != rejecterId) return false;

      await requestRef.update({'status': FriendRequestStatus.rejected.toString().split('.').last});
      if (kDebugMode) debugPrint('Arkadaşlık isteği reddedildi: ${request.fromNickname} -> ${request.toNickname}');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('HATA: Arkadaşlık isteği reddedilirken hata: $e');
      return false;
    }
  }

  /// Kullanıcının arkadaşlarını getir
  Future<List<Friend>> getFriends(String userId) async {
    try {
      final querySnapshot = await _db
          .collection(_friendsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Friend.fromMap(doc.data()['friend'] as Map<String, dynamic>))
          .toList();
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
          .collection(_collectionName)
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThan: query + '\uf8ff')
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
}