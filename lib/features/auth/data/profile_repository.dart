import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class ProfileRepository {
  final ApiClient apiClient;
  ProfileRepository(this.apiClient);

  // HARDCODE: Karena Admin tidak punya endpoint API Profile sendiri
  Future<Map<String, dynamic>> getProfile() async {
    return {
      "name": "Admin Barista",
      "role": "SENIOR BARISTA"
    };
  }

  // API Asli: Cek status Barista
  Future<Map<String, dynamic>> getBaristaStatus() async {
    final response = await apiClient.dio.get('/settings/barista-status');
    return response.data['data'];
  }

  // API Asli: Update status Barista
  Future<void> updateBaristaStatus(bool isAvailable) async {
    await apiClient.dio.patch('/admin/settings/barista-status', data: {"is_available": isAvailable});
  }

  // --- VOUCHER CRUD (API ASLI) ---
  Future<List<dynamic>> getVouchers() async {
    final response = await apiClient.dio.get('/admin/vouchers');
    return response.data['data'] ?? [];
  }

  Future<void> addVoucher(Map<String, dynamic> data) async {
    await apiClient.dio.post('/admin/vouchers', data: data);
  }

  Future<void> updateVoucher(String id, Map<String, dynamic> data) async {
    await apiClient.dio.put('/admin/vouchers/$id', data: data);
  }

  Future<void> deleteVoucher(String id) async {
    await apiClient.dio.delete('/admin/vouchers/$id');
  }
}