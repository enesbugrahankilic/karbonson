// lib/services/http_interceptor_service.dart
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import '../core/navigation/navigation_service.dart';

/// HTTP İstemci wrapper'ı, 401/403 hatalarını global olarak handle eder
/// Çözüm: Token yoksa login sayfasına redirect
class HttpInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  static VoidCallback? _onUnauthorized;

  HttpInterceptorClient(this._inner);

  /// Yetkisiz erişim callback'ini ayarla
  static void setUnauthorizedCallback(VoidCallback callback) {
    _onUnauthorized = callback;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // Add auth token if available
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        request.headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          debugPrint('🔐 HTTP Request: Added auth token');
        }
      }

      final streamedResponse = await _inner.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('❌ HTTP 401 Unauthorized - Token invalid or expired');
        }
        await _handleUnauthorized();
        throw HttpException(
          'Unauthorized: Token expired or invalid. Please log in again.',
          response.statusCode,
        );
      }

      // Handle 403 Forbidden
      if (response.statusCode == 403) {
        if (kDebugMode) {
          debugPrint('❌ HTTP 403 Forbidden - Access denied');
        }
        await _handleForbidden();
        throw HttpException(
          'Forbidden: You do not have permission to access this resource.',
          response.statusCode,
        );
      }

      // Handle other server errors
      if (response.statusCode >= 500) {
        if (kDebugMode) {
          debugPrint('❌ HTTP ${response.statusCode} Server Error');
        }
      }

      return streamedResponse;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HTTP Request Error: $e');
      }
      rethrow;
    }
  }

  /// 401 durumunda çalışacak handler
  static Future<void> _handleUnauthorized() async {
    try {
      // Firebase'den çıkış yap
      await FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        debugPrint('🚪 User signed out due to unauthorized access');
      }

      // Callback'i çağır (login sayfasına redirect)
      _onUnauthorized?.call();

      // Fallback: navigationService üzerinden login'e git
      NavigationService().navigateTo('/login');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error handling unauthorized: $e');
      }
    }
  }

  /// 403 durumunda çalışacak handler
  static Future<void> _handleForbidden() async {
    try {
      if (kDebugMode) {
        debugPrint('🚫 Access forbidden');
      }

      // Kullanıcıyı login'e yönlendir
      NavigationService().navigateTo('/login');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error handling forbidden: $e');
      }
    }
  }
}

/// HTTP istisnası
class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException(this.message, [this.statusCode]);

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}

/// HTTP Client factory - singleton olarak kullan
class HttpClientFactory {
  static final HttpClientFactory _instance = HttpClientFactory._internal();
  late HttpInterceptorClient _client;

  factory HttpClientFactory() => _instance;

  HttpClientFactory._internal() {
    _client = HttpInterceptorClient(http.Client());
  }

  HttpInterceptorClient getClient() => _client;

  /// Global unauthorized callback'i ayarla
  void setOnUnauthorized(VoidCallback callback) {
    HttpInterceptorClient.setUnauthorizedCallback(callback);
  }
}
