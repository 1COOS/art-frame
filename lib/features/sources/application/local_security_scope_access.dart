import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/media_source.dart';
import 'local_security_scope_access_stub.dart'
    if (dart.library.io) 'local_security_scope_access_io.dart' as impl;

class LocalSecurityScopeAccess {
  const LocalSecurityScopeAccess();

  Future<void> persistSourceAccess(MediaSource source) {
    return impl.persistSourceAccess(source);
  }

  Future<void> restoreAccess(List<MediaSource> sources) {
    return impl.restoreAccess(sources);
  }

  Future<void> syncSources(List<MediaSource> sources) {
    return impl.syncSources(sources);
  }
}

final localSecurityScopeAccessProvider = Provider<LocalSecurityScopeAccess>((
  ref,
) {
  return const LocalSecurityScopeAccess();
});
