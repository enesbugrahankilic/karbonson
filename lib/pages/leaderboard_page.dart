// lib/pages/leaderboard_page.dart
// Leaderboard Page - Sosyal karşılaştırma ve lider tabloları
// Updated: Uses Firestore for real-time data with dynamic category sorting

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/firestore_service.dart';
import '../services/friendship_service.dart';
import '../widgets/leaderboard_item.dart';
import '../widgets/page_templates.dart';

class LeaderboardPage extends StatefulWidget {
  LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final FriendshipService _friendshipService = FriendshipService();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  late TabController _tabController;

  // Global leaderboard data
  List<Map<String, dynamic>> _globalLeaderboard = [];

  // Friends leaderboard data
  List<Map<String, dynamic>> _friendsLeaderboard = [];

  // Loading states
  bool _isLoading = true;

  // Category data - dynamically loaded
  Map<String, List<Map<String, dynamic>>> _categoryData = {};
  bool _isLoadingCategories = true;

  // Class and section filters
  int? _selectedClassLevel;
  String? _selectedClassSection;

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
      // Load global leaderboard from Firestore with filters
      _globalLeaderboard = await _loadGlobalLeaderboard();

      // Load friends leaderboard from Firestore
      _friendsLeaderboard = await _loadFriendsLeaderboard();

      // Load category-specific leaderboards
      await _loadCategoryData();

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

  /// Load category-specific leaderboard data from Firestore
  Future<void> _loadCategoryData() async {
    setState(() => _isLoadingCategories = true);
    
    try {
      // Load all categories in parallel
      final results = await Future.wait([
        _firestoreService.getQuizMastersLeaderboard(),
        _firestoreService.getDuelChampionsLeaderboard(),
        _firestoreService.getSocialButterfliesLeaderboard(),
        _firestoreService.getStreakKingsLeaderboard(),
      ]);

      _categoryData = {
        'quiz_masters': _formatCategoryLeaderboard(results[0], 'quizCount'),
        'duel_champions': _formatCategoryLeaderboard(results[1], 'duelWins'),
        'social_butterflies': _formatCategoryLeaderboard(results[2], 'friendCount'),
        'streak_kings': _formatCategoryLeaderboard(results[3], 'longestStreak'),
      };
      
      if (kDebugMode) {
        debugPrint('✅ Category data loaded: ${_categoryData.keys.join(', ')}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error loading category data: $e');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  /// Format category leaderboard with rank and metadata
  List<Map<String, dynamic>> _formatCategoryLeaderboard(
    List<Map<String, dynamic>> data,
    String sortField,
  ) {
    final currentUserUid = _auth.currentUser?.uid;
    
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final user = entry.value;
      final sortValue = user[sortField] as int? ?? 0;
      
      return {
        'rank': index + 1,
        'userId': user['uid'] ?? '',
        'displayName': user['nickname'] ?? 'Anonim',
        'avatar': user['avatarUrl'] ?? '🎯',
        'score': user['score'] as int? ?? 0,
        'sortValue': sortValue, // The value used for sorting this category
        'isCurrentUser': user['uid'] == currentUserUid,
        // Include all category-specific fields
        'friendCount': user['friendCount'] as int? ?? 0,
        'duelWins': user['duelWins'] as int? ?? 0,
        'quizCount': user['quizCount'] as int? ?? 0,
        'longestStreak': user['longestStreak'] as int? ?? 0,
        'winRate': (user['winRate'] as num?)?.toDouble() ?? 0.0,
        'averageScore': user['averageScore'] as int? ?? 0,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadGlobalLeaderboard() async {
    try {
      // Get leaderboard data from Firestore with class filters
      final leaderboardData = await _firestoreService.getLeaderboard(
        classLevel: _selectedClassLevel,
        classSection: _selectedClassSection,
      );

      if (leaderboardData.isEmpty) {
        return [];
      }

      final currentUserUid = _auth.currentUser?.uid;

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
          'isCurrentUser': user['uid'] == currentUserUid || user['userId'] == currentUserUid,
          'classLevel': user['classLevel'] as int?,
          'classSection': user['classSection'] as String?,
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
      appBar: StandardAppBar(
        title: const Text('Lider Tablosu'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: false,
        child: Column(
          children: [
            Material(
              color: Theme.of(context).cardColor,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Global', icon: Icon(Icons.public)),
                  Tab(text: 'Arkadaşlar', icon: Icon(Icons.people)),
                  Tab(text: 'Kategoriler', icon: Icon(Icons.category)),
                ],
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGlobalLeaderboard(),
                        _buildFriendsLeaderboard(),
                        _buildCategoriesLeaderboard(),
                      ],
                    ),
            ),
          ],
        ),
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
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show different categories with dynamic data from Firestore
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCategoryCard(
          'Quiz Uzmanları',
          'En çok quiz tamamlayanlar',
          Icons.quiz,
          Colors.blue,
          _categoryData['quiz_masters'] ?? [],
          'quizCount',
          'quiz',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Düello Şampiyonları',
          'En çok düello kazananlar',
          Icons.sports_esports,
          Colors.red,
          _categoryData['duel_champions'] ?? [],
          'duelWins',
          'duel',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Sosyal Kelebekler',
          'En çok arkadaş edinenler',
          Icons.people,
          Colors.green,
          _categoryData['social_butterflies'] ?? [],
          'friendCount',
          'social',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          'Seri Kralları',
          'En uzun seri yakalayanlar',
          Icons.local_fire_department,
          Colors.orange,
          _categoryData['streak_kings'] ?? [],
          'longestStreak',
          'streak',
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
            const SizedBox(height: 8),
            Text(
              'İlk quizinizi çözerek başlayın!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
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
            avatarUrl: null,
            rank: player['rank'],
            isCurrentPlayerInTop10: isCurrentUser,
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<Map<String, dynamic>> data,
    String sortField,
    String categoryType,
  ) {
    final isEmpty = data.isEmpty;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showCategoryLeaderboard(context, title, data, categoryType),
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
                    if (!isEmpty && data.length >= 3) ...[
                      const SizedBox(height: 8),
                      _buildTopThreeAvatars(data),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    isEmpty ? '0' : '${data[0][sortField] ?? 0}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    isEmpty ? '' : _getSortFieldLabel(sortField),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
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

  Widget _buildTopThreeAvatars(List<Map<String, dynamic>> data) {
    final topThree = data.take(3).toList();
    
    return Row(
      children: topThree.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        final avatar = player['avatar'] ?? '👤';
        
        return Container(
          margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: index == 0 ? Colors.amber.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            avatar,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  String _getSortFieldLabel(String sortField) {
    switch (sortField) {
      case 'friendCount':
        return 'Arkadaş';
      case 'duelWins':
        return 'Galibiyet';
      case 'quizCount':
        return 'Quiz';
      case 'longestStreak':
        return 'Seri';
      default:
        return '';
    }
  }

  void _showCategoryLeaderboard(
    BuildContext context,
    String category,
    List<Map<String, dynamic>> data,
    String categoryType,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryLeaderboardPage(
          categoryName: category,
          leaderboard: data,
          categoryType: categoryType,
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
  final String categoryType;

  const CategoryLeaderboardPage({
    super.key,
    required this.categoryName,
    required this.leaderboard,
    required this.categoryType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: leaderboard.isEmpty
          ? Center(
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
                    'Bu kategoride henüz veri yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final player = leaderboard[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildCategoryPlayerCard(context, player, index),
                );
              },
            ),
    );
  }

  Widget _buildCategoryPlayerCard(
    BuildContext context,
    Map<String, dynamic> player,
    int index,
  ) {
    final isCurrentUser = player['isCurrentUser'] == true;
    final avatar = player['avatar'] ?? '👤';
    final displayName = player['displayName'] ?? 'Oyuncu';
    final sortValue = player['sortValue'] ?? 0;
    
    // Get category-specific value to display
    String categoryValue = '';
    switch (categoryType) {
      case 'quiz':
        categoryValue = '${player['quizCount'] ?? 0} quiz';
        break;
      case 'duel':
        categoryValue = '${player['duelWins'] ?? 0} galibiyet';
        break;
      case 'social':
        categoryValue = '${player['friendCount'] ?? 0} arkadaş';
        break;
      case 'streak':
        categoryValue = '${player['longestStreak'] ?? 0} gün';
        break;
    }

    return Card(
      elevation: index < 3 ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Show player profile bottom sheet
          showModalBottomSheet(
            context: context,
            builder: (context) => PlayerProfileSheet(player: player),
            backgroundColor: Colors.transparent,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Rank
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.amber
                      : index == 1
                          ? Colors.grey[300]
                          : index == 2
                              ? Colors.brown[300]
                              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: index < 3 ? Colors.white : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentUser
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Sen',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$categoryValue • ${player['score'] ?? 0} puan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Category value
              Text(
                '$sortValue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

