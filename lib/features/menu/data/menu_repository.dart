import 'package:dio/dio.dart';
import 'package:kopibang_customer/core/api_client.dart';

class MenuRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getMenus() async {
    try {
      final response = await _apiClient.dio.get('/menus');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat daftar menu';
    }
  }
}