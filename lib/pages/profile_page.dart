// lib/pages/profile_page.dart
// Gelişmiş Profil Sayfası - UID merkezli mimari ile iki aşamalı yükleme

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:clipboard/clipboard.dart'; // Using built-in services
import '../models/profile_data.dart';
import '../provides/profile_bloc.dart';
import '../services/profile_service.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../core/navigation/app_router.dart';
import '../widgets/home_button.dart';

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: ThemeColors.getCardBackground(context),
      appBar: AppBar(
        leading: const HomeButton(),
        title: Text(
          'Profilim',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: ThemeColors.getText(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: ThemeColors.getPrimaryButtonColor(context),
            ),
            onPressed: () {
              context.read<ProfileBloc>().add(RefreshServerData());
            },
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideController),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return _buildLoadingState();
              } else if (state is ProfileLoaded) {
                return _buildProfileContent(context, state.profileData, state.currentNickname);
              } else if (state is ProfileError) {
                return _buildErrorState(context, state.message);
              } else {
                return _buildLoadingState();
              }
            },
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

  Widget _buildProfileContent(BuildContext context, ProfileData profileData, String currentNickname) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Üst Bölüm: Kimlik Kartı (Sunucu Verisi)
          _buildIdentityCard(context, profileData.serverData, currentNickname),
          const SizedBox(height: 24),

          // B. Orta Bölüm: Oyun İstatistikleri (Lokal Veri)
          _buildGameStatistics(context, profileData.localData),
          const SizedBox(height: 24),

          // C. Alt Bölüm: Oyun Geçmişi (Lokal Veri)
          _buildGameHistory(context, profileData.localData),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context, ServerProfileData? serverData, String currentNickname) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
            color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profil Resmi ve Seviye Halkası
          Stack(
            alignment: Alignment.center,
            children: [
              // Seviye Halkası
              Container(
                width: isSmallScreen ? 100 : 120,
                height: isSmallScreen ? 100 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 4,
                  ),
                ),
              ),
              // Profil Avatarı
              CircleAvatar(
                radius: isSmallScreen ? 40 : 48,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: serverData?.profilePictureUrl != null
                    ? NetworkImage(serverData!.profilePictureUrl!)
                    : null,
                child: serverData?.profilePictureUrl == null
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
            ],
          ),
          const SizedBox(height: 16),

          // Nickname
          Text(
            currentNickname.isNotEmpty ? currentNickname : 'Kullanıcı',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // UID
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copy,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'UID: ${serverData?.uid.substring(0, 8) ?? "Bilinmiyor"}...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
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
                  if (serverData?.uid != null) {
                    // Copy to clipboard functionality
                    // FlutterClipboard.copy(serverData!.uid);
                    debugPrint('UID kopyalanacak: ${serverData!.uid}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UID kopyalandı (debug modunda)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
          const SizedBox(height: 8),

          // Son Giriş
          Text(
            _formatLastLogin(serverData?.lastLogin),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isSmallScreen ? 11 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatistics(BuildContext context, LocalStatisticsData localData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oyun İstatistikleri',
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        
        // 2x2 Grid Layout
        GridView.count(
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
              value: '${(localData.winRate * 100).round()}%',
              color: ThemeColors.getSuccessColor(context),
            ),
            _buildStatCard(
              context,
              icon: Icons.games,
              title: 'Toplam Oyun',
              value: localData.totalGamesPlayed.toString(),
              color: ThemeColors.getInfoColor(context),
            ),
            _buildStatCard(
              context,
              icon: Icons.emoji_events,
              title: 'En Yüksek Skor',
              value: localData.highestScore.toString(),
              color: ThemeColors.getWarningColor(context),
            ),
            _buildStatCard(
              context,
              icon: Icons.analytics,
              title: 'Ortalama Puan',
              value: localData.averageScore.toString(),
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
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
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 20 : 24,
            ),
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

  Widget _buildGameHistory(BuildContext context, LocalStatisticsData localData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oyun Geçmişi',
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        if (localData.recentGames.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeColors.getBorder(context),
                width: 1,
              ),
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
        else
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeColors.getBorder(context),
                width: 1,
              ),
            ),
            child: Column(
              children: localData.recentGames
                  .take(10)
                  .map((game) => _buildGameHistoryItem(context, game))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildGameHistoryItem(BuildContext context, GameHistoryItem game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ThemeColors.getBorder(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Sonuç İkonu
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: game.isWin
                  ? ThemeColors.getSuccessColor(context).withValues(alpha: 0.1)
                  : ThemeColors.getErrorColor(context).withValues(alpha: 0.1),
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

          // Oyun Bilgileri
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

    if (difference.inMinutes < 1) {
      return 'Son giriş: Az önce';
    } else if (difference.inHours < 1) {
      return 'Son giriş: ${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return 'Son giriş: ${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return 'Son giriş: ${difference.inDays} gün önce';
    } else {
      return 'Son giriş: ${lastLogin.day}/${lastLogin.month}/${lastLogin.year}';
    }
  }

  String _formatGameDate(DateTime playedAt) {
    final now = DateTime.now();
    final difference = now.difference(playedAt);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}dk';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}sa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g';
    } else {
      return '${playedAt.day}/${playedAt.month}';
    }
  }
}
