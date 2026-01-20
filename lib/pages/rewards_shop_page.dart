// lib/pages/rewards_shop_page.dart
// Modern Rewards Shop Page - Card-based UI, Filters, Animations
// Redesigned with theme integration and modern aesthetics

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/reward_item.dart';
import '../models/user_progress.dart';
import '../services/reward_service.dart';
import '../services/user_progress_service.dart';
import '../widgets/reward_card.dart';
import '../widgets/owned_rewards_section.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';

class RewardsShopPage extends StatefulWidget {
  const RewardsShopPage({super.key});

  @override
  State<RewardsShopPage> createState() => _RewardsShopPageState();
}

class _RewardsShopPageState extends State<RewardsShopPage>
    with TickerProviderStateMixin {
  final RewardService _rewardService = RewardService();
  final UserProgressService _userProgressService = UserProgressService();
  late TabController _tabController;

  // Filter states
  RewardItemType? _selectedType;
  RewardItemRarity? _selectedRarity;
  RewardUnlockStatus? _selectedStatus;
  String _searchQuery = '';
  
  // Sort options
  SortOption _sortOption = SortOption.newest;
  bool _sortAscending = false;

  List<RewardItem> _allRewards = [];
  UserProgress? _userProgress;
  bool _isLoading = true;
  bool _isUnlocking = false;
  String? _lastUnlockedRewardId;
  UserRewardInventory? _currentInventory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _subscribeToRewardStream();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Subscribe to reward service stream for real-time UI updates
  void _subscribeToRewardStream() {
    _rewardService.inventoryStream.listen((inventory) {
      if (mounted) {
        setState(() {
          _currentInventory = inventory;
          _isUnlocking = false;
        });
        
        if (_lastUnlockedRewardId != null && 
            _isRewardInInventory(_lastUnlockedRewardId!, inventory)) {
          _showRewardUnlockedAnimation(_lastUnlockedRewardId!);
          _lastUnlockedRewardId = null;
        }
      }
    });
  }

  bool _isRewardInInventory(String rewardId, UserRewardInventory inventory) {
    return inventory.unlockedAvatarIds.contains(rewardId) ||
           inventory.unlockedThemeIds.contains(rewardId) ||
           inventory.unlockedFeatureIds.contains(rewardId);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      _allRewards = _rewardService.getAllRewardItems();
      _userProgress = await _userProgressService.getUserProgress();
      _currentInventory = await _rewardService.getCurrentInventory();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  /// Backend sync: Unlock reward and update UI immediately
  Future<void> _unlockReward(RewardItem reward) async {
    if (_isUnlocking) return;
    
    setState(() => _isUnlocking = true);
    _lastUnlockedRewardId = reward.id;

    try {
      final success = await _rewardService.unlockReward(reward.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${reward.name} başarıyla açıldı!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ödül zaten açılmış veya kilidi açılamıyor'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to unlock reward: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ödül açılırken hata oluştu: $e')),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isUnlocking = false);
    }
  }

  void _showRewardUnlockedAnimation(String rewardId) {
    final reward = _rewardService.getRewardItemById(rewardId);
    if (reward == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _RewardUnlockedDialog(reward: reward);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: child,
        );
      },
    );
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
          ? _buildLoadingState()
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 16),
          Text('Ödüller yükleniyor...'),
        ],
      ),
    );
  }

  Widget _buildShopTab() {
    final filteredRewards = _getFilteredRewards();

    return Column(
      children: [
        // Point wallet at top
        PointWalletCard(
          points: _userProgress?.totalPoints ?? 0,
          streakDays: _userProgress?.loginStreak ?? 0,
        ),
        
        // Search bar
        _buildSearchBar(),
        
        // Filter chips
        _buildFilterSection(),
        
        // Sort options
        _buildSortOptions(),
        
        // Rewards list
        Expanded(
          child: filteredRewards.isEmpty
              ? _buildEmptyShop()
              : _buildRewardsGrid(filteredRewards),
        ),
        
        if (_isUnlocking)
          Container(
            padding: const EdgeInsets.all(16),
            child: const LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Ödül ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          filled: true,
          fillColor: ThemeColors.getInputBackground(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Type filters
          RewardFilterChip(
            label: 'Tümü',
            icon: Icons.all_inclusive,
            isSelected: _selectedType == null,
            onTap: () => setState(() => _selectedType = null),
          ),
          const SizedBox(width: 8),
          RewardFilterChip(
            label: 'Avatar',
            icon: Icons.person,
            isSelected: _selectedType == RewardItemType.avatar,
            onTap: () => setState(() => _selectedType = _selectedType == RewardItemType.avatar ? null : RewardItemType.avatar),
          ),
          const SizedBox(width: 8),
          RewardFilterChip(
            label: 'Tema',
            icon: Icons.palette,
            isSelected: _selectedType == RewardItemType.theme,
            onTap: () => setState(() => _selectedType = _selectedType == RewardItemType.theme ? null : RewardItemType.theme),
          ),
          const SizedBox(width: 8),
          RewardFilterChip(
            label: 'Özellik',
            icon: Icons.star,
            isSelected: _selectedType == RewardItemType.feature,
            onTap: () => setState(() => _selectedType = _selectedType == RewardItemType.feature ? null : RewardItemType.feature),
          ),
          const SizedBox(width: 16),
          
          // Status filters
          RewardFilterChip(
            label: 'Açılabilir',
            icon: Icons.star,
            isSelected: _selectedStatus == RewardUnlockStatus.available,
            activeColor: Colors.blue,
            onTap: () => setState(() => _selectedStatus = _selectedStatus == RewardUnlockStatus.available ? null : RewardUnlockStatus.available),
          ),
          const SizedBox(width: 8),
          RewardFilterChip(
            label: 'Açıldı',
            icon: Icons.check_circle,
            isSelected: _selectedStatus == RewardUnlockStatus.unlocked,
            activeColor: Colors.green,
            onTap: () => setState(() => _selectedStatus = _selectedStatus == RewardUnlockStatus.unlocked ? null : RewardUnlockStatus.unlocked),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('Sırala:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          DropdownButton<SortOption>(
            value: _sortOption,
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortOption = value);
              }
            },
            items: const [
              DropdownMenuItem(value: SortOption.newest, child: Text('Yeniden eskiye')),
              DropdownMenuItem(value: SortOption.oldest, child: Text('Eskiden yeniye')),
              DropdownMenuItem(value: SortOption.rarity, child: Text('Nadirlik')),
              DropdownMenuItem(value: SortOption.progress, child: Text('İlerleme')),
              DropdownMenuItem(value: SortOption.name, child: Text('İsim')),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () => setState(() => _sortAscending = !_sortAscending),
            tooltip: _sortAscending ? 'Artan' : 'Azalan',
          ),
        ],
      ),
    );
  }

  List<RewardItem> _getFilteredRewards() {
    final rewardsWithStatus = _allRewards.map((reward) {
      final isUnlocked = _isRewardUnlocked(reward);
      final unlockProgress = reward.getUnlockProgress(_userProgress);
      return reward.copyWith(isUnlocked: isUnlocked);
    }).toList();

    // Apply type filter
    var filtered = _selectedType != null
        ? rewardsWithStatus.where((r) => r.type == _selectedType).toList()
        : rewardsWithStatus;

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((r) {
        final progress = r.getUnlockProgress(_userProgress);
        return progress.status == _selectedStatus;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.name.toLowerCase().contains(query) ||
               r.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    filtered = _applySorting(filtered);

    return filtered;
  }

  List<RewardItem> _applySorting(List<RewardItem> rewards) {
    switch (_sortOption) {
      case SortOption.newest:
        return _sortAscending 
            ? [...rewards].reversed.toList() 
            : [...rewards];
      case SortOption.oldest:
        return _sortAscending 
            ? [...rewards] 
            : [...rewards].reversed.toList();
      case SortOption.rarity:
        return [...rewards]..sort((a, b) {
          final rarityOrder = [RewardItemRarity.common, RewardItemRarity.rare, RewardItemRarity.epic, RewardItemRarity.legendary];
          final aIndex = rarityOrder.indexOf(a.rarity);
          final bIndex = rarityOrder.indexOf(b.rarity);
          return _sortAscending ? aIndex.compareTo(bIndex) : bIndex.compareTo(aIndex);
        });
      case SortOption.progress:
        return [...rewards]..sort((a, b) {
          final aProgress = a.getUnlockProgress(_userProgress).progressPercentage;
          final bProgress = b.getUnlockProgress(_userProgress).progressPercentage;
          return _sortAscending ? aProgress.compareTo(bProgress) : bProgress.compareTo(aProgress);
        });
      case SortOption.name:
        return [...rewards]..sort((a, b) {
          return _sortAscending 
              ? a.name.compareTo(b.name) 
              : b.name.compareTo(a.name);
        });
    }
  }

  Widget _buildRewardsGrid(List<RewardItem> rewards) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final canUnlock = reward.canUserUnlock(_userProgress) && !reward.isUnlocked;
        
        return ModernRewardCard(
          rewardItem: reward,
          isUnlocked: reward.isUnlocked,
          userProgress: _userProgress,
          onTap: () => _showRewardDetails(context, reward),
          onUse: canUnlock ? () => _unlockReward(reward) : null,
        );
      },
    );
  }

  bool _isRewardUnlocked(RewardItem reward) {
    if (_currentInventory == null) return false;
    
    switch (reward.type) {
      case RewardItemType.avatar:
        return _currentInventory!.hasAvatarUnlocked(reward.id);
      case RewardItemType.theme:
        return _currentInventory!.hasThemeUnlocked(reward.id);
      case RewardItemType.feature:
        return _currentInventory!.hasFeatureUnlocked(reward.id);
    }
  }

  Widget _buildInventoryTab() {
    return OwnedRewardsSection(
      userProgress: _userProgress,
      showHeader: true,
      compactMode: false,
      onRewardTap: (reward) {},
      onRewardUse: (reward) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${reward.name} kullanıldı!')),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    final unlockedAvatars = _allRewards
        .where((r) => r.type == RewardItemType.avatar && _isRewardUnlocked(r))
        .length;
    final unlockedThemes = _allRewards
        .where((r) => r.type == RewardItemType.theme && _isRewardUnlocked(r))
        .length;
    final unlockedFeatures = _allRewards
        .where((r) => r.type == RewardItemType.feature && _isRewardUnlocked(r))
        .length;

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
            unlockedAvatars: unlockedAvatars,
            unlockedThemes: unlockedThemes,
            unlockedFeatures: unlockedFeatures,
          ),
          const SizedBox(height: 20),
          _buildRewardTypeStats(),
          const SizedBox(height: 20),
          _buildProgressSection(),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    if (_userProgress == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İlerleme Durumunuz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressRow('Toplam Puan', _userProgress!.totalPoints.toString(), Icons.stars),
            const SizedBox(height: 12),
            _buildProgressRow('Seviye', _userProgress!.level.toString(), Icons.arrow_upward),
            const SizedBox(height: 12),
            _buildProgressRow('Tamamlanan Quiz', _userProgress!.completedQuizzes.toString(), Icons.quiz),
            const SizedBox(height: 12),
            _buildProgressRow('Düello Kazanımları', _userProgress!.duelWins.toString(), Icons.sports_kabaddi),
            const SizedBox(height: 12),
            _buildProgressRow('Arkadaş Sayısı', _userProgress!.friendsCount.toString(), Icons.people),
            const SizedBox(height: 12),
            _buildProgressRow('Günlük Seri', _userProgress!.loginStreak.toString(), Icons.local_fire_department),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyShop() {
    return RewardEmptyState(
      title: 'Bu kategoride ödül bulunamadı',
      subtitle: 'Farklı bir kategori veya arama terimi deneyin',
      icon: Icons.card_giftcard,
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
      builder: (context) => RewardDetailSheet(reward: reward),
    );
  }
}

/// Sort options for rewards
enum SortOption { newest, oldest, rarity, progress, name }

/// Dialog shown when a reward is successfully unlocked
class _RewardUnlockedDialog extends StatelessWidget {
  final RewardItem reward;

  const _RewardUnlockedDialog({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor().withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated reward icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getRarityColor().withOpacity(0.2),
                  border: Border.all(color: _getRarityColor(), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _getRarityColor().withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    reward.icon,
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Tebrikler!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Reward name
            Text(
              reward.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _getRarityColor(),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getRarityColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                reward.rarityName,
                style: TextStyle(
                  color: _getRarityColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              reward.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Harika!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
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

