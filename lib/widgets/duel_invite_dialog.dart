// lib/widgets/duel_invite_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/friendship_service.dart';
import '../services/notification_service.dart';
import '../models/game_board.dart' as board;
import '../theme/theme_colors.dart';

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

class _DuelInviteDialogState extends State<DuelInviteDialog> {
  final FriendshipService _friendshipService = FriendshipService();
  final NotificationService _notificationService = NotificationService();
  
  List<board.Friend> _friends = [];
  List<String> _selectedFriendIds = [];
  bool _isLoading = true;
  bool _isInviting = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _friendshipService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arkadaşlar yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendInvitations() async {
    if (_selectedFriendIds.isEmpty) return;

    setState(() => _isInviting = true);

    try {
      final invitations = <Future>[];
      
      for (final friendId in _selectedFriendIds) {
        final friend = _friends.firstWhere((f) => f.id == friendId);
        
        // Save invitation to Firestore
        await FirebaseFirestore.instance
            .collection('duel_invitations')
            .doc(DateTime.now().millisecondsSinceEpoch.toString())
            .set({
          'inviterId': widget.hostId,
          'inviterNickname': widget.hostNickname,
          'inviteeId': friendId,
          'inviteeNickname': friend.nickname,
          'roomId': widget.roomId,
          'message': '${widget.hostNickname} sizi düello davet ediyor!',
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });

        // Send notification
        await NotificationService.showDuelInvitationNotification(
          fromNickname: widget.hostNickname,
          roomCode: widget.roomId,
        );

        invitations.add(Future.value(null));
      }

      await Future.wait(invitations);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedFriendIds.length} arkadaşınıza davet gönderildi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Davet gönderilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isInviting = false);
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: ThemeColors.getDialogBackground(context),
      title: Row(
        children: [
          Icon(
            Icons.person_add,
            color: ThemeColors.getGreen(context),
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Arkadaşlarını Davet Et',
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.getDialogContentBackground(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ThemeColors.getBorder(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: ThemeColors.getGreen(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oda Kodu: ${widget.roomId}',
                          style: TextStyle(
                            color: ThemeColors.getText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Düello Daveti',
                          style: TextStyle(
                            color: ThemeColors.getSecondaryText(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Friends List
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_friends.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: ThemeColors.getSecondaryText(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz arkadaşınız yok',
                      style: TextStyle(
                        color: ThemeColors.getSecondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arkadaş eklemek için arkadaşlar sayfasını ziyaret edin',
                      style: TextStyle(
                        color: ThemeColors.getSecondaryText(context),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _friends.length,
                  itemBuilder: (context, index) {
                    final friend = _friends[index];
                    final isSelected = _selectedFriendIds.contains(friend.id);
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          _toggleFriendSelection(friend.id);
                        },
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                friend.nickname,
                                style: TextStyle(
                                  color: ThemeColors.getText(context),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            // Status indicator
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ThemeColors.getGreen(context),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Arkadaş',
                          style: TextStyle(
                            color: ThemeColors.getSecondaryText(context),
                            fontSize: 12,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: ThemeColors.getGreen(context),
                        checkColor: Colors.white,
                        secondary: CircleAvatar(
                          radius: 16,
                          backgroundColor: ThemeColors.getCardBackgroundLight(context),
                          child: Text(
                            friend.nickname.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: ThemeColors.getText(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isInviting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'İptal',
            style: TextStyle(
              color: ThemeColors.getSecondaryText(context),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isInviting || _selectedFriendIds.isEmpty ? null : _sendInvitations,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.getGreen(context),
            foregroundColor: Colors.white,
          ),
          child: _isInviting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(_selectedFriendIds.isEmpty 
                  ? 'Davet Et' 
                  : 'Seçilenleri Davet Et (${_selectedFriendIds.length})'),
        ),
      ],
    );
  }
}