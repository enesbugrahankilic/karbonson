// lib/pages/multiplayer_lobby_page.dart
// Modern multiplayer lobby page with enhanced UI/UX following design system

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/authentication_state_service.dart';
import '../services/profile_service.dart';
import '../services/leaderboard_category_service.dart';
import '../models/leaderboard_category.dart';
import '../core/navigation/app_router_complete.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../widgets/copy_to_clipboard_widget.dart';
import '../widgets/user_qr_code_widget.dart';
import '../widgets/quiz_layout.dart';
import '../utils/firebase_logger.dart';
import 'duel_page.dart';
import 'spectator_mode_page.dart';

class MultiplayerLobbyPage extends StatefulWidget {
   final String? userNickname;
   final String? preSharedRoomCode;

   const MultiplayerLobbyPage({
     super.key,
     this.userNickname,
     this.preSharedRoomCode,
   });

   @override
   State<MultiplayerLobbyPage> createState() => _MultiplayerLobbyPageState();
}

class _MultiplayerLobbyPageState extends State<MultiplayerLobbyPage>
      with TickerProviderStateMixin {
    final FirestoreService _firestoreService = FirestoreService();
    final AuthenticationStateService _authStateService =
        AuthenticationStateService();
    final ProfileService _profileService = ProfileService();
    final LeaderboardCategoryService _categoryService = LeaderboardCategoryService();

   // Enhanced animation controllers for staggered entrance
   late AnimationController _fadeController;
   late AnimationController _slideController;
   late AnimationController _headerSlideController;
   late List<AnimationController> _cardControllers;

   bool _isCreatingRoom = false;
   bool _isJoiningRoom = false;
   bool _isLoading = true;
   String? _userNickname;
   String? _userAvatarUrl;
   int _totalGames = 0;
   int _duelWins = 0;
   String? _createdRoomCode;

   // Leaderboard data
   List<LeaderboardCategory> _lobbyCategories = [];
   Map<String, List<Map<String, dynamic>>> _lobbyCategoryData = {};
   bool _isLoadingLeaderboard = true;

   @override
   void initState() {
     super.initState();

     // Initialize enhanced animation controllers
     _fadeController = AnimationController(
       duration: const Duration(milliseconds: 800),
       vsync: this,
     );
     _slideController = AnimationController(
       duration: const Duration(milliseconds: 600),
       vsync: this,
     );
     _headerSlideController = AnimationController(
       duration: const Duration(milliseconds: 500),
       vsync: this,
     );

     // Initialize card controllers for staggered animations
     _cardControllers = List.generate(
       4, // Number of main cards/sections
       (index) => AnimationController(
         duration: const Duration(milliseconds: 400),
         vsync: this,
       ),
     );

     // Start main animations
     _fadeController.forward();
     _slideController.forward();
     _headerSlideController.forward();

     // Stagger card animations
     for (int i = 0; i < _cardControllers.length; i++) {
       Future.delayed(Duration(milliseconds: 300 + (i * 150)), () {
         if (mounted) {
           _cardControllers[i].forward();
         }
       });
     }

     _loadUserData();
     _loadLobbyLeaderboard();
     if (widget.preSharedRoomCode != null && widget.preSharedRoomCode!.isNotEmpty) {
       WidgetsBinding.instance.addPostFrameCallback((_) => _joinDuelRoom(widget.preSharedRoomCode!));
     }
   }

   @override
   void dispose() {
     _fadeController.dispose();
     _slideController.dispose();
     _headerSlideController.dispose();
     for (final controller in _cardControllers) {
       controller.dispose();
     }
     super.dispose();
   }

   Future<void> _loadUserData() async {
     try {
       final user = FirebaseAuth.instance.currentUser;
       if (user == null) {
         if (mounted) setState(() {
           _isLoading = false;
           _userNickname = widget.userNickname ?? 'Misafir';
         });
         return;
       }
       final profile = await _profileService.loadServerProfile();
       if (mounted) {
         setState(() {
           _userNickname = profile?.nickname ?? widget.userNickname ?? user.displayName ?? 'Oyuncu';
           _userAvatarUrl = profile?.profilePictureUrl;
           _totalGames = profile?.totalGamesPlayed ?? 0;
           _duelWins = profile?.duelWins ?? 0;
           _isLoading = false;
         });
       }
     } catch (e) {
       if (kDebugMode) debugPrint('Error loading user data: $e');
       if (mounted) setState(() {
         _isLoading = false;
         _userNickname = widget.userNickname ?? 'Oyuncu';
       });
     }
   }

   Future<String> _getPlayerId() async => await _authStateService.getGamePlayerId();
   Future<String> _getPlayerNickname() async => await _authStateService.getGameNickname();

   Future<void> _loadLobbyLeaderboard() async {
     setState(() => _isLoadingLeaderboard = true);

     try {
       // Load lobby categories (limited to 4 for display)
       _lobbyCategories = await _categoryService.getLobbyCategories(limit: 4);

       // Load data for each category in parallel
       final categoryFutures = _lobbyCategories.map((category) async {
         List<Map<String, dynamic>> data;
         switch (category.id) {
           case 'quiz_masters':
             data = await _firestoreService.getQuizMastersLeaderboard(limit: 10);
             break;
           case 'duel_champions':
             data = await _firestoreService.getDuelChampionsLeaderboard(limit: 10);
             break;
           case 'social_butterflies':
             data = await _firestoreService.getSocialButterfliesLeaderboard(limit: 10);
             break;
           case 'streak_kings':
             data = await _firestoreService.getStreakKingsLeaderboard(limit: 10);
             break;
           default:
             data = [];
             break;
         }
         return MapEntry(category.id, _formatLobbyCategoryLeaderboard(data, category.sortField));
       });

       final results = await Future.wait(categoryFutures);
       _lobbyCategoryData = Map.fromEntries(results);

       if (kDebugMode) {
         debugPrint('✅ Lobby leaderboard data loaded: ${_lobbyCategoryData.keys.join(', ')}');
       }
     } catch (e) {
       if (kDebugMode) debugPrint('🚨 Error loading lobby leaderboard: $e');
     } finally {
       if (mounted) setState(() => _isLoadingLeaderboard = false);
     }
   }

   List<Map<String, dynamic>> _formatLobbyCategoryLeaderboard(
     List<Map<String, dynamic>> data,
     String sortField,
   ) {
     final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
     final topThree = data.take(3).toList();

     return topThree.asMap().entries.map((entry) {
       final index = entry.key;
       final user = entry.value;
       final sortValue = user[sortField] as int? ?? 0;

       return {
         'rank': index + 1,
         'userId': user['uid'] ?? '',
         'displayName': user['nickname'] ?? 'Anonim',
         'avatar': user['avatarUrl'] ?? '🎯',
         'score': user['score'] as int? ?? 0,
         'sortValue': sortValue,
         'isCurrentUser': user['uid'] == currentUserUid,
       };
     }).toList();
   }

   Future<void> _createDuelRoom() async {
     setState(() => _isCreatingRoom = true);
     try {
       final playerId = await _getPlayerId();
       final playerNickname = await _getPlayerNickname();

       if (kDebugMode) debugPrint('🎯 [CREATE_ROOM] Starting room creation for $playerNickname ($playerId)');

       final room = await _firestoreService.createDuelRoom(playerId, playerNickname);

       if (room != null && mounted) {
         if (kDebugMode) debugPrint('✅ [CREATE_ROOM] Room created successfully: ${room.id}');

         setState(() {
           _createdRoomCode = room.id;
         });
         FirebaseLogger.logPlayerAction(roomId: room.id, playerId: playerId, nickname: playerNickname, action: 'CREATE_ROOM', success: true);

         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Row(mainAxisSize: MainAxisSize.min, children: [
               Expanded(child: Text('Oda oluşturuldu! Kod: ${room.id}')),
               SizedBox(width: DesignSystem.spacingS),
               CopyToClipboardWidget(
                 textToCopy: room.id,
                 successMessage: 'Oda kodu kopyalandı!',
                 iconColor: Colors.white,
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.white.withValues(alpha: 0.2),
                     borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                   ),
                   child: const Icon(Icons.copy, size: 16, color: Colors.white),
                 ),
               ),
             ]),
             backgroundColor: ThemeColors.getSuccessColor(context),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
           ),
         );
       } else {
         if (kDebugMode) debugPrint('❌ [CREATE_ROOM] Room creation failed - returned null');
         throw Exception('Oda oluşturulamadı');
       }
     } catch (e, stackTrace) {
       if (kDebugMode) {
         debugPrint('🚨 [CREATE_ROOM] Error: $e');
         debugPrint('Stack trace: $stackTrace');
       }

       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Oda oluşturulurken hata: $e'),
             backgroundColor: ThemeColors.getErrorColor(context),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
           ),
         );
       }
     } finally {
       if (mounted) setState(() => _isCreatingRoom = false);
     }
   }

   Future<void> _joinDuelRoom(String roomCode) async {
     if (kDebugMode) debugPrint('🎯 [MULTIPLAYER_LOBBY] Starting room join process for code: $roomCode');
     setState(() => _isJoiningRoom = true);
     try {
       final playerId = await _getPlayerId();
       final playerNickname = await _getPlayerNickname();
       if (kDebugMode) debugPrint('🔄 [MULTIPLAYER_LOBBY] Attempting to join duel room with code: $roomCode');
       final room = await _firestoreService.joinDuelRoomByCode(roomCode, playerId, playerNickname).timeout(
         const Duration(seconds: 10),
         onTimeout: () {
           if (kDebugMode) debugPrint('⏰ [MULTIPLAYER_LOBBY] Timeout');
           throw Exception('Bağlantı zaman aşımına uğradı.');
         },
       );
       if (room != null && mounted) {
         if (kDebugMode) debugPrint('✅ [MULTIPLAYER_LOBBY] Successfully joined duel room: ${room.id}');
         FirebaseLogger.logPlayerAction(roomId: room.id, playerId: playerId, nickname: playerNickname, action: 'JOIN_ROOM', success: true);
         if (widget.preSharedRoomCode != null) Navigator.of(context).pop();
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DuelPage()));
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('Odaya başarıyla katıldınız!'),
             backgroundColor: ThemeColors.getSuccessColor(context),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
           ),
         );
       } else {
         throw Exception('Oda katılımı başarısız oldu.');
       }
     } catch (e) {
       if (kDebugMode) debugPrint('🚨 [MULTIPLAYER_LOBBY] Error: $e');
       String errorMessage = 'Odaya katılırken hata oluştu';
       if (e.toString().contains('not found') || e.toString().contains('null')) errorMessage = 'Oda bulunamadı.';
       else if (e.toString().contains('full')) errorMessage = 'Oda dolu.';
       else if (e.toString().contains('timeout') || e.toString().contains('zaman aşımı')) errorMessage = 'Bağlantı hatası.';
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(errorMessage),
             backgroundColor: ThemeColors.getErrorColor(context),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusM)),
           ),
         );
       }
     } finally {
       if (mounted) setState(() => _isJoiningRoom = false);
     }
   }

   void _showJoinRoomDialog() {
     final roomIdController = TextEditingController();
     showDialog(
       context: context,
       builder: (context) => Dialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
         backgroundColor: ThemeColors.getDialogBackground(context),
         child: Container(
           padding: const EdgeInsets.all(DesignSystem.spacingL),
           constraints: const BoxConstraints(maxWidth: 400),
           child: Column(mainAxisSize: MainAxisSize.min, children: [
             Row(children: [
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingS),
                 decoration: BoxDecoration(
                   color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.login, color: ThemeColors.getPrimaryButtonColor(context), size: 24),
               ),
               SizedBox(width: DesignSystem.spacingM),
               Expanded(
                 child: Text(
                   'Odaya Katıl',
                   style: DesignSystem.getHeadlineSmall(context).copyWith(
                     color: ThemeColors.getText(context),
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
             ]),
             SizedBox(height: DesignSystem.spacingL),
             TextField(
               controller: roomIdController,
               decoration: DesignSystem.getInputDecoration(context, labelText: 'Oda Kodu', hintText: '4 haneli kodu girin').copyWith(
                 prefixIcon: Icon(Icons.key, color: ThemeColors.getSecondaryText(context)),
               ),
               style: TextStyle(color: ThemeColors.getText(context)),
               maxLength: 4,
               keyboardType: TextInputType.number,
             ),
             SizedBox(height: DesignSystem.spacingL),
             Row(
               children: [
                 Expanded(
                   child: TextButton(
                     onPressed: () => Navigator.of(context).pop(),
                     style: TextButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
                     ),
                     child: Text(
                       'İptal',
                       style: DesignSystem.getLabelLarge(context).copyWith(
                         color: ThemeColors.getSecondaryText(context),
                       ),
                     ),
                   ),
                 ),
                 SizedBox(width: DesignSystem.spacingM),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () {
                       final roomCode = roomIdController.text.trim();
                       if (roomCode.isEmpty || roomCode.length != 4 || !RegExp(r'^\d{4}$').hasMatch(roomCode)) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Geçersiz kod formatı.')),
                         );
                         return;
                       }
                       Navigator.of(context).pop();
                       _joinDuelRoom(roomCode);
                     },
                     style: DesignSystem.getPrimaryButtonStyle(context),
                     child: const Text('Katıl'),
                   ),
                 ),
               ],
             ),
           ]),
         ),
       ),
     );
   }

   void _showHowToPlayDialog() {
     showDialog(
       context: context,
       builder: (context) => Dialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
         backgroundColor: ThemeColors.getDialogBackground(context),
         child: Container(
           padding: const EdgeInsets.all(DesignSystem.spacingL),
           constraints: const BoxConstraints(maxWidth: 400),
           child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
             Row(children: [
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingS),
                 decoration: BoxDecoration(
                   color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.help_outline, color: ThemeColors.getSuccessColor(context), size: 24),
               ),
               SizedBox(width: DesignSystem.spacingM),
               Expanded(
                 child: Text(
                   'Nasıl Oynanır?',
                   style: DesignSystem.getHeadlineSmall(context).copyWith(
                     color: ThemeColors.getText(context),
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
             ]),
             SizedBox(height: DesignSystem.spacingL),
             _buildRuleItem(Icons.people, '2 oyuncu gereklidir'),
             _buildRuleItem(Icons.quiz, '5 soru sorulacak'),
             _buildRuleItem(Icons.emoji_events, 'En çok doğru cevap kazanır'),
             _buildRuleItem(Icons.speed, 'Hız bonusu ile puan kazanın'),
             _buildRuleItem(Icons.timer, '15 saniye süre sınırı'),
             SizedBox(height: DesignSystem.spacingL),
             Align(
               alignment: Alignment.centerRight,
               child: ElevatedButton(
                 onPressed: () => Navigator.pop(context),
                 style: DesignSystem.getPrimaryButtonStyle(context),
                 child: const Text('Anladım'),
               ),
             ),
           ]),
         ),
       ),
     );
   }

   Widget _buildRuleItem(IconData icon, String text) {
     return Padding(
       padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
       child: Row(children: [
         Container(
           padding: const EdgeInsets.all(DesignSystem.spacingS),
           decoration: BoxDecoration(
             color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
             shape: BoxShape.circle,
           ),
           child: Icon(icon, color: ThemeColors.getSuccessColor(context), size: 20),
         ),
         SizedBox(width: DesignSystem.spacingM),
         Expanded(
           child: Text(
             text,
             style: DesignSystem.getBodyMedium(context).copyWith(
               color: ThemeColors.getText(context),
             ),
           ),
         ),
       ]),
     );
   }

   @override
   Widget build(BuildContext context) {
     // Show loading indicator while fetching user data
     if (_isLoading) {
       return QuizLayout(
         title: 'Çok Oyunculu Lobi',
         subtitle: 'Oyuncu verisi yükleniyor',
         showBackButton: true,
         onBackPressed: () => Navigator.pop(context),
         scrollable: true,
         child: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               DesignSystem.modernProgressIndicator(context),
               const SizedBox(height: 16),
               Text(
                 'Yükleniyor...',
                 style: DesignSystem.getBodyLarge(context).copyWith(
                   color: ThemeColors.getSecondaryText(context),
                 ),
               ),
             ],
           ),
         ),
       );
     }

     return QuizLayout(
       title: 'Çok Oyunculu Lobi',
       subtitle: 'Arkadaşlarıyla düello yap veya odalar oluştur',
       showBackButton: true,
       onBackPressed: () => Navigator.pop(context),
       actions: [
         IconButton(
           onPressed: _showHowToPlayDialog,
           icon: const Icon(Icons.help_outline),
           tooltip: 'Nasıl Oynanır?',
         ),
       ],
       scrollable: true,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
             // User Profile Section
             SlideTransition(
               position: Tween<Offset>(
                 begin: const Offset(0, 0.2),
                 end: Offset.zero,
               ).animate(CurvedAnimation(
                 parent: _slideController,
                 curve: Curves.easeOut,
               )),
               child: _buildUserProfileSection(context, false),
             ),

             const SizedBox(height: 24),

             // Room Created Card (if applicable)
             if (_createdRoomCode != null)
               FadeTransition(
                 opacity: _cardControllers.isNotEmpty ? _cardControllers[0] : _fadeController,
                 child: _buildRoomCreatedCard(context, false),
               ),

             if (_createdRoomCode != null) const SizedBox(height: 24),

             // Main Actions Section
             FadeTransition(
               opacity: _cardControllers.length > 1 ? _cardControllers[1] : _fadeController,
               child: _buildMainActionsSection(context, false),
             ),

             const SizedBox(height: 24),

             // Quick Access Section
             FadeTransition(
               opacity: _cardControllers.length > 2 ? _cardControllers[2] : _fadeController,
               child: _buildQuickAccessSection(context, false),
             ),

             const SizedBox(height: 24),

             // How to Play Section
             FadeTransition(
               opacity: _cardControllers.length > 3 ? _cardControllers[3] : _fadeController,
               child: _buildHowToPlaySection(context, false),
             ),

             const SizedBox(height: 24),

             // Leaderboard Section
             FadeTransition(
               opacity: _cardControllers.length > 3 ? _cardControllers[3] : _fadeController,
               child: _buildLeaderboardSection(context, false),
             ),

             const SizedBox(height: 20),
           ],
         ),
     );
   }

  Widget _buildUserProfileSection(BuildContext context, bool isSmallScreen) {
    // Determine text colors based on theme
    final brightness = Theme.of(context).brightness;
    final isDarkTheme = brightness == Brightness.dark;
    final primaryTextColor = isDarkTheme ? Colors.white : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDarkTheme ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF4A4A4A);
    final shadowColor = Colors.black.withValues(alpha: 0.3);
    
    return DesignSystem.glassCard(
      context,
      padding: EdgeInsets.all(isSmallScreen ? DesignSystem.spacingL : DesignSystem.spacingXl),
      child: Row(
        children: [
          // Avatar with enhanced styling
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.3),
                  ThemeColors.getAccentButtonColor(context).withValues(alpha: 0.3),
                ],
              ),
              boxShadow: ThemeColors.getModernShadow(context, elevation: 0.5),
            ),
            child: CircleAvatar(
              radius: isSmallScreen ? 32.0 : 36.0,
              backgroundColor: Colors.transparent,
              backgroundImage: _userAvatarUrl != null ? NetworkImage(_userAvatarUrl!) : null,
              child: _userAvatarUrl == null
                  ? Text(
                      _userNickname?.isNotEmpty == true ? _userNickname![0].toUpperCase() : 'O',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: isSmallScreen ? 24.0 : 28.0,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: shadowColor,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: DesignSystem.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userNickname ?? 'Oyuncu',
                  style: DesignSystem.getTitleLarge(context).copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: shadowColor,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: DesignSystem.spacingS),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: DesignSystem.spacingXs),
                    Text(
                      '$_duelWins galibiyet',
                      style: DesignSystem.getBodySmall(context).copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(width: DesignSystem.spacingM),
                    Icon(
                      Icons.gamepad,
                      color: isDarkTheme ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF6A6A6A),
                      size: 16,
                    ),
                    SizedBox(width: DesignSystem.spacingXs),
                    Text(
                      '$_totalGames oyun',
                      style: DesignSystem.getBodySmall(context).copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Time display with modern styling
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingM,
              vertical: DesignSystem.spacingS,
            ),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: DesignSystem.getLabelLarge(context).copyWith(
                color: ThemeColors.getSuccessColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildRoomCreatedCard(BuildContext context, bool isSmallScreen) {
     return DesignSystem.card(
       context,
       backgroundColor: ThemeColors.getSuccessColor(context),
       child: Column(
         children: [
           Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingM),
                 decoration: BoxDecoration(
                   color: ThemeColors.getTextOnColoredBackground(context).withValues(alpha: 0.2),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   Icons.check_circle,
                   color: Colors.white,
                   size: 32,
                 ),
               ),
               SizedBox(width: DesignSystem.spacingM),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Oda Oluşturuldu!',
                       style: DesignSystem.getTitleLarge(context).copyWith(
                         color: Colors.white,
                         fontWeight: FontWeight.w700,
                       ),
                     ),
                     SizedBox(height: DesignSystem.spacingXs),
                     Text(
                       'Arkadaşlarınızla paylaşın',
                       style: DesignSystem.getBodyMedium(context).copyWith(
                         color: Colors.white.withValues(alpha: 0.9),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
           SizedBox(height: DesignSystem.spacingL),
           Container(
             padding: const EdgeInsets.all(DesignSystem.spacingL),
             decoration: BoxDecoration(
               color: Colors.white.withValues(alpha: 0.15),
               borderRadius: BorderRadius.circular(DesignSystem.radiusM),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   'Oda Kodu: ',
                   style: DesignSystem.getBodyLarge(context).copyWith(
                     color: Colors.white,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
                 Text(
                   _createdRoomCode!,
                   style: DesignSystem.getHeadlineSmall(context).copyWith(
                     color: Colors.white,
                     fontWeight: FontWeight.w800,
                     letterSpacing: 4,
                   ),
                 ),
                 SizedBox(width: DesignSystem.spacingM),
                 CopyToClipboardWidget(
                   textToCopy: _createdRoomCode!,
                   successMessage: 'Kod kopyalandı!',
                   iconColor: Colors.white,
                   child: Container(
                     padding: const EdgeInsets.all(DesignSystem.spacingS),
                     decoration: BoxDecoration(
                       color: Colors.white.withValues(alpha: 0.2),
                       borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                     ),
                     child: Icon(
                       Icons.copy,
                       color: Colors.white,
                       size: 20,
                     ),
                   ),
                 ),
               ],
             ),
           ),
           SizedBox(height: DesignSystem.spacingL),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () => Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(builder: (context) => const DuelPage()),
               ),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.white,
                 foregroundColor: ThemeColors.getSuccessColor(context),
                 padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacingM),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                 ),
                 elevation: 2,
               ),
               child: Text(
                 'Odadan Başlat',
                 style: DesignSystem.getLabelLarge(context).copyWith(
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
           ),
         ],
       ),
     );
   }

   Widget _buildMainActionsSection(BuildContext context, bool isSmallScreen) {
     // Determine text colors based on theme
     final brightness = Theme.of(context).brightness;
     final isDarkTheme = brightness == Brightness.dark;
     final textColor = isDarkTheme ? Colors.white : const Color(0xFF1A1A1A);
     final shadowColor = Colors.black.withValues(alpha: 0.3);
     
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Padding(
           padding: EdgeInsets.only(
             left: DesignSystem.spacingS,
             bottom: DesignSystem.spacingM,
           ),
           child: Text(
             'Oyun Seçenekleri',
             style: DesignSystem.getTitleLarge(context).copyWith(
               color: textColor,
               fontSize: isSmallScreen ? 20.0 : 24.0,
               fontWeight: FontWeight.w800,
               shadows: [
                 Shadow(
                   color: shadowColor,
                   offset: const Offset(0, 2),
                   blurRadius: 4,
                 ),
               ],
             ),
           ),
         ),
         Row(
           children: [
             Expanded(child: _buildCreateRoomCard(context, isSmallScreen)),
             SizedBox(width: DesignSystem.spacingM),
             Expanded(child: _buildJoinRoomCard(context, isSmallScreen)),
           ],
         ),
       ],
     );
   }

   Widget _buildCreateRoomCard(BuildContext context, bool isSmallScreen) {
     return DesignSystem.card(
       context,
       child: InkWell(
         onTap: _isCreatingRoom ? null : _createDuelRoom,
         borderRadius: BorderRadius.circular(DesignSystem.radiusL),
         child: Container(
           padding: EdgeInsets.all(isSmallScreen ? DesignSystem.spacingL : DesignSystem.spacingXl),
           decoration: BoxDecoration(
             gradient: LinearGradient(
               colors: [
                 ThemeColors.getSuccessColor(context),
                 ThemeColors.getSuccessColor(context).withValues(alpha: 0.8),
               ],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ),
             borderRadius: BorderRadius.circular(DesignSystem.radiusL),
             boxShadow: ThemeColors.getModernShadow(context, elevation: 1.0),
           ),
           child: Column(
             children: [
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingL),
                 decoration: BoxDecoration(
                   color: ThemeColors.getTextOnColoredBackground(context).withValues(alpha: 0.2),
                   shape: BoxShape.circle,
                 ),
                 child: _isCreatingRoom
                     ? DesignSystem.modernProgressIndicator(context)
                     : Icon(
                         Icons.add_circle,
                         color: Colors.white,
                         size: isSmallScreen ? 32.0 : 40.0,
                       ),
               ),
               SizedBox(height: DesignSystem.spacingM),
               Text(
                 'Oda Oluştur',
                 style: DesignSystem.getTitleMedium(context).copyWith(
                   color: Colors.white,
                   fontWeight: FontWeight.w700,
                 ),
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: DesignSystem.spacingS),
               Text(
                 'Arkadaşlarını davet et',
                 style: DesignSystem.getBodySmall(context).copyWith(
                   color: Colors.white.withValues(alpha: 0.9),
                 ),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         ),
       ),
     );
   }

   Widget _buildJoinRoomCard(BuildContext context, bool isSmallScreen) {
     return DesignSystem.card(
       context,
       child: InkWell(
         onTap: _isJoiningRoom ? null : _showJoinRoomDialog,
         borderRadius: BorderRadius.circular(DesignSystem.radiusL),
         child: Container(
           padding: EdgeInsets.all(isSmallScreen ? DesignSystem.spacingL : DesignSystem.spacingXl),
           decoration: BoxDecoration(
             gradient: LinearGradient(
               colors: [
                 ThemeColors.getInfoColor(context),
                 ThemeColors.getInfoColor(context).withValues(alpha: 0.8),
               ],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ),
             borderRadius: BorderRadius.circular(DesignSystem.radiusL),
             boxShadow: ThemeColors.getModernShadow(context, elevation: 1.0),
           ),
           child: Column(
             children: [
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingL),
                 decoration: BoxDecoration(
                   color: ThemeColors.getTextOnColoredBackground(context).withValues(alpha: 0.2),
                   shape: BoxShape.circle,
                 ),
                 child: _isJoiningRoom
                     ? DesignSystem.modernProgressIndicator(context)
                     : Icon(
                         Icons.login,
                         color: Colors.white,
                         size: isSmallScreen ? 32.0 : 40.0,
                       ),
               ),
               SizedBox(height: DesignSystem.spacingM),
               Text(
                 'Odaya Katıl',
                 style: DesignSystem.getTitleMedium(context).copyWith(
                   color: Colors.white,
                   fontWeight: FontWeight.w700,
                 ),
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: DesignSystem.spacingS),
               Text(
                 'Kod ile katıl',
                 style: DesignSystem.getBodySmall(context).copyWith(
                   color: Colors.white.withValues(alpha: 0.9),
                 ),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         ),
       ),
     );
   }

   Widget _buildQuickAccessSection(BuildContext context, bool isSmallScreen) {
     return DesignSystem.card(
       context,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Padding(
             padding: EdgeInsets.all(DesignSystem.spacingM),
             child: Text(
               'Hızlı Erişim',
               style: DesignSystem.getTitleMedium(context).copyWith(
                 color: ThemeColors.getText(context),
                 fontWeight: FontWeight.w700,
               ),
             ),
           ),
           Padding(
             padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
             child: Row(
               children: [
                 Expanded(
                   child: _buildQuickAccessButton(
                     context,
                     isSmallScreen,
                     Icons.visibility,
                     'İzleyici Modu',
                     ThemeColors.getAccentButtonColor(context),
                     () => Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => SpectatorModePage()),
                     ),
                   ),
                 ),
                 SizedBox(width: DesignSystem.spacingM),
                 Expanded(
                   child: _buildQuickAccessButton(
                     context,
                     isSmallScreen,
                     Icons.qr_code,
                     'QR Paylaş',
                     ThemeColors.getSecondaryButtonColor(context),
                     () => _showQRShareDialog(context),
                   ),
                 ),
               ],
             ),
           ),
           SizedBox(height: DesignSystem.spacingM),
         ],
       ),
     );
   }

   Widget _buildQuickAccessButton(
     BuildContext context,
     bool isSmallScreen,
     IconData icon,
     String label,
     Color color,
     VoidCallback onTap,
   ) {
     return InkWell(
       onTap: onTap,
       borderRadius: BorderRadius.circular(DesignSystem.radiusM),
       child: Container(
         padding: EdgeInsets.all(isSmallScreen ? DesignSystem.spacingM : DesignSystem.spacingL),
         decoration: BoxDecoration(
           color: color.withValues(alpha: 0.1),
           borderRadius: BorderRadius.circular(DesignSystem.radiusM),
           border: Border.all(
             color: color.withValues(alpha: 0.3),
             width: 1,
           ),
         ),
         child: Column(
           children: [
             Icon(
               icon,
               color: color,
               size: isSmallScreen ? 28.0 : 32.0,
             ),
             SizedBox(height: DesignSystem.spacingS),
             Text(
               label,
               style: DesignSystem.getBodySmall(context).copyWith(
                 color: color,
                 fontWeight: FontWeight.w600,
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

   Widget _buildHowToPlaySection(BuildContext context, bool isSmallScreen) {
     return DesignSystem.glassCard(
       context,
       child: InkWell(
         onTap: _showHowToPlayDialog,
         borderRadius: BorderRadius.circular(DesignSystem.radiusL),
         child: Padding(
           padding: const EdgeInsets.all(DesignSystem.spacingL),
           child: Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingM),
                 decoration: BoxDecoration(
                   color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   Icons.lightbulb_outline,
                   color: ThemeColors.getSuccessColor(context),
                   size: 28,
                 ),
               ),
               SizedBox(width: DesignSystem.spacingM),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Nasıl Oynanır?',
                       style: DesignSystem.getTitleMedium(context).copyWith(
                         color: ThemeColors.getText(context),
                         fontWeight: FontWeight.w700,
                       ),
                     ),
                     SizedBox(height: DesignSystem.spacingXs),
                     Text(
                       'Oyun kuralları hakkında bilgi alın',
                       style: DesignSystem.getBodySmall(context).copyWith(
                         color: ThemeColors.getSecondaryText(context),
                       ),
                     ),
                   ],
                 ),
               ),
               Container(
                 padding: const EdgeInsets.all(DesignSystem.spacingS),
                 decoration: BoxDecoration(
                   color: ThemeColors.getPrimaryButtonColor(context),
                   borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                 ),
                 child: Icon(
                   Icons.arrow_forward,
                   color: Colors.white,
                   size: 18,
                 ),
               ),
             ],
           ),
         ),
       ),
     );
   }

   Widget _buildLeaderboardSection(BuildContext context, bool isSmallScreen) {
     return DesignSystem.card(
       context,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Padding(
             padding: EdgeInsets.all(DesignSystem.spacingM),
             child: Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(DesignSystem.spacingS),
                   decoration: BoxDecoration(
                     color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
                     shape: BoxShape.circle,
                   ),
                   child: Icon(
                     Icons.leaderboard,
                     color: ThemeColors.getPrimaryButtonColor(context),
                     size: 20,
                   ),
                 ),
                 SizedBox(width: DesignSystem.spacingM),
                 Expanded(
                   child: Text(
                     'Lider Tablosu',
                     style: DesignSystem.getTitleMedium(context).copyWith(
                       color: ThemeColors.getText(context),
                       fontWeight: FontWeight.w700,
                     ),
                   ),
                 ),
                 TextButton(
                   onPressed: () => Navigator.of(context).pushNamed(AppRoutes.leaderboard),
                   child: Text(
                     'Tümü',
                     style: DesignSystem.getLabelLarge(context).copyWith(
                       color: ThemeColors.getPrimaryButtonColor(context),
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ],
             ),
           ),
           if (_isLoadingLeaderboard)
             Padding(
               padding: const EdgeInsets.all(DesignSystem.spacingL),
               child: Center(child: DesignSystem.modernProgressIndicator(context)),
             )
           else if (_lobbyCategories.isEmpty)
             Padding(
               padding: const EdgeInsets.all(DesignSystem.spacingL),
               child: Center(
                 child: Text(
                   'Lider tablosu verisi yükleniyor...',
                   style: DesignSystem.getBodyMedium(context).copyWith(
                     color: ThemeColors.getSecondaryText(context),
                   ),
                 ),
               ),
             )
           else
             Padding(
               padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacingM),
               child: Column(
                 children: _lobbyCategories.map((category) {
                   final data = _lobbyCategoryData[category.id] ?? [];
                   return Padding(
                     padding: const EdgeInsets.only(bottom: DesignSystem.spacingM),
                     child: _buildLobbyCategoryCard(context, category, data, isSmallScreen),
                   );
                 }).toList(),
               ),
             ),
           SizedBox(height: DesignSystem.spacingM),
         ],
       ),
     );
   }

   Widget _buildLobbyCategoryCard(
     BuildContext context,
     LeaderboardCategory category,
     List<Map<String, dynamic>> data,
     bool isSmallScreen,
   ) {
     return InkWell(
       onTap: () => Navigator.of(context).pushNamed(AppRoutes.leaderboard),
       borderRadius: BorderRadius.circular(DesignSystem.radiusM),
       child: Container(
         padding: EdgeInsets.all(DesignSystem.spacingM),
         decoration: BoxDecoration(
           color: category.color.withValues(alpha: 0.05),
           borderRadius: BorderRadius.circular(DesignSystem.radiusM),
           border: Border.all(
             color: category.color.withValues(alpha: 0.2),
             width: 1,
           ),
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               children: [
                 Icon(category.icon, color: category.color, size: 20),
                 SizedBox(width: DesignSystem.spacingS),
                 Expanded(
                   child: Text(
                     category.name,
                     style: DesignSystem.getBodyLarge(context).copyWith(
                       color: category.color,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
                 if (data.isNotEmpty)
                   Text(
                     '${data[0]['sortValue'] ?? 0}',
                     style: DesignSystem.getTitleMedium(context).copyWith(
                       color: category.color,
                       fontWeight: FontWeight.w700,
                     ),
                   ),
               ],
             ),
             SizedBox(height: DesignSystem.spacingS),
             if (data.isNotEmpty)
               Row(
                 children: data.map((player) {
                   final rank = player['rank'] as int;
                   return Expanded(
                     child: Container(
                       margin: const EdgeInsets.only(right: 4),
                       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                       decoration: BoxDecoration(
                         color: rank == 1
                             ? Colors.amber.withValues(alpha: 0.2)
                             : ThemeColors.getCardBackground(context),
                         borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                       ),
                       child: Column(
                         children: [
                           Text(
                             '#$rank',
                             style: DesignSystem.getBodySmall(context).copyWith(
                               color: rank == 1 ? Colors.amber : ThemeColors.getSecondaryText(context),
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                           SizedBox(height: 2),
                           Text(
                             player['displayName']?.substring(0, 3) ?? '???',
                             style: DesignSystem.getBodySmall(context).copyWith(
                               color: ThemeColors.getText(context),
                               fontWeight: FontWeight.w500,
                             ),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ],
                       ),
                     ),
                   );
                 }).toList(),
               )
             else
               Text(
                 'Henüz veri yok',
                 style: DesignSystem.getBodySmall(context).copyWith(
                   color: ThemeColors.getSecondaryText(context),
                 ),
               ),
           ],
         ),
       ),
     );
   }

   void _showQRShareDialog(BuildContext context) {
     final user = FirebaseAuth.instance.currentUser;
     if (user == null) return;

     showDialog(
       context: context,
       builder: (context) => Dialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSystem.radiusL)),
         backgroundColor: ThemeColors.getDialogBackground(context),
         child: Container(
           constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
           child: UserQRCodeWidget(
             userId: user.uid,
             nickname: _userNickname ?? 'Oyuncu',
           ),
         ),
       ),
     );
   }
}
