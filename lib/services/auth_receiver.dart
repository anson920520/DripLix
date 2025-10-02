import 'dart:async';

class AuthReceiverService {
  const AuthReceiverService();

  Future<Map<String, dynamic>> receiveSignIn({
    required String accountType,
    required String emailOrUsername,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'type': 'signIn',
      'accountType': accountType,
      'emailOrUsername': emailOrUsername,
      'password': password,
      'receivedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> receiveSignUp({
    required String username,
    required String email,
    required String verificationCode,
    required String password,
    required String confirmPassword,
    required String gender,
    required bool agreeTerms,
    required bool agreeMarketing,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return {
      'type': 'signUp',
      'username': username,
      'email': email,
      'verificationCode': verificationCode,
      'password': password,
      'confirmPassword': confirmPassword,
      'gender': gender,
      'agreeTerms': agreeTerms,
      'agreeMarketing': agreeMarketing,
      'receivedAt': DateTime.now().toIso8601String(),
    };
  }
}
