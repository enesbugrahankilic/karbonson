// lib/pages/main_navigation_shell.dart
// 🚀 Main Navigation Shell with 5-Tab System

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/navigation/simplified_app_router.dart';
import '../services/authentication_state_service.dart';
import '../services/notification_service.dart';
import '../services/user_progress_service.dart';
import '../services/achievement_service.dart';
import '../theme/design_system.dart';
import 'home_dashboard.dart';
import 'quiz_page.dart';
import 'leaderboard_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';

/// 🚀 Main Navigation Shell
/// Provides 5-tab navigation with simplified routing
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  // Tab icons with labels
  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Ana Sayfa',
    ),
    BottomNavItem(
      route: AppRoutes.gameModes,
      icon: Icons.sports_esports_outlined,
      activeIcon: Icons.sports_esports,
      label: 'Oyunlar',
    ),
    BottomNavItem(
      route: AppRoutes.social,
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Sosyal',
    ),
    BottomNavItem(
      route: AppRoutes.friends,
      icon: Icons.person_add_outlined,
      activeIcon: Icons.person_add,
      label: 'Arkadaşlar',
    ),
    BottomNavItem(
      route: AppRoutes.profile,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize services in parallel
      await Future.wait([
        NotificationService.initializeStatic(),
        AchievementService().initializeForUser(),
      ]);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Service initialization error: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized
          ? IndexedStack(
              index: _currentIndex,
              children: _buildTabPages(),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  List<Widget> _buildTabPages() {
    return [
      // Home Tab
      const HomeDashboard(),
      
      // Games Tab - Quiz as main game hub
      const QuizPage(),
      
      // Social Tab - Leaderboard as main social hub
      LeaderboardPage(),
      
      // Friends Tab
      FriendsPage(userNickname: ''),
      
      // Profile Tab
      const ProfilePage(),
    ];
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _onTabSelected(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? theme.primaryColor
                              : theme.unselectedWidgetColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.unselectedWidgetColor,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      // Scroll to top if already on this tab
      _scrollToTop(index);
    } else {
      setState(() {
        _currentIndex = index;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _scrollToTop(int index) {
    // This will be implemented by each tab page
    // Tab pages should have a GlobalKey to scroll to top
  }
}

/// Bottom Navigation Item Model
class BottomNavItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Extension for tab pages to support scroll-to-top
extension ScrollToTopExtension on State {
  void _scrollToTopInTab(int tabIndex) {
    // This can be overridden by individual tab pages
  }
}

