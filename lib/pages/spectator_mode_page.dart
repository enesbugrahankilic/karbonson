import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/spectator_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/quiz_layout.dart';

/// Spectator Mode Page - Watch live games and interact with other spectators
class SpectatorModePage extends StatefulWidget {
  SpectatorModePage({super.key});

  @override
  State<SpectatorModePage> createState() => _SpectatorModePageState();
}

class _SpectatorModePageState extends State<SpectatorModePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SpectatorService _spectatorService = SpectatorService.instance;

  // State
  List<LiveGameInfo> _activeGames = [];
  List<GameReplay> _replays = [];
  bool _isLoading = true;
  String? _userId;
  String? _userNickname;
  String? _userAvatarUrl;

  // Active game watching state
  LiveGameState? _currentGameState;
  List<SpectatorChatMessage> _chatMessages = [];
  List<Spectator> _spectators = [];
  String? _watchingGameId;

  // Controllers
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // Stream subscriptions
  dynamic _activeGamesSubscription;
  dynamic _gameStateSubscription;
  dynamic _chatSubscription;
  dynamic _reactionsSubscription;
  dynamic _spectatorsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _startListeningToActiveGames();
    _loadReplays();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _stopAllListening();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
          _userNickname = user.displayName ?? user.email?.split('@')[0] ?? 'İzleyici';
          _userAvatarUrl = user.photoURL;
        });
      } else {
        // Use a guest ID if not authenticated
        setState(() {
          _userId = const Uuid().v4();
          _userNickname = 'Misafir İzleyici';
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading user data: $e');
      setState(() {
        _userId = const Uuid().v4();
        _userNickname = 'İzleyici';
      });
    }
  }

  void _startListeningToActiveGames() {
    _activeGamesSubscription =
        _spectatorService.activeGamesStream.listen((games) {
      if (mounted) {
        setState(() {
          _activeGames = games;
          _isLoading = false;
        });
      }
    });

    _spectatorService.startListeningToActiveGames();
  }

  Future<void> _loadReplays() async {
    try {
      final replays = await _spectatorService.getAvailableReplays();
      if (mounted) {
        setState(() {
          _replays = replays;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading replays: $e');
    }
  }

  void _stopAllListening() {
    _activeGamesSubscription?.cancel();
    _gameStateSubscription?.cancel();
    _chatSubscription?.cancel();
    _reactionsSubscription?.cancel();
    _spectatorsSubscription?.cancel();

    _spectatorService.stopListeningToActiveGames();
    _spectatorService.stopWatchingGameState();
    _spectatorService.stopListeningToSpectatorChat();
    _spectatorService.stopListeningToEmojiReactions();
    _spectatorService.stopListeningToSpectators();
  }

  Future<void> _watchGame(LiveGameInfo game) async {
    if (_userId == null || _userNickname == null) return;

    try {
      // Join as spectator
      await _spectatorService.joinAsSpectator(
        game.id,
        _userId!,
        _userNickname!,
        avatarUrl: _userAvatarUrl,
      );

      // Start listening to game state
      await _spectatorService.watchGameState(game.id);

      // Listen to streams
      _gameStateSubscription =
          _spectatorService.gameStateStream.listen((state) {
        if (mounted && state != null) {
          setState(() {
            _currentGameState = state;
            _watchingGameId = game.id;
          });
        }
      });

      _chatSubscription =
          _spectatorService.chatMessagesStream.listen((messages) {
        if (mounted) {
          setState(() {
            _chatMessages = messages;
          });
          // Scroll to bottom
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_chatScrollController.hasClients) {
              _chatScrollController.jumpTo(
                _chatScrollController.position.maxScrollExtent,
              );
            }
          });
        }
      });

      _reactionsSubscription =
          _spectatorService.reactionsStream.listen((reactions) {
        if (mounted) {
          // Reactions handled internally by the service
          setState(() {});
        }
      });

      _spectatorsSubscription =
          _spectatorService.spectatorsStream.listen((spectators) {
        if (mounted) {
          setState(() {
            _spectators = spectators;
          });
        }
      });

      // Start listening to all
      _spectatorService.listenToSpectatorChat(game.id);
      _spectatorService.startListeningToEmojiReactions(game.id);
      _spectatorService.listenToSpectators(game.id);

      // Switch to watching view
      setState(() {
        _tabController.animateTo(0); // Switch to active games tab
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${game.hostNickname}\'nin oyununu izlemeye başladınız'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error watching game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oyun izlenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _leaveGame() async {
    if (_userId == null || _watchingGameId == null) return;

    try {
      await _spectatorService.leaveSpectatorMode(_watchingGameId!, _userId!);
      _stopAllListening();

      setState(() {
        _currentGameState = null;
        _watchingGameId = null;
        _chatMessages = [];
        _spectators = [];
      });

      _startListeningToActiveGames();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyun izleme modundan çıktınız'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error leaving game: $e');
    }
  }

  Future<void> _sendChatMessage() async {
    if (_userId == null ||
        _watchingGameId == null ||
        _chatController.text.trim().isEmpty) return;

    try {
      await _spectatorService.sendSpectatorMessage(
        _watchingGameId!,
        _userId!,
        _chatController.text.trim(),
      );
      _chatController.clear();
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mesaj gönderilemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendEmoji(String emoji) async {
    if (_userId == null || _watchingGameId == null) return;

    try {
      await _spectatorService.sendEmojiReaction(
        _watchingGameId!,
        _userId!,
        emoji,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending emoji: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    final title = _currentGameState != null
        ? '${_currentGameState!.hostNickname}\'nin Oyunu'
        : 'İzleyici Modu';
    final subtitle = _currentGameState != null
        ? 'Canlı oyunu izle ve diğer izleyicilerle etkileşim kur'
        : 'Canlı oyunları izle veya kayıtlı oyunları tekrar izle';

    return QuizLayout(
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      actions: [
        if (_currentGameState != null)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'İzlemeden Çık',
            onPressed: _leaveGame,
          ),
      ],
      scrollable: true,
      child: _currentGameState != null
          ? _buildWatchingView(context, isSmallScreen)
          : Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: ThemeColors.getPrimaryButtonColor(context),
                    unselectedLabelColor: ThemeColors.getSecondaryText(context),
                    indicatorColor: ThemeColors.getPrimaryButtonColor(context),
                    tabs: const [
                      Tab(text: 'Canlı Oyunlar'),
                      Tab(text: 'Tekrarlar'),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildGameListView(context, isSmallScreen),
                ),
              ],
            ),
    );
  }

  Widget _buildWatchingView(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // Game State Display
        Expanded(
          flex: 2,
          child: _buildGameStateDisplay(context, isSmallScreen),
        ),
        // Divider
        Container(
          height: 1,
          color: Colors.grey[300],
        ),
        // Chat and Reactions
        Expanded(
          flex: 1,
          child: _buildChatAndReactions(context, isSmallScreen),
        ),
      ],
    );
  }

  Widget _buildGameStateDisplay(BuildContext context, bool isSmallScreen) {
    final gameState = _currentGameState;
    if (gameState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
            ThemeColors.getAccentButtonColor(context).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Info Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ev Sahibi: ${gameState.hostNickname}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getText(context),
                    ),
                  ),
                  Text(
                    'Süre: ${gameState.timeElapsedFormatted}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                ],
              ),
              // Spectator count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text(
                      '${_spectators.length} İzleyici',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Player Indicator
          if (gameState.currentPlayer != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.getPrimaryButtonColor(context)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryButtonColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sıra: ${gameState.currentPlayer!.nickname}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.getText(context),
                          ),
                        ),
                        Text(
                          'Skor: ${gameState.currentPlayer!.quizScore} | Pozisyon: ${gameState.currentPlayer!.position}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: ThemeColors.getSecondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Last Action
          if (gameState.lastAction.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Son hareket: ${gameState.lastAction}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Players List
          Expanded(
            child: ListView.builder(
              itemCount: gameState.players.length,
              itemBuilder: (context, index) {
                final player = gameState.players[index];
                final isCurrentPlayer = index == gameState.currentPlayerIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentPlayer
                        ? ThemeColors.getPrimaryButtonColor(context)
                            .withValues(alpha: 0.2)
                        : ThemeColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentPlayer
                          ? ThemeColors.getPrimaryButtonColor(context)
                          : Colors.grey[300]!,
                      width: isCurrentPlayer ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isCurrentPlayer
                            ? ThemeColors.getPrimaryButtonColor(context)
                            : Colors.grey[400],
                        child: Text(
                          player.nickname.isNotEmpty
                              ? player.nickname[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  player.nickname,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight:
                                        isCurrentPlayer
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                    color: ThemeColors.getText(context),
                                  ),
                                ),
                                if (isCurrentPlayer) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ThemeColors.getPrimaryButtonColor(
                                          context),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'SIRA',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'Skor: ${player.quizScore} | Pozisyon: ${player.position}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: ThemeColors.getSecondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!player.isOnline)
                        const Icon(Icons.offline_bolt, color: Colors.red),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatAndReactions(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // Emoji Reactions Panel
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmojiButton('👍'),
              _buildEmojiButton('❤️'),
              _buildEmojiButton('😂'),
              _buildEmojiButton('😮'),
              _buildEmojiButton('👏'),
              _buildEmojiButton('🔥'),
            ],
          ),
        ),
        // Chat Messages
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Messages list
                Expanded(
                  child: _chatMessages.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz mesaj yok. İlk mesajı gönderin!',
                            style: TextStyle(
                              color: ThemeColors.getSecondaryText(context),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _chatScrollController,
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = _chatMessages[index];
                            return _buildChatMessage(message);
                          },
                        ),
                ),
                // Chat input
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: InputDecoration(
                            hintText: 'Mesaj gönder...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onSubmitted: (_) => _sendChatMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendChatMessage,
                        icon: const Icon(Icons.send, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiButton(String emoji) {
    return InkWell(
      onTap: () => _sendEmoji(emoji),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildChatMessage(SpectatorChatMessage message) {
    final isOwnMessage = message.spectatorId == _userId;
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOwnMessage
              ? ThemeColors.getPrimaryButtonColor(context)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: isOwnMessage ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGameListView(BuildContext context, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getCardBackground(context),
            ThemeColors.getCardBackground(context).withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildActiveGamesList(context, isSmallScreen),
                        _buildReplaysList(context, isSmallScreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveGamesList(BuildContext context, bool isSmallScreen) {
    if (_activeGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Şu anda aktif oyun yok',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                color: ThemeColors.getSecondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yakında oyuncular burada görünecek!',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: ThemeColors.getSecondaryText(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeGames.length,
      itemBuilder: (context, index) {
        final game = _activeGames[index];
        return _buildGameCard(context, game, isSmallScreen);
      },
    );
  }

  Widget _buildGameCard(
      BuildContext context, LiveGameInfo game, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _watchGame(game),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.1),
                Colors.teal.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${game.hostNickname}\'nin Oyunu',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.getText(context),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${game.playerCount} oyuncu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Watch button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.teal],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'İzle',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time elapsed
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        game.timeElapsedFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Spectator count
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 14, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        '${game.spectatorCount} izleyici',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CANLI',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplaysList(BuildContext context, bool isSmallScreen) {
    if (_replays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz tekrar yok',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                color: ThemeColors.getSecondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tamamlanan oyunlar burada görünecek',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: ThemeColors.getSecondaryText(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _replays.length,
      itemBuilder: (context, index) {
        final replay = _replays[index];
        return _buildReplayCard(context, replay, isSmallScreen);
      },
    );
  }

  Widget _buildReplayCard(
      BuildContext context, GameReplay replay, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_filled,
                color: Colors.blue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    replay.title ?? 'Oyun Tekrarı',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${replay.totalMoves} hamle • ${replay.durationInSeconds != null ? '${replay.durationInSeconds! ~/ 60}dk ${replay.durationInSeconds! % 60}sn' : "Süre belirtilmemiş"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${replay.createdAt.day}/${replay.createdAt.month}/${replay.createdAt.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tekrar oynatma yakında!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

