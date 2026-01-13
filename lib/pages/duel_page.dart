// lib/pages/duel_page.dart
import 'package:flutter/material.dart';
import '../services/duel_game_logic.dart';
import '../services/firestore_service.dart';
import '../services/authentication_state_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/duel_invite_dialog.dart';
import '../widgets/copy_to_clipboard_widget.dart';
import '../widgets/home_button.dart';

class DuelPage extends StatefulWidget {
  const DuelPage({super.key});

  @override
  State<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends State<DuelPage> {
  final DuelGameLogic _duelLogic = DuelGameLogic();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _answerController = TextEditingController();
  final AuthenticationStateService _authStateService =
      AuthenticationStateService();

  DuelRoom? _currentRoom;
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;

  /// Get current player ID from global authentication state
  Future<String> _getPlayerId() async {
    return await _authStateService.getGamePlayerId();
  }

  /// Get current player nickname from global authentication state
  Future<String> _getPlayerNickname() async {
    return await _authStateService.getGameNickname();
  }

  @override
  void initState() {
    super.initState();
    _duelLogic.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _duelLogic.removeListener(_onGameStateChanged);
    _duelLogic.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {
      _currentRoom = _duelLogic.currentRoom;
    });
  }

  Future<void> _createDuelRoom() async {
    setState(() => _isCreatingRoom = true);

    try {
      // Create a simple board for duel mode
      final boardTiles = List.generate(
          20,
          (index) => {
                'type': index == 0
                    ? 'start'
                    : index == 19
                        ? 'finish'
                        : 'quiz',
                'position': index,
              });

      // Get current player info from global authentication state
      final playerId = await _getPlayerId();
      final playerNickname = await _getPlayerNickname();

      final room = await _firestoreService.createRoom(
        playerId,
        playerNickname,
        boardTiles,
      );

      if (room != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text('Oda oluşturuldu! Oda Kodu: ${room.id}'),
                ),
                const SizedBox(width: 8),
                CopyToClipboardWidget(
                  textToCopy: room.id,
                  successMessage: 'Oda kodu kopyalandı!',
                  iconColor: Colors.white,
                  child: const Icon(Icons.copy, size: 16, color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oda oluşturulurken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCreatingRoom = false);
    }
  }

  Future<void> _joinDuelRoom(String roomId) async {
    setState(() => _isJoiningRoom = true);

    try {
      // Get current player info from global authentication state
      final playerId = await _getPlayerId();
      final playerNickname = await _getPlayerNickname();

      // Create player object for duel
      _createPlayerForDuel(playerId, playerNickname);

      // Note: This would need to be adapted to work with existing room structure
      // For now, we'll show a simplified message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oda katılma özelliği geliştiriliyor...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odaya katılırken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isJoiningRoom = false);
    }
  }

  void _createPlayerForDuel(String playerId, String playerNickname) {
    // Create DuelPlayer for use in duel operations
    DuelPlayer(
      id: playerId,
      nickname: playerNickname,
      duelScore: 0,
      isReady: true,
    );
    // Player initialized for duel operations
  }
  

  void _showJoinRoomDialog() {
    final roomIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: ThemeColors.getDialogBackground(context),
        title: Text(
          'Odaya Katıl',
          style: TextStyle(color: ThemeColors.getText(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login,
              size: 64,
              color: ThemeColors.getGreen(context),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomIdController,
              decoration: InputDecoration(
                labelText: 'Oda Kodu',
                filled: true,
                fillColor: ThemeColors.getInputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                ),
              ),
              style: TextStyle(color: ThemeColors.getText(context)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: TextStyle(color: ThemeColors.getSecondaryText(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (roomIdController.text.isNotEmpty) {
                Navigator.of(context).pop();
                _joinDuelRoom(roomIdController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getGreen(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Katıl'),
          ),
        ],
      ),
    );
  }

  void _submitAnswer() async {
    if (_answerController.text.trim().isNotEmpty) {
      final playerId = await _getPlayerId();
      _duelLogic.submitAnswer(_answerController.text.trim(), playerId);
      _answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRoom == null) {
      return _buildLobbyView();
    } else {
      return _buildGameView();
    }
  }

  Widget _buildLobbyView() {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: const Text('Düello Modu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 100,
                    color: ThemeColors.getGreen(context),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Düello Modu',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getText(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'İki oyuncu arasında hızlı cevap yarışı!',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCreatingRoom ? null : _createDuelRoom,
                      icon: _isCreatingRoom
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add),
                      label: const Text('Oda Oluştur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getGreen(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isJoiningRoom ? null : _showJoinRoomDialog,
                      icon: _isJoiningRoom
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.login),
                      label: const Text('Odaya Katıl'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Invite Friends Button
                  if (_currentRoom != null && _currentRoom!.players.length == 1)
                    FutureBuilder<String>(
                      future: _getPlayerId(),
                      builder: (context, playerIdSnapshot) {
                        return FutureBuilder<String>(
                          future: _getPlayerNickname(),
                          builder: (context, playerNicknameSnapshot) {
                            if (playerIdSnapshot.hasData &&
                                playerNicknameSnapshot.hasData) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => DuelInviteDialog(
                                        roomId: _currentRoom!.id,
                                        hostId: playerIdSnapshot.data!,
                                        hostNickname:
                                            playerNicknameSnapshot.data!,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.person_add),
                                  label: const Text('Arkadaşlarını Davet Et'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9800),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.getCardBackgroundLight(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info,
                          color: ThemeColors.getGreen(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nasıl Oynanır?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.getText(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 2 oyuncu gereklidir\n• 5 soru sorulacak\n• En çok doğru cevap kazanır\n• Hız bonusu ile puan kazanın\n• 15 saniye süre sınırı',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColors.getSecondaryText(context),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
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

  Widget _buildGameView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Düello - ${_currentRoom?.gameStatusText ?? ''}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Game Status
                  _buildGameStatus(),

                  // Current Question
                  if (_duelLogic.currentQuestion != null) _buildQuestionCard(),

                  // Answer Input
                  if (_duelLogic.isGameActive) _buildAnswerInput(),

                  // Score Board
                  _buildScoreBoard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                'Süre',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: 12,
                ),
              ),
              Text(
                _duelLogic.timeElapsedFormatted,
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Soru',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: 12,
                ),
              ),
              Text(
                '${_duelLogic.currentQuestionIndex}/5',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _duelLogic.currentQuestion!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${_duelLogic.currentQuestionIndex}',
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.text,
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Cevabınız',
                filled: true,
                fillColor: ThemeColors.getInputBackground(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ThemeColors.getBorder(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: ThemeColors.getGreen(context), width: 2),
                ),
              ),
              style: TextStyle(color: ThemeColors.getText(context)),
              onSubmitted: (_) => _submitAnswer(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getGreen(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    if (_currentRoom == null || _currentRoom!.players.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<String>(
      future: _getPlayerId(),
      builder: (context, playerIdSnapshot) {
        if (!playerIdSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Skor Tablosu',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._currentRoom!.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: player.id == playerIdSnapshot.data!
                          ? ThemeColors.getGreen(context).withValues(alpha: 0.2)
                          : ThemeColors.getCardBackgroundLight(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: player.id == playerIdSnapshot.data!
                            ? ThemeColors.getGreen(context)
                            : ThemeColors.getBorder(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          player.nickname,
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${player.duelScore} puan',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
