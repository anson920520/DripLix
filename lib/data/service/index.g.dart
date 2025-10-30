// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(floweyService)
const floweyServiceProvider = FloweyServiceProvider._();

final class FloweyServiceProvider
    extends $FunctionalProvider<FloweyService, FloweyService, FloweyService>
    with $Provider<FloweyService> {
  const FloweyServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'floweyServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$floweyServiceHash();

  @$internal
  @override
  $ProviderElement<FloweyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FloweyService create(Ref ref) {
    return floweyService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FloweyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FloweyService>(value),
    );
  }
}

String _$floweyServiceHash() => r'4f890f2ab24ccd261f511764ca50190660021c56';
