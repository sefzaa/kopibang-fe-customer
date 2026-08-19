abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalSales;
  final int totalOrders;
  final int totalPointsRedeemed;
  final List<dynamic> menuStats;

  DashboardLoaded({
    required this.totalSales,
    required this.totalOrders,
    required this.totalPointsRedeemed,
    required this.menuStats,
  });
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}