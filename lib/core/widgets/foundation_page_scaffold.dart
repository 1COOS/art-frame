import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/adaptive/adaptive_layout.dart';
import '../../app/adaptive/app_breakpoints.dart';
import '../../app/l10n/generated/app_localizations.dart';

class FoundationPageScaffold extends StatelessWidget {
  const FoundationPageScaffold({
    super.key,
    required this.title,
    required this.description,
    this.footer,
  });

  final String title;
  final String description;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = GoRouterState.of(context).uri.toString();

    return AdaptiveLayout(
      builder: (context, type) {
        final String layoutLabel;
        if (type == AdaptiveWindowType.phone) {
          layoutLabel = l10n.phoneLayout;
        } else if (type == AdaptiveWindowType.tablet) {
          layoutLabel = l10n.tabletLayout;
        } else {
          layoutLabel = l10n.wideLayout;
        }

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoCard(
                  label: l10n.currentRouteLabel,
                  value: route,
                ),
                _InfoCard(
                  label: l10n.currentDeviceLabel,
                  value: layoutLabel,
                ),
              ],
            ),
            if (footer != null) ...[
              const SizedBox(height: 24),
              footer!,
            ],
            const SizedBox(height: 24),
            Text(
              l10n.shellHeadline,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(l10n.shellDescription),
          ],
        );

        final double maxWidth;
        if (type == AdaptiveWindowType.phone) {
          maxWidth = 680;
        } else if (type == AdaptiveWindowType.tablet) {
          maxWidth = 840;
        } else {
          maxWidth = 1040;
        }

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
