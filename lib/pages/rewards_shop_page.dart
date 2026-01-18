// lib/pages/rewards_shop_page.dart
// Rewards Shop Page - Ödül mağazası ve envanter yönetimi

import 'package:flutter/material.dart';
import '../models/reward_item.dart';
import '../services/reward_service.dart';
import '../widgets/reward_card.dart';
import '../theme/app_theme.dart';

class RewardsShopPage extends StatefulWidget {
  const RewardsShopPage({super.key});

  @override
  State<RewardsShopPage> createState() => _RewardsShopPageState();
}

class _RewardsShopPageState extends State<RewardsShopPage>
    with TickerProviderStateMixin {
  final RewardService _rewardService = RewardService();
  late TabController _tabController;

  RewardItemType? _selectedType;
  List<RewardItem> _allRewards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRewards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    setState(() => _isLoading = true);

    try {
      _allRewards = _rewardService.getAllRewardItems();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ödüller yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ödül Mağazası'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mağaza'),
            Tab(text: 'Envanterim'),
            Tab(text: 'İstatistikler'),
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
                _buildShopTab(),
                _buildInventoryTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildShopTab() {
    final availableRewards = _selectedType != null
        ? _allRewards.where((r) => r.type == _selectedType).toList()
        : _allRewards;

    return Column(
      children: [
        _buildTypeFilter(),
        Expanded(
          child: availableRewards.isEmpty
              ? _buildEmptyShop()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableRewards.length,
                  itemBuilder: (context, index) {
                    final reward = availableRewards[index];
                    return RewardCard(
                      rewardItem: reward,
                      isUnlocked: reward.isUnlocked,
                      onTap: () => _showRewardDetails(context, reward),
                      onUse: () => _useReward(reward),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInventoryTab() {
    // This would show user's unlocked rewards
    // For now, show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Envanter sistemi yakında gelecek',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kazandığınız ödüller burada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    // This would show reward statistics
    // For now, show a placeholder with summary
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ödül İstatistikleri',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          RewardInventorySummary(
            totalAvatars: _allRewards.where((r) => r.type == RewardItemType.avatar).length,
            totalThemes: _allRewards.where((r) => r.type == RewardItemType.theme).length,
            totalFeatures: _allRewards.where((r) => r.type == RewardItemType.feature).length,
            unlockedAvatars: 0, // Would be loaded from user data
            unlockedThemes: 0, // Would be loaded from user data
            unlockedFeatures: 0, // Would be loaded from user data
          ),
          const SizedBox(height: 20),
          _buildRewardTypeStats(),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(null, 'Tümü', Icons.all_inclusive),
          const SizedBox(width: 8),
          _buildFilterChip(RewardItemType.avatar, 'Avatar', Icons.person),
          const SizedBox(width: 8),
          _buildFilterChip(RewardItemType.theme, 'Tema', Icons.palette),
          const SizedBox(width: 8),
          _buildFilterChip(RewardItemType.feature, 'Özellik', Icons.star),
        ],
      ),
    );
  }

  Widget _buildFilterChip(RewardItemType? type, String label, IconData icon) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedType = selected ? type : null);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyShop() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bu kategoride ödül bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı bir kategori seçmeyi deneyin',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTypeStats() {
    final avatarCount = _allRewards.where((r) => r.type == RewardItemType.avatar).length;
    final themeCount = _allRewards.where((r) => r.type == RewardItemType.theme).length;
    final featureCount = _allRewards.where((r) => r.type == RewardItemType.feature).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mevcut Ödül Türleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Avatarlar', avatarCount, Icons.person, Colors.blue),
            const SizedBox(height: 12),
            _buildStatRow('Temalar', themeCount, Icons.palette, Colors.purple),
            const SizedBox(height: 12),
            _buildStatRow('Özellikler', featureCount, Icons.star, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showRewardDetails(BuildContext context, RewardItem reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RewardDetailSheet(rewardItem: reward),
    );
  }

  Future<void> _useReward(RewardItem reward) async {
    // This would implement the reward usage logic
    // For now, just show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${reward.name} kullanıldı!')),
      );
    }
  }
}

class RewardDetailSheet extends StatelessWidget {
  final RewardItem rewardItem;

  const RewardDetailSheet({super.key, required this.rewardItem});

  @override
  Widget build(BuildContext context) {
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
                    border: Border.all(
                      color: _getRarityColor(),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      rewardItem.icon,
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
                        rewardItem.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: rewardItem.isUnlocked
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
                          rewardItem.rarityName,
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
              rewardItem.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Unlock requirements
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kilidi Açma Koşulu:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${rewardItem.unlockRequirement} rozet kazan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
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
                onPressed: rewardItem.isUnlocked ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: rewardItem.isUnlocked
                      ? _getRarityColor()
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  rewardItem.isUnlocked ? 'Kullan' : 'Kilitli',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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
}