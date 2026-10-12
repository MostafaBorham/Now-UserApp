// ponytail: lives in core but still imports features/cart for the cart button;
// decoupling means relocating the cart viewmodel too — do that when cart is
// refactored, not before.
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/texts/out_of_stock_label.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';

class ProductItemCard1 extends StatefulWidget {
  const ProductItemCard1({super.key, this.product, this.onFavouriteChanged});

  final ProductModel? product;

  /// Forwarded to the heart button — fired with the new status after a
  /// successful favourite toggle, so the list this card belongs to can persist
  /// the change onto its product model (e.g. via `updateProductFavourite`).
  final ValueChanged<bool>? onFavouriteChanged;

  @override
  State<ProductItemCard1> createState() => _ProductItemCard1State();
}

class _ProductItemCard1State extends State<ProductItemCard1> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double discountValue = widget.product?.activeDeal?.discountValue ?? 0;
    // A deal is a percentage or a fixed money amount — the badge must match.
    final bool dealIsPercentage =
        widget.product?.activeDeal?.isPercentage ?? true;
    final double? price = widget.product?.price;
    // The live price is the deal-adjusted discountPrice; the base price is only
    // struck through when a deal actually lowers it (see ProductModel.hasDeal).
    final bool hasDeal = widget.product?.hasDeal ?? false;
    final double? sellingPrice =
        hasDeal ? widget.product?.discountPrice : price;
    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: widget.product?.slug,
      ),
      child: LayoutBuilder(
        builder: (context, con) {
          return Card(
            elevation: 3,
            color: colors.white,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular16,
            ),
            child: Column(
              spacing: 5,
              children: [
                Expanded(
                  child: Padding(
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
                                      widget.product?.images?.firstOrNull ?? '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            if ((widget.product?.rating?.average ?? 0) > 0)
                              AppRateWidget(
                                starColor: colors.amber500,
                                rateRatio:
                                    '${formatDouble(widget.product?.rating?.average)}',
                                rateColor: colors.neutral500,
                                size: con.maxWidth * 0.08,
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // No deal means no badge. It used to render
                              // unconditionally, so an undiscounted product
                              // carried a red "0%" flash.
                              if (discountValue > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer,
                                    borderRadius: BorderRadiusDirectional.only(
                                      topEnd: Radius.circular(
                                        con.maxWidth * 0.1,
                                      ),
                                      bottomEnd: Radius.circular(
                                        con.maxWidth * 0.1,
                                      ),
                                    ),
                                  ),
                                  child: dealIsPercentage
                                      ? Text(
                                          '${formatDouble(discountValue)}%',
                                          textDirection: TextDirection.ltr,
                                          style: TextStyle(
                                            color: colors.white,
                                            fontSize: con.maxWidth * 0.06,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : NewPriceWidget(
                                          color: colors.white,
                                          price: formatMoney(discountValue),
                                          size: con.maxWidth * 0.06,
                                          fontWeight: FontWeight.w700,
                                        ),
                                )
                              else
                                // Keeps the heart at the trailing edge:
                                // spaceBetween with one child would pull it
                                // back to the start.
                                const SizedBox.shrink(),
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
                                  onFavouriteChanged: widget.onFavouriteChanged,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          color: colors.neutral1200,
                          fontSize: con.maxWidth * 0.09,
                        ),
                      ),
                      Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          SizedBox(
                            width: con.maxWidth * 0.55,
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                NewPriceWidget(
                                  color: colors.black,
                                  price: formatMoney(sellingPrice),
                                  size: con.maxWidth * 0.1,
                                  fontWeight: FontWeight.bold,
                                ),
                                if (hasDeal)
                                  OldPriceWidget(
                                    color: colors.neutral400,
                                    price: formatMoney(price),
                                    size: con.maxWidth * 0.07,
                                  ),
                              ],
                            ),
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
                                child: (widget.product?.stock ?? 1) < 1
                                    ? const OutOfStockLabel()
                                    : AnimatedCartButton(
                                        productId: widget.product?.id,
                                        productSlug: widget.product?.slug,
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
