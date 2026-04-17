import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/adaptive/adaptive_layout.dart';
import '../../app/adaptive/app_breakpoints.dart';
import '../../app/l10n/generated/app_localizations.dart';

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
            label: l10n.homeTab,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
          _ShellDestination(
            label: l10n.galleryTab,
            icon: Icons.photo_library_outlined,
            selectedIcon: Icons.photo_library,
          ),
          _ShellDestination(
            label: l10n.settingsTab,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
          ),
        ];

        final body = navigationShell;
        final appBar = AppBar(title: Text(l10n.appTitle));

        if (type.usesBottomNavigation) {
          return Scaffold(
            appBar: appBar,
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
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
          appBar: appBar,
          body: Row(
            children: [
              if (type.usesRail)
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _goBranch,
                  labelType: NavigationRailLabelType.all,
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
                NavigationDrawer(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    _goBranch(index);
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 16, 16, 12),
                      child: Text(
                        l10n.appTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    for (final item in destinations)
                      NavigationDrawerDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: type.usesSidebar
                        ? const Border(
                            left: BorderSide(color: Color(0x14000000)),
                          )
                        : null,
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
