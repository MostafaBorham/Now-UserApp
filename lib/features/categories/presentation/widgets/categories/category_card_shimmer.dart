import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';

/// Skeleton placeholder mirroring [CategoryCard]'s layout, meant to be
/// rendered inside an [AppShimmer] while categories are loading.
class CategoryCardShimmer extends StatelessWidget {
  const CategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: AppBorderRadius.brCircular12,
            ),
          ),
        ),
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: colors.onPrimary,
            borderRadius: AppBorderRadius.brCircular4,
          ),
        ),
      ],
    );
  }
}
