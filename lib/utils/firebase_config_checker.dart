// lib/utils/firebase_config_checker.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfigChecker {
  /// Comprehensive Firebase configuration and connectivity check
  static Future<Map<String, dynamic>> checkFirebaseConfiguration() async {
    final Map<String, dynamic> results = {
      'firebase_initialized': false,
      'auth_supported': false,
      'firestore_accessible': false,
      'network_connectivity': false,
      'config_issues': <String>[],
      'recommendations': <String>[],
    };

    try {
      // Check 1: Firebase App initialization
      if (FirebaseAuth.instance.app != null) {
        results['firebase_initialized'] = true;
        if (kDebugMode) debugPrint('✅ Firebase App is initialized');
      } else {
        results['config_issues'].add('Firebase App not initialized');
        results['recommendations'].add('Check Firebase initialization in main.dart');
        if (kDebugMode) debugPrint('❌ Firebase App not initialized');
      }

      // Check 2: Auth Provider availability
      try {
        final authInstance = FirebaseAuth.instance;
        results['auth_supported'] = true;
        if (kDebugMode) debugPrint('✅ Firebase Auth is available');
      } catch (e) {
        results['config_issues'].add('Firebase Auth not accessible');
        results['recommendations'].add('Check google-services.json and Firebase project configuration');
        if (kDebugMode) debugPrint('❌ Firebase Auth not accessible: $e');
      }

      // Check 3: Network connectivity (basic test)
      try {
        // This will throw if network is unavailable
        await InternetAddress.lookup('google.com');
        results['network_connectivity'] = true;
        if (kDebugMode) debugPrint('✅ Network connectivity is available');
      } catch (e) {
        results['config_issues'].add('No network connectivity');
        results['recommendations'].add('Check internet connection');
        if (kDebugMode) debugPrint('❌ No network connectivity: $e');
      }

      // Check 4: Firestore accessibility (basic test)
      try {
        await FirebaseFirestore.instance.enableNetwork();
        results['firestore_accessible'] = true;
        if (kDebugMode) debugPrint('✅ Firestore is accessible');
      } catch (e) {
        results['config_issues'].add('Firestore not accessible');
        results['recommendations'].add('Check Firebase project permissions and network connection');
        if (kDebugMode) debugPrint('❌ Firestore not accessible: $e');
      }

    } catch (e, stackTrace) {
      results['config_issues'].add('General configuration error: $e');
      if (kDebugMode) {
        debugPrint('🚨 Firebase configuration check failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }

    return results;
  }

  /// Get user-friendly error messages for common Firebase issues
  static String getErrorMessage(Map<String, dynamic> checkResults) {
    final issues = checkResults['config_issues'] as List<String>;
    
    if (issues.isEmpty) {
      return 'Firebase yapılandırması doğru görünüyor. Kayıt işlemini tekrar deneyin.';
    }

    final messages = <String>[];
    
    for (final issue in issues) {
      if (issue.contains('not initialized')) {
        messages.add('Firebase başlatma sorunu. Uygulamayı yeniden başlatmayı deneyin.');
      } else if (issue.contains('Auth not accessible')) {
        messages.add('Firebase Authentication yapılandırma sorunu. google-services.json dosyasını kontrol edin.');
      } else if (issue.contains('network')) {
        messages.add('İnternet bağlantısı sorunu. Bağlantınızı kontrol edin.');
      } else if (issue.contains('Firestore')) {
        messages.add('Veritabanı erişim sorunu. Firebase proje izinlerini kontrol edin.');
      } else {
        messages.add('Firebase yapılandırma sorunu: $issue');
      }
    }

    return messages.join('\n');
  }
}
