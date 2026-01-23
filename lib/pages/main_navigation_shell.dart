// lib/pages/main_navigation_shell.dart
// Premium Main Navigation Shell - Apple Quality Navigation Experience
// Features: Smooth transitions, independent nav stacks, haptic feedback, state preservation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/premium_bottom_navigation.dart';
import '../services/profile_service.dart';
import 'home_dashboard.dart';
import 'quiz_page.dart';
import 'duel_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';

/// Premium Main Navigation Shell - Apple Quality
class MainNavigationShell extends StatefulWidget {
  final int? initialTabIndex;

  const MainNavigationShell({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  final ProfileService _profileService = ProfileService();

  // Independent navigator keys for each tab
  static final GlobalKey<NavigatorState> _homeNavKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _quizNavKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _duelNavKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _socialNavKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _profileNavKey =
      GlobalKey<NavigatorState>();

  // Last tab tap times for double-tap detection
  late List<DateTime> _lastTabTapTimes;

  // User nickname for FriendsPage
  String _userNickname = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex ?? 0;
    _pageController = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _lastTabTapTimes = List.filled(5, DateTime.now());
    _loadUserNickname();
  }

  Future<void> _loadUserNickname() async {
    try {
      final nickname = await _profileService.getCurrentNickname();
      if (mounted && nickname != null) {
        setState(() {
          _userNickname = nickname;
        });
      }
    } catch (e) {
      // Handle error silently or log it
      if (mounted) {
        setState(() {
          _userNickname = 'Kullanıcı'; // Fallback
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    final now = DateTime.now();
    final isDoubleTap = now.difference(_lastTabTapTimes[index]).inMilliseconds < 500;
    _lastTabTapTimes[index] = now;

    if (isDoubleTap && index != 0) {
      // Double tap: pop to root
      _getNavKey(index).currentState?.popUntil((route) => route.isFirst);
      HapticFeedback.mediumImpact();
    } else if (_selectedIndex == index) {
      // Single tap on same tab: scroll to top
      _getNavKey(index).currentState?.popUntil((route) => route.isFirst);
      HapticFeedback.lightImpact();
    } else {
      // Switch to different tab
      HapticFeedback.selectionClick();
      setState(() {
        _selectedIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  GlobalKey<NavigatorState> _getNavKey(int index) {
    switch (index) {
      case 0:
        return _homeNavKey;
      case 1:
        return _quizNavKey;
      case 2:
        return _duelNavKey;
      case 3:
        return _socialNavKey;
      case 4:
        return _profileNavKey;
      default:
        return _homeNavKey;
    }
  }

  Widget _buildTab(int index, GlobalKey<NavigatorState> navKey, Widget page) {
    return Navigator(
      key: navKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final navKey = _getNavKey(_selectedIndex);
        if (navKey.currentState?.canPop() ?? false) {
          navKey.currentState?.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildTab(0, _homeNavKey, const HomePage()),
            _buildTab(1, _quizNavKey, const QuizPage()),
            _buildTab(2, _duelNavKey, const DuelPage()),
            _buildTab(3, _socialNavKey, FriendsPage(userNickname: _userNickname)),
            _buildTab(4, _profileNavKey, const ProfilePage()),
          ],
        ),
        bottomNavigationBar: _buildPremiumBottomNav(context),
      ),
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context) {
    return PremiumBottomNavigation(
      selectedIndex: _selectedIndex,
      onItemTapped: _onNavItemTapped,
      items: [
        NavigationItem(
          icon: Icons.home_rounded,
          label: 'Home',
        ),
        NavigationItem(
          icon: Icons.psychology,
          label: 'Quiz',
        ),
        NavigationItem(
          icon: Icons.flash_on,
          label: 'Duel',
        ),
        NavigationItem(
          icon: Icons.people_rounded,
          label: 'Social',
        ),
        NavigationItem(
          icon: Icons.person_rounded,
          label: 'Profile',
        ),
      ],
    );
  }
}

// Home Page Tab Content
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const HomeDashboard();
  }
}
