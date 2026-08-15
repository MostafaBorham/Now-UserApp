import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/top_categories_controller.dart'
    show currentTopCategoryIndexProvider, topCategoriesCountProvider;
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/glass_product_item_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

class HomeTopCategoryItem extends ConsumerWidget {
  const HomeTopCategoryItem({super.key});
  @override
  Widget build(BuildContext context,WidgetRef ref) {
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
                  colors.neutral500.withValues(alpha: 0.5),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            child: LayoutBuilder(
              builder: (context,con) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        CircleAvatar(
                          radius: con.maxWidth*0.07,
                          backgroundColor: colors.onError,
                          backgroundImage: NetworkImage(
                            'https://www.image2url.com/r2/default/images/1786626164813-6ce56bed-b383-4588-8d3a-e2cda5dc2efd.png',
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                'Electronics Market',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: con.maxWidth*0.05,
                                  fontWeight: FontWeight.w700,
                                  color: colors.white,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: StoreInfoRow(
                                  infoFontSize: con.maxWidth*0.04,
                                  infoIconSize: con.maxWidth*0.045,
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
                    2.hSpace,
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const rowsCount = 2;
                          const spacing = 12.0;

                          final itemHeight =
                              (constraints.maxHeight - spacing) / rowsCount;

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              mainAxisExtent: itemHeight,
                            ),
                            itemBuilder: (context, index) {
                              return const GlassProductItemView();
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        ref.read(topCategoriesCountProvider),
                        (index) => Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == ref.watch(currentTopCategoryIndexProvider) ? colors.white : Colors.transparent,
                            border: Border.all(color: colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}
