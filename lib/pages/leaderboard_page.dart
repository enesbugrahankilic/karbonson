// lib/pages/leaderboard_page.dart
// Leaderboard Page - Sosyal karşılaştırma ve lider tabloları

import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/achievement_service.dart';
import '../widgets/leaderboard_item.dart';
import '../theme/app_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
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
      // Load global leaderboard (simulated data for now)
      _globalLeaderboard = await _loadGlobalLeaderboard();

      // Load friends leaderboard (simulated data for now)
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
    // Simulated global leaderboard data
    // In a real app, this would come from Firestore
    return [
      {
        'rank': 1,
        'userId': 'user1',
        'displayName': 'QuizMaster2024',
        'avatar': '🎯',
        'score': 2500,
        'level': 15,
        'achievements': 25,
        'winRate': 85.5,
      },
      {
        'rank': 2,
        'userId': 'user2',
        'displayName': 'BrainTeaser',
        'avatar': '🧠',
        'score': 2350,
        'level': 14,
        'achievements': 22,
        'winRate': 82.3,
      },
      {
        'rank': 3,
        'userId': 'user3',
        'displayName': 'KnowledgeKing',
        'avatar': '👑',
        'score': 2200,
        'level': 13,
        'achievements': 20,
        'winRate': 79.8,
      },
      {
        'rank': 4,
        'userId': 'user4',
        'displayName': 'SmartPlayer',
        'avatar': '🎓',
        'score': 2100,
        'level': 12,
        'achievements': 18,
        'winRate': 76.4,
      },
      {
        'rank': 5,
        'userId': 'user5',
        'displayName': 'QuizWizard',
        'avatar': '🧙‍♂️',
        'score': 1950,
        'level': 11,
        'achievements': 16,
        'winRate': 73.2,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _loadFriendsLeaderboard() async {
    // Simulated friends leaderboard data
    return [
      {
        'rank': 1,
        'userId': 'friend1',
        'displayName': 'Arkadaşım Ali',
        'avatar': '🤝',
        'score': 1800,
        'level': 10,
        'achievements': 14,
        'winRate': 71.5,
        'isFriend': true,
      },
      {
        'rank': 2,
        'userId': 'friend2',
        'displayName': 'Kızkardeşim Ayşe',
        'avatar': '👩‍👧',
        'score': 1650,
        'level': 9,
        'achievements': 12,
        'winRate': 68.9,
        'isFriend': true,
      },
      {
        'rank': 3,
        'userId': 'current_user',
        'displayName': 'Ben',
        'avatar': '👤',
        'score': 1500,
        'level': 8,
        'achievements': 10,
        'winRate': 65.2,
        'isFriend': true,
        'isCurrentUser': true,
      },
    ];
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
                  color: color.withOpacity(0.1),
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

  void _showPlayerProfile(BuildContext context, Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerProfileSheet(player: player),
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      player['avatar'],
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
                            player['displayName'],
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
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                        'Seviye ${player['level']} • ${player['score']} puan',
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
                _buildStatColumn(context, 'Başarımlar', player['achievements'].toString()),
                _buildStatColumn(context, 'Kazanma Oranı', '%${player['winRate']}'),
                _buildStatColumn(context, 'Sıralama', '#${player['rank']}'),
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
              username: player['displayName'],
              score: player['score'],
              avatarUrl: null,
              rank: index + 1,
              isCurrentPlayerInTop10: player['isCurrentUser'] == true,
            ),
          );
        },
      ),
    );
  }

  void _showPlayerProfile(BuildContext context, Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerProfileSheet(player: player),
    );
  }
}
