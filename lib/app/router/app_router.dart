import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shell/adaptive_shell.dart';
import '../theme/app_motion.dart';
import '../../features/connect/presentation/connect_page.dart';
import '../../features/connect/presentation/network_config_page.dart';
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
      GoRoute(
        path: AppDestination.networkConfig.path,
        pageBuilder: (context, state) {
          final args = state.extra as NetworkConfigPageArgs?;
          return CustomTransitionPage(
            child: NetworkConfigPage(args: args),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: AppMotion.curve,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              );
            },
            transitionDuration: AppMotion.standard,
            reverseTransitionDuration: AppMotion.standard,
          );
        },
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
