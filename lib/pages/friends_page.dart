import 'package:flutter/material.dart';
import '../widgets/page_templates.dart';

class FriendsPage extends StatefulWidget {
  final String userNickname;

  const FriendsPage({super.key, required this.userNickname});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final List<Map<String, dynamic>> _friends = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      // Arkadaşları yükle
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Arkadaşlar'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
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
            : _friends.isEmpty
                ? _buildEmptyState()
                : _buildFriendsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text('Henüz arkadaş yok',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddFriendDialog(),
            child: const Text('Arkadaş Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Text((friend['nickname'] ?? 'A')[0]),
            ),
            title: Text(friend['nickname'] ?? 'Bilinmeyen'),
            subtitle: Text(friend['status'] ?? 'Çevrimdışı'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'game',
                  child: Text('Oyun Davet Et'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Sil', style: TextStyle(color: Colors.red)),
                ),
              ],
              onSelected: (value) {
                if (value == 'game') {
                  _inviteFriendToGame(friend['id']);
                } else if (value == 'remove') {
                  _removeFriend(friend['id']);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddFriendDialog() {
    final nicknameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arkadaş Ekle'),
        content: TextField(
          controller: nicknameController,
          decoration: const InputDecoration(
            hintText: 'Arkadaşın adını gir',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _addFriend(nicknameController.text);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriend(String nickname) async {
    if (nickname.isEmpty) return;
    try {
      setState(() {
        _friends.add({'id': nickname, 'nickname': nickname, 'status': 'Çevrimdışı'});
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$nickname arkadaş olarak eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      setState(() {
        _friends.removeWhere((f) => f['id'] == friendId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaş silindi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _inviteFriendToGame(String friendId) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyun daveti gönderildi')),
      );
    }
  }
}
