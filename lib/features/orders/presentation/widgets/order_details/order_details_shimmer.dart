import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Skeleton placeholder for [OrderDetailsScreen] — a header row and a stack of
/// section cards — so the loading state lays out like the real details screen
/// instead of a bare spinner.
class OrderDetailsShimmer extends StatelessWidget {
  const OrderDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color block = colors.neutral500.withValues(alpha: 0.3);

    Widget box({double? width, double height = 14}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: block,
        borderRadius: AppBorderRadius.brCircular12,
      ),
    );

    Widget card(double height) => Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: block,
        borderRadius: AppBorderRadius.brCircular12,
      ),
    );

    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        // Matches the loaded content's top spacing so the loading and data
        // states line up under the wave (AppWavedView drops the body's top
        // padding once a scroll controller is wired in).
        padding: const EdgeInsets.only(top: 57),
        child: Column(
          spacing: 15,
          children: [
            Row(
              spacing: 8,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: block,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: 90, height: 12),
                      6.hSpace,
                      box(width: 140, height: 18),
                    ],
                  ),
                ),
                box(width: 70, height: 26),
              ],
            ),
            card(150),
            card(120),
            card(120),
            card(48),
            card(120),
            card(220),
          ],
        ),
      ),
    );
  }
}
