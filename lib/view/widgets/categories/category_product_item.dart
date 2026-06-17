import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/widgets/home/add_to_cart_button.dart';
import 'package:nowdelivery_user_app/view/widgets/home/add_to_cart_counter_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/clippers/diognal_clipper.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/current_price_with_currency.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/previous_price_with_currency.dart';

import '../../assets/assets.gen.dart';
import '../../styles/text_styles.dart';

class CategoryProductItem extends StatefulWidget {
  const CategoryProductItem({super.key});

  @override
  State<CategoryProductItem> createState() => _CategoryProductItemState();
}

class _CategoryProductItemState extends State<CategoryProductItem> {
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
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: ClipPath(
                  clipper: DiagonalClipper(),
                  child: Image.network(
                    'https://picsum.photos/300/300',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    isFavorite = !isFavorite;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8.0),
                    child: Material(
                      elevation: 1,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 13.sp,
                        backgroundColor: colors.onPrimary,
                        child:
                            (isFavorite
                                    ? Assets
                                          .media
                                          .images
                                          .svg
                                          .filledFavouriteIcon
                                    : Assets.media.images.svg.favouriteIcon)
                                .svg(
                                  width: 15.sp,
                                  colorFilter: ColorFilter.mode(
                                    isFavorite
                                        ? colors.errorContainer
                                        : colors.onTertiaryFixed,
                                    BlendMode.srcIn,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 140 * .57,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2),
                      borderRadius: AppBorderRadius.brCircular8,
                    ),
                    child: AutoSizeText(
                      'أطفال',
                      maxLines: 1,
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 10,
              children: [
                Row(
                  spacing: 7,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Assets.media.images.svg.starRate.svg(width: 20.sp),
                    Expanded(
                      child: AutoSizeText(
                        '4',
                        style: AppTextStyles.style14Medium.copyWith(
                          color: colors.onSecondary,
                        ),
                      ),
                    ),
                    showAddToCartCounter
                        ? AnimatedScale(
                            scale: showAddToCartCounter ? 1 : 0,
                            duration: const Duration(seconds: 2),
                            curve: Curves.linear,
                            onEnd: () {},
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
                          )
                        : InkWell(
                            onTap: () {
                              isRotate = !isRotate;
                              setState(() {});
                            },
                            child: AddToCartButton(
                              text: counter < 1 ? '+' : counter.toString(),
                              onEnd: () {
                                startTimer();
                                if (counter < 1) counter++;
                                showAddToCartCounter = true;
                                setState(() {});
                              },
                              isRotate: isRotate,
                            ),
                          ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            CurrentPriceWithCurrency(
                              color: colors.onSecondary,
                              price: '10',
                            ),
                            PreviousPriceWithCurrency(),
                          ],
                        ),
                        AutoSizeText(
                          't-shirt',
                          style: AppTextStyles.style14Medium.copyWith(
                            color: colors.onSecondary,
                          ),
                        ),
                      ],
                    ),
                    CircularBrandLogo(radius: 20.r, logoUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png')
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
