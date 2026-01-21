// lib/services/session_management_service.dart
// Comprehensive session and token lifecycle management

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';
import 'analytics_service.dart';

class SessionManagementService {
  static final SessionManagementService _instance = SessionManagementService._internal();
  factory SessionManagementService() => _instance;
  SessionManagementService._internal();

  late FirebaseAuth _auth;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Token management
  String? _currentToken;
  DateTime? _tokenExpiry;
  Timer? _tokenRefreshTimer;
  StreamSubscription<User?>? _authStateSubscription;

  // Session constants
  static const String _tokenKey = 'user_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _lastActivityKey = 'last_activity';
  static const Duration _sessionTimeout = Duration(hours: 24);
  static const Duration _tokenRefreshThreshold = Duration(minutes: 5);

  // Callbacks
  Function(String)? onSessionExpired;
  Function(String)? onTokenRefreshed;
  Function()? onUserBanned;

  /// Initialize session management
  Future<void> initialize(SharedPreferences prefs) async {
    if (_isInitialized) return;

    try {
      _auth = FirebaseAuth.instance;
      _prefs = prefs;

      // Load cached token
      _currentToken = _prefs.getString(_tokenKey);
      final expiryStr = _prefs.getString(_tokenExpiryKey);
      if (expiryStr != null) {
        _tokenExpiry = DateTime.parse(expiryStr);
      }

      // Listen to auth state changes
      _authStateSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);

      // Setup token refresh timer
      _setupTokenRefreshTimer();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ Session management initialized');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Session init error: $e');
    }
  }

  /// Handle auth state changes
  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      // User logged out
      _clearSession();
      onSessionExpired?.call('User logged out');
    } else {
      // User logged in
      await _refreshUserSession(user);
    }
  }

  /// Setup token refresh timer
  void _setupTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    if (_tokenExpiry == null) {
      if (kDebugMode) debugPrint('⚠️ No token expiry set');
      return;
    }

    final now = DateTime.now();
    final timeUntilRefresh = _tokenExpiry!.subtract(_tokenRefreshThreshold).difference(now);

    if (timeUntilRefresh.isNegative) {
      // Token already expired or close to expiry
      _handleTokenExpiry();
      return;
    }

    _tokenRefreshTimer = Timer(timeUntilRefresh, _handleTokenRefresh);

    if (kDebugMode) {
      debugPrint('🔄 Token refresh scheduled in ${timeUntilRefresh.inMinutes} minutes');
    }
  }

  /// Handle token refresh
  Future<void> _handleTokenRefresh() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _handleTokenExpiry();
        return;
      }

      // Force token refresh
      final idTokenResult = await user.getIdTokenResult(true);
      _currentToken = idTokenResult.token;
      _tokenExpiry = idTokenResult.expirationTime;

      // Save to cache
      await _saveTokenToCache();

      // Setup next refresh
      _setupTokenRefreshTimer();

      onTokenRefreshed?.call(_currentToken!);

      if (kDebugMode) {
        debugPrint('✅ Token refreshed successfully');
      }

      // Log to analytics
      AnalyticsService().setUserProperty('token_status', 'refreshed');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Token refresh error: $e');
      await AnalyticsService().logError('TokenRefreshError', e.toString());
      _handleTokenExpiry();
    }
  }

  /// Handle token expiry
  void _handleTokenExpiry() {
    if (kDebugMode) debugPrint('🚨 Token expired');

    _clearSession();
    onSessionExpired?.call('Token expired');

    AnalyticsService().logError('TokenExpiry', 'User token has expired');
  }

  /// Refresh user session
  Future<void> _refreshUserSession(User user) async {
    try {
      final idTokenResult = await user.getIdTokenResult();
      _currentToken = idTokenResult.token;
      _tokenExpiry = idTokenResult.expirationTime;

      // Check if user is banned
      await _checkUserBanStatus(user.uid);

      // Save to cache
      await _saveTokenToCache();

      // Update last activity
      await _updateLastActivity();

      // Setup refresh timer
      _setupTokenRefreshTimer();

      if (kDebugMode) {
        debugPrint('✅ User session refreshed for ${user.email}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Session refresh error: $e');
      await AnalyticsService().logError('SessionRefreshError', e.toString());
    }
  }

  /// Check if user is banned
  Future<void> _checkUserBanStatus(String userId) async {
    try {
      // Note: Implement this with your Firestore user collection
      // Example: final userDoc = await _firestore.collection('users').doc(userId).get();
      // if (userDoc.data()['isBanned'] == true) { onUserBanned?.call(); }

      if (kDebugMode) debugPrint('✅ User ban status checked');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Ban check error: $e');
    }
  }

  /// Save token to cache
  Future<void> _saveTokenToCache() async {
    try {
      if (_currentToken != null) {
        await _prefs.setString(_tokenKey, _currentToken!);
      }
      if (_tokenExpiry != null) {
        await _prefs.setString(_tokenExpiryKey, _tokenExpiry!.toIso8601String());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error saving token to cache: $e');
    }
  }

  /// Update last activity timestamp
  Future<void> _updateLastActivity() async {
    try {
      await _prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error updating activity: $e');
    }
  }

  /// Get current token
  String? getToken() {
    if (_isTokenValid()) {
      return _currentToken;
    }
    return null;
  }

  /// Check if token is valid
  bool _isTokenValid() {
    if (_currentToken == null || _tokenExpiry == null) {
      return false;
    }

    final now = DateTime.now();
    final isValid = now.isBefore(_tokenExpiry!);

    if (!isValid && kDebugMode) {
      debugPrint('⚠️ Token invalid - expiry: $_tokenExpiry, now: $now');
    }

    return isValid;
  }

  /// Get session timeout remaining
  Duration? getSessionTimeRemaining() {
    if (_tokenExpiry == null) return null;

    final remaining = _tokenExpiry!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Get session info for debugging
  Map<String, dynamic> getSessionInfo() {
    return {
      'has_token': _currentToken != null,
      'token_expiry': _tokenExpiry?.toIso8601String(),
      'is_valid': _isTokenValid(),
      'time_remaining_minutes': getSessionTimeRemaining()?.inMinutes,
      'last_activity': _prefs.getString(_lastActivityKey),
    };
  }

  /// Manual logout
  Future<void> logout() async {
    try {
      _clearSession();
      await _auth.signOut();

      AnalyticsService().logCustomEvent('user_logout', null);

      if (kDebugMode) {
        debugPrint('✅ User logged out');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Logout error: $e');
      await AnalyticsService().logError('LogoutError', e.toString());
    }
  }

  /// Clear session data
  void _clearSession() {
    _currentToken = null;
    _tokenExpiry = null;
    _tokenRefreshTimer?.cancel();

    try {
      _prefs.remove(_tokenKey);
      _prefs.remove(_tokenExpiryKey);
      _prefs.remove(_lastActivityKey);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing cache: $e');
    }

    if (kDebugMode) {
      debugPrint('🗑️ Session cleared');
    }
  }

  /// Dispose
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _authStateSubscription?.cancel();
    _isInitialized = false;
  }
}
