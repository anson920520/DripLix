// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreRepository)
const exploreRepositoryProvider = ExploreRepositoryProvider._();

final class ExploreRepositoryProvider extends $FunctionalProvider<
    ExploreRepository,
    ExploreRepository,
    ExploreRepository> with $Provider<ExploreRepository> {
  const ExploreRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exploreRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exploreRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExploreRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExploreRepository create(Ref ref) {
    return exploreRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreRepository>(value),
    );
  }
}

String _$exploreRepositoryHash() => r'0a094332fbd235bfd0437a2c1c7c5978b94d5b92';
