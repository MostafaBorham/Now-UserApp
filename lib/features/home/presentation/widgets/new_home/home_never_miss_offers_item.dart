import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/card_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

/// One card of the `flash_offers` section.
///
/// The favourite heart and the cart control are the wired shared widgets, so
/// both act on the real product: the heart drives `productFavouriteProvider`
/// via [CircularAppFavouriteIcon], and [AnimatedCartButton] drives
/// `updateCartProductProvider`. Tapping anywhere else opens product details.
class HomeNeverMissOffersItem extends StatelessWidget {
  const HomeNeverMissOffersItem({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // The price actually charged: `effective_price` already has the running
    // deal applied, and falls back to the list price when no deal is on.
    final double? price = product.effectivePrice ?? product.price;
    final double? discount = product.discountPercentage;
    final bool isDiscounted = discount != null && discount > 0;
    final String imageUrl = product.images?.firstOrNull ?? '';
    final String vendorLogoUrl = product.vendor?.logoUrl ?? '';

    return InkWell(
      onTap: product.slug == null
          ? null
          : () => context.pushNamed(
              AppRoutes.productDetailsScreen,
              extra: product.slug,
            ),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Positioned.fill(
                  child: ClipPath(
                    clipper: BreadCardClipper(
                      textDirection: Directionality.of(context),
                    ),
                    child: LayoutBuilder(
                      builder: (context, con) {
                        return Container(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: colors.black.withValues(alpha: 0.15),
                                offset: Offset(0, 0),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // A widget rather than a DecorationImage: this one
                              // shows a shimmer while loading and a placeholder
                              // when the URL is missing or fails, instead of
                              // letting the provider's error escape the card.
                              Positioned.fill(
                                child: AppCachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Hidden outright when the product carries no
                                  // discount, rather than showing a "0%" badge.
                                  if (isDiscounted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.errorContainer,
                                        borderRadius:
                                            BorderRadiusDirectional.only(
                                              bottomEnd: Radius.circular(16),
                                            ),
                                      ),
                                      child: AutoSizeText(
                                        '${discount.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: CircularAppFavouriteIcon(
                                      size: con.maxWidth * 0.1,
                                      favouriteType: FavouriteType.product,
                                      itemId: product.id,
                                      isFavourite: product.isFavorite ?? false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  alignment: AlignmentDirectional.bottomEnd,
                  child: AnimatedCartButton(
                    productId: product.productId ?? product.id,
                    productQuantity: product.cartQuantity ?? 0,
                    stock: product.stock,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, con) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  color: colors.white,
                  borderRadius: BorderRadiusGeometry.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: colors.black.withValues(alpha: 0.15),
                      offset: Offset(0, 0),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    Text(
                      context.getLocalizedApiText(product.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.style16SemiBold.copyWith(
                        color: colors.neutral1200,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bounded, so a long real price pair wraps onto a
                        // second line instead of overflowing the card — the
                        // placeholder prices this card was built against were
                        // short enough to hide that.
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 7,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  NewPriceWidget(
                                    color: colors.black,
                                    price: price?.toStringAsFixed(2) ?? '0.00',
                                    size: con.maxWidth * 0.1,
                                  ),
                                  // The struck-through list price only makes
                                  // sense while a deal is actually cutting it.
                                  if (isDiscounted)
                                    OldPriceWidget(
                                      color: colors.neutral500,
                                      price:
                                          product.price?.toStringAsFixed(2) ??
                                          '0.00',
                                      size: con.maxWidth * 0.08,
                                    ),
                                ],
                              ),
                              Wrap(
                                spacing: 7,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Assets.media.images.svg.starRate.svg(
                                    width: 20,
                                  ),
                                  AutoSizeText(
                                    '${formatDouble(product.rating?.average)}',
                                    style: AppTextStyles.style14Regular
                                        .copyWith(color: colors.neutral1200),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: con.maxWidth * 0.25,
                          height: con.maxWidth * 0.25,
                          child: vendorLogoUrl.isEmpty
                              ? null
                              : CachedNetworkImage(
                                  imageUrl: vendorLogoUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      const SizedBox.shrink(),
                                  errorWidget: (context, url, error) =>
                                      const SizedBox.shrink(),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
