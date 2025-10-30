// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreUseCase)
const exploreUseCaseProvider = ExploreUseCaseProvider._();

final class ExploreUseCaseProvider
    extends $FunctionalProvider<ExploreUseCase, ExploreUseCase, ExploreUseCase>
    with $Provider<ExploreUseCase> {
  const ExploreUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exploreUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exploreUseCaseHash();

  @$internal
  @override
  $ProviderElement<ExploreUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExploreUseCase create(Ref ref) {
    return exploreUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreUseCase>(value),
    );
  }
}

String _$exploreUseCaseHash() => r'a4f3fc6b6e3c4e3cb85db9073e28581c222601eb';
