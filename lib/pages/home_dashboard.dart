import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provides/language_provider.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../core/navigation/app_router_complete.dart';
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
import 'tutorial_page.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
           minHeight != oldDelegate.minHeight ||
           child != oldDelegate.child;
  }
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _buttonControllers;
  String? _lastSelectedTheme;
  bool _rememberTheme = false;

  // Dynamic data variables
  UserData? _userData;
  UserProgress? _userProgress;
  List<Achievement> _userAchievements = [];
  List<DailyChallenge> _dailyChallenges = [];
  List<UserActivity> _recentActivities = [];
  bool _isLoadingData = true;

  // Stream subscriptions for proper disposal (using dynamic type for compatibility)
  dynamic _achievementsSubscription;
  dynamic _progressSubscription;
  dynamic _challengesSubscription;

  // Services
  final ProfileService _profileService = ProfileService();
  final UserProgressService _userProgressService = UserProgressService();
  final AchievementService _achievementService = AchievementService();
  final UserActivityService _userActivityService = UserActivityService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonControllers = List.generate(
        6,
        (index) => AnimationController(
              duration: const Duration(milliseconds: 300),
              vsync: this,
            ));

    // Load saved theme preference
    _loadThemePreference();

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Stagger button animations
    for (int i = 0; i < _buttonControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 100)), () {
        if (mounted) {
          _buttonControllers[i].forward();
        }
      });
    }

    // Load user data
    _loadUserData();
    
    // Check and show tutorial if first login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorialIfFirstLogin();
    });
  }

  @override
  void dispose() {
    // Cancel stream subscriptions to prevent memory leaks
    _achievementsSubscription?.cancel();
    _progressSubscription?.cancel();
    _challengesSubscription?.cancel();
    
    _fadeController.dispose();
    _slideController.dispose();
    for (final controller in _buttonControllers) {
      controller.dispose();
    }
    // Dispose achievement service streams
    _achievementService.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSelectedTheme = prefs.getString('lastSelectedTheme');
    _rememberTheme = prefs.getBool('rememberTheme') ?? false;
  }

  Future<void> _saveThemePreference(String theme, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString('lastSelectedTheme', theme);
    }
    await prefs.setBool('rememberTheme', remember);
    _lastSelectedTheme = theme;
    _rememberTheme = remember;
  }

  /// Check if this is first login and show tutorial
  Future<void> _checkAndShowTutorialIfFirstLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenTutorial = prefs.getBool('hasSeenTutorialAfterLogin') ?? false;
      final hasSeenWelcome = prefs.getBool('hasSeenWelcomePage') ?? false;

      if (!hasSeenWelcome && mounted) {
        // Mark as seen
        await prefs.setBool('hasSeenWelcomePage', true);

        // Show welcome page first
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Hoşgeldin')),
                body: const Center(
                  child: Text('Hoşgeldiniz! Uygulamayı keşfetmeye başlayın.'),
                ),
              ),
              fullscreenDialog: true,
            ),
          );
        }
      } else if (!hasSeenTutorial && mounted) {
        // Mark as seen
        await prefs.setBool('hasSeenTutorialAfterLogin', true);

        // Show tutorial page
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TutorialPage(isFirstLogin: true),
              fullscreenDialog: true,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking tutorial status: $e');
    }
  }

  /// Load user data from services
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoadingData = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoadingData = false;
        });
        return;
      }

      // Load user profile data
      _userData = await _profileService.loadServerProfile();
      
      // Load user progress
      _userProgress = await _userProgressService.getUserProgress();
      
      // Initialize achievement service for current user
      await _achievementService.initializeForUser();
      
      // Listen to achievements stream
      _achievementsSubscription = _achievementService.achievementsStream.listen((achievements) {
        if (mounted) {
          setState(() {
            _userAchievements = achievements;
          });
        }
      });
      
      // Listen to progress stream
      _progressSubscription = _achievementService.progressStream.listen((progress) {
        if (mounted) {
          setState(() {
            _userProgress = progress;
          });
        }
      });
      
      // Listen to daily challenges stream
      _challengesSubscription = _achievementService.challengesStream.listen((challenges) {
        if (mounted) {
          setState(() {
            _dailyChallenges = challenges;
          });
        }
      });

      // Load recent activities
      _recentActivities = await _userActivityService.getRecentActivities(limit: 5);

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        // Responsive values
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth < 600;

        final appBarHeight =
            isSmallScreen ? 80.0 : (isMediumScreen ? 100.0 : 120.0);
        final titleFontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);

        // Show loading indicator while fetching user data
        if (_isLoadingData) {
          return Scaffold(
            backgroundColor: ThemeColors.getCardBackground(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.loadingData,
                    style: TextStyle(
                      color: ThemeColors.getText(context),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ThemeColors.getCardBackground(context),
          body: Container(
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getCardBackground(context),
                  ThemeColors.getCardBackground(context).withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Minimal App Bar
                  Container(
                    height: appBarHeight,
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const HomeButton(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeController,
                            child: Text(
                              AppLocalizations.home,
                              style: TextStyle(
                                color: ThemeColors.getText(context),
                                fontWeight: FontWeight.w600,
                                fontSize: titleFontSize,
                              ),
                            ),
                          ),
                        ),
                        LanguageSelectorButton(),
                      ],
                    ),
                  ),

                  // Main Content - Scrollable with CustomScrollView and Sticky Headers
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Sticky Welcome Section Header
                        SliverPersistentHeader(
                          pinned: true,
                          floating: false,
                          delegate: _StickyHeaderDelegate(
                            minHeight: 120.0,
                            maxHeight: 160.0,
                            child: Container(
                              color: ThemeColors.getCardBackground(context).withOpacity(0.95),
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0,
                                  vertical: 8.0),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _slideController,
                                  curve: Curves.easeOut,
                                )),
                                child: _buildWelcomeSection(context),
                              ),
                            ),
                          ),
                        ),

                        // Main Content Sections
                        SliverList(
                          delegate: SliverChildListDelegate([
                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Duel Mode Section - Ana odak noktası (EN ÜSTTE)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildDuelModeSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Quick Access Settings Button
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildQuickAccessSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Quick Quiz Start Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildQuickQuizSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Progress & Achievements Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildProgressSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Multiplayer Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildMultiplayerSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Spectator Mode Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildSpectatorModeSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Daily Challenges Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildDailyChallengesSection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Statistics Summary Section
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildStatisticsSummarySection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Recent Activity
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildRecentActivitySection(context),
                            ),

                            SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                            // Carbon Footprint Widget
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16.0 : 20.0),
                              child: _buildCarbonFootprintWidget(context),
                            ),

                            SizedBox(height: 20.0),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Get dynamic user data
    final displayName = _userData?.nickname ??
                        user?.displayName ??
                        user?.email?.split('@')[0] ??
                        'Kullanıcı';
    final totalPoints = _userProgress?.totalPoints ?? 0;
    final achievementCount = _userAchievements.length;

    return Semantics(
      label: 'Kullanıcı hoş geldin bölümü, $displayName, $totalPoints puan, $achievementCount başarı',
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
        decoration: BoxDecoration(
          color: ThemeColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16.0 : 20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => _showEditProfilePictureDialog(context),
              child: Semantics(
                label: 'Profil resmi, dokunarak değiştir',
                child: CircleAvatar(
                  radius: isSmallScreen ? 25.0 : 30.0,
                  backgroundColor: ThemeColors.getPrimaryButtonColor(context).withOpacity( 0.2),
                  backgroundImage: _userData?.profilePictureUrl != null
                      ? NetworkImage(_userData!.profilePictureUrl!)
                      : null,
                  child: _userData?.profilePictureUrl == null
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            color: ThemeColors.getTextOnColoredBackground(context),
                            fontSize: isSmallScreen ? 18.0 : 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            SizedBox(width: isSmallScreen ? 16.0 : 20.0),

            // Welcome Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.helloEmoji,
                    style: TextStyle(
                      color: ThemeColors.getText(context),
                      fontSize: isSmallScreen ? 20.0 : 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    displayName,
                    style: TextStyle(
                      color: ThemeColors.getSecondaryText(context),
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Stats
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: isSmallScreen ? 16.0 : 18.0,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '$totalPoints ${AppLocalizations.points}',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.orange,
                      size: isSmallScreen ? 16.0 : 18.0,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '$achievementCount ${AppLocalizations.badgesAbbrev}',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Time display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: ThemeColors.getPrimaryButtonColor(context)
                    .withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: ThemeColors.getSuccessColor(context),
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final sectionTitleFontSize = isSmallScreen ? 18.0 : 22.0;

    return Container(
      margin: EdgeInsets.all(
          isSmallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'Son Aktiviteler',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen
                  ? DesignSystem.spacingS
                  : DesignSystem.spacingM),
              child: _recentActivities.isEmpty
                  ? _buildEmptyActivitiesMessage(context, isSmallScreen)
                  : Column(
                      children: _recentActivities
                          .map((activity) => _buildActivityItemFromActivity(
                                context,
                                activity: activity,
                                isSmallScreen: isSmallScreen,
                              ))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivitiesMessage(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        Icon(
          Icons.history,
          size: isSmallScreen ? 32.0 : 40.0,
          color: ThemeColors.getSecondaryText(context),
        ),
        SizedBox(height: DesignSystem.spacingS),
        Text(
          'Henüz aktivite bulunmuyor',
          style: TextStyle(
            color: ThemeColors.getSecondaryText(context),
            fontSize: isSmallScreen ? 14.0 : 16.0,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignSystem.spacingS),
        Text(
          'Quiz çözerek, düello yaparak aktivitelerinizi görün!',
          style: TextStyle(
            color: ThemeColors.getSecondaryText(context),
            fontSize: isSmallScreen ? 12.0 : 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityItemFromActivity(
    BuildContext context, {
    required UserActivity activity,
    required bool isSmallScreen,
  }) {
    final color = _getActivityColor(activity.type);
    final icon = _getActivityIcon(activity.type);
    final timeAgo = _getTimeAgo(activity.timestamp);

    return _buildActivityItem(
      context,
      icon: icon,
      title: activity.title,
      subtitle: timeAgo,
      color: color,
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity( 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: DesignSystem.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.getBodyMedium(context),
              ),
              Text(
                subtitle,
                style: DesignSystem.getBodyMedium(context).copyWith(
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.quizCompleted:
        return ThemeColors.getSuccessColor(context);
      case ActivityType.friendAdded:
        return ThemeColors.getInfoColor(context);
      case ActivityType.duelWon:
        return Colors.purple;
      case ActivityType.achievementUnlocked:
        return Colors.orange;
      case ActivityType.levelUp:
        return Colors.amber;
      case ActivityType.loginStreak:
        return Colors.red;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.quizCompleted:
        return Icons.quiz;
      case ActivityType.friendAdded:
        return Icons.people;
      case ActivityType.duelWon:
        return Icons.security;
      case ActivityType.achievementUnlocked:
        return Icons.emoji_events;
      case ActivityType.levelUp:
        return Icons.trending_up;
      case ActivityType.loginStreak:
        return Icons.local_fire_department;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.deepPurple,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity( 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showQuickMenu(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.security,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showLoginRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özelliği kullanmak için giriş yapın')),
    );
  }

  void _showQuickMenu(BuildContext context) {
    final menuItems = QuickMenuBuilder.buildCompleteMenu(
      onQuizTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.quiz);
      },
      onDuelTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.duel);
      },
      onBoardGameTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.boardGame);
      },
      onMultiplayerTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.multiplayerLobby);
      },
      onFriendsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.friends);
      },
      onLeaderboardTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.leaderboard);
      },
      onDailyChallengeTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.dailyChallenge);
      },
      onAchievementsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.achievement);
      },
      onRewardsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed('/rewards-shop');
      },
      onAIRecommendationsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.aiRecommendations);
      },
      onHowToPlayTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.howToPlay);
      },
      onSettingsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.settings);
      },
      onProfileTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.profile);
      },
      onNotificationsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.notifications);
      },
      onSpectatorModeTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.spectatorMode);
      },
      onCarbonFootprintTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.carbonFootprint);
      },
      onQuizResultsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.quizResults);
      },
      onQuizSettingsTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.quizSettings);
      },
      onWelcomeTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.welcome);
      },
      onRewardsMainTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.rewardsMain);
      },
      friendRequestCount: 3, // Bu değer dinamik olarak güncellenmeli
      dailyChallengeCount: _dailyChallenges.length,
      achievementCount: _userAchievements.length,
      notificationCount: null, // Bildirim sayısı dinamik olarak güncellenmeli
    );

    // If user data is not loaded, modify menu items to show login required
    final updatedItems = _userData == null ? menuItems.map((item) {
      return QuickMenuItem(
        id: item.id,
        title: item.title,
        subtitle: 'Giriş yapın',
        icon: item.icon,
        color: item.color,
        gradientStart: item.gradientStart,
        gradientEnd: item.gradientEnd,
        onTap: () {
          Navigator.pop(context);
          _showLoginRequiredMessage(context);
        },
        isNew: item.isNew,
        badge: item.badge,
        badgeCount: item.badgeCount,
        category: item.category,
        isFeatured: item.isFeatured,
      );
    }).toList() : menuItems;

    // Full screen overlay dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenSize = MediaQuery.of(context).size;
            final screenWidth = screenSize.width;
            final isSmallScreen = screenWidth < 360;
            final isTablet = screenWidth > 800;
            
            // Calculate optimal columns based on screen width
            final columns = isTablet ? 5 : (isSmallScreen ? 3 : 4);
            final horizontalPadding = isTablet ? 40.0 : 20.0;
            
            return Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ThemeColors.getCardBackground(context),
                      ThemeColors.getCardBackground(context).withOpacity(0.98),
                      ThemeColors.getCardBackground(context).withOpacity(0.95),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Close button at top right
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: ThemeColors.getText(context),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Header Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: isSmallScreen ? 8 : 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ThemeColors.getPrimaryButtonColor(context),
                                    ThemeColors.getAccentButtonColor(context),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColors.getPrimaryButtonColor(context)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_view,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hızlı Menü',
                                    style: DesignSystem.getHeadlineSmall(context).copyWith(
                                      color: ThemeColors.getText(context),
                                      fontWeight: FontWeight.w800,
                                      fontSize: isSmallScreen ? 20 : 24,
                                    ),
                                  ),
                                  Text(
                                    '${menuItems.length} özellik keşfet',
                                    style: TextStyle(
                                      color: ThemeColors.getSecondaryText(context),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Stats Bar
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
                              ThemeColors.getAccentButtonColor(context).withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickStat(
                              context,
                              icon: Icons.star,
                              value: '${_userProgress?.totalPoints ?? 0}',
                              color: Colors.amber,
                              label: 'Puan',
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                            _buildQuickStat(
                              context,
                              icon: Icons.emoji_events,
                              value: '${_userProgress?.level ?? 1}',
                              color: Colors.purple,
                              label: 'Seviye',
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                            _buildQuickStat(
                              context,
                              icon: Icons.local_fire_department,
                              value: '${_userProgress?.loginStreak ?? 0}',
                              color: Colors.orange,
                              label: 'Gün',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Quick Menu Grid - Full width
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 8,
                          ),
                          child: QuickMenuGrid(
                            items: updatedItems,
                            columns: columns,
                            spacing: isSmallScreen ? 10 : 14,
                            showScrollbar: true,
                            scrollbarThickness: 6,
                            scrollbarRadius: const Radius.circular(4),
                          ),
                        ),
                      ),
                      
                      // Bottom padding
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
    String? label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (label != null)
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          backgroundColor: ThemeColors.getDialogBackground(context),
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacingXl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: ThemeColors.getPrimaryButtonColor(context),
                        size: 32,
                      ),
                      const SizedBox(width: DesignSystem.spacingM),
                      Expanded(
                        child: Text(
                          'Yardım & Bilgi',
                          style: DesignSystem.getHeadlineSmall(context).copyWith(
                            color: ThemeColors.getTitleColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSystem.spacingL),
                  
                  // About Section
                  _buildHelpSection(
                    context,
                    icon: Icons.info_outline,
                    title: 'Uygulama Hakkında',
                    content: 'Eco Game, çevre bilincini artırmak için tasarlanmış eğlenceli bir quiz uygulamasıdır. Enerji, su, orman, geri dönüşüm ve daha birçok konuda sorularla çevre bilginizi test edin!',
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  
                  // Quiz Section
                  _buildHelpSection(
                    context,
                    icon: Icons.quiz,
                    title: 'Quiz Modu',
                    content: 'Farklı çevre temalarından 15 soruluk quiz\'ler çözün. Her doğru cevap puan kazandırır. Daha fazla quiz çözerek seviyenizi yükseltin ve yeni başarılar kazanın!',
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  
                  // Duel Section
                  _buildHelpSection(
                    context,
                    icon: Icons.security,
                    title: 'Düello Modu',
                    content: 'Arkadaşlarınızla veya rastgele oyuncularla düello yapın! Hızlı düello ile 5 soruda kazanın veya kalıcı bir oda oluşturarak arkadaşlarınızı davet edin.',
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  
                  // Multiplayer Section
                  _buildHelpSection(
                    context,
                    icon: Icons.group,
                    title: 'Takım Oyunu',
                    content: '4 oyuncuya kadar bir araya gelin ve birlikte yarışın! Arkadaşlarınızı davet edin veya aktif odalara katılarak yeni arkadaşlıklar kurun.',
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  
                  // Achievements Section
                  _buildHelpSection(
                    context,
                    icon: Icons.emoji_events,
                    title: 'Başarılar & Rozetler',
                    content: 'Quiz çözerek, düello kazanarak ve günlük görevleri tamamlayarak rozetler kazanın. Nadir ve efsanevi rozetler için çabalayın!',
                  ),
                  const SizedBox(height: DesignSystem.spacingM),
                  
                  // Daily Challenges Section
                  _buildHelpSection(
                    context,
                    icon: Icons.task_alt,
                    title: 'Günlük Görevler',
                    content: 'Her gün yeni görevler sizi bekliyor. Görevleri tamamlayarak ekstra puan kazanın ve ilerlemenizi hızlandırın.',
                  ),
                  const SizedBox(height: DesignSystem.spacingL),
                  
                  // Contact Info
                  Container(
                    padding: const EdgeInsets.all(DesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryButtonColor(context).withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: ThemeColors.getPrimaryButtonColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: DesignSystem.spacingS),
                        Expanded(
                          child: Text(
                            'Destek için: support@ecogame.app',
                            style: DesignSystem.getBodyMedium(context).copyWith(
                              color: ThemeColors.getText(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacingL),
                  
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        ),
                      ),
                      child: const Text('Anladım'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context).withOpacity( 0.5),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: ThemeColors.getBorder(context).withOpacity( 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryButtonColor(context).withOpacity( 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: ThemeColors.getPrimaryButtonColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.getTitleMedium(context).copyWith(
                    color: ThemeColors.getText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: DesignSystem.getBodySmall(context).copyWith(
                    color: ThemeColors.getSecondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'Hızlı Erişim',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 18.0 : 22.0,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  context,
                  icon: Icons.settings,
                  label: 'Ayarlar',
                  color: ThemeColors.getAccentButtonColor(context),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.settings);
                  },
                ),
              ),
              SizedBox(width: DesignSystem.spacingS),
              Expanded(
                child: _buildQuickAccessButton(
                  context,
                  icon: Icons.person,
                  label: 'Profil',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.profile);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        decoration: BoxDecoration(
          color: color.withOpacity( 0.1),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: color.withOpacity( 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: isSmallScreen ? 24.0 : 28.0,
            ),
            SizedBox(height: DesignSystem.spacingS),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isSmallScreen ? 12.0 : 14.0,
                fontWeight: FontWeight.w600,
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

  Widget _buildQuickQuizSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'Hızlı Quiz Başlat',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 18.0 : 22.0,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
                isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryButtonColor(context),
                  ThemeColors.getAccentButtonColor(context),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.getPrimaryButtonColor(context)
                      .withOpacity( 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.quizSettings),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              child: Column(
                children: [
                  Icon(
                    Icons.quiz,
                    size: isSmallScreen ? 48.0 : 64.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  Text(
                    'Çevre Bilgisi Quiz\'i',
                    style: TextStyle(
                      color: ThemeColors.getTextOnColoredBackground(context),
                      fontSize: isSmallScreen ? 18.0 : 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSystem.spacingS),
                  Text(
                    'Çevre bilincini artır, puan kazan!',
                    style: TextStyle(
                      color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.9),
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingM,
                      vertical: DesignSystem.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Text(
                      'Şimdi Başlat',
                      style: TextStyle(
                        color: ThemeColors.getTextOnColoredBackground(context),
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final sectionTitleFontSize = isSmallScreen ? 16.0 : 20.0;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'İlerleme & Başarılar',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen
                  ? DesignSystem.spacingS
                  : DesignSystem.spacingM),
              child: Column(
                children: [
                  // Level Progress
                  _buildLevelProgress(context),
                  SizedBox(height: DesignSystem.spacingM),
                  // Quiz Stats
                  _buildQuizStats(context),
                  SizedBox(height: DesignSystem.spacingM),
                  // Recent Achievements
                  _buildRecentAchievements(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Get dynamic level data
    final currentLevel = _userProgress?.level ?? 1;
    final experiencePoints = _userProgress?.experiencePoints ?? 0;
    final nextLevelXP = (currentLevel * 100);
    final progressPercentage = nextLevelXP > 0 ? (experiencePoints / nextLevelXP) : 0.0;
    final pointsToNext = nextLevelXP - experiencePoints;

    return Container(
      padding: EdgeInsets.all(
          isSmallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      decoration: BoxDecoration(
        color:
            ThemeColors.getPrimaryButtonColor(context).withOpacity( 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seviye $currentLevel',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$experiencePoints/$nextLevelXP XP',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacingS),
          LinearProgressIndicator(
            value: progressPercentage.clamp(0.0, 1.0),
            backgroundColor:
                ThemeColors.getCardBackground(context).withOpacity( 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColors.getPrimaryButtonColor(context),
            ),
          ),
          SizedBox(height: DesignSystem.spacingS),
          Text(
            'Sonraki seviyeye $pointsToNext XP kaldı',
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 11.0 : 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStats(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Get dynamic quiz statistics
    final totalQuizzes = _userProgress?.completedQuizzes ?? 0;
    // For now, assume win rate is based on duel wins vs total duels (simplified)
    final totalDuels = _userProgress?.totalDuels ?? 0;
    final duelWins = _userProgress?.duelWins ?? 0;
    final winRatePercentage = totalDuels > 0 ? ((duelWins / totalDuels) * 100).round() : 0;
    final averageTime = _userProgress != null && _userProgress!.totalTimeSpent > 0 && totalQuizzes > 0
        ? '${(_userProgress!.totalTimeSpent / totalQuizzes).round()}dk'
        : '2.3dk'; // fallback

    return Container(
      padding: EdgeInsets.all(
          isSmallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: ThemeColors.getSuccessColor(context).withOpacity( 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz İstatistikleri',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 14.0 : 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignSystem.spacingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.quiz,
                value: '$totalQuizzes',
                label: 'Toplam Quiz',
                color: ThemeColors.getSuccessColor(context),
              ),
              _buildStatItem(
                context,
                icon: Icons.check_circle,
                value: '$winRatePercentage%',
                label: 'Doğru Oran',
                color: ThemeColors.getSuccessColor(context),
              ),
              _buildStatItem(
                context,
                icon: Icons.timer,
                value: averageTime,
                label: 'Ort. Süre',
                color: ThemeColors.getInfoColor(context),
              ),
            ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity( 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20.0 : 24.0,
          ),
        ),
        SizedBox(height: DesignSystem.spacingXs),
        Text(
          value,
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: isSmallScreen ? 14.0 : 16.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: ThemeColors.getSecondaryText(context),
            fontSize: isSmallScreen ? 10.0 : 12.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentAchievements(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Get recent achievements (last 3)
    final recentAchievements = _userAchievements.take(3).toList();

    if (recentAchievements.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Başarılar',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 14.0 : 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: DesignSystem.spacingS),
          Text(
            'Henüz başarı kazanmadınız. Quiz çözerek başarı kazanmaya başlayın!',
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 12.0 : 14.0,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Başarılar',
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: isSmallScreen ? 14.0 : 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: DesignSystem.spacingS),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentAchievements.length,
            itemBuilder: (context, index) {
              final achievement = recentAchievements[index];
              return Container(
                width: 70,
                margin: EdgeInsets.only(right: DesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: ThemeColors.getCardBackground(context)
                      .withOpacity( 0.5),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(
                    color: _getRarityColor(achievement.rarity.name)
                        .withOpacity( 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 2),
                    Text(
                      achievement.title,
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSummarySection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final sectionTitleFontSize = isSmallScreen ? 16.0 : 20.0;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'İstatistik Özeti',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen
                  ? DesignSystem.spacingS
                  : DesignSystem.spacingM),
              child: Column(
                children: [
                  // Quick Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: DesignSystem.spacingS,
                    crossAxisSpacing: DesignSystem.spacingS,
                    childAspectRatio: isSmallScreen ? 1.5 : 1.8,
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.timer,
                        title: 'Toplam Süre',
                        value: '${(_userProgress?.totalTimeSpent ?? 0) ~/ 60}h ${(_userProgress?.totalTimeSpent ?? 0) % 60}dk',
                        subtitle: 'Oyun süresi',
                        color: ThemeColors.getInfoColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.local_fire_department,
                        title: 'En Uzun Seri',
                        value: '${_userProgress?.loginStreak ?? 0} gün',
                        subtitle: 'Giriş serisi',
                        color: ThemeColors.getSuccessColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.trending_up,
                        title: 'En Yüksek Skor',
                        value: '${_userProgress?.bestScore ?? 0}/15',
                        subtitle: 'Quiz skoru',
                        color: ThemeColors.getWarningColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.people,
                        title: 'Düello Kazanma',
                        value: _userProgress != null && _userProgress!.totalDuels > 0
                            ? '%${((_userProgress!.duelWins / _userProgress!.totalDuels) * 100).round()}'
                            : '%0',
                        subtitle: '${_userProgress?.totalDuels ?? 0} düello',
                        color: Colors.purple,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.eco,
                        title: 'Çevre Puanı',
                        value: '${_userProgress?.totalPoints ?? 0}',
                        subtitle: 'Toplam puan',
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.emoji_events,
                        title: 'Başarılar',
                        value: '${_userAchievements.length}',
                        subtitle: 'Kazanılan rozet',
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.quiz,
                        title: 'Çözülen Quiz',
                        value: '${_userProgress?.completedQuizzes ?? 0}',
                        subtitle: 'Toplam quiz',
                        color: ThemeColors.getPrimaryButtonColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Günlük Görev',
                        value: '${_dailyChallenges.length}',
                        subtitle: 'Aktif görev',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  
                  // Weekly Progress Chart
                  Container(
                    padding: EdgeInsets.all(DesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryButtonColor(context)
                          .withOpacity( 0.05),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Haftalık Aktivite',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: DesignSystem.spacingS),
                        _buildWeeklyChart(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: color.withOpacity( 0.05),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: color.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20.0 : 24.0,
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 14.0 : 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 10.0 : 12.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 8.0 : 10.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDuelModeSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              '⚔️ Düello Modu - Ana Özellik',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 20.0 : 24.0,
                fontWeight: FontWeight.w800,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                      isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.deepPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity( 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showDuelOptionsDialog(context),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          size: isSmallScreen ? 48.0 : 64.0,
                          color: Colors.white,
                        ),
                        SizedBox(height: DesignSystem.spacingM),
                        Text(
                          'Hızlı Düello',
                          style: TextStyle(
                            color: ThemeColors.getTextOnColoredBackground(context),
                            fontSize: isSmallScreen ? 18.0 : 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: DesignSystem.spacingS),
                        Text(
                          'Arkadaşınla hızlı yarış!',
                          style: TextStyle(
                            color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.9),
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: DesignSystem.spacingM),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.spacingM,
                            vertical: DesignSystem.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity( 0.2),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                          ),
                          child: Text(
                            'Başlat',
                            style: TextStyle(
                              color: ThemeColors.getTextOnColoredBackground(context),
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12.0 : 16.0),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(
                      isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.red,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity( 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.duel),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people,
                          size: isSmallScreen ? 48.0 : 64.0,
                          color: Colors.white,
                        ),
                        SizedBox(height: DesignSystem.spacingM),
                        Text(
                          'Oda Oluştur',
                          style: TextStyle(
                            color: ThemeColors.getTextOnColoredBackground(context),
                            fontSize: isSmallScreen ? 18.0 : 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: DesignSystem.spacingS),
                        Text(
                          'Kalıcı düello odası',
                          style: TextStyle(
                            color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.9),
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: DesignSystem.spacingM),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.spacingM,
                            vertical: DesignSystem.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity( 0.2),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                          ),
                          child: Text(
                            'Oluştur',
                            style: TextStyle(
                              color: ThemeColors.getTextOnColoredBackground(context),
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplayerSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'Çoklu Oynama',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 18.0 : 22.0,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
                isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal,
                  Colors.cyan,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity( 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.multiplayerLobby),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: isSmallScreen ? 48.0 : 64.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: DesignSystem.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Takım Oyunu',
                              style: TextStyle(
                                color: ThemeColors.getTextOnColoredBackground(context),
                                fontSize: isSmallScreen ? 18.0 : 22.0,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: DesignSystem.spacingS),
                            Text(
                              '4 kişiye kadar oyna!',
                              style: TextStyle(
                                color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.9),
                                fontSize: isSmallScreen ? 14.0 : 16.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.spacingM,
                          vertical: DesignSystem.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity( 0.2),
                          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        ),
                        child: Text(
                          'Oyna',
                          style: TextStyle(
                            color: ThemeColors.getTextOnColoredBackground(context),
                            fontSize: isSmallScreen ? 14.0 : 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  Container(
                    padding: EdgeInsets.all(DesignSystem.spacingS),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMultiplayerFeature(
                          context,
                          icon: Icons.add_circle,
                          text: 'Oda Oluştur',
                          color: Colors.white,
                        ),
                        _buildMultiplayerFeature(
                          context,
                          icon: Icons.login,
                          text: 'Koda Katıl',
                          color: Colors.white,
                        ),
                        _buildMultiplayerFeature(
                          context,
                          icon: Icons.login,
                          text: 'Koda Katıl',
                          color: Colors.white,
                        ),
                        _buildMultiplayerFeature(
                          context,
                          icon: Icons.people,
                          text: 'Aktif Odalar',
                          color: Colors.white,
                        ),
                        _buildMultiplayerFeature(
                          context,
                          icon: Icons.visibility,
                          text: 'İzleyici Modu',
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpectatorModeSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'İzleyici Modu',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 18.0 : 22.0,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen
                  ? DesignSystem.spacingS
                  : DesignSystem.spacingM),
              child: Column(
                children: [
                  // Live Games Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity( 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.live_tv,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: DesignSystem.spacingM),
                      Expanded(
                        child: Text(
                          'Canlı Oyunlar',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'CANLI',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.spacingM),

                  // Live Games List (Mock data for now)
                  _buildLiveGameItem(
                    context,
                    player1: 'Ahmet K.',
                    player2: 'Mehmet Y.',
                    gameType: 'Düello',
                    spectators: 12,
                    timeRemaining: '2:34',
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: DesignSystem.spacingS),
                  _buildLiveGameItem(
                    context,
                    player1: 'Ayşe D.',
                    player2: 'Fatma S.',
                    gameType: 'Takım Oyunu',
                    spectators: 8,
                    timeRemaining: '5:12',
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: DesignSystem.spacingS),
                  _buildLiveGameItem(
                    context,
                    player1: 'Ali V.',
                    player2: 'Can B.',
                    gameType: 'Düello',
                    spectators: 15,
                    timeRemaining: '1:58',
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: DesignSystem.spacingM),

                  // Spectator Mode Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo,
                          Colors.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity( 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.spectatorMode),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                      child: Column(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: isSmallScreen ? 48.0 : 64.0,
                            color: Colors.white,
                          ),
                          SizedBox(height: DesignSystem.spacingM),
                          Text(
                            'İzleyici Moduna Geç',
                            style: TextStyle(
                              color: ThemeColors.getTextOnColoredBackground(context),
                              fontSize: isSmallScreen ? 18.0 : 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: DesignSystem.spacingS),
                          Text(
                            'Canlı oyunları izle ve öğren',
                            style: TextStyle(
                              color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.9),
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: DesignSystem.spacingM),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignSystem.spacingM,
                              vertical: DesignSystem.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity( 0.2),
                              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                            ),
                            child: Text(
                              'İzlemeye Başla',
                              style: TextStyle(
                                color: ThemeColors.getTextOnColoredBackground(context),
                                fontSize: isSmallScreen ? 14.0 : 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGameItem(
    BuildContext context, {
    required String player1,
    required String player2,
    required String gameType,
    required int spectators,
    required String timeRemaining,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context).withOpacity( 0.5),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: Colors.red.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Players
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$player1 vs $player2',
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: isSmallScreen ? 14.0 : 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  gameType,
                  style: TextStyle(
                    color: ThemeColors.getSecondaryText(context),
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                  ),
                ),
              ],
            ),
          ),

          // Spectators & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    color: Colors.red,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$spectators',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                timeRemaining,
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          SizedBox(width: DesignSystem.spacingM),

          // Watch Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'İzle',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplayerFeature(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDuelOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        ),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacingXl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ThemeColors.getGradientColors(context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: DesignSystem.spacingM),
                  Expanded(
                    child: Text(
                      'Düello Seçenekleri',
                      style: DesignSystem.getHeadlineSmall(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSystem.spacingL),
              Text(
                'Hangi düello türünü tercih edersiniz?',
                style: DesignSystem.getBodyLarge(context).copyWith(
                  color: Colors.white.withOpacity( 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingL),
              Column(
                children: [
                  _buildDuelOptionButton(
                    context,
                    icon: Icons.flash_on,
                    title: 'Hızlı Düello',
                    description: '5 soru, 15 saniye süre',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.duel);
                    },
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  _buildDuelOptionButton(
                    context,
                    icon: Icons.people,
                    title: 'Oda Düellosu',
                    description: 'Kalıcı oda ile arkadaşınla oyna',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.duel);
                    },
                  ),
                ],
              ),
              const SizedBox(height: DesignSystem.spacingL),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: DesignSystem.getLabelLarge(context).copyWith(
                    color: Colors.white.withOpacity( 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuelOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DesignSystem.spacingM),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity( 0.1),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity( 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignSystem.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.getTitleMedium(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: DesignSystem.getBodySmall(context).copyWith(
                      color: Colors.white.withOpacity( 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity( 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintWidget(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              '🌱 Çevre Bilinci',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 18.0 : 22.0,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
                isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity( 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.carbonFootprint),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: isSmallScreen ? 48.0 : 64.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  Text(
                    'Karbon Ayak İzini Hesapla',
                    style: TextStyle(
                      color: ThemeColors.getTextOnColoredBackground(context),
                      fontSize: isSmallScreen ? 18.0 : 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSystem.spacingS),
                  Text(
                    'Çevreye duyarlılığını ölç, iyileştirme önerileri al!',
                    style: TextStyle(
                      color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.9),
                      fontSize: isSmallScreen ? 14.0 : 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingM,
                      vertical: DesignSystem.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.2),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Text(
                      'Hemen Başla',
                      style: TextStyle(
                        color: ThemeColors.getTextOnColoredBackground(context),
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Get weekly activity data from user progress
    final weeklyActivity = _userProgress?.weeklyActivity ?? {};
    final now = DateTime.now();

    // Create week data for the last 7 days
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayName = _getDayName(date.weekday);
      final value = weeklyActivity[dayKey] ?? 0;

      // Normalize value to 0-1 range (assuming max 10 activities per day)
      final normalizedValue = (value / 10.0).clamp(0.0, 1.0);

      return {
        'day': dayName,
        'value': normalizedValue,
        'actualValue': value,
      };
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekData.map((data) {
        final value = data['value'] as double;
        return Column(
          children: [
            Container(
              width: isSmallScreen ? 16.0 : 20.0,
              height: isSmallScreen ? 40.0 : 60.0,
              decoration: BoxDecoration(
                color: ThemeColors.getPrimaryButtonColor(context),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: (isSmallScreen ? 40.0 : 60.0) * value,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              data['day'] as String,
              style: TextStyle(
                color: ThemeColors.getSecondaryText(context),
                fontSize: isSmallScreen ? 10.0 : 12.0,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pzt';
      case 2: return 'Sal';
      case 3: return 'Çar';
      case 4: return 'Per';
      case 5: return 'Cum';
      case 6: return 'Cmt';
      case 7: return 'Paz';
      default: return '';
    }
  }

  Widget _buildDailyChallengesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final sectionTitleFontSize = isSmallScreen ? 16.0 : 20.0;

    return Container(
      margin: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? DesignSystem.spacingS
                    : DesignSystem.spacingM,
                vertical: DesignSystem.spacingS),
            child: Text(
              'Günlük Görevler',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity( 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen
                  ? DesignSystem.spacingS
                  : DesignSystem.spacingM),
              child: _dailyChallenges.isEmpty
                  ? _buildEmptyChallengesMessage(context, isSmallScreen)
                  : Column(
                      children: _dailyChallenges
                          .take(3)
                          .map((challenge) => _buildDailyChallengeItem(
                                context,
                                challenge: challenge,
                                isSmallScreen: isSmallScreen,
                              ))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChallengesMessage(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        Icon(
          Icons.task_alt,
          size: isSmallScreen ? 32.0 : 40.0,
          color: ThemeColors.getSecondaryText(context),
        ),
        SizedBox(height: DesignSystem.spacingS),
        Text(
          'Bugün için görev bulunamadı',
          style: TextStyle(
            color: ThemeColors.getSecondaryText(context),
            fontSize: isSmallScreen ? 14.0 : 16.0,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignSystem.spacingS),
        Text(
          'Yarın yeni günlük görevler sizi bekliyor!',
          style: TextStyle(
            color: ThemeColors.getSecondaryText(context),
            fontSize: isSmallScreen ? 12.0 : 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDailyChallengeItem(
    BuildContext context, {
    DailyChallenge? challenge,
    bool isSmallScreen = false,
    // Legacy parameters for backward compatibility
    IconData? icon,
    String? title,
    String? description,
    int? progress,
    int? target,
    String? reward,
    Color? color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final smallScreen = isSmallScreen || screenWidth < 360;
    
    // Use challenge data if available, otherwise use legacy parameters
    final challengeIcon = challenge?.icon ?? icon ?? Icons.task;
    final challengeTitle = challenge?.title ?? title ?? 'Görev';
    final challengeDescription = challenge?.description ?? description ?? '';
    final challengeProgress = challenge?.currentValue ?? progress ?? 0;
    final challengeTarget = challenge?.targetValue ?? target ?? 1;
    final challengeReward = challenge?.rewardPoints != null 
        ? '${challenge!.rewardPoints} Puan'
        : reward ?? '10 Puan';
    final challengeColor = _getChallengeColor(challenge?.type, color);
    
    final progressPercentage = challengeTarget > 0 
        ? (challengeProgress / challengeTarget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(
          smallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: challengeColor.withOpacity( 0.05),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: challengeColor.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: challengeColor.withOpacity( 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconFromString(challengeIcon.toString()),
              size: 20,
              color: challengeColor,
            ),
          ),
          SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challengeTitle,
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: smallScreen ? 14.0 : 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  challengeDescription,
                  style: TextStyle(
                    color: ThemeColors.getSecondaryText(context),
                    fontSize: smallScreen ? 12.0 : 14.0,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSystem.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: ThemeColors.getCardBackground(context)
                            .withOpacity( 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(challengeColor),
                      ),
                    ),
                    SizedBox(width: DesignSystem.spacingS),
                    Text(
                      '$challengeProgress/$challengeTarget',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: smallScreen ? 12.0 : 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Ödül: $challengeReward',
                  style: TextStyle(
                    color: challengeColor,
                    fontSize: smallScreen ? 11.0 : 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to get icon from string
  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case '🧠':
        return Icons.quiz;
      case '⚔️':
        return Icons.security;
      case '👥':
        return Icons.people;
      case '🤝':
        return Icons.group;
      case '⚡':
        return Icons.flash_on;
      case '💎':
        return Icons.diamond;
      default:
        return Icons.task;
    }
  }

  /// Helper method to get color for challenge type
  Color _getChallengeColor(ChallengeType? type, Color? fallback) {
    if (fallback != null) return fallback;
    
    switch (type) {
      case ChallengeType.quiz:
        return ThemeColors.getSuccessColor(context);
      case ChallengeType.duel:
        return Colors.purple;
      case ChallengeType.multiplayer:
        return ThemeColors.getInfoColor(context);
      case ChallengeType.social:
        return Colors.blue;
      case ChallengeType.special:
        return Colors.orange;
      default:
        return ThemeColors.getAccentButtonColor(context);
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Sıradan':
        return Colors.grey;
      case 'Nadir':
        return Colors.blue;
      case 'Destansı':
        return Colors.purple;
      case 'Efsanevi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showThemeSelectionDialog(BuildContext context) async {
    // If theme is remembered and we have a last selected theme, use it directly
    if (_rememberTheme && _lastSelectedTheme != null) {
      final result = await Navigator.of(context).pushNamed(
        AppRoutes.quiz,
        arguments: {
          'category': _lastSelectedTheme == 'Tümü' ? null : _lastSelectedTheme
        },
      );

      // Show quiz completion summary if quiz was completed
      if (result != null && result is int && mounted) {
        await _showQuizCompletionSummary(context, result);
      }
      return;
    }

    final themes = [
      {
        'name': 'Tümü',
        'description': 'Tüm çevre konularından karışık sorular',
        'icon': Icons.all_inclusive,
        'color': ThemeColors.getPrimaryButtonColor(context),
      },
      {
        'name': 'Enerji',
        'description': 'Enerji tasarrufu ve sürdürülebilir enerji',
        'icon': Icons.flash_on,
        'color': Colors.yellow,
      },
      {
        'name': 'Su',
        'description': 'Su tasarrufu ve su kaynakları yönetimi',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'name': 'Orman',
        'description': 'Orman koruma ve ağaçlandırma çalışmaları',
        'icon': Icons.forest,
        'color': Colors.green,
      },
      {
        'name': 'Geri Dönüşüm',
        'description': 'Atık yönetimi ve geri dönüşüm',
        'icon': Icons.recycling,
        'color': Colors.orange,
      },
      {
        'name': 'Ulaşım',
        'description': 'Çevre dostu ulaşım alternatifleri',
        'icon': Icons.directions_car,
        'color': Colors.purple,
      },
      {
        'name': 'Tüketim',
        'description': 'Sürdürülebilir tüketim alışkanlıkları',
        'icon': Icons.shopping_bag,
        'color': Colors.pink,
      },
    ];

    bool rememberThemeChoice = _rememberTheme;

    final selectedTheme = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ThemeColors.getGradientColors(context),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: DesignSystem.spacingM),
                    Expanded(
                      child: Text(
                        'Quiz Teması Seç',
                        style: DesignSystem.getHeadlineSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spacingM),
                Text(
                  'Hangi çevre temasında yarışmak istersiniz?',
                  style: DesignSystem.getBodyLarge(context).copyWith(
                    color: Colors.white.withOpacity( 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spacingL),

                // Theme Options
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: themes.map((theme) {
                        return Container(
                          margin: const EdgeInsets.only(
                              bottom: DesignSystem.spacingM),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity( 0.1),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusM),
                            border: Border.all(
                              color: ThemeColors.getTextOnColoredBackground(context).withOpacity( 0.2),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () =>
                                Navigator.pop(context, theme['name'] as String),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusM),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(DesignSystem.spacingM),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                        DesignSystem.spacingS),
                                    decoration: BoxDecoration(
                                      color: (theme['color'] as Color)
                                          .withOpacity( 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      theme['icon'] as IconData,
                                      color: theme['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: DesignSystem.spacingM),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          theme['name'] as String,
                                          style: DesignSystem.getTitleMedium(
                                                  context)
                                              .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          theme['description'] as String,
                                          style:
                                              DesignSystem.getBodySmall(context)
                                                  .copyWith(
                                            color: Colors.white
                                                .withOpacity( 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white.withOpacity( 0.5),
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

                const SizedBox(height: DesignSystem.spacingM),

                // Remember Theme Checkbox
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: rememberThemeChoice,
                        onChanged: (value) {
                          setState(() {
                            rememberThemeChoice = value ?? false;
                          });
                        },
                        activeColor: Colors.white,
                        checkColor: ThemeColors.getPrimaryButtonColor(context),
                      ),
                      const SizedBox(width: DesignSystem.spacingS),
                      Expanded(
                        child: Text(
                          'Bu temayı hatırla (sonraki quiz\'lerde otomatik seçilsin)',
                          style: DesignSystem.getBodySmall(context).copyWith(
                            color: Colors.white.withOpacity( 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignSystem.spacingL),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: DesignSystem.getLabelLarge(context).copyWith(
                      color: Colors.white.withOpacity( 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selectedTheme != null && mounted) {
      // Save theme preference
      await _saveThemePreference(selectedTheme, rememberThemeChoice);

      // Navigate to quiz with selected theme and handle result
      final result = await Navigator.of(context).pushNamed(
        AppRoutes.quiz,
        arguments: {'category': selectedTheme == 'Tümü' ? null : selectedTheme},
      );

      // Show quiz completion summary if quiz was completed
      if (result != null && result is int && mounted) {
        await _showQuizCompletionSummary(context, result);
      }
    }
  }

  void _showEditProfilePictureDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // ProfilePictureService kullanarak avatar seçeneklerini al
    final profilePictureService = ProfilePictureService();
    final avatars = profilePictureService.allAvatars;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Profil Resmi Seç',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getText(context),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 3 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                final avatar = avatars[index];
                return GestureDetector(
                  onTap: () async {
                    // ProfilePictureService kullanarak profil resmini güncelle
                    final profilePictureService = ProfilePictureService();
                    final profileService = ProfileService();

                    final success = await profilePictureService.updateProfilePicture(
                      avatar,
                      profileService,
                    );

                    if (success) {
                      // UI'yi yenile
                      _loadUserData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil resmi güncellendi'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil resmi güncellenirken hata oluştu'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemeColors.getBorder(context),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ThemeColors.getCardBackground(context),
                            child: Icon(
                              Icons.person,
                              color: ThemeColors.getSecondaryText(context),
                              size: isSmallScreen ? 24 : 32,
                            ),
                          );
                        },
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
              child: Text(
                'İptal',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final profilePictureService = ProfilePictureService();
                final profileService = ProfileService();

                // Kullanıcıdan kaynak seçmesini iste
                final source = await profilePictureService.showImageSourceDialog(context);
                if (source == null) return;

                // Resmi seç veya çek
                final imageFile = source == ImageSource.camera
                    ? await profilePictureService.pickImageFromCamera()
                    : await profilePictureService.pickImageFromGallery();

                if (imageFile != null) {
                  // Firebase'e yükle
                  final imageUrl = await profilePictureService.uploadImageToFirebase(imageFile);

                  if (imageUrl != null) {
                    // Profil resmini güncelle
                    final success = await profilePictureService.updateProfilePicture(
                      imageUrl,
                      profileService,
                    );

                    if (success) {
                      // UI'yi yenile
                      _loadUserData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil resmi güncellendi'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil resmi güncellenirken hata oluştu'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Resim yüklenirken hata oluştu'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Fotoğraf Çek'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showQuizCompletionSummary(
      BuildContext context, int score) async {
    // Update user progress and achievements
    AchievementService().updateProgress(
      completedQuizzes: 1,
    );

    // Send a reminder notification for next quiz
    // await NotificationService.scheduleQuizReminderNotification();

    // Get wrong answer categories from quiz logic
    // We need to access the quiz logic through the bloc
    // For now, we'll show a simple summary

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        ),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ThemeColors.getGradientColors(context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    score >= 12
                        ? Icons.emoji_events
                        : score >= 8
                            ? Icons.thumb_up
                            : Icons.lightbulb,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: DesignSystem.spacingM),
                  Expanded(
                    child: Text(
                      'Quiz Tamamlandı!',
                      style: DesignSystem.getHeadlineSmall(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSystem.spacingM),

              // Score Display
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score/15',
                      style: DesignSystem.getDisplaySmall(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingS),
                    Text(
                      score >= 12
                          ? 'Harika! Çevre konusunda çok bilgilisiniz!'
                          : score >= 8
                              ? 'Güzel! Daha fazla öğrenebilirsiniz.'
                              : 'Çalışmaya devam edin, çevre bilinciniz artacak!',
                      style: DesignSystem.getBodyMedium(context).copyWith(
                        color: Colors.white.withOpacity( 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignSystem.spacingL),

              // Learning Suggestion
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.yellow,
                          size: 20,
                        ),
                        const SizedBox(width: DesignSystem.spacingS),
                        Text(
                          'Öğrenme Önerisi',
                          style: DesignSystem.getTitleMedium(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spacingS),
                    Text(
                      'Bir sonraki quiz\'de yanlış cevapladığınız konulardan daha fazla soru çıkacak. Bu sayede zayıf olduğunuz alanlarda gelişebilirsiniz!',
                      style: DesignSystem.getBodySmall(context).copyWith(
                        color: Colors.white.withOpacity( 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DesignSystem.spacingL),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Ana Sayfa',
                        style: DesignSystem.getLabelLarge(context).copyWith(
                          color: Colors.white.withOpacity( 0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spacingS),
                  if (_rememberTheme)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showThemeSelectionDialog(context);
                        },
                        child: Text(
                          'Tema Değiştir',
                          style: DesignSystem.getLabelLarge(context).copyWith(
                            color: Colors.white.withOpacity( 0.9),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: DesignSystem.spacingS),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showThemeSelectionDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity( 0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignSystem.radiusM),
                        ),
                      ),
                      child: const Text('Tekrar Oyna'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
