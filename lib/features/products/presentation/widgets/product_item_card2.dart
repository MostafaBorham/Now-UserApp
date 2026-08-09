import 'dart:async';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_counter_view.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/diognal_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/previous_price_with_currency.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

import '../../../favourites/presentation/widgets/circular_app_favourite_icon.dart';

class ProductItemCard2 extends StatefulWidget {
  const ProductItemCard2({
    super.key,
    this.productModel,
    this.onTap,
    this.onFavouriteChanged,
  });
  final ProductModel? productModel;
  final GestureTapCallback? onTap;

  /// Forwarded to the heart button — fired with the new status after a
  /// successful favourite toggle. Lets a list remove the card when it is
  /// unfavourited (see the favourites screen).
  final ValueChanged<bool>? onFavouriteChanged;
  @override
  State<ProductItemCard2> createState() => _ProductItemCard2State();
}

class _ProductItemCard2State extends State<ProductItemCard2> {
  bool isRotate = false;
  bool showAddToCartCounter = false;
  int counter = 0;
  Timer? _timer;
  bool isFavorite = false;

  void startTimer() {
    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 2), () {
      showAddToCartCounter = false;
      isRotate = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap:
          widget.onTap ??
          () => context.pushNamed(
            AppRoutes.productDetailsScreen,
            extra: widget.productModel?.slug,
          ),
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: AppBorderRadius.brCircular20,
          boxShadow: [
            BoxShadow(
              color: colors.neutral500.withValues(alpha: .3),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, con) {
                  return Stack(
                    children: [
                      ReverseWidget(
                        applyReverse: context.isRTL,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: ClipPath(
                            clipper: DiagonalClipper(),
                            child: ReverseWidget(
                              applyReverse: context.isRTL,
                              child: AppCachedNetworkImage(
                                imageUrl:
                                    widget.productModel?.images?.firstOrNull ??
                                    '',
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Padding(
                          padding: EdgeInsetsDirectional.all(
                            con.maxWidth * 0.05,
                          ),
                          child: CircularAppFavouriteIcon(
                            size: con.maxWidth * 0.08,
                            favouriteType: FavouriteType.product,
                            itemId: widget.productModel?.id,
                            isFavourite:
                                widget.productModel?.isFavorite ?? false,
                            onFavouriteChanged: widget.onFavouriteChanged,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: con.maxHeight * 0.22,
                            end: con.maxWidth * 0.05,
                          ),
                          child: Transform.rotate(
                            angle: context.isRTL ? 0.2 : -0.2,
                            child: Container(
                              width: con.maxWidth * 0.5,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.secondaryContainer.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius: AppBorderRadius.brCircular6,
                              ),
                              child: Text(
                                context.getLocalizedApiText(
                                  widget.productModel?.subCategory?.name,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, con) {
                  final widthCon = con.maxWidth;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: SizedBox(
                                width: widthCon*0.6,
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    Assets.media.images.svg.starRate.svg(
                                      width: widthCon * 0.1,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '4.7',
                                        style: AppTextStyles.style14Medium.copyWith(
                                          color: colors.black,
                                          fontSize: widthCon * 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: con.maxWidth * 0.2,
                                  maxWidth: con.maxWidth * 0.7,
                                ),
                                child: (widget.productModel?.stock ?? 1) < 1
                                    ? Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                      child: Text(
                                          LangKeys.outOfStockKey.tr(),
                                          style: AppTextStyles.style12Medium
                                              .copyWith(color: colors.onError),
                                        ),
                                    )
                                    : AnimatedCartButton(
                                        productId:
                                            widget.productModel?.productId ??
                                            widget.productModel?.id,
                                        productQuantity:
                                            widget.productModel?.cartQuantity ??
                                            0,
                                        stock: widget.productModel?.stock,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        spacing: widthCon * 0.1,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  textDirection: TextDirection.ltr,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: FittedBox(
                                        child: OldPriceWidget(
                                          color: colors.neutral500,
                                          price:
                                              '${widget.productModel?.comparePrice}',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: FittedBox(
                                        child: NewPriceWidget(
                                          color: colors.black,
                                          price:
                                              '${widget.productModel?.price}',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                AutoSizeText(
                                  context.getLocalizedApiText(
                                    widget.productModel?.name,
                                  ),
                                  style: AppTextStyles.style12SemiBold.copyWith(
                                    color: colors.black,
                                    fontSize: widthCon * 0.09,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircularBrandLogo(
                            radius: widthCon * 0.12,
                            logoUrl: widget.productModel?.vendor?.logoUrl ?? '',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
