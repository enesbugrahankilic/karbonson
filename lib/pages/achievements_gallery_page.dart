// lib/pages/achievements_gallery_page.dart
// Achievements Gallery Page - Tüm başarımları görüntüleme ve filtreleme

import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../widgets/achievement_card.dart';
import '../widgets/page_templates.dart';

class AchievementsGalleryPage extends StatefulWidget {
  const AchievementsGalleryPage({super.key});

  @override
  State<AchievementsGalleryPage> createState() => _AchievementsGalleryPageState();
}

class _AchievementsGalleryPageState extends State<AchievementsGalleryPage>
    with TickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
  late TabController _tabController;

  AchievementCategory? _selectedCategory;
  List<Achievement> _allAchievements = [];
  List<Achievement> _userAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      _allAchievements = _achievementService.getAllAchievements();

      // Get user achievements (this would need to be implemented in the service)
      // For now, we'll simulate with empty list
      _userAchievements = [];

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Başarımlar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: Text('Başarımlar Galerisi'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: false,
        child: Column(
          children: [
            // TabBar
            Material(
              color: Theme.of(context).cardColor,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tüm Başarımlar', icon: Icon(Icons.star_outline)),
                  Tab(text: 'Kazandıklarım', icon: Icon(Icons.emoji_events)),
                ],
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
              ),
            ),
            // TabBarView
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllAchievementsTab(),
                        _buildUserAchievementsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAchievementsTab() {
    final filteredAchievements = _selectedCategory != null
        ? _allAchievements.where((a) => a.category == _selectedCategory).toList()
        : _allAchievements;

    return Column(
      children: [
        AchievementCategoryFilter(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        Expanded(
          child: AchievementList(
            achievements: filteredAchievements,
            showUnlockedOnly: false,
            onAchievementTap: _showAchievementDetails,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAchievementsTab() {
    final filteredAchievements = _selectedCategory != null
        ? _userAchievements.where((a) => a.category == _selectedCategory).toList()
        : _userAchievements;

    return Column(
      children: [
        AchievementCategoryFilter(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        Expanded(
          child: filteredAchievements.isEmpty
              ? _buildEmptyUserAchievements()
              : AchievementList(
                  achievements: filteredAchievements,
                  showUnlockedOnly: true,
                  onAchievementTap: _showAchievementDetails,
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyUserAchievements() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz başarı kazanmadın',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Oyun oynayarak başarıları açabilirsin!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home/game page
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', // Adjust route name as needed
                (route) => false,
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Oynamaya Başla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailSheet(achievement: achievement),
    );
  }
}

class AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailSheet({super.key, required this.achievement});

  // Helper function to get rarity color
  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.unlockedAt != null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and close button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRarityColor().withOpacity(0.2),
                    border: Border.all(
                      color: _getRarityColor(),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                            ? _getRarityColor()
                            : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRarityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          achievement.rarityName,
                          style: TextStyle(
                            color: _getRarityColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              achievement.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Requirements
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gereksinimler:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...achievement.requirements.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatRequirement(entry.key, entry.value),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Reward info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getRarityColor().withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '+${achievement.points} puan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getRarityColor(),
                  ),
                ),
                const Spacer(),
                Text(
                  achievement.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRequirement(String key, dynamic value) {
    switch (key) {
      case 'completedQuizzes':
        return '$value quiz tamamla';
      case 'duelWins':
        return '$value düello kazan';
      case 'multiplayerWins':
        return '$value çok oyunculu maç kazan';
      case 'friendsCount':
        return '$value arkadaş ekle';
      case 'loginStreak':
        return '$value gün üst üste oyna';
      case 'perfectScore':
        return 'Bir quizde %100 doğruluk oranı yakala';
      case 'fastAnswer':
        return 'Bir soruyu 5 saniyede cevapla';
      default:
        return '$key: $value';
    }
  }
}