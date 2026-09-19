import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final data = await authRepository.login(email, password);
      emit(AuthAuthenticated(data['role']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String rewritePassword,
  }) async {
    emit(AuthLoading());
    try {
      final data = await authRepository.register(
        name: name,
        username: username,
        email: email,
        password: password,
        rewritePassword: rewritePassword,
      );
      emit(AuthAuthenticated(data['role']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}