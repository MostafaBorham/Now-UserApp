import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/featured_stores_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/glass_product_item_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';






class HomeFeaturedStoreItem extends StatelessWidget {
  const HomeFeaturedStoreItem({
    super.key,
    required this.store,
    required this.storesCount,
  });

  final StoreModel store;


  final int storesCount;



  static const int _maxProducts = 4;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<ProductModel> products =
        (store.products ?? const <ProductModel>[]).take(_maxProducts).toList();


    final Color tint = store.storeColor ?? const Color(0xFF4968B7);
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: AlignmentDirectional.topStart,
                radius: 0.5,
                colors: [
                  tint.withValues(alpha: 0.6),
                  tint.withValues(alpha: 0.2),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LayoutBuilder(
              builder: (context, con) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    InkWell(
                      onTap: store.id == null
                          ? null
                          : () => context.pushNamed(
                              AppRoutes.storeDetailsScreen,
                              extra: store.id,
                            ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          CircularBrandLogo(
                            radius: con.maxWidth * 0.07,
                            logoUrl: store.logoUrl ?? '',
                            backgroundColor: colors.onError,


                            logoScale: 2,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Text(
                                  context.getLocalizedApiText(store.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: con.maxWidth * 0.05,
                                    fontWeight: FontWeight.w700,
                                    color: colors.white,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: StoreInfoRow(
                                    infoFontSize: con.maxWidth * 0.04,
                                    infoIconSize: con.maxWidth * 0.045,
                                    deliveryTime: store.deliveryTime == null
                                        ? null
                                        : '${store.deliveryTime} ${LangKeys.minutesKey.tr()}',
                                    distance: store.distance == null
                                        ? null
                                        : '${formatDouble(store.distance)} ${LangKeys.kmKey.tr()}',
                                    deliveryFee:
                                        '${formatDouble(store.deliveryFee)}',
                                    color: colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                              mainAxisExtent: itemHeight,
                            ),
                            itemBuilder: (context, index) {
                              return GlassProductItemView(
                                product: products[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    _FeaturedStoresIndicator(count: storesCount),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}





class _FeaturedStoresIndicator extends ConsumerWidget {
  const _FeaturedStoresIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final int currentIndex = ref.watch(currentFeaturedStoreIndexProvider);
    return RepaintBoundary(
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (index) => Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex ? colors.white : Colors.transparent,
              border: Border.all(color: colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
