// lib/pages/home_dashboard_premium.dart
// Premium Home Dashboard - Apple Quality Design
// Features: Smooth animations, haptic feedback, performance optimized

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provides/language_provider.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/apple_design_system.dart';
import '../widgets/page_templates.dart';
import '../widgets/premium_page_transition.dart';
import '../core/navigation/app_router.dart';
import '../widgets/home_button.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/quick_menu_widget.dart';
import '../services/achievement_service.dart';
import '../services/profile_service.dart';
import '../services/profile_picture_service.dart';
import '../services/user_progress_service.dart';
import '../services/user_activity_service.dart';
import '../services/app_localizations.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../models/daily_challenge.dart';
import '../models/user_data.dart';
import '../models/user_activity.dart';

class HomeDashboardPremium extends StatefulWidget {
  HomeDashboardPremium({super.key});

  @override
  State<HomeDashboardPremium> createState() => _HomeDashboardPremiumState();
}

class _HomeDashboardPremiumState extends State<HomeDashboardPremium>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  // Dynamic data variables
  UserData? _userData;
  UserProgress? _userProgress;
  List<Achievement> _userAchievements = [];
  List<DailyChallenge> _dailyChallenges = [];
  bool _isLoadingData = true;

  // Services
  final ProfileService _profileService = ProfileService();
  final UserProgressService _userProgressService = UserProgressService();
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _profileService.getUserData(user.uid);
        final progress = await _userProgressService.getUserProgress(uid: user.uid);
        final achievements =
            await _achievementService.getUserAchievements(user.uid);

        setState(() {
          _userData = userData;
          _userProgress = progress;
          _userAchievements = achievements;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animationController,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 160,
                backgroundColor: ThemeColors.getCardBackground(context),
                elevation: innerBoxIsScrolled ? 0.5 : 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(),
                  collapseMode: CollapseMode.parallax,
                ),
              ),
            ];
          },
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppleDesignSystem.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Welcome back!',
            style: AppleDesignSystem.headline2.copyWith(
              color: ThemeColors.getText(context),
            ),
          ),
          SizedBox(height: AppleDesignSystem.spacing8),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: AppleDesignSystem.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData?.nickname ?? 'User',
                      style: AppleDesignSystem.body1.copyWith(
                        color: ThemeColors.getText(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Level ${_userProgress?.level ?? 1}',
                      style: AppleDesignSystem.caption1.copyWith(
                        color: ThemeColors.getSecondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings_rounded,
                    color: Theme.of(context).primaryColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingData) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ),
      );
    }

    return PageBody(
      scrollable: false,
      padding: EdgeInsets.symmetric(
        horizontal: AppleDesignSystem.spacing16,
        vertical: AppleDesignSystem.spacing20,
      ),
      child: ListView(
        children: [
          // Quick Stats
          _buildQuickStats(),
          SizedBox(height: AppleDesignSystem.spacing24),

          // Daily Challenge
          _buildDailyChallenge(),
          SizedBox(height: AppleDesignSystem.spacing24),

          // Quick Actions
          _buildQuickActions(),
          SizedBox(height: AppleDesignSystem.spacing24),

          // Recent Achievements
          _buildRecentAchievements(),
          SizedBox(height: AppleDesignSystem.spacing40),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Statistics'),
        SizedBox(height: AppleDesignSystem.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Score',
                value: '${_userProgress?.bestScore ?? 0}',
                icon: Icons.trending_up_rounded,
              ),
            ),
            SizedBox(width: AppleDesignSystem.spacing12),
            Expanded(
              child: _buildStatCard(
                title: 'Streak',
                value: '${_userProgress?.loginStreak ?? 0}',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return AppleDesignSystem.premiumCard(
      context: context,
      padding: EdgeInsets.all(AppleDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          SizedBox(height: AppleDesignSystem.spacing8),
          Text(
            value,
            style: AppleDesignSystem.headline3.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppleDesignSystem.spacing4),
          Text(
            title,
            style: AppleDesignSystem.caption1.copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Daily Challenge'),
        SizedBox(height: AppleDesignSystem.spacing12),
        AppleDesignSystem.premiumCard(
          context: context,
          padding: EdgeInsets.all(AppleDesignSystem.spacing16),
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to daily challenge
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Answer 5 questions',
                    style: AppleDesignSystem.title2.copyWith(
                      color: ThemeColors.getText(context),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppleDesignSystem.radius8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppleDesignSystem.spacing8,
                      vertical: AppleDesignSystem.spacing4,
                    ),
                    child: Text(
                      '+50 XP',
                      style: AppleDesignSystem.caption1.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppleDesignSystem.spacing12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppleDesignSystem.radius4),
                child: LinearProgressIndicator(
                  value: 0.6,
                  minHeight: 4,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: AppleDesignSystem.spacing8),
              Text(
                '3 of 5 completed',
                style: AppleDesignSystem.caption1.copyWith(
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quick Access'),
        SizedBox(height: AppleDesignSystem.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.psychology,
                label: 'Quiz',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to quiz
                },
              ),
            ),
            SizedBox(width: AppleDesignSystem.spacing12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.sports_kabaddi,
                label: 'Duel',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to duel
                },
              ),
            ),
            SizedBox(width: AppleDesignSystem.spacing12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.card_giftcard_rounded,
                label: 'Rewards',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to rewards
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppleDesignSystem.premiumCard(
        context: context,
        padding: EdgeInsets.symmetric(
          horizontal: AppleDesignSystem.spacing12,
          vertical: AppleDesignSystem.spacing16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: AppleDesignSystem.spacing8),
            Text(
              label,
              style: AppleDesignSystem.caption1.copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements() {
    if (_userAchievements.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recent Achievements'),
        SizedBox(height: AppleDesignSystem.spacing12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppleDesignSystem.spacing12,
            crossAxisSpacing: AppleDesignSystem.spacing12,
          ),
          itemCount: _userAchievements.take(6).length,
          itemBuilder: (context, index) {
            final achievement = _userAchievements[index];
            return _buildAchievementItem(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return AppleDesignSystem.premiumCard(
      context: context,
      padding: EdgeInsets.all(AppleDesignSystem.spacing12),
      onTap: () {
        HapticFeedback.lightImpact();
        // Show achievement details
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon ?? '🏆',
            style: const TextStyle(fontSize: 32),
          ),
          SizedBox(height: AppleDesignSystem.spacing8),
          Text(
            achievement.title ?? 'Achievement',
            style: AppleDesignSystem.caption1.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
