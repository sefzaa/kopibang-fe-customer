import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  DashboardCubit(this.repository) : super(DashboardInitial());

  // Hapus parameter 'token', cukup sisakan 'filter'
  Future<void> fetchDashboard({String filter = 'today'}) async {
    emit(DashboardLoading());
    try {
      final data = await repository.getDashboardMetrics(filter: filter);

      emit(DashboardLoaded(
        totalSales: data['total_sales'] ?? 0,
        totalOrders: data['total_orders'] ?? 0,
        totalPointsRedeemed: data['total_points_redeemed'] ?? 0,
        menuStats: data['menu_stats'] ?? [],
      ));
    } catch (e) {
      emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}