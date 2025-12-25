import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../core/navigation/app_router.dart';
import '../widgets/home_button.dart';
import '../widgets/language_selector_button.dart';
import '../services/achievement_service.dart';
import '../services/music_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _buttonControllers;
  String? _lastSelectedTheme;
  bool _rememberTheme = false;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    for (final controller in _buttonControllers) {
      controller.dispose();
    }
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive values
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 600;

    final appBarHeight =
        isSmallScreen ? 80.0 : (isMediumScreen ? 100.0 : 120.0);
    final titleFontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);

    return Scaffold(
      backgroundColor: ThemeColors.getCardBackground(context),
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.getCardBackground(context),
              ThemeColors.getCardBackground(context).withValues(alpha: 0.95),
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
                          'Ana Sayfa',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontWeight: FontWeight.w600,
                            fontSize: titleFontSize,
                          ),
                        ),
                      ),
                    ),
                    const LanguageSelectorButton(),
                  ],
                ),
              ),

              // Main Content - Scrollable if needed but fits screen
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16.0 : 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: _buildWelcomeSection(context),
                        ),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Quick Quiz Start Section
                        _buildQuickQuizSection(context),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Duel Mode Section
                        _buildDuelModeSection(context),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Progress & Achievements Section
                        _buildProgressSection(context),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Multiplayer Section
                        _buildMultiplayerSection(context),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Daily Challenges Section
                        _buildDailyChallengesSection(context),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Statistics Summary Section
                        _buildStatisticsSummarySection(context),

                        SizedBox(height: isSmallScreen ? 20.0 : 24.0),

                        // Recent Activity
                        _buildRecentActivitySection(context),

                        SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16.0 : 20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : (user?.email?.isNotEmpty == true
                        ? user!.email![0].toUpperCase()
                        : 'U'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18.0 : 22.0,
                  fontWeight: FontWeight.w600,
                ),
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
                    fontSize: isSmallScreen ? 20.0 : 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  user?.displayName ?? user?.email ?? 'Kullanıcı',
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
                    '1250 Puan',
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
                    '3 Rozet',
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
                  .withValues(alpha: 0.1),
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                  _buildActivityItem(
                    context,
                    icon: Icons.quiz,
                    title: 'Quiz tamamlandı',
                    subtitle: '2 saat önce',
                    color: ThemeColors.getSuccessColor(context),
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  _buildActivityItem(
                    context,
                    icon: Icons.people,
                    title: 'Yeni arkadaş eklendi',
                    subtitle: '1 gün önce',
                    color: ThemeColors.getInfoColor(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            color: color.withValues(alpha: 0.1),
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

  Widget _buildFloatingActionButton(BuildContext context) {
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
            color: ThemeColors.getPrimaryButtonColor(context)
                .withValues(alpha: 0.4),
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
              color:
                  ThemeColors.getCardBackground(context).withValues(alpha: 0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(DesignSystem.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingL),
                Text(
                  'Hızlı Menü',
                  style: DesignSystem.getTitleLarge(context).copyWith(
                    color: ThemeColors.getText(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.quiz,
                      label: 'Quiz Başlat',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.quiz);
                      },
                    ),
                    _buildSimpleMenuButton(
                      context,
                      icon: Icons.people,
                      label: 'Düello',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context)
                            .pushNamed(AppRoutes.multiplayerLobby);
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
                const SizedBox(height: DesignSystem.spacingM),
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
                        // Show help dialog
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spacingM),
              ],
            ),
          ),
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _showThemeSelectionDialog(context),
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
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18.0 : 22.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignSystem.spacingS),
                  Text(
                    'Çevre bilincini artır, puan kazan!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Text(
                      'Şimdi Başlat',
                      style: TextStyle(
                        color: Colors.white,
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.05),
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

    return Container(
      padding: EdgeInsets.all(
          isSmallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      decoration: BoxDecoration(
        color:
            ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seviye 5',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '450/500 XP',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacingS),
          LinearProgressIndicator(
            value: 0.9, // 450/500 = 0.9
            backgroundColor:
                ThemeColors.getCardBackground(context).withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeColors.getPrimaryButtonColor(context),
            ),
          ),
          SizedBox(height: DesignSystem.spacingS),
          Text(
            'Sonraki seviyeye 50 XP kaldı',
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

    return Container(
      padding: EdgeInsets.all(
          isSmallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
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
                value: '47',
                label: 'Toplam Quiz',
                color: ThemeColors.getSuccessColor(context),
              ),
              _buildStatItem(
                context,
                icon: Icons.check_circle,
                value: '89%',
                label: 'Doğru Oran',
                color: ThemeColors.getSuccessColor(context),
              ),
              _buildStatItem(
                context,
                icon: Icons.timer,
                value: '2.3dk',
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
            color: color.withValues(alpha: 0.1),
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

    final achievements = [
      {'icon': '🏆', 'title': 'Quiz Ustası', 'rarity': 'Nadir'},
      {'icon': '⚔️', 'title': 'Düello Başlangıcı', 'rarity': 'Sıradan'},
      {'icon': '🔥', 'title': 'Düzenli Oyuncu', 'rarity': 'Destansı'},
    ];

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
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 70,
                margin: EdgeInsets.only(right: DesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: ThemeColors.getCardBackground(context)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  border: Border.all(
                    color: _getRarityColor(achievement['rarity'] as String)
                        .withValues(alpha: 0.3),
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                        value: '12.5 saat',
                        subtitle: 'Son 30 gün',
                        color: ThemeColors.getInfoColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.local_fire_department,
                        title: 'En Uzun Seri',
                        value: '7 gün',
                        subtitle: 'Günlük quiz',
                        color: ThemeColors.getSuccessColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.trending_up,
                        title: 'En Yüksek Skor',
                        value: '14/15',
                        subtitle: 'Enerji konusu',
                        color: ThemeColors.getWarningColor(context),
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.people,
                        title: 'Düello Kazanma',
                        value: '%68',
                        subtitle: '15 düello',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  
                  // Weekly Progress Chart
                  Container(
                    padding: EdgeInsets.all(DesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryButtonColor(context)
                          .withValues(alpha: 0.05),
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
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
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
              'Düello Modu',
              style: DesignSystem.getTitleLarge(context).copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 18.0 : 22.0,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
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
                        color: Colors.purple.withValues(alpha: 0.3),
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
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18.0 : 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: DesignSystem.spacingS),
                        Text(
                          'Arkadaşınla hızlı yarış!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                          ),
                          child: Text(
                            'Başlat',
                            style: TextStyle(
                              color: Colors.white,
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
                        color: Colors.orange.withValues(alpha: 0.3),
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
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18.0 : 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: DesignSystem.spacingS),
                        Text(
                          'Kalıcı düello odası',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                          ),
                          child: Text(
                            'Oluştur',
                            style: TextStyle(
                              color: Colors.white,
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.teal.withValues(alpha: 0.3),
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
                                color: Colors.white,
                                fontSize: isSmallScreen ? 18.0 : 22.0,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: DesignSystem.spacingS),
                            Text(
                              '4 kişiye kadar oyna!',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        ),
                        child: Text(
                          'Oyna',
                          style: TextStyle(
                            color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.1),
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
                          icon: Icons.people,
                          text: 'Aktif Odalar',
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
                  color: Colors.white.withValues(alpha: 0.9),
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
                    color: Colors.white.withValues(alpha: 0.7),
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
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacingS),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Sample data for weekly activity
    final weekData = [
      {'day': 'Pzt', 'value': 0.8},
      {'day': 'Sal', 'value': 0.6},
      {'day': 'Çar', 'value': 0.9},
      {'day': 'Per', 'value': 0.7},
      {'day': 'Cum', 'value': 0.5},
      {'day': 'Cmt', 'value': 0.4},
      {'day': 'Paz', 'value': 0.3},
    ];
    
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                  _buildDailyChallengeItem(
                    context,
                    icon: Icons.quiz,
                    title: 'Günlük Quiz',
                    description: 'Bugün 3 quiz tamamla',
                    progress: 2,
                    target: 3,
                    reward: '25 Puan',
                    color: ThemeColors.getSuccessColor(context),
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  _buildDailyChallengeItem(
                    context,
                    icon: Icons.security,
                    title: 'Düello Mücadelesi',
                    description: 'Bugün 2 düello kazan',
                    progress: 1,
                    target: 2,
                    reward: '50 Puan',
                    color: Colors.purple,
                  ),
                  SizedBox(height: DesignSystem.spacingM),
                  _buildDailyChallengeItem(
                    context,
                    icon: Icons.people,
                    title: 'Sosyal Bağ',
                    description: 'Bugün 1 arkadaş ekle',
                    progress: 0,
                    target: 1,
                    reward: '15 Puan',
                    color: ThemeColors.getInfoColor(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int progress,
    required int target,
    required String reward,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final progressPercentage = progress / target;

    return Container(
      padding: EdgeInsets.all(
          isSmallScreen ? DesignSystem.spacingS : DesignSystem.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: isSmallScreen ? 14.0 : 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: ThemeColors.getSecondaryText(context),
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                  ),
                ),
                SizedBox(height: DesignSystem.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: ThemeColors.getCardBackground(context)
                            .withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    SizedBox(width: DesignSystem.spacingS),
                    Text(
                      '$progress/$target',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: isSmallScreen ? 12.0 : 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Ödül: $reward',
                  style: TextStyle(
                    color: color,
                    fontSize: isSmallScreen ? 11.0 : 12.0,
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
            padding: const EdgeInsets.all(DesignSystem.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryButtonColor(context)
                      .withValues(alpha: 0.2),
                  ThemeColors.getPrimaryButtonColor(context)
                      .withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context)
                    .withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.getPrimaryButtonColor(context)
                      .withValues(alpha: 0.2),
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
          const SizedBox(height: DesignSystem.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeColors.getText(context),
                  fontWeight: FontWeight.w500,
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
                    color: Colors.white.withValues(alpha: 0.9),
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
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusM),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
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
                                          .withValues(alpha: 0.2),
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
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white.withValues(alpha: 0.5),
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
                    color: Colors.white.withValues(alpha: 0.1),
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
                            color: Colors.white.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.7),
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
                  color: Colors.white.withValues(alpha: 0.1),
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                  color: Colors.white.withValues(alpha: 0.1),
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
                        color: Colors.white.withValues(alpha: 0.8),
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
                          color: Colors.white.withValues(alpha: 0.7),
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
                            color: Colors.white.withValues(alpha: 0.9),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
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
