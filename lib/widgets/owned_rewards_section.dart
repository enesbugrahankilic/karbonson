// lib/widgets/owned_rewards_section.dart
// Sahip Olunan Ödüller Bölümü - Real-time UI synchronization

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/reward_item.dart';
import '../models/user_progress.dart';
import '../services/reward_service.dart';
import 'reward_card.dart';

/// Widget for displaying owned rewards section
/// Updates in real-time when rewards are unlocked
class OwnedRewardsSection extends StatefulWidget {
  final UserProgress? userProgress;
  final bool showHeader;
  final bool compactMode;
  final VoidCallback? onRewardTap;
  final void Function(RewardItem)? onRewardUse;

  const OwnedRewardsSection({
    super.key,
    this.userProgress,
    this.showHeader = true,
    this.compactMode = false,
    this.onRewardTap,
    this.onRewardUse,
  });

  @override
  State<OwnedRewardsSection> createState() => _OwnedRewardsSectionState();
}

class _OwnedRewardsSectionState extends State<OwnedRewardsSection> {
  final RewardService _rewardService = RewardService();
  List<RewardItem> _unlockedRewards = [];
  List<RewardItem> _avatars = [];
  List<RewardItem> _themes = [];
  List<RewardItem> _features = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockedRewards();
    _subscribeToInventoryStream();
  }

  @override
  void didUpdateWidget(OwnedRewardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProgress != widget.userProgress) {
      _loadUnlockedRewards();
    }
  }

  void _subscribeToInventoryStream() {
    _rewardService.inventoryStream.listen((inventory) {
      if (mounted) {
        _refreshRewardsFromInventory(inventory);
      }
    });
  }

  Future<void> _loadUnlockedRewards() async {
    setState(() => _isLoading = true);
    try {
      final unlockedRewards = await _getUnlockedRewardsFromService();
      _categorizeRewards(unlockedRewards);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load unlocked rewards: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<List<RewardItem>> _getUnlockedRewardsFromService() async {
    final inventory = await _rewardService.getCurrentInventory();
    final allRewards = _rewardService.getAllRewardItems();
    final unlockedIds = [
      ...inventory.unlockedAvatarIds,
      ...inventory.unlockedThemeIds,
      ...inventory.unlockedFeatureIds,
    ];
    
    return allRewards
        .where((r) => unlockedIds.contains(r.id))
        .map((r) => r.copyWith(isUnlocked: true))
        .toList();
  }

  void _refreshRewardsFromInventory(UserRewardInventory inventory) {
    final allRewards = _rewardService.getAllRewardItems();
    final unlockedIds = [
      ...inventory.unlockedAvatarIds,
      ...inventory.unlockedThemeIds,
      ...inventory.unlockedFeatureIds,
    ];

    final unlockedRewards = allRewards
        .where((r) => unlockedIds.contains(r.id))
        .map((r) => r.copyWith(isUnlocked: true))
        .toList();

    _categorizeRewards(unlockedRewards);
    if (mounted) {
      setState(() {});
    }
  }

  void _categorizeRewards(List<RewardItem> rewards) {
    _unlockedRewards = rewards;
    _avatars = rewards.where((r) => r.type == RewardItemType.avatar).toList();
    _themes = rewards.where((r) => r.type == RewardItemType.theme).toList();
    _features = rewards.where((r) => r.type == RewardItemType.feature).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_unlockedRewards.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) _buildHeader(),
        if (widget.compactMode) _buildCompactView(),
        if (!widget.compactMode) _buildFullView(),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 12),
            Text('Ödüller yükleniyor...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Henüz ödülünüz yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Quizler tamamlayarak veya görevleri bitirerek ödül kazanabilirsiniz',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalCount = _unlockedRewards.length;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sahip Olunan Ödüller',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalCount ödül kazanıldı',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _showFullInventoryDialog();
            },
            child: const Text('Tümünü Gör'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _unlockedRewards.map((reward) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildCompactRewardItem(reward),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactRewardItem(RewardItem reward) {
    return InkWell(
      onTap: () => widget.onRewardTap?.call(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getRarityColor(reward.rarity).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(reward.rarity).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reward.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              reward.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          _buildTabBar(),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildRewardList(_unlockedRewards),
                _buildRewardList(_avatars),
                _buildRewardList(_themes),
                _buildRewardList(_features),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      tabs: const [
        Tab(text: 'Tümü'),
        Tab(text: 'Avatar'),
        Tab(text: 'Tema'),
        Tab(text: 'Özellik'),
      ],
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
    );
  }

  Widget _buildRewardList(List<RewardItem> rewards) {
    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Bu kategoride ödül yok',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return RewardCard(
          rewardItem: reward,
          isUnlocked: true,
          userProgress: widget.userProgress,
          onTap: () {
            widget.onRewardTap?.call();
            _showRewardDetails(reward);
          },
          onUse: () => widget.onRewardUse?.call(reward),
        );
      },
    );
  }

  void _showRewardDetails(RewardItem reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RewardDetailSheet(reward: reward),
    );
  }

  void _showFullInventoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sahip Olunan Ödüller'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _unlockedRewards.length,
            itemBuilder: (context, index) {
              final reward = _unlockedRewards[index];
              return ListTile(
                leading: Text(reward.icon, style: const TextStyle(fontSize: 24)),
                title: Text(reward.name),
                subtitle: Text(reward.typeName),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRarityColor(reward.rarity).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reward.rarityName,
                    style: TextStyle(
                      color: _getRarityColor(reward.rarity),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(RewardItemRarity rarity) {
    switch (rarity) {
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
}

/// Detail sheet for owned reward
class RewardDetailSheet extends StatelessWidget {
  final RewardItem reward;

  const RewardDetailSheet({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                    color: _getRarityColor().withOpacity(0.2),
                    border: Border.all(color: _getRarityColor(), width: 2),
                  ),
                  child: Center(
                    child: Text(reward.icon, style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getRarityColor(),
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
                          reward.rarityName,
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
              reward.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Type info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(_getTypeIcon(), size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(reward.typeName, style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Açıldı', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getRarityColor().withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _useReward(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getRarityColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _getActionButtonText(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _useReward(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reward.name} kullanıldı!'),
        backgroundColor: _getRarityColor(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getActionButtonText() {
    switch (reward.type) {
      case RewardItemType.avatar:
        return 'Avatar Olarak Kullan';
      case RewardItemType.theme:
        return 'Temayı Uygula';
      case RewardItemType.feature:
        return 'Özelliği Etkinleştir';
    }
  }

  IconData _getTypeIcon() {
    switch (reward.type) {
      case RewardItemType.avatar:
        return Icons.person;
      case RewardItemType.theme:
        return Icons.palette;
      case RewardItemType.feature:
        return Icons.star;
    }
  }

  Color _getRarityColor() {
    switch (reward.rarity) {
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
}

