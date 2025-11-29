// lib/widgets/game_invitation_dialog.dart
// Game invitation dialog widget for real-time invitations

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../services/game_invitation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameInvitationDialog extends StatefulWidget {
  final GameInvitation invitation;
  final VoidCallback? onInvitationHandled;

  const GameInvitationDialog({
    super.key,
    required this.invitation,
    this.onInvitationHandled,
  });

  @override
  State<GameInvitationDialog> createState() => _GameInvitationDialogState();
}

class _GameInvitationDialogState extends State<GameInvitationDialog> {
  bool _isProcessing = false;
  final GameInvitationService _invitationService = GameInvitationService();

  Future<void> _acceptInvitation() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _invitationService.acceptInvitation(widget.invitation.id);
      
      if (mounted) {
        if (result.success) {
          // Show success message and navigate to game
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Invitation accepted!'),
              backgroundColor: Colors.green,
            ),
          );

          if (result.roomId != null) {
            // Navigate to multiplayer lobby with the room ID
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/multiplayer_lobby',
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Failed to accept invitation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onInvitationHandled?.call();
      }
    }
  }

  Future<void> _declineInvitation() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _invitationService.declineInvitation(widget.invitation.id);
      
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Invitation declined'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.of(context).pop(); // Close dialog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Failed to decline invitation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        widget.onInvitationHandled?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.videogame_asset,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Oyun Daveti',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: widget.invitation.fromNickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const TextSpan(text: ' seni oyuna davet etti!'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oda Hostu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      widget.invitation.roomHostNickname,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Davet Zamanı: ${_formatTime(widget.invitation.createdAt)}',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : _declineInvitation,
          child: Text(
            _isProcessing ? 'İşleniyor...' : 'Reddet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _acceptInvitation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(
            _isProcessing ? 'Katılıyor...' : 'Katıl',
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}

/// Show game invitation dialog
void showGameInvitationDialog({
  required BuildContext context,
  required GameInvitation invitation,
  VoidCallback? onInvitationHandled,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => GameInvitationDialog(
      invitation: invitation,
      onInvitationHandled: onInvitationHandled,
    ),
  );
}