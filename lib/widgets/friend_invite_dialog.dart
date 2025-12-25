// lib/widgets/friend_invite_dialog.dart
// Friend invitation dialog for inviting users by User ID to game rooms

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../services/game_invitation_service.dart';
import 'copy_to_clipboard_widget.dart';

class FriendInviteDialog extends StatefulWidget {
  final String roomId;
  final String roomHostNickname;
  final String inviterNickname;

  const FriendInviteDialog({
    super.key,
    required this.roomId,
    required this.roomHostNickname,
    required this.inviterNickname,
  });

  @override
  State<FriendInviteDialog> createState() => _FriendInviteDialogState();
}

class _FriendInviteDialogState extends State<FriendInviteDialog> {
  final GameInvitationService _invitationService = GameInvitationService();
  final TextEditingController _searchController = TextEditingController();

  List<UserSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _isInviting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Search for users by user ID or nickname
  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _invitationService.searchUsers(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama sırasında hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Invite user to game room
  Future<void> _inviteUser(UserSearchResult user) async {
    setState(() {
      _isInviting = true;
    });

    try {
      final result = await _invitationService.inviteFriendByUserId(
        roomId: widget.roomId,
        targetUserId: user.userId,
        inviterNickname: widget.inviterNickname,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Davet gönderildi!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Close dialog on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Davet gönderilemedi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error inviting user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Davet gönderilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isInviting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arkadaş Davet Et',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.roomHostNickname}\'ın Odası',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kullanıcı ID veya Takma Ad ile Ara',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı ID veya takma ad girin',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _searchResults.clear();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _searchUsers(value);
                    },
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                        ? _searchController.text.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aramak için kullanıcı ID veya takma ad girin',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Kullanıcı bulunamadı',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final user = _searchResults[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: Text(
                                      user.nickname.isNotEmpty
                                          ? user.nickname[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    user.nickname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('ID: ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                          Expanded(
                                            child: CopyToClipboardWidget(
                                              textToCopy: user.userId,
                                              successMessage:
                                                  'Kullanıcı ID\'si kopyalandı!',
                                              iconSize: 14,
                                              child: Text(
                                                '${user.userId.substring(0, 8)}...',
                                                style: const TextStyle(
                                                    fontFamily: 'monospace'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        user.foundBy == 'userId'
                                            ? 'ID ile bulundu'
                                            : 'Takma ad ile bulundu',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: _isInviting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : ElevatedButton(
                                          onPressed: () => _inviteUser(user),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Davet Et'),
                                        ),
                                  onTap: () => _inviteUser(user),
                                ),
                              );
                            },
                          ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
