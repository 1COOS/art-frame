import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/widgets/foundation_page_scaffold.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FoundationPageScaffold(
      title: l10n.galleryTitle,
      description: l10n.galleryBody,
    );
  }
}
