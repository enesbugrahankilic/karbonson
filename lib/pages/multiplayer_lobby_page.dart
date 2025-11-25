// lib/pages/multiplayer_lobby_page.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/game_board.dart';
import '../services/firestore_service.dart';
import 'board_game_page.dart';
import 'friends_page.dart';

class MultiplayerLobbyPage extends StatefulWidget {
  final String userNickname;

  const MultiplayerLobbyPage({super.key, required this.userNickname});

  @override
  State<MultiplayerLobbyPage> createState() => _MultiplayerLobbyPageState();
}

class _MultiplayerLobbyPageState extends State<MultiplayerLobbyPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _roomIdController = TextEditingController();
  List<GameRoom> _activeRooms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadActiveRooms();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveRooms() async {
    setState(() => _isLoading = true);
    _activeRooms = await _firestoreService.getActiveRooms();
    setState(() => _isLoading = false);
  }

  Future<void> _createRoom() async {
    setState(() => _isLoading = true);

    final gameBoard = GameBoard();
    final boardTiles = gameBoard.tiles.map((tile) => {
      'index': tile.index,
      'type': tile.type.toString().split('.').last,
      'label': tile.label,
    }).toList();

    final playerId = const Uuid().v4();
    final player = MultiplayerPlayer(
      id: playerId,
      nickname: widget.userNickname,
      isReady: true,
    );

    final room = await _firestoreService.createRoom(
      playerId,
      widget.userNickname,
      boardTiles,
    );

    if (room != null && mounted) {
      final success = await _firestoreService.joinRoom(room.id, player);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BoardGamePage.multiplayer(
              userNickname: widget.userNickname,
              roomId: room.id,
              playerId: playerId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oda oluşturulamadı')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oda oluşturulamadı')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _joinRoom(String roomId) async {
    setState(() => _isLoading = true);

    final playerId = const Uuid().v4();
    final player = MultiplayerPlayer(
      id: playerId,
      nickname: widget.userNickname,
    );

    final success = await _firestoreService.joinRoom(roomId, player);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BoardGamePage.multiplayer(
            userNickname: widget.userNickname,
            roomId: roomId,
            playerId: playerId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odaya katılamadınız')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çok Oyunculu Lobi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Hoş Geldin, ${widget.userNickname}!',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _createRoom,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Yeni Oda Oluştur'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: const Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FriendsPage(userNickname: widget.userNickname),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.people, color: Color(0xFF8BC34A)),
                                  label: const Text('Arkadaşlarını Yönet', style: TextStyle(color: Color(0xFF8BC34A))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Odaya Katıl',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _roomIdController,
                              decoration: const InputDecoration(
                                labelText: 'Oda ID',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                final roomId = _roomIdController.text.trim();
                                if (roomId.isNotEmpty) {
                                  _joinRoom(roomId);
                                }
                              },
                              child: const Text('Katıl'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Aktif Odalar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _activeRooms.isEmpty
                                    ? const Center(
                                        child: Text('Aktif oda bulunamadı'),
                                      )
                                    : ListView.builder(
                                        itemCount: _activeRooms.length,
                                        itemBuilder: (context, index) {
                                          final room = _activeRooms[index];
                                          return Card(
                                            child: ListTile(
                                              title: Text('${room.hostNickname}\'ın Odası'),
                                              subtitle: Text(
                                                '${room.players.length}/4 oyuncu • ${room.id}',
                                              ),
                                              trailing: ElevatedButton(
                                                onPressed: room.players.length >= 4
                                                    ? null
                                                    : () => _joinRoom(room.id),
                                                child: const Text('Katıl'),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}