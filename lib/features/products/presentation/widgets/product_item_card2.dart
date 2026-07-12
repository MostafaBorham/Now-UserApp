import 'dart:async';
import 'package:go_router/go_router.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_item_quantity_button/add_to_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_item_quantity_button/add_to_cart_counter_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/diognal_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/previous_price_with_currency.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

import '../../../favourites/presentation/widgets/circular_app_favourite_icon.dart';

class ProductItemCard2 extends StatefulWidget {
  const ProductItemCard2({super.key, this.productModel,this.onTap});
  final ProductModel? productModel;
  final GestureTapCallback? onTap;
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: widget.onTap?? () => context.pushNamed(AppRoutes.productDetailsScreen,extra: widget.productModel?.slug),
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.onPrimary,
          borderRadius: AppBorderRadius.brCircular20,
          boxShadow: [
            BoxShadow(
              color: colors.onSecondary.withValues(alpha: .5),
              blurRadius: 1,
              offset: Offset(0, 1),
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
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: ClipPath(
                          clipper: DiagonalClipper(),
                          child: AppCachedNetworkImage(
                            imageUrl:
                                widget.productModel?.images.firstOrNull??'',
                            width: double.infinity,
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
                            size: con.maxWidth*0.08,
                            isFavourite: widget.productModel?.isFeatured?? false,
                            onFavouriteChanged: (currentFavourite) {
                            },
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
                            angle: -0.2,
                            child: Container(
                              width: con.maxWidth*0.5,
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
                                widget.productModel?.name??'',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onPrimary,
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
                      Row(
                        spacing: widthCon * 0.02,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Assets.media.images.svg.starRate.svg(
                            width: widthCon * 0.1,
                          ),
                          Expanded(
                            child: AutoSizeText(
                              '4.7',
                              style: AppTextStyles.style14Medium.copyWith(
                                color: colors.onSecondary,
                                fontSize: widthCon * 0.1,
                              ),
                            ),
                          ),
                          showAddToCartCounter
                              ? AnimatedScale(
                                  scale: showAddToCartCounter ? 1 : 0,
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.linear,
                                  onEnd: () {},
                                  child: SizedBox(
                                    width: widthCon * 0.6,
                                    height: widthCon * 0.2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: AddToCartCounterWidget(
                                        counter: counter,
                                        onInc: () {
                                          startTimer();
                                          counter++;
                                          setState(() {});
                                        },
                                        onDec: () {
                                          startTimer();
                                          counter--;
                                          setState(() {});
                                        },
                                        onDelete: () {
                                          showAddToCartCounter = false;
                                          counter--;
                                          isRotate = false;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    isRotate = !isRotate;
                                    setState(() {});
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: AddToCartButton(
                                      text: counter < 1
                                          ? '+'
                                          : counter.toString(),
                                      onEnd: () {
                                        startTimer();
                                        if (counter < 1) counter++;
                                        showAddToCartCounter = true;
                                        setState(() {});
                                      },
                                      isRotate: isRotate,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Row(
                        spacing: widthCon * 0.2,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 10,
                                    children: [
                                      OldPriceWidget(color: colors.onSurface.withValues(alpha: 0.7), price: '${widget.productModel?.price}'),
                                   NewPriceWidget(color: colors.onSecondary, price: '${widget.productModel?.price}')
                                    ],
                                  ),
                                ),
                                AutoSizeText(
                                  '${widget.productModel?.name}',
                                  style: AppTextStyles.style12SemiBold.copyWith(
                                    color: colors.onSecondary,
                                    fontSize: widthCon * 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircularBrandLogo(
                            radius: widthCon * 0.12,
                            logoUrl:
                                widget.productModel?.vendor.logoUrl??'',
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
