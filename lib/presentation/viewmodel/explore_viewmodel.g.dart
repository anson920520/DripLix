// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExploreViewModel)
const exploreViewModelProvider = ExploreViewModelProvider._();

final class ExploreViewModelProvider
    extends $AsyncNotifierProvider<ExploreViewModel, List<svc.ExplorePost>> {
  const ExploreViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exploreViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exploreViewModelHash();

  @$internal
  @override
  ExploreViewModel create() => ExploreViewModel();
}

String _$exploreViewModelHash() => r'3f68d32ec222bcd44b487618313ae4b729b21544';

abstract class _$ExploreViewModel
    extends $AsyncNotifier<List<svc.ExplorePost>> {
  FutureOr<List<svc.ExplorePost>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<List<svc.ExplorePost>>, List<svc.ExplorePost>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<svc.ExplorePost>>, List<svc.ExplorePost>>,
        AsyncValue<List<svc.ExplorePost>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
