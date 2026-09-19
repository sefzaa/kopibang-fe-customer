import 'package:dio/dio.dart';
import '../../../core/api_client.dart'; // Corrected path
import '../../../core/secure_storage_helper.dart'; // Corrected path

class ProfileRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageHelper _secureStorage = SecureStorageHelper();

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load profile';
    }
  }

  Future<void> updateProfile(String name, String username) async {
    try {
      await _apiClient.dio.put('/profile', data: {
        "name": name,
        "username": username,
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update profile';
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.dio.post('/auth/logout', data: {
          "refresh_token": refreshToken,
        });
      }
    } catch (e) {
      // Abaikan error jaringan saat logout, paksa hapus storage lokal
    } finally {
      await _secureStorage.clearAll();
    }
  }
}