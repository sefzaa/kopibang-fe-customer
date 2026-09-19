abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profileData;
  ProfileLoaded(this.profileData);
}
class ProfileActionSuccess extends ProfileState {
  final String message;
  ProfileActionSuccess(this.message);
}
class ProfileLoggedOut extends ProfileState {}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}