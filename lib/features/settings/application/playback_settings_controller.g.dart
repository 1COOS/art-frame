// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaybackSettingsController)
const playbackSettingsControllerProvider =
    PlaybackSettingsControllerProvider._();

final class PlaybackSettingsControllerProvider
    extends
        $AsyncNotifierProvider<PlaybackSettingsController, PlaybackSettings> {
  const PlaybackSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackSettingsControllerHash();

  @$internal
  @override
  PlaybackSettingsController create() => PlaybackSettingsController();
}

String _$playbackSettingsControllerHash() =>
    r'1d20995b4183a627072c855384d2b63aff7f2da5';

abstract class _$PlaybackSettingsController
    extends $AsyncNotifier<PlaybackSettings> {
  FutureOr<PlaybackSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<PlaybackSettings>, PlaybackSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlaybackSettings>, PlaybackSettings>,
              AsyncValue<PlaybackSettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
