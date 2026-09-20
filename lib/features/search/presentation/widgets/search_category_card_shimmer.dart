import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

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
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.25),
            blurRadius: 1.35,
            spreadRadius: 0,
            offset: Offset(0, 0),
          )
        ],
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
