import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_counter_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/previous_price_with_currency.dart';

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
    final AppColorScheme colors = context.colors;
    return Card(
      elevation: 3,
       clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Container(
        width: 190,
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
                              Assets.media.images.svg.starRate.svg(width: 20),
                              AutoSizeText(
                                '4',
                                style: AppTextStyles.style14Medium.copyWith(
                                  color: colors.neutral500,
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
                                  color: colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8.0),
                              child: CircularAppFavouriteIcon(
                                isFavourite: false,
                                onFavouriteChanged: (currentFavourite) {

                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  CircularBrandLogo(
                    radius: 25,
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
                        color: colors.neutral1200
                    ),),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        PriceWithCurrency(color: colors.primary700,price: '20',),
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
                  child: AnimatedCartCounterView(
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
                  child: AnimatedAddToCartButton(
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
