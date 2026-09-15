import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';





class OnlineCardRadioSelectorItemShimmer extends StatelessWidget {
  const OnlineCardRadioSelectorItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color block = colors.neutral500.withValues(alpha: 0.3);

    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: colors.neutral500.withValues(alpha: 0.1),
          borderRadius: AppBorderRadius.brCircular12,
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: block),
            ),
            10.wSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Container(
                    height: 16,
                    width: 140,
                    decoration: BoxDecoration(
                      color: block,
                      borderRadius: AppBorderRadius.brCircular30,
                    ),
                  ),
                  Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: block,
                      borderRadius: AppBorderRadius.brCircular30,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 25,
              height: 16,
              decoration: BoxDecoration(
                color: block,
                borderRadius: AppBorderRadius.brCircular30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
