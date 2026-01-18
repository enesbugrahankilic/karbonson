// lib/core/navigation/bottom_navigation.dart
// Modern bottom navigation system with accessibility and animations

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'app_router.dart';
import 'navigation_service.dart';

/// Bottom navigation item configuration
class BottomNavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;
  final bool requiresAuth;
  final String? tooltip;

  const BottomNavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
    this.requiresAuth = false,
    this.tooltip,
  });

  BottomNavItem copyWith({
    String? route,
    IconData? icon,
    IconData? activeIcon,
    String? label,
    int? badgeCount,
    bool? requiresAuth,
    String? tooltip,
  }) {
    return BottomNavItem(
      route: route ?? this.route,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,
      badgeCount: badgeCount ?? this.badgeCount,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      tooltip: tooltip ?? this.tooltip,
    );
  }
}

/// Main bottom navigation bar widget
class AppBottomNavigationBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final bool enableAnimations;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const AppBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.showLabels = true,
    this.enableAnimations = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ??
        theme.colorScheme.surface.withOpacity( 0.8);
    final selectedColor = widget.selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor =
        widget.unselectedItemColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity( 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60 + MediaQuery.of(context).padding.bottom,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: _buildNavItem(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required int index,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return GestureDetector(
      onTap: () {
        _handleItemTap(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.backgroundColor ??
                              Theme.of(context).colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        item.badgeCount! > 99
                            ? '99+'
                            : item.badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.showLabels) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleItemTap(int index) {
    final item = widget.items[index];

    // Log navigation event
    final navService = NavigationService();
    navService.logNavigationEvent(
      NavigationEventType.push,
      toRoute: item.route,
      metadata: {
        'navigationType': 'bottom_nav',
        'itemIndex': index,
        'itemLabel': item.label,
      },
    );

    // Handle authentication requirement
    if (item.requiresAuth) {
      // TODO: Check authentication status
      // For now, just navigate
    }

    // Call onTap callback if provided
    widget.onTap?.call(index);
  }
}

/// Bottom navigation controller for managing state
class BottomNavigationController extends ChangeNotifier {
  int _currentIndex = 0;
  final List<BottomNavItem> _items;

  BottomNavigationController(this._items);

  int get currentIndex => _currentIndex;
  List<BottomNavItem> get items => List.unmodifiable(_items);

  /// Set current index and navigate to route
  void setCurrentIndex(int index, {bool navigate = true}) {
    if (index < 0 || index >= _items.length) return;

    final previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();

    if (navigate && index != previousIndex) {
      _navigateToRoute(_items[index].route);
    }
  }

  /// Navigate to specific route
  void _navigateToRoute(String route) {
    // Use global navigator key to navigate
    // This would be set up in the main app
    if (kDebugMode) {
      debugPrint('BottomNav: Navigating to $route');
    }
  }

  /// Update badge count for specific item
  void updateBadgeCount(int index, int? count) {
    if (index < 0 || index >= _items.length) return;

    // Note: In a real implementation, you'd want to make BottomNavItem mutable
    // or use a state management solution
    if (kDebugMode) {
      debugPrint(
          'BottomNav: Badge count updated for ${_items[index].label}: $count');
    }
  }

  /// Get current route name
  String? get currentRoute =>
      _items.isNotEmpty ? _items[_currentIndex].route : null;

  /// Check if route is in bottom nav items
  bool isBottomNavRoute(String route) {
    return _items.any((item) => item.route == route);
  }

  /// Get index of route
  int getRouteIndex(String route) {
    return _items.indexWhere((item) => item.route == route);
  }
}

/// Predefined bottom navigation configurations
class BottomNavConfigs {
  /// Main navigation with essential features
  static List<BottomNavItem> mainNavigation() {
    return [
      const BottomNavItem(
        route: AppRoutes.home,
        icon: Icons.home,
        activeIcon: Icons.home,
        label: 'Ana Sayfa',
        requiresAuth: true,
        tooltip: 'Ana Sayfa',
      ),
      const BottomNavItem(
        route: AppRoutes.quiz,
        icon: Icons.quiz,
        activeIcon: Icons.quiz,
        label: 'Quiz',
        requiresAuth: false,
        tooltip: 'Quiz Oyunları',
      ),
      const BottomNavItem(
        route: AppRoutes.duel,
        icon: Icons.sports_esports,
        activeIcon: Icons.sports_esports,
        label: 'Düello',
        requiresAuth: true,
        tooltip: 'Düello',
      ),
      const BottomNavItem(
        route: AppRoutes.profile,
        icon: Icons.person,
        activeIcon: Icons.person,
        label: 'Profil',
        requiresAuth: true,
        tooltip: 'Profiliniz',
      ),
    ];
  }

  /// Extended navigation with more features
  static List<BottomNavItem> extendedNavigation() {
    return [
      const BottomNavItem(
        route: AppRoutes.home,
        icon: Icons.home,
        activeIcon: Icons.home,
        label: 'Ana Sayfa',
        requiresAuth: true,
      ),
      const BottomNavItem(
        route: AppRoutes.quiz,
        icon: Icons.quiz,
        activeIcon: Icons.quiz,
        label: 'Quiz',
        requiresAuth: false,
      ),
      const BottomNavItem(
        route: AppRoutes.leaderboard,
        icon: Icons.leaderboard,
        activeIcon: Icons.leaderboard,
        label: 'Sıralama',
        requiresAuth: false,
      ),
      const BottomNavItem(
        route: AppRoutes.friends,
        icon: Icons.people,
        activeIcon: Icons.people,
        label: 'Arkadaşlar',
        requiresAuth: true,
      ),
      const BottomNavItem(
        route: AppRoutes.profile,
        icon: Icons.person,
        activeIcon: Icons.person,
        label: 'Profil',
        requiresAuth: true,
      ),
    ];
  }

  /// Game-focused navigation
  static List<BottomNavItem> gameNavigation() {
    return [
      const BottomNavItem(
        route: AppRoutes.boardGame,
        icon: Icons.casino,
        activeIcon: Icons.casino,
        label: 'Board',
        tooltip: 'Board Game',
      ),
      const BottomNavItem(
        route: AppRoutes.quiz,
        icon: Icons.quiz,
        activeIcon: Icons.quiz,
        label: 'Quiz',
        tooltip: 'Quiz Mode',
      ),
      const BottomNavItem(
        route: AppRoutes.duel,
        icon: Icons.security,
        activeIcon: Icons.security,
        label: 'Duel',
        tooltip: 'Quick Duel',
      ),
      const BottomNavItem(
        route: AppRoutes.multiplayerLobby,
        icon: Icons.group,
        activeIcon: Icons.group,
        label: 'Multiplayer',
        requiresAuth: true,
        tooltip: 'Multiplayer Games',
      ),
    ];
  }

  /// Social-focused navigation
  static List<BottomNavItem> socialNavigation() {
    return [
      const BottomNavItem(
        route: AppRoutes.friends,
        icon: Icons.people,
        activeIcon: Icons.people,
        label: 'Friends',
        requiresAuth: true,
        tooltip: 'Friends List',
      ),
      const BottomNavItem(
        route: AppRoutes.leaderboard,
        icon: Icons.emoji_events,
        activeIcon: Icons.emoji_events,
        label: 'Rankings',
        tooltip: 'Player Rankings',
      ),
      const BottomNavItem(
        route: AppRoutes.duel,
        icon: Icons.sports_esports,
        activeIcon: Icons.sports_esports,
        label: 'Duel',
        tooltip: 'Challenge Players',
      ),
      const BottomNavItem(
        route: AppRoutes.profile,
        icon: Icons.person,
        activeIcon: Icons.person,
        label: 'Profile',
        requiresAuth: true,
        tooltip: 'Your Profile',
      ),
    ];
  }
}

/// Bottom navigation provider for easy state management
class BottomNavigationProvider extends ChangeNotifier {
  static BottomNavigationProvider? _instance;
  static BottomNavigationProvider get instance =>
      _instance ??= BottomNavigationProvider._internal();

  BottomNavigationProvider._internal();

  BottomNavigationController? _controller;

  BottomNavigationController get controller {
    _controller ??=
        BottomNavigationController(BottomNavConfigs.mainNavigation());
    return _controller!;
  }

  void updateConfiguration(List<BottomNavItem> items) {
    _controller = BottomNavigationController(items);
    notifyListeners();
  }
}
