import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/media_item.dart';
import '../domain/media_source.dart';

final bundledSourcesProvider = Provider<List<MediaSource>>((ref) {
  return const [
    MediaSource(
      id: 'foundation-gallery',
      title: 'Foundation Gallery',
      description: 'Bundled screenshots from the current Flutter shell for the first playback loop.',
      badge: 'bundled',
      kind: MediaSourceKind.bundled,
      items: [
        MediaItem(
          id: 'gallery-phone',
          title: 'Gallery phone',
          path: 'art-frame-gallery-phone.png',
          description: 'Compact preview captured from the Flutter shell.',
        ),
        MediaItem(
          id: 'wide-shell',
          title: 'Wide shell',
          path: 'art-frame-wide.png',
          description: 'Wide adaptive shell baseline screenshot.',
        ),
        MediaItem(
          id: 'web-gallery-phone',
          title: 'Web gallery phone',
          path: 'art-frame-webserver-gallery-phone.png',
          description: 'Bundled web-server phone layout verification image.',
        ),
        MediaItem(
          id: 'web-gallery-wide',
          title: 'Web gallery wide',
          path: 'art-frame-webserver-wide.png',
          description: 'Bundled web-server wide layout verification image.',
        ),
      ],
    ),
  ];
});

