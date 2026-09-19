import 'package:dio/dio.dart';
import 'package:kopibang_customer/core/api_client.dart';

class HistoryRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fetchOrderHistory(int page, int limit) async {
    try {
      final response = await _apiClient.dio.get(
        '/user/orders/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      // Mengembalikan map berisi 'orders' dan 'meta'
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat riwayat pesanan';
    }
  }
}