// lib/services/qr_share_service.dart
// QR Code Sharing Service - Share QR via WhatsApp, Gmail, and System Share

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'qr_image_service.dart';

/// QR Code Sharing Service
/// Supports WhatsApp, Gmail, and System Share Menu
class QRShareService {
  static final QRShareService _instance = QRShareService._internal();
  factory QRShareService() => _instance;
  QRShareService._internal();

  final QRImageService _qrImageService = QRImageService();

  /// Share QR code via WhatsApp
  Future<bool> shareViaWhatsApp({
    required String qrData,
    required String nickname,
    String? customMessage,
  }) async {
    try {
      // Generate QR image bytes
      final qrBytes = await _qrImageService.generateQRBytes(
        data: qrData,
        size: 512,
      );

      // Create temporary file for sharing
      final directory = Directory.systemTemp;
      final qrFile = File('${directory.path}/qr_$nickname.png');
      await qrFile.writeAsBytes(qrBytes);

      // Prepare WhatsApp message
      final message = customMessage ??
          '$nickname size Karbonson\'da arkadaşlık isteği gönderiyor! '
          'Bu QR kodunu tara ve beni arkadaş listene ekle. 🌍';

      // Try to launch WhatsApp with text
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/?text=$encodedMessage';
      final Uri whatsappUri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback to system share
      await Share.shareXFiles(
        [XFile(qrFile.path, mimeType: 'image/png')],
        text: message,
      );
      
      qrFile.delete().ignore();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('WhatsApp share error: $e');
      return false;
    }
  }

  /// Share QR code via WhatsApp text only
  Future<bool> shareViaWhatsAppText({
    required String qrData,
    required String nickname,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ??
          '🌍 $nickname seni Karbonson\'da arkadaş olmaya davet ediyor!\n\n'
          'QR kodumu taramak için: ${_generateShareLink(nickname)}';

      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'whatsapp://send?text=$encodedMessage';
      final Uri uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('WhatsApp text share error: $e');
      return false;
    }
  }

  /// Share QR code via Gmail
  Future<bool> shareViaGmail({
    required String qrData,
    required String nickname,
    String? recipientEmail,
    String? subject,
    String? customBody,
  }) async {
    try {
      final subjectText = subject ?? 'Karbonson Arkadaşlık Daveti';
      final bodyText = customBody ??
          'Merhaba!\n\n'
          '$nickname sizi Karbonson çevre oyununa arkadaş olmaya davet ediyor!\n\n'
          'Benimle bağlanmak için bu QR kodumu taramanız yeterli:\n\n'
          'QR Data: $qrData\n\n'
          'veya bu bağlantıyı kullanabilirsiniz:\n'
          '${_generateShareLink(nickname)}\n\n'
          'Görüşmek üzre! 🌍';

      final String mailtoUri = recipientEmail != null
          ? 'mailto:$recipientEmail?subject=${Uri.encodeComponent(subjectText)}&body=${Uri.encodeComponent(bodyText)}'
          : 'mailto:?subject=${Uri.encodeComponent(subjectText)}&body=${Uri.encodeComponent(bodyText)}';

      final Uri uri = Uri.parse(mailtoUri);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      await Share.share('$subjectText\n\n$bodyText', subject: subjectText);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Gmail share error: $e');
      return false;
    }
  }

  /// Share QR code via system share menu
  Future<bool> shareViaSystem({
    required String qrData,
    required String nickname,
    String? customMessage,
  }) async {
    try {
      final qrBytes = await _qrImageService.generateQRBytes(
        data: qrData,
        size: 512,
      );

      final directory = Directory.systemTemp;
      final qrFile = File('${directory.path}/qr_$nickname.png');
      await qrFile.writeAsBytes(qrBytes);

      final message = customMessage ??
          '$nickname size Karbonson\'da arkadaşlık isteği gönderiyor! 🌍\n\n'
          'Beni arkadaş listene eklemek için bu QR kodunu tara.';

      await Share.shareXFiles(
        [XFile(qrFile.path, mimeType: 'image/png')],
        text: message,
        subject: 'Karbonson Arkadaşlık Daveti',
      );

      qrFile.delete().ignore();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('System share error: $e');
      try {
        final message = customMessage ??
            '$nickname sizi Karbonson\'da arkadaş olmaya davet ediyor!\n'
            'Bağlantı: ${_generateShareLink(nickname)}';
        await Share.share(message, subject: 'Karbonson Arkadaşlık Daveti');
        return true;
      } catch (e2) {
        if (kDebugMode) debugPrint('System text share error: $e2');
        return false;
      }
    }
  }

  /// Share text only
  Future<bool> shareText({
    required String nickname,
    required String qrData,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ??
          '🌍 $nickname seni Karbonson çevre oyununa arkadaş olmaya davet ediyor!\n\n'
          ' Beni arkadaş listene eklemek için QR kodumu tara veya bu bağlantıyı kullan:\n'
          '${_generateShareLink(nickname)}\n\n'
          'Karbonson\'da görüşmek üzre!';

      await Share.share(message, subject: 'Karbonson Arkadaşlık Daveti');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Text share error: $e');
      return false;
    }
  }

  /// Copy QR data to clipboard
  Future<bool> copyToClipboard({
    required String qrData,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ??
          'Karbonson Arkadaşlık ID:\n$qrData\n\n'
          'Bağlantı: ${_generateShareLinkFromData(qrData)}';
          
      await Clipboard.setData(ClipboardData(text: message));
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Clipboard error: $e');
      return false;
    }
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    try {
      final Uri whatsappUrl = Uri.parse('whatsapp://');
      return await canLaunchUrl(whatsappUrl);
    } catch (e) {
      return false;
    }
  }

  /// Check if Gmail is installed
  Future<bool> isGmailInstalled() async {
    try {
      final Uri gmailUrl = Uri.parse('mailto:');
      return await canLaunchUrl(gmailUrl);
    } catch (e) {
      return false;
    }
  }

  /// Generate shareable deep link
  String _generateShareLink(String nickname) {
    return 'https://karbonson.app/addfriend/${Uri.encodeComponent(nickname)}';
  }

  /// Generate shareable link from QR data
  String _generateShareLinkFromData(String qrData) {
    try {
      return 'https://karbonson.app/addfriend?data=${Uri.encodeComponent(qrData)}';
    } catch (e) {
      return 'https://karbonson.app';
    }
  }

  /// Get share options
  List<ShareOption> getShareOptions() {
    return [
      const ShareOption(
        id: 'whatsapp',
        name: 'WhatsApp',
        icon: Icons.chat,
        color: Color(0xFF25D366),
        description: 'WhatsApp üzerinden paylaş',
      ),
      const ShareOption(
        id: 'gmail',
        name: 'Gmail',
        icon: Icons.email,
        color: Color(0xFFEA4335),
        description: 'E-posta ile gönder',
      ),
      const ShareOption(
        id: 'system',
        name: 'Paylaş',
        icon: Icons.share,
        color: Color(0xFF2196F3),
        description: 'Diğer uygulamalar',
      ),
      const ShareOption(
        id: 'copy',
        name: 'Kopyala',
        icon: Icons.content_copy,
        color: Color(0xFF607D8B),
        description: 'Bağlantıyı kopyala',
      ),
    ];
  }
}

/// Share option model
class ShareOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const ShareOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

