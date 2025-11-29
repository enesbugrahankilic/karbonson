// lib/services/comprehensive_2fa_service.dart
// Comprehensive Two-Factor Authentication Service supporting multiple verification methods

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Verification method types supported by the system
enum VerificationMethod {
  sms('SMS'),
  totp('TOTP'),
  hardwareToken('Hardware Token'),
  backupCode('Backup Code');

  const VerificationMethod(this.displayName);
  final String displayName;
}

/// Verification result class with detailed information
class VerificationResult {
  final bool isSuccess;
  final String message;
  final String? code; // Generated verification code for TOTP
  final int? expiresAt; // Unix timestamp when code expires
  final String? sessionId; // Session identifier for tracking
  final List<VerificationMethod>? availableMethods; // Available verification methods

  const VerificationResult({
    required this.isSuccess,
    required this.message,
    this.code,
    this.expiresAt,
    this.sessionId,
    this.availableMethods,
  });

  factory VerificationResult.success(String message, {String? sessionId, List<VerificationMethod>? availableMethods}) {
    return VerificationResult(
      isSuccess: true,
      message: message,
      sessionId: sessionId,
      availableMethods: availableMethods,
    );
  }

  factory VerificationResult.failure(String message) {
    return VerificationResult(
      isSuccess: false,
      message: message,
    );
  }

  factory VerificationResult.totpCode(String code, int expiresAt, String message) {
    return VerificationResult(
      isSuccess: true,
      message: message,
      code: code,
      expiresAt: expiresAt,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt!;
  }

  String get TurkishMessage => _translateToTurkish(message);

  String _translateToTurkish(String message) {
    const translations = {
      'SMS sent successfully': 'SMS başarıyla gönderildi',
      'Code verified successfully': 'Kod başarıyla doğrulandı',
      'Invalid code': 'Geçersiz kod',
      'Code expired': 'Kod süresi doldu',
      'Too many attempts': 'Çok fazla deneme',
      'Network error': 'Ağ hatası',
      'Hardware token not found': 'Donanım tokeni bulunamadı',
      'Backup code used': 'Yedek kod kullanıldı',
      'Session expired': 'Oturum süresi doldu',
    };

    return translations[message] ?? message;
  }
}

/// Comprehensive 2FA Service with multi-method support
class Comprehensive2FAService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _codeExpirationTime = Duration(minutes: 5);
  static const int _maxVerificationAttempts = 3;
  static const int _maxResendAttempts = 5;

  // In-memory session tracking (in production, use Redis or similar)
  static final Map<String, _VerificationSession> _sessions = {};
  static Timer? _cleanupTimer;

  /// Initialize service and start session cleanup
  static void initialize() {
    _startSessionCleanupTimer();
    if (kDebugMode) {
      debugPrint('Comprehensive2FAService initialized');
    }
  }

  /// Start session cleanup timer
  static void _startSessionCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupExpiredSessions();
    });
  }

  /// Clean up expired sessions
  static void _cleanupExpiredSessions() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _sessions.removeWhere((key, session) => now > session.expiresAt);
  }

  /// Check network connectivity (simplified for demo)
  static Future<bool> _isNetworkAvailable() async {
    try {
      // In a real implementation, use connectivity_plus package
      // For now, assume network is available
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking network connectivity: $e');
      }
      return true;
    }
  }

  /// Start verification process for a specific method
  static Future<VerificationResult> startVerification({
    required VerificationMethod method,
    String? phoneNumber,
    String? totpSecret,
  }) async {
    // Check network connectivity
    if (!await _isNetworkAvailable()) {
      return VerificationResult.failure('İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.');
    }

    // Generate session ID
    final sessionId = _generateSecureId();
    final expiresAt = DateTime.now().add(_codeExpirationTime).millisecondsSinceEpoch;

    try {
      switch (method) {
        case VerificationMethod.sms:
          return await _startSMSVerification(phoneNumber!, sessionId, expiresAt);
        case VerificationMethod.totp:
          return await _startTOTPVerification(totpSecret!, sessionId, expiresAt);
        case VerificationMethod.hardwareToken:
          return await _startHardwareTokenVerification(sessionId, expiresAt);
        case VerificationMethod.backupCode:
          return await _startBackupCodeVerification(sessionId, expiresAt);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting ${method.displayName} verification: $e');
      }
      return VerificationResult.failure('${method.displayName} doğrulaması başlatılamadı');
    }
  }

  /// Start SMS verification
  static Future<VerificationResult> _startSMSVerification(
    String phoneNumber,
    String sessionId,
    int expiresAt,
  ) async {
    try {
      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        return VerificationResult.failure('Geçersiz telefon numarası formatı');
      }

      // In a real implementation, this would call Firebase phone verification
      // For demonstration, we'll simulate the process
      
      // Create verification session
      final session = _VerificationSession(
        sessionId: sessionId,
        method: VerificationMethod.sms,
        phoneNumber: phoneNumber,
        expiresAt: expiresAt,
        attempts: 0,
        resendAttempts: 0,
      );
      _sessions[sessionId] = session;

      // Simulate SMS sending delay
      await Future.delayed(const Duration(seconds: 1));

      return VerificationResult.success(
        'SMS sent successfully',
        sessionId: sessionId,
        availableMethods: [
          VerificationMethod.sms,
          VerificationMethod.backupCode,
        ],
      );
    } catch (e) {
      return VerificationResult.failure('SMS gönderilemedi: $e');
    }
  }

  /// Start TOTP verification
  static Future<VerificationResult> _startTOTPVerification(
    String secret,
    String sessionId,
    int expiresAt,
  ) async {
    try {
      // Generate current TOTP code
      final code = generateTOTP(secret);
      final actualExpiresAt = DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch;

      // Create verification session
      final session = _VerificationSession(
        sessionId: sessionId,
        method: VerificationMethod.totp,
        totpSecret: secret,
        expiresAt: actualExpiresAt,
        attempts: 0,
        resendAttempts: 0,
      );
      _sessions[sessionId] = session;

      return VerificationResult.totpCode(
        code,
        actualExpiresAt,
        'Authenticator code generated',
      );
    } catch (e) {
      return VerificationResult.failure('TOTP kodu oluşturulamadı: $e');
    }
  }

  /// Start hardware token verification (simulated biometric)
  static Future<VerificationResult> _startHardwareTokenVerification(
    String sessionId,
    int expiresAt,
  ) async {
    try {
      // Create verification session
      final session = _VerificationSession(
        sessionId: sessionId,
        method: VerificationMethod.hardwareToken,
        expiresAt: expiresAt,
        attempts: 0,
        resendAttempts: 0,
      );
      _sessions[sessionId] = session;

      return VerificationResult.success(
        'Hardware token verification ready',
        sessionId: sessionId,
        availableMethods: [
          VerificationMethod.hardwareToken,
          VerificationMethod.backupCode,
        ],
      );
    } catch (e) {
      return VerificationResult.failure('Hardware token doğrulaması başlatılamadı: $e');
    }
  }

  /// Start backup code verification
  static Future<VerificationResult> _startBackupCodeVerification(
    String sessionId,
    int expiresAt,
  ) async {
    try {
      // Create verification session
      final session = _VerificationSession(
        sessionId: sessionId,
        method: VerificationMethod.backupCode,
        expiresAt: expiresAt,
        attempts: 0,
        resendAttempts: 0,
      );
      _sessions[sessionId] = session;

      return VerificationResult.success(
        'Backup code verification ready',
        sessionId: sessionId,
        availableMethods: [
          VerificationMethod.backupCode,
          VerificationMethod.sms,
        ],
      );
    } catch (e) {
      return VerificationResult.failure('Yedek kod doğrulaması başlatılamadı: $e');
    }
  }

  /// Verify code for a specific method
  static Future<VerificationResult> verifyCode({
    required String sessionId,
    required String code,
    required VerificationMethod method,
  }) async {
    // Check network connectivity
    if (!await _isNetworkAvailable()) {
      return VerificationResult.failure('İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.');
    }

    // Get session
    final session = _sessions[sessionId];
    if (session == null) {
      return VerificationResult.failure('Session not found or expired');
    }

    // Check if session is expired
    if (DateTime.now().millisecondsSinceEpoch > session.expiresAt) {
      _sessions.remove(sessionId);
      return VerificationResult.failure('Session expired');
    }

    // Check attempt limits
    if (session.attempts >= _maxVerificationAttempts) {
      return VerificationResult.failure('Too many attempts');
    }

    try {
      session.attempts++;

      switch (method) {
        case VerificationMethod.sms:
          return await _verifySMSCode(session, code);
        case VerificationMethod.totp:
          return await _verifyTOTPCode(session, code);
        case VerificationMethod.hardwareToken:
          return await _verifyHardwareToken(session);
        case VerificationMethod.backupCode:
          return await _verifyBackupCode(session, code);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying ${method.displayName} code: $e');
      }
      return VerificationResult.failure('Doğrulama hatası: $e');
    }
  }

  /// Verify SMS code
  static Future<VerificationResult> _verifySMSCode(_VerificationSession session, String code) async {
    // In a real implementation, this would verify against Firebase
    // For demonstration, we'll simulate validation
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return VerificationResult.failure('Invalid code format');
    }

    // Simulate successful verification (in reality, this would be a random 6-digit code)
    if (code == '123456' || code == '000000') {
      await _logSecurityEvent(session, 'SMS_VERIFICATION_SUCCESS');
      _sessions.remove(session.sessionId);
      return VerificationResult.success('Code verified successfully');
    }

    return VerificationResult.failure('Invalid code');
  }

  /// Verify TOTP code
  static Future<VerificationResult> _verifyTOTPCode(_VerificationSession session, String code) async {
    if (session.totpSecret == null) {
      return VerificationResult.failure('TOTP secret not found');
    }

    final expectedCode = generateTOTP(session.totpSecret!);
    if (code == expectedCode) {
      await _logSecurityEvent(session, 'TOTP_VERIFICATION_SUCCESS');
      _sessions.remove(session.sessionId);
      return VerificationResult.success('Code verified successfully');
    }

    return VerificationResult.failure('Invalid code');
  }

  /// Verify hardware token (simulated biometric)
  static Future<VerificationResult> _verifyHardwareToken(_VerificationSession session) async {
    try {
      // Simulate biometric authentication
      // In a real implementation, this would use local_auth package
      final didAuthenticate = await _simulateBiometricAuth();

      if (didAuthenticate) {
        await _logSecurityEvent(session, 'HARDWARE_TOKEN_VERIFICATION_SUCCESS');
        _sessions.remove(session.sessionId);
        return VerificationResult.success('Hardware token verified successfully');
      }

      return VerificationResult.failure('Biometric authentication cancelled');
    } catch (e) {
      return VerificationResult.failure('Biometric authentication failed: $e');
    }
  }

  /// Simulate biometric authentication (for demo purposes)
  static Future<bool> _simulateBiometricAuth() async {
    // In a real app, this would prompt for biometric authentication
    // For demo, we'll randomly succeed or fail
    await Future.delayed(const Duration(seconds: 1));
    return DateTime.now().millisecond % 3 != 0; // 66% success rate
  }

  /// Verify backup code
  static Future<VerificationResult> _verifyBackupCode(_VerificationSession session, String code) async {
    // In a real implementation, this would validate against stored backup codes
    // For demonstration, we'll simulate validation
    if (code.length != 8 || !RegExp(r'^[A-Z0-9]{8}$').hasMatch(code)) {
      return VerificationResult.failure('Invalid backup code format');
    }

    // Simulate successful verification with common backup codes
    const validCodes = ['ABC12345', 'BACKUP01', 'EMERGENCY'];
    if (validCodes.contains(code.toUpperCase())) {
      await _logSecurityEvent(session, 'BACKUP_CODE_VERIFICATION_SUCCESS');
      _sessions.remove(session.sessionId);
      return VerificationResult.success('Backup code verified successfully');
    }

    return VerificationResult.failure('Invalid backup code');
  }

  /// Resend verification code for SMS
  static Future<VerificationResult> resendCode(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      return VerificationResult.failure('Session not found');
    }

    if (session.resendAttempts >= _maxResendAttempts) {
      return VerificationResult.failure('Too many resend attempts');
    }

    session.resendAttempts++;

    if (session.method == VerificationMethod.sms) {
      return await _startSMSVerification(
        session.phoneNumber!,
        sessionId,
        DateTime.now().add(_codeExpirationTime).millisecondsSinceEpoch,
      );
    }

    return VerificationResult.failure('Resend not supported for this method');
  }

  /// Generate TOTP code using HMAC-SHA1
  static String generateTOTP(String secret, {int digits = 6, int period = 30}) {
    final key = Base32Decoder.decode(secret.toUpperCase());
    final time = (DateTime.now().millisecondsSinceEpoch / 1000) ~/ period;
    final timeBytes = _int64ToBytes(time);
    
    final hmac = Hmac(sha1, key);
    final hash = hmac.convert(timeBytes).bytes;
    
    final offset = hash[hash.length - 1] & 0xf;
    final code = ((hash[offset] & 0x7f) << 24) |
                 ((hash[offset + 1] & 0xff) << 16) |
                 ((hash[offset + 2] & 0xff) << 8) |
                 (hash[offset + 3] & 0xff);
    
    final mod = pow(10, digits);
    final otp = (code % mod).toString().padLeft(digits, '0');
    
    return otp;
  }

  /// Convert int64 to bytes
  static List<int> _int64ToBytes(int value) {
    return [
      (value >> 56) & 0xff,
      (value >> 48) & 0xff,
      (value >> 40) & 0xff,
      (value >> 32) & 0xff,
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ];
  }

  /// Generate secure random ID
  static String _generateSecureId() {
    final bytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Validate phone number format
  static bool _isValidPhoneNumber(String phoneNumber) {
    // Basic international phone number validation
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Log security event
  static Future<void> _logSecurityEvent(_VerificationSession session, String eventType) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('security_logs').add({
        'userId': user.uid,
        'eventType': eventType,
        'method': session.method.displayName,
        'timestamp': FieldValue.serverTimestamp(),
        'sessionId': session.sessionId,
        'attempts': session.attempts,
        'ipAddress': null, // In production, capture IP address
        'userAgent': null, // In production, capture user agent
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging security event: $e');
      }
    }
  }

  /// Get user's enrolled verification methods
  static Future<List<VerificationMethod>> getEnrolledMethods(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data() as Map<String, dynamic>?;

      if (data == null) return [];

      final methods = <VerificationMethod>[];
      if (data['smsEnabled'] == true) methods.add(VerificationMethod.sms);
      if (data['totpEnabled'] == true) methods.add(VerificationMethod.totp);
      if (data['hardwareTokenEnabled'] == true) methods.add(VerificationMethod.hardwareToken);
      if (data['backupCodesEnabled'] == true) methods.add(VerificationMethod.backupCode);

      return methods;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting enrolled methods: $e');
      }
      return [];
    }
  }

  /// Check if 2FA is enabled for user
  static Future<bool> is2FAEnabled(String userId) async {
    try {
      final methods = await getEnrolledMethods(userId);
      return methods.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking 2FA status: $e');
      }
      return false;
    }
  }

  /// Clean up resources
  static void dispose() {
    _cleanupTimer?.cancel();
    _sessions.clear();
  }
}

/// Internal class to track verification sessions
class _VerificationSession {
  final String sessionId;
  final VerificationMethod method;
  final String? phoneNumber;
  final String? totpSecret;
  final int expiresAt;
  int attempts;
  int resendAttempts;

  _VerificationSession({
    required this.sessionId,
    required this.method,
    this.phoneNumber,
    this.totpSecret,
    required this.expiresAt,
    required this.attempts,
    required this.resendAttempts,
  });

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAt;
}

/// Base32 decoder for TOTP secret processing
class Base32Decoder {
  static const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const List<int> _alphabetMap = [
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 0-15
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 16-31
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // 32-47
    -1, -1, 26, 27, 28, 29, 30, 31, -1, -1, -1, -1, -1, -1, -1, -1, // 48-63
    -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, // 64-79
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, // 80-95
    -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, // 96-111
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, // 112-127
  ];

  static List<int> decode(String input) {
    final cleanInput = input.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
    final output = <int>[];
    var buffer = 0;
    var bitsLeft = 0;

    for (final char in cleanInput.codeUnits) {
      final val = char < 128 ? _alphabetMap[char] : -1;
      if (val == -1) continue;

      buffer = (buffer << 5) | val;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        output.add((buffer >> (bitsLeft - 8)) & 0xff);
        bitsLeft -= 8;
      }
    }

    return output;
  }
}