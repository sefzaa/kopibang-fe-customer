import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  DashboardCubit({required this.repository}) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final baristaData = await repository.getBaristaStatus();
      final recentOrdersData = await repository.getRecentOrders();
      emit(DashboardLoaded(baristaData, recentOrdersData));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<String?> requestRedeemQr() async {
    try {
      return await repository.generateRedeemQr();
    } catch (e) {
      throw e.toString(); // Ubah baris ini agar error diteruskan ke UI
    }
  }

  Future<void> processEarnQr(String token) async {
    try {
      await repository.scanEarnPoint(token);
    } catch (e) {
      throw e.toString();
    }
  }
}