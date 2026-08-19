import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;
  HistoryCubit(this.repository) : super(HistoryInitial());

  Future<void> fetchHistory({
    bool isRefresh = false,
    String filter = 'this_month',
    int limit = 10,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final currentState = state;
      int page = 1;
      List<dynamic> oldOrders = [];

      if (!isRefresh && currentState is HistoryLoaded) {
        if (currentState.hasReachedMax) return;
        page = currentState.currentPage + 1;
        oldOrders = currentState.orders;
      } else {
        emit(HistoryLoading());
      }

      final data = await repository.getHistory(
        page: page,
        limit: limit,
        filter: filter,
        startDate: startDate,
        endDate: endDate,
      );
      final newOrders = data['orders'] as List<dynamic>? ?? [];

      bool hasReachedMax = newOrders.length < limit;

      emit(HistoryLoaded(
        [...oldOrders, ...newOrders],
        hasReachedMax: hasReachedMax,
        currentPage: page,
      ));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}