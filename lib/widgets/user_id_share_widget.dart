// lib/widgets/user_id_share_widget.dart
// User ID Share Widget - Display and share user ID with WhatsApp, Gmail, System Share

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_share_service.dart';

class UserIdShareWidget extends StatefulWidget {
  final String? userId;
  final String? nickname;
  final bool showQRCodeButton;
  final VoidCallback? onQRCodePressed;
  final double fontSize;

  const UserIdShareWidget({
    super.key,
    this.userId,
    this.nickname,
    this.showQRCodeButton = true,
    this.onQRCodePressed,
    this.fontSize = 14,
  });

  @override
  State<UserIdShareWidget> createState() => _UserIdShareWidgetState();
}

class _UserIdShareWidgetState extends State<UserIdShareWidget> {
  String _displayUserId = '';
  String _displayNickname = '';
  bool _isLoading = true;
  final QRShareService _qrShareService = QRShareService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      String userId = widget.userId ?? '';
      String nickname = widget.nickname ?? '';

      if (userId.isEmpty) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          userId = currentUser.uid;
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (userDoc.exists) {
            nickname = userDoc.data()?['nickname'] ?? 'Kullanıcı';
          } else {
            nickname = currentUser.displayName ?? 'Kullanıcı';
          }
        }
      }

      if (mounted) {
        setState(() {
          _displayUserId = userId;
          _displayNickname = nickname;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _copyUserId() async {
    await Clipboard.setData(ClipboardData(text: _displayUserId));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kullanıcı ID kopyalandı!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String _maskUserId(String userId) {
    if (userId.length <= 8) return userId;
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }

  String _getQRData() {
    // Generate QR data for friend request
    return '{"type":"friend_request","userId":"$_displayUserId","nickname":"$_displayNickname"}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Arkadaş Ekle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _displayNickname,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Kullanıcı ID',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _maskUserId(_displayUserId),
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: 20, color: Colors.blue),
                    onPressed: _copyUserId,
                    tooltip: 'Kopyala',
                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.showQRCodeButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_2, size: 18),
                      label: const Text('QR Kodum'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: widget.onQRCodePressed ?? _showQRCodeDialog,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Bu ID\'yi veya QR kodunu paylaşarak arkadaşlarınla bağlanabilirsin',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCodeDialog() {
    final qrData = _getQRData();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Kodum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _displayNickname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _maskUserId(_displayUserId),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Arkadaşların bu QR kodunu tarayarak sana arkadaşlık isteği gönderebilir',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Share Buttons
            _buildShareButtons(context, qrData),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('ID Kopyala'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _displayUserId));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kullanıcı ID kopyalandı!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons(BuildContext context, String qrData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Paylaş',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // WhatsApp
            _buildShareButton(
              context: context,
              icon: Icons.chat,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () async {
                final success = await _qrShareService.shareViaWhatsApp(
                  qrData: qrData,
                  nickname: _displayNickname,
                );
                _showShareResult(context, success, 'WhatsApp');
              },
            ),
            // Gmail
            _buildShareButton(
              context: context,
              icon: Icons.email,
              label: 'Gmail',
              color: const Color(0xFFEA4335),
              onTap: () async {
                final success = await _qrShareService.shareViaGmail(
                  qrData: qrData,
                  nickname: _displayNickname,
                );
                _showShareResult(context, success, 'Gmail');
              },
            ),
            // System Share
            _buildShareButton(
              context: context,
              icon: Icons.share,
              label: 'Paylaş',
              color: const Color(0xFF2196F3),
              onTap: () async {
                final success = await _qrShareService.shareViaSystem(
                  qrData: qrData,
                  nickname: _displayNickname,
                );
                _showShareResult(context, success, 'Paylaş');
              },
            ),
            // Copy Link
            _buildShareButton(
              context: context,
              icon: Icons.link,
              label: 'Bağlantı',
              color: const Color(0xFF607D8B),
              onTap: () async {
                final success = await _qrShareService.copyToClipboard(
                  qrData: qrData,
                );
                _showShareResult(context, success, 'Bağlantı kopyalandı');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareResult(BuildContext context, bool success, String method) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '$method ile paylaşıldı!' 
            : '$method ile paylaşılamadı'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

