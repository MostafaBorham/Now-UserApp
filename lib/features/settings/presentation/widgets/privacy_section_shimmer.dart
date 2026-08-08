import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Skeleton placeholder matching a [PrivacySection] (a title bar over a few
/// body lines); wrap in [AppShimmer] while the privacy content is loading.
class PrivacySectionShimmer extends StatelessWidget {
  const PrivacySectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = BoxDecoration(
      color: context.colors.onTertiaryContainer,
      borderRadius: BorderRadius.circular(6),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 140, height: 18, decoration: decoration),
        const SizedBox(height: 12),
        Container(width: double.infinity, height: 12, decoration: decoration),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 12, decoration: decoration),
        const SizedBox(height: 8),
        Container(width: 220, height: 12, decoration: decoration),
      ],
    );
  }
}
