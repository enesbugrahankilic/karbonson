// lib/pages/room_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:uuid/uuid.dart';
import '../models/game_board.dart';
import '../services/firestore_service.dart';
import 'board_game_page.dart';
import '../utils/room_code_generator.dart';
import '../widgets/friend_invite_dialog.dart';
import '../widgets/game_invitation_list.dart';

class RoomManagementPage extends StatefulWidget {
  final String userNickname;

  const RoomManagementPage({super.key, required this.userNickname});

  @override
  State<RoomManagementPage> createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _customRoomCodeController = TextEditingController();
  final TextEditingController _customAccessCodeController = TextEditingController();
  
  bool _isLoading = false;
  GameRoom? _currentRoom;
  bool _isHost = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _accessCodeController.dispose();
    _customRoomCodeController.dispose();
    _customAccessCodeController.dispose();
    super.dispose();
  }

  /// Oda oluşturma
  Future<void> _createRoom({String? customRoomCode, String? customAccessCode}) async {
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
        customRoomCode: customRoomCode,
        customAccessCode: customAccessCode,
      );

      if (room != null && mounted) {
        if (kDebugMode) debugPrint('Room created successfully, joining as host...');
        
        final success = await _firestoreService.joinRoom(room.id, player);
        if (success) {
          if (kDebugMode) debugPrint('Successfully joined created room, navigating to game');
          
          setState(() {
            _currentRoom = room;
            _isHost = true;
          });
          
          _showRoomDetailsDialog(room, customAccessCode);
          
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

  /// Erişim kodu ile odaya katılma
  Future<void> _joinRoomByAccessCode() async {
    final accessCode = _accessCodeController.text.trim();
    
    if (accessCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen erişim kodunu girin')),
      );
      return;
    }

    if (!RoomCodeGenerator.isValidAccessCode(accessCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz kod formatı. 4 haneli kod girin.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final playerId = const Uuid().v4();
      final player = MultiplayerPlayer(
        id: playerId,
        nickname: widget.userNickname,
      );

      final room = await _firestoreService.joinRoomByAccessCode(accessCode, player);

      if (room != null && mounted) {
        setState(() {
          _currentRoom = room;
          _isHost = false;
        });
        
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
          const SnackBar(
            content: Text('Oda bulunamadı veya dolu. Kodu kontrol edin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in _joinRoomByAccessCode: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odaya katılırken hata oluştu: ${e.toString()}'),
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

  /// Oda detaylarını gösteren dialog
  void _showRoomDetailsDialog(GameRoom room, String? customAccessCode) {
    final accessCode = customAccessCode ?? room.accessCode ?? 'N/A';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Oda Başarıyla Oluşturuldu!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Oda Bilgileri',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Oda Kodu:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(room.roomCode, style: const TextStyle(fontSize: 18, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Erişim Kodu:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SelectableText(
                          accessCode,
                          style: const TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bu kodları arkadaşlarınızla paylaşabilirsiniz!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFriendInviteDialog(); // Show friend invite dialog after room creation
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add, size: 18, color: Colors.green),
                const SizedBox(width: 4),
                Text('Arkadaş Davet Et', style: TextStyle(color: Colors.green.shade700)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  /// Oda durumunu değiştir (aktif/pasif)
  Future<void> _toggleRoomStatus() async {
    if (_currentRoom == null) return;

    final newStatus = !_currentRoom!.isActive;
    final success = await _firestoreService.updateRoomStatus(
      _currentRoom!.id,
      isActive: newStatus,
    );

    if (success) {
      setState(() {
        _currentRoom = _currentRoom!.copyWith(isActive: newStatus);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oda ${newStatus ? 'aktif' : 'pasif'} olarak işaretlendi'),
          backgroundColor: newStatus ? Colors.green : Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oda durumu güncellenirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show friend invitation dialog
  void _showFriendInviteDialog() {
    if (_currentRoom == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FriendInviteDialog(
        roomId: _currentRoom!.id,
        roomHostNickname: _currentRoom!.hostNickname,
        inviterNickname: widget.userNickname,
      ),
    );
  }

  /// Özel kod ile oda oluşturma dialogu
  void _showCustomRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Özel Kod ile Oda Oluştur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Özel kodlar belirleyebilir veya otomatik üretilmesini sağlayabilirsiniz.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customRoomCodeController,
              decoration: const InputDecoration(
                labelText: 'Oda Kodu (4 hane, boş bırakırsanız otomatik)',
                border: OutlineInputBorder(),
              ),
              maxLength: 4,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customAccessCodeController,
              decoration: const InputDecoration(
                labelText: 'Erişim Kodu (4 hane, boş bırakırsanız otomatik)',
                border: OutlineInputBorder(),
              ),
              maxLength: 4,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customRoomCodeController.clear();
              _customAccessCodeController.clear();
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final roomCode = _customRoomCodeController.text.trim();
              final accessCode = _customAccessCodeController.text.trim();
              
              if (roomCode.isNotEmpty && !RoomCodeGenerator.isValidRoomCode(roomCode)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz oda kodu formatı')),
                );
                return;
              }
              
              if (accessCode.isNotEmpty && !RoomCodeGenerator.isValidAccessCode(accessCode)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz erişim kodu formatı')),
                );
                return;
              }
              
              Navigator.pop(context);
              _createRoom(
                customRoomCode: roomCode.isEmpty ? null : roomCode,
                customAccessCode: accessCode.isEmpty ? null : accessCode,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oda Oluştur'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oda Yönetimi', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_currentRoom != null && _isHost) ...[
            IconButton(
              icon: Icon(_currentRoom!.isActive ? Icons.pause : Icons.play_arrow),
              onPressed: _toggleRoomStatus,
              tooltip: _currentRoom!.isActive ? 'Odayı Pasifleştir' : 'Odayı Aktifleştir',
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showFriendInviteDialog,
              tooltip: 'Arkadaş Davet Et (User ID ile)',
            ),
          ],
        ],
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
                                  onPressed: _showCustomRoomDialog,
                                  icon: const Icon(Icons.settings, size: 18),
                                  label: const Text('Özel Kod ile Oluştur'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    backgroundColor: Colors.green.shade50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
                                  'Erişim Kodu ile Katıl',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _accessCodeController,
                                  decoration: InputDecoration(
                                    labelText: '4 Haneli Erişim Kodu',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.key),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  maxLength: 4,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _joinRoomByAccessCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Odaya Katıl'),
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
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Bekleyen Oyun Davetleri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const GameInvitationList(),
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
                                FutureBuilder<List<GameRoom>>(
                                  future: _firestoreService.getActiveRooms(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text('Aktif odalar yüklenirken hata oluştu'),
                                      );
                                    }
                                    
                                    final activeRooms = snapshot.data ?? [];
                                    
                                    if (activeRooms.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'Aktif oda bulunamadı',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    return ConstrainedBox(
                                      constraints: const BoxConstraints(maxHeight: 300),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: activeRooms.length,
                                        itemBuilder: (context, index) {
                                          final room = activeRooms[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              title: Text(
                                                '${room.hostNickname}\'ın Odası',
                                                style: const TextStyle(color: Colors.black),
                                              ),
                                              subtitle: Text(
                                                '${room.players.length}/4 oyuncu • Kod: ${room.roomCode}',
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
                                              trailing: ElevatedButton(
                                                onPressed: room.players.length >= 4
                                                    ? null
                                                    : () {
                                                        // Oyunu başlatabilir veya özel bir işlem yapabilirsiniz
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Bu odaya katılmak için kod: ${room.accessCode}'),
                                                            backgroundColor: Colors.blue,
                                                          ),
                                                        );
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text('Kod Gör'),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
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

// Extension for easy copying with modified fields
extension GameRoomCopy on GameRoom {
  GameRoom copyWith({
    String? id,
    String? hostId,
    String? hostNickname,
    List<MultiplayerPlayer>? players,
    GameStatus? status,
    int? currentPlayerIndex,
    int? timeElapsedInSeconds,
    List<Map<String, dynamic>>? boardTiles,
    DateTime? createdAt,
    String? roomCode,
    bool? isActive,
    String? accessCode,
  }) {
    return GameRoom(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostNickname: hostNickname ?? this.hostNickname,
      players: players ?? this.players,
      status: status ?? this.status,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      timeElapsedInSeconds: timeElapsedInSeconds ?? this.timeElapsedInSeconds,
      boardTiles: boardTiles ?? this.boardTiles,
      createdAt: createdAt ?? this.createdAt,
      roomCode: roomCode ?? this.roomCode,
      isActive: isActive ?? this.isActive,
      accessCode: accessCode ?? this.accessCode,
    );
  }
}