import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async => await _storage.write(key: 'access_token', value: token);
  Future<String?> getToken() async => await _storage.read(key: 'access_token');
  Future<void> deleteToken() async => await _storage.delete(key: 'access_token');

  Future<void> saveRefreshToken(String token) async => await _storage.write(key: 'refresh_token', value: token);
  Future<String?> getRefreshToken() async => await _storage.read(key: 'refresh_token');
  Future<void> deleteRefreshToken() async => await _storage.delete(key: 'refresh_token');

  Future<void> clearAll() async => await _storage.deleteAll();
}