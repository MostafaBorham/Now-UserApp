import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Loading view for the address search results.
///
/// Self-contained: renders a non-scrolling list of skeleton rows shaped like
/// the real suggestion tiles — leading icon, short title line, long subtitle
/// line — so the results area keeps its layout instead of collapsing onto a
/// spinner while Places answers.
class PlacesShimmerView extends StatelessWidget {
  const PlacesShimmerView({super.key, this.itemCount = 6});

  /// Number of skeleton rows to render.
  final int itemCount;

  static const double _rowGap = 20;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: _rowGap),
      itemBuilder: (_, _) => AppShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            // Stands in for the leading search icon.
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.onSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  // Title — a short main text such as "Cairo".
                  Container(
                    height: 14,
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: colors.onSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Subtitle — the longer secondary line.
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.onSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
