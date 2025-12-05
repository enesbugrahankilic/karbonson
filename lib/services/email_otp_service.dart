// lib/services/email_otp_service.dart
// Email OTP Service for password reset verification
// Generates 6-digit codes and sends via email for secure password reset

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// OTP kod durumu enum
enum OtpStatus {
  active,      // Kod aktif ve kullanılabilir
  used,        // Kod kullanılmış
  expired,     // Kod süresi dolmuş
}

/// OTP kod modeli
class OtpCode {
  final String code;
  final String email;
  final DateTime createdAt;
  final DateTime expiresAt;
  final OtpStatus status;
  final String? usedAt;

  OtpCode({
    required this.code,
    required this.email,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.usedAt,
  });

  /// Kod süresi dolmuş mu?
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  /// Kod kullanılabilir mi?
  bool get isUsable => status == OtpStatus.active && !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'email': email,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'status': status.name,
      'usedAt': usedAt,
    };
  }

  factory OtpCode.fromMap(Map<String, dynamic> map) {
    return OtpCode(
      code: map['code'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] ?? 0),
      status: OtpStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OtpStatus.active,
      ),
      usedAt: map['usedAt'],
    );
  }
}

/// Email OTP servisi sonucu
class EmailOtpResult {
  final bool isSuccess;
  final String message;
  final String? email;
  final String? code; // Sadece test amaçlı, production'da kullanmayın

  const EmailOtpResult({
    required this.isSuccess,
    required this.message,
    this.email,
    this.code,
  });

  factory EmailOtpResult.success(String message, String email) {
    return EmailOtpResult(
      isSuccess: true,
      message: message,
      email: email,
    );
  }

  factory EmailOtpResult.failure(String message) {
    return EmailOtpResult(
      isSuccess: false,
      message: message,
    );
  }
}

/// Email OTP Verification result
class EmailOtpVerificationResult {
  final bool isValid;
  final String message;
  final String? email;
  final bool isExpired;
  final bool isUsed;

  const EmailOtpVerificationResult({
    required this.isValid,
    required this.message,
    this.email,
    this.isExpired = false,
    this.isUsed = false,
  });

  factory EmailOtpVerificationResult.valid(String email) {
    return EmailOtpVerificationResult(
      isValid: true,
      message: 'Doğrulama kodu geçerli',
      email: email,
    );
  }

  factory EmailOtpVerificationResult.invalid(String message) {
    return EmailOtpVerificationResult(
      isValid: false,
      message: message,
    );
  }

  factory EmailOtpVerificationResult.expired(String message) {
    return EmailOtpVerificationResult(
      isValid: false,
      message: message,
      isExpired: true,
    );
  }

  factory EmailOtpVerificationResult.used(String message) {
    return EmailOtpVerificationResult(
      isValid: false,
      message: message,
      isUsed: true,
    );
  }
}

/// Email OTP Service - generates and manages verification codes
class EmailOtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // OTP kod süresi (5 dakika)
  static const Duration _otpDuration = Duration(minutes: 5);
  
  // Kod uzunluğu
  static const int _codeLength = 6;

  /// ⚡ HIZLANDIRILMIŞ E-posta adresi için OTP kodu gönder
  static Future<EmailOtpResult> sendOtpCode({
    required String email,
    String? purpose, // 'password_reset' veya 'forgot_password'
  }) async {
    try {
      // E-posta formatını kontrol et
      if (!_isValidEmail(email)) {
        return EmailOtpResult.failure('Geçerli bir e-posta adresi girin');
      }

      // ⚡ PARALEL İŞLEM - Cleanup ve kod oluşturmayı aynı anda yap
      final cleanupFuture = _cleanupExistingCodes(email);
      final code = _generateOtpCode();
      final now = DateTime.now();
      final expiresAt = now.add(_otpDuration);

      // OTP kodunu Firestore'a kaydet (cleanup tamamlanana kadar bekle)
      await cleanupFuture;
      
      final otpCode = OtpCode(
        code: code,
        email: email,
        createdAt: now,
        expiresAt: expiresAt,
        status: OtpStatus.active,
      );

      // ⚡ ASYNC WRITE - Firestore'a kaydet ve email gönderimi aynı anda
      final firestoreWrite = _firestore
          .collection('email_otp_codes')
          .doc('$email-${now.millisecondsSinceEpoch}')
          .set(otpCode.toMap());

      if (kDebugMode) {
        debugPrint('Email OTP: Kod oluşturuldu: ***$code (email: ${email.replaceRange(2, email.indexOf('@'), '***')})');
      }

      // E-posta ile kodu gönder (paralel)
      final emailSendFuture = _sendEmailWithCode(email: email, code: code, purpose: purpose);
      
      // Her iki işlemi de bekle
      await Future.wait([firestoreWrite, emailSendFuture]);

      // Success message (production'da kodu gösterme!)
      String successMessage;
      if (kDebugMode && purpose == 'debug') {
        successMessage = 'Kod gönderildi: $code (Debug modu)';
      } else {
        successMessage = '6 haneli doğrulama kodu e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin. 📧';
      }

      return EmailOtpResult.success(successMessage, email);

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email OTP gönderme hatası: $e');
      }
      return EmailOtpResult.failure('Kod gönderilemedi. Lütfen tekrar deneyin.');
    }
  }

  /// OTP kodunu doğrula
  static Future<EmailOtpVerificationResult> verifyOtpCode({
    required String email,
    required String code,
  }) async {
    try {
      // Firestore'dan e-posta için aktif kodları bul
      final querySnapshot = await _firestore
          .collection('email_otp_codes')
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: OtpStatus.active.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return EmailOtpVerificationResult.invalid('Doğrulama kodu bulunamadı. Lütfen yeni bir kod isteyin.');
      }

      final docs = querySnapshot.docs;
      OtpCode? matchingCode;

      // Kodu bul
      for (final doc in docs) {
        final otpData = OtpCode.fromMap(doc.data());
        if (otpData.code == code) {
          matchingCode = otpData;
          break;
        }
      }

      if (matchingCode == null) {
        return EmailOtpVerificationResult.invalid('Geçersiz doğrulama kodu. Lütfen kodu tekrar kontrol edin.');
      }

      // Süre kontrolü
      if (matchingCode.isExpired) {
        // Kodu expired olarak güncelle
        await _firestore
            .collection('email_otp_codes')
            .doc('${matchingCode.email}-${matchingCode.createdAt.millisecondsSinceEpoch}')
            .update({'status': OtpStatus.expired.name});
            
        return EmailOtpVerificationResult.expired('Doğrulama kodunun süresi dolmuş. Lütfen yeni bir kod isteyin.');
      }

      // Kodu kullanılmış olarak işaretle
      await _firestore
          .collection('email_otp_codes')
          .doc('${matchingCode.email}-${matchingCode.createdAt.millisecondsSinceEpoch}')
          .update({
            'status': OtpStatus.used.name,
            'usedAt': DateTime.now().millisecondsSinceEpoch,
          });

      if (kDebugMode) {
        debugPrint('Email OTP: Kod doğrulandı (email: ${email.replaceRange(2, email.indexOf('@'), '***')})');
      }

      return EmailOtpVerificationResult.valid(email);

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email OTP doğrulama hatası: $e');
      }
      return EmailOtpVerificationResult.invalid('Doğrulama işlemi başarısız. Lütfen tekrar deneyin.');
    }
  }

  /// ⚡ HIZLANDIRILMIŞ Önceki kodları temizle (aynı e-posta için)
  static Future<void> _cleanupExistingCodes(String email) async {
    try {
      // ⚡ BATCH OPERATION kullanarak hızlandırma
      final querySnapshot = await _firestore
          .collection('email_otp_codes')
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: OtpStatus.active.name)
          .limit(10) // ⚡ Sadece son 10 kodu kontrol et (performance)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        
        for (final doc in querySnapshot.docs) {
          batch.update(doc.reference, {'status': OtpStatus.expired.name});
        }
        
        // ⚡ Tek seferde commit et
        await batch.commit();
        
        if (kDebugMode) {
          debugPrint('Email OTP: ${querySnapshot.docs.length} eski kod temizlendi');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Cleanup error: $e');
      }
      // Cleanup hatası kritik değil, devam et
    }
  }

  /// 6 haneli kod oluştur
  static String _generateOtpCode() {
    final random = Random();
    int code = 0;
    for (int i = 0; i < _codeLength; i++) {
      code = code * 10 + random.nextInt(10); // 0-9 arası
    }
    return code.toString().padLeft(_codeLength, '0');
  }

  /// E-posta ile kod gönder
  static Future<void> _sendEmailWithCode({
    required String email,
    required String code,
    String? purpose,
  }) async {
    try {
      // Firebase Action Code Settings kullanarak e-posta gönder
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://karbonson.page.link/otp-verification?email=${Uri.encodeComponent(email)}&code=${Uri.encodeComponent(code)}',
        handleCodeInApp: true,
        androidPackageName: 'com.example.karbonson',
        androidMinimumVersion: '21',
      );

      // Custom token ile e-posta gönder (Firebase Email Link Auth)
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      if (kDebugMode) {
        debugPrint('Email OTP: E-posta gönderildi ($purpose)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Email OTP e-posta gönderme hatası: $e');
      }
      rethrow;
    }
  }

  /// E-posta formatını kontrol et
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email) && email.isNotEmpty;
  }

  /// Süresi dolmuş kodları temizle (background task)
  static Future<void> cleanupExpiredCodes() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final querySnapshot = await _firestore
          .collection('email_otp_codes')
          .where('expiresAt', isLessThan: now)
          .where('status', isEqualTo: OtpStatus.active.name)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'status': OtpStatus.expired.name});
      }

      if (querySnapshot.docs.isNotEmpty) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint('Email OTP: ${querySnapshot.docs.length} süresi dolmuş kod temizlendi');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Expired codes cleanup error: $e');
      }
    }
  }
}