// lib/pages/won_boxes_page.dart
// Kazanılan Kutular (Won Boxes) Page - Ödül bölümü için açılmamış kutular

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/loot_box.dart';
import '../models/loot_box_reward.dart';
import '../services/loot_box_service.dart';
import '../widgets/loot_box_widget.dart';
import '../utils/loot_box_animations.dart';

/// Sort options enum
enum SortOption {
  newest,
  oldest,
  rarity,
  type,
  expiry,
}

/// LootBox result class
class LootBoxOpenResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserLootBox? openedBox;
  final List<OpenedReward>? rewards;

  LootBoxOpenResult._({
    required this.isSuccess,
    this.errorMessage,
    this.openedBox,
    this.rewards,
  });

  factory LootBoxOpenResult.success({
    required UserLootBox openedBox,
    required List<OpenedReward> rewards,
  }) {
    return LootBoxOpenResult._(
      isSuccess: true,
      openedBox: openedBox,
      rewards: rewards,
    );
  }

  factory LootBoxOpenResult.failure(String error) {
    return LootBoxOpenResult._(
      isSuccess: false,
      errorMessage: error,
    );
  }
}

/// Kazanılan Kutular Sayfası - Açılmamış kutuların listelendiği ekran
class WonBoxesPage extends StatefulWidget {
  const WonBoxesPage({super.key});

  @override
  State<WonBoxesPage> createState() => _WonBoxesPageState();
}

class _WonBoxesPageState extends State<WonBoxesPage> with TickerProviderStateMixin {
  final LootBoxService _lootBoxService = LootBoxService();
  
  List<UserLootBox> _unopenedBoxes = [];
  List<UserLootBox> _filteredBoxes = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter and sort options
  LootBoxType? _selectedFilterType;
  LootBoxRarity? _selectedFilterRarity;
  SortOption _sortOption = SortOption.newest;
  bool _sortAscending = false;

  // Tab controller for view types
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeService();
    _subscribeToStreams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _lootBoxService.initializeForUser();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Servis başlatılamadı: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToStreams() {
    _lootBoxService.unopenedBoxesStream.listen((boxes) {
      if (mounted) {
        setState(() {
          _unopenedBoxes = boxes;
          _applyFilters();
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kutular yüklenemedi: $error';
          _isLoading = false;
        });
      }
    });

    // Listen for reward reveal to refresh list
    _lootBoxService.rewardRevealedStream.listen((reward) {
      if (reward != null && mounted) {
        _refreshBoxes();
      }
    });
  }

  Future<void> _refreshBoxes() async {
    setState(() => _isLoading = true);
    try {
      final boxes = await _lootBoxService.getUnopenedBoxes();
      if (mounted) {
        setState(() {
          _unopenedBoxes = boxes;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kutular yenilenemedi: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<UserLootBox> result = List.from(_unopenedBoxes);

    // Filter by type
    if (_selectedFilterType != null) {
      result = result.where((box) => box.boxType == _selectedFilterType).toList();
    }

    // Filter by rarity
    if (_selectedFilterRarity != null) {
      result = result.where((box) => box.rarity == _selectedFilterRarity).toList();
    }

    // Apply sorting
    result = _applySorting(result);

    setState(() {
      _filteredBoxes = result;
    });
  }

  List<UserLootBox> _applySorting(List<UserLootBox> boxes) {
    switch (_sortOption) {
      case SortOption.newest:
        boxes.sort((a, b) => _sortAscending
            ? a.obtainedAt.compareTo(b.obtainedAt)
            : b.obtainedAt.compareTo(a.obtainedAt));
        break;
      case SortOption.oldest:
        boxes.sort((a, b) => _sortAscending
            ? b.obtainedAt.compareTo(a.obtainedAt)
            : a.obtainedAt.compareTo(b.obtainedAt));
        break;
      case SortOption.rarity:
        boxes.sort((a, b) => _sortAscending
            ? a.rarity.index.compareTo(b.rarity.index)
            : b.rarity.index.compareTo(a.rarity.index));
        break;
      case SortOption.type:
        boxes.sort((a, b) => _sortAscending
            ? a.boxType.index.compareTo(b.boxType.index)
            : b.boxType.index.compareTo(a.boxType.index));
        break;
      case SortOption.expiry:
        boxes.sort((a, b) {
          final aExpiry = a.expiresAt ?? DateTime.now().add(const Duration(days: 9999));
          final bExpiry = b.expiresAt ?? DateTime.now().add(const Duration(days: 9999));
          return _sortAscending
              ? aExpiry.compareTo(bExpiry)
              : bExpiry.compareTo(aExpiry);
        });
        break;
    }
    return boxes;
  }

  Future<void> _openBox(UserLootBox box) async {
    try {
      final result = await _lootBoxService.openLootBox(box.id);
      
      if (result.isSuccess && result.rewards != null && result.rewards!.isNotEmpty) {
        if (mounted) {
          showLootBoxOpeningDialog(
            context: context,
            lootBox: box,
            reward: result.rewards!.first,
            onClose: () {
              Navigator.of(context).pop();
              _refreshBoxes();
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Kutu açılamadı'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtrele ve Sırala',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Filter by Type
            const Text(
              'Kutu Tipi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeFilterChip(null, 'Tümü'),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip(LootBoxType.quiz, 'Quiz'),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip(LootBoxType.daily, 'Günlük'),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip(LootBoxType.achievement, 'Başarı'),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip(LootBoxType.challenge, 'Görev'),
                  const SizedBox(width: 8),
                  _buildTypeFilterChip(LootBoxType.seasonal, 'Mevsimlik'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Filter by Rarity
            const Text(
              'Nadirlik',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRarityFilterChip(null, 'Tümü'),
                  const SizedBox(width: 8),
                  _buildRarityFilterChip(LootBoxRarity.common, 'Sıradan'),
                  const SizedBox(width: 8),
                  _buildRarityFilterChip(LootBoxRarity.rare, 'Nadir'),
                  const SizedBox(width: 8),
                  _buildRarityFilterChip(LootBoxRarity.epic, 'Destansı'),
                  const SizedBox(width: 8),
                  _buildRarityFilterChip(LootBoxRarity.legendary, 'Efsanevi'),
                  const SizedBox(width: 8),
                  _buildRarityFilterChip(LootBoxRarity.mythic, 'Mitolojik'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Sort options
            const Text(
              'Sırala',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip(SortOption.newest, 'En Yeni'),
                  const SizedBox(width: 8),
                  _buildSortChip(SortOption.oldest, 'En Eski'),
                  const SizedBox(width: 8),
                  _buildSortChip(SortOption.rarity, 'Nadirlik'),
                  const SizedBox(width: 8),
                  _buildSortChip(SortOption.type, 'Tip'),
                  const SizedBox(width: 8),
                  _buildSortChip(SortOption.expiry, 'Süre'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Reset filters button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilterType = null;
                  _selectedFilterRarity = null;
                  _sortOption = SortOption.newest;
                });
                _applyFilters();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Filtreleri Sıfırla'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip(LootBoxType? type, String label) {
    final isSelected = _selectedFilterType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilterType = selected ? type : null;
        });
        _applyFilters();
        Navigator.of(context).pop();
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildRarityFilterChip(LootBoxRarity? rarity, String label) {
    final isSelected = _selectedFilterRarity == rarity;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilterRarity = selected ? rarity : null;
        });
        _applyFilters();
        Navigator.of(context).pop();
      },
      selectedColor: LootBoxColors.getRarityColor(rarity ?? LootBoxRarity.common).withOpacity(0.2),
      checkmarkColor: LootBoxColors.getRarityColor(rarity ?? LootBoxRarity.common),
    );
  }

  Widget _buildSortChip(SortOption option, String label) {
    final isSelected = _sortOption == option;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            if (_sortOption == option) {
              _sortAscending = !_sortAscending;
            } else {
              _sortOption = option;
              _sortAscending = false;
            }
          });
          _applyFilters();
          Navigator.of(context).pop();
        }
      },
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
    );
  }

  IconData _getBoxIcon(LootBoxType type) {
    switch (type) {
      case LootBoxType.quiz:
        return Icons.quiz;
      case LootBoxType.daily:
        return Icons.calendar_today;
      case LootBoxType.achievement:
        return Icons.emoji_events;
      case LootBoxType.challenge:
        return Icons.workspace_premium;
      case LootBoxType.returnReward:
        return Icons.replay;
      case LootBoxType.seasonal:
        return Icons.ac_unit;
      case LootBoxType.login:
        return Icons.login;
      case LootBoxType.special:
        return Icons.star;
      case LootBoxType.premium:
        return Icons.diamond;
    }
  }

  String _formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    final diff = expiry.difference(now);

    if (diff.inDays > 0) {
      return '${diff.inDays} gün kaldı';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} saat kaldı';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika kaldı';
    }
    return 'Süresi dolmak üzere';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _unopenedBoxes.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kazanılan Kutular'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Box count badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Badge(
              label: Text('$totalCount'),
              backgroundColor: totalCount > 0 ? Colors.green : Colors.grey,
              child: const Icon(Icons.inbox),
            ),
          ),
          // Filter button
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele ve Sırala',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.grid_view),
              text: 'Grid',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Liste',
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: _unopenedBoxes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_unopenedBoxes.isNotEmpty) {
                  _openBox(_unopenedBoxes.first);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Tümünü Aç'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshBoxes,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_unopenedBoxes.isEmpty) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildGridView(),
        _buildListView(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Açılmamış Kutu Yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Quizleri tamamlayarak, günlük giriş yaparak veya başarılar kazanarak kutular kazanabilirsiniz!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/quiz');
            },
            icon: const Icon(Icons.quiz),
            label: const Text('Quiz Başlat'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: _refreshBoxes,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredBoxes.length,
        itemBuilder: (context, index) {
          final box = _filteredBoxes[index];
          return _buildGridItem(box);
        },
      ),
    );
  }

  Widget _buildGridItem(UserLootBox box) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: LootBoxColors.getRarityColor(box.rarity).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _openBox(box),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loot box widget
            LootBoxWidget(
              lootBox: box,
              size: 80,
              onTap: () => _openBox(box),
              showRarityBadge: true,
            ),
            const SizedBox(height: 8),
            // Box type name
            Text(
              box.boxTypeName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // Source description
            if (box.sourceDescription != null) ...[
              const SizedBox(height: 4),
              Text(
                box.sourceDescription!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Expiry warning
            if (box.expiresAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatExpiry(box.expiresAt!),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: box.expiresAt!.difference(DateTime.now()).inDays < 3
                          ? Colors.orange
                          : Colors.grey,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBoxes.length,
      itemBuilder: (context, index) {
        final box = _filteredBoxes[index];
        return _buildListItem(box);
      },
    );
  }

  Widget _buildListItem(UserLootBox box) {
    final rarityColor = LootBoxColors.getRarityColor(box.rarity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rarityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _openBox(box),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Box icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      rarityColor.withOpacity(0.3),
                      rarityColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: rarityColor, width: 2),
                ),
                child: Icon(
                  _getBoxIcon(box.boxType),
                  size: 30,
                  color: rarityColor,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          box.rarityName,
                          style: TextStyle(
                            color: rarityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Expiry badge if applicable
                        if (box.expiresAt != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: box.expiresAt!.difference(DateTime.now()).inDays < 3
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatExpiry(box.expiresAt!),
                              style: TextStyle(
                                color: box.expiresAt!.difference(DateTime.now()).inDays < 3
                                    ? Colors.orange
                                    : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      box.sourceDescription ?? box.typeName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(box.obtainedAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // Open button
              ElevatedButton.icon(
                onPressed: () => _openBox(box),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Aç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rarityColor.withOpacity(0.1),
                  foregroundColor: rarityColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

