import 'package:dio/dio.dart';
import '../../../core/api_client.dart'; // Sesuaikan path ini

class DashboardRepository {
  final ApiClient apiClient;

  DashboardRepository(this.apiClient);

  // Tidak perlu lagi menerima parameter token
  Future<Map<String, dynamic>> getDashboardMetrics({String filter = 'today'}) async {
    try {
      // Menggunakan Dio. Parameter query 'filter' disisipkan via queryParameters
      final response = await apiClient.dio.get('/admin/dashboard', queryParameters: {
        'filter': filter,
      });

      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat data dashboard');
    }
  }
}