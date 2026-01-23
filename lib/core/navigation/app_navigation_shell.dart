// lib/core/navigation/app_navigation_shell.dart
// Apple Quality Main Navigation Shell - Simplified 5 Tab Navigation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/premium_bottom_navigation.dart';
import '../../pages/home_dashboard.dart';
import '../../pages/quiz_page.dart';
import '../../pages/duel_page.dart';
import '../../pages/friends_page.dart';
import '../../pages/profile_page.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _selectedIndex = 0;
  int _pendingFriendRequests = 3;
  int _dailyChallengesCount = 3;

  void _onNavItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageStack(_selectedIndex),
      bottomNavigationBar: PremiumBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavItemTapped,
        items: [
          NavigationItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
          NavigationItem(
              icon: Icons.quiz_rounded,
              label: 'Quiz',
              badge: _dailyChallengesCount > 0 ? _dailyChallengesCount : null),
          NavigationItem(icon: Icons.sports_esports_rounded, label: 'Düello'),
          NavigationItem(
              icon: Icons.people_rounded,
              label: 'Arkadaşlar',
              badge: _pendingFriendRequests > 0 ? _pendingFriendRequests : null),
          NavigationItem(icon: Icons.person_rounded, label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildPageStack(int index) {
    switch (index) {
      case 0:
        return const HomeDashboard();
      case 1:
        return const QuizPage();
      case 2:
        return const DuelPage();
      case 3:
        return FriendsPage(userNickname: '');
      case 4:
        return const ProfilePage();
      default:
        return const HomeDashboard();
    }
  }
}
