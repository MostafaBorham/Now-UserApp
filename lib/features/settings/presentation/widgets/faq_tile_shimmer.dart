import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Skeleton placeholder matching a collapsed [FaqTile]; wrap in [AppShimmer]
/// while the FAQ list is loading.
class FaqTileShimmer extends StatelessWidget {
  const FaqTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.onTertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
