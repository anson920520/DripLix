import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  bool build() {
    return false;
  }
  
  void setLoggedIn(bool loggedIn) {
    state = loggedIn;
  }
}
