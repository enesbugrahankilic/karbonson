import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if biometric authentication is available on the device
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (kDebugMode) {
        debugPrint('🔍 Biometric availability check:');
        debugPrint('🔍 Can check biometrics: $isAvailable');
        debugPrint('🔍 Device supported: $isDeviceSupported');
        debugPrint('🔍 Overall available: ${isAvailable && isDeviceSupported}');
      }
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 Biometric availability check error: $e');
      }
      return false;
    }
  }
  
  /// Get list of available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      
      if (kDebugMode) {
        debugPrint('🔍 Available biometrics: ${biometrics.length} types');
        for (final biometric in biometrics) {
          debugPrint('🔍 - $biometric');
        }
      }
      
      return biometrics;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 Error getting available biometrics: $e');
      }
      return [];
    }
  }
  
  /// Check if specific biometric types are available
  static Future<bool> isFingerprintAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }
  
  static Future<bool> isFaceIdAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }
  
  /// Authenticate with biometrics only
  static Future<bool> authenticateWithBiometrics({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyOnly = false,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 Starting biometric authentication');
        debugPrint('🔐 Reason: $localizedReason');
      }

      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Biyometrik Kimlik Doğrulama Gerekli!',
            biometricHint: 'Biyometrik kimlik bilgilerinizi doğrulayın',
            cancelButton: 'İptal',
            goToSettingsButton: 'Ayarlar',
            goToSettingsDescription: 'Biyometrik ayarlarınızı yapılandırmak için lütfen ayarlara gidin.',
            biometricNotRecognized: 'Biyometrik bilgiler tanınmadı. Lütfen tekrar deneyin.',
          ),
          IOSAuthMessages(
            cancelButton: 'İptal',
            goToSettingsButton: 'Ayarlar',
            goToSettingsDescription: 'Biyometrik ayarlarınızı yapılandırmak için lütfen ayarlara gidin.',
            lockOut: 'Biyometrik kimlik doğrulama geçici olarak devre dışı. Lütfen cihazınızı kilitleyin ve açın.',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyOnly,
        ),
      );

      if (kDebugMode) {
        debugPrint('🔐 Biometric authentication result: $result');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 Biometric authentication error: $e');
        debugPrint('🚨 Error type: ${e.runtimeType}');
      }
      return false;
    }
  }
  
  /// Authenticate with biometrics OR fallback to device credential
  static Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyOnly = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('Biyometrik kimlik doğrulama mevcut değil');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Kimlik Doğrulama Gerekli!',
            biometricHint: 'Kimlik bilgilerinizi doğrulayın',
            cancelButton: 'İptal',
            goToSettingsButton: 'Ayarlar',
            goToSettingsDescription: 'Kimlik doğrulama ayarlarınızı yapılandırmak için lütfen ayarlara gidin.',
            biometricNotRecognized: 'Biyometrik bilgiler tanınmadı. Lütfen tekrar deneyin.',
          ),
          IOSAuthMessages(
            cancelButton: 'İptal',
            goToSettingsButton: 'Ayarlar',
            goToSettingsDescription: 'Kimlik doğrulama ayarlarınızı yapılandırmak için lütfen ayarlara gidin.',
            lockOut: 'Kimlik doğrulama geçici olarak devre dışı. Lütfen cihazınızı kilitleyin ve açın.',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: false, // Allow fallback to device credentials
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyOnly,
        ),
      );
    } catch (e) {
      debugPrint('Kimlik doğrulama hatası: $e');
      return false;
    }
  }
  
  /// Stop authentication process
  static Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Kimlik doğrulama durdurma hatası: $e');
      }
    }
  }
  
  /// Get user-friendly biometric type name
  static Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Parmak İzi';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'İris Tarama';
    } else {
      return 'Biyometrik Kimlik Doğrulama';
    }
  }
}