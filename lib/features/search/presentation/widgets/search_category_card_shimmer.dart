import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';

/// Skeleton placeholder mirroring [CategoryCard]'s layout, meant to be
/// rendered inside an [AppShimmer] while categories are loading.
class SearchCategoryCardShimmer extends StatelessWidget {
  const SearchCategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // Only the image slot shimmers; the label area stays empty so the
    // skeleton reads as a bare card image while categories load.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 6,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: AppBorderRadius.brCircular10,
            ),
          ),
        ),
        // Reserves the real card's two-line label slot (kept blank).
        const SizedBox(height: 36),
      ],
    );
  }
}
