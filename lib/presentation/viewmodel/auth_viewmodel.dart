import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/auth.dart';
import '../../services/auth_state.dart';

class AuthViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 无初始化任务
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final AuthUseCase useCase = ref.read(authUseCaseProvider);
    try {
      await useCase.signIn(email, password);
      ref.read(authProvider.notifier).setLoggedIn(true);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError<Object>(e, st);
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    state = const AsyncLoading();
    final AuthUseCase useCase = ref.read(authUseCaseProvider);
    try {
      await useCase.signUp(username, email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError<Object>(e, st);
    }
  }
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(
  () => AuthViewModel(),
);


