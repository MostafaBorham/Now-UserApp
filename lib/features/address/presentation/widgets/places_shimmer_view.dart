import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';







class PlacesShimmerView extends StatelessWidget {
  const PlacesShimmerView({super.key, this.itemCount = 6});


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

            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[

                  Container(
                    height: 14,
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.neutral500,
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
