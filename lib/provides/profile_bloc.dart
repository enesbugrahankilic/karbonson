// lib/provides/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/profile_data.dart';
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

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileData profileData;
  final String currentNickname;

  const ProfileLoaded({
    required this.profileData,
    required this.currentNickname,
  });

  @override
  List<Object> get props => [profileData, currentNickname];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;

  ProfileBloc({required this.profileService}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshServerData>(_onRefreshServerData);
    on<UpdateNickname>(_onUpdateNickname);
    on<AddGameResult>(_onAddGameResult);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Cache nickname for later use
      await profileService.cacheNickname(event.userNickname);
      
      // Load profile data with two-stage loading strategy
      final profileData = await profileService.getProfileData();
      
      emit(ProfileLoaded(
        profileData: profileData,
        currentNickname: event.userNickname,
      ));

      // Refresh server data in background
      if (profileData.serverData == null) {
        final updatedProfile = await profileService.refreshServerData(profileData);
        if (updatedProfile.serverData != null) {
          emit(ProfileLoaded(
            profileData: updatedProfile,
            currentNickname: event.userNickname,
          ));
        }
      }
    } catch (e) {
      emit(ProfileError('Profil yüklenirken hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshServerData(RefreshServerData event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final updatedProfile = await profileService.refreshServerData(currentState.profileData);
        
        if (updatedProfile.serverData != currentState.profileData.serverData) {
          emit(ProfileLoaded(
            profileData: updatedProfile,
            currentNickname: currentState.currentNickname,
          ));
        }
      } catch (e) {
        // Silent error handling for background refresh
        if (e.toString().contains('PERMISSION_DENIED')) {
          // User might not be logged in, ignore silently
        } else {
          emit(ProfileError('Sunucu verisi güncellenirken hata oluştu: ${e.toString()}'));
        }
      }
    }
  }

  Future<void> _onUpdateNickname(UpdateNickname event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final success = await profileService.updateNickname(event.newNickname);
        
        if (success) {
          // Update local cache
          await profileService.cacheNickname(event.newNickname);
          
          // Update profile data with new nickname
          final updatedServerData = currentState.profileData.serverData?.copyWith(
            nickname: event.newNickname,
          );
          
          final updatedProfile = currentState.profileData.copyWith(
            serverData: updatedServerData,
          );
          
          emit(ProfileLoaded(
            profileData: updatedProfile,
            currentNickname: event.newNickname,
          ));
        } else {
          emit(ProfileError('Takma ad güncellenirken hata oluştu'));
        }
      } catch (e) {
        emit(ProfileError('Takma ad güncellenirken hata oluştu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddGameResult(AddGameResult event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        // Add game result to local statistics
        await profileService.addGameResult(
          score: event.score,
          isWin: event.isWin,
          gameType: event.gameType,
        );

        // Reload local statistics
        final updatedLocalData = await profileService.loadLocalStatistics();
        final updatedProfile = currentState.profileData.copyWith(
          localData: updatedLocalData,
        );

        emit(ProfileLoaded(
          profileData: updatedProfile,
          currentNickname: currentState.currentNickname,
        ));
      } catch (e) {
        emit(ProfileError('Oyun sonucu kaydedilirken hata oluştu: ${e.toString()}'));
      }
    }
  }
}