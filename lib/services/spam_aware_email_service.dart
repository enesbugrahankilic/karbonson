import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// E-postaların spam filtrelerine takılmaması için optimizasyon servisi - HIZLANDIRILMIŞ VERSİYON
class SpamAwareEmailService {
  // ⚡ COOLDOWN SÜRESİ 1 DAKİKADAN 15 SANİYEYE DÜŞÜRÜLDÜ
  static const Duration _emailCooldown = Duration(seconds: 15);
  static final Map<String, DateTime> _lastEmailSent = {};

  // 🚀 PERFORMANCE OPTİMİZASYONU - CACHE EKLEMESİ
  static final Map<String, bool> _emailSendCache = {};
  static const Duration _cacheTimeout = Duration(seconds: 30);

  /// ⚡ HIZLANDIRILMIŞ Rate limiting ile güvenli şifre sıfırlama e-postası gönderir
  static Future<bool> sendPasswordResetSpamSafe({
    required String email,
    required BuildContext context,
  }) async {
    // 🚀 CACHE KONTROLÜ - HIZLANDIRMA
    final cacheKey = 'reset_$email';
    if (_emailSendCache.containsKey(cacheKey)) {
      final cachedResult = _emailSendCache[cacheKey];
      if (cachedResult == true) {
        _showCachedSuccessMessage(context);
        return true;
      }
    }

    // Rate limiting kontrolü (15 saniye cooldown)
    if (!_canSendEmail(email)) {
      _showCooldownMessage(context);
      return false;
    }

    try {
      // E-posta adresini normalize et
      final normalizedEmail = _normalizeEmail(email);

      // ⚡ PARALEL İŞLEM - Firebase email gönderimini hızlandır
      await Future.wait([
        FirebaseAuth.instance.sendPasswordResetEmail(email: normalizedEmail),
        _updateCacheAsync(cacheKey, true),
      ]);

      _recordEmailSent(email);
      _showSuccessMessage(context);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e, context);
      // 🚀 HATA DURUMUNDA DA CACHE'İ GÜNCELLE
      await _updateCacheAsync('reset_$email', false);
      return false;
    }
  }

  /// 🚀 CACHE İÇİN ASYNC GÜNCELLEME
  static Future<void> _updateCacheAsync(String cacheKey, bool success) async {
    _emailSendCache[cacheKey] = success;
    // Cache'i 30 saniye sonra temizle
    Future.delayed(_cacheTimeout, () {
      _emailSendCache.remove(cacheKey);
    });
  }

  /// 🚀 CACHE'DEN BAŞARILI MESAJI GÖSTER
  static void _showCachedSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('E-posta az önce gönderildi - cache\'den yüklendi ⚡'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// ⚡ HIZLANDIRILMIŞ E-posta doğrulama gönderimi (spam safe)
  static Future<bool> sendEmailVerificationSpamSafe({
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorMessage(context, 'Kullanıcı oturumu bulunamadı');
      return false;
    }

    // 🚀 CACHE KONTROLÜ
    final cacheKey = 'verify_${user.email}';
    if (_emailSendCache.containsKey(cacheKey)) {
      _showCachedSuccessMessage(context);
      return true;
    }

    // Rate limiting kontrolü (15 saniye cooldown)
    if (!_canSendEmail(user.email!)) {
      _showCooldownMessage(context);
      return false;
    }

    try {
      // ⚡ PARALEL İŞLEM - Email gönderimi ve cache güncelleme
      await Future.wait([
        user.sendEmailVerification(),
        _updateCacheAsync(cacheKey, true),
      ]);

      _recordEmailSent(user.email!);
      _showSuccessMessage(context, 'Doğrulama e-postası gönderildi ⚡');
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e, context);
      await _updateCacheAsync(cacheKey, false);
      return false;
    }
  }

  /// E-posta adresini normalize eder
  static String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  /// E-posta gönderim sıklığını kontrol eder
  static bool _canSendEmail(String email) {
    final lastSent = _lastEmailSent[email];
    if (lastSent == null) return true;

    return DateTime.now().difference(lastSent) >= _emailCooldown;
  }

  /// E-posta gönderimini kaydeder
  static void _recordEmailSent(String email) {
    _lastEmailSent[email] = DateTime.now();
  }

  /// Başarı mesajı gösterir
  static void _showSuccessMessage(BuildContext context,
      [String? customMessage]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(customMessage ?? 'E-posta başarıyla gönderildi'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Soğutma süresi mesajı gösterir (15 saniye)
  static void _showCooldownMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Güvenlik nedeniyle lütfen 15 saniye bekleyin ⚡'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Hata mesajı gösterir
  static void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  /// Firebase hatalarını spam context'inde işler
  static void _handleFirebaseError(
      FirebaseAuthException e, BuildContext context) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'Bu e-posta adresine kayıtlı kullanıcı bulunamadı';
        break;
      case 'invalid-email':
        message = 'Geçerli bir e-posta adresi girin';
        break;
      case 'too-many-requests':
        message = 'Çok fazla deneme yaptınız. Güvenlik için 5 dakika bekleyin';
        break;
      case 'network-request-failed':
        message = 'İnternet bağlantınızı kontrol edin';
        break;
      case 'email-already-in-use':
        message = 'Bu e-posta adresi zaten kullanımda';
        break;
      case 'weak-password':
        message = 'Şifreniz çok zayıf. Daha güçlü bir şifre seçin';
        break;
      case 'operation-not-allowed':
        message = 'Bu işlem şu anda etkinleştirilmemiş';
        break;
      case 'invalid-action-code':
        message = 'Geçersiz veya süresi dolmuş bağlantı';
        break;
      case 'expired-action-code':
        message = 'Bağlantının süresi dolmuş. Yeni bir bağlantı isteyin';
        break;
      case 'requires-recent-login':
        message = 'Bu işlem için tekrar giriş yapmanız gerekiyor';
        break;
      default:
        message = 'Bir hata oluştu: ${e.message}';
    }

    _showErrorMessage(context, message);
  }

  /// E-posta gönderim istatistiklerini getirir
  static Map<String, dynamic> getEmailStats() {
    final now = DateTime.now();
    final last24Hours = now.subtract(Duration(hours: 24));

    final recentSends = _lastEmailSent.values
        .where((timestamp) => timestamp.isAfter(last24Hours))
        .length;

    return {
      'total_unique_emails': _lastEmailSent.keys.length,
      'last_24h_sends': recentSends,
      'cooldown_period_minutes': _emailCooldown.inMinutes,
    };
  }

  /// E-posta gönderim geçmişini temizler (admin function)
  static void clearEmailHistory() {
    _lastEmailSent.clear();
  }
}

/// Spam riskini analiz eden servis
class SpamRiskAnalyzer {
  /// E-posta içeriğini spam riski açısından analiz eder
  static SpamAnalysis analyzeContent({
    required String subject,
    required String body,
  }) {
    final issues = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];

    // Subject line analizi
    _analyzeSubject(subject, issues, warnings, suggestions);

    // Body analizi
    _analyzeBody(body, issues, warnings, suggestions);

    // HTML/Düz metin oranı
    _analyzeHtmlRatio(body, warnings, suggestions);

    // Genel risk skoru hesapla
    final riskScore = _calculateRiskScore(issues, warnings);

    return SpamAnalysis(
      riskScore: riskScore,
      issues: issues,
      warnings: warnings,
      suggestions: suggestions,
      riskLevel: _determineRiskLevel(riskScore),
    );
  }

  static void _analyzeSubject(String subject, List<String> issues,
      List<String> warnings, List<String> suggestions) {
    // Aşırı ünlem işareti
    if (subject.contains('!!')) {
      issues.add('Konu satırında çok fazla ünlem işareti (!!) kullanılmış');
      suggestions.add('Ünlem işareti sayısını 1\'e düşürün');
    }

    // Tamamen büyük harf
    if (subject == subject.toUpperCase() && subject.isNotEmpty) {
      issues.add('Konu satırı tamamen büyük harfle yazılmış');
      suggestions.add('Normal büyük/küçük harf kullanımına geçin');
    }

    // Spam tetikleyici kelimeler
    final spamWords = ['ACİL', 'ÜCRETSİZ', 'HEMEN', 'SON FIRSAT', 'MİLYONER'];
    for (final word in spamWords) {
      if (subject.toUpperCase().contains(word)) {
        issues.add('Spam tetikleyici kelime tespit edildi: $word');
        suggestions
            .add('"$word" kelimesini daha nötr bir ifade ile değiştirin');
      }
    }

    // Konu uzunluğu
    if (subject.length > 70) {
      warnings.add('Konu satırı çok uzun (70 karakter üzeri)');
      suggestions.add('Konu satırını 50-60 karakter arası tutun');
    }

    if (subject.length < 10) {
      warnings.add('Konu satırı çok kısa');
      suggestions.add('Konu satırını en az 20 karakter yapın');
    }
  }

  static void _analyzeBody(String body, List<String> issues,
      List<String> warnings, List<String> suggestions) {
    // Spam tetikleyici kelimeler
    final spamWords = {
      'ACİL': 'Acil durumlarda daha resmi dil kullanın',
      'ÜCRETSİZ': 'Bedava kelimesi yerine "mevcut" kullanın',
      'HEMEN': 'Hemen yerine "hızlı" kullanın',
      'SON FIRSAT': 'Süre kısıtlaması varsa daha açık belirtin',
      '\$': 'Para sembolü yerine "TL" yazın',
      '€': 'Euro sembolü yerine "EUR" yazın',
    };

    final upperBody = body.toUpperCase();
    for (final entry in spamWords.entries) {
      if (upperBody.contains(entry.key)) {
        issues.add('Spam tetikleyici ifade: ${entry.key}');
        suggestions.add(entry.value);
      }
    }

    // Çok fazla büyük harf
    final uppercaseRatio = upperBody.replaceAll(RegExp(r'[^A-Z]'), '').length /
        upperBody.replaceAll(RegExp(r'[^A-Z]'), '').length;
    if (uppercaseRatio > 0.3) {
      warnings.add(
          'Metinde çok fazla büyük harf kullanımı (%${(uppercaseRatio * 100).toInt()})');
      suggestions.add('Normal yazım stilini benimseyin');
    }

    // Çok fazla link
    final linkCount = RegExp(r'https?://').allMatches(body).length;
    if (linkCount > 3) {
      issues.add('Çok fazla bağlantı tespit edildi ($linkCount adet)');
      suggestions.add('Bağlantı sayısını 1-2\'ye düşürün');
    }
  }

  static void _analyzeHtmlRatio(
      String body, List<String> warnings, List<String> suggestions) {
    final htmlTags = RegExp(r'<[^>]+>').allMatches(body).length;
    final textContent = body.replaceAll(RegExp(r'<[^>]+>'), '');
    final textLength = textContent.trim().length;

    if (textLength == 0) return;

    final htmlRatio = htmlTags / textLength;

    if (htmlRatio > 0.5) {
      warnings.add('Çok fazla HTML etiketi kullanılmış');
      suggestions.add('HTML kullanımını azaltın, daha fazla düz metin ekleyin');
    }

    if (htmlRatio < 0.1) {
      warnings.add('Çok az HTML etiketi (görsel sunumu zayıf)');
      suggestions.add('Daha iyi görsel sunum için HTML kullanın');
    }
  }

  static double _calculateRiskScore(
      List<String> issues, List<String> warnings) {
    final issueScore = issues.length * 3.0;
    final warningScore = warnings.length * 1.0;
    return issueScore + warningScore;
  }

  static SpamRiskLevel _determineRiskLevel(double score) {
    if (score >= 10) return SpamRiskLevel.HIGH;
    if (score >= 5) return SpamRiskLevel.MEDIUM;
    return SpamRiskLevel.LOW;
  }
}

class SpamAnalysis {
  final double riskScore;
  final List<String> issues;
  final List<String> warnings;
  final List<String> suggestions;
  final SpamRiskLevel riskLevel;

  SpamAnalysis({
    required this.riskScore,
    required this.issues,
    required this.warnings,
    required this.suggestions,
    required this.riskLevel,
  });

  bool get isHighRisk => riskLevel == SpamRiskLevel.HIGH;
  bool get isMediumRisk => riskLevel == SpamRiskLevel.MEDIUM;
  bool get isLowRisk => riskLevel == SpamRiskLevel.LOW;

  String get riskDescription {
    switch (riskLevel) {
      case SpamRiskLevel.HIGH:
        return 'Yüksek spam riski - Göndermeyin';
      case SpamRiskLevel.MEDIUM:
        return 'Orta spam riski - İyileştirme önerilir';
      case SpamRiskLevel.LOW:
        return 'Düşük spam riski - Güvenle gönderebilirsiniz';
    }
  }
}

enum SpamRiskLevel { LOW, MEDIUM, HIGH }

/// E-posta gönderimini monitör eden servis
class EmailMonitoringService {
  static final List<EmailSendLog> _logs = [];

  static void logEmailSend({
    required String email,
    required EmailType type,
    required bool success,
    String? errorCode,
    String? errorMessage,
  }) {
    _logs.add(EmailSendLog(
      email: email,
      type: type,
      success: success,
      timestamp: DateTime.now(),
      errorCode: errorCode,
      errorMessage: errorMessage,
    ));

    // Sadece son 1000 log'u tut
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
  }

  static EmailStats getStats() {
    final now = DateTime.now();
    final last24h = now.subtract(Duration(hours: 24));
    final last7d = now.subtract(Duration(days: 7));

    final last24hLogs =
        _logs.where((log) => log.timestamp.isAfter(last24h)).toList();
    final last7dLogs =
        _logs.where((log) => log.timestamp.isAfter(last7d)).toList();

    final successful24h = last24hLogs.where((log) => log.success).length;
    final successful7d = last7dLogs.where((log) => log.success).length;

    return EmailStats(
      totalSent: _logs.length,
      last24hSent: last24hLogs.length,
      last7dSent: last7dLogs.length,
      last24hSuccessRate: last24hLogs.isNotEmpty
          ? (successful24h / last24hLogs.length * 100)
          : 0,
      last7dSuccessRate:
          last7dLogs.isNotEmpty ? (successful7d / last7dLogs.length * 100) : 0,
      uniqueEmails: _logs.map((log) => log.email).toSet().length,
    );
  }

  static List<EmailSendLog> getRecentFailures({int limit = 10}) {
    return _logs
        .where((log) => !log.success)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  static void clearLogs() {
    _logs.clear();
  }
}

class EmailSendLog {
  final String email;
  final EmailType type;
  final bool success;
  final DateTime timestamp;
  final String? errorCode;
  final String? errorMessage;

  EmailSendLog({
    required this.email,
    required this.type,
    required this.success,
    required this.timestamp,
    this.errorCode,
    this.errorMessage,
  });
}

class EmailStats {
  final int totalSent;
  final int last24hSent;
  final int last7dSent;
  final double last24hSuccessRate;
  final double last7dSuccessRate;
  final int uniqueEmails;

  EmailStats({
    required this.totalSent,
    required this.last24hSent,
    required this.last7dSent,
    required this.last24hSuccessRate,
    required this.last7dSuccessRate,
    required this.uniqueEmails,
  });
}

enum EmailType { PASSWORD_RESET, EMAIL_VERIFICATION, WELCOME, OTHER }
