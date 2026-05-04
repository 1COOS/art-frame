import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shell/adaptive_shell.dart';
import '../../features/connect/presentation/connect_page.dart';
import '../../features/playback/presentation/playback_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/sources/presentation/sources_page.dart';
import 'app_destination.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppDestination.library.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestination.library.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SourcesPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestination.connect.path,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ConnectPage(),
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
        return AppDestination.library.path;
      }
      return null;
    },
  );
});
