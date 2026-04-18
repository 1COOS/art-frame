import '../domain/media_item.dart';

enum MediaLibraryPickStatus {
  success,
  cancelled,
  empty,
  permissionDenied,
  unsupported,
}

class MediaLibraryPickResult {
  const MediaLibraryPickResult._({
    required this.status,
    this.items = const <MediaItem>[],
  });

  const MediaLibraryPickResult.success(List<MediaItem> items)
    : this._(status: MediaLibraryPickStatus.success, items: items);

  const MediaLibraryPickResult.cancelled()
    : this._(status: MediaLibraryPickStatus.cancelled);

  const MediaLibraryPickResult.empty()
    : this._(status: MediaLibraryPickStatus.empty);

  const MediaLibraryPickResult.permissionDenied()
    : this._(status: MediaLibraryPickStatus.permissionDenied);

  const MediaLibraryPickResult.unsupported()
    : this._(status: MediaLibraryPickStatus.unsupported);

  final MediaLibraryPickStatus status;
  final List<MediaItem> items;
}
