// lib/widgets/block_user_dialog.dart
// Block User Dialog - Confirm and handle user blocking

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/blocked_user.dart';

class BlockUserDialog extends StatefulWidget {
  final String userId;
  final String nickname;
  final VoidCallback? onBlockComplete;

  const BlockUserDialog({
    super.key,
    required this.userId,
    required this.nickname,
    this.onBlockComplete,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  BlockReason _selectedReason = BlockReason.other;
  bool _isReported = false;
  bool _isBlocking = false;
  String _customReason = '';

  static const Map<BlockReason, String> _reasonDisplayNames = {
    BlockReason.harassment: 'Taciz',
    BlockReason.spam: 'Spam',
    BlockReason.cheating: 'Hile',
    BlockReason.inappropriateBehavior: 'Uygunsuz Davranış',
    BlockReason.tooManyRequests: 'Çok Fazla İstek',
    BlockReason.personal: 'Kişisel Neden',
    BlockReason.other: 'Diğer',
  };

  Future<void> _blockUser() async {
    if (_isBlocking) return;

    setState(() => _isBlocking = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('Oturum açmanız gerekiyor');
        return;
      }

      // Create blocked user record
      final blockedUser = BlockedUser(
        id: '${currentUser.uid}_${widget.userId}',
        blockedUserId: widget.userId,
        blockedUserNickname: widget.nickname,
        blockedAt: DateTime.now(),
        reason: _selectedReason,
        customReason: _customReason.isNotEmpty ? _customReason : null,
        isReported: _isReported,
      );

      // Save to Firestore: users/{currentUserId}/blocked_users/{blockedUserId}
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .doc(widget.userId)
          .set(blockedUser.toMap());

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.nickname} engellendi'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onBlockComplete?.call();
      }
    } catch (e) {
      _showError('Engelleme sırasında hata oluştu');
    } finally {
      if (mounted) {
        setState(() => _isBlocking = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.block, color: Colors.red),
          const SizedBox(width: 8),
          Text('Engelle'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.nickname} kullanıcısını engellemek istiyor musunuz?'),
          const SizedBox(height: 16),
          
          // Reason selection
          Text(
            'Engelleme nedeni:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<BlockReason>(
              value: _selectedReason,
              isExpanded: true,
              underline: const SizedBox(),
              items: BlockReason.values.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(_reasonDisplayNames[reason] ?? reason.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedReason = value);
                }
              },
            ),
          ),
          
          // Custom reason input
          if (_selectedReason == BlockReason.other) ...[
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Açıklama (opsiyonel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => _customReason = value,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Report checkbox
          CheckboxListTile(
            title: const Text('Bu kullanıcıyı bildir'),
            subtitle: const Text(
              'Uygulama yöneticilerine bildirim gönder',
              style: TextStyle(fontSize: 11),
            ),
            value: _isReported,
            onChanged: (value) {
              setState(() => _isReported = value ?? false);
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBlocking ? null : () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: _isBlocking ? null : _blockUser,
          child: _isBlocking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Engelle'),
        ),
      ],
    );
  }
}

// Show block dialog helper
void showBlockUserDialog({
  required BuildContext context,
  required String userId,
  required String nickname,
  VoidCallback? onBlockComplete,
}) {
  showDialog(
    context: context,
    builder: (context) => BlockUserDialog(
      userId: userId,
      nickname: nickname,
      onBlockComplete: onBlockComplete,
    ),
  );
}

