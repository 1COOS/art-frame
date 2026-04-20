import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/adaptive_shell.dart';
import '../../features/playback/presentation/playback_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/sources/presentation/sources_page.dart';
import 'app_destination.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppDestination.sources.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestination.sources.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SourcesPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestination.settings.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppDestination.playback.path,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PlaybackPage(),
        ),
      ),
    ],
    redirect: (context, state) {
      if (state.matchedLocation == '/') {
        return AppDestination.sources.path;
      }
      return null;
    },
  );
});
