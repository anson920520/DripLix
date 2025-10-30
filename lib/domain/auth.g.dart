// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authUseCase)
const authUseCaseProvider = AuthUseCaseProvider._();

final class AuthUseCaseProvider
    extends $FunctionalProvider<AuthUseCase, AuthUseCase, AuthUseCase>
    with $Provider<AuthUseCase> {
  const AuthUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authUseCaseHash();

  @$internal
  @override
  $ProviderElement<AuthUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthUseCase create(Ref ref) {
    return authUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthUseCase>(value),
    );
  }
}

String _$authUseCaseHash() => r'8a16487a2ac3f18871a93e49ff31b78bebf530da';
