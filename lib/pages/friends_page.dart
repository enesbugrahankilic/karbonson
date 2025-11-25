// lib/pages/friends_page.dart

import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../services/firestore_service.dart';

class FriendsPage extends StatefulWidget {
  final String userNickname;

  const FriendsPage({super.key, required this.userNickname});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<Friend> _friends = [];
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    setState(() => _isLoading = true);

    // Burada gerçek kullanıcı ID'si gerekli olacak
    // Şimdilik nickname'i ID olarak kullanacağız
    final userId = widget.userNickname;

    _friends = await _firestoreService.getFriends(userId);
    _receivedRequests = await _firestoreService.getReceivedFriendRequests(userId);
    _sentRequests = await _firestoreService.getSentFriendRequests(userId);

    setState(() => _isLoading = false);
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    _searchResults = await _firestoreService.searchUsers(query, widget.userNickname);
    setState(() => _isLoading = false);
  }

  Future<void> _sendFriendRequest(String toNickname) async {
    final success = await _firestoreService.sendFriendRequest(
      widget.userNickname,
      widget.userNickname,
      toNickname,
      toNickname,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$toNickname kullanıcısına arkadaşlık isteği gönderildi')),
      );
      _loadFriendsData();
    }
  }

  Future<void> _acceptFriendRequest(String requestId) async {
    final success = await _firestoreService.acceptFriendRequest(requestId, widget.userNickname);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arkadaşlık isteği kabul edildi')),
      );
      _loadFriendsData();
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    final success = await _firestoreService.rejectFriendRequest(requestId, widget.userNickname);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arkadaşlık isteği reddedildi')),
      );
      _loadFriendsData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlar'),
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
            : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Kullanıcı ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                      ),
                      onChanged: _searchUsers,
                    ),
                  ),

                  // Search Results
                  if (_searchResults.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final nickname = user['nickname'] as String;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.person_add),
                              title: Text(nickname),
                              trailing: ElevatedButton(
                                onPressed: () => _sendFriendRequest(nickname),
                                child: const Text('İstek Gönder'),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    // Tab Bar
                    Expanded(
                      child: DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            const TabBar(
                              tabs: [
                                Tab(text: 'Arkadaşlar'),
                                Tab(text: 'İstekler'),
                                Tab(text: 'Gönderilen'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // Friends Tab
                                  _friends.isEmpty
                                      ? const Center(child: Text('Henüz arkadaşın yok'))
                                      : ListView.builder(
                                          itemCount: _friends.length,
                                          itemBuilder: (context, index) {
                                            final friend = _friends[index];
                                            return Card(
                                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                              child: ListTile(
                                                leading: const Icon(Icons.person),
                                                title: Text(friend.nickname),
                                                subtitle: Text('Arkadaşlık: ${friend.addedAt.day}/${friend.addedAt.month}/${friend.addedAt.year}'),
                                                trailing: ElevatedButton(
                                                  onPressed: () {
                                                    // TODO: Implement invite to game
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('${friend.nickname} kullanıcısını oyuna davet et')),
                                                    );
                                                  },
                                                  child: const Text('Davet Et'),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                  // Received Requests Tab
                                  _receivedRequests.isEmpty
                                      ? const Center(child: Text('Yeni arkadaşlık isteği yok'))
                                      : ListView.builder(
                                          itemCount: _receivedRequests.length,
                                          itemBuilder: (context, index) {
                                            final request = _receivedRequests[index];
                                            return Card(
                                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                              child: ListTile(
                                                leading: const Icon(Icons.person_add),
                                                title: Text('${request.fromNickname} isteği gönderdi'),
                                                subtitle: Text('Tarih: ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}'),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.check, color: Colors.green),
                                                      onPressed: () => _acceptFriendRequest(request.id),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.red),
                                                      onPressed: () => _rejectFriendRequest(request.id),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                  // Sent Requests Tab
                                  _sentRequests.isEmpty
                                      ? const Center(child: Text('Gönderilmiş arkadaşlık isteği yok'))
                                      : ListView.builder(
                                          itemCount: _sentRequests.length,
                                          itemBuilder: (context, index) {
                                            final request = _sentRequests[index];
                                            return Card(
                                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                              child: ListTile(
                                                leading: const Icon(Icons.schedule),
                                                title: Text('${request.toNickname} kullanıcısına istek gönderildi'),
                                                subtitle: Text('Tarih: ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}'),
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}