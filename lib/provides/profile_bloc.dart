// lib/provides/profile_bloc.dart
// PROFIL BLOK - TÜM VERİLER FIRESTORE'DAN GELİR
// ProfileData ve SharedPreferences KALDIRILDI - SADECE USERDATA KULLANILIYOR

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import '../services/profile_service.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userNickname;

  const LoadProfile(this.userNickname);

  @override
  List<Object> get props => [userNickname];
}

/// Event to start listening to profile changes in real-time
class ListenToProfile extends ProfileEvent {}

class RefreshProfile extends ProfileEvent {}

class RefreshServerData extends ProfileEvent {}

class UpdateNickname extends ProfileEvent {
  final String newNickname;

  const UpdateNickname(this.newNickname);

  @override
  List<Object> get props => [newNickname];
}

class AddGameResult extends ProfileEvent {
  final int score;
  final bool isWin;
  final String gameType;

  const AddGameResult({
    required this.score,
    required this.isWin,
    required this.gameType,
  });

  @override
  List<Object> get props => [score, isWin, gameType];
}

class UpdateProfilePicture extends ProfileEvent {
  final String imageUrl;

  const UpdateProfilePicture(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class SyncProfileData extends ProfileEvent {}

/// Event for real-time profile updates
class ProfileDataUpdated extends ProfileEvent {
  final UserData userData;

  const ProfileDataUpdated(this.userData);

  @override
  List<Object> get props => [userData];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserData userData;
  final String currentNickname;

  const ProfileLoaded({
    required this.userData,
    required this.currentNickname,
  });

  @override
  List<Object> get props => [userData, currentNickname];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;
  StreamSubscription? _profileSubscription;

  ProfileBloc({required this.profileService}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<ListenToProfile>(_onListenToProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<RefreshServerData>(_onRefreshServerData);
    on<UpdateNickname>(_onUpdateNickname);
    on<AddGameResult>(_onAddGameResult);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
    on<SyncProfileData>(_onSyncProfileData);
    on<ProfileDataUpdated>(_onProfileDataUpdated);
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Get current authenticated user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError(
            'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.'));
        return;
      }

      // Load user profile from Firestore - TÜM VERİLER BURADAN GELİYOR
      final userData = await profileService.getUserProfile();

      if (userData != null) {
        emit(ProfileLoaded(
          userData: userData,
          currentNickname: event.userNickname.isNotEmpty
              ? event.userNickname
              : userData.nickname,
        ));
      } else {
        // Create minimal profile from Auth user if no Firestore data exists yet
        final fallbackNickname = event.userNickname.isNotEmpty
            ? event.userNickname
            : (currentUser.email?.split('@')[0] ?? 'Kullanıcı');
        
        final minimalUserData = UserData(
          uid: currentUser.uid,
          nickname: fallbackNickname,
          profilePictureUrl: null,
          lastLogin: DateTime.now(),
        );
        
        emit(ProfileLoaded(
          userData: minimalUserData,
          currentNickname: fallbackNickname,
        ));
      }
    } catch (e) {
      emit(ProfileError('Profil yüklenirken hata oluştu: ${e.toString()}'));
    }
  }

  /// Start listening to profile changes in real-time
  Future<void> _onListenToProfile(
      ListenToProfile event, Emitter<ProfileState> emit) async {
    // Cancel any existing subscription
    _profileSubscription?.cancel();

    final currentState = state;
    if (currentState is! ProfileLoaded) {
      return;
    }

    try {
      // Start listening to profile changes
      _profileSubscription = profileService.listenToUserProfile().listen(
        (userData) {
          if (userData != null) {
            add(ProfileDataUpdated(userData));
          }
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('Profile stream error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting up profile listener: $e');
      }
    }
  }

  /// Handle real-time profile data updates
  void _onProfileDataUpdated(
      ProfileDataUpdated event, Emitter<ProfileState> emit) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(
        userData: event.userData,
        currentNickname: currentState.currentNickname,
      ));
    }
  }

  Future<void> _onRefreshProfile(
      RefreshProfile event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        // Refresh from Firestore
        final updatedUserData = await profileService.refreshProfile();

        if (updatedUserData != null) {
          emit(ProfileLoaded(
            userData: updatedUserData,
            currentNickname: currentState.currentNickname,
          ));
        }
      } catch (e) {
        // Silent error handling for background refresh
        if (e.toString().contains('PERMISSION_DENIED')) {
          // User might not be logged in, ignore silently
        } else {
          emit(ProfileError(
              'Sunucu verisi güncellenirken hata oluştu: ${e.toString()}'));
        }
      }
    }
  }

  Future<void> _onRefreshServerData(
      RefreshServerData event, Emitter<ProfileState> emit) async {
    // RefreshServerData aynı işi yapar, _onRefreshProfile'ı çağır
    await _onRefreshProfile(RefreshProfile(), emit);
  }

  Future<void> _onUpdateNickname(
      UpdateNickname event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final success = await profileService.updateNickname(event.newNickname);

        if (success) {
          // Update user data with new nickname
          final updatedUserData = currentState.userData.copyWith(
            nickname: event.newNickname,
          );

          emit(ProfileLoaded(
            userData: updatedUserData,
            currentNickname: event.newNickname,
          ));

          emit(ProfileUpdateSuccess('Takma ad başarıyla güncellendi'));
        } else {
          emit(ProfileError('Takma ad güncellenirken hata oluştu'));
        }
      } catch (e) {
        emit(ProfileError(
            'Takma ad güncellenirken hata oluştu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddGameResult(
      AddGameResult event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        // Add game result to Firestore
        final success = await profileService.addGameResult(
          score: event.score,
          isWin: event.isWin,
          gameType: event.gameType,
        );

        if (success) {
          // Reload user data from Firestore
          final updatedUserData = await profileService.getUserProfile();

          if (updatedUserData != null) {
            emit(ProfileLoaded(
              userData: updatedUserData,
              currentNickname: currentState.currentNickname,
            ));
          }
        } else {
          emit(ProfileError('Oyun sonucu kaydedilirken hata oluştu'));
        }
      } catch (e) {
        emit(ProfileError(
            'Oyun sonucu kaydedilirken hata oluştu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateProfilePicture(
      UpdateProfilePicture event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        // Update profile picture in Firestore
        final success = await profileService.updateProfilePicture(event.imageUrl);

        if (success) {
          // Update user data with new profile picture
          final updatedUserData = currentState.userData.copyWith(
            profilePictureUrl: event.imageUrl,
          );

          emit(ProfileLoaded(
            userData: updatedUserData,
            currentNickname: currentState.currentNickname,
          ));

          emit(ProfileUpdateSuccess('Profil resmi başarıyla güncellendi'));
        } else {
          emit(ProfileError('Profil resmi güncellenirken hata oluştu'));
        }
      } catch (e) {
        emit(ProfileError(
            'Profil resmi güncellenirken hata oluştu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSyncProfileData(
      SyncProfileData event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final success = await profileService.syncAllProfileData();
        if (success) {
          // Reload user data after sync
          final updatedUserData = await profileService.getUserProfile();
          if (updatedUserData != null) {
            emit(ProfileLoaded(
              userData: updatedUserData,
              currentNickname: currentState.currentNickname,
            ));
          }
          emit(ProfileUpdateSuccess('Profil verileri senkronize edildi'));
        } else {
          emit(ProfileError('Profil verileri senkronize edilirken hata oluştu'));
        }
      } catch (e) {
        emit(ProfileError('Senkronizasyon hatası: ${e.toString()}'));
      }
    }
  }
}

