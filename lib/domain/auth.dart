import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repository/auth_repository.dart';

part 'auth.g.dart';

class AuthUseCase {
  final AuthRepository _repo;

  const AuthUseCase(this._repo);

  Future<void> signIn(String email, String password) async {
    await _repo.signIn(email, password);
  }

  Future<void> signUp(String username, String email, String password) async {
    await _repo.signUp(username, email, password);
  }
}

@riverpod
AuthUseCase authUseCase(Ref ref) {
  final AuthRepository repo = ref.read(authRepositoryProvider);
  return AuthUseCase(repo);
}