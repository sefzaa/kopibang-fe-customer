abstract class HistoryState {}
class HistoryInitial extends HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final List<dynamic> orders;
  final bool hasReachedMax; // Penanda jika data sudah habis
  final int currentPage;
  HistoryLoaded(this.orders, {this.hasReachedMax = false, this.currentPage = 1});
}
class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}