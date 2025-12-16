// lib/pages/profile_page.dart
// Enhanced with UID Centrality, Presence System, and Offline-First Strategy (III.1-III.4)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../provides/profile_bloc.dart';
import '../services/profile_service.dart';
import '../services/presence_service.dart';
import '../services/friendship_service.dart';
import '../services/authentication_state_service.dart';
import '../services/email_otp_service.dart';
import '../services/biometric_user_service.dart';
import '../services/biometric_service.dart';
import '../models/profile_data.dart';
import '../models/user_data.dart';
import '../theme/theme_colors.dart';
import '../widgets/copy_to_clipboard_widget.dart';
import '../widgets/profile_picture_change_dialog.dart';
import '../widgets/biometric_setup_widget.dart';
import '../widgets/home_button.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'email_otp_verification_page.dart';
import '../services/app_localizations.dart';
import '../provides/language_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // Services for enhanced functionality
  final PresenceService _presenceService = PresenceService();
  final FriendshipService _friendshipService = FriendshipService();
  final ProfileService _profileService = ProfileService();
  final AuthenticationStateService _authStateService = AuthenticationStateService();
  
  // Stream for real-time presence updates
  StreamSubscription? _presenceSubscription;
  Map<String, PresenceStatus> _friendPresence = {};
  
  // Registration status
  bool _isRegistered = false;
  bool _isCheckingRegistration = true;

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

    // Check registration status first
    _checkRegistrationStatus();
    
    // Listen to language changes
    context.read<LanguageProvider>().addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() {
      _isCheckingRegistration = true;
    });

    try {
      final isRegistered = await _profileService.isUserRegistered();
      setState(() {
        _isRegistered = isRegistered;
        _isCheckingRegistration = false;
      });

      if (_isRegistered) {
        // Start animations for registered users
        _fadeController.forward();
        _slideController.forward();
        
        // Initialize presence service
        _initializePresenceService();
        
        // Initialize authentication state service
        await _authStateService.initializeAuthState();
      }
    } catch (e) {
      setState(() {
        _isRegistered = false;
        _isCheckingRegistration = false;
      });
    }
  }

  Future<void> _initializePresenceService() async {
    await _presenceService.initialize();
    
    // Set user as online
    _presenceService.setUserOnline();
    
    // Listen to friends presence if available
    _setupFriendsPresenceListener();
  }

  void _setupFriendsPresenceListener() {
    // Get friends and set up presence listener
    _friendshipService.getFriends().then((friends) {
      if (friends.isNotEmpty) {
        final friendIds = friends.map((friend) => friend.id).toList();
        _presenceSubscription = _presenceService.listenToFriendsPresence(friendIds).listen(
          (presenceMap) {
            if (mounted) {
              setState(() {
                _friendPresence = presenceMap;
              });
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _presenceSubscription?.cancel();
    _presenceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking registration status
    if (_isCheckingRegistration) {
      return const _RegistrationCheckScreen();
    }

    // Show registration prompt for unregistered users
    if (!_isRegistered) {
      return const _UnregisteredUserScreen();
    }

    // Show profile page for registered users
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(AppLocalizations.profile, style: TextStyle(color: ThemeColors.getAppBarText(context)));
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: ThemeColors.getAppBarIcon(context)),
        actions: [
          // Change Password button
          IconButton(
            icon: const Icon(Icons.lock_reset),
            onPressed: () => _showChangePasswordDialog(context),
            tooltip: 'Şifre Değiştir',
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => ProfileBloc(
          profileService: ProfileService(),
        ),
        child: const ProfileContent(),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı bilgileri bulunamadı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Email OTP ile şifre sıfırlama
    _sendPasswordResetCode(context, user.email!);
  }

  Future<void> _sendPasswordResetCode(BuildContext context, String email) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Şifre Sıfırlama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                '${email.replaceRange(2, email.indexOf('@'), '***')} adresine 6 haneli doğrulama kodu gönderilecek.',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _startEmailOtpFlow(context, email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kod Gönder'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startEmailOtpFlow(BuildContext context, String email) async {
    try {
      final result = await EmailOtpService.sendOtpCode(
        email: email,
        purpose: 'profile_reset',
      );

      if (result.isSuccess) {
        // Email OTP sayfasına yönlendir
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EmailOtpVerificationPage(
              email: email,
              purpose: 'profile_reset',
            ),
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kod gönderilemedi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.getLogoutButtonBackground(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Set user as offline
      _presenceService.setUserOffline();
      _presenceService.dispose();

      // Clear authentication state service
      _authStateService.clearAuthenticationState();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate back to login page
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  void initState() {
    super.initState();
    // Automatically load profile when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(const LoadProfile(''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const _LoadingState();
        } else if (state is ProfileLoaded) {
          return _buildProfileContent(context, state);
        } else if (state is ProfileError) {
          return _ErrorState(message: state.message);
        } else {
          return const _LoadingState();
        }
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(RefreshServerData());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeIn,
                )),
                child: _IdentityCard(profileData: state.profileData),
              ),
            ),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOut,
                )),
                child: _StatisticsCards(localData: state.profileData.localData),
              ),
            ),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOut,
                )),
                child: const _BiometricSettingsSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOut,
                )),
                child: _GameHistoryList(games: state.profileData.localData.recentGames),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Profil yükleniyor...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Refresh or retry logic
                  final nickname = 'Oyuncu'; // Default fallback
                  context.read<ProfileBloc>().add(LoadProfile(nickname));
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final ProfileData profileData;

  const _IdentityCard({required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture with Level Ring
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => ProfilePictureChangeDialog(
                  currentProfilePictureUrl: profileData.serverData?.profilePictureUrl,
                  onProfilePictureUpdated: (imageUrl) {
                    // Image cache'i temizle
                    imageCache.clearLiveImages();
                    imageCache.clear();
                    imageCache.clearLiveImages();
                    // Profil resmini hemen güncelle
                    context.read<ProfileBloc>().add(UpdateProfilePicture(imageUrl));
                    // Backend'i de senkronize et (arka planda)
                    context.read<ProfileBloc>().add(RefreshServerData());
                  },
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Level Ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileData.serverData?.profilePictureUrl != null && profileData.serverData!.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(profileData.serverData!.profilePictureUrl!)
                        : null,
                    onBackgroundImageError: profileData.serverData?.profilePictureUrl != null 
                        ? (exception, stackTrace) {
                            if (kDebugMode) {
                              print('❌ Failed to load profile picture: $exception');
                            }
                          }
                        : null,
                    child: (profileData.serverData?.profilePictureUrl == null || profileData.serverData!.profilePictureUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 56, color: Colors.grey)
                        : null,
                  ),
                ),
                // Edit Icon
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Level Badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Lvl 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
          const SizedBox(height: 20),
          
          // Nickname
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              profileData.serverData?.nickname ?? 'Yükleniyor...',
              key: ValueKey(profileData.serverData?.nickname),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTitleColor(context),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // UID with copy button
          if (profileData.serverData?.uid != null)
            CopyToClipboardWidget(
              textToCopy: profileData.serverData!.uid,
              successMessage: 'UID kopyalandı!',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'UID: ${profileData.serverData!.uid}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getStatsCardText(context),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'UID: Yükleniyor...',
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getStatsCardText(context),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Last Login
          if (profileData.serverData?.lastLogin != null)
            Text(
              'Son giriş: ${_formatDate(profileData.serverData!.lastLogin!)}',
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.getStatsCardText(context),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}

class _StatisticsCards extends StatelessWidget {
  final LocalStatisticsData localData;

  const _StatisticsCards({required this.localData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Oyun İstatistikleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: 'Kazanma Oranı',
                value: '${(localData.winRate * 100).toInt()}%',
                color: ThemeColors.getSuccessColor(context),
              ),
              _buildStatCard(
                context,
                icon: Icons.gamepad,
                title: 'Toplam Oyun',
                value: localData.totalGamesPlayed.toString(),
                color: ThemeColors.getInfoColor(context),
              ),
              _buildStatCard(
                context,
                icon: Icons.star,
                title: 'En Yüksek Skor',
                value: localData.highestScore.toString(),
                color: ThemeColors.getWarningColor(context),
              ),
              _buildStatCard(
                context,
                icon: Icons.analytics,
                title: 'Ortalama Puan',
                value: localData.averageScore.toString(),
                color: ThemeColors.getAccentButtonColor(context),
              ),
            ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: ThemeColors.getStatsCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.getStatsCardText(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameHistoryList extends StatelessWidget {
  final List<GameHistoryItem> games;

  const _GameHistoryList({required this.games});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Son Skorlar ve Geçmiş',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (games.isEmpty)
            _buildEmptyState(context)
          else
            _buildGameList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.getHistoryCardBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.gamepad,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz oyun geçmişi yok',
            style: TextStyle(
              fontSize: 16,
              color: ThemeColors.getEmptyStateText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.getHistoryCardBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: games.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameItem(context, game);
        },
      ),
    );
  }

  Widget _buildGameItem(BuildContext context, GameHistoryItem game) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: game.isWin ? ThemeColors.getSuccessColor(context) : ThemeColors.getErrorColor(context),
        ),
        child: Icon(
          game.isWin ? Icons.check : Icons.close,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        '${game.score} puan',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${_formatGameDate(game.playedAt)} • ${_getGameTypeText(game.gameType)}',
        style: TextStyle(
          color: ThemeColors.getStatsCardText(context),
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: game.isWin ? Colors.green[100] : Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          game.isWin ? 'Kazandın' : 'Kaybettin',
          style: TextStyle(
            color: game.isWin ? Colors.green[800] : Colors.red[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatGameDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  String _getGameTypeText(String gameType) {
    switch (gameType) {
      case 'multiplayer':
        return 'Çok Oyunculu';
      default:
        return 'Tek Oyuncu';
    }
  }
}

// Biyometri ayarları bölümü
class _BiometricSettingsSection extends StatefulWidget {
  const _BiometricSettingsSection();

  @override
  State<_BiometricSettingsSection> createState() => _BiometricSettingsSectionState();
}

class _BiometricSettingsSectionState extends State<_BiometricSettingsSection> {
  bool _isBiometricEnabled = false;
  bool _isLoading = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    try {
      final isEnabled = await BiometricUserService.isUserBiometricEnabled();
      if (mounted) {
        setState(() {
          _isBiometricEnabled = isEnabled;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Biyometri durumu yükleme hatası: $e');
      }
    }
  }

  Future<void> _disableBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BiometricUserService.disableBiometric();
      
      if (success) {
        setState(() {
          _isBiometricEnabled = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biyometrik giriş devre dışı bırakıldı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biyometrik giriş devre dışı bırakılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enableBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Biyometrik kimlik doğrulama iste
      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Biyometrik giriş etkinleştirmek için kimlik doğrulama gerekli',
        useErrorDialogs: true,
      );

      if (authenticated) {
        // Kurulumu kaydet
        final success = await BiometricUserService.saveBiometricSetup();
        
        if (success) {
          if (mounted) {
            setState(() {
              _isBiometricEnabled = true;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biyometrik giriş başarıyla etkinleştirildi'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biyometrik kurulumu kaydetme başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Güvenlik Ayarları',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: ThemeColors.getGreen(context),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biyometrik Giriş',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isBiometricEnabled 
                                  ? 'Biyometrik kimlik doğrulama etkin'
                                  : 'Biyometrik kimlik doğrulama devre dışı',
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColors.getSecondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isBiometricEnabled,
                        onChanged: _isLoading ? null : (value) {
                          if (value) {
                            // Biyometriyi etkinleştir
                            _enableBiometric();
                          } else {
                            // Biyometriyi devre dışı bırak
                            _disableBiometric();
                          }
                        },
                        activeColor: ThemeColors.getGreen(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BiometricSetupStatus(),
                  const SizedBox(height: 16),
                  if (_isBiometricEnabled)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Giriş yaparken biyometrik kimlik doğrulama seçeneği görünecektir.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
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
}

// Registration check screen widget
class _RegistrationCheckScreen extends StatelessWidget {
  const _RegistrationCheckScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Profil kontrol ediliyor...',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Unregistered user screen widget
class _UnregisteredUserScreen extends StatelessWidget {
  const _UnregisteredUserScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(AppLocalizations.profile, style: TextStyle(color: ThemeColors.getAppBarText(context)));
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        iconTheme: IconThemeData(color: ThemeColors.getAppBarIcon(context)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeColors.getCardBackground(context).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 80,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Kayıt Olmanız Gerekiyor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profil sayfasına erişebilmek için önce kayıt olmanız gerekiyor. Kayıt olarak daha fazla özellikten yararlanabilirsiniz.',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.getStatsCardText(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Kayıt Ol'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getPrimaryButtonColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Geri Dön'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}