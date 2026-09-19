import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  Map<String, dynamic>? _cachedData;

  ProfileCubit({required this.repository}) : super(ProfileInitial());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      _cachedData = await repository.getUserProfile();
      emit(ProfileLoaded(_cachedData!));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(String name, String username) async {
    emit(ProfileLoading());
    try {
      await repository.updateProfile(name, username);
      emit(ProfileActionSuccess("Profile updated successfully!"));
      fetchProfile(); // Refresh data
    } catch (e) {
      emit(ProfileError(e.toString()));
      if (_cachedData != null) emit(ProfileLoaded(_cachedData!)); // Return to previous state
    }
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    try {
      await repository.logout();
      emit(ProfileLoggedOut());
    } catch (e) {
      emit(ProfileLoggedOut()); // Tetap paksa logout di sisi UI
    }
  }
}