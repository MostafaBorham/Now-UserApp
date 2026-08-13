import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/glass_product_item_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

class HomeTopCategoryItem extends StatelessWidget {
  const HomeTopCategoryItem({super.key});
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: AlignmentDirectional.topStart,
                radius: 0.5,
                colors: [
                  const Color(0xFF4968B7).withValues(alpha: 0.6),
                  const Color(0xFF4963B7).withValues(alpha: 0.2),
                ],
              ),
              image: DecorationImage(
                image: AssetImage(Assets.media.images.png.starsBackground.path),
                colorFilter: ColorFilter.mode(
                  colors.neutral300,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.onError,
                      backgroundImage: NetworkImage(
                        'https://www.image2url.com/r2/default/images/1786626164813-6ce56bed-b383-4588-8d3a-e2cda5dc2efd.png',
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            'Electronics Market',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: colors.white,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: StoreInfoRow(
                              infoFontSize: 15,
                              infoIconSize: 20,
                              deliveryTime: '40-50 mins',
                              distance: '40-50 km',
                              deliveryFee: '10',
                              color: colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const int crossAxisCount = 2;
                      const double mainAxisSpacing = 12;
                      const int rowCount = 2; // 4 items over 2 columns
                      final double itemHeight =
                          (constraints.maxHeight -
                              (mainAxisSpacing * (rowCount - 1))) /
                          rowCount;
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: itemHeight,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: mainAxisSpacing,
                        ),
                        itemBuilder: (context, index) {
                          return const GlassProductItemView();
                        },
                      );
                    },
                  ),
                ),
                Center(
                  child: Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0 ? colors.white : Colors.transparent,
                          border: Border.all(color: colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
