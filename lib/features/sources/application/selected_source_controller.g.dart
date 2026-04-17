// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_source_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedSourceController)
const selectedSourceControllerProvider = SelectedSourceControllerProvider._();

final class SelectedSourceControllerProvider
    extends $AsyncNotifierProvider<SelectedSourceController, String?> {
  const SelectedSourceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedSourceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedSourceControllerHash();

  @$internal
  @override
  SelectedSourceController create() => SelectedSourceController();
}

String _$selectedSourceControllerHash() =>
    r'37f4379f9a996424b5a86f4da038eb56ebb9c27b';

abstract class _$SelectedSourceController extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
