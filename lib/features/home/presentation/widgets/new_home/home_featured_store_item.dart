import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/color_sharpener.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/featured_stores_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/glass_product_item_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

/// One page of the featured-stores carousel: a store's identity (logo, name,
/// delivery details) over a 2×2 grid of its products.
///
/// Tapping the header opens the store; tapping a product tile opens that
/// product (the tile owns its own add-to-cart and favourite actions).
class HomeFeaturedStoreItem extends StatelessWidget {
  const HomeFeaturedStoreItem({
    super.key,
    required this.store,
    required this.storesCount,
    this.onProductFavouriteChanged,
  });

  final StoreModel store;

  /// How many stores the carousel holds — the number of indicator dots.
  final int storesCount;

  /// Called with a product's id and its new favourite status whenever a tile in
  /// this store's grid settles, so the feed can persist the change onto the
  /// nested product model.
  final void Function(int? productId, bool isFavourite)?
      onProductFavouriteChanged;

  /// The design's 2×2 grid; a store sending more products than that keeps only
  /// the first four.
  static const int _maxProducts = 4;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<ProductModel> products =
        (store.products ?? const <ProductModel>[]).take(_maxProducts).toList();
    // The vendor item's own `store_color`; the design's blue stands in for a
    // store the admin left uncoloured.
    final Color tint = store.storeColor ?? const Color(0xFF4968B7);
    final Color sharpTint = sharpenColor(tint);
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
                              pathParameters: <String, String>{
                                'id': '${store.id}',
                              },
                              extra: store.name,
                            ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          CircularBrandLogo(
                            radius: con.maxWidth * 0.07,
                            logoUrl: store.logoUrl ?? '',
                            backgroundColor: colors.onError,
                            // Fills the circle, matching the design's cover
                            // -cropped store avatar.
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
                                    color: sharpTint,
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
                                    deliveryFee: formatMoney(store.deliveryFee),
                                    color: sharpTint,
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
                                onFavouriteChanged: (bool isFavourite) =>
                                    onProductFavouriteChanged?.call(
                                      products[index].id,
                                      isFavourite,
                                    ),
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

/// The page-indicator dots. Isolated as the only widget that watches the
/// current index so an auto-play page change rebuilds just these dots — never
/// the slide's gradient, avatar, or product grid. Wrapped in a
/// [RepaintBoundary] so its repaints stay local.
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
