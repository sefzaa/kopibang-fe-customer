abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> profile;
  final bool isAvailable;
  final List<dynamic> vouchers;

  ProfileLoaded(this.profile, this.isAvailable, this.vouchers);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}