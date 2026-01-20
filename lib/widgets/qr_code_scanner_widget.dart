// lib/widgets/qr_code_scanner_widget.dart
// QR Code Scanner Widget - Scan QR codes to add friends
// Requires: qr_code_scanner package

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/qr_code_service.dart';
import '../services/firestore_service.dart';
import '../services/friend_suggestion_service.dart';
import '../services/notification_service.dart';
import '../models/friend_suggestion.dart';

class QRCodeScannerWidget extends StatefulWidget {
  final Function(bool isScanning)? onScanStateChanged;
  final VoidCallback? onScanComplete;

  const QRCodeScannerWidget({
    super.key,
    this.onScanStateChanged,
    this.onScanComplete,
  });

  @override
  State<QRCodeScannerWidget> createState() => _QRCodeScannerWidgetState();
}

class _QRCodeScannerWidgetState extends State<QRCodeScannerWidget> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? _result;
  bool _isProcessing = false;
  bool _hasPermission = false;
  bool _isFrontCamera = false;
  QRViewController? _controller;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    if (kIsWeb) {
      setState(() => _hasPermission = true);
      return;
    }

    // For web, we assume permission is granted
    // For mobile, permission handling would require permission_handler
    setState(() => _hasPermission = true);
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing || scanData.code == null) return;

      // Prevent duplicate processing
      if (_result != null && _result!.code == scanData.code) return;

      setState(() {
        _result = scanData;
        _isProcessing = true;
      });

      widget.onScanStateChanged?.call(false);

      await _handleScanResult(scanData.code!);

      // Reset after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      widget.onScanComplete?.call();
    });
  }

  Future<void> _handleScanResult(String qrData) async {
    try {
      // Try to parse as friend QR code
      final qrResult = QRCodeService.parseScanResult(qrData);

      if (qrResult.success && qrResult.friendData != null) {
        await _handleFriendQRCode(qrResult.friendData!);
        return;
      }

      // Try to parse as deep link
      if (qrData.startsWith('https://') || qrData.startsWith('karbonson://')) {
        await _handleDeepLink(qrData);
        return;
      }

      // Try to parse as user ID directly
      if (_isValidUserId(qrData)) {
        await _handleUserId(qrData);
        return;
      }

      // Show invalid QR code message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Geçersiz QR kodu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error handling QR scan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('QR kod işlenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidUserId(String id) {
    // Basic validation for Firebase user IDs
    return id.length >= 20 &&
        id.length <= 40 &&
        RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id);
  }

  Future<void> _handleFriendQRCode(QRFriendData friendData) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${friendData.nickname} kullanıcısına istek gönderiliyor...'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    final success = await FriendSuggestionService()
        .sendRequestFromSuggestion(FriendSuggestion(
      userId: friendData.userId,
      nickname: friendData.nickname ?? 'Kullanıcı',
      reason: SuggestionReason.other,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: success
              ? const Text('Arkadaşlık isteği gönderildi!')
              : const Text('İstek gönderilemedi'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDeepLink(String url) async {
    // Parse deep link to extract user ID
    final uri = Uri.parse(url);
    
    // Check for addfriend route
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'addfriend') {
      final userId = uri.pathSegments[1];
      if (_isValidUserId(userId)) {
        await _handleUserId(userId);
        return;
      }
    }

    // Check query parameters
    final userId = uri.queryParameters['userId'];
    if (userId != null && _isValidUserId(userId)) {
      await _handleUserId(userId);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Geçersiz bağlantı formatı'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleUserId(String userId) async {
    final firestoreService = FirestoreService();
    
    // Get user profile
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    if (!userDoc.exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kullanıcı bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final nickname = userDoc.data()?['nickname'] ?? 'Kullanıcı';

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Arkadaş Ekle'),
          content: Text('$nickname kullanıcısına arkadaşlık isteği göndermek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendFriendRequest(userId, nickname);
              },
              child: const Text('İstek Gönder'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendFriendRequest(String userId, String nickname) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final success = await FirestoreService().sendFriendRequest(
      currentUser.uid,
      currentUser.displayName ?? 'Kullanıcı',
      userId,
      nickname,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: success
              ? Text('$nickname kullanıcısına istek gönderildi!')
              : const Text('İstek gönderilemedi'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _toggleCamera() {
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod Tara'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {},
            tooltip: 'Flash',
          ),
          IconButton(
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: _toggleCamera,
            tooltip: 'Kamera Değiştir',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Arkadaşınızın QR kodunu tarayarak arkadaşlık isteği gönderebilirsiniz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Permission check
          if (!_hasPermission)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kamera izni gerekli',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      child: const Text('İzin Ver'),
                    ),
                  ],
                ),
              ),
            )
          else
            // QR Scanner
            Expanded(
              child: Stack(
                children: [
                  // QR View
                  QRView(
                    key: _qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.green,
                      borderRadius: 12,
                      borderLength: 30,
                      borderWidth: 5,
                    ),
                    cameraFacing: _isFrontCamera
                        ? CameraFacing.front
                        : CameraFacing.back,
                  ),

                  // Scanning indicator
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'İşleniyor...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Result overlay
                  if (_result != null && !_isProcessing)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Card(
                        color: Colors.white.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Taratıldı!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _result!.code ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

