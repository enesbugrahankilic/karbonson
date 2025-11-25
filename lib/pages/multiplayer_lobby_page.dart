// lib/pages/multiplayer_lobby_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
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

    try {
      if (kDebugMode) debugPrint('Starting room creation for: ${widget.userNickname}');

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

      if (kDebugMode) debugPrint('Created player with ID: $playerId');

      final room = await _firestoreService.createRoom(
        playerId,
        widget.userNickname,
        boardTiles,
      );

      if (room != null && mounted) {
        if (kDebugMode) debugPrint('Room created successfully, joining as host...');
        
        final success = await _firestoreService.joinRoom(room.id, player);
        if (success) {
          if (kDebugMode) debugPrint('Successfully joined created room, navigating to game');
          
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
          if (kDebugMode) debugPrint('Failed to join the created room');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oda oluşturuldu ama katılım başarısız oldu. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (kDebugMode) debugPrint('Room creation failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oda oluşturulamadı. İnternet bağlantınızı kontrol edin ve tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in _createRoom: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        title: const Text('Çok Oyunculu Lobi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  'Hoş Geldin, ${widget.userNickname}!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _createRoom,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Yeni Oda Oluştur'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                  icon: Icon(Icons.people, color: Colors.black87),
                                  label: Text('Arkadaşlarını Yönet', style: TextStyle(color: Colors.black87)),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Odaya Katıl',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _roomIdController,
                                  decoration: InputDecoration(
                                    labelText: 'Oda ID',
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    final roomId = _roomIdController.text.trim();
                                    if (roomId.isNotEmpty) {
                                      _joinRoom(roomId);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Katıl'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Aktif Odalar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                _activeRooms.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Aktif oda bulunamadı',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 300),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _activeRooms.length,
                                          itemBuilder: (context, index) {
                                            final room = _activeRooms[index];
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              child: ListTile(
                                                title: Text('${room.hostNickname}\'ın Odası', style: const TextStyle(color: Colors.black)),
                                                subtitle: Text(
                                                  '${room.players.length}/4 oyuncu • ${room.id}',
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                                trailing: ElevatedButton(
                                                  onPressed: room.players.length >= 4
                                                      ? null
                                                      : () => _joinRoom(room.id),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF4CAF50),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
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
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}