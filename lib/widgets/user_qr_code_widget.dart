// lib/widgets/user_qr_code_widget.dart
// Widget for displaying user's QR code and sharing options

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qr_code_service.dart';
import '../services/qr_share_service.dart';

class UserQRCodeWidget extends StatefulWidget {
  final String userId;
  final String nickname;

  const UserQRCodeWidget({
    super.key,
    required this.userId,
    required this.nickname,
  });

  @override
  State<UserQRCodeWidget> createState() => _UserQRCodeWidgetState();
}

class _UserQRCodeWidgetState extends State<UserQRCodeWidget> {
  final QRCodeService _qrService = QRCodeService();
  final QRShareService _shareService = QRShareService();

  late QRFriendData _qrData;
  bool _isGenerating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateQRData();
  }

  Future<void> _generateQRData() async {
    try {
      setState(() => _isGenerating = true);
      _qrData = _qrService.generateFriendQR(
        userId: widget.userId,
        nickname: widget.nickname,
      );
      setState(() => _isGenerating = false);
    } catch (e) {
      setState(() {
        _error = 'QR kod oluşturulurken hata: $e';
        _isGenerating = false;
      });
    }
  }

  Future<void> _shareQR(ShareOption option) async {
    final qrString = _qrService.generateQRCodeData(_qrData);

    bool success = false;
    String message = '';

    switch (option.id) {
      case 'whatsapp':
        success = await _shareService.shareViaWhatsApp(
          qrData: qrString,
          nickname: widget.nickname,
        );
        message = success ? 'WhatsApp ile paylaşıldı' : 'WhatsApp paylaşımı başarısız';
        break;
      case 'gmail':
        success = await _shareService.shareViaGmail(
          qrData: qrString,
          nickname: widget.nickname,
        );
        message = success ? 'E-posta ile gönderildi' : 'E-posta gönderimi başarısız';
        break;
      case 'system':
        success = await _shareService.shareViaSystem(
          qrData: qrString,
          nickname: widget.nickname,
        );
        message = success ? 'Paylaşıldı' : 'Paylaşım başarısız';
        break;
      case 'copy':
        success = await _shareService.copyToClipboard(qrData: qrString);
        message = success ? 'Bağlantı panoya kopyalandı' : 'Kopyalama başarısız';
        break;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('QR kod oluşturuluyor...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateQRData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Text(
            'Arkadaşlık QR Kodum',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bu QR kodu arkadaşlarınızla paylaşarak kolayca arkadaş ekleyebilirsiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // QR Code Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // User info
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    widget.nickname.isNotEmpty ? widget.nickname[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: QrImageView(
                    data: _qrService.generateQRCodeData(_qrData),
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  '7 gün geçerli',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Share Options
          Text(
            'Paylaş',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Share buttons grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: _shareService.getShareOptions().map((option) {
              return ElevatedButton(
                onPressed: () => _shareQR(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: option.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(option.icon, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      option.name,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Additional info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Nasıl çalışır?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arkadaşlarınız bu QR kodu tarayarak size arkadaşlık isteği gönderebilir. '
                  'İstekler otomatik olarak arkadaş listesine eklenecektir.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}