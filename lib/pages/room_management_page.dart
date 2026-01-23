// lib/pages/room_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game_board.dart';
import '../services/firestore_service.dart';
import 'board_game_page.dart';
import '../utils/room_code_generator.dart';
import '../widgets/friend_invite_dialog.dart';
import '../widgets/game_invitation_list.dart';
import '../widgets/copy_to_clipboard_widget.dart';
// import '../widgets/home_button.dart';
import '../widgets/page_templates.dart';
import '../theme/design_system.dart';
import '../theme/theme_colors.dart';

class RoomManagementPage extends StatefulWidget {
  final String userNickname;

  const RoomManagementPage({super.key, required this.userNickname});

  @override
  State<RoomManagementPage> createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _accessCodeController = TextEditingController();
  final TextEditingController _customRoomCodeController =
      TextEditingController();
  final TextEditingController _customAccessCodeController =
      TextEditingController();

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
  Future<void> _createRoom(
      {String? customRoomCode, String? customAccessCode}) async {
    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        debugPrint('Starting room creation for: ${widget.userNickname}');
      }

      final gameBoard = GameBoard();
      final boardTiles = gameBoard.tiles
          .map((tile) => {
                'index': tile.index,
                'type': tile.type.toString().split('.').last,
                'label': tile.label,
              })
          .toList();

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
        if (kDebugMode) {
          debugPrint('Room created successfully, joining as host...');
        }

        final success = await _firestoreService.joinRoom(room.id, player);
        if (success) {
          if (kDebugMode) {
            debugPrint('Successfully joined created room, navigating to game');
          }

          setState(() {
            _currentRoom = room;
            _isHost = true;
          });

          _showRoomDetailsDialog(room, customAccessCode);
        } else {
          if (kDebugMode) debugPrint('Failed to join the created room');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Oda oluşturuldu ama katılım başarısız oldu. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (kDebugMode) debugPrint('Room creation failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Oda oluşturulamadı. İnternet bağlantınızı kontrol edin ve tekrar deneyin.'),
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
        const SnackBar(
            content: Text('Geçersiz kod formatı. 4 haneli kod girin.')),
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

      final room =
          await _firestoreService.joinRoomByAccessCode(accessCode, player);

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
            DesignSystem.card(
              context,
              backgroundColor: Colors.blue.shade50,
              padding: const EdgeInsets.all(DesignSystem.spacingL),
              child: Column(
                children: [
                  Text(
                    'Oda Bilgileri',
                    style: DesignSystem.getTitleMedium(context),
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Oda Kodu:', style: DesignSystem.getBodyLarge(context)),
                      Flexible(
                        child: CopyToClipboardWidget(
                          textToCopy: room.roomCode,
                          successMessage: 'Oda kodu kopyalandı!',
                          child: Text(
                            room.roomCode,
                            style: DesignSystem.getBodyLarge(context).copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Erişim Kodu:', style: DesignSystem.getBodyLarge(context)),
                      Flexible(
                        child: CopyToClipboardWidget(
                          textToCopy: accessCode,
                          successMessage: 'Erişim kodu kopyalandı!',
                          child: SelectableText(
                            accessCode,
                            style: DesignSystem.getBodyLarge(context).copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  Text(
                    'Bu kodları arkadaşlarınızla paylaşabilirsiniz!',
                    style: DesignSystem.getBodySmall(context).copyWith(
                      color: ThemeColors.getSecondaryText(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignSystem.spacingM),
            Text(
              'Arkadaşlarınızı davet etmek için paylaşın:',
              style: DesignSystem.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShareButton(
                  icon: Icons.share,
                  label: 'Paylaş',
                  onPressed: () => _shareRoomCode(room, accessCode),
                ),
                const SizedBox(width: DesignSystem.spacingS),
                _buildShareButton(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  onPressed: () => _shareViaWhatsApp(room, accessCode),
                ),
                const SizedBox(width: DesignSystem.spacingS),
                _buildShareButton(
                  icon: Icons.email,
                  label: 'E-posta',
                  onPressed: () => _shareViaEmail(room, accessCode),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToGame(room, accessCode);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, size: 18, color: Colors.green),
                const SizedBox(width: 4),
                Text('Oyuna Başla',
                    style: TextStyle(color: Colors.green.shade700)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Daha Sonra', style: TextStyle(color: Colors.blue)),
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
          content:
              Text('Oda ${newStatus ? 'aktif' : 'pasif'} olarak işaretlendi'),
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

              if (roomCode.isNotEmpty &&
                  !RoomCodeGenerator.isValidRoomCode(roomCode)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz oda kodu formatı')),
                );
                return;
              }

              if (accessCode.isNotEmpty &&
                  !RoomCodeGenerator.isValidAccessCode(accessCode)) {
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
      appBar: StandardAppBar(
        title: const Text('Oda Yönetimi'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          if (_currentRoom != null && _isHost) ...[
            IconButton(
              icon:
                  Icon(_currentRoom!.isActive ? Icons.pause : Icons.play_arrow),
              onPressed: _toggleRoomStatus,
              tooltip: _currentRoom!.isActive
                  ? 'Odayı Pasifleştir'
                  : 'Odayı Aktifleştir',
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showFriendInviteDialog,
              tooltip: 'Arkadaş Davet Et (User ID ile)',
            ),
          ],
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: Container(
          decoration: DesignSystem.getPageContainerDecoration(context),
          padding: const EdgeInsets.all(DesignSystem.spacingM),
          child: _isLoading
              ? DesignSystem.loadingIndicator(context, message: 'Oda yükleniyor...')
              : DesignSystem.responsiveContainer(
                  context,
                  mobile: _buildRoomManagementContent(context),
                  tablet: _buildRoomManagementContent(context),
                  desktop: _buildRoomManagementContent(context),
                  maxWidth: 600,
                ),
        ),
      ),
    );
  }

  Widget _buildRoomManagementContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesignSystem.card(
          context,
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          child: Column(
            children: [
              Text(
                'Hoş Geldin, ${widget.userNickname}!',
                style: DesignSystem.getTitleMedium(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingM),
              ElevatedButton.icon(
                onPressed: _createRoom,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Oda Oluştur'),
                style: DesignSystem.getPrimaryButtonStyle(context),
              ),
              const SizedBox(height: DesignSystem.spacingS),
              TextButton.icon(
                onPressed: _showCustomRoomDialog,
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('Özel Kod ile Oluştur'),
                style: DesignSystem.getTextButtonStyle(context).copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    ThemeColors.getSecondaryButtonColor(context).withValues(alpha: 0.1),
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    ThemeColors.getSecondaryButtonColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignSystem.spacingM),
        DesignSystem.card(
          context,
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Erişim Kodu ile Katıl',
                style: DesignSystem.getTitleMedium(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingM),
              TextField(
                controller: _accessCodeController,
                decoration: DesignSystem.getInputDecoration(
                  context,
                  labelText: '4 Haneli Erişim Kodu',
                  prefixIcon: const Icon(Icons.key),
                ),
                style: DesignSystem.getBodyLarge(context),
                maxLength: 4,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: DesignSystem.spacingM),
              ElevatedButton(
                onPressed: _joinRoomByAccessCode,
                style: DesignSystem.getSecondaryButtonStyle(context),
                child: const Text('Odaya Katıl'),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignSystem.spacingM),
        DesignSystem.card(
          context,
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bekleyen Oyun Davetleri',
                style: DesignSystem.getTitleMedium(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingM),
              GameInvitationList(),
            ],
          ),
        ),
        const SizedBox(height: DesignSystem.spacingM),
        DesignSystem.card(
          context,
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aktif Odalar',
                style: DesignSystem.getTitleMedium(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingM),
              FutureBuilder<List<GameRoom>>(
                future: _firestoreService.getActiveRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DesignSystem.loadingIndicator(context);
                  }

                  if (snapshot.hasError) {
                    return DesignSystem.errorState(
                      context,
                      message: 'Aktif odalar yüklenirken hata oluştu',
                      onRetry: () => setState(() {}),
                    );
                  }

                  final activeRooms = snapshot.data ?? [];

                  if (activeRooms.isEmpty) {
                    return DesignSystem.emptyState(
                      context,
                      message: 'Aktif oda bulunamadı',
                      icon: Icons.meeting_room,
                    );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: activeRooms.length,
                      itemBuilder: (context, index) {
                        final room = activeRooms[index];
                        return DesignSystem.card(
                          context,
                          margin: const EdgeInsets.only(bottom: DesignSystem.spacingS),
                          padding: const EdgeInsets.all(DesignSystem.spacingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${room.hostNickname}\'ın Odası',
                                style: DesignSystem.getBodyLarge(context),
                              ),
                              const SizedBox(height: DesignSystem.spacingXs),
                              Text(
                                '${room.players.length}/4 oyuncu',
                                style: DesignSystem.getBodySmall(context).copyWith(
                                  color: ThemeColors.getSecondaryText(context),
                                ),
                              ),
                              const SizedBox(height: DesignSystem.spacingXs),
                              CopyToClipboardWidget(
                                textToCopy: room.roomCode,
                                successMessage: 'Oda kodu kopyalandı!',
                                iconSize: 14,
                                child: Text(
                                  'Kod: ${room.roomCode}',
                                  style: DesignSystem.getBodySmall(context).copyWith(
                                    color: ThemeColors.getSecondaryText(context),
                                  ),
                                ),
                              ),
                              const SizedBox(height: DesignSystem.spacingS),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: room.players.length >= 4
                                      ? null
                                      : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Bu odaya katılmak için kod: ${room.accessCode}'),
                                              backgroundColor: Colors.blue,
                                            ),
                                          );
                                        },
                                  style: DesignSystem.getAccentButtonStyle(context).copyWith(
                                    minimumSize: WidgetStateProperty.all(const Size(80, 36)),
                                  ),
                                  child: const Text('Kod Gör'),
                                ),
                              ),
                            ],
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
      ],
    );
  }

  /// Paylaşım butonu widget'ı
  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Genel paylaşım
  Future<void> _shareRoomCode(GameRoom room, String accessCode) async {
    final shareText = '''
🎮 Karbonson Oyun Odası!

Oda Sahibi: ${room.hostNickname}
Oda Kodu: ${room.roomCode}
Erişim Kodu: $accessCode

Arkadaşınla birlikte çevre bilincini artıracak eğlenceli bir oyun oyna!

#Karbonson #ÇevreBilinci
    ''';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (kDebugMode) debugPrint('Paylaşım hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşım sırasında hata oluştu')),
      );
    }
  }

  /// WhatsApp ile paylaşım
  Future<void> _shareViaWhatsApp(GameRoom room, String accessCode) async {
    final message = '''
🎮 Karbonson Oyun Odası!

Oda Sahibi: ${room.hostNickname}
Oda Kodu: ${room.roomCode}
Erişim Kodu: $accessCode

Arkadaşınla birlikte çevre bilincini artıracak eğlenceli bir oyun oyna!

#Karbonson #ÇevreBilinci
    ''';

    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        // WhatsApp yüklü değilse genel paylaşım
        await _shareRoomCode(room, accessCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('WhatsApp paylaşım hatası: $e');
      await _shareRoomCode(room, accessCode);
    }
  }

  /// E-posta ile paylaşım
  Future<void> _shareViaEmail(GameRoom room, String accessCode) async {
    final subject = 'Karbonson Oyun Daveti - ${room.hostNickname}';
    final body = '''
Merhaba!

${room.hostNickname} seni Karbonson oyun odasına davet ediyor!

Oda Bilgileri:
- Oda Sahibi: ${room.hostNickname}
- Oda Kodu: ${room.roomCode}
- Erişim Kodu: $accessCode

Uygulamada "Odaya Katıl" bölümüne gidip erişim kodunu girerek oyuna katılabilirsin.

Birlikte çevre bilincini artıracak eğlenceli bir oyun oynayalım!

#Karbonson #ÇevreBilinci
    ''';

    final emailUrl = 'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    try {
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        // E-posta uygulaması yoksa genel paylaşım
        await _shareRoomCode(room, accessCode);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('E-posta paylaşım hatası: $e');
      await _shareRoomCode(room, accessCode);
    }
  }

  /// Oyuna geçiş
  void _navigateToGame(GameRoom room, String accessCode) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BoardGamePage.multiplayer(
          userNickname: widget.userNickname,
          roomId: room.id,
          playerId: const Uuid().v4(), // Host için yeni player ID
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
