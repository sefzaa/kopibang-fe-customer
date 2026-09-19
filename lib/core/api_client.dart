import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_storage_helper.dart'; // Corrected path (same folder)

class ApiClient {
  late Dio dio;
  final SecureStorageHelper _secureStorage = SecureStorageHelper();

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? 'https://kopibang.mydm.cloud/api/v1/',
      connectTimeout: Duration(seconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '15')),
      receiveTimeout: Duration(seconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '15')),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            bool isRefreshed = await _refreshToken();
            if (isRefreshed) {
              final newToken = await _secureStorage.getToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final cloneReq = await dio.fetch(e.requestOptions);
              return handler.resolve(cloneReq);
            } else {
              await _secureStorage.clearAll();
              // Routing handled by UI or root router listening to state
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final tempDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final response = await tempDio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final data = response.data['data'];
      await _secureStorage.saveToken(data['access_token']);
      await _secureStorage.saveRefreshToken(data['refresh_token']);
      return true;
    } catch (e) {
      return false;
    }
  }
}