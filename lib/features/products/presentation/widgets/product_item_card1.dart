import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class ProductItemCard1 extends StatefulWidget {
  const ProductItemCard1({super.key, this.product});

  final ProductModel? product;

  @override
  State<ProductItemCard1> createState() => _ProductItemCard1State();
}

class _ProductItemCard1State extends State<ProductItemCard1> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: widget.product?.slug,
      ),
      child: LayoutBuilder(
        builder: (context, con) {
          return Card(
            elevation: 3,
            color: colors.onPrimary,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular16,
            ),
            child: Column(
              spacing: 5,
              children: [
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                        ).copyWith(top: 12),
                        child: Stack(
                          children: [
                            Column(
                              spacing: 4,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      con.maxWidth * 0.04,
                                    ),
                                    child: AppCachedNetworkImage(
                                      imageUrl:
                                          widget.product?.images?.firstOrNull ??
                                          '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                AppRateWidget(
                                  starColor: colors.onSecondaryContainer,
                                  rateRatio: '4.2',
                                  rateColor: colors.onSurface,
                                  size: con.maxWidth * 0.1,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.errorContainer,
                                        borderRadius:
                                            BorderRadiusDirectional.only(
                                              topEnd: Radius.circular(
                                                con.maxWidth * 0.1,
                                              ),
                                              bottomEnd: Radius.circular(
                                                con.maxWidth * 0.1,
                                              ),
                                            ),
                                      ),
                                      child: Text(
                                        '${widget.product?.activeDeal?.discountValue??0}%',
                                        style: TextStyle(
                                          color: colors.onPrimary,
                                          fontSize: con.maxWidth * 0.06,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 8.0,
                                    ),
                                    child: CircularAppFavouriteIcon(
                                      size: con.maxWidth * 0.08,
                                      favouriteType: FavouriteType.product,
                                      itemId: widget.product?.id,
                                      isFavourite:
                                          widget.product?.isFavorite ?? false,
                                      onFavouriteChanged: (currentFavourite) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 10,
                        end: 2,
                        child: CircularBrandLogo(
                          elevation: 0,
                          radius: con.maxWidth * 0.1,
                          backgroundColor: colors.onPrimary,
                          logoUrl:
                              widget.product?.vendor?.logoUrl ??
                              'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0).copyWith(top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 7,
                    children: [
                      Text(
                        context.getLocalizedApiText(widget.product?.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.style18Bold.copyWith(
                          color: colors.onTertiaryFixed,
                          fontSize: con.maxWidth * 0.1,
                        ),
                      ),
                      Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.ltr,
                            spacing: 5,
                            children: [
                                OldPriceWidget(
                                  color: colors.inversePrimary,
                                  price:
                                      widget.product?.comparePrice
                                          ?.toStringAsFixed(0) ??
                                      '10',
                                  size: con.maxWidth * 0.04,
                                ),
                              NewPriceWidget(
                                color: colors.onSecondary,
                                price:
                                    '${widget.product?.price}',
                                size: con.maxWidth * 0.08,
                              ),
                            ],
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomEnd,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: con.maxWidth * 0.2,
                                maxWidth: con.maxWidth * 0.7,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerEnd,
                                child: AnimatedCartButton(
                                  productId:
                                      widget.product?.id,
                                  productQuantity:
                                      widget.product?.cartQuantity ?? 0,
                                  stock: widget.product?.stock,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
