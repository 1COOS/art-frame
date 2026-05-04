import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../adaptive/adaptive_layout.dart';
import '../adaptive/app_breakpoints.dart';
import '../l10n/generated/app_localizations.dart';

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      builder: (context, type) {
        final l10n = AppLocalizations.of(context);
        final destinations = [
          _ShellDestination(
            label: l10n.libraryTab,
            icon: Icons.photo_library_outlined,
            selectedIcon: Icons.photo_library,
          ),
          _ShellDestination(
            label: l10n.connectTab,
            icon: Icons.add_link_outlined,
            selectedIcon: Icons.add_link,
          ),
          _ShellDestination(
            label: l10n.settingsTab,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
          ),
        ];

        final body = navigationShell;

        if (type.usesBottomNavigation) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                for (final item in destinations)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              if (type.usesRail)
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  labelType: NavigationRailLabelType.none,
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              if (type.usesSidebar)
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  labelType: NavigationRailLabelType.none,
                  destinations: [
                    for (final item in destinations)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: body,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
