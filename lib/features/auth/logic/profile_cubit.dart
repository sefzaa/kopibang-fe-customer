import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> loadAllData() async {
    emit(ProfileLoading());
    try {
      final profile = await repository.getProfile();
      final status = await repository.getBaristaStatus();
      final vouchers = await repository.getVouchers();

      emit(ProfileLoaded(profile, status['is_available'] ?? false, vouchers));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleStatus(bool newVal) async {
    if (state is ProfileLoaded) {
      final currState = state as ProfileLoaded;

      // Optimistic Update
      emit(ProfileLoaded(currState.profile, newVal, currState.vouchers));

      try {
        await repository.updateBaristaStatus(newVal);
      } catch (e) {
        emit(ProfileLoaded(currState.profile, !newVal, currState.vouchers));
        emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  // --- VOUCHER CRUD ACTIONS ---
  Future<void> createVoucher(Map<String, dynamic> payload) async {
    try {
      await repository.addVoucher(payload);
      loadAllData(); // Refresh UI setelah berhasil disimpan
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // FUNGSI BARU UNTUK EDIT VOUCHER
  Future<void> editVoucher(String id, Map<String, dynamic> payload) async {
    try {
      await repository.updateVoucher(id, payload);
      loadAllData();
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteVoucher(String id) async {
    try {
      await repository.deleteVoucher(id);
      loadAllData();
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}