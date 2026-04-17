import 'package:flutter/foundation.dart';

@immutable
class PlaybackSettings {
  const PlaybackSettings({
    required this.autoplay,
    required this.intervalSeconds,
  });

  const PlaybackSettings.defaults()
    : autoplay = true,
      intervalSeconds = 5;

  factory PlaybackSettings.fromJson(Map<String, Object?> json) {
    return PlaybackSettings(
      autoplay: json['autoplay'] as bool? ?? true,
      intervalSeconds: json['intervalSeconds'] as int? ?? 5,
    );
  }

  final bool autoplay;
  final int intervalSeconds;

  PlaybackSettings copyWith({
    bool? autoplay,
    int? intervalSeconds,
  }) {
    return PlaybackSettings(
      autoplay: autoplay ?? this.autoplay,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'autoplay': autoplay,
      'intervalSeconds': intervalSeconds,
    };
  }
}
