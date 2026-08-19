import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class HistoryRepository {
  final ApiClient apiClient;

  HistoryRepository(this.apiClient);

  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int limit = 10,
    String filter = 'today',
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Siapkan query parameter dasar
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'filter': filter,
      };

      // Tambahkan start_date dan end_date jika filter 'custom' dipilih
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;

      final response = await apiClient.dio.get(
        '/admin/orders/history',
        queryParameters: queryParams,
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal mengambil history transaksi');
    }
  }
}