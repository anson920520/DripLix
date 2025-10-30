import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  const AuthRepository(this._service);

  Future<void> signIn(String email, String password) =>
      _service.signIn(email: email, password: password);

  Future<void> signUp(String username, String email, String password) =>
      _service.signUp(username: username, email: email, password: password);

  Future<void> refreshToken() => _service.refreshToken();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final AuthService service = ref.read(authServiceProvider);
  return AuthRepository(service);
});


