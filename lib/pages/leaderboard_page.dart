// lib/pages/leaderboard_page.dart
// Leaderboard Page - Sosyal karşılaştırma ve lider tabloları
// Updated: Uses Firestore for real-time data

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/firestore_service.dart';
import '../services/friendship_service.dart';
import '../widgets/leaderboard_item.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final FriendshipService _friendshipService = FriendshipService();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  late TabController _tabController;

  List<Map<String, dynamic>> _globalLeaderboard = [];
  List<Map<String, dynamic>> _friendsLeaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    setState(() => _isLoading = true);

    try {
      // Load global leaderboard from Firestore
      _globalLeaderboard = await _loadGlobalLeaderboard();

      // Load friends leaderboard from Firestore
      _friendsLeaderboard = await _loadFriendsLeaderboard();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lider tabloları yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadGlobalLeaderboard() async {
    try {
      // Get leaderboard data from Firestore
      final leaderboardData = await _firestoreService.getLeaderboard();

      if (leaderboardData.isEmpty) {
        // Return empty list if no data in database
        return [];
      }

      // Add rank and format data for display
      return leaderboardData.asMap().entries.map((entry) {
        final index = entry.key;
        final user = entry.value;
        final score = user['score'] as int? ?? 0;
        
        // Calculate level based on score (approx 500 points per level)
        final level = (score / 500).floor() + 1;

        return {
          'rank': index + 1,
          'userId': user['uid'] ?? user['userId'] ?? '',
          'displayName': user['nickname'] ?? user['displayName'] ?? 'Anonim',
          'avatar': user['avatarUrl'] ?? '🎯',
          'score': score,
          'level': level,
          'achievements': user['achievements'] as int? ?? 0,
          'winRate': user['winRate'] as double? ?? 0.0,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading global leaderboard: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadFriendsLeaderboard() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      // Get user's friends
      final friends = await _friendshipService.getFriends();

      if (friends.isEmpty) {
        return [];
      }

      // Get all friend UIDs
      final friendUids = friends.map((f) => f.id).toList();

      // Get scores for all friends from Firestore
      final allScores = await _firestoreService.getLeaderboard();

      // Filter and sort friends' scores
      final friendsScores = allScores.where((user) {
        final uid = user['uid'] as String?;
        return uid != null && friendUids.contains(uid);
      }).toList();

      // Sort by score descending
      friendsScores.sort((a, b) {
        final scoreA = a['score'] as int? ?? 0;
        final scoreB = b['score'] as int? ?? 0;
        return scoreB.compareTo(scoreA);
      });

      // Format data for display
      final result = <Map<String, dynamic>>[];
      final currentUserUid = currentUser.uid;
      int currentUserRank = 0;

      for (int i = 0; i < friendsScores.length; i++) {
        final user = friendsScores[i];
        final uid = user['uid'] as String? ?? '';
        final score = user['score'] as int? ?? 0;
        final level = (score / 500).floor() + 1;

        final entry = {
          'rank': i + 1,
          'userId': uid,
          'displayName': user['nickname'] ?? 'Arkadaş',
          'avatar': user['avatarUrl'] ?? '👤',
          'score': score,
          'level': level,
          'achievements': user['achievements'] as int? ?? 0,
          'winRate': user['winRate'] as double? ?? 0.0,
          'isFriend': true,
          'isCurrentUser': uid == currentUserUid,
        };

        if (uid == currentUserUid) {
          currentUserRank = i + 1;
        }

        result.add(entry);
      }

      // Add current user if not already in the list
      if (currentUserRank == 0) {
        final currentUserData = allScores.firstWhere(
          (u) => (u['uid'] as String?) == currentUserUid,
          orElse: () => {'nickname': 'Ben', 'score': 0},
        );

        final score = currentUserData['score'] as int? ?? 0;
        result.add({
          'rank': result.length + 1,
          'userId': currentUserUid,
          'displayName': 'Ben',
          'avatar': '👤',
          'score': score,
          'level': (score / 500).floor() + 1,
          'achievements': 0,
          'winRate': 0.0,
          'isFriend': true,
          'isCurrentUser': true,
        });
      }

      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading friends leaderboard: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Lider Tablosu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Arkadaşlar'),
            Tab(text: 'Kategoriler'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGlobalLeaderboard(),
                _buildFriendsLeaderboard(),
                _buildCategoriesLeaderboard(),
              ],
            ),
    );
  }

  Widget _buildGlobalLeaderboard() {
    return _buildLeaderboardList(_globalLeaderboard, showGlobalRank: true);
  }

  Widget _buildFriendsLeaderboard() {
    return _buildLeaderboardList(_friendsLeaderboard, showFriendIndicators: true);
  }

  Widget _buildCategoriesLeaderboard() {
    // Show different categories like Quiz Masters, Duel Champions, etc.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCategoryCard(
          'Quiz Uzmanları',
          'En çok quiz tamamlayanlar',
          Icons.quiz,
          Colors.blue,
          _globalLeaderboard,
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Düello Şampiyonları',
          'En çok düello kazananlar',
          Icons.sports_esports,
          Colors.red,
          _globalLeaderboard,
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Sosyal Kelebekler',
          'En çok arkadaş edinenler',
          Icons.people,
          Colors.green,
          _globalLeaderboard,
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Seri Kralları',
          'En uzun seri yakalayanlar',
          Icons.local_fire_department,
          Colors.orange,
          _globalLeaderboard,
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> leaderboard,
      {bool showGlobalRank = false, bool showFriendIndicators = false}) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Lider tablosu boş',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final player = leaderboard[index];
        final isCurrentUser = player['isCurrentUser'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: LeaderboardItem(
            username: player['displayName'],
            score: player['score'],
            avatarUrl: null, // Using emoji avatars, so null for now
            rank: player['rank'],
            isCurrentPlayerInTop10: isCurrentUser,
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, IconData icon,
      Color color, List<Map<String, dynamic>> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showCategoryLeaderboard(context, title, data),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryLeaderboard(BuildContext context, String category,
      List<Map<String, dynamic>> data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryLeaderboardPage(
          categoryName: category,
          leaderboard: data,
        ),
      ),
    );
  }
}

class PlayerProfileSheet extends StatelessWidget {
  final Map<String, dynamic> player;

  const PlayerProfileSheet({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = player['isCurrentUser'] == true;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      player['avatar'] ?? '👤',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            player['displayName'] ?? 'Oyuncu',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Sen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seviye ${player['level'] ?? 1} • ${player['score'] ?? 0} puan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(context, 'Başarımlar', '${player['achievements'] ?? 0}'),
                _buildStatColumn(context, 'Kazanma Oranı', '%${player['winRate']?.toStringAsFixed(1) ?? '0'}'),
                _buildStatColumn(context, 'Sıralama', '#${player['rank'] ?? '-'}'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          if (!isCurrentUser)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add friend functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${player['displayName']} arkadaşlık isteği gönderildi')),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Arkadaş Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
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

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class CategoryLeaderboardPage extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> leaderboard;

  const CategoryLeaderboardPage({
    super.key,
    required this.categoryName,
    required this.leaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final player = leaderboard[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: LeaderboardItem(
              username: player['displayName'] ?? 'Oyuncu',
              score: player['score'] ?? 0,
              avatarUrl: null,
              rank: index + 1,
              isCurrentPlayerInTop10: player['isCurrentUser'] == true,
            ),
          );
        },
      ),
    );
  }
}

