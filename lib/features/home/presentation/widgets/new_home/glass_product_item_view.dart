import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
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








class GlassProductItemView extends StatelessWidget {
  const GlassProductItemView({
    super.key,
    required this.product,
    this.onFavouriteChanged,
  });

  final ProductModel product;



  final ValueChanged<bool>? onFavouriteChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;


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
                            size: con.maxWidth * 0.1,
                            favouriteType: FavouriteType.product,
                            itemId: product.id,
                            isFavourite: product.isFavorite ?? false,
                            onFavouriteChanged: onFavouriteChanged,
                          ),
                        ],
                      ),
                    ),
                    LiquidGlassLens(
                      style: const LiquidGlassStyle(
                        shape: LiquidGlassShape.roundedRectangle(
                          cornerRadius: 0,
                          borderWidth: 0,
                          lightIntensity: 0,
                        ),
                        appearance: LiquidGlassAppearance(
                          blur: LiquidGlassBlur(sigmaX: 5, sigmaY: 5),
                        ),
                        refraction: LiquidGlassRefraction(
                          distortionWidth: 0,
                          magnification: 1,
                        ),
                      ),



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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                AppRateWidget(
                                  starColor: colors.amber500,
                                  rateRatio:
                                      '${formatDouble(product.rating?.average)}',
                                  rateColor: colors.black,
                                  rateCount: '${product.rating?.total ?? 0}',
                                  size: 14,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                NewPriceWidget(
                                  color: colors.black,
                                  price: price?.toStringAsFixed(2) ?? '0.00',
                                  size: 16,
                                ),




                                SizedBox.square(
                                  dimension:
                                      MediaQuery.sizeOf(context).width * 0.075,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),






                PositionedDirectional(
                  bottom: 8,
                  end: 8,
                  child: AnimatedCartButton(
                    productId: product.productId ?? product.id,
                    productQuantity: product.cartQuantity ?? 0,
                    stock: product.stock,
                  ),
                ),





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
                              child: Assets.media.images.svg.discountBadge
                                  .svg(fit: BoxFit.contain),
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
