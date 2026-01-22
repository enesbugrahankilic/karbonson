// lib/pages/profile_page.dart
// Gelişmiş Profil Sayfası - UID merkezli mimari ile tamamen dinamik

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_data.dart';
import '../models/profile_data.dart'; // For GameHistoryItem
import '../provides/profile_bloc.dart';
import '../services/profile_service.dart';
import '../services/profile_picture_service.dart';
import '../services/nickname_service.dart';
import '../theme/theme_colors.dart';
import '../core/navigation/app_router.dart';
import '../widgets/page_templates.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileService: ProfileService(),
      )..add(const LoadProfile('')),
      child: const ProfileContent(),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

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

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(ListenToProfile());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Profilim'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProfileBloc>().add(RefreshServerData());
            },
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_slideController),
            child: BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ThemeColors.getErrorColor(context),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else if (state is ProfileUpdateSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ThemeColors.getSuccessColor(context),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return _buildLoadingState();
                  } else if (state is ProfileLoaded) {
                    return _buildProfileContent(context, state.userData, state.currentNickname);
                  } else if (state is ProfileError) {
                    return _buildErrorState(context, state.message);
                  } else {
                    return _buildLoadingState();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Profil yükleniyor...',
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: ThemeColors.getErrorColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Hata Oluştu',
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: ThemeColors.getSecondaryText(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(const LoadProfile(''));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserData userData, String currentNickname) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section with profile identity
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getPrimaryButtonColor(context),
                ThemeColors.getAccentButtonColor(context),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _buildIdentityCard(context, userData, currentNickname),
        ),

        // Account Information Section
        _buildSectionHeader(context, 'Hesap Bilgileri'),
        _buildAccountInfoCard(context, userData),

        // Game Statistics Section
        _buildSectionHeader(context, 'Oyun İstatistikleri'),
        _buildGameStatistics(context, userData),

        // Achievements Section
        _buildSectionHeader(context, 'Başarımlar'),
        _buildAchievementsAndRewards(context, userData),

        // Game History Section
        _buildSectionHeader(context, 'Oyun Geçmişi'),
        _buildGameHistory(context, userData),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ThemeColors.getText(context),
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, UserData userData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.getBorder(context), width: 1),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, 'UID', userData.uid.substring(0, 8) + '...', Icons.fingerprint),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Kayıt Tarihi', _formatDate(userData.createdAt), Icons.calendar_today),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Son Giriş', _formatLastLogin(userData.lastLogin), Icons.access_time),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'E-posta Doğrulama', userData.isEmailVerified ? 'Doğrulanmış' : 'Doğrulanmamış',
              userData.isEmailVerified ? Icons.verified : Icons.unpublished,
              color: userData.isEmailVerified ? ThemeColors.getSuccessColor(context) : ThemeColors.getWarningColor(context)),
          const SizedBox(height: 12),
          _buildInfoRow(context, '2FA', userData.is2FAEnabled ? 'Aktif' : 'Pasif',
              userData.is2FAEnabled ? Icons.security : Icons.security_outlined,
              color: userData.is2FAEnabled ? ThemeColors.getSuccessColor(context) : ThemeColors.getSecondaryText(context)),
          if (userData.classLevel != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Sınıf', '${userData.classLevel}. Sınıf ${userData.classSection ?? ''}', Icons.school),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? ThemeColors.getPrimaryButtonColor(context)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? ThemeColors.getPrimaryButtonColor(context), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Bilinmiyor';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildIdentityCard(BuildContext context, UserData userData, String currentNickname) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showEditProfilePictureDialog(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: isSmallScreen ? 100 : 120,
                height: isSmallScreen ? 100 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 4,
                  ),
                ),
              ),
              CircleAvatar(
                radius: isSmallScreen ? 40 : 48,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: userData.profilePictureUrl != null
                    ? (userData.profilePictureUrl!.startsWith('assets/')
                        ? AssetImage(userData.profilePictureUrl!) as ImageProvider
                        : NetworkImage(userData.profilePictureUrl!) as ImageProvider)
                    : null,
                child: userData.profilePictureUrl == null
                    ? Text(
                        currentNickname.isNotEmpty
                            ? currentNickname[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ThemeColors.getPrimaryButtonColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showEditNicknameDialog(context, currentNickname),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentNickname.isNotEmpty ? currentNickname : 'Kullanıcı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                color: Colors.white.withOpacity(0.7),
                size: isSmallScreen ? 16 : 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copy, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'UID: ${userData.uid.substring(0, 8)}...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('UID kopyalandı (debug modunda)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kopyala',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameStatistics(BuildContext context, UserData userData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isSmallScreen ? 1.3 : 1.5,
        children: [
          _buildStatCard(
            context,
            icon: Icons.trending_up,
            title: 'Kazanma Oranı',
            value: '${(userData.winRate * 100).round()}%',
            color: ThemeColors.getSuccessColor(context),
          ),
          _buildStatCard(
            context,
            icon: Icons.games,
            title: 'Toplam Oyun',
            value: userData.totalGamesPlayed.toString(),
            color: ThemeColors.getInfoColor(context),
          ),
          _buildStatCard(
            context,
            icon: Icons.emoji_events,
            title: 'En Yüksek Skor',
            value: userData.highestScore.toString(),
            color: ThemeColors.getWarningColor(context),
          ),
          _buildStatCard(
            context,
            icon: Icons.analytics,
            title: 'Ortalama Puan',
            value: userData.averageScore.toString(),
            color: Colors.purple,
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
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 10 : 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsAndRewards(BuildContext context, UserData userData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      children: [
        // Main achievement card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ThemeColors.getPrimaryButtonColor(context).withOpacity(0.8),
                ThemeColors.getAccentButtonColor(context).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oyun Uzmanı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${userData.totalGamesPlayed} oyun oynandı',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.games, color: Colors.white, size: isSmallScreen ? 24 : 28),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kazanma Oranı',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      Text(
                        '%${(userData.winRate * 100).round()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: userData.winRate,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Achievement grid
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isSmallScreen ? 1.1 : 1.2,
            children: [
              _buildAchievementCard(
                context,
                icon: Icons.emoji_events,
                title: 'En Yüksek Skor',
                value: '${userData.highestScore}',
                subtitle: 'Puan',
                color: Colors.amber,
              ),
              _buildAchievementCard(
                context,
                icon: Icons.assignment_turned_in,
                title: 'Toplam Oyun',
                value: '${userData.totalGamesPlayed}',
                subtitle: 'Oynandı',
                color: Colors.green,
              ),
              _buildAchievementCard(
                context,
                icon: Icons.card_giftcard,
                title: 'Ortalama',
                value: '${userData.averageScore}',
                subtitle: 'Puan',
                color: Colors.purple,
              ),
              _buildAchievementCard(
                context,
                icon: Icons.local_fire_department,
                title: 'Kazanma Oranı',
                value: '%${(userData.winRate * 100).round()}',
                subtitle: 'Başarı',
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
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
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 10 : 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
              fontSize: isSmallScreen ? 9 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameHistory(BuildContext context, UserData userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: userData.recentGames.isEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.getBorder(context), width: 1),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.gamepad,
                    size: 48,
                    color: ThemeColors.getSecondaryText(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz oyun oynanmamış',
                    style: TextStyle(
                      color: ThemeColors.getSecondaryText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk oyununu oynamak için ana sayfaya git!',
                    style: TextStyle(
                      color: ThemeColors.getSecondaryText(context),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Sayfa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: ThemeColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.getBorder(context), width: 1),
              ),
              child: Column(
                children: userData.recentGames.take(10).map((game) => _buildGameHistoryItem(context, game)).toList(),
              ),
            ),
    );
  }

  Widget _buildGameHistoryItem(BuildContext context, GameHistoryItem game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ThemeColors.getBorder(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: game.isWin
                  ? ThemeColors.getSuccessColor(context).withOpacity(0.1)
                  : ThemeColors.getErrorColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              game.isWin ? Icons.check_circle : Icons.cancel,
              color: game.isWin
                  ? ThemeColors.getSuccessColor(context)
                  : ThemeColors.getErrorColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.isWin ? 'Kazandın' : 'Kaybettin',
                      style: TextStyle(
                        color: ThemeColors.getText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${game.score} puan',
                      style: TextStyle(
                        color: ThemeColors.getSecondaryText(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.gameType == 'single' ? 'Tek Oyuncu' : 'Çok Oyuncu',
                      style: TextStyle(
                        color: ThemeColors.getSecondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatGameDate(game.playedAt),
                      style: TextStyle(
                        color: ThemeColors.getSecondaryText(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime? lastLogin) {
    if (lastLogin == null) return 'Son giriş: Bilinmiyor';
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    if (difference.inMinutes < 1) return 'Son giriş: Az önce';
    if (difference.inHours < 1) return 'Son giriş: ${difference.inMinutes} dakika önce';
    if (difference.inDays < 1) return 'Son giriş: ${difference.inHours} saat önce';
    if (difference.inDays < 7) return 'Son giriş: ${difference.inDays} gün önce';
    return 'Son giriş: ${lastLogin.day}/${lastLogin.month}/${lastLogin.year}';
  }

  String _formatGameDate(DateTime playedAt) {
    final now = DateTime.now();
    final difference = now.difference(playedAt);
    if (difference.inMinutes < 1) return 'Az önce';
    if (difference.inHours < 1) return '${difference.inMinutes}dk';
    if (difference.inDays < 1) return '${difference.inHours}sa';
    if (difference.inDays < 7) return '${difference.inDays}g';
    return '${playedAt.day}/${playedAt.month}';
  }

  void _showEditNicknameDialog(BuildContext context, String currentNickname) {
    final TextEditingController controller = TextEditingController(text: currentNickname);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    String? validationError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Takma Adı Düzenle',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.getText(context),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Yeni Takma Ad',
                      hintText: 'Takma adınızı girin',
                      errorText: validationError,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: ThemeColors.getPrimaryButtonColor(context),
                          width: 2,
                        ),
                      ),
                    ),
                    maxLength: 20,
                    autofocus: true,
                    onChanged: (value) {
                      if (validationError != null) setState(() => validationError = null);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('İptal', style: TextStyle(color: ThemeColors.getSecondaryText(context))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newNickname = controller.text.trim();
                    final validation = NicknameValidator.validate(newNickname);
                    if (!validation.isValid) {
                      setState(() => validationError = validation.error);
                      return;
                    }
                    if (newNickname != currentNickname) {
                      context.read<ProfileBloc>().add(UpdateNickname(newNickname));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Takma ad güncelleniyor...'), duration: Duration(seconds: 1)),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditProfilePictureDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final profilePictureService = ProfilePictureService();
    final avatars = profilePictureService.allAvatars;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hazır Avatarlar',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.getText(context),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isSmallScreen ? 3 : 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = avatars[index];
                    return GestureDetector(
                      onTap: () async {
                        final profileService = ProfileService();
                        final success = await profilePictureService.updateProfilePicture(avatar, profileService);
                        if (success) {
                          context.read<ProfileBloc>().add(UpdateProfilePicture(avatar));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil resmi güncellendi'), duration: Duration(seconds: 2)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil resmi güncellenirken hata oluştu'), duration: Duration(seconds: 2)),
                          );
                        }
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeColors.getBorder(context), width: 2),
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final profileService = ProfileService();
                    final source = await profilePictureService.showImageSourceDialog(context);
                    if (source == null) return;
                    final imageFile = source == ImageSource.camera
                        ? await profilePictureService.pickImageFromCamera()
                        : await profilePictureService.pickImageFromGallery();
                    if (imageFile != null) {
                      final croppedFile = await profilePictureService.cropImage(imageFile, context);
                      if (croppedFile != null) {
                        final imageUrl = await profilePictureService.uploadImageToFirebase(croppedFile);
                        if (imageUrl != null) {
                          final success = await profilePictureService.updateProfilePicture(imageUrl, profileService);
                          if (success) {
                            context.read<ProfileBloc>().add(UpdateProfilePicture(imageUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil resmi güncellendi'), duration: Duration(seconds: 2)),
                            );
                          }
                        }
                      }
                    }
                    if (mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Fotoğraf Yükle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.getAccentButtonColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal', style: TextStyle(color: ThemeColors.getSecondaryText(context))),
            ),
          ],
        );
      },
    );
  }
}
