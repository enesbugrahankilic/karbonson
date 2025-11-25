// lib/pages/profile_page.dart
// Enhanced with UID Centrality, Presence System, and Offline-First Strategy (III.1-III.4)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provides/profile_bloc.dart';
import '../services/profile_service.dart';
import '../services/presence_service.dart';
import '../services/friendship_service.dart';
import '../models/profile_data.dart';
import '../models/user_data.dart';

class ProfilePage extends StatefulWidget {
  final String userNickname;

  const ProfilePage({super.key, required this.userNickname});

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
  
  // Stream for real-time presence updates
  StreamSubscription? _presenceSubscription;
  Map<String, PresenceStatus> _friendPresence = {};

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

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Initialize presence service
    _initializePresenceService();
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
    return Scaffold(
      body: BlocProvider(
        create: (context) => ProfileBloc(
          profileService: ProfileService(),
        )..add(LoadProfile(widget.userNickname)),
        child: const ProfileContent(),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

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

  Future<void> _copyUID(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await Clipboard.setData(ClipboardData(text: uid));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UID panoya kopyalandı'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.95),
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
          Stack(
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
                  backgroundImage: profileData.serverData?.profilePictureUrl != null
                      ? NetworkImage(profileData.serverData!.profilePictureUrl!)
                      : null,
                  child: profileData.serverData?.profilePictureUrl == null
                      ? const Icon(Icons.person, size: 56, color: Colors.grey)
                      : null,
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
          const SizedBox(height: 20),
          
          // Nickname
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              profileData.serverData?.nickname ?? 'Yükleniyor...',
              key: ValueKey(profileData.serverData?.nickname),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // UID with copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'UID: ${profileData.serverData?.uid ?? "Yükleniyor..."}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _copyUID(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Last Login
          if (profileData.serverData?.lastLogin != null)
            Text(
              'Son giriş: ${_formatDate(profileData.serverData!.lastLogin!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
                icon: Icons.trending_up,
                title: 'Kazanma Oranı',
                value: '${(localData.winRate * 100).toInt()}%',
                color: const Color(0xFF4CAF50),
              ),
              _buildStatCard(
                icon: Icons.gamepad,
                title: 'Toplam Oyun',
                value: localData.totalGamesPlayed.toString(),
                color: const Color(0xFF2196F3),
              ),
              _buildStatCard(
                icon: Icons.star,
                title: 'En Yüksek Skor',
                value: localData.highestScore.toString(),
                color: const Color(0xFFFF9800),
              ),
              _buildStatCard(
                icon: Icons.analytics,
                title: 'Ortalama Puan',
                value: localData.averageScore.toString(),
                color: const Color(0xFF9C27B0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: Colors.grey[600],
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
            _buildEmptyState()
          else
            _buildGameList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.9),
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
          const Text(
            'Henüz oyun geçmişi yok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: games.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameItem(game);
        },
      ),
    );
  }

  Widget _buildGameItem(GameHistoryItem game) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: game.isWin ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
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
          color: Colors.grey[600],
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