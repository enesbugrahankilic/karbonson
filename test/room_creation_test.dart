import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karbonson/services/firestore_service.dart';
import 'package:karbonson/services/duel_game_logic.dart';
import 'package:karbonson/models/game_board.dart';
import 'firebase_test_config.dart';

// Extension to add toMap to BoardTile
extension BoardTileExtension on BoardTile {
  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'type': type.toString().split('.').last,
      'label': label,
    };
  }
}

void main() {
  group('Oda Oluşturma Fonksiyonları Test', () {
    late FirestoreService firestoreService;

    setUpAll(() async {
      // Firebase'i test için başlat
      await FirebaseTestConfig.initialize();
      firestoreService = FirestoreService();
    });

    tearDownAll(() async {
      // Test sonrası temizlik
    });

    group('createRoom Test', () {
      test('Yeni multiplayer oda oluşturulabiliyor', () async {
        const hostId = 'test-host-123';
        const hostNickname = 'Test Host';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room = await firestoreService.createRoom(
          hostId,
          hostNickname,
          boardTiles,
        );

        expect(room, isNotNull);
        expect(room!.id, isNotEmpty);
        expect(room.hostId, equals(hostId));
        expect(room.hostNickname, equals(hostNickname));
        expect(room.players, isEmpty); // Başlangıçta oyuncu yok
        expect(room.roomCode, isNotEmpty);
        expect(room.accessCode, isNotEmpty);
        expect(room.status, equals(GameStatus.waiting));
      });

      test('Oda kodu benzersiz', () async {
        const hostId1 = 'test-host-1';
        const hostNickname1 = 'Host 1';
        const hostId2 = 'test-host-2';
        const hostNickname2 = 'Host 2';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room1 = await firestoreService.createRoom(
          hostId1,
          hostNickname1,
          boardTiles,
        );

        final room2 = await firestoreService.createRoom(
          hostId2,
          hostNickname2,
          boardTiles,
        );

        expect(room1!.roomCode, isNot(equals(room2!.roomCode)));
      });

      test('Custom oda kodu ile oda oluşturulabiliyor', () async {
        const hostId = 'test-host-custom';
        const hostNickname = 'Custom Host';
        const customRoomCode = 'CUSTOM123';
        const customAccessCode = 'ACCESS456';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room = await firestoreService.createRoom(
          hostId,
          hostNickname,
          boardTiles,
          customRoomCode: customRoomCode,
          customAccessCode: customAccessCode,
        );

        expect(room, isNotNull);
        expect(room!.roomCode, equals(customRoomCode));
        expect(room.accessCode, equals(customAccessCode));
      });
    });

    group('createDuelRoom Test', () {
      test('Yeni duel oda oluşturulabiliyor', () async {
        const hostId = 'duel-host-123';
        const hostNickname = 'Duel Host';

        final duelRoom = await firestoreService.createDuelRoom(
          hostId,
          hostNickname,
        );

        expect(duelRoom, isNotNull);
        expect(duelRoom!.id, isNotEmpty);
        expect(duelRoom.hostId, equals(hostId));
        expect(duelRoom.hostNickname, equals(hostNickname));
        expect(duelRoom.players.length, equals(1)); // Host otomatik eklenir
        expect(duelRoom.players.first.id, equals(hostId));
        expect(duelRoom.players.first.nickname, equals(hostNickname));
        expect(duelRoom.status, equals(DuelGameStatus.waiting));
      });

      test('Duel odasında host oyuncu hazır durumda', () async {
        const hostId = 'duel-host-ready';
        const hostNickname = 'Ready Host';

        final duelRoom = await firestoreService.createDuelRoom(
          hostId,
          hostNickname,
        );

        expect(duelRoom!.players.first.isReady, isTrue);
        expect(duelRoom.players.first.duelScore, equals(0));
      });
    });

    group('joinRoom Test', () {
      test('Odada oyuncu katılımı çalışıyor', () async {
        // Önce oda oluştur
        const hostId = 'join-test-host';
        const hostNickname = 'Join Test Host';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room = await firestoreService.createRoom(
          hostId,
          hostNickname,
          boardTiles,
        );

        expect(room, isNotNull);

        // Oyuncu ekle
        final player = MultiplayerPlayer(
          id: 'join-test-player',
          nickname: 'Join Test Player',
          position: 0,
          quizScore: 0,
          turnsToSkip: 0,
          isReady: true,
        );

        final joinSuccess = await firestoreService.joinRoom(
          room!.id,
          player,
        );

        expect(joinSuccess, isTrue);
      });

      test('Dolu odaya katılım reddediliyor', () async {
        // 4 oyuncu ile dolu oda oluştur
        const hostId = 'full-room-host';
        const hostNickname = 'Full Room Host';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room = await firestoreService.createRoom(
          hostId,
          hostNickname,
          boardTiles,
        );

        expect(room, isNotNull);

        // 4 oyuncu ekle (maksimum)
        for (int i = 1; i <= 4; i++) {
          final player = MultiplayerPlayer(
            id: 'player-$i',
            nickname: 'Player $i',
            position: 0,
            quizScore: 0,
            turnsToSkip: 0,
            isReady: true,
          );

          final joinSuccess = await firestoreService.joinRoom(
            room!.id,
            player,
          );

          if (i <= 4) {
            expect(joinSuccess, isTrue);
          }
        }

        // 5. oyuncu eklemeye çalış - başarısız olmalı
        final extraPlayer = MultiplayerPlayer(
          id: 'extra-player',
          nickname: 'Extra Player',
          position: 0,
          quizScore: 0,
          turnsToSkip: 0,
          isReady: true,
        );

        final extraJoinSuccess = await firestoreService.joinRoom(
          room!.id,
          extraPlayer,
        );

        expect(extraJoinSuccess, isFalse);
      });
    });

    group('joinDuelRoomByCode Test', () {
      test('Duel odaya kod ile katılım çalışıyor', () async {
        // Önce duel oda oluştur
        const hostId = 'duel-join-host';
        const hostNickname = 'Duel Join Host';

        final duelRoom = await firestoreService.createDuelRoom(
          hostId,
          hostNickname,
        );

        expect(duelRoom, isNotNull);

        // Oyuncu katıl
        const playerId = 'duel-join-player';
        const playerNickname = 'Duel Join Player';

        final joinedRoom = await firestoreService.joinDuelRoomByCode(
          duelRoom!.id, // Oda ID'sini kod olarak kullan
          playerId,
          playerNickname,
        );

        expect(joinedRoom, isNotNull);
        expect(joinedRoom!.players.length, equals(2));
        expect(joinedRoom.players.any((p) => p.id == playerId), isTrue);
        expect(joinedRoom.status, equals(DuelGameStatus.playing));
      });

      test('Dolmuş duel odaya katılım reddediliyor', () async {
        // Önce duel oda oluştur
        const hostId = 'full-duel-host';
        const hostNickname = 'Full Duel Host';

        final duelRoom = await firestoreService.createDuelRoom(
          hostId,
          hostNickname,
        );

        expect(duelRoom, isNotNull);

        // İkinci oyuncu ekle
        const playerId = 'duel-player-2';
        const playerNickname = 'Duel Player 2';

        final joinedRoom = await firestoreService.joinDuelRoomByCode(
          duelRoom!.id,
          playerId,
          playerNickname,
        );

        expect(joinedRoom, isNotNull);
        expect(joinedRoom!.players.length, equals(2));

        // Üçüncü oyuncu eklemeye çalış - başarısız olmalı
        const extraPlayerId = 'duel-extra-player';
        const extraPlayerNickname = 'Duel Extra Player';

        final extraJoin = await firestoreService.joinDuelRoomByCode(
          duelRoom.id,
          extraPlayerId,
          extraPlayerNickname,
        );

        expect(extraJoin, isNull);
      });
    });

    group('Firebase Uyumluluk Test', () {
      test('Firestore bağlantısı çalışıyor', () async {
        final db = FirebaseFirestore.instance;
        expect(db, isNotNull);

        // Basit bir collection referansı al
        final collection = db.collection('test_collection');
        expect(collection, isNotNull);
      });

      test('Oda verisi Firestore formatına uygun', () async {
        const hostId = 'firebase-test-host';
        const hostNickname = 'Firebase Test Host';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room = await firestoreService.createRoom(
          hostId,
          hostNickname,
          boardTiles,
        );

        expect(room, isNotNull);

        // Room verisini Firestore formatına çevir
        final roomData = room!.toMap();

        // Gerekli alanlar var mı kontrol et
        expect(roomData['id'], isNotNull);
        expect(roomData['hostId'], equals(hostId));
        expect(roomData['hostNickname'], equals(hostNickname));
        expect(roomData['players'], isNotNull);
        expect(roomData['roomCode'], isNotNull);
        expect(roomData['accessCode'], isNotNull);
        expect(roomData['status'], isNotNull);
        expect(roomData['createdAt'], isNotNull);
      });

      test('Real-time listener çalışıyor', () async {
        const hostId = 'listener-test-host';
        const hostNickname = 'Listener Test Host';
        final boardTiles = GameBoard().tiles.map((tile) => tile.toMap()).toList();

        final room = await firestoreService.createRoom(
          hostId,
          hostNickname,
          boardTiles,
        );

        expect(room, isNotNull);

        // Listener'ı test et
        final stream = firestoreService.listenToRoom(room!.id);
        expect(stream, isNotNull);

        // Stream'den veri almayı test et (timeout ile)
        final roomFromStream = await stream.first.timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );

        expect(roomFromStream, isNotNull);
        expect(roomFromStream!.id, equals(room.id));
      });
    });
  });
}