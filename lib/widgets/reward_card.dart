// lib/widgets/reward_card.dart
// Reward card widget for displaying reward items

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/reward_item.dart';

class RewardCard extends StatelessWidget {
  final RewardItem rewardItem;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onUse;

  const RewardCard({
    super.key,
    required this.rewardItem,
    this.isUnlocked = false,
    this.isSelected = false,
    this.onTap,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isUnlocked ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getRarityColor(),
          width: isSelected ? 3 : 2,
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
                          rewardItem.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? _getRarityColor()
                                    : Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rewardItem.description,
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
              _buildTypeAndStatus(),
              const SizedBox(height: 8),
              if (isUnlocked && onUse != null) _buildActionButton(context),
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
          rewardItem.icon,
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
        rewardItem.rarityName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeAndStatus() {
    return Row(
      children: [
        Icon(
          _getTypeIcon(),
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          rewardItem.typeName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (isUnlocked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Açık',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock,
                  size: 12,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${rewardItem.unlockRequirement} rozet gerekli',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    String buttonText;
    VoidCallback onPressed;
    Color color;

    switch (rewardItem.type) {
      case RewardItemType.avatar:
        buttonText = isSelected ? 'Seçili' : 'Kullan';
        onPressed = isSelected ? () {} : (onUse ?? () {});
        color = isSelected ? Colors.grey : _getRarityColor();
        break;
      case RewardItemType.theme:
        buttonText = isSelected ? 'Aktif' : 'Uygula';
        onPressed = isSelected ? () {} : (onUse ?? () {});
        color = isSelected ? Colors.grey : _getRarityColor();
        break;
      case RewardItemType.feature:
        buttonText = 'Özellik';
        onPressed = () {};
        color = _getRarityColor();
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (rewardItem.rarity) {
      case RewardItemRarity.common:
        return Colors.grey;
      case RewardItemRarity.rare:
        return Colors.blue;
      case RewardItemRarity.epic:
        return Colors.purple;
      case RewardItemRarity.legendary:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon() {
    switch (rewardItem.type) {
      case RewardItemType.avatar:
        return Icons.person;
      case RewardItemType.theme:
        return Icons.palette;
      case RewardItemType.feature:
        return Icons.star;
    }
  }
}

/// Reward list widget
class RewardList extends StatelessWidget {
  final List<RewardItem> rewardItems;
  final RewardItemType? filterType;
  final Function(RewardItem)? onRewardTap;
  final Function(RewardItem)? onRewardUse;

  const RewardList({
    super.key,
    required this.rewardItems,
    this.filterType,
    this.onRewardTap,
    this.onRewardUse,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = filterType != null
        ? rewardItems.where((item) => item.type == filterType).toList()
        : rewardItems;

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Ödül bulunamadı',
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
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final reward = filteredItems[index];
        return RewardCard(
          rewardItem: reward,
          isUnlocked: reward.isUnlocked,
          isSelected: _isSelected(reward),
          onTap: () => onRewardTap?.call(reward),
          onUse: () => onRewardUse?.call(reward),
        );
      },
    );
  }

  bool _isSelected(RewardItem reward) {
    // This would need to be determined based on current user selections
    return false;
  }
}

/// Reward type filter
class RewardTypeFilter extends StatelessWidget {
  final RewardItemType? selectedType;
  final Function(RewardItemType?) onTypeSelected;

  const RewardTypeFilter({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTypeChip(
            context,
            null,
            'Tümü',
            Icons.all_inclusive,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            RewardItemType.avatar,
            'Avatar',
            Icons.person,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            RewardItemType.theme,
            'Tema',
            Icons.palette,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            RewardItemType.feature,
            'Özellik',
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    RewardItemType? type,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedType == type;
    
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onTypeSelected(selected ? type : null);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

/// Reward inventory summary widget
class RewardInventorySummary extends StatelessWidget {
  final int totalAvatars;
  final int totalThemes;
  final int totalFeatures;
  final int unlockedAvatars;
  final int unlockedThemes;
  final int unlockedFeatures;

  const RewardInventorySummary({
    super.key,
    required this.totalAvatars,
    required this.totalThemes,
    required this.totalFeatures,
    required this.unlockedAvatars,
    required this.unlockedThemes,
    required this.unlockedFeatures,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödül Envanteri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Avatarlar',
                    unlockedAvatars,
                    totalAvatars,
                    Icons.person,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Temalar',
                    unlockedThemes,
                    totalThemes,
                    Icons.palette,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Özellikler',
                    unlockedFeatures,
                    totalFeatures,
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int unlocked,
    int total,
    IconData icon,
    Color color,
  ) {
    final percentage = total > 0 ? (unlocked / total) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '$unlocked/$total',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}