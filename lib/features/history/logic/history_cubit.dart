import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repository;
  int _currentPage = 1;
  final int _limit = 10; // Ambil 10 data per request

  HistoryCubit({required this.repository}) : super(HistoryInitial());

  Future<void> loadHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    final currentState = state;
    var oldOrders = <dynamic>[];

    // Jika bukan refresh dan data sedang dimuat, abaikan agar tidak dobel request
    if (currentState is HistoryLoading && !isRefresh) return;

    if (currentState is HistoryLoaded) {
      if (!isRefresh && currentState.hasReachedMax) return;
      oldOrders = currentState.orders;
    }

    emit(HistoryLoading(oldOrders, isFirstFetch: _currentPage == 1));

    try {
      final data = await repository.fetchOrderHistory(_currentPage, _limit);
      final List<dynamic> newOrders = data['orders'] ?? [];
      final Map<String, dynamic> meta = data['meta'] ?? {};

      final int totalPages = meta['total_pages'] ?? 1;
      final bool hasReachedMax = _currentPage >= totalPages;

      if (isRefresh) {
        emit(HistoryLoaded(newOrders, hasReachedMax: hasReachedMax));
      } else {
        emit(HistoryLoaded(oldOrders + newOrders, hasReachedMax: hasReachedMax));
      }

      if (!hasReachedMax) {
        _currentPage++;
      }
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}