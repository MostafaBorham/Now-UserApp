import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

/// Product tile with a frosted-glass info panel, used by the featured-stores
/// carousel ([HomeFeaturedStoreItem]).
///
/// The favourite heart and the cart control are the wired shared widgets, so
/// both act on the real product: the heart drives `productFavouriteProvider`
/// via [CircularAppFavouriteIcon], and [AnimatedCartButton] drives
/// `updateCartProductProvider`. Tapping anywhere else opens product details.
class GlassProductItemView extends StatelessWidget {
  const GlassProductItemView({
    super.key,
    required this.product,
    this.onFavouriteChanged,
  });

  final ProductModel product;

  /// Called with the new favourite status whenever it settles for this tile, so
  /// the owner of the list can persist the change onto its product model.
  final ValueChanged<bool>? onFavouriteChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // The price actually charged: `effective_price` already has the running
    // deal applied, and falls back to the list price when no deal is on.
    final double? price = product.effectivePrice ?? product.price;
    final double? discount = product.discountPercentage;
    return InkWell(
      onTap: product.slug == null
          ? null
          : () => context.pushNamed(
              AppRoutes.productDetailsScreen,
              extra: product.slug,
            ),
      child: LayoutBuilder(
        builder: (context, con) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadiusGeometry.circular(8),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: AppCachedNetworkImage(
                      imageUrl: product.images?.firstOrNull ?? '',
                      width: con.maxWidth * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircularAppFavouriteIcon(
                            favouriteType: FavouriteType.product,
                            itemId: product.id,
                            isFavourite: product.isFavorite ?? false,
                            onFavouriteChanged: onFavouriteChanged,
                          ),
                        ],
                      ),
                    ),
                    // Frosted glass: a plain σ5 backdrop blur clipped to the
                    // panel, which is all the liquid-glass lens was configured
                    // to draw (no tint, refraction, light or border) — at one
                    // backdrop pass instead of two, without the lens repainting
                    // on every scroll frame, and without its black edge under
                    // Android's stretch overscroll. Not `.grouped`: a shared
                    // backdrop is read once, at the first tile, so every later
                    // tile would blur a copy that lacks its own card and image.
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        // A single white line on the top edge only; the other
                        // edges stay borderless.
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            spacing: 5,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.getLocalizedApiText(product.name),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.black,
                                      ),
                                    ),
                                  ),
                                  if ((product.rating?.average ?? 0) > 0)
                                    AppRateWidget(
                                      starColor: colors.amber500,
                                      rateRatio:
                                          '${formatDouble(product.rating?.average)}',
                                      rateColor: colors.black,
                                      rateCount:
                                          '${product.rating?.total ?? 0}',
                                      size: 14,
                                    ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  NewPriceWidget(
                                    color: colors.black,
                                    price: formatMoney(price),
                                    size: 16,
                                  ),
                                  // Reserve the slot the cart control occupies so
                                  // the price keeps its place. The real control is a
                                  // Stack overlay below, so its counter can expand
                                  // over the price/name without shifting them.
                                  SizedBox.square(
                                    dimension:
                                        MediaQuery.sizeOf(context).width *
                                        0.075,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // The cart control floats at its original bottom-end corner.
                // Living in the card Stack (not the price Row) lets the counter
                // grow up and inward over the price and name when it opens —
                // on top of them and without moving them — while staying fully
                // tappable inside the card bounds. Insets match the glass
                // panel's padding so it lines up with the reserved slot above.
                PositionedDirectional(
                  bottom: 8,
                  end: 8,
                  child: AnimatedCartButton(
                    productId: product.productId ?? product.id,
                    productSlug: product.slug,
                    productQuantity: product.cartQuantity ?? 0,
                    stock: product.stock,
                    minOrderQuantity: product.minOrderQuantity,
                  ),
                ),
                // Diagonal discount badge wrapping the top-start corner, with
                // the discount text laid along the band. The SVG is mirrored in
                // LTR so the band always sits on the start corner; the text
                // rotates to match the band direction on each side. Hidden
                // outright when the product carries no discount.
                if (discount != null && discount > 0)
                  PositionedDirectional(
                    top: 0,
                    start: 0,
                    child: SizedBox.square(
                      dimension: con.maxWidth * 0.6,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ReverseWidget(
                              applyReverse: !context.isRTL,
                              child: Assets.media.images.svg.discountBadge.svg(
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            top: con.maxWidth * 0.09,
                            start: con.maxWidth * 0.01,
                            child: Transform.rotate(
                              angle: context.isRTL ? math.pi / 4 : -math.pi / 4,
                              child: Text(
                                '${discount.toStringAsFixed(0)}% ${LangKeys.discountKey.tr()}',
                                style: TextStyle(
                                  color: colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: con.maxWidth * 0.06,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
