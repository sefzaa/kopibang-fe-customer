abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Dipanggil saat Login berhasil
class AuthAuthenticated extends AuthState {
  final String role;
  final String accessToken;
  final String refreshToken;

  AuthAuthenticated({
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });
}

// Dipanggil saat Logout berhasil
class AuthUnauthenticated extends AuthState {}

// Dipanggil saat ada error dari backend atau network
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}