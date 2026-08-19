import 'package:dio/dio.dart';
import '../../../core/api_client.dart'; // Sesuaikan path ini

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post('/admin/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal melakukan login');
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      // Access token sudah otomatis disisipkan oleh ApiClient
      await apiClient.dio.post('/auth/logout', data: {
        'refresh_token': refreshToken,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal logout');
    }
  }
}