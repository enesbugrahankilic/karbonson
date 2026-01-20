// lib/widgets/add_friend_bottom_sheet.dart
// Add Friend Bottom Sheet - Modern UI for adding friends

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_code_scanner_widget.dart';
import '../services/firestore_service.dart';

class AddFriendBottomSheet extends StatefulWidget {
  final bool Function(String userId, String nickname)? onUserSelected;

  const AddFriendBottomSheet({
    super.key,
    this.onUserSelected,
  });

  @override
  State<AddFriendBottomSheet> createState() => _AddFriendBottomSheetState();
}

class _AddFriendBottomSheetState extends State<AddFriendBottomSheet> {
  final TextEditingController _userIdController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSearching = false;
  String? _searchError;

  // Localized strings (Turkish)
  static const String _title = 'Arkadaş Ekle';
  static const String _scanQRCode = 'QR Kod Tara';
  static const String _addByUserId = 'Kullanıcı ID ile Ekle';
  static const String _suggestedFriends = 'Önerilen Arkadaşlar';
  static const String _userId = 'Kullanıcı ID';
  static const String _cancel = 'İptal';
  static const String _search = 'Ara';
  static const String _sendRequest = 'İstek Gönder';
  static const String _addFriendById = 'Kullanıcı ID ile Ekleme';
  static const String _scanQRSubtitle = 'Arkadaşınızın QR kodunu tarayın';
  static const String _addByIdSubtitle = 'Kullanıcı ID ile ekle';
  static const String _suggestionsSubtitle = 'Önerilen arkadaşları görün';
  static const String _userIdRequired = 'Kullanıcı ID\'si gerekli';
  static const String _invalidUserIdFormat = 'Geçersiz Kullanıcı ID formatı';
  static const String _sessionRequired = 'Oturum açmanız gerekiyor';
  static const String _cannotAddSelf = 'Kendinizi ekleyemezsiniz';
  static const String _alreadyFriend = 'Bu kullanıcı zaten arkadaşınız';
  static const String _requestAlreadySent = 'Bu kullanıcıya zaten istek gönderdiniz';
  static const String _userNotFound = 'Kullanıcı bulunamadı';
  static const String _searchErrorMessage = 'Arama sırasında hata oluştu';
  static const String _enterUserId = 'Kullanıcı ID\'sini girin';
  static const String _confirmSendRequest = 'Arkadaşlık isteği göndermek istiyor musunuz?';
  static const String _requestSent = 'İstek gönderildi!';
  static const String _requestFailed = 'İstek gönderilemedi';
  static const String _nickname = 'Kullanıcı';

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _showUserIdInputDialog() {
    Navigator.of(context).pop(); // Close bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_addFriendById),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: _userId,
                hintText: _enterUserId,
                border: OutlineInputBorder(),
                errorText: _searchError,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_cancel),
          ),
          ElevatedButton(
            onPressed: _isSearching ? null : () => _searchByUserId(),
            child: _isSearching
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_search),
          ),
        ],
      ),
    );
  }

  void _goToSuggestions() {
    Navigator.of(context).pop();
    // Switch to suggestions tab (index 3)
    final tabController = DefaultTabController.of(context);
    if (tabController != null) {
      tabController.animateTo(3);
    }
  }

  void _openQRScanner() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRCodeScannerWidget(),
      ),
    );
  }

  Future<void> _searchByUserId() async {
    final userId = _userIdController.text.trim();

    if (userId.isEmpty) {
      setState(() => _searchError = _userIdRequired);
      return;
    }

    if (userId.length < 20) {
      setState(() => _searchError = _invalidUserIdFormat);
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _searchError = _sessionRequired);
        return;
      }

      if (userId == currentUser.uid) {
        setState(() => _searchError = _cannotAddSelf);
        return;
      }

      // Check if already friends
      final friends = await _firestoreService.getFriends(currentUser.uid);
      if (friends.any((f) => f.id == userId)) {
        setState(() => _searchError = _alreadyFriend);
        return;
      }

      // Check for existing request
      final sentRequests = await _firestoreService.getSentFriendRequests(currentUser.uid);
      if (sentRequests.any((r) => r.toUserId == userId)) {
        setState(() => _searchError = _requestAlreadySent);
        return;
      }

      // Get user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        setState(() => _searchError = _userNotFound);
        return;
      }

      final nickname = userDoc.data()?['nickname'] ?? _nickname;

      // Success - close dialog and send request
      Navigator.of(context).pop();
      _showConfirmationDialog(userId, nickname);
    } catch (e) {
      setState(() => _searchError = _searchErrorMessage);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _showConfirmationDialog(String userId, String nickname) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_title),
        content: Text('$nickname kullanıcısına $_confirmSendRequest'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _sendFriendRequest(userId, nickname);
            },
            child: Text(_sendRequest),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFriendRequest(String userId, String nickname) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final success = await _firestoreService.sendFriendRequest(
      currentUser.uid,
      currentUser.displayName ?? _nickname,
      userId,
      nickname,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: success
              ? Text('$_nickname kullanıcısına $_requestSent')
              : const Text(_requestFailed),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),
          
          // Title
          Text(
            _title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 24),
          
          // QR Code Scan Option
          _buildOptionTile(
            icon: Icons.qr_code_scanner,
            iconColor: Colors.blue,
            title: _scanQRCode,
            subtitle: _scanQRSubtitle,
            onTap: _openQRScanner,
          ),
          
          SizedBox(height: 12),
          
          // User ID Input Option
          _buildOptionTile(
            icon: Icons.person_add,
            iconColor: Colors.green,
            title: _addByUserId,
            subtitle: _addByIdSubtitle,
            onTap: _showUserIdInputDialog,
          ),
          
          SizedBox(height: 12),
          
          // Suggestions Option
          _buildOptionTile(
            icon: Icons.auto_awesome,
            iconColor: Colors.purple,
            title: _suggestedFriends,
            subtitle: _suggestionsSubtitle,
            onTap: _goToSuggestions,
          ),
          
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

