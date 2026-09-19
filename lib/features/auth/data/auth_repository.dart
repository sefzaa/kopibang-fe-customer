import 'package:dio/dio.dart';
import '../../../core/api_client.dart'; // Corrected path
import '../../../core/secure_storage_helper.dart'; // Corrected path

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageHelper _secureStorage = SecureStorageHelper();

  // Fungsi Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login', // Berdasarkan endpoint Swagger
        data: {
          "email": email,
          "password": password,
        },
      );

      // Simpan token ke storage
      final data = response.data['data'];
      await _secureStorage.saveToken(data['access_token']);
      await _secureStorage.saveRefreshToken(data['refresh_token']);

      return data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Terjadi kesalahan saat login';
    }
  }

  // Fungsi Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String rewritePassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register', // Berdasarkan endpoint Swagger
        data: {
          "name": name,
          "username": username,
          "email": email,
          "password": password,
          "rewrite_password": rewritePassword,
        },
      );

      // Otomatis login (simpan token) setelah sukses register
      final data = response.data['data'];
      await _secureStorage.saveToken(data['access_token']);
      await _secureStorage.saveRefreshToken(data['refresh_token']);

      return data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Terjadi kesalahan saat registrasi';
    }
  }
}