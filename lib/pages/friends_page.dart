import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../widgets/page_templates.dart';
import '../services/firestore_service.dart';
import '../models/user_data.dart';
import '../models/game_board.dart';
import '../widgets/user_qr_code_widget.dart';
import '../theme/design_system.dart';
import '../theme/theme_colors.dart';

/// QR Code Scanner Page for adding friends
class QRScannerPage extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRScannerPage({super.key, required this.onQRCodeScanned});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        _isProcessing = true;
        _processQRCode(scanData.code!);
      }
    });
  }

  Future<void> _processQRCode(String code) async {
    try {
      // QR code should contain user ID
      final userId = code.trim();

      if (userId.isNotEmpty) {
        // Call the callback
        widget.onQRCodeScanned(userId);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR kod başarıyla tarandı!')),
          );
        }

        // Go back
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Geçersiz QR kod')),
          );
          _isProcessing = false;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR kod işlenirken hata: $e')),
        );
        _isProcessing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tara'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: const Text(
              'Arkadaşınızın QR kodunu tarayın',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class FriendsPage extends StatefulWidget {
   final String? userNickname;

   const FriendsPage({super.key, this.userNickname});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addFriendController = TextEditingController();

  List<Friend> _friends = [];
  List<FriendRequest> _sentRequests = [];
  List<FriendRequest> _receivedRequests = [];
  List<UserData> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _currentUserId = '';

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _addFriendController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
        await _loadFriendsData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yüklenirken hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFriendsData() async {
    final friends = await _firestoreService.getFriends(_currentUserId);
    final sentRequests = await _firestoreService.getSentFriendRequests(_currentUserId);
    final receivedRequests = await _firestoreService.getReceivedFriendRequests(_currentUserId);

    if (mounted) {
      setState(() {
        _friends = friends;
        _sentRequests = sentRequests;
        _receivedRequests = receivedRequests;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _firestoreService.searchUsersByNickname(query);
      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _sendFriendRequest(String targetUserId, String targetNickname) async {
    try {
      final success = await _firestoreService.sendFriendRequest(
        _currentUserId,
        widget.userNickname ?? 'Kullanıcı',
        targetUserId,
        targetNickname,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$targetNickname\'a arkadaşlık isteği gönderildi')),
        );
        await _loadFriendsData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İstek gönderilemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _acceptFriendRequest(String requestId) async {
    try {
      final success = await _firestoreService.acceptFriendRequest(requestId, _currentUserId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaşlık isteği kabul edildi')),
        );
        await _loadFriendsData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İstek kabul edilemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      final success = await _firestoreService.rejectFriendRequest(requestId, _currentUserId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaşlık isteği reddedildi')),
        );
        await _loadFriendsData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İstek reddedilemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      final success = await _firestoreService.removeFriend(_currentUserId, friendId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaş silindi')),
        );
        await _loadFriendsData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arkadaş silinemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onQRCodeScanned: (userId) async {
            try {
              // Get user data by ID
              final userData = await _firestoreService.getUserProfile(userId);
              if (userData != null) {
                // Send friend request
                await _sendFriendRequest(userData.uid, userData.nickname);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kullanıcı bulunamadı')),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _showQRShareDialog() {
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
             nickname: widget.userNickname ?? 'Kullanıcı',
           ),
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
        backgroundColor: ThemeColors.getDialogBackground(context),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignSystem.spacingS),
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_add, color: ThemeColors.getPrimaryButtonColor(context), size: 24),
                  ),
                  SizedBox(width: DesignSystem.spacingM),
                  Expanded(
                    child: Text(
                      'Arkadaş Ekle',
                      style: DesignSystem.getHeadlineSmall(context).copyWith(
                        color: ThemeColors.getText(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignSystem.spacingL),
              TextField(
                controller: _addFriendController,
                decoration: DesignSystem.getInputDecoration(context, labelText: 'Kullanıcı Adı', hintText: 'Arkadaşınızın kullanıcı adını girin'),
                style: TextStyle(color: ThemeColors.getText(context)),
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
                      onPressed: () async {
                        final nickname = _addFriendController.text.trim();
                        if (nickname.isNotEmpty) {
                          Navigator.of(context).pop();
                          await _searchAndSendRequest(nickname);
                          _addFriendController.clear();
                        }
                      },
                      style: DesignSystem.getPrimaryButtonStyle(context),
                      child: const Text('Ara ve Ekle'),
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

  Future<void> _searchAndSendRequest(String nickname) async {
    try {
      final results = await _firestoreService.searchUsersByNickname(nickname);
      final exactMatch = results.where((user) => user.nickname.toLowerCase() == nickname.toLowerCase()).toList();

      if (exactMatch.isNotEmpty) {
        final user = exactMatch.first;
        await _sendFriendRequest(user.uid, user.nickname);
      } else if (results.isNotEmpty) {
        // Show suggestions
        if (mounted) {
          _showUserSuggestionsDialog(results, nickname);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"$nickname" kullanıcısı bulunamadı')),
          );
        }
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showUserSuggestionsDialog(List<UserData> suggestions, String originalQuery) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
        backgroundColor: ThemeColors.getDialogBackground(context),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"$originalQuery" için öneriler',
                style: DesignSystem.getHeadlineSmall(context).copyWith(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: DesignSystem.spacingM),
              Expanded(
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final user = suggestions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePictureUrl != null ? NetworkImage(user.profilePictureUrl!) : null,
                        child: user.profilePictureUrl == null ? Text(user.nickname[0].toUpperCase()) : null,
                      ),
                      title: Text(user.nickname, style: TextStyle(color: ThemeColors.getText(context))),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _sendFriendRequest(user.uid, user.nickname);
                        },
                        child: const Text('İstek Gönder'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Arkadaşlar'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'QR Kod ile Tara',
            onPressed: _showQRScanner,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Arkadaş Ekle',
            onPressed: () => _showAddFriendDialog(),
          ),
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildSearchBar(),
                  _buildRequestsSection(),
                  Expanded(
                    child: _friends.isEmpty && _searchResults.isEmpty
                        ? _buildEmptyState()
                        : _buildFriendsList(),
                  ),
                ],
              ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _showQRShareDialog,
          backgroundColor: ThemeColors.getPrimaryButtonColor(context),
          child: const Icon(Icons.qr_code, color: Colors.white),
          tooltip: 'QR Kodunu Paylaş',
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: TextField(
        controller: _searchController,
        decoration: DesignSystem.getInputDecoration(context,
          labelText: 'Arkadaş Ara',
          hintText: 'Kullanıcı adı ile ara...',
          prefixIcon: Icon(Icons.search, color: ThemeColors.getSecondaryText(context)),
        ),
        style: TextStyle(color: ThemeColors.getText(context)),
        onChanged: (value) {
          if (value.length >= 2) {
            _searchUsers(value);
          } else {
            setState(() => _searchResults = []);
          }
        },
      ),
    );
  }

  Widget _buildRequestsSection() {
    if (_receivedRequests.isEmpty && _sentRequests.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_receivedRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: DesignSystem.spacingS),
              child: Text(
                'Gelen İstekler',
                style: DesignSystem.getTitleMedium(context).copyWith(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ..._receivedRequests.map((request) => _buildFriendRequestCard(request, true)),
          ],
          if (_sentRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: DesignSystem.spacingM, bottom: DesignSystem.spacingS),
              child: Text(
                'Gönderilen İstekler',
                style: DesignSystem.getTitleMedium(context).copyWith(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ..._sentRequests.map((request) => _buildFriendRequestCard(request, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendRequestCard(FriendRequest request, bool isReceived) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingS),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingM),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(request.fromNickname[0].toUpperCase()),
            ),
            SizedBox(width: DesignSystem.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReceived ? request.fromNickname : request.toNickname,
                    style: DesignSystem.getBodyLarge(context).copyWith(
                      color: ThemeColors.getText(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isReceived ? 'Arkadaşlık isteği gönderdi' : 'İstek bekleniyor',
                    style: DesignSystem.getBodySmall(context).copyWith(
                      color: ThemeColors.getSecondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isReceived) ...[
              TextButton(
                onPressed: () => _acceptFriendRequest(request.id),
                child: Text('Kabul Et', style: TextStyle(color: ThemeColors.getSuccessColor(context))),
              ),
              TextButton(
                onPressed: () => _rejectFriendRequest(request.id),
                child: Text('Reddet', style: TextStyle(color: ThemeColors.getErrorColor(context))),
              ),
            ] else ...[
              Text(
                'Bekleniyor',
                style: DesignSystem.getBodySmall(context).copyWith(
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: ThemeColors.getSecondaryText(context)),
          SizedBox(height: DesignSystem.spacingL),
          Text(
            'Henüz arkadaş yok',
            style: DesignSystem.getHeadlineSmall(context).copyWith(
              color: ThemeColors.getText(context),
            ),
          ),
          SizedBox(height: DesignSystem.spacingM),
          Text(
            'QR kodunu paylaşarak veya kullanıcı adı ile arkadaş ekleyebilirsin',
            style: DesignSystem.getBodyMedium(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSystem.spacingXl),
          ElevatedButton.icon(
            onPressed: () => _showAddFriendDialog(),
            icon: const Icon(Icons.person_add),
            label: const Text('Arkadaş Ekle'),
            style: DesignSystem.getPrimaryButtonStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    final items = _searchResults.isNotEmpty ? _searchResults : _friends;

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (_searchResults.isNotEmpty) {
          final user = items[index] as UserData;
          return _buildSearchResultCard(user);
        } else {
          final friend = items[index] as Friend;
          return _buildFriendCard(friend);
        }
      },
    );
  }

  Widget _buildSearchResultCard(UserData user) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profilePictureUrl != null ? NetworkImage(user.profilePictureUrl!) : null,
          child: user.profilePictureUrl == null ? Text(user.nickname[0].toUpperCase()) : null,
        ),
        title: Text(user.nickname, style: TextStyle(color: ThemeColors.getText(context))),
        subtitle: Text('Kullanıcı', style: TextStyle(color: ThemeColors.getSecondaryText(context))),
        trailing: ElevatedButton(
          onPressed: () => _sendFriendRequest(user.uid, user.nickname),
          child: const Text('İstek Gönder'),
        ),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(friend.nickname[0].toUpperCase()),
        ),
        title: Text(friend.nickname, style: TextStyle(color: ThemeColors.getText(context))),
        subtitle: Text(
          'Arkadaş • ${friend.addedAt.difference(DateTime.now()).inDays.abs()} gün önce eklendi',
          style: TextStyle(color: ThemeColors.getSecondaryText(context)),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'invite':
                // TODO: Implement game invitation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Oyun daveti yakında eklenecek')),
                );
                break;
              case 'remove':
                _removeFriend(friend.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'invite',
              child: Text('Oyun Davet Et'),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Text('Arkadaşlıktan Çıkar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
