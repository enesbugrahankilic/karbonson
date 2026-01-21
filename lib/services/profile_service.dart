// lib/services/profile_service.dart
// PROFIL SAYFASI TAMAMEN DINAMIK - TÜM VERILER FIRESTORE'DAN GELIR
// SharedPreferences fallback KALDIRILDI

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data.dart' as user_model;
import '../models/profile_data.dart'; // For GameHistoryItem
import 'firestore_service.dart';

/// Email verification status for UI display
class EmailVerificationStatus {
  final String uid;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String message;
  final bool hasEmail;
  final String? email;

  EmailVerificationStatus({
    required this.uid,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.message = '',
    this.hasEmail = false,
    this.email,
  });

  bool get isPending => hasEmail && !emailVerified;
}

/// Game statistics data class - used for UI display
/// This is a helper class that extracts game statistics from UserData
class GameStatisticsData {
  final double winRate;
  final int totalGamesPlayed;
  final int highestScore;
  final int averageScore;
  final List<GameHistoryItem> recentGames;

  GameStatisticsData({
    required this.winRate,
    required this.totalGamesPlayed,
    required this.highestScore,
    required this.averageScore,
    required this.recentGames,
  });

  /// Create from UserData
  static GameStatisticsData fromUserData(user_model.UserData userData) {
    return GameStatisticsData(
      winRate: userData.winRate,
      totalGamesPlayed: userData.totalGamesPlayed,
      highestScore: userData.highestScore,
      averageScore: userData.averageScore,
      recentGames: userData.recentGames,
    );
  }

  /// Check if user has played any games
  bool get hasPlayedGames => totalGamesPlayed > 0;

  /// Get formatted win rate as percentage
  String get formattedWinRate => '${(winRate * 100).round()}%';
}

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService;

  ProfileService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// TÜM VERİLERİ FIRESTORE'DAN ÇEK - Artık SharedPreferences yok
  /// Bu metod sadece Firestore'dan veri çeker
  Future<user_model.UserData?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No authenticated user found');
        return null;
      }

      // Firestore'dan doğrudan veri çek
      final userData = await _firestoreService.getUserProfile(user.uid);
      
      if (userData != null && kDebugMode) {
        debugPrint('✅ User profile loaded from Firestore: ${userData.nickname}');
        debugPrint('   - Total Games: ${userData.totalGamesPlayed}');
        debugPrint('   - Win Rate: ${(userData.winRate * 100).round()}%');
        debugPrint('   - Highest Score: ${userData.highestScore}');
        debugPrint('   - Recent Games: ${userData.recentGames.length}');
      }
      
      return userData;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error loading user profile from Firestore: $e');
      return null;
    }
  }

  /// Kullanıcı adını Firestore'dan getir
  Future<String?> getCurrentNickname() async {
    try {
      final userData = await getUserProfile();
      return userData?.nickname;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting nickname: $e');
      return null;
    }
  }

  /// Firestore'dan oyun istatistiklerini getir
  Future<GameStatisticsData?> getGameStatistics() async {
    try {
      final userData = await getUserProfile();
      if (userData == null) return null;

      return GameStatisticsData(
        winRate: userData.winRate,
        totalGamesPlayed: userData.totalGamesPlayed,
        highestScore: userData.highestScore,
        averageScore: userData.averageScore,
        recentGames: userData.recentGames,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting game statistics: $e');
      return null;
    }
  }

  /// Update profile picture URL in Firestore
  Future<bool> updateProfilePicture(String imageUrl) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('❌ No user available for profile picture update');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('📸 Updating profile picture for user: ${user.uid}');
      }

      // Get current user profile from Firestore
      final currentProfile = await _firestoreService.getUserProfile(user.uid);
      if (currentProfile == null) {
        if (kDebugMode) {
          debugPrint('❌ User profile not found for picture update');
        }
        return false;
      }

      // Create updated user data with new profile picture URL
      final updatedUserData = currentProfile.copyWith(
        profilePictureUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
        fcmToken: updatedUserData.fcmToken,
      );

      if (success != null && kDebugMode) {
        debugPrint('✅ Profile picture updated successfully');
      } else if (kDebugMode) {
        debugPrint('❌ Failed to update profile picture');
      }

      return success != null;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error updating profile picture: $e');
      return false;
    }
  }

  /// Update nickname with validation in Firestore
  Future<bool> updateNickname(String newNickname) async {
    return _firestoreService.updateUserNickname(newNickname);
  }

  /// Add a new game result to Firestore statistics
  Future<bool> addGameResult({
    required int score,
    required bool isWin,
    required String gameType,
  }) async {
    try {
      return _firestoreService.addGameResult(
        score: score,
        isWin: isWin,
        gameType: gameType,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding game result: $e');
      return false;
    }
  }

  /// Initialize profile for a new user in Firestore
  Future<void> initializeProfile({
    required String nickname,
    String? profilePictureUrl,
    user_model.PrivacySettings? privacySettings,
    User? user,
    int? classLevel,
    String? classSection,
  }) async {
    try {
      final currentUser = user ?? _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('❌ No user available for profile initialization');
        }
        return;
      }

      // Initialize server profile in Firestore with UID centrality
      await _firestoreService.createOrUpdateUserProfile(
        nickname: nickname,
        profilePictureUrl: profilePictureUrl,
        privacySettings: privacySettings,
        classLevel: classLevel,
        classSection: classSection,
      );

      if (kDebugMode) {
        debugPrint('✅ Profile initialized in Firestore for: $nickname');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing profile: $e');
    }
  }

  /// Check if user is authenticated
  bool get isUserLoggedIn => _auth.currentUser != null;

  /// Get current user UID
  String? get currentUserUid => _auth.currentUser?.uid;

  /// Check if user is authenticated with UID validation
  bool get isUserAuthenticated => _firestoreService.isUserAuthenticated;

  /// Check if user is registered (has email/password account vs anonymous)
  Future<bool> isUserRegistered() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final isEmailUser = user.email != null && user.email!.isNotEmpty;
      final isAnonymous = user.isAnonymous;

      return isEmailUser && !isAnonymous;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking registration status: $e');
      return false;
    }
  }

  /// ============================================
  /// EMAIL VERIFICATION METHODS
  /// ============================================

  /// Check if current user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      return user.emailVerified;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking email verification status: $e');
      }
      return false;
    }
  }

  /// Get email verification status with detailed information
  Future<EmailVerificationStatus> getEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return EmailVerificationStatus(
          uid: '',
          emailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          message: 'Kullanıcı oturumu bulunamadı',
        );
      }

      await user.reload();
      final currentUser = _auth.currentUser!;

      final hasEmail = currentUser.email != null && currentUser.email!.isNotEmpty;
      final isVerified = currentUser.emailVerified;

      return EmailVerificationStatus(
        uid: user.uid,
        emailVerified: isVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        message: isVerified
            ? 'E-posta adresi doğrulanmış'
            : 'E-posta adresi doğrulanmamış',
        hasEmail: hasEmail,
        email: currentUser.email,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting email verification status: $e');
      return EmailVerificationStatus(
        uid: '',
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        message: 'Doğrulama durumu kontrol edilemedi',
      );
    }
  }

  /// Sync email verification status between Firebase Auth and Firestore
  Future<bool> syncEmailVerificationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      final isVerified = user.emailVerified;

      // Update in Firestore
      final userData = await _firestoreService.getUserProfile(user.uid);
      if (userData == null) return false;

      final updatedUserData = userData.copyWith(
        isEmailVerified: isVerified,
        emailVerifiedAt: isVerified ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
        fcmToken: updatedUserData.fcmToken,
      );

      return success != null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error syncing email verification status: $e');
      return false;
    }
  }

  /// ============================================
  /// 2FA (Multi-Factor Authentication) METHODS
  /// ============================================

  /// Update 2FA status in Firestore
  Future<bool> update2FAStatus(bool is2FAEnabled, String? phoneNumber) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userData = await _firestoreService.getUserProfile(user.uid);
      if (userData == null) return false;

      final updatedUserData = userData.copyWith(
        is2FAEnabled: is2FAEnabled,
        phoneNumber: phoneNumber,
        last2FAVerification: is2FAEnabled ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      final success = await _firestoreService.createOrUpdateUserProfile(
        nickname: updatedUserData.nickname,
        profilePictureUrl: updatedUserData.profilePictureUrl,
        privacySettings: updatedUserData.privacySettings,
        fcmToken: updatedUserData.fcmToken,
      );

      return success != null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating 2FA status: $e');
      return false;
    }
  }

  /// Get 2FA status information for current user from Firestore
  Future<Map<String, dynamic>> get2FAStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'is2FAEnabled': false,
          'phoneNumber': null,
          'last2FAVerification': null,
        };
      }

      final userData = await _firestoreService.getUserProfile(user.uid);
      if (userData == null) {
        return {
          'is2FAEnabled': false,
          'phoneNumber': null,
          'last2FAVerification': null,
        };
      }

      return {
        'is2FAEnabled': userData.is2FAEnabled,
        'phoneNumber': userData.phoneNumber,
        'last2FAVerification': userData.last2FAVerification,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting 2FA status: $e');
      return {
        'is2FAEnabled': false,
        'phoneNumber': null,
        'last2FAVerification': null,
      };
    }
  }

  /// Sync 2FA status with Firebase Auth state
  Future<bool> sync2FAStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final hasPhoneProvider = user.providerData.any((provider) => provider.providerId == 'phone');

      String? phoneNumber;
      if (hasPhoneProvider) {
        final phoneProvider = user.providerData.firstWhere((provider) => provider.providerId == 'phone');
        phoneNumber = phoneProvider.phoneNumber;
      }

      return update2FAStatus(hasPhoneProvider, phoneNumber);
    } catch (e) {
      if (kDebugMode) debugPrint('Error syncing 2FA status: $e');
      return false;
    }
  }

  /// ============================================
  /// PRIVACY SETTINGS METHODS
  /// ============================================

  /// Update privacy settings in Firestore
  Future<bool> updatePrivacySettings(user_model.PrivacySettings privacySettings) async {
    return _firestoreService.updatePrivacySettings(privacySettings);
  }

  /// Get privacy settings from Firestore
  Future<user_model.PrivacySettings?> getPrivacySettings() async {
    try {
      final userData = await getUserProfile();
      return userData?.privacySettings;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting privacy settings: $e');
      return null;
    }
  }

  /// ============================================
  /// FIRESTORE REAL-TIME LISTENERS
  /// ============================================

  /// Listen to user profile changes in real-time
  /// Returns a stream that emits whenever the user profile is updated in Firestore
  /// This is essential for a fully dynamic profile page
  Stream<user_model.UserData?> listenToUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestoreService.listenToUserProfile(user.uid);
  }

  /// ============================================
  /// PROFILE REFRESH METHODS
  /// ============================================

  /// Refresh user profile from Firestore
  Future<user_model.UserData?> refreshProfile() async {
    return getUserProfile();
  }

  /// Load server profile - alias for getUserProfile for compatibility
  Future<user_model.UserData?> loadServerProfile() async {
    return getUserProfile();
  }

  /// Cache nickname to local storage (for fallback purposes)
  Future<void> cacheNickname(String nickname) async {
    // This is a stub for compatibility - in a fully dynamic system,
    // nickname is always loaded from Firestore
    if (kDebugMode) {
      debugPrint('Note: cacheNickname called, but system uses Firestore as source of truth');
    }
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sync all profile data between Firebase Auth and Firestore
  /// This ensures consistency between Auth state and Firestore data
  Future<bool> syncAllProfileData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('❌ No user available for sync');
        return false;
      }

      // Sync email verification status
      await syncEmailVerificationStatus();

      // Sync 2FA status
      await sync2FAStatus();

      if (kDebugMode) {
        debugPrint('✅ All profile data synced for user: ${user.uid}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('🚨 Error syncing profile data: $e');
      return false;
    }
  }

  /// Get formatted account creation date
  Future<String?> getFormattedCreatedAt() async {
    try {
      final userData = await getUserProfile();
      if (userData == null || userData.createdAt == null) {
        return null;
      }

      final createdAt = userData.createdAt!;
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays < 1) {
        return 'Bugün';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} hafta önce';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} ay önce';
      } else {
        return '${(difference.inDays / 365).floor()} yıl önce';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting formatted createdAt: $e');
      return null;
    }
  }

  /// Get last profile update formatted string
  Future<String?> getFormattedLastUpdated() async {
    try {
      final userData = await getUserProfile();
      if (userData == null || userData.updatedAt == null) {
        return null;
      }

      final updatedAt = userData.updatedAt!;
      final now = DateTime.now();
      final difference = now.difference(updatedAt);

      if (difference.inMinutes < 1) {
        return 'Az önce';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} dakika önce';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} saat önce';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else {
        return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting formatted updatedAt: $e');
      return null;
    }
  }

  /// Get account age in days
  Future<int?> getAccountAgeInDays() async {
    try {
      final userData = await getUserProfile();
      if (userData == null || userData.createdAt == null) {
        return null;
      }

      final now = DateTime.now();
      return now.difference(userData.createdAt!).inDays;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting account age: $e');
      return null;
    }
  }

  /// Check if account is new (less than 7 days old)
  Future<bool> isNewAccount() async {
    final age = await getAccountAgeInDays();
    return age != null && age < 7;
  }

  /// Get account summary statistics
  Future<Map<String, dynamic>> getAccountSummary() async {
    try {
      final userData = await getUserProfile();
      if (userData == null) {
        return {
          'accountAge': null,
          'isNewAccount': true,
          'formattedCreatedAt': null,
          'formattedLastUpdated': null,
        };
      }

      final accountAge = await getAccountAgeInDays();
      final formattedCreatedAt = await getFormattedCreatedAt();
      final formattedLastUpdated = await getFormattedLastUpdated();

      return {
        'accountAge': accountAge,
        'isNewAccount': accountAge != null && accountAge < 7,
        'formattedCreatedAt': formattedCreatedAt,
        'formattedLastUpdated': formattedLastUpdated,
        'createdAt': userData.createdAt,
        'updatedAt': userData.updatedAt,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting account summary: $e');
      return {
        'accountAge': null,
        'isNewAccount': true,
        'formattedCreatedAt': null,
        'formattedLastUpdated': null,
      };
    }
  }
}

