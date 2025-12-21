// lib/services/authentication_state_service.dart
// Global authentication state management service to ensure consistent user account name usage across all games

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_service.dart';

/// Global authentication state service that manages user login state
/// and ensures authenticated account names are used consistently across all game types
class AuthenticationStateService extends ChangeNotifier {
  static final AuthenticationStateService _instance =
      AuthenticationStateService._internal();
  factory AuthenticationStateService() => _instance;
  AuthenticationStateService._internal();

  final ProfileService _profileService = ProfileService();

  // Authentication state
  bool _isAuthenticated = false;
  String _authenticatedNickname = '';
  String _authenticatedUid = '';

  // Getters for current state
  bool get isAuthenticated => _isAuthenticated;
  String get authenticatedNickname => _authenticatedNickname;
  String get authenticatedUid => _authenticatedUid;

  /// Check if user has authenticated account (not anonymous)
  bool get hasAuthAccount => _isAuthenticated && _authenticatedUid.isNotEmpty;

  /// Get the nickname to use for games (authenticated nickname if logged in, fallback to cached)
  Future<String> getGameNickname() async {
    if (_isAuthenticated && _authenticatedNickname.isNotEmpty) {
      return _authenticatedNickname;
    }

    // Fallback to cached nickname for anonymous users
    final cachedNickname = await _profileService.getCurrentNickname();
    return cachedNickname ?? 'Oyuncu';
  }

  /// Get the player ID for games (authenticated UID if logged in, fallback to temp ID)
  Future<String> getGamePlayerId() async {
    if (_isAuthenticated && _authenticatedUid.isNotEmpty) {
      return _authenticatedUid;
    }

    // Fallback to Firebase current user or generate temp ID for anonymous
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }

    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Set user as authenticated with account details
  Future<void> setAuthenticatedUser({
    required String nickname,
    required String uid,
  }) async {
    _authenticatedNickname = nickname;
    _authenticatedUid = uid;
    _isAuthenticated = true;

    // Cache the authenticated nickname for consistency
    await _profileService.cacheNickname(nickname);

    if (kDebugMode) {
      debugPrint(
          'AuthenticationStateService: User authenticated as $nickname (UID: $uid)');
    }

    notifyListeners();
  }

  /// Clear authentication state (logout)
  void clearAuthenticationState() {
    _isAuthenticated = false;
    _authenticatedNickname = '';
    _authenticatedUid = '';

    if (kDebugMode) {
      debugPrint('AuthenticationStateService: Authentication state cleared');
    }

    notifyListeners();
  }

  /// Check if current Firebase user matches authenticated state
  Future<bool> isCurrentUserAuthenticated() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Check if user has email (indicates real account vs anonymous)
    final hasEmail = user.email != null && user.email!.isNotEmpty;

    // If user has email but our state doesn't show authenticated, sync it
    if (hasEmail && (!_isAuthenticated || _authenticatedUid != user.uid)) {
      final nickname = await _profileService.getCurrentNickname() ??
          user.email!.split('@')[0] ??
          'Kullanıcı';

      await setAuthenticatedUser(
        nickname: nickname,
        uid: user.uid,
      );

      return true;
    }

    return _isAuthenticated && _authenticatedUid == user.uid;
  }

  /// Initialize authentication state from current Firebase user with persistent session support
  Future<void> initializeAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (kDebugMode) {
        debugPrint(
            'AuthenticationStateService: Initializing auth state. Current user: ${user?.uid ?? 'none'}');
        debugPrint('User email: ${user?.email ?? 'none'}');
        debugPrint('User isAnonymous: ${user?.isAnonymous ?? 'none'}');
      }

      if (user != null) {
        // Check if user has email (indicates real account vs anonymous)
        final hasEmail = user.email != null && user.email!.isNotEmpty;

        if (hasEmail) {
          // User has email account, set as authenticated
          final nickname = await _profileService.getCurrentNickname() ??
              user.email!.split('@')[0] ??
              'Kullanıcı';

          await setAuthenticatedUser(
            nickname: nickname,
            uid: user.uid,
          );

          if (kDebugMode) {
            debugPrint(
                'AuthenticationStateService: Authenticated user restored from persistent session: $nickname (${user.uid})');
          }
        } else {
          // Anonymous user, clear authentication state
          clearAuthenticationState();
          if (kDebugMode) {
            debugPrint(
                'AuthenticationStateService: Anonymous user detected, clearing auth state');
          }
        }
      } else {
        // No user, clear authentication state
        clearAuthenticationState();
        if (kDebugMode) {
          debugPrint(
              'AuthenticationStateService: No current user, auth state cleared');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'AuthenticationStateService: Error initializing auth state: $e');
      }
      clearAuthenticationState();
    }
  }

  /// Check if user should be required to login for specific features
  Future<bool> shouldRequireLogin(String featureName) async {
    // For multiplayer and duel modes, require login if user has played before
    if (featureName.contains('multiplayer') || featureName.contains('duel')) {
      final cachedNickname = await _profileService.getCurrentNickname();
      return cachedNickname != null && cachedNickname.isNotEmpty;
    }

    return false;
  }

  /// Get debug information about current authentication state
  Map<String, dynamic> getDebugInfo() {
    return {
      'isAuthenticated': _isAuthenticated,
      'authenticatedNickname': _authenticatedNickname,
      'authenticatedUid': _authenticatedUid,
      'hasAuthAccount': hasAuthAccount,
      'currentFirebaseUser': FirebaseAuth.instance.currentUser?.uid ?? 'none',
      'currentFirebaseUserEmail':
          FirebaseAuth.instance.currentUser?.email ?? 'none',
    };
  }
}
