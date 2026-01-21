 // lib/pages/friends_page.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/game_board.dart';
import '../models/user_data.dart';
import '../services/firestore_service.dart';
import '../services/game_invitation_service.dart';
import '../services/presence_service.dart';
import '../services/notification_service.dart';
import '../services/achievement_service.dart';
import '../services/friend_suggestion_service.dart';
import '../models/friend_suggestion.dart';
import '../widgets/game_invitation_dialog.dart';
import '../widgets/home_button.dart';
import '../services/app_localizations.dart';
import '../provides/language_provider.dart';
import '../widgets/qr_code_scanner_widget.dart';
import '../widgets/add_friend_bottom_sheet.dart';
import '../widgets/block_user_dialog.dart';
import '../widgets/user_qr_code_widget.dart';
import '../theme/design_system.dart';

class FriendsPage extends StatefulWidget {
  final String userNickname;

  const FriendsPage({super.key, required this.userNickname});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final GameInvitationService _invitationService = GameInvitationService();
  final PresenceService _presenceService = PresenceService();
  final FriendSuggestionService _friendSuggestionService =
      FriendSuggestionService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Friend> _friends = [];
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];
  List<GameInvitation> _gameInvitations = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<UserData> _allRegisteredUsers = [];
  List<FriendSuggestion> _friendSuggestions = [];
  Map<String, PresenceStatus> _presenceMap = {};
  bool _isLoading = false;
  bool _isLoadingSuggestions = false;
  StreamSubscription<List<GameInvitation>>? _invitationSubscription;
  StreamSubscription<List<FriendRequest>>? _friendRequestSubscription;
  StreamSubscription<Map<String, PresenceStatus>>? _presenceSubscription;

  // Button protection against double-clicks and race conditions
  final Set<String> _processingRequests = {};

  // Pending friend request from deep link
  String? _pendingAddFriendId;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
    _initializePresence();
    _startListeningToInvitations();
    _startListeningToFriendRequests();
    _startListeningToPresence();
    _loadFriendSuggestions();

    // Listen to language changes
    context.read<LanguageProvider>().addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _invitationSubscription?.cancel();
    _friendRequestSubscription?.cancel();
    _presenceSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToPresence() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final friendIds = _friends.map((f) => f.id).toList();
    if (friendIds.isEmpty) return;

    _presenceSubscription =
        _presenceService.listenToFriendsPresence(friendIds).listen((presenceMap) {
      if (mounted) {
        setState(() {
          _presenceMap = presenceMap;
        });
      }
    });
  }

  Future<void> _initializePresence() async {
    await _presenceService.initialize();
  }

  /// Load friend suggestions
  Future<void> _loadFriendSuggestions() async {
    setState(() => _isLoadingSuggestions = true);

    try {
      final suggestions = await _friendSuggestionService.getSuggestions();
      if (mounted) {
        setState(() {
          _friendSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error loading friend suggestions: $e');
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
  }

  /// Send friend request from suggestion
  Future<void> _sendRequestFromSuggestion(FriendSuggestion suggestion) async {
    try {
      final success =
          await _friendSuggestionService.sendRequestFromSuggestion(suggestion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: success
                ? Text('${suggestion.nickname} kullanıcısına istek gönderildi!')
                : const Text('İstek gönderilemedi'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          // Remove from suggestions after successful request
          setState(() {
            _friendSuggestions.remove(suggestion);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error sending request from suggestion: $e');
    }
  }

  /// Open QR scanner
  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRCodeScannerWidget(),
      ),
    );
  }

  /// Get human-readable text for suggestion reason
  String _getSuggestionReasonText(SuggestionReason reason) {
    switch (reason) {
      case SuggestionReason.commonFriends:
        return 'Ortak arkadaşlarınız var';
      case SuggestionReason.recentlyPlayed:
        return 'Son oynadığınız oyuncular';
      case SuggestionReason.leaderboard:
        return 'Sizinle benzer seviyede';
      case SuggestionReason.popular:
        return 'Popüler oyuncular';
      case SuggestionReason.nearby:
        return 'Yakınınızdaki oyuncular';
      case SuggestionReason.suggested:
        return 'Sizin için önerilen';
      case SuggestionReason.other:
        return 'Önerilen';
    }
  }

  void _startListeningToInvitations() {
    _invitationSubscription =
        _invitationService.listenToInvitations().listen((invitations) {
      if (mounted) {
        setState(() {
          _gameInvitations = invitations;
        });

        // Show dialog for new invitations
        for (final invitation in invitations) {
          Future.delayed(Duration.zero, () {
            showGameInvitationDialog(
              context: context,
              invitation: invitation,
              onInvitationHandled: () {
                setState(() {
                  _gameInvitations.remove(invitation);
                });
              },
            );
          });
        }
      }
    });
  }

  void _startListeningToFriendRequests() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Keep track of previous request IDs to detect new requests
    final Set<String> previousRequestIds = <String>{};

    // Listen to real-time changes in friend requests for current user
    _friendRequestSubscription = _firestoreService
        .listenToReceivedFriendRequests(currentUser.uid)
        .listen((requests) {
      if (mounted) {
        setState(() {
          _receivedRequests = requests;
        });

        // Show notification for new friend requests
        final currentRequestIds = requests.map((r) => r.id).toSet();
        final newRequests = requests
            .where((request) => !previousRequestIds.contains(request.id))
            .toList();

        if (newRequests.isNotEmpty) {
          Future.delayed(Duration.zero, () {
            for (final request in newRequests) {
              _showFriendRequestNotification(request);
            }
          });
        }

        // Update previous request IDs for next comparison
        previousRequestIds.clear();
        previousRequestIds.addAll(currentRequestIds);
      }
    });
  }

  void _showFriendRequestNotification(FriendRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📨 Yeni Arkadaşlık İsteği!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${request.fromNickname} arkadaşlık isteği gönderdi',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Görüntüle',
          textColor: Colors.white,
          onPressed: () {
            // Scroll to requests tab
            final tabController = DefaultTabController.of(context);
            tabController.animateTo(1);
                    },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _loadFriendsData() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) debugPrint('❌ User not authenticated');
        return;
      }

      final userId = currentUser.uid;

      // Load all data in parallel for better performance
      final results = await Future.wait([
        _firestoreService.getFriends(userId),
        _firestoreService.getReceivedFriendRequests(userId),
        _firestoreService.getSentFriendRequests(userId),
        _firestoreService.getAllUsers(limit: 50),
      ]);

      _friends = results[0] as List<Friend>;
      _receivedRequests = results[1] as List<FriendRequest>;
      _sentRequests = results[2] as List<FriendRequest>;
      _allRegisteredUsers = results[3] as List<UserData>;

      // Filter out current user and existing friends
      final friendIds = _friends.map((f) => f.id).toSet();
      _allRegisteredUsers.removeWhere((user) =>
          user.uid == currentUser.uid || friendIds.contains(user.uid));
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error loading friends data: $e');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: () => _loadFriendsData(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    if (kDebugMode) debugPrint('🔄 Refreshing friend data...');
    await _loadFriendsData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Veriler güncellendi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      _searchResults =
          await _firestoreService.searchUsers(query, currentUser.uid);
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error searching users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendFriendRequest(String toNickname) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Search for user by nickname
      final searchResults =
          await _firestoreService.searchUsers(toNickname, currentUser.uid);

      if (searchResults.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kullanıcı bulunamadı: $toNickname')),
          );
        }
        return;
      }

      // Find exact match
      final targetUser = searchResults.firstWhere(
        (user) => user['nickname'] == toNickname,
        orElse: () => <String, dynamic>{},
      );

      if (targetUser.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kullanıcı bulunamadı: $toNickname')),
          );
        }
        return;
      }

      final success = await _firestoreService.sendFriendRequest(
        currentUser.uid,
        currentUser.displayName ?? toNickname,
        toNickname,
        toNickname,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$toNickname kullanıcısına arkadaşlık isteği gönderildi')),
        );
        _loadFriendsData(); // Refresh all data including registered users
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error sending friend request: $e');
    }
  }

  /// Invite friend to join current game room
  Future<void> _inviteFriendToGame(Friend friend) async {
    try {
      // Check if user is currently in a game
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oturum açmanız gerekiyor')),
        );
        return;
      }

      // Show dialog to ask for room ID or create new room
      final roomId = await _showRoomIdDialog();
      if (roomId == null || roomId.isEmpty) {
        return; // User cancelled
      }

      final result = await _invitationService.inviteFriendToGame(
        roomId: roomId,
        friendId: friend.id,
        friendNickname: friend.nickname,
        inviterNickname: widget.userNickname,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Davet gönderildi!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Davet gönderilemedi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error inviting friend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Davet gönderilirken hata oluştu')),
        );
      }
    }
  }

  Future<String?> _showRoomIdDialog() async {
    final TextEditingController roomIdController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Oyun Daveti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Arkadaşınızı hangi odaya davet etmek istiyorsunuz?'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Oda ID',
                hintText: 'Oda ID\'sini girin',
                border: OutlineInputBorder(),
              ),
              controller: roomIdController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(roomIdController.text.trim());
            },
            child: Text('Davet Gönder'),
          ),
        ],
      ),
    );
  }

  /// Arkadaşlık isteğini güvenli şekilde kabul et
  /// Specification: Double-click koruması ve hata yönetimi
  Future<void> _acceptFriendRequest(String requestId) async {
    // Double-click koruması
    if (_processingRequests.contains(requestId)) {
      if (kDebugMode) debugPrint('İstek zaten işleniyor: $requestId');
      return;
    }

    // Processing başlat
    _processingRequests.add(requestId);
    setState(() {}); // UI'ı güncelle

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // İlk önce isteğin geçerliliğini kontrol et
      final isValid = await _firestoreService.isFriendRequestValid(
          requestId, currentUser.uid);

      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu istek artık geçerli değil'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _loadFriendsData(); // Refresh all data including registered users
        return;
      }

      // Atomik kabul işlemi
      final success = await _firestoreService.acceptFriendRequest(
          requestId, currentUser.uid);

      if (mounted) {
        if (success) {
          // Update achievement for adding friend
          AchievementService().updateProgress(
            friendsCount: 1,
          );

          // Get request details for notification
          final requestDoc = await FirebaseFirestore.instance
              .collection('friend_requests')
              .doc(requestId)
              .get();

          if (requestDoc.exists) {
            // Request data exists, process accepted notification
            // Send friend request accepted notification
            await NotificationService.showFriendRequestAcceptedNotificationStatic(
              currentUser.displayName ?? 'Kullanıcı',
              currentUser.uid,
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Arkadaşlık isteği başarıyla kabul edildi!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 İstek kabul edilirken bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _loadFriendsData(); // Refresh all data including registered users
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Kritik hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beklenmeyen bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Processing bitir
      _processingRequests.remove(requestId);
      if (mounted) {
        setState(() {}); // UI'ı güncelle
      }
    }
  }

  /// Arkadaşlık isteğini güvenli şekilde reddet
  /// Specification: Double-click koruması ve hata yönetimi
  Future<void> _rejectFriendRequest(String requestId) async {
    // Double-click koruması
    if (_processingRequests.contains(requestId)) {
      if (kDebugMode) debugPrint('İstek zaten işleniyor: $requestId');
      return;
    }

    // Processing başlat
    _processingRequests.add(requestId);
    setState(() {}); // UI'ı güncelle

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // İlk önce isteğin geçerliliğini kontrol et
      final isValid = await _firestoreService.isFriendRequestValid(
          requestId, currentUser.uid);

      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu istek artık geçerli değil'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _loadFriendsData(); // Refresh all data including registered users
        return;
      }

      // Get request details for notification before rejecting
      final requestDoc = await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        // Request data exists, will process rejection
      }

      // Atomik reddetme işlemi (bildirim ile)
      final success = await _firestoreService.rejectFriendRequest(
        requestId,
        currentUser.uid,
        sendNotification:
            true, // Bildirim gönder (FirestoreService içinde NotificationService çağrısı yapılır)
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Arkadaşlık isteği reddedildi'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 İstek reddedilirken bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _loadFriendsData(); // Refresh all data including registered users
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Kritik hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Beklenmeyen bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Processing bitir
      _processingRequests.remove(requestId);
      if (mounted) {
        setState(() {}); // UI'ı güncelle
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(AppLocalizations.friends);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // QR Scanner button
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openQRScanner,
            tooltip: 'QR Kod Tara',
          ),
          // Friend request counter
          if (_receivedRequests.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    // Switch to requests tab
                    final tabController = DefaultTabController.of(context);
                    tabController.animateTo(1);
                                    },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_receivedRequests.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          // Game invitation counter
          if (_gameInvitations.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.videogame_asset),
                  onPressed: () {
                    // Show pending invitations
                    _showPendingInvitations();
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_gameInvitations.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        color: Colors.blue,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _isLoading && _friends.isEmpty && _receivedRequests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Kullanıcı ara...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.white.withOpacity( 0.9),
                                  ),
                                  onChanged: _searchUsers,
                                ),
                              ),
                              SizedBox(width: 8),
                              // Refresh button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                  onPressed: _isLoading ? null : _refreshData,
                                  tooltip: 'Yenile',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Search Results
                        if (_searchResults.isNotEmpty)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                final nickname = user['nickname'] as String;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Colors.green.withOpacity( 0.1),
                                      child: Icon(Icons.person_add,
                                          color: Colors.green),
                                    ),
                                    title: Text(nickname),
                                    trailing: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => _sendFriendRequest(nickname),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(_isLoading
                                          ? 'Yükleniyor...'
                                          : 'İstek Gönder'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          // Tab Bar
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Scrollbar(
                              child: DefaultTabController(
                                  length: 6,
                                  child: Column(
                                  children: [
                                    TabBar(
                                      tabs: [
                                        Tab(
                                          text: 'Arkadaşlar',
                                          icon: Icon(Icons.group),
                                        ),
                                        Tab(
                                          text: 'İstekler',
                                          icon: Stack(
                                            children: [
                                              Icon(Icons.person_add),
                                              if (_receivedRequests.isNotEmpty)
                                                Positioned(
                                                  right: -2,
                                                  top: -2,
                                                  child: Container(
                                                    padding: EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    constraints: BoxConstraints(
                                                      minWidth: 12,
                                                      minHeight: 12,
                                                    ),
                                                    child: Text(
                                                      '${_receivedRequests.length}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Tab(
                                          text: 'Gönderilen',
                                          icon: Icon(Icons.send),
                                        ),
                                        Tab(
                                          text: 'Öneriler',
                                          icon: Icon(Icons.auto_awesome),
                                        ),
                                        Tab(
                                          text: 'Kullanıcılar',
                                          icon: Icon(Icons.people),
                                        ),
                                        Tab(
                                          text: 'QR Kodum',
                                          icon: Icon(Icons.qr_code),
                                        ),
                                      ],
                                      indicatorColor: Colors.blue,
                                      labelColor: Colors.blue,
                                      unselectedLabelColor: Colors.black54,
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          // Friends Tab with Online Status
                                          _friends.isEmpty
                                              ? DesignSystem.globalNoFriendsScreen(context)
                                              : ListView.builder(
                                                  itemCount: _friends.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final friend =
                                                        _friends[index];
                                                    final presence =
                                                        _presenceMap[
                                                            friend.id];
                                                    final isOnline =
                                                        presence?.isOnline ??
                                                            false;

                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: ListTile(
                                                        leading: Stack(
                                                          children: [
                                                            const Icon(
                                                                Icons.person),
                                                            // Online status indicator
                                                            Positioned(
                                                              right: 0,
                                                              bottom: 0,
                                                              child:
                                                                  Container(
                                                                width: 12,
                                                                height: 12,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isOnline
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .grey,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border:
                                                                      Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        title: Text(
                                                            friend.nickname),
                                                        subtitle: Text(
                                                          isOnline
                                                              ? 'Çevrimiçi'
                                                              : 'Çevrimdışı',
                                                          style: TextStyle(
                                                            color: isOnline
                                                                ? Colors.green
                                                                : Colors.grey,
                                                          ),
                                                        ),
                                                        trailing: PopupMenuButton<String>(
                                                          onSelected: (value) {
                                                            if (value == 'invite') {
                                                              _inviteFriendToGame(friend);
                                                            } else if (value == 'block') {
                                                              _showBlockDialog(friend);
                                                            }
                                                          },
                                                          itemBuilder: (context) => [
                                                            const PopupMenuItem(
                                                              value: 'invite',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.videogame_asset, size: 18),
                                                                  SizedBox(width: 8),
                                                                  Text('Davet Et'),
                                                                ],
                                                              ),
                                                            ),
                                                            const PopupMenuItem(
                                                              value: 'block',
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.block, size: 18, color: Colors.red),
                                                                  SizedBox(width: 8),
                                                                  Text('Engelle'),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                          // Received Requests Tab
                                          _receivedRequests.isEmpty
                                              ? DesignSystem.globalEmptyStateScreen(
                                                  context,
                                                  title: 'Yeni Arkadaşlık İsteği Yok',
                                                  message: 'Yeni istekler burada görünecek',
                                                  icon: Icons.person_add_alt,
                                                )
                                              : ListView.builder(
                                                  itemCount:
                                                      _receivedRequests.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final request =
                                                        _receivedRequests[
                                                            index];
                                                    final isProcessing =
                                                        _processingRequests
                                                            .contains(
                                                                request.id);

                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 6),
                                                      elevation: 2,
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.all(16),
                                                        leading: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.blue
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1),
                                                          child: Icon(
                                                            Icons.person_add,
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                        title: Text(
                                                          request.fromNickname,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Arkadaşlık isteği gönderdi',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              'Tarih: ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year} ${request.createdAt.hour}:${request.createdAt.minute.toString().padLeft(2, '0')}',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey[500],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: isProcessing
                                                            ? SizedBox(
                                                                width: 80,
                                                                height: 32,
                                                                child: Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 16,
                                                                    height: 16,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      valueColor: AlwaysStoppedAnimation<
                                                                              Color>(
                                                                          Colors
                                                                              .blue),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // Kabul butonu
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .green,
                                                                      size: 32,
                                                                    ),
                                                                    onPressed: isProcessing
                                                                        ? null
                                                                        : () =>
                                                                            _acceptFriendRequest(request.id),
                                                                    tooltip:
                                                                        'Kabul Et',
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      minWidth:
                                                                          48,
                                                                      minHeight:
                                                                          48,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  // Red butonu
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 32,
                                                                    ),
                                                                    onPressed: isProcessing
                                                                        ? null
                                                                        : () =>
                                                                            _rejectFriendRequest(request.id),
                                                                    tooltip:
                                                                        'Reddet',
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      minWidth:
                                                                          48,
                                                                      minHeight:
                                                                          48,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              // Sent Requests Tab
                                              _sentRequests.isEmpty
                                                  ? DesignSystem.globalEmptyStateScreen(
                                                      context,
                                                      title: 'Gönderilmiş İstek Yok',
                                                      message: 'Gönderdiğiniz arkadaşlık istekleri burada görünecek',
                                                      icon: Icons.send,
                                                    )
                                                  : ListView.builder(
                                                  itemCount:
                                                      _sentRequests.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final request =
                                                        _sentRequests[index];
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: ListTile(
                                                        leading: const Icon(
                                                            Icons.schedule),
                                                        title: Text(
                                                            '${request.toNickname} kullanıcısına istek gönderildi'),
                                                        subtitle: Text(
                                                            'Tarih: ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}'),
                                                      ),
                                                    );
                                                  },
                                                ),

                                          // Friend Suggestions Tab
                                          _isLoadingSuggestions
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : _friendSuggestions.isEmpty
                                                  ? DesignSystem.globalEmptyStateScreen(
                                                      context,
                                                      title: 'Öneri Yok',
                                                      message: 'Şu anda arkadaş önerisi bulunmuyor',
                                                      icon: Icons.auto_awesome,
                                                    )
                                                  : ListView.builder(
                                                      itemCount:
                                                          _friendSuggestions
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final suggestion =
                                                            _friendSuggestions[
                                                                index];
                                                        return Card(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 4),
                                                          child: ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.purple
                                                                      .withValues(
                                                                          alpha:
                                                                              0.1),
                                                              child: Icon(
                                                                Icons
                                                                    .auto_awesome,
                                                                color: Colors
                                                                    .purple,
                                                              ),
                                                            ),
                                                            title: Text(suggestion
                                                                .nickname),
                                                            subtitle: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  _getSuggestionReasonText(
                                                                      suggestion
                                                                          .reason),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .purple,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                if (suggestion
                                                                        .commonFriendsCount !=
                                                                    null)
                                                                  Text(
                                                                    '${suggestion.commonFriendsCount} ortak arkadaş',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .grey[600],
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                            trailing: ElevatedButton(
                                                              onPressed: () =>
                                                                  _sendRequestFromSuggestion(
                                                                      suggestion),
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .purple,
                                                                foregroundColor:
                                                                    Colors.white,
                                                              ),
                                                              child: const Text(
                                                                  'İstek Gönder'),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),

                                          // All Registered Users Tab
                                          _allRegisteredUsers.isEmpty
                                              ? DesignSystem.globalEmptyStateScreen(
                                                  context,
                                                  title: 'Kullanıcı Bulunamadı',
                                                  message: 'Henüz kayıtlı kullanıcı yok',
                                                  icon: Icons.people,
                                                )
                                              : ListView.builder(
                                                  itemCount: _allRegisteredUsers
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final user =
                                                        _allRegisteredUsers[
                                                            index];
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 4),
                                                      child: ListTile(
                                                        leading: const Icon(
                                                            Icons.people),
                                                        title:
                                                            Text(user.nickname),
                                                        subtitle: Text(
                                                            'Kayıt Tarihi: ${user.createdAt != null ? "${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}" : "Bilinmiyor"}'),
                                                        trailing:
                                                            ElevatedButton(
                                                          onPressed: () =>
                                                              _sendFriendRequest(
                                                                  user.nickname),
                                                          child: const Text(
                                                              'Arkadaş Ekle'),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),

                                          // QR Code Tab
                                          UserQRCodeWidget(
                                            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                                            nickname: widget.userNickname,
                                          ),
                                        ],
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
        ),
      ),
    );
  }

  void _showAddFriendBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFriendBottomSheet(
        onUserSelected: (userId, nickname) {
          return true;
        },
      ),
    );
  }

  void _showBlockDialog(Friend friend) {
    showDialog(
      context: context,
      builder: (context) => BlockUserDialog(
        userId: friend.id,
        nickname: friend.nickname,
        onBlockComplete: () {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${friend.nickname} engellendi')),
          );
        },
      ),
    );
  }

  void _showPendingInvitations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bekleyen Oyun Davetleri'),
        content: _gameInvitations.isEmpty
            ? Text('Bekleyen davet yok')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _gameInvitations.length,
                  itemBuilder: (context, index) {
                    final invitation = _gameInvitations[index];
                    return Card(
                      child: ListTile(
                        title:
                            Text('${invitation.fromNickname} tarafından davet'),
                        subtitle: Text('Oda: ${invitation.roomId}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _invitationService
                                    .acceptInvitation(invitation.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await _invitationService
                                    .declineInvitation(invitation.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Kapat'),
          ),
        ],
      ),
    );
  }


}
