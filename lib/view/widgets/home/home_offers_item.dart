import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';

import 'add_to_cart_button.dart';
import 'add_to_cart_counter_widget.dart';
import '../shared/price_with_currency.dart';
import '../shared/previous_price_with_currency.dart';

class HomeOffersItem extends StatefulWidget {
  const HomeOffersItem({super.key});

  @override
  State<HomeOffersItem> createState() => _HomeOffersItemState();
}

class _HomeOffersItemState extends State<HomeOffersItem> {
  bool isFavorite = false;
  bool isRotate = false;
  bool showAddToCartCounter = false;
  int counter = 0;
  Timer? _timer;

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
    return Card(
      elevation: 3,
       clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Container(
        width: 190.w,
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 12),
        child: Column(
          spacing: 15,
          children: [
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Stack(
                    children: [
                      Column(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                borderRadius: AppBorderRadius.brCircular12,
                              ),
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Row(
                            spacing: 7,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Assets.media.images.svg.starRate.svg(width: 20.sp),
                              AutoSizeText(
                                '4',
                                style: AppTextStyles.style14Medium.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.errorContainer,
                                borderRadius: BorderRadiusDirectional.only(
                                  topEnd: Radius.circular(15),
                                  bottomEnd: Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                '50%',
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                isFavorite = !isFavorite;
                                setState(() {
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8.0),
                                child: Material(
                                  elevation: 1,
                                  shape: const CircleBorder(),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: colors.onPrimary,
                                    child: (isFavorite? Assets.media.images.svg.filledFavouriteIcon : Assets.media.images.svg.favouriteIcon)
                                        .svg(
                                          width: 16.sp,
                                          colorFilter: ColorFilter.mode(
                                            isFavorite ? colors.errorContainer : colors.onTertiaryFixed,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  CircularBrandLogo(
                    radius: 25.sp,
                    logoUrl:
                        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    AutoSizeText('sdsd',style: AppTextStyles.style18SemiBold.copyWith(
                        color: colors.onTertiaryFixed
                    ),),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        PriceWithCurrency(color: colors.onPrimaryFixedVariant,price: '20',),
                        PreviousPriceWithCurrency(),
                      ],
                    ),

                  ],
                ),
                // ReverseWidget(child: Assets.media.images.svg.addToCartBtn.svg())
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
                      if(counter<1) counter++ ;
                      showAddToCartCounter = true;
                      setState(() {});
                    },
                    isRotate: isRotate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
