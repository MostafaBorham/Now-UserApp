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

  /// The product to render. When `null` (e.g. the home view has no data wired
  /// up yet, or a card is built without a model) the card falls back to
  /// [_placeholderProduct] so it still looks populated instead of showing empty
  /// texts and blank slots.
  final ProductModel? product;

  /// Dummy stand-in used whenever no [product] is passed, so the card renders
  /// with plausible-looking data. Temporary until the home view is integrated
  /// with the backend.
  static const ProductModel _placeholderProduct = ProductModel(
    id: 0,
    productId: 0,
    name: <String, dynamic>{
      'en': 'Fresh Orange Juice 1L',
      'ar': 'عصير برتقال طازج ١ لتر',
    },
    // Old price ([price]) shown struck-through next to the new discounted price
    // ([dealDiscountAmount]); [activeDeal] drives the red discount badge.
    price: 99.99,
    dealDiscountAmount: 74.99,
    activeDeal: ActiveDealModel(discountValue: 25),
    // Temporary internet images for the product photo and the brand logo.
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

  /// Called with the new favourite status whenever it settles for this card, so
  /// the owner of the list can persist the change onto its product model.
  final ValueChanged<bool>? onFavouriteChanged;

  /// Tap handler for the whole card. Defaults to opening the product details
  /// screen for [product] (passing its slug), matching the other product cards.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ProductModel product = this.product ?? _placeholderProduct;
    // A running deal drives the discount badge and the struck-through old price.
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
                        // With no stock left there is nothing to add, so show an
                        // "out of stock" chip instead of a cart button that would
                        // only flip open and collapse again (matches the product
                        // cards). Absent stock (`null`) is treated as available.
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
                            child: product.dealDiscountAmount != null &&
                                    product.dealDiscountAmount! > 0
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
