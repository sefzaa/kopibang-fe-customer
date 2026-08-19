import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart'; // Sesuaikan path ini

class MenuRepository {
  final ApiClient apiClient;

  MenuRepository(this.apiClient);

  Future<List<dynamic>> getMenus() async {
    try {
      final response = await apiClient.dio.get('/menus');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil menu');
    }
  }

  Future<void> createMenu(Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/admin/menus', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal membuat menu');
    }
  }

  Future<void> updateMenu(String id, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.put('/admin/menus/$id', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal update menu');
    }
  }

  Future<void> deleteMenu(String id) async {
    try {
      await apiClient.dio.delete('/admin/menus/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus menu');
    }
  }

  Future<void> toggleMenuStatus(String id) async {
    try {
      await apiClient.dio.patch('/admin/menus/$id/status');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengubah status menu');
    }
  }

  // UPLOAD GAMBAR MENGGUNAKAN DIO FORMDATA
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await apiClient.dio.post('/admin/upload', data: formData);
      return response.data['data']['image_url'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengupload gambar');
    }
  }
}