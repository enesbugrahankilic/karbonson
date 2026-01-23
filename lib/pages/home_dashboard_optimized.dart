import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_colors.dart';
import '../core/navigation/app_router.dart';
import '../widgets/home_button.dart';
import '../widgets/language_selector_button.dart';
import '../widgets/page_templates.dart';
import '../services/achievement_service.dart';
import '../services/profile_service.dart';
import '../services/user_progress_service.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../models/user_data.dart';

class HomeDashboardOptimized extends StatefulWidget {
  HomeDashboardOptimized({super.key});

  @override
  State<HomeDashboardOptimized> createState() => _HomeDashboardOptimizedState();
}

class _HomeDashboardOptimizedState extends State<HomeDashboardOptimized>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  String? _lastSelectedTheme;
  bool _rememberTheme = false;

  // Dynamic data variables
  UserData? _userData;
  UserProgress? _userProgress;
  List<Achievement> _userAchievements = [];
  bool _isLoadingData = true;

  // Services
  final ProfileService _profileService = ProfileService();
  final UserProgressService _userProgressService = UserProgressService();
  final AchievementService _achievementService = AchievementService();

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

    // Load saved theme preference
    _loadThemePreference();

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Load user data
    _loadUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
      _achievementService.achievementsStream.listen((achievements) {
        if (mounted) {
          setState(() {
            _userAchievements = achievements;
          });
        }
      });
      
      // Listen to progress stream
      _achievementService.progressStream.listen((progress) {
        if (mounted) {
          setState(() {
            _userProgress = progress;
          });
        }
      });
      


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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive values - gelişmiş kontroller
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;
    final isLargeScreen = screenWidth > 800;

    final appBarHeight = isSmallScreen ? 70.0 : (isMediumScreen ? 85.0 : 100.0);
    final titleFontSize = isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : (isLargeScreen ? 24.0 : 20.0));
    
    // Text boyutları için responsive değerler
    final headerTextSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : (isLargeScreen ? 28.0 : 24.0));
    final bodyTextSize = isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 18.0);
    final smallTextSize = isSmallScreen ? 12.0 : 14.0;

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
                'Veriler yükleniyor...',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Ana Sayfa'),
        showBackButton: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Section
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOut,
                      )),
                      child: _buildWelcomeSection(context, isSmallScreen, headerTextSize, bodyTextSize, smallTextSize),
                    ),

                    SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                    // Quick Actions Grid
                    _buildQuickActionsGrid(context, isSmallScreen, bodyTextSize),

                    SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                    // Progress Overview
                    _buildProgressOverview(context, isSmallScreen, bodyTextSize, smallTextSize),

                    SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                    // Quick Quiz
                    _buildQuickQuizSection(context, isSmallScreen, headerTextSize, bodyTextSize),

                    SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                    // Recent Achievements
                    _buildRecentAchievements(context, isSmallScreen, bodyTextSize),

                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, isSmallScreen),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isSmallScreen, double headerTextSize, double bodyTextSize, double smallTextSize) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Get dynamic user data
    final displayName = _userData?.nickname ?? 
                       user?.displayName ?? 
                       user?.email?.split('@')[0] ?? 
                       'Kullanıcı';
    final totalPoints = _userProgress?.totalPoints ?? 0;
    final achievementCount = _userAchievements.length;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isSmallScreen ? 50.0 : 60.0,
            height: isSmallScreen ? 50.0 : 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryButtonColor(context),
                  ThemeColors.getAccentButtonColor(context),
                ],
              ),
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18.0 : 22.0,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                  'Merhaba 👋',
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: headerTextSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                Text(
                  displayName,
                  style: TextStyle(
                    color: ThemeColors.getSecondaryText(context),
                    fontSize: bodyTextSize,
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
                    '$totalPoints Puan',
                    style: TextStyle(
                      color: ThemeColors.getText(context),
                      fontSize: smallTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    '$achievementCount Rozet',
                    style: TextStyle(
                      color: ThemeColors.getText(context),
                      fontSize: smallTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  .withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: ThemeColors.getSuccessColor(context),
                fontSize: smallTextSize,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isSmallScreen, double bodyTextSize) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isSmallScreen ? 2 : 3,
            mainAxisSpacing: isSmallScreen ? 8.0 : 12.0,
            crossAxisSpacing: isSmallScreen ? 8.0 : 12.0,
            childAspectRatio: isSmallScreen ? 1.2 : 1.4,
            children: [
              _buildActionButton(
                context,
                icon: Icons.quiz,
                label: 'Quiz Başlat',
                color: ThemeColors.getPrimaryButtonColor(context),
                onTap: () => _showThemeSelectionDialog(context),
              ),
              _buildActionButton(
                context,
                icon: Icons.leaderboard,
                label: 'Liderlik',
                color: ThemeColors.getWarningColor(context),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.leaderboard),
              ),
              _buildActionButton(
                context,
                icon: Icons.people,
                label: 'Arkadaşlar',
                color: ThemeColors.getInfoColor(context),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.friends),
              ),
              _buildActionButton(
                context,
                icon: Icons.person,
                label: 'Profil',
                color: Colors.purple,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              ),
              _buildActionButton(
                context,
                icon: Icons.settings,
                label: 'Ayarlar',
                color: ThemeColors.getAccentButtonColor(context),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
              _buildActionButton(
                context,
                icon: Icons.emoji_events,
                label: 'Ödüller',
                color: Colors.amber,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.rewards),
              ),
              _buildActionButton(
                context,
                icon: Icons.help_outline,
                label: 'Yardım',
                color: Colors.blueGrey,
                onTap: () => _showHelpDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha:  0.1),
          borderRadius: BorderRadius.circular(isSmallScreen ? 8.0 : 12.0),
          border: Border.all(
            color: color.withValues(alpha:  0.3),
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
              label,
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontSize: isSmallScreen ? 10.0 : 12.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context, bool isSmallScreen, double bodyTextSize, double smallTextSize) {
    final level = 5;
    final currentXP = 450;
    final maxXP = 500;
    final progressPercentage = currentXP / maxXP;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İlerleme Özeti',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          
          // Level Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seviye $level',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: bodyTextSize,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$currentXP/$maxXP XP',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: smallTextSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: ThemeColors.getCardBackground(context).withValues(alpha:  0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColors.getPrimaryButtonColor(context),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Sonraki seviyeye ${maxXP - currentXP} XP kaldı',
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: smallTextSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuizSection(BuildContext context, bool isSmallScreen, double headerTextSize, double bodyTextSize) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context),
            ThemeColors.getAccentButtonColor(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showThemeSelectionDialog(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          children: [
            Icon(
              Icons.quiz,
              size: isSmallScreen ? 48.0 : 64.0,
              color: Colors.white,
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            Text(
              'Çevre Bilgisi Quiz\'i',
              style: TextStyle(
                color: Colors.white,
                fontSize: headerTextSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 6.0 : 8.0),
            Text(
              'Çevre bilincini artır, puan kazan!',
              style: TextStyle(
                color: Colors.white.withValues(alpha:  0.9),
                fontSize: bodyTextSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16.0 : 20.0,
                vertical: isSmallScreen ? 8.0 : 10.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:  0.2),
                borderRadius: BorderRadius.circular(isSmallScreen ? 16.0 : 20.0),
              ),
              child: Text(
                'Şimdi Başlat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(BuildContext context, bool isSmallScreen, double bodyTextSize) {
    final achievements = [
      {'icon': '🏆', 'title': 'Quiz Ustası', 'rarity': 'Nadir'},
      {'icon': '⚔️', 'title': 'Düello Başlangıcı', 'rarity': 'Sıradan'},
      {'icon': '🔥', 'title': 'Düzenli Oyuncu', 'rarity': 'Destansı'},
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Başarılar',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    color: ThemeColors.getCardBackground(context).withValues(alpha:  0.5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: _getRarityColor(achievement['rarity'] as String).withValues(alpha:  0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        achievement['icon'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 2),
                      Text(
                        achievement['title'] as String,
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
      ),
    );
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

  Widget _buildFloatingActionButton(BuildContext context, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context),
            ThemeColors.getAccentButtonColor(context),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.4),
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
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context).withValues(alpha:  0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withValues(alpha:  0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:  0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Hızlı Menü',
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.quiz,
                      label: 'Quiz Başlat',
                      onTap: () {
                        Navigator.pop(context);
                        _showThemeSelectionDialog(context);
                      },
                    ),
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.people,
                      label: 'Düello',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.multiplayerLobby);
                      },
                    ),
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.leaderboard,
                      label: 'Liderlik',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.leaderboard);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.person,
                      label: 'Arkadaşlar',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.friends);
                      },
                    ),
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.settings,
                      label: 'Ayarlar',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.settings);
                      },
                    ),
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.help_outline,
                      label: 'Yardım',
                      onTap: () {
                        Navigator.pop(context);
                        _showHelpDialog();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.2),
                  ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha:  0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 28,
              color: ThemeColors.getPrimaryButtonColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ThemeColors.getGradientColors(context),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Quiz Teması Seç',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Hangi çevre temasında yarışmak istersiniz?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:  0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // Theme Options
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: themes.map((theme) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:  0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:  0.2),
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, theme['name'] as String),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (theme['color'] as Color).withValues(alpha:  0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      theme['icon'] as IconData,
                                      color: theme['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          theme['name'] as String,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          theme['description'] as String,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha:  0.7),
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white.withValues(alpha:  0.5),
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

                const SizedBox(height: 16),

                // Remember Theme Checkbox
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:  0.1),
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bu temayı hatırla (sonraki quiz\'lerde otomatik seçilsin)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:  0.9),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:  0.7),
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

  Future<void> _showQuizCompletionSummary(BuildContext context, int score) async {
    // Update user progress and achievements
    AchievementService().updateProgress(
      completedQuizzes: 1,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ThemeColors.getGradientColors(context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Quiz Tamamlandı!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Score Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:  0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score/15',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      score >= 12
                          ? 'Harika! Çevre konusunda çok bilgilisiniz!'
                          : score >= 8
                              ? 'Güzel! Daha fazla öğrenebilirsiniz.'
                              : 'Çalışmaya devam edin, çevre bilinciniz artacak!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:  0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Ana Sayfa',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:  0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_rememberTheme)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showThemeSelectionDialog(context);
                        },
                        child: Text(
                          'Tema Değiştir',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:  0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showThemeSelectionDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha:  0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: ThemeColors.getDialogBackground(context),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline,
                        color: ThemeColors.getPrimaryButtonColor(context),
                        size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Yardım',
                      style: TextStyle(
                        color: ThemeColors.getTitleColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Eco Game hakkında yardıma mı ihtiyacınız var? Bu uygulama çevre bilincini artırmak için tasarlanmış eğlenceli bir quiz oyunudur. Quiz çözerek puan kazanabilir, rozetler elde edebilir ve arkadaşlarınızla yarışabilirsiniz.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}