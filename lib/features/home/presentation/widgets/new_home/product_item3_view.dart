import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/texts/out_of_stock_label.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

class ProductItem3View extends StatelessWidget {
  const ProductItem3View({
    super.key,
    this.product,
    this.onFavouriteChanged,
    this.onTap,
  });





  final ProductModel? product;




  static const ProductModel _placeholderProduct = ProductModel(
    id: 0,
    productId: 0,
    name: <String, dynamic>{
      'en': 'Fresh Orange Juice 1L',
      'ar': 'عصير برتقال طازج ١ لتر',
    },


    price: 99.99,
    dealDiscountAmount: 74.99,
    activeDeal: ActiveDealModel(discountValue: 25),

    images: <String>[
      'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600',
    ],
    vendor: StoreModel(
      logoUrl:
          'https://images.unsplash.com/photo-1613145997970-db84a7975fbb?w=200',
    ),
    stock: 10,
    isFavorite: false,
  );



  final ValueChanged<bool>? onFavouriteChanged;



  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ProductModel product = this.product ?? _placeholderProduct;

    final bool hasDeal = product.activeDeal != null;
    return InkWell(
      onTap:
          onTap ??
          () => context.pushNamed(
            AppRoutes.productDetailsScreen,
            extra: product.slug,
          ),
      child: AspectRatio(
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
                        imageUrl: product.images?.firstOrNull ?? '',
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
                                logoUrl: product.vendor?.logoUrl ?? '',
                                backgroundColor: colors.white,
                              ),
                              CircularAppFavouriteIcon(
                                size: con.maxWidth*0.08,
                                favouriteType: FavouriteType.product,
                                itemId: product.id,
                                isFavourite: product.isFavorite ?? false,
                                onFavouriteChanged: onFavouriteChanged,
                              ),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: 5,
                        bottom: 5,




                        child: (product.stock ?? 1) < 1
                            ? OutOfStockLabel(fontSize: con.maxWidth * 0.06)
                            : AnimatedCartButton(
                                productId: product.productId ?? product.id,
                                productQuantity: product.cartQuantity ?? 0,
                                stock: product.stock,
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
                              rateRatio:
                                  '${formatDouble(product.rating?.average)}',
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
                                        Text('${product.activeDeal?.discountValue?.toStringAsFixed(0) ?? 0}%',style: TextStyle(
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



                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: con.maxWidth * 0.75,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: product.dealDiscountAmount != null &&
                                    product.dealDiscountAmount! > 0
                                ? Row(


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
                                    price: product.price?.toStringAsFixed(2) ?? '0.00',
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
                                context.getLocalizedApiText(product.name),
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
      ),
    );
  }
}
