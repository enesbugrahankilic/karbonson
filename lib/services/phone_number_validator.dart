import 'package:flutter/foundation.dart';

/// SMS formatına uygun telefon numarası validatörü
/// E.164 formatı: +[1-9]{1-3}[0-9]{1,14}
class PhoneNumberValidator {
  // Regex pattern E.164 formatı için
  static final RegExp _e164Pattern = RegExp(r'^\+[1-9]\d{1,14}$');
  
  // Türkiye'ye özgü pattern
  static final RegExp _turkeyPattern = RegExp(r'^(\+90|0)?[1-9][0-9]{9}$');

  /// E.164 formatında geçerli bir numaradır
  static bool isValidE164(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return _e164Pattern.hasMatch(clean);
  }

  /// Türkiye formatında geçerli bir numaradır
  static bool isValidTurkey(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return _turkeyPattern.hasMatch(clean);
  }

  /// Telefon numarasını E.164 formatına dönüştür
  static String? toE164(String phoneNumber, {String countryCode = '+90'}) {
    try {
      var clean = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      
      // Türkiye numarası mı kontrol et
      if (clean.startsWith('0')) {
        clean = clean.substring(1); // Başındaki 0'ı kaldır
      }
      
      if (clean.startsWith('90')) {
        clean = clean.substring(2); // Başındaki 90'ı kaldır
      }
      
      if (clean.startsWith('+')) {
        // Zaten uluslararası formatında
        if (_e164Pattern.hasMatch(clean)) {
          return clean;
        }
        return null;
      }
      
      // Ülke kodu ekle
      final e164 = '$countryCode$clean';
      
      if (_e164Pattern.hasMatch(e164)) {
        return e164;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Telefon numarası dönüşüm hatası: $e');
      }
      return null;
    }
  }

  /// Telefon numarasının biçimlendirilmiş versiyonu
  static String format(String phoneNumber) {
    var clean = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // E.164 formatına dönüştür
    final e164 = toE164(clean);
    if (e164 == null) return phoneNumber;
    
    // Türkiye numarası mı kontrol et
    if (e164.startsWith('+90')) {
      final lastNine = e164.substring(3); // +90 sonrasını al
      if (lastNine.length == 10) {
        return '+90 (${lastNine.substring(0, 3)}) ${lastNine.substring(3, 6)}-${lastNine.substring(6)}';
      }
    }
    
    // Genel E.164 formatı
    return e164;
  }

  /// Telefon numarasının geçerli olup olmadığını kontrol et
  /// desteklenen formlar: +905551234567, 05551234567, 5551234567, +90 (555) 123-4567, etc.
  static bool isValid(String phoneNumber, {bool acceptTurkeyOnly = false}) {
    if (phoneNumber.isEmpty) return false;
    
    if (acceptTurkeyOnly) {
      return isValidTurkey(phoneNumber);
    }
    
    // E.164 formatı dene
    if (isValidE164(phoneNumber)) {
      return true;
    }
    
    // E.164'e dönüştürmeyi dene
    final e164 = toE164(phoneNumber);
    return e164 != null;
  }

  /// Telefon numarasından ülke kodunu çıkar
  static String? extractCountryCode(String phoneNumber) {
    final clean = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!clean.startsWith('+')) {
      return null;
    }
    
    // + sonrasından sabit olmayan ilk rakamı bulana kadar oku
    var countryCode = '+';
    for (int i = 1; i < clean.length; i++) {
      if (clean[i] == '0' && i > 1) break; // Ülke kodunda 0 ile başlayan kısım olmaz
      countryCode += clean[i];
    }
    
    return countryCode;
  }

  /// SMS gönderimi için uyumlu mu kontrol et
  static bool isSMSCompatible(String phoneNumber) {
    // SMS gönderimi için E.164 formatı gerekli
    return isValidE164(phoneNumber) || (toE164(phoneNumber) != null);
  }
}
