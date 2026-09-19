abstract class DashboardState {}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> baristaStatus;
  final List<dynamic> recentOrders;
  DashboardLoaded(this.baristaStatus, this.recentOrders);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}