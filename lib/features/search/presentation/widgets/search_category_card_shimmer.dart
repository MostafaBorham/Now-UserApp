import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Skeleton placeholder for [SearchCategoryCard], rendered inside an
/// [AppShimmer] while categories load.
///
/// It fills the whole shared cell with a single rounded block, so — sized by
/// the strip's SizedBox(width: a third of the screen) + AspectRatio(0.85) — it
/// shimmers at exactly the card's width and height.
class SearchCategoryCardShimmer extends StatelessWidget {
  const SearchCategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: colors.white,
          borderRadius: AppBorderRadius.brCircular12,
          boxShadow: [BoxShadow(
              color: colors.black.withValues(alpha: 0.25),
              blurRadius: 1.35,
              spreadRadius: 0,
              offset: Offset(0, 0)
          )]
      ),
      child: AppShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: AppBorderRadius.brCircular12,
          ),
        ),
      ),
    );
  }
}
