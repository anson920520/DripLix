import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'index.dart';
import 'secure_storage_service.dart';
part 'auth_service.g.dart';

class AuthService {
  final FloweyService _flowey;
  final SecureStorageService _storage;

  AuthService({required FloweyService flowey, required SecureStorageService storage})
      : _flowey = flowey,
        _storage = storage;

  Future<void> signIn({required String email, required String password}) async {
    final Response<dynamic> res = await _flowey.dio.post('/auth/signin',
        data: <String, dynamic>{'email': email, 'password': password});
    final Map<String, dynamic> data = (res.data as Map).cast<String, dynamic>();
    final String access = data['accessToken'] as String;
    final String refresh = data['refreshToken'] as String;
    await _storage.saveTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    await _flowey.dio.post('/auth/signup', data: <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<void> refreshToken() async {
    final String? refresh = await _storage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw StateError('No refresh token');
    }
    final Response<dynamic> res =
        await _flowey.dio.post('/auth/refresh', data: <String, dynamic>{'refreshToken': refresh});
    final Map<String, dynamic> data = (res.data as Map).cast<String, dynamic>();
    final String access = data['accessToken'] as String;
    final String newRefresh = (data['refreshToken'] as String?) ?? refresh;
    await _storage.saveTokens(accessToken: access, refreshToken: newRefresh);
  }
}
 
@riverpod
AuthService authService(Ref ref) {
  final FloweyService flowey = ref.read(floweyServiceProvider);
  final SecureStorageService storage = ref.read(secureStorageServiceProvider);
  return AuthService(flowey: flowey, storage: storage);
}

