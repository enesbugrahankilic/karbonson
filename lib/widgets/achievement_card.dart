// lib/widgets/achievement_card.dart
// Achievement card widget for displaying achievements

import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final double progress; // 0.0 to 1.0

  const AchievementCard({
    Key? key,
    required this.achievement,
    this.isUnlocked = false,
    this.onTap,
    this.progress = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isUnlocked ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getRarityColor(),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getRarityColor().withOpacity(0.1),
                      _getRarityColor().withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? _getRarityColor()
                                    : Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildRarityBadge(),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUnlocked
            ? _getRarityColor().withOpacity(0.2)
            : Colors.grey[300],
        border: Border.all(
          color: _getRarityColor(),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          achievement.icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildRarityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRarityColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        achievement.rarityName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: _getRarityColor(),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Tamamlandı',
              style: TextStyle(
                color: _getRarityColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRarityColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${achievement.points} puan',
                style: TextStyle(
                  color: _getRarityColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              '${achievement.points} puan',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getRarityColor()),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          _getCategoryIcon(),
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          achievement.categoryName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (!isUnlocked)
          Text(
            'Kilitli',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

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

  IconData _getCategoryIcon() {
    switch (achievement.category) {
      case AchievementCategory.quiz:
        return Icons.quiz;
      case AchievementCategory.duel:
        return Icons.sports_esports;
      case AchievementCategory.multiplayer:
        return Icons.group;
      case AchievementCategory.social:
        return Icons.people;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}

/// Achievement list widget
class AchievementList extends StatelessWidget {
  final List<Achievement> achievements;
  final bool showUnlockedOnly;
  final Function(Achievement)? onAchievementTap;

  const AchievementList({
    Key? key,
    required this.achievements,
    this.showUnlockedOnly = false,
    this.onAchievementTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredAchievements = showUnlockedOnly
        ? achievements.where((a) => a.unlockedAt != null).toList()
        : achievements;

    if (filteredAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              showUnlockedOnly
                  ? 'Henüz rozet kazanmadın'
                  : 'Rozet bulunamadı',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        final isUnlocked = achievement.unlockedAt != null;
        final progress = isUnlocked ? 1.0 : _calculateProgress(achievement);

        return AchievementCard(
          achievement: achievement,
          isUnlocked: isUnlocked,
          progress: progress,
          onTap: () => onAchievementTap?.call(achievement),
        );
      },
    );
  }

  double _calculateProgress(Achievement achievement) {
    // This would need to be calculated based on user progress
    // For now, return a placeholder value
    return 0.0;
  }
}

/// Achievement category filter
class AchievementCategoryFilter extends StatelessWidget {
  final AchievementCategory? selectedCategory;
  final Function(AchievementCategory?) onCategorySelected;

  const AchievementCategoryFilter({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip(
            context,
            null,
            'Tümü',
            Icons.all_inclusive,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            AchievementCategory.quiz,
            'Quiz',
            Icons.quiz,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            AchievementCategory.duel,
            'Düello',
            Icons.sports_esports,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            AchievementCategory.multiplayer,
            'Çok Oyunculu',
            Icons.group,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            AchievementCategory.social,
            'Sosyal',
            Icons.people,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            AchievementCategory.streak,
            'Seri',
            Icons.local_fire_department,
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            AchievementCategory.special,
            'Özel',
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    AchievementCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedCategory == category;
    
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onCategorySelected(selected ? category : null);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
