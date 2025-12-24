// lib/widgets/duel_invite_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/friendship_service.dart';
import '../services/notification_service.dart';
import '../models/game_board.dart' as board;
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/modern_ui_components.dart';

class DuelInviteDialog extends StatefulWidget {
  final String roomId;
  final String hostId;
  final String hostNickname;

  const DuelInviteDialog({
    super.key,
    required this.roomId,
    required this.hostId,
    required this.hostNickname,
  });

  @override
  State<DuelInviteDialog> createState() => _DuelInviteDialogState();
}

class _DuelInviteDialogState extends State<DuelInviteDialog>
    with TickerProviderStateMixin {
  final FriendshipService _friendshipService = FriendshipService();
  final NotificationService _notificationService = NotificationService();

  List<board.Friend> _friends = [];
  List<String> _selectedFriendIds = [];
  bool _isLoading = true;
  bool _isInviting = false;

  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dialogController,
      curve: Curves.easeInOut,
    ));

    _dialogController.forward();
    _loadFriends();
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _friendshipService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });

      // Animate friends list appearance
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _dialogController.forward();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ModernUI.showModernToast(
          context,
          message: 'Arkadaşlar yüklenirken hata: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _toggleFriendSelection(String friendId) {
    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        _selectedFriendIds.add(friendId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXl),
          ),
          backgroundColor: ThemeColors.getDialogBackground(context),
          elevation: 8,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced header with modern styling
                _buildHeader(),
                const SizedBox(height: DesignSystem.spacingL),

                // Room info card with gradient
                _buildRoomInfoCard(),
                const SizedBox(height: DesignSystem.spacingL),

                // Friends list with animations
                _buildFriendsList(),
              ],
            ),
          ),
          actions: [
            // Modern action buttons
            _buildCancelButton(),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.1),
            ThemeColors.getAccentButtonColor(context).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color:
              ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingS),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryButtonColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              Icons.person_add,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arkadaşlarını Davet Et',
                  style: DesignSystem.getTitleLarge(context).copyWith(
                    color: ThemeColors.getPrimaryButtonColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Düello oyunu için arkadaşlarını seç',
                  style: DesignSystem.getBodyMedium(context).copyWith(
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

  Widget _buildRoomInfoCard() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
            ThemeColors.getSuccessColor(context).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.getSuccessColor(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
            ),
            child: Icon(
              Icons.security,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oda Kodu: ${widget.roomId}',
                  style: DesignSystem.getTitleMedium(context).copyWith(
                    color: ThemeColors.getSuccessColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Düello Daveti',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeColors.getSecondaryText(context),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          ModernUI.statusIndicator(context, status: StatusType.online),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_friends.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFriendsListContent();
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ModernUI.shimmerCard(context),
        const SizedBox(height: DesignSystem.spacingM),
        ModernUI.shimmerCard(context),
        const SizedBox(height: DesignSystem.spacingM),
        ModernUI.shimmerCard(context),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingXl),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: ThemeColors.getSecondaryText(context),
          ),
          const SizedBox(height: DesignSystem.spacingL),
          Text(
            'Henüz arkadaşınız yok',
            style: DesignSystem.getTitleMedium(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingS),
          Text(
            'Arkadaş eklemek için arkadaşlar sayfasını ziyaret edin',
            style: DesignSystem.getBodyMedium(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsListContent() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          final isSelected = _selectedFriendIds.contains(friend.id);

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildFriendTile(friend, isSelected),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFriendTile(board.Friend friend, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleFriendSelection(friend.id),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        ThemeColors.getPrimaryButtonColor(context)
                            .withValues(alpha: 0.1),
                        ThemeColors.getPrimaryButtonColor(context)
                            .withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              color: isSelected ? null : ThemeColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: isSelected
                    ? ThemeColors.getPrimaryButtonColor(context)
                    : ThemeColors.getBorder(context),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ThemeColors.getPrimaryButtonColor(context)
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Friend avatar with status indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          ThemeColors.getCardBackgroundLight(context),
                      child: Text(
                        friend.nickname.substring(0, 1).toUpperCase(),
                        style: DesignSystem.getTitleMedium(context).copyWith(
                          color: ThemeColors.getText(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: ModernUI.statusIndicator(
                        context,
                        status: StatusType.online,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: DesignSystem.spacingM),

                // Friend info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.nickname,
                        style: DesignSystem.getTitleMedium(context).copyWith(
                          color: ThemeColors.getText(context),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Arkadaş',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ThemeColors.getSecondaryText(context),
                            ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? ThemeColors.getPrimaryButtonColor(context)
                        : ThemeColors.getSecondaryText(context),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendInvitations() async {
    if (_selectedFriendIds.isEmpty) return;

    setState(() => _isInviting = true);

    // Handle async operation
    await _performSendInvitations();
  }

  Future<void> _performSendInvitations() async {
    try {
      // Send duel invitations to selected friends
      for (final friendId in _selectedFriendIds) {
        final friend = _friends.firstWhere((f) => f.id == friendId);

        // Send duel invitation notification
        await NotificationService.showDuelInvitationNotificationStatic(
          widget.hostNickname,
          widget.roomId,
        );

        if (kDebugMode) {
          debugPrint(
              'Duel invitation sent to ${friend.nickname} for room ${widget.roomId}');
        }
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ModernUI.showModernToast(
          context,
          message:
              '${_selectedFriendIds.length} arkadaşınıza düello daveti gönderildi!',
          type: ToastType.success,
        );
        Navigator.of(context).pop(_selectedFriendIds);
      }
    } catch (e) {
      if (mounted) {
        ModernUI.showModernToast(
          context,
          message: 'Davet gönderilirken hata: $e',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInviting = false);
      }
    }
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: _isInviting ? null : () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingL,
          vertical: DesignSystem.spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
      ),
      child: Text(
        'İptal',
        style: DesignSystem.getLabelLarge(context).copyWith(
          color: ThemeColors.getSecondaryText(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _dialogController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isInviting ? 0.95 : 1.0,
          child: ModernUI.animatedButton(
            context,
            text: _selectedFriendIds.isEmpty
                ? 'Davet Et'
                : 'Seçilenleri Davet Et (${_selectedFriendIds.length})',
            onPressed: (_isInviting || _selectedFriendIds.isEmpty)
                ? null
                : _sendInvitations,
            isLoading: _isInviting,
            backgroundColor: ThemeColors.getPrimaryButtonColor(context),
            width: 160,
          ),
        );
      },
    );
  }
}
