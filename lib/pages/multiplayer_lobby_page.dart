// lib/pages/multiplayer_lobby_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../services/firestore_service.dart';
import '../services/authentication_state_service.dart';
import '../services/duel_game_logic.dart';
import '../theme/theme_colors.dart';
import '../widgets/copy_to_clipboard_widget.dart';
import '../widgets/home_button.dart';
import '../utils/firebase_logger.dart';
import 'duel_page.dart';

class MultiplayerLobbyPage extends StatefulWidget {
  final String userNickname;

  const MultiplayerLobbyPage({super.key, required this.userNickname});

  @override
  State<MultiplayerLobbyPage> createState() => _MultiplayerLobbyPageState();
}

class _MultiplayerLobbyPageState extends State<MultiplayerLobbyPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthenticationStateService _authStateService =
      AuthenticationStateService();

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

  Future<void> _createDuelRoom() async {
    setState(() => _isCreatingRoom = true);

    try {
      // Get current player info from global authentication state
      final playerId = await _getPlayerId();
      final playerNickname = await _getPlayerNickname();

      final room = await _firestoreService.createDuelRoom(
        playerId,
        playerNickname,
      );

      if (room != null && mounted) {
        // Navigate to duel page with the created room
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DuelPage(initialRoom: room),
          ),
        );

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

  Future<void> _joinDuelRoom(String roomCode) async {
    if (kDebugMode) {
      debugPrint('🎯 [MULTIPLAYER_LOBBY] Starting room join process for code: $roomCode');
    }

    setState(() => _isJoiningRoom = true);

    try {
      // Get current player info from global authentication state
      final playerId = await _getPlayerId();
      final playerNickname = await _getPlayerNickname();

      if (kDebugMode) {
        debugPrint('🔄 [MULTIPLAYER_LOBBY] Attempting to join duel room with code: $roomCode for player: $playerNickname ($playerId)');
      }

      // Call the backend service with timeout
      final room = await _firestoreService.joinDuelRoomByCode(
        roomCode,
        playerId,
        playerNickname,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) debugPrint('⏰ [MULTIPLAYER_LOBBY] Timeout: Room join request timed out after 10 seconds');
          throw Exception('Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.');
        },
      );

      if (room != null && mounted) {
        if (kDebugMode) {
          debugPrint('✅ [MULTIPLAYER_LOBBY] Successfully joined duel room: ${room.id}');
          debugPrint('📊 [MULTIPLAYER_LOBBY] Room details - Host: ${room.hostNickname}, Players: ${room.players.length}, Status: ${room.status}');
        }

        // Log the successful join
        FirebaseLogger.logPlayerAction(
          roomId: room.id,
          playerId: playerId,
          nickname: playerNickname,
          action: 'JOIN_ROOM',
          success: true,
        );

        // Navigate to duel page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DuelPage(initialRoom: room),
          ),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odaya başarıyla katıldınız!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (kDebugMode) debugPrint('❌ [MULTIPLAYER_LOBBY] Failed to join room: Room is null');
        throw Exception('Oda katılımı başarısız oldu.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 [MULTIPLAYER_LOBBY] Error joining duel room: $e');
        debugPrint('📋 [MULTIPLAYER_LOBBY] Error type: ${e.runtimeType}');
      }

      String errorMessage = 'Odaya katılırken hata oluştu';

      if (e.toString().contains('not found') || e.toString().contains('null')) {
        errorMessage = 'Oda bulunamadı. Lütfen oda kodunu kontrol edin.';
      } else if (e.toString().contains('full')) {
        errorMessage = 'Oda dolu. Başka bir odaya katılmayı deneyin.';
      } else if (e.toString().contains('timeout') || e.toString().contains('zaman aşımı')) {
        errorMessage = 'Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('already in room')) {
        errorMessage = 'Zaten bu odadasınız.';
      }

      if (kDebugMode) {
        debugPrint('💬 [MULTIPLAYER_LOBBY] Showing error message: $errorMessage');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoiningRoom = false);
      }
    }
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
              final roomCode = roomIdController.text.trim();
              if (roomCode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen oda kodunu girin')),
                );
                return;
              }
              if (roomCode.length != 4 || !RegExp(r'^\d{4}$').hasMatch(roomCode)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz kod formatı. 4 haneli sayı girin.')),
                );
                return;
              }
              Navigator.of(context).pop();
              _joinDuelRoom(roomCode);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: const Text('Çok Oyunculu Lobi'),
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
                    Icons.group,
                    size: 100,
                    color: ThemeColors.getGreen(context),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Çok Oyunculu Mod',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.getText(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '2 oyuncu arasında hızlı cevap yarışı!',
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
}
