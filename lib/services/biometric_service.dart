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
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Biyometri kontrolü hatası: $e');
      return false;
    }
  }
  
  /// Get list of available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Mevcut biyometri türlerini alma hatası: $e');
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
      return await _localAuth.authenticate(
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
    } catch (e) {
      print('Biyometrik kimlik doğrulama hatası: $e');
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
      print('Kimlik doğrulama hatası: $e');
      return false;
    }
  }
  
  /// Stop authentication process
  static Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('Kimlik doğrulama durdurma hatası: $e');
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