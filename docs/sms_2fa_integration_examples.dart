// ignore_for_file: uri_does_not_exist, undefined_identifier, undefined_method, undefined_named_parameter, avoid_print, dead_code
import 'package:flutter/material.dart';
import 'pages/two_factor_auth_page.dart';
import 'services/phone_number_validator.dart';
import 'services/email_otp_service.dart';

/// SMS 2FA Entegrasyon Kılavuzu
/// 
/// Karbonson uygulamasında SMS tabanlı 2FA sistemi kullanma adımları

// ============================================================================
// 1. PROFIL SAYFASINDA 2FA AYARLA (Profile Page)
// ============================================================================

class Example2FAProfileIntegration {
  /// Profil sayfasında 2FA buton ekle
  static Widget buildTwoFactorButton(BuildContext context, String userId) {
    return ElevatedButton.icon(
      onPressed: () => _navigateTo2FAPage(context, userId),
      icon: const Icon(Icons.security),
      label: const Text('2FA Ayarla'),
    );
  }

  static void _navigateTo2FAPage(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwoFactorAuthPage(
          userId: userId,
          initialPhoneNumber: null, // Veya kaydedilmiş telefon
          onVerificationSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('2FA başarıyla etkinleştirildi! ✓')),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// 2. GİRİŞ SAYFASINDA 2FA DOĞRULAMA (Login Page)
// ============================================================================

class Example2FALoginIntegration {
  /// Şifre doğrulanıp 2FA aktifse 2FA sayfasına yönlendir
  static Future<void> handleLoginWith2FA(
    BuildContext context,
    String userId,
    String userPhone,
  ) async {
    // 1. Şifre doğrulama (normal login flow)
    bool passwordValid = true; // Your password validation logic
    
    if (!passwordValid) {
      return;
    }

    // 2. User 2FA aktif mi kontrol et
    bool user2FAEnabled = true; // Firestore'dan oku
    
    if (user2FAEnabled) {
      // 3. 2FA sayfasına yönlendir
      if (context.mounted) {
        final verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorAuthPage(
              userId: userId,
              initialPhoneNumber: userPhone,
              onVerificationSuccess: () {
                // 2FA doğrulama başarılı
              },
            ),
          ),
        );

        if (verified == true) {
          // 4. Giriş tamamla
          if (context.mounted) {
            _completeLogin(context, userId);
          }
        }
      }
    } else {
      // 2FA yok, direkt giriş yap
      _completeLogin(context, userId);
    }
  }

  static void _completeLogin(BuildContext context, String userId) {
    // Ana sayfaya git
    // Navigator.pushReplacementNamed(context, '/home');
  }
}

// ============================================================================
// 3. TELEFON NUMARASI DOĞRULAMA (Phone Validation)
// ============================================================================

class Example3PhoneNumberValidation {
  /// Telefon numarasının formatını kontrol et
  static void validatePhoneNumber(String phoneNumber) {
    // Basit doğrulama
    if (PhoneNumberValidator.isValid(phoneNumber)) {
      print('✅ Geçerli telefon numarası');
    } else {
      print('❌ Geçersiz telefon numarası');
      return;
    }

    // SMS uyumluluğu kontrol et
    if (PhoneNumberValidator.isSMSCompatible(phoneNumber)) {
      print('✅ SMS gönderilebilir');
    } else {
      print('❌ SMS gönderilemez');
      return;
    }

    // E.164 formatına dönüştür (SMS için)
    final e164 = PhoneNumberValidator.toE164(phoneNumber);
    print('📱 E.164 Formatı: $e164');

    // Görüntüleme için biçimlendir
    final formatted = PhoneNumberValidator.format(phoneNumber);
    print('🎨 Biçimlendirilmiş: $formatted');
  }

  /// Desteklenen Türkiye Formatları
  static void demonstrateFormats() {
    final formats = [
      '05551234567',        // Standart
      '+905551234567',      // Uluslararası
      '5551234567',         // Kısaltılmış
      '+90 555 123 4567',   // Boşluklu
      '0555 123 4567',      // Türkiye formatı
    ];

    for (var format in formats) {
      final isValid = PhoneNumberValidator.isValid(format);
      print('$format → ${isValid ? '✅' : '❌'}');
    }
  }
}

// ============================================================================
// 4. SMS OTP GÖNDERME (Send SMS OTP)
// ============================================================================

class Example4SendSmsOtp {
  /// SMS OTP kodu gönder
  static Future<void> sendSmsOtp(String phoneNumber) async {
    try {
      // 1. Telefon numarasını doğrula
      if (!PhoneNumberValidator.isValid(phoneNumber)) {
        print('❌ Geçersiz telefon numarası');
        return;
      }

      // 2. E.164 formatına dönüştür
      final e164Phone = PhoneNumberValidator.toE164(phoneNumber);
      if (e164Phone == null) {
        print('❌ Telefon numarası dönüştürülemedi');
        return;
      }

      // 3. SMS OTP kodu gönder
      final result = await EmailOtpService.sendSmsOtpCode(
        phoneNumber: e164Phone,
        purpose: 'two_factor', // Veya 'phone_verification'
      );

      if (result.isSuccess) {
        print('✅ SMS gönderildi: ${result.message}');
        print('📱 Telefon: ${result.email}');
        // UI güncelle: Geri sayım başlat, kodu giriş alanını göster
      } else {
        print('❌ SMS gönderilemedi: ${result.message}');
        // Hata mesajını UI'de göster
      }
    } catch (e) {
      print('❌ Hata: $e');
    }
  }
}

// ============================================================================
// 5. SMS OTP KODU DOĞRULAMA (Verify SMS OTP)
// ============================================================================

class Example5VerifySmOtp {
  /// SMS OTP kodu doğrula
  static Future<void> verifySmsOtp(
    String phoneNumber,
    String code,
  ) async {
    try {
      // 1. Doğrula
      final result = await EmailOtpService.verifySmsOtpCode(
        phoneNumber: phoneNumber,
        code: code,
      );

      if (result.isValid) {
        print('✅ Doğrulama başarılı!');
        print('📧 Email: ${result.email}');
        // 2FA tamamlandı callback çalıştır

      } else if (result.isExpired) {
        print('❌ Kod süresi dolmuş');
        // Yeni kod isteyin mesajı göster

      } else if (result.isUsed) {
        print('❌ Kod zaten kullanıldı');
        // Yeni kod isteyin mesajı göster

      } else {
        print('❌ Doğrulama başarısız: ${result.message}');
        // Hata mesajını göster
      }
    } catch (e) {
      print('❌ Hata: $e');
    }
  }

  /// Kod süresi dolmuşsa yeniden gönder
  static Future<void> resendCode(String phoneNumber) async {
    print('🔄 Yeni SMS kodu gönderiliyor...');
    await Example4SendSmsOtp.sendSmsOtp(phoneNumber);
  }
}

// ============================================================================
// 6. CUSTOM 2FA DIALOG (Custom Integration)
// ============================================================================

class Example6CustomTwoFactorDialog {
  /// Kendi 2FA dialog'unu oluştur
  static void showCustom2FADialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('2FA Doğrulaması'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SMS ile doğrulama kodu alacaksınız'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '05551234567'),
              onChanged: (value) {
                // Real-time doğrulama
                final isValid = PhoneNumberValidator.isValid(value);
                print('Telefon: $value → ${isValid ? '✅' : '❌'}');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // SMS OTP gönder
              Navigator.pop(context);
            },
            child: const Text('SMS Gönder'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. GRADUAl ROLLOUT (Aşamalı Yayınlama)
// ============================================================================

class Example7GradualRollout {
  /// 2FA'yı aşamalı olarak yayınla
  /// %25 → %50 → %75 → %100
  static bool should2FABeActive(String userId) {
    // Firestore'dan user'ın 2FA ayarını oku
    // Remote Config ile A/B test yap
    return true; // Veya user preference'dan oku
  }

  /// Feature flag ile kontrol et
  static bool is2FAEnabled() {
    // Remote Config kullan
    // return firebaseRemoteConfig.getBool('enable_2fa');
    return true;
  }
}

// ============================================================================
// 8. HATA YÖNETME (Error Handling)
// ============================================================================

class Example8ErrorHandling {
  static Future<void> sendSmsWithErrorHandling(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      final result = await EmailOtpService.sendSmsOtpCode(
        phoneNumber: phoneNumber,
        purpose: 'two_factor',
      );

      if (result.isSuccess) {
        // Başarı
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Hata
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Exception
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================================================
// 9. TESTING (Test Kodları)
// ============================================================================

void testExamples() {
  // Test: Telefon numarası doğrulaması
  Example3PhoneNumberValidation.validatePhoneNumber('05551234567');
  Example3PhoneNumberValidation.demonstrateFormats();

  // Test: SMS OTP gönderimi
  // await Example4SendSmsOtp.sendSmsOtp('05551234567');

  // Test: SMS OTP doğrulaması
  // await Example5VerifySmOtp.verifySmsOtp('05551234567', '123456');
}

// ============================================================================
// 10. PRODUCTION CHECKLIST
// ============================================================================

/// Production'a çıkmadan önce kontrol et:
/// 
/// ✅ SMS API (Twilio, Firebase SMS, vb.) entegre et
///    → lib/services/email_otp_service.dart :: _sendSmsWithCode()
/// 
/// ✅ Firestore Security Rules yapılandır
///    → sms_otp_codes koleksiyonu read/write kuralları
/// 
/// ✅ Environment variables konfigüre et
///    → SMS API credentials (TWILIO_ACCOUNT_SID, vb.)
/// 
/// ✅ Rate limiting ekle
///    → Maksimum SMS gönderimi: 3 denemesi / 15 dakika
/// 
/// ✅ Monitoring ve logging kur
///    → Başarılı/başarısız 2FA denemeleri takip et
/// 
/// ✅ User education
///    → 2FA avantajlarını kullanıcılara açıkla
/// 
/// ✅ Fallback options
///    → Email + SMS kombinasyonu, Recovery codes
/// 
/// ✅ Testing
///    → Unit tests, Integration tests, E2E tests

void main() {
  // Test kodlarını çalıştır
  testExamples();
}
