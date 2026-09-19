abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role; // Untuk menyimpan role dari token response
  AuthAuthenticated(this.role);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}