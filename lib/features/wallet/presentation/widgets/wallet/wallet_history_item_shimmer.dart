import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Skeleton placeholder mirroring [WalletHistoryItem]'s geometry — the circular
/// logo, the merchant-name bar, the status chip and the amount — as blank
/// shimmering blocks. It carries no real content, only the layout, so the
/// loading state lays out exactly like a real transaction row.
class WalletHistoryItemShimmer extends StatelessWidget {
  const WalletHistoryItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color block = colors.neutral500.withValues(alpha: 0.3);

    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, con) {
          final double width = con.maxWidth;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              color: colors.neutral500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(width * 0.1),
            ),
            child: Row(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: width * 0.14,
                        height: width * 0.14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: block,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: width * 0.045,
                          decoration: BoxDecoration(
                            color: block,
                            borderRadius: AppBorderRadius.brCircular30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width * 0.2,
                  height: width * 0.075,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: AppBorderRadius.brCircular30,
                  ),
                ),
                Container(
                  width: width * 0.14,
                  height: width * 0.045,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: AppBorderRadius.brCircular30,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
