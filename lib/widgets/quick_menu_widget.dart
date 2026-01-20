// lib/widgets/quick_menu_widget.dart
// Enhanced Quick Menu Widget with Modern Design

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../core/navigation/app_router.dart';

/// Quick Menu Item with enhanced properties
class QuickMenuItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onTap;
  final bool isNew;
  final String? badge;
  final int? badgeCount;
  final String category;
  final bool isFeatured;

  QuickMenuItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
    this.isNew = false,
    this.badge,
    this.badgeCount,
    this.category = 'general',
    this.isFeatured = false,
  });
}

/// Menu Category for organizing items
class MenuCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  MenuCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class QuickMenuWidget extends StatefulWidget {
  final List<QuickMenuItem> items;
  final List<MenuCategory>? categories;
  final double itemWidth;
  final double itemHeight;
  final bool enableScroll;
  final EdgeInsets? padding;
  final String title;
  final IconData? titleIcon;
  final bool showStatsBar;
  final int? userPoints;
  final int? userLevel;
  final int? userStreak;

  const QuickMenuWidget({
    super.key,
    required this.items,
    this.categories,
    this.itemWidth = 220, // Increased from 170 to 220 for wider widgets (full screen)
    this.itemHeight = 200, // Increased from 180 to 200 for better proportions
    this.enableScroll = true,
    this.padding,
    this.title = 'Hızlı Menü',
    this.titleIcon,
    this.showStatsBar = true,
    this.userPoints,
    this.userLevel,
    this.userStreak,
  });

  @override
  State<QuickMenuWidget> createState() => _QuickMenuWidgetState();
}

class _QuickMenuWidgetState extends State<QuickMenuWidget> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  double _scrollPosition = 0;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollPosition = _scrollController.offset;
    });
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Trigger scale animation
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    // Trigger haptic feedback if available
    widget.items[index].onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        
        // Stats Bar
        if (widget.showStatsBar) _buildStatsBar(context),
        
        const SizedBox(height: 16),
        
        // Main Menu Content
        SizedBox(
          height: widget.itemHeight + 20,
          child: widget.enableScroll
              ? _buildScrollableMenu()
              : _buildNonScrollableMenu(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (widget.titleIcon != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.titleIcon,
                color: ThemeColors.getPrimaryButtonColor(context),
                size: 26,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ThemeColors.getTitleColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.categories != null)
                  Text(
                    '${widget.items.length} özellik',
                    style: TextStyle(
                      color: ThemeColors.getSecondaryText(context),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.enableScroll && widget.items.length > 3)
            _buildScrollIndicators(),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withOpacity(0.15),
            ThemeColors.getAccentButtonColor(context).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            icon: Icons.star,
            value: '${widget.userPoints ?? 0}',
            label: 'Puan',
            color: Colors.amber,
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            context,
            icon: Icons.emoji_events,
            value: '${widget.userLevel ?? 1}',
            label: 'Seviye',
            color: Colors.purple,
          ),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem(
            context,
            icon: Icons.local_fire_department,
            value: '${widget.userStreak ?? 0}',
            label: 'Gün',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: ThemeColors.getSecondaryText(context),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildScrollIndicators() {
    final itemCount = (widget.items.length / 3).ceil();
    final activeIndex = (_scrollPosition / (widget.itemWidth + 12)).floor();

    return Row(
      children: List.generate(
        itemCount.clamp(1, 5),
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == activeIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == activeIndex
                ? ThemeColors.getPrimaryButtonColor(context)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableMenu() {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.items.length,
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isFirst = index == 0;
        final isLast = index == widget.items.length - 1;
        final isSelected = _selectedIndex == index;
        
        return Padding(
          padding: EdgeInsets.only(
            left: isFirst ? 0 : 12,
            right: isLast ? 0 : 12,
          ),
          child: _buildMenuItem(item, context, isSelected: isSelected),
        );
      },
    );
  }

  Widget _buildNonScrollableMenu() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.items.map((item) {
        return SizedBox(
          width: widget.itemWidth,
          child: _buildMenuItem(item, context),
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(QuickMenuItem item, BuildContext context, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _onItemTap(widget.items.indexOf(item)),
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final scale = _scaleController.value;
          return Transform.scale(
            scale: isSelected ? 1.0 - (scale * 0.1) : 1.0,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.itemWidth,
          height: widget.itemHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [item.gradientStart, item.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: item.color.withOpacity(item.isFeatured ? 0.8 : 0.5),
              width: item.isFeatured ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.4),
                blurRadius: item.isFeatured ? 20 : 15,
                offset: const Offset(0, 8),
              ),
              if (item.isFeatured)
                BoxShadow(
                  color: item.color.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative icon
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  item.icon,
                  size: 90,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              
              // Featured badge
              if (item.isFeatured)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      '★ ÖNE ÇIKAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // New badge
              if (item.isNew && !item.isFeatured)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'YENİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row with icon and badge count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        if (item.badgeCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item.badgeCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Title and subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Quick Menu for smaller spaces
class CompactQuickMenu extends StatelessWidget {
  final List<QuickMenuItem> items;
  final double itemSize;
  final int maxItems;
  final bool showLabels;

  const CompactQuickMenu({
    super.key,
    required this.items,
    this.itemSize = 64,
    this.maxItems = 6,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(maxItems).toList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: displayItems.map((item) {
        return _buildCompactItem(item, context);
      }).toList(),
    );
  }

  Widget _buildCompactItem(QuickMenuItem item, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: item.onTap,
          child: Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.gradientStart, item.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(itemSize * 0.3),
              border: Border.all(
                color: item.color.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: itemSize * 0.4,
                  ),
                ),
                if (item.isNew)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (item.badgeCount != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: itemSize + 10,
            child: Text(
              item.title,
              style: TextStyle(
                color: ThemeColors.getTitleColor(context),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

/// Grid-style Quick Menu for dashboard
class QuickMenuGrid extends StatelessWidget {
  final List<QuickMenuItem> items;
  final int columns;
  final double spacing;
  final EdgeInsets? padding;
  final bool showScrollbar;
  final double? scrollbarThickness;
  final Radius? scrollbarRadius;

  const QuickMenuGrid({
    super.key,
    required this.items,
    this.columns = 4, // Changed from 3 to 4 for more items visible
    this.spacing = 12, // Decreased from 16 to 12 for tighter layout
    this.padding,
    this.showScrollbar = true,
    this.scrollbarThickness = 6.0,
    this.scrollbarRadius = const Radius.circular(4),
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (padding?.horizontal ?? 40) - (spacing * (columns - 1))) / columns;

    final scrollContent = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: items.map((item) {
          return SizedBox(
            width: itemWidth,
            child: _buildGridItem(item, context, itemWidth),
          );
        }).toList(),
      ),
    );

    if (showScrollbar) {
      return Scrollbar(
        thickness: scrollbarThickness,
        radius: scrollbarRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.only(right: 20),
          child: scrollContent,
        ),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      child: scrollContent,
    );
  }

  Widget _buildGridItem(QuickMenuItem item, BuildContext context, double width) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [item.gradientStart.withOpacity(0.8), item.gradientEnd.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.color.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.subtitle != null)
              Text(
                item.subtitle!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

/// Quick Menu Builder with predefined categories
class QuickMenuBuilder {
  /// Build complete menu with all features
  static List<QuickMenuItem> buildCompleteMenu({
    required VoidCallback onQuizTap,
    required VoidCallback onDuelTap,
    required VoidCallback onBoardGameTap,
    required VoidCallback onMultiplayerTap,
    required VoidCallback onFriendsTap,
    required VoidCallback onLeaderboardTap,
    required VoidCallback onDailyChallengeTap,
    required VoidCallback onAchievementsTap,
    required VoidCallback onRewardsTap,
    required VoidCallback onAIRecommendationsTap,
    required VoidCallback onHowToPlayTap,
    required VoidCallback onSettingsTap,
    required VoidCallback onProfileTap,
    int? friendRequestCount,
    int? dailyChallengeCount,
    int? achievementCount,
  }) {
    return [
      // Game Modes - Featured
      QuickMenuItem(
        id: 'quiz',
        title: 'Quiz',
        subtitle: 'Çevre bilgini test et',
        icon: Icons.quiz,
        color: Colors.purple,
        gradientStart: Colors.purple.shade400,
        gradientEnd: Colors.purple.shade700,
        onTap: onQuizTap,
        category: 'game_modes',
        isFeatured: true,
      ),
      QuickMenuItem(
        id: 'duel',
        title: 'Düello',
        subtitle: 'Arkadaşlarınla yarış',
        icon: Icons.sports_esports,
        color: Colors.orange,
        gradientStart: Colors.orange.shade400,
        gradientEnd: Colors.orange.shade700,
        onTap: onDuelTap,
        category: 'game_modes',
        isFeatured: true,
        isNew: true,
      ),
      QuickMenuItem(
        id: 'board_game',
        title: 'Masa Oyunu',
        subtitle: 'Strateji tabanlı',
        icon: Icons.casino,
        color: Colors.teal,
        gradientStart: Colors.teal.shade400,
        gradientEnd: Colors.teal.shade700,
        onTap: onBoardGameTap,
        category: 'game_modes',
      ),
      QuickMenuItem(
        id: 'multiplayer',
        title: 'Çoklu Oyuncu',
        subtitle: '4 kişiye kadar',
        icon: Icons.group,
        color: Colors.blue,
        gradientStart: Colors.blue.shade400,
        gradientEnd: Colors.blue.shade700,
        onTap: onMultiplayerTap,
        category: 'game_modes',
      ),
      
      // Social
      QuickMenuItem(
        id: 'friends',
        title: 'Arkadaşlar',
        subtitle: 'Arkadaş ekle ve gör',
        icon: Icons.people,
        color: Colors.cyan,
        gradientStart: Colors.cyan.shade400,
        gradientEnd: Colors.cyan.shade700,
        onTap: onFriendsTap,
        category: 'social',
        badgeCount: friendRequestCount,
      ),
      QuickMenuItem(
        id: 'leaderboard',
        title: 'Lider Tablosu',
        subtitle: 'En iyi oyuncular',
        icon: Icons.leaderboard,
        color: Colors.blue,
        gradientStart: Colors.blue.shade400,
        gradientEnd: Colors.blue.shade700,
        onTap: onLeaderboardTap,
        category: 'social',
      ),
      QuickMenuItem(
        id: 'daily_challenges',
        title: 'Günlük Görevler',
        subtitle: 'Bugünün görevleri',
        icon: Icons.task_alt,
        color: Colors.green,
        gradientStart: Colors.green.shade400,
        gradientEnd: Colors.green.shade700,
        onTap: onDailyChallengeTap,
        category: 'social',
        badgeCount: dailyChallengeCount,
      ),
      QuickMenuItem(
        id: 'achievements',
        title: 'Başarılar',
        subtitle: 'Rozetlerini gör',
        icon: Icons.emoji_events,
        color: Colors.amber,
        gradientStart: Colors.amber.shade400,
        gradientEnd: Colors.amber.shade700,
        onTap: onAchievementsTap,
        category: 'social',
        badgeCount: achievementCount,
      ),
      
      // Tools & Features
      QuickMenuItem(
        id: 'rewards',
        title: 'Ödül Mağazası',
        subtitle: 'Sana özel hediyeler',
        icon: Icons.card_giftcard,
        color: Colors.pink,
        gradientStart: Colors.pink.shade400,
        gradientEnd: Colors.pink.shade700,
        onTap: onRewardsTap,
        category: 'tools',
      ),
      QuickMenuItem(
        id: 'ai_recommendations',
        title: 'AI Önerileri',
        subtitle: 'Kişiselleştirilmiş',
        icon: Icons.lightbulb,
        color: Colors.indigo,
        gradientStart: Colors.indigo.shade400,
        gradientEnd: Colors.indigo.shade700,
        onTap: onAIRecommendationsTap,
        category: 'tools',
        isNew: true,
      ),
      QuickMenuItem(
        id: 'how_to_play',
        title: 'Nasıl Oynanır',
        subtitle: 'Kurallar ve ipuçları',
        icon: Icons.help,
        color: Colors.lightBlue,
        gradientStart: Colors.lightBlue.shade400,
        gradientEnd: Colors.lightBlue.shade700,
        onTap: onHowToPlayTap,
        category: 'tools',
      ),
      QuickMenuItem(
        id: 'settings',
        title: 'Ayarlar',
        subtitle: 'Uygulama ayarları',
        icon: Icons.settings,
        color: Colors.grey,
        gradientStart: Colors.grey.shade400,
        gradientEnd: Colors.grey.shade700,
        onTap: onSettingsTap,
        category: 'tools',
      ),
      QuickMenuItem(
        id: 'profile',
        title: 'Profil',
        subtitle: 'Kullanıcı bilgileri',
        icon: Icons.person,
        color: Colors.deepPurple,
        gradientStart: Colors.deepPurple.shade400,
        gradientEnd: Colors.deepPurple.shade700,
        onTap: onProfileTap,
        category: 'tools',
      ),
    ];
  }

  /// Build menu categories
  static List<MenuCategory> buildCategories() {
    return [
      MenuCategory(
        id: 'game_modes',
        title: 'Oyun Modları',
        icon: Icons.sports_esports,
        color: Colors.purple,
      ),
      MenuCategory(
        id: 'social',
        title: 'Sosyal',
        icon: Icons.people,
        color: Colors.blue,
      ),
      MenuCategory(
        id: 'tools',
        title: 'Araçlar',
        icon: Icons.build,
        color: Colors.green,
      ),
    ];
  }

  /// Build compact menu for bottom navigation
  static List<QuickMenuItem> buildCompactMenu({
    required VoidCallback onQuizTap,
    required VoidCallback onDuelTap,
    required VoidCallback onFriendsTap,
    required VoidCallback onLeaderboardTap,
    required VoidCallback onAchievementsTap,
    required VoidCallback onSettingsTap,
  }) {
    return [
      QuickMenuItem(
        id: 'quiz',
        title: 'Quiz',
        icon: Icons.quiz,
        color: Colors.purple,
        gradientStart: Colors.purple.shade400,
        gradientEnd: Colors.purple.shade700,
        onTap: onQuizTap,
        category: 'game_modes',
      ),
      QuickMenuItem(
        id: 'duel',
        title: 'Düello',
        icon: Icons.sports_esports,
        color: Colors.orange,
        gradientStart: Colors.orange.shade400,
        gradientEnd: Colors.orange.shade700,
        onTap: onDuelTap,
        category: 'game_modes',
        isNew: true,
      ),
      QuickMenuItem(
        id: 'friends',
        title: 'Arkadaşlar',
        icon: Icons.people,
        color: Colors.cyan,
        gradientStart: Colors.cyan.shade400,
        gradientEnd: Colors.cyan.shade700,
        onTap: onFriendsTap,
        category: 'social',
      ),
      QuickMenuItem(
        id: 'leaderboard',
        title: 'Sıralama',
        icon: Icons.leaderboard,
        color: Colors.blue,
        gradientStart: Colors.blue.shade400,
        gradientEnd: Colors.blue.shade700,
        onTap: onLeaderboardTap,
        category: 'social',
      ),
      QuickMenuItem(
        id: 'achievements',
        title: 'Başarılar',
        icon: Icons.emoji_events,
        color: Colors.amber,
        gradientStart: Colors.amber.shade400,
        gradientEnd: Colors.amber.shade700,
        onTap: onAchievementsTap,
        category: 'social',
      ),
      QuickMenuItem(
        id: 'settings',
        title: 'Ayarlar',
        icon: Icons.settings,
        color: Colors.grey,
        gradientStart: Colors.grey.shade400,
        gradientEnd: Colors.grey.shade700,
        onTap: onSettingsTap,
        category: 'tools',
      ),
    ];
  }
}

