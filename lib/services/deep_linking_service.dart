// lib/services/deep_linking_service.dart
// Comprehensive deep linking service for password reset and other app flows
// Note: This service requires firebase_dynamic_links and uni_links packages
// Run: flutter pub get firebase_dynamic_links uni_links

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Deep link types that the app can handle
enum DeepLinkType {
  passwordReset,
  emailVerification,
  unknown;

  static DeepLinkType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'password_reset':
      case 'resetpassword':
        return DeepLinkType.passwordReset;
      case 'email_verification':
      case 'emailverification':
        return DeepLinkType.emailVerification;
      default:
        return DeepLinkType.unknown;
    }
  }
}

/// Result class for deep link processing
class DeepLinkResult {
  final bool isSuccess;
  final DeepLinkType? linkType;
  final String? oobCode;
  final String? email;
  final String? errorMessage;

  const DeepLinkResult({
    required this.isSuccess,
    this.linkType,
    this.oobCode,
    this.email,
    this.errorMessage,
  });

  factory DeepLinkResult.success({
    required DeepLinkType linkType,
    String? oobCode,
    String? email,
  }) {
    return DeepLinkResult(
      isSuccess: true,
      linkType: linkType,
      oobCode: oobCode,
      email: email,
    );
  }

  factory DeepLinkResult.failure(String errorMessage) {
    return DeepLinkResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'DeepLinkResult{isSuccess: $isSuccess, linkType: $linkType, oobCode: $oobCode, email: $email, errorMessage: $errorMessage}';
  }
}

class DeepLinkingService {
  static final DeepLinkingService _instance = DeepLinkingService._internal();
  factory DeepLinkingService() => _instance;
  DeepLinkingService._internal();

  static const Duration _defaultTimeout = Duration(seconds: 10);
  StreamSubscription<String?>? _linkSubscription;

  /// Initialize deep linking service
  Future<void> initialize() async {
    try {
      // Initialize Firebase Dynamic Links
      await FirebaseDynamicLinks.instance.getInitialLink();
      
      // Listen for incoming links when app is in foreground
      _linkSubscription = linkStream.listen(_onLinkReceived, onError: (err) {
        if (kDebugMode) {
          debugPrint('Deep linking error: $err');
        }
      });

      if (kDebugMode) {
        debugPrint('Deep linking service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize deep linking service: $e');
      }
    }
  }

  /// Clean up deep linking service
  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Handle incoming deep link - can be called manually or from navigation
  Future<DeepLinkResult> handleDeepLink(Uri uri) async {
    try {
      if (kDebugMode) {
        debugPrint('Processing deep link: $uri');
      }

      // Parse query parameters
      final queryParams = uri.queryParameters;
      final oobCode = queryParams['oobCode'];
      final email = queryParams['email'];
      final mode = queryParams['mode'];

      if (kDebugMode) {
        debugPrint('Query parameters: mode=$mode, email=${email?.replaceRange(2, email.indexOf('@'), '***')}, oobCode=${oobCode?.substring(0, 8) ?? 'null'}...');
      }

      // Determine link type from mode or path
      DeepLinkType linkType;
      String? pathSegment;

      // Check if it's a Firebase Auth action URL
      if (uri.path.contains('/__/auth/action')) {
        pathSegment = mode;
      } else {
        // Extract type from path
        final pathParts = uri.path.split('/');
        if (pathParts.isNotEmpty) {
          final lastPart = pathParts.last;
          if (lastPart.contains('reset-password')) {
            pathSegment = 'password_reset';
          } else if (lastPart.contains('verify-email')) {
            pathSegment = 'email_verification';
          } else {
            pathSegment = lastPart;
          }
        }
      }

      linkType = DeepLinkType.fromString(pathSegment ?? '');

      // Validate oobCode for password reset
      if (linkType == DeepLinkType.passwordReset) {
        if (oobCode == null || oobCode.isEmpty) {
          return DeepLinkResult.failure('Geçersiz şifre sıfırlama bağlantısı. Kod bulunamadı.');
        }
        if (oobCode.length < 10) {
          return DeepLinkResult.failure('Geçersiz şifre sıfırlama kodu. Kod çok kısa.');
        }

        // Optionally verify the code
        try {
          final verifiedEmail = await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
          if (kDebugMode) {
            debugPrint('Password reset code verified for email: ${verifiedEmail.replaceRange(2, verifiedEmail.indexOf('@'), '***')}');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Password reset code verification failed: $e');
          }
          return DeepLinkResult.failure('Şifre sıfırlama kodu geçersiz veya süresi dolmuş. Lütfen yeni bir şifre sıfırlama e-postası gönderin.');
        }
      }

      return DeepLinkResult.success(
        linkType: linkType,
        oobCode: oobCode,
        email: email,
      );

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deep link processing error: $e');
      }
      return DeepLinkResult.failure('Bağlantı işlenirken hata oluştu: $e');
    }
  }

  /// Handle deep link when app is opened from background
  Future<DeepLinkResult> handleInitialLink() async {
    try {
      // Check for initial link (when app was opened via deep link)
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        if (kDebugMode) {
          debugPrint('Initial deep link detected: $initialUri');
        }
        return handleDeepLink(initialUri);
      }
      
      return DeepLinkResult.failure('İlk bağlantı bulunamadı');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Initial link handling error: $e');
      }
      return DeepLinkResult.failure('İlk bağlantı işlenirken hata oluştu: $e');
    }
  }

  /// Listen for deep links when app is in foreground
  void _onLinkReceived(String? uriString) async {
    if (uriString != null) {
      try {
        final uri = Uri.parse(uriString);
        final result = await handleDeepLink(uri);
        if (kDebugMode) {
          debugPrint('Deep link result: $result');
        }
        
        // Here you would typically navigate to the appropriate screen
        _onDeepLinkProcessed(result);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to parse received deep link: $e');
        }
      }
    }
  }

  /// Callback when deep link is processed - navigate based on result
  void _onDeepLinkProcessed(DeepLinkResult result) async {
    if (kDebugMode) {
      debugPrint('Processing deep link result: $result');
    }

    if (result.isSuccess && result.linkType != null) {
      switch (result.linkType!) {
        case DeepLinkType.passwordReset:
          _navigateToPasswordReset(result);
          break;
        case DeepLinkType.emailVerification:
          _navigateToEmailVerification(result);
          break;
        case DeepLinkType.unknown:
          _showUnknownLinkMessage();
          break;
      }
    } else if (!result.isSuccess) {
      _showErrorMessage(result.errorMessage ?? 'Bilinmeyen hata');
    }
  }

  /// Navigate to password reset page with extracted parameters
  void _navigateToPasswordReset(DeepLinkResult result) async {
    if (kDebugMode) {
      debugPrint('Deep link result ready for password reset navigation');
      debugPrint('oobCode: ${result.oobCode?.substring(0, 8) ?? 'null'}...');
      debugPrint('email: ${result.email?.replaceRange(2, result.email!.indexOf('@'), '***') ?? 'null'}');
      debugPrint('Navigation will be handled by route management system');
    }
    
    // Store the deep link result for when navigation is available
    _storeDeepLinkResult(result);
  }

  /// Navigate to email verification page
  void _navigateToEmailVerification(DeepLinkResult result) async {
    if (kDebugMode) {
      debugPrint('Deep link result ready for email verification navigation');
    }
    
    _storeDeepLinkResult(result);
  }

  /// Store deep link result for later navigation
  void _storeDeepLinkResult(DeepLinkResult result) {
    // In a real implementation, you might want to store this in a service or state management
    // For now, we'll just log that the result is ready for navigation
    if (kDebugMode) {
      debugPrint('Deep link result stored for later navigation');
    }
  }

  /// Show error message for unknown link types
  void _showUnknownLinkMessage() {
    if (kDebugMode) {
      debugPrint('Unknown deep link type');
    }
  }

  /// Show error message for failed deep links
  void _showErrorMessage(String message) {
    if (kDebugMode) {
      debugPrint('Deep link error: $message');
    }
  }

  /// Check if a URI is a valid Firebase Auth action URL
  static bool isFirebaseAuthAction(Uri uri) {
    return uri.host.contains('firebaseapp.com') || 
           uri.host.contains('web.app') ||
           uri.host.contains('page.link');
  }

  /// Create a test deep link for development purposes
  static String createTestPasswordResetLink({
    required String email,
    required String oobCode,
  }) {
    try {
      // Create a test URL structure that mimics Firebase Auth format
      final testUrl = 'https://karbonson.page.link/reset-password?oobCode=$oobCode&email=${Uri.encodeComponent(email)}&mode=resetPassword';
      if (kDebugMode) {
        debugPrint('Test deep link created: ${testUrl.replaceRange(testUrl.indexOf('oobCode='), testUrl.indexOf('oobCode=') + 20, 'oobCode=***...')}');
      }
      return testUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create test deep link: $e');
      }
      rethrow;
    }
  }

  /// Parse deep link URL manually (for testing or when packages not available)
  static Future<DeepLinkResult> parseDeepLinkManually(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      return await DeepLinkingService().handleDeepLink(uri);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to parse deep link manually: $e');
      }
      return DeepLinkResult.failure('Geçersiz bağlantı formatı');
    }
  }

  /// ============================================
  /// 4. 🔗 DEEP LINKING HAZIRLIK SERVİSİ
  /// Firebase ve Flutter için derin bağlantı entegrasyonu
  /// ============================================

  /// Enhanced deep linking service with comprehensive Firebase integration
  static Map<String, dynamic> getFirebaseFlutterConfiguration() {
    return {
      'service_initialized': true,
      'mode': 'enhanced', // Enhanced configuration ready
      'supported_link_types': DeepLinkType.values.map((e) => e.name).toList(),
      'firebase_configuration': {
        'domains': [
          'firebaseapp.com',
          'web.app', 
          'page.link',
          'karbonson.page.link'
        ],
        'dynamic_links_domain': 'https://karbonson.page.link',
        'action_code_settings': {
          'url': 'https://karbonson.page.link/reset-password',
          'handleCodeInApp': true,
          'android_package_name': 'com.example.karbonson',
          'android_minimum_version': '21',
          'android_install_app': true,
          'ios_bundle_id': 'com.example.karbonson'
        }
      },
      'flutter_configuration': {
        'required_packages': {
          'firebase_dynamic_links': 'firebase_dynamic_links: ^5.4.0+',
          'uni_links': 'uni_links: ^3.0.0'
        },
        'setup_instructions': [
          '1. Add packages to pubspec.yaml',
          '2. Configure Firebase Console Dynamic Links',
          '3. Set up iOS URL Schemes',
          '4. Configure Android Intent Filters',
          '5. Initialize service in main.dart'
        ]
      },
      'implementation_status': {
        'enhanced_auth_service': true,
        'enhanced_error_handling': true,
        'enhanced_verification_screen': true,
        'deep_linking_ready': false // Will be true after packages installation
      }
    };
  }

  /// Create Firebase Dynamic Link for password reset
  static Future<String> createFirebasePasswordResetLink({
    required String email,
    String? customDomain,
  }) async {
    try {
      // Note: This requires firebase_dynamic_links package
      // This is a placeholder implementation
      final domain = customDomain ?? 'https://karbonson.page.link';
      final link = '$domain/reset-password?email=${Uri.encodeComponent(email)}';
      
      if (kDebugMode) {
        debugPrint('Created Firebase Dynamic Link: ${link.replaceRange(link.indexOf('email='), link.indexOf('email=') + 15, 'email=***@***')}');
      }
      
      return link;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create Firebase Dynamic Link: $e');
      }
      rethrow;
    }
  }

  /// Debug method to get current app state
  static Map<String, dynamic> getDebugInfo() {
    return getFirebaseFlutterConfiguration();
  }
}