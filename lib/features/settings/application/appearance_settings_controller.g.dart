// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppearanceSettingsController)
const appearanceSettingsControllerProvider =
    AppearanceSettingsControllerProvider._();

final class AppearanceSettingsControllerProvider
    extends
        $AsyncNotifierProvider<
          AppearanceSettingsController,
          AppearanceSettings
        > {
  const AppearanceSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceSettingsControllerHash();

  @$internal
  @override
  AppearanceSettingsController create() => AppearanceSettingsController();
}

String _$appearanceSettingsControllerHash() =>
    r'd790c7c154b856293990b055a524d7ac1e1021f5';

abstract class _$AppearanceSettingsController
    extends $AsyncNotifier<AppearanceSettings> {
  FutureOr<AppearanceSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<AppearanceSettings>, AppearanceSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppearanceSettings>, AppearanceSettings>,
              AsyncValue<AppearanceSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
