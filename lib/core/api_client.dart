import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'secure_storage_helper.dart';

class ApiClient {
  late Dio dio;

  // Sistem antrean menggunakan Future untuk mencegah double refresh
  static Future<void>? _refreshTokenFuture;

  ApiClient() {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8080/api/v1';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
      ),
    );

    // Mengatasi masalah sertifikat SSL lokal/development jika diperlukan
    final adapter = IOHttpClientAdapter();
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    dio.httpClientAdapter = adapter;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageHelper.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Tangkap pesan error dari backend jika ada[cite: 11]
        if (e.response?.data != null && e.response?.data is Map) {
          final errorMessage = e.response?.data['message'] ?? 'Something went wrong';
          e = e.copyWith(message: errorMessage);
        }

        // Logic Auto-Refresh Token saat mendeteksi 401 Unauthorized[cite: 11]
        if (e.response?.statusCode == 401) {
          if (_refreshTokenFuture == null) {
            _refreshTokenFuture = _performRefresh(baseUrl, adapter);
          }

          try {
            // Request lain ikut menunggu di sini sampai proses refresh selesai[cite: 11]
            await _refreshTokenFuture;

            // Ambil token baru yang sudah disimpan di brankas[cite: 11]
            final newToken = await SecureStorageHelper.getAccessToken();
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            // Ulangi request awal yang sempat gagal[cite: 11]
            final retryResponse = await dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } catch (error) {
            // Jika refresh token gagal/expired, teruskan error agar trigger logout[cite: 11]
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  // Fungsi khusus untuk mengeksekusi Refresh Token ke Backend Go
  Future<void> _performRefresh(String baseUrl, IOHttpClientAdapter adapter) async {
    try {
      final refreshToken = await SecureStorageHelper.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      refreshDio.httpClientAdapter = adapter;

      // Sesuaikan endpoint refresh dengan route di backend Go kamu (misal: /auth/refresh)
      final response = await refreshDio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      // Backend membungkus data di dalam key ['data']
      final resData = response.data['data'] ?? response.data;
      final newAccess = resData['access_token'];
      final newRefresh = resData['refresh_token'];
      final role = resData['role'] ?? 'admin';

      await SecureStorageHelper.saveAuthData(newAccess, newRefresh, role);
    } catch (e) {
      await SecureStorageHelper.clearTokens();
      rethrow;
    } finally {
      _refreshTokenFuture = null; // Kosongkan antrean
    }
  }
}