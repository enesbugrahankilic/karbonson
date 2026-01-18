// lib/widgets/enhanced_reward_card.dart
// Gelişmiş Ödül Kartı Widget'ı

import 'package:flutter/material.dart';
import '../models/reward_models.dart';

class EnhancedRewardCard extends StatelessWidget {
  final Reward reward;
  final bool isSelected;
  final bool canAfford;
  final VoidCallback? onTap;
  final VoidCallback? onEquip;
  final VoidCallback? onPurchase;

  const EnhancedRewardCard({
    super.key,
    required this.reward,
    this.isSelected = false,
    this.canAfford = false,
    this.onTap,
    this.onEquip,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: reward.status == RewardStatus.unlocked ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: rarityColor,
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
            gradient: reward.status == RewardStatus.unlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      rarityColor.withOpacity(0.15),
                      rarityColor.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIcon(rarityColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: reward.status == RewardStatus.unlocked
                                    ? rarityColor
                                    : Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildRarityBadge(rarityColor),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatusAndProgress(),
              if (reward.status == RewardStatus.unlocked && _hasAction()) ...[
                const SizedBox(height: 12),
                _buildActionButton(context, rarityColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color rarityColor) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reward.status == RewardStatus.unlocked
            ? rarityColor.withOpacity(0.2)
            : Colors.grey[300],
        border: Border.all(
          color: rarityColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          reward.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Widget _buildRarityBadge(Color rarityColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: rarityColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        reward.rarityName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusAndProgress() {
    final isUnlocked = reward.status == RewardStatus.unlocked;
    
    return Row(
      children: [
        Icon(
          _getTypeIcon(),
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          reward.typeName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        if (isUnlocked) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 12, color: Colors.green[600]),
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
          ),
        ] else if (reward.price > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: canAfford ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  canAfford ? Icons.shopping_cart : Icons.lock,
                  size: 12,
                  color: canAfford ? Colors.blue[600] : Colors.orange[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${reward.price} KP',
                  style: TextStyle(
                    color: canAfford ? Colors.blue[600] : Colors.orange[600],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 12, color: Colors.orange[600]),
                const SizedBox(width: 4),
                Text(
                  '${reward.unlockRequirement} gerekli',
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
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Color color) {
    String buttonText;
    VoidCallback onPressed;
    bool isEnabled;

    switch (reward.type) {
      case RewardType.avatar:
        buttonText = isSelected ? 'Seçili' : 'Kullan';
        onPressed = isSelected ? () {} : (onEquip ?? () {});
        isEnabled = true;
        break;
      case RewardType.theme:
        buttonText = isSelected ? 'Aktif' : 'Uygula';
        onPressed = isSelected ? () {} : (onEquip ?? () {});
        isEnabled = true;
        break;
      case RewardType.feature:
        buttonText = 'Etkinleştir';
        onPressed = onEquip ?? () {};
        isEnabled = true;
        break;
      default:
        buttonText = 'Satın Al';
        onPressed = canAfford ? (onPurchase ?? () {}) : () {};
        isEnabled = canAfford;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  bool _hasAction() {
    return reward.type == RewardType.avatar ||
           reward.type == RewardType.theme ||
           reward.type == RewardType.feature ||
           reward.price > 0;
  }

  Color _getRarityColor() {
    switch (reward.rarity) {
      case RewardRarity.common: return Colors.grey;
      case RewardRarity.uncommon: return Colors.green;
      case RewardRarity.rare: return Colors.blue;
      case RewardRarity.epic: return Colors.purple;
      case RewardRarity.legendary: return Colors.orange;
      case RewardRarity.mythic: return Colors.red;
    }
  }

  IconData _getTypeIcon() {
    switch (reward.type) {
      case RewardType.avatar: return Icons.person;
      case RewardType.theme: return Icons.palette;
      case RewardType.feature: return Icons.star;
      case RewardType.currency: return Icons.attach_money;
      case RewardType.badge: return Icons.emoji_events;
      case RewardType.title: return Icons.title;
      case RewardType.item: return Icons.inventory_2;
    }
  }
}

/// Puan Cüzdanı Widget'ı
class PointWalletWidget extends StatelessWidget {
  final PointWallet wallet;
  final int streakDays;

  const PointWalletWidget({super.key, required this.wallet, this.streakDays = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                Text(
                  '${wallet.availablePoints}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  'KP',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.amber[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsRow(context),
            if (streakDays > 0) ...[
              const SizedBox(height: 16),
              _buildStreakBadge(streakDays),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, 'Toplam', '${wallet.totalPoints}', Icons.savings),
        _buildStatItem(context, 'Ömür Boyu', '${wallet.lifetimePoints}', Icons.history),
        _buildStatItem(context, 'Seviye', '${wallet.levelPoints ~/ 100 + 1}', Icons.grade),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
        ),
      ],
    );
  }

  Widget _buildStreakBadge(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.2), Colors.red.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            '$days Gün Seri',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// İlerleme Çubuğu Widget'ı
class ProgressBarWidget extends StatelessWidget {
  final double progress;
  final String label;
  final String currentValue;
  final String targetValue;
  final Color color;
  final bool showPercentage;

  const ProgressBarWidget({
    super.key,
    required this.progress,
    required this.label,
    required this.currentValue,
    required this.targetValue,
    this.color = Colors.blue,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (showPercentage)
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$currentValue / $targetValue',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// Kilometre Taşı Kartı Widget'ı
class MilestoneCard extends StatelessWidget {
  final MilestoneReward milestone;
  final int currentValue;
  final VoidCallback? onClaim;

  const MilestoneCard({super.key, required this.milestone, required this.currentValue, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final progress = milestone.getProgress(currentValue);
    final isAchieved = milestone.isAchieved(currentValue);
    final reward = milestone.reward;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isAchieved ? Colors.green.withOpacity(0.2) : Colors.grey[200],
                    border: Border.all(
                      color: isAchieved ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      milestone.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        milestone.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                if (isAchieved && !milestone.isClaimed)
                  ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Al'),
                  )
                else if (milestone.isClaimed)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            ProgressBarWidget(
              progress: progress,
              label: 'İlerleme',
              currentValue: currentValue.toString(),
              targetValue: milestone.targetValue.toString(),
              color: isAchieved ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: Text(
                    reward.icon,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${reward.name} (${reward.rarityName})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRarityColor(reward.rarity),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(RewardRarity rarity) {
    switch (rarity) {
      case RewardRarity.common: return Colors.grey;
      case RewardRarity.uncommon: return Colors.green;
      case RewardRarity.rare: return Colors.blue;
      case RewardRarity.epic: return Colors.purple;
      case RewardRarity.legendary: return Colors.orange;
      case RewardRarity.mythic: return Colors.red;
    }
  }
}

/// Seri (Streak) Gösterge Widget'ı
class StreakWidget extends StatelessWidget {
  final UserStreak streak;
  final List<StreakReward> streakRewards;

  const StreakWidget({super.key, required this.streak, required this.streakRewards});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
                const SizedBox(width: 12),
                Text(
                  '${streak.currentStreak}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gün',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.orange,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              streak.currentStreak == streak.longestStreak
                  ? 'En iyi serin!'
                  : 'En iyi: ${streak.longestStreak} gün',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 20),
            _buildRewardsProgress(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsProgress(BuildContext context) {
    return Column(
      children: streakRewards.map((reward) {
        final isAchieved = streak.currentStreak >= reward.streakDays;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                isAchieved ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isAchieved ? Colors.green : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                reward.title,
                style: TextStyle(
                  color: isAchieved ? Colors.green[700] : Colors.grey[600],
                  fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              Text(
                '+${reward.pointsBonus} KP',
                style: TextStyle(
                  color: isAchieved ? Colors.green : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
