import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/page_templates.dart';
import '../widgets/quiz_layout.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../services/firestore_service.dart';
import '../services/profile_service.dart';
import '../services/authentication_state_service.dart';
import '../widgets/copy_to_clipboard_widget.dart';
import '../widgets/user_qr_code_widget.dart';
import '../models/board_game_models.dart';
import '../utils/firebase_logger.dart';

class BoardGamePage extends StatefulWidget {
  final String? userNickname;
  final String? roomId;
  final String? playerId;

  const BoardGamePage({super.key, this.userNickname})
      : roomId = null,
        playerId = null;

  const BoardGamePage.multiplayer({
    super.key,
    required this.userNickname,
    required this.roomId,
    required this.playerId,
  });

  @override
  State<BoardGamePage> createState() => _BoardGamePageState();
}

class _BoardGamePageState extends State<BoardGamePage> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final ProfileService _profileService = ProfileService();
  final AuthenticationStateService _authStateService = AuthenticationStateService();

  // Game state
  BoardGameRoom? _currentRoom;
  StreamSubscription<BoardGameRoom?>? _roomSubscription;
  bool _isLoading = true;
  String? _userId;
  String? _userNickname;
  String? _userAvatarUrl;
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;
  String? _createdRoomCode;

  // Game board state
  List<BoardTile> _boardTiles = [];
  List<BoardGamePlayer> _players = [];
  int _currentPlayerIndex = 0;
  bool _isGameActive = false;
  int _currentTurn = 1;
  String? _gameMessage;

  // Animations
  late AnimationController _diceController;
  late AnimationController _playerMoveController;
  late AnimationController _tileEffectController;
  int _diceValue = 1;
  bool _isRollingDice = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();

    if (widget.roomId != null && widget.playerId != null) {
      // Joining existing multiplayer game
      _joinExistingGame(widget.roomId!, widget.playerId!);
    } else {
      // Single player or room creation
      _initializeSinglePlayerGame();
    }
  }

  void _initializeAnimations() {
    _diceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _playerMoveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tileEffectController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _diceController.dispose();
    _playerMoveController.dispose();
    _tileEffectController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
          _userNickname = widget.userNickname ?? user.displayName ?? user.email?.split('@')[0] ?? 'Oyuncu';
          _userAvatarUrl = user.photoURL;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading user data: $e');
    }
  }

  void _initializeSinglePlayerGame() {
    _initializeBoard();
    _initializePlayers();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _joinExistingGame(String roomId, String playerId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Join the room
      final room = await _firestoreService.joinBoardGameRoom(roomId, playerId, _userNickname ?? 'Oyuncu');

      if (room != null) {
        _currentRoom = room;
        _listenToRoomChanges();
        _initializeBoard();
        _initializePlayersFromRoom(room);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error joining game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Odaya katılırken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _listenToRoomChanges() {
    if (_currentRoom != null) {
      _roomSubscription?.cancel();
      _roomSubscription = _firestoreService.listenToBoardGameRoom(_currentRoom!.id).listen((room) {
        if (mounted && room != null) {
          setState(() {
            _currentRoom = room;
            _players = room.players;
            _currentPlayerIndex = room.currentPlayerIndex;
            _currentTurn = room.currentTurn;
            _isGameActive = room.isGameActive;
          });
        }
      });
    }
  }

  void _initializeBoard() {
    _boardTiles = [];

    // Create a 6x6 board with environmental themes
    final tileTypes = [
      BoardTileType.energy,
      BoardTileType.water,
      BoardTileType.forest,
      BoardTileType.recycling,
      BoardTileType.transport,
      BoardTileType.carbon,
      BoardTileType.chance,
      BoardTileType.community,
    ];

    for (int i = 0; i < 36; i++) {
      final tileType = tileTypes[i % tileTypes.length];
      _boardTiles.add(BoardTile(
        id: i,
        type: tileType,
        position: i,
        title: _getTileTitle(tileType),
        description: _getTileDescription(tileType),
        points: _getTilePoints(tileType),
      ));
    }
  }

  void _initializePlayers() {
    _players = [
      BoardGamePlayer(
        id: _userId ?? 'player1',
        nickname: _userNickname ?? 'Oyuncu',
        position: 0,
        points: 0,
        avatarUrl: _userAvatarUrl,
        color: Colors.blue,
      ),
    ];
  }

  void _initializePlayersFromRoom(BoardGameRoom room) {
    _players = room.players;
  }

  Color _getPlayerColor(int index) {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    return colors[index % colors.length];
  }

  String _getTileTitle(BoardTileType type) {
    switch (type) {
      case BoardTileType.energy: return 'Enerji Tasarrufu';
      case BoardTileType.water: return 'Su Koruma';
      case BoardTileType.forest: return 'Orman';
      case BoardTileType.recycling: return 'Geri Dönüşüm';
      case BoardTileType.transport: return 'Ulaşım';
      case BoardTileType.carbon: return 'Karbon Ayak İzi';
      case BoardTileType.chance: return 'Şans';
      case BoardTileType.community: return 'Topluluk';
    }
  }

  String _getTileDescription(BoardTileType type) {
    switch (type) {
      case BoardTileType.energy: return 'LED ampul kullan, 10 puan kazan!';
      case BoardTileType.water: return 'Duş süresini kısalt, 8 puan kazan!';
      case BoardTileType.forest: return 'Ağaç dik, 15 puan kazan!';
      case BoardTileType.recycling: return 'Cam şişeyi geri dönüştür, 5 puan kazan!';
      case BoardTileType.transport: return 'Bisiklet kullan, 12 puan kazan!';
      case BoardTileType.carbon: return 'Elektrikli araç tercih et, 20 puan kazan!';
      case BoardTileType.chance: return 'Şans kartı çek!';
      case BoardTileType.community: return 'Topluluk görevini yerine getir!';
    }
  }

  int _getTilePoints(BoardTileType type) {
    switch (type) {
      case BoardTileType.energy: return 10;
      case BoardTileType.water: return 8;
      case BoardTileType.forest: return 15;
      case BoardTileType.recycling: return 5;
      case BoardTileType.transport: return 12;
      case BoardTileType.carbon: return 20;
      case BoardTileType.chance: return 0;
      case BoardTileType.community: return 0;
    }
  }

  Future<void> _createRoom() async {
    setState(() => _isCreatingRoom = true);
    try {
      final playerId = await _authStateService.getGamePlayerId();
      final playerNickname = await _authStateService.getGameNickname();

      final room = await _firestoreService.createBoardGameRoom(playerId, playerNickname);

      if (room != null && mounted) {
        setState(() {
          _createdRoomCode = room.id;
          _currentRoom = room;
        });

        FirebaseLogger.logPlayerAction(roomId: room.id, playerId: playerId, nickname: playerNickname, action: 'CREATE_BOARD_GAME_ROOM', success: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(mainAxisSize: MainAxisSize.min, children: [
              Expanded(child: Text('Oda oluşturuldu! Kod: ${room.id}')),
              SizedBox(width: DesignSystem.spacingS),
              CopyToClipboardWidget(
                textToCopy: room.id,
                successMessage: 'Oda kodu kopyalandı!',
                iconColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                  child: const Icon(Icons.copy, size: 16, color: Colors.white),
                ),
              ),
            ]),
            backgroundColor: ThemeColors.getSuccessColor(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oda oluşturulurken hata: $e'),
          backgroundColor: ThemeColors.getErrorColor(context),
        ),
      );
    } finally {
      setState(() => _isCreatingRoom = false);
    }
  }

  void _showJoinRoomDialog() {
    final roomIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
        backgroundColor: ThemeColors.getDialogBackground(context),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.login, color: ThemeColors.getPrimaryButtonColor(context), size: 24),
              ),
              SizedBox(width: DesignSystem.spacingM),
              Expanded(
                child: Text(
                  'Tahta Oyununa Katıl',
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
            SizedBox(height: DesignSystem.spacingL),
            TextField(
              controller: roomIdController,
              decoration: DesignSystem.getInputDecoration(context, labelText: 'Oda Kodu', hintText: '4 haneli kodu girin').copyWith(
                prefixIcon: Icon(Icons.key, color: ThemeColors.getSecondaryText(context)),
              ),
              style: TextStyle(color: ThemeColors.getText(context)),
              maxLength: 4,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: DesignSystem.spacingL),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
                    ),
                    child: Text(
                      'İptal',
                      style: DesignSystem.getLabelLarge(context).copyWith(
                        color: ThemeColors.getSecondaryText(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final roomCode = roomIdController.text.trim();
                      if (roomCode.isEmpty || roomCode.length != 4 || !RegExp(r'^\d{4}$').hasMatch(roomCode)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Geçersiz kod formatı.')),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      _joinRoom(roomCode);
                    },
                    style: DesignSystem.getPrimaryButtonStyle(context),
                    child: const Text('Katıl'),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _joinRoom(String roomCode) async {
    setState(() => _isJoiningRoom = true);
    try {
      final playerId = await _authStateService.getGamePlayerId();
      final playerNickname = await _authStateService.getGameNickname();

      final room = await _firestoreService.joinBoardGameRoom(roomCode, playerId, playerNickname);

      if (room != null && mounted) {
        setState(() {
          _currentRoom = room;
        });
        _listenToRoomChanges();
        _initializePlayersFromRoom(room);

        FirebaseLogger.logPlayerAction(roomId: room.id, playerId: playerId, nickname: playerNickname, action: 'JOIN_BOARD_GAME_ROOM', success: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Odaya başarıyla katıldınız!'),
            backgroundColor: ThemeColors.getSuccessColor(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error joining room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Odaya katılırken hata: $e'),
          backgroundColor: ThemeColors.getErrorColor(context),
        ),
      );
    } finally {
      setState(() => _isJoiningRoom = false);
    }
  }

  Future<void> _rollDice() async {
    if (_isRollingDice || !_isGameActive) return;

    setState(() {
      _isRollingDice = true;
    });

    // Animate dice rolling
    await _diceController.forward();

    // Generate random dice value
    final random = math.Random();
    _diceValue = random.nextInt(6) + 1;

    await _diceController.reverse();

    setState(() {
      _isRollingDice = false;
    });

    // Move player
    await _movePlayer(_diceValue);
  }

  Future<void> _movePlayer(int steps) async {
    if (_players.isEmpty) return;

    final currentPlayer = _players[_currentPlayerIndex];
    final newPosition = (currentPlayer.position + steps) % _boardTiles.length;

    // Update player position
    setState(() {
      _players[_currentPlayerIndex] = BoardGamePlayer(
        id: currentPlayer.id,
        nickname: currentPlayer.nickname,
        position: newPosition,
        points: currentPlayer.points,
        avatarUrl: currentPlayer.avatarUrl,
        color: currentPlayer.color,
      );
    });

    // Animate movement
    await _playerMoveController.forward();
    await _playerMoveController.reverse();

    // Handle tile effect
    await _handleTileEffect(_boardTiles[newPosition]);

    // Next player's turn
    _nextTurn();
  }

  Future<void> _handleTileEffect(BoardTile tile) async {
    await _tileEffectController.forward();
    await _tileEffectController.reverse();

    final currentPlayer = _players[_currentPlayerIndex];
    final newPoints = currentPlayer.points + tile.points;

    setState(() {
      _players[_currentPlayerIndex] = BoardGamePlayer(
        id: currentPlayer.id,
        nickname: currentPlayer.nickname,
        position: currentPlayer.position,
        points: newPoints,
        avatarUrl: currentPlayer.avatarUrl,
        color: currentPlayer.color,
      );
      _gameMessage = '${currentPlayer.nickname}: ${tile.description} (+${tile.points} puan)';
    });

    // Update room if multiplayer
    if (_currentRoom != null) {
      await _firestoreService.updateBoardGameState(
        _currentRoom!.id,
        players: _players.map((p) => p.toMap()).toList(),
        currentPlayerIndex: _currentPlayerIndex,
        currentTurn: _currentTurn,
      );
    }
  }

  void _nextTurn() {
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
      _currentTurn++;
    });

    if (_currentRoom != null) {
      _firestoreService.updateBoardGameState(
        _currentRoom!.id,
        currentPlayerIndex: _currentPlayerIndex,
        currentTurn: _currentTurn,
      );
    }
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _gameMessage = 'Oyun başladı! İyi eğlenceler!';
    });

    if (_currentRoom != null) {
      _firestoreService.updateBoardGameState(
        _currentRoom!.id,
        isGameActive: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return QuizLayout(
        title: 'Çevre Tahta Oyunu',
        subtitle: 'Yükleniyor...',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return QuizLayout(
      title: 'Çevre Tahta Oyunu',
      subtitle: _currentRoom != null
          ? '${_players.length} oyuncu • Tur $_currentTurn'
          : 'Çevre dostu tahta oyunu',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      actions: [
        if (_currentRoom == null) ...[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isCreatingRoom ? null : _createRoom,
            tooltip: 'Oda Oluştur',
          ),
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: _isJoiningRoom ? null : _showJoinRoomDialog,
            tooltip: 'Odaya Katıl',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.qr_code),
          onPressed: () => _showQRShareDialog(context),
          tooltip: 'QR Paylaş',
        ),
      ],
      child: _currentRoom != null && _createdRoomCode != null
          ? _buildRoomCreatedView()
          : _buildGameView(),
    );
  }

  Widget _buildRoomCreatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DesignSystem.glassCard(
            context,
            padding: const EdgeInsets.all(DesignSystem.spacingXl),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spacingL),
                  decoration: BoxDecoration(
                    color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                SizedBox(height: DesignSystem.spacingL),
                Text(
                  'Oda Oluşturuldu!',
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: DesignSystem.spacingM),
                Text(
                  'Arkadaşlarınızla paylaşın',
                  style: DesignSystem.getBodyLarge(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: DesignSystem.spacingL),
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spacingL),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Oda Kodu: ',
                        style: DesignSystem.getBodyLarge(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _createdRoomCode!,
                        style: DesignSystem.getHeadlineSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                      SizedBox(width: DesignSystem.spacingM),
                      CopyToClipboardWidget(
                        textToCopy: _createdRoomCode!,
                        successMessage: 'Kod kopyalandı!',
                        iconColor: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.all(DesignSystem.spacingS),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                          ),
                          child: Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: DesignSystem.spacingL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ThemeColors.getSuccessColor(context),
                      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Oyunu Başlat',
                      style: DesignSystem.getLabelLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    return Column(
      children: [
        // Game Status
        if (_gameMessage != null)
          Container(
            margin: const EdgeInsets.all(DesignSystem.spacingM),
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: BoxDecoration(
              color: ThemeColors.getInfoColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: ThemeColors.getInfoColor(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: ThemeColors.getInfoColor(context),
                ),
                SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: Text(
                    _gameMessage!,
                    style: DesignSystem.getBodyMedium(context).copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Players Status
        Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _players.length,
            itemBuilder: (context, index) {
              final player = _players[index];
              final isCurrentPlayer = index == _currentPlayerIndex;
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentPlayer
                      ? (player.color ?? Colors.blue).withValues(alpha: 0.2)
                      : ThemeColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(
                    color: isCurrentPlayer ? (player.color ?? Colors.blue) : Colors.grey[300]!,
                    width: isCurrentPlayer ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditNicknameDialog(index),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player.nickname,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                                color: ThemeColors.getText(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: ThemeColors.getSecondaryText(context),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${player.points} puan',
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeColors.getSecondaryText(context),
                      ),
                    ),
                    Text(
                      'Pozisyon: ${player.position}',
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeColors.getSecondaryText(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Game Board
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(DesignSystem.spacingM),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _boardTiles.length,
              itemBuilder: (context, index) {
                final tile = _boardTiles[index];
                final playersOnTile = _players.where((p) => p.position == index).toList();

                return _buildBoardTile(tile, playersOnTile);
              },
            ),
          ),
        ),

        // Game Controls
        Container(
          padding: const EdgeInsets.all(DesignSystem.spacingM),
          child: Column(
            children: [
              if (!_isGameActive)
                ElevatedButton(
                  onPressed: _startGame,
                  style: DesignSystem.getPrimaryButtonStyle(context),
                  child: const Text('Oyunu Başlat'),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dice
                    GestureDetector(
                      onTap: _rollDice,
                      child: AnimatedBuilder(
                        animation: _diceController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _diceController.value * 2 * math.pi,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: ThemeColors.getPrimaryButtonColor(context),
                                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _isRollingDice ? '🎲' : '$_diceValue',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: DesignSystem.spacingL),
                    Text(
                      'Zar At',
                      style: DesignSystem.getTitleMedium(context).copyWith(
                        color: ThemeColors.getText(context),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBoardTile(BoardTile tile, List<BoardGamePlayer> playersOnTile) {
    return AnimatedBuilder(
      animation: _tileEffectController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _getTileColor(tile.type).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(DesignSystem.radiusS),
            border: Border.all(
              color: _getTileColor(tile.type),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getTileColor(tile.type).withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Tile content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTileIcon(tile.type),
                      color: Colors.white,
                      size: 20,
                    ),
                    Text(
                      '${tile.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Players on tile
              if (playersOnTile.isNotEmpty)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: playersOnTile.map((player) {
                      return Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                          color: player.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            player.nickname[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getTileColor(BoardTileType type) {
    switch (type) {
      case BoardTileType.energy: return Colors.yellow;
      case BoardTileType.water: return Colors.blue;
      case BoardTileType.forest: return Colors.green;
      case BoardTileType.recycling: return Colors.orange;
      case BoardTileType.transport: return Colors.purple;
      case BoardTileType.carbon: return Colors.red;
      case BoardTileType.chance: return Colors.pink;
      case BoardTileType.community: return Colors.teal;
    }
  }

  IconData _getTileIcon(BoardTileType type) {
    switch (type) {
      case BoardTileType.energy: return Icons.flash_on;
      case BoardTileType.water: return Icons.water_drop;
      case BoardTileType.forest: return Icons.forest;
      case BoardTileType.recycling: return Icons.recycling;
      case BoardTileType.transport: return Icons.directions_car;
      case BoardTileType.carbon: return Icons.eco;
      case BoardTileType.chance: return Icons.casino;
      case BoardTileType.community: return Icons.people;
    }
  }

  void _showEditNicknameDialog(int playerIndex) {
    final player = _players[playerIndex];
    final isCurrentUser = player.id == _userId;

    // Only allow editing your own nickname or in single player mode
    if (!isCurrentUser && _currentRoom != null) return;

    final nicknameController = TextEditingController(text: player.nickname);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
        backgroundColor: ThemeColors.getDialogBackground(context),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: ThemeColors.getPrimaryButtonColor(context), size: 24),
              ),
              SizedBox(width: DesignSystem.spacingM),
              Expanded(
                child: Text(
                  'Takma Adı Düzenle',
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
            SizedBox(height: DesignSystem.spacingL),
            TextField(
              controller: nicknameController,
              decoration: DesignSystem.getInputDecoration(context, labelText: 'Yeni Takma Ad', hintText: 'Takma adınızı girin').copyWith(
                prefixIcon: Icon(Icons.person, color: ThemeColors.getSecondaryText(context)),
              ),
              style: TextStyle(color: ThemeColors.getText(context)),
              maxLength: 20,
            ),
            SizedBox(height: DesignSystem.spacingL),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
                    ),
                    child: Text(
                      'İptal',
                      style: DesignSystem.getLabelLarge(context).copyWith(
                        color: ThemeColors.getSecondaryText(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final newNickname = nicknameController.text.trim();
                      if (newNickname.isNotEmpty && newNickname != player.nickname) {
                        _updatePlayerNickname(playerIndex, newNickname);
                      }
                      Navigator.of(context).pop();
                    },
                    style: DesignSystem.getPrimaryButtonStyle(context),
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  void _updatePlayerNickname(int playerIndex, String newNickname) {
    setState(() {
      _players[playerIndex] = BoardGamePlayer(
        id: _players[playerIndex].id,
        nickname: newNickname,
        position: _players[playerIndex].position,
        points: _players[playerIndex].points,
        avatarUrl: _players[playerIndex].avatarUrl,
        color: _players[playerIndex].color,
      );

      // Update user nickname if it's the current user
      if (_players[playerIndex].id == _userId) {
        _userNickname = newNickname;
      }
    });

    // Update room if multiplayer
    if (_currentRoom != null) {
      _firestoreService.updateBoardGameState(
        _currentRoom!.id,
        players: _players.map((p) => p.toMap()).toList(),
      );
    }
  }

  void _showQRShareDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
        backgroundColor: ThemeColors.getDialogBackground(context),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: UserQRCodeWidget(
            userId: user.uid,
            nickname: _userNickname ?? 'Oyuncu',
          ),
        ),
      ),
    );
  }
}

