import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class HomeAppCategorySectionView extends StatelessWidget {
  const HomeAppCategorySectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      children: [
        Positioned.fill(child: Assets.media.images.svg.oneWaveBackground.svg()),
        Column(
          spacing: 24,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Electronics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.black,
                  ),
                ),
                HomeViewAllWidget(
                  size: 15,
                  startBackgroundColor: colors.secondaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  endBackgroundColor: colors.secondaryContainer.withValues(
                    alpha: 0.2,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ProductItem3View();
                },
                separatorBuilder: (context, index) => 8.wSpace,
                itemCount: 5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}