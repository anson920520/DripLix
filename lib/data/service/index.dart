import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'secure_storage_service.dart';
part 'index.g.dart';

class FloweyService {
  final Dio dio = Dio();

  FloweyService._internal();

  static FloweyService createWithInterceptors({
    required SecureStorageService storage,
  }) {
    final FloweyService service = FloweyService._internal();
    service.dio.options.baseUrl =
        dotenv.env['FLOWEY_URL'] ?? 'http://64.176.227.70:9101/v1';
    service.dio.options.headers['Content-Type'] = 'application/json';
    service.dio.options.headers['Accept'] = 'application/json';

    service.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final String? token = await storage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // 可在此触发刷新逻辑（由上层AuthService处理更合适）
          }
          handler.next(error);
        },
      ),
    );
    return service;
  }

  void insertBearerToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
 
@riverpod
FloweyService floweyService(Ref ref) {
  final SecureStorageService storage = ref.read(secureStorageServiceProvider);
  return FloweyService.createWithInterceptors(storage: storage);
}