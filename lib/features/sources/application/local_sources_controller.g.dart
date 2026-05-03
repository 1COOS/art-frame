// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_sources_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalSourcesController)
const localSourcesControllerProvider = LocalSourcesControllerProvider._();

final class LocalSourcesControllerProvider
    extends $AsyncNotifierProvider<LocalSourcesController, List<MediaSource>> {
  const LocalSourcesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localSourcesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localSourcesControllerHash();

  @$internal
  @override
  LocalSourcesController create() => LocalSourcesController();
}

String _$localSourcesControllerHash() =>
    r'1308d673295f8d47c5ccd804c34e6180fbc66dcd';

abstract class _$LocalSourcesController
    extends $AsyncNotifier<List<MediaSource>> {
  FutureOr<List<MediaSource>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<MediaSource>>, List<MediaSource>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MediaSource>>, List<MediaSource>>,
              AsyncValue<List<MediaSource>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
