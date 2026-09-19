abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {
  final List<dynamic> oldOrders;
  final bool isFirstFetch;

  HistoryLoading(this.oldOrders, {this.isFirstFetch = false});
}

class HistoryLoaded extends HistoryState {
  final List<dynamic> orders;
  final bool hasReachedMax;

  HistoryLoaded(this.orders, {this.hasReachedMax = false});
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}