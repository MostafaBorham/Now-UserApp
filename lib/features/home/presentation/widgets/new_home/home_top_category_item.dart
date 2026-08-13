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
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.5,
              colors: [
                const Color(0xFF4968B7).withValues(alpha: 0.60),
                const Color(0xFF4963B7).withValues(alpha: 0.0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Assets.media.images.svg.starsBackground.svg(),
        ),
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors.onError,
                ),
                Column(
                  children: [
                    Text(
                      'Electronics Market',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.white,
                      ),
                    ),
                    StoreInfoRow(
                      infoFontSize: 15,
                      infoIconSize: 20,
                      deliveryTime: '40-50 mins',
                      distance: 40,
                      deliveryFee: 10,
                    )
                  ],
                )
              ],
            ),
            GridView.builder(
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 20,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return GlassProductItemView();
              },
            ),
            Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) => Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index==0? colors.white : Colors.transparent,
                  border: Border.all(
                    color: colors.white,
                  )
                ),

              ),).toList(),
            )
          ],
        )
      ],
    );
  }
}
