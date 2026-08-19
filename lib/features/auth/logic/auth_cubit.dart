import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/secure_storage_helper.dart'; // Import storage
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await repository.login(email, password);

      final String accessToken = result['access_token'];
      final String refreshToken = result['refresh_token'];
      // Jika di payload backend ada role/status lain, bisa disesuaikan
      final String role = result['role'] ?? 'admin';

      // 1. SIMPAN TOKEN KE DALAM BRANKAS HP (Agar fitur auto-login bekerja)
      await SecureStorageHelper.saveAuthData(accessToken, refreshToken, role);

      emit(AuthAuthenticated(
        role: role,
        accessToken: accessToken,
        refreshToken: refreshToken,
      ));
    } catch (e) {
      emit(AuthError(_cleanErrorMessage(e)));
    }
  }

  // Ubah parameter logout, kita tidak perlu mengirim token dari UI lagi
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      // Ambil refresh token dari brankas untuk dikirim ke backend
      final refreshToken = await SecureStorageHelper.getRefreshToken() ?? '';

      await repository.logout(refreshToken);

      // 2. BERSIHKAN BRANKAS SAAT LOGOUT
      await SecureStorageHelper.clearTokens();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_cleanErrorMessage(e)));
    }
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}