import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'secure_storage_service.g.dart';

class SecureStorageService {
  static const String _keyAccessToken = 'bearer_token';
  static const String _keyRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _keyAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}
 
@riverpod
SecureStorageService secureStorageService(Ref ref) {
  const FlutterSecureStorage storage = FlutterSecureStorage();
  return SecureStorageService(storage);
}

