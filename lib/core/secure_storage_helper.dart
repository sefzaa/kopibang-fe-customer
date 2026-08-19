import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'role';

  static Future<void> saveAuthData(String access, String refresh, String role) async {
    await _storage.write(key: _tokenKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _roleKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }
}