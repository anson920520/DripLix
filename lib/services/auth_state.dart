import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool loggedIn) {
    if (_isLoggedIn == loggedIn) return;
    _isLoggedIn = loggedIn;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthState> {
  const AuthScope(
      {Key? key, required AuthState notifier, required Widget child})
      : super(key: key, notifier: notifier, child: child);

  static AuthState of(BuildContext context) {
    final AuthScope? scope =
        context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null,
        'AuthScope not found in context. Ensure MaterialApp is wrapped.');
    return scope!.notifier!;
  }
}
