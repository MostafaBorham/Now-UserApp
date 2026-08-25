import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

class ProductItem3View extends StatelessWidget {
  const ProductItem3View({super.key, this.product});

  /// The product to render. `null` while used as a shimmer placeholder, where
  /// the layout is drawn but the values are irrelevant.
  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ProductModel? product = this.product;
    // A running deal drives the discount badge and the struck-through old price.
    final bool hasDeal = product?.activeDeal != null;
    return AspectRatio(
      aspectRatio: 0.65,
      child: LayoutBuilder(
        builder: (context,con) {
          return Card(
            elevation: 2,
            shadowColor: colors.black.withValues(alpha: 0.25),
            color: colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular12,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        imageUrl: product?.images?.firstOrNull ?? '',
                        fit: BoxFit.cover,
                      ),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircularBrandLogo(
                                radius: con.maxWidth*0.1,
                                logoUrl: product?.vendor?.logoUrl ?? '',
                                backgroundColor: colors.white,
                              ),
                              CircularAppFavouriteIcon(
                                size: con.maxWidth*0.08,
                                favouriteType: FavouriteType.product,
                                itemId: product?.id,
                                isFavourite: product?.isFavorite ?? false,
                                onFavouriteChanged: (currentFavourite) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: 5,
                        bottom: 5,
                        // With no stock left there is nothing to add, so show an
                        // "out of stock" chip instead of a cart button that would
                        // only flip open and collapse again (matches the product
                        // cards). Absent stock (`null`) is treated as available.
                        child: (product?.stock ?? 1) < 1
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.white,
                                  borderRadius: AppBorderRadius.brCircular8,
                                ),
                                child: Text(
                                  LangKeys.outOfStockKey.tr(),
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.onError,
                                    fontSize: con.maxWidth * 0.06,
                                  ),
                                ),
                              )
                            : AnimatedCartButton(
                                productId: product?.productId ?? product?.id,
                                productQuantity: product?.cartQuantity ?? 0,
                                stock: product?.stock,
                              ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppRateWidget(
                              starColor: colors.amber500,
                              rateRatio: '4.5',
                              rateColor: colors.black,
                              size: con.maxWidth*0.1,
                            ),
                            hasDeal
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.errorContainer,
                                      borderRadius: BorderRadiusGeometry.circular(5),
                                    ),
                                    child: Row(
                                      textDirection: TextDirection.ltr,
                                      spacing: 3,
                                      children: [
                                        Text('${product?.activeDeal?.discountValue?.toStringAsFixed(0) ?? 0}%',style: TextStyle(
                                            color: colors.white,
                                            fontSize: con.maxWidth*0.07,
                                            fontWeight: FontWeight.w700
                                        ),),
                                        Assets.media.images.svg.zigzagArrowIcon.svg(
                                          colorFilter: ColorFilter.mode(colors.white,BlendMode.srcIn),
                                          width: con.maxWidth*0.04
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                        // Prices never push past 75% of the card: a very large
                        // number is scaled down by the FittedBox to fit that slot
                        // instead of overflowing the card width.
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: con.maxWidth * 0.75,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: product?.dealDiscountAmount != null &&
                                    product!.dealDiscountAmount! > 0
                                ? Row(
                                    // Sizes to its content — required under the
                                    // FittedBox's unbounded width.
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 4,
                                    children: [
                                      NewPriceWidget(
                                        color: colors.primary700,
                                        price: product.dealDiscountAmount
                                                ?.toStringAsFixed(2) ??
                                            '0.00',
                                        size: con.maxWidth*0.12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Text(
                                        product.price?.toStringAsFixed(2) ?? '0.00',
                                        style: TextStyle(
                                          color: colors.neutral500,
                                          fontSize: con.maxWidth*0.09,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.lineThrough,
                                          decorationThickness: 1,
                                          decorationColor: colors.neutral500.withValues(
                                            alpha: 0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : NewPriceWidget(
                                    color: colors.black,
                                    price: product?.price?.toStringAsFixed(2) ?? '0.00',
                                    size: con.maxWidth*0.13,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, textCon) {
                              final double fontSize = con.maxWidth * 0.1;
                              const double lineHeight = 1.2;
                              final int fitLines = (textCon.maxHeight /
                                      (fontSize * lineHeight))
                                  .floor()
                                  .clamp(1, 2);
                              return Text(
                                context.getLocalizedApiText(product?.name),
                                maxLines: fitLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  height: lineHeight,
                                  fontWeight: FontWeight.w600,
                                  color: colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
