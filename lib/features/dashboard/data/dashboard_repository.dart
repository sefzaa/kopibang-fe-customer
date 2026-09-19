import 'package:dio/dio.dart';
import 'package:kopibang_customer/core/api_client.dart';

class DashboardRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getBaristaStatus() async {
    try {
      final response = await _apiClient.dio.get('/settings/barista-status');
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengambil status barista';
    }
  }

  Future<List<dynamic>> getRecentOrders() async {
    try {
      final response = await _apiClient.dio.get('/user/orders/history', queryParameters: {
        'page': 1,
        'limit': 5, // Sesuai permintaan, limit 5 order terakhir
      });
      return response.data['data']['orders'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengambil riwayat';
    }
  }

  Future<String> generateRedeemQr() async {
    try {
      final response = await _apiClient.dio.post('/points/redeem-qr');
      return response.data['data']['redeem_token'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal membuat QR Redeem';
    }
  }
  Future<void> scanEarnPoint(String earnToken) async {
    try {
      await _apiClient.dio.post('/points/scan-earn', data: {
        "earn_token": earnToken,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memproses QR Code';
    }
  }
}