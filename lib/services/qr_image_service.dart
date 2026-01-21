// lib/services/qr_image_service.dart
// QR Code Image Generation Service - Convert QR to image bytes

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class QRImageService {
  static final QRImageService _instance = QRImageService._internal();
  factory QRImageService() => _instance;
  QRImageService._internal();

  /// Generate QR code as raw bytes (PNG format)
  Future<Uint8List> generateQRBytes({
    required String data,
    int size = 512,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('Invalid QR code data');
    }

    final qrCode = qrValidationResult.qrCode!;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw background
    final Paint paintBg = Paint()..color = backgroundColor;
    final Rect rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    canvas.drawRect(rect, paintBg);

    // Draw QR code
    final painter = QrPainter.withQr(
      qr: qrCode,
      emptyColor: backgroundColor,
      gapless: true,
    );

    final Size qrSize = Size(size.toDouble(), size.toDouble());
    painter.paint(canvas, qrSize);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert QR to bytes');
    }

    return byteData.buffer.asUint8List();
  }

  /// Generate QR code and save to file
  Future<File> generateQRFile({
    required String data,
    required String filename,
    int size = 512,
  }) async {
    final bytes = await generateQRBytes(data: data, size: size);
    
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename.png');
    
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Generate QR code with embedded logo/text
  Future<Uint8List> generateQRWithLogo({
    required String data,
    required Uint8List logoBytes,
    int size = 512,
    double logoRatio = 0.25,
  }) async {
    // Generate base QR
    final qrBytes = await generateQRBytes(data: data, size: size);
    
    // Decode QR image
    final img.Image? qrImage = img.decodePng(qrBytes);
    if (qrImage == null) {
      throw Exception('Failed to decode QR image');
    }
    
    // Decode logo
    final img.Image? logoImage = img.decodePng(logoBytes);
    if (logoImage == null) {
      throw Exception('Failed to decode logo image');
    }
    
    // Calculate logo size (25% of QR size)
    final logoWidth = (size * logoRatio).round();
    final logoHeight = (logoWidth * (logoImage.height / logoImage.width)).round();
    
    // Resize logo
    final resizedLogo = img.copyResize(
      logoImage,
      width: logoWidth,
      height: logoHeight,
    );
    
    // Center logo on QR
    final centerX = (size - logoWidth) ~/ 2;
    final centerY = (size - logoHeight) ~/ 2;
    
    // Draw white background for logo
    final bgPadding = 10;
    img.fillRect(
      qrImage,
      x1: centerX - bgPadding,
      y1: centerY - bgPadding,
      x2: centerX + logoWidth + bgPadding,
      y2: centerY + logoHeight + bgPadding,
      color: img.ColorRgb8(255, 255, 255),
    );
    
    // Draw logo on QR
    img.compositeImage(
      qrImage,
      resizedLogo,
      dstX: centerX,
      dstY: centerY,
    );
    
    return Uint8List.fromList(img.encodePng(qrImage));
  }

  /// Generate QR code with custom styling
  Future<Uint8List> generateStyledQR({
    required String data,
    int size = 512,
    String? logoPath,
    Color? backgroundColor,
    Color? foregroundColor,
  }) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('Invalid QR code data');
    }

    final qrCode = qrValidationResult.qrCode!;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Draw rounded background
    final bgPaint = Paint()..color = backgroundColor ?? Colors.white;
    final RRect bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      const Radius.circular(16),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Custom QR painter with styling
    final painter = QrPainter.withQr(
      qr: qrCode,
      emptyColor: backgroundColor ?? Colors.white,
      gapless: true,
    );

    // Apply padding
    const padding = 20.0;
    final qrSize = size - (padding * 2);
    final offset = Offset(padding, padding);
    painter.paint(canvas, Size(qrSize, qrSize) + offset);

    final ui.Image image = await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert QR to bytes');
    }

    return byteData.buffer.asUint8List();
  }

  /// Validate QR data
  bool validateQRData(String data) {
    if (data.isEmpty) return false;
    if (data.length > 2953) return false; // Max QR data capacity
    
    final result = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );
    
    return result.status == QrValidationStatus.valid;
  }

  /// Get optimal QR version for data
  int getOptimalVersion(String data) {
    final length = data.length;
    if (length <= 17) return 1;
    if (length <= 32) return 2;
    if (length <= 53) return 3;
    if (length <= 78) return 4;
    if (length <= 106) return 5;
    if (length <= 134) return 6;
    if (length <= 154) return 7;
    if (length <= 192) return 8;
    if (length <= 230) return 9;
    if (length <= 271) return 10;
    return 40; // Max version
  }
}

