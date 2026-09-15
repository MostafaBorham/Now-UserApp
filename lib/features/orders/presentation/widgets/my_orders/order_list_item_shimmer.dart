import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';




class OrderListItemShimmer extends StatelessWidget {
  const OrderListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color block = colors.neutral500.withValues(alpha: 0.3);

    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: AppBorderRadius.brCircular16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: AppBorderRadius.brCircular12,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 18,
                        decoration: BoxDecoration(
                          color: block,
                          borderRadius: AppBorderRadius.brCircular12,
                        ),
                      ),
                      8.hSpace,
                      Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: block,
                          borderRadius: AppBorderRadius.brCircular12,
                        ),
                      ),
                      10.hSpace,
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 24,
                            decoration: BoxDecoration(
                              color: block,
                              borderRadius: AppBorderRadius.brCircular20,
                            ),
                          ),
                          8.wSpace,
                          Container(
                            width: 72,
                            height: 24,
                            decoration: BoxDecoration(
                              color: block,
                              borderRadius: AppBorderRadius.brCircular20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: AppBorderRadius.brCircular12,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: block,
                      borderRadius: AppBorderRadius.brCircular12,
                    ),
                  ),
                ),
                12.wSpace,
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: block,
                      borderRadius: AppBorderRadius.brCircular12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderListViewShimmer extends StatelessWidget {
  const OrderListViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(



      padding: const EdgeInsets.fromLTRB(3, 57, 3, 3),
      itemCount: 4,
      separatorBuilder: (BuildContext context, int index) =>
      const SizedBox(height: 20),
      itemBuilder: (BuildContext context, int index) =>
      const AspectRatio(aspectRatio: 2, child: OrderListItemShimmer()),
    );
  }
}
