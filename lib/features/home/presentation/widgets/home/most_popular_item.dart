import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_item_quantity_button/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/card_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';

import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_item_quantity_button/animated_cart_counter_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/previous_price_with_currency.dart';

class MostPopularItem extends StatefulWidget {
  const MostPopularItem({super.key});

  @override
  State<MostPopularItem> createState() => _MostPopularItemState();
}

class _MostPopularItemState extends State<MostPopularItem> {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: 170,
          child: Column(
            spacing: 5,
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  ClipPath(
                    clipper: BreadCardClipper(),
                    child: Container(
                      height: constraints.maxHeight * 0.6,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.errorContainer,
                                      borderRadius:
                                          BorderRadiusDirectional.only(
                                            bottomEnd: Radius.circular(16),
                                          ),
                                    ),
                                    child: const AutoSizeText(
                                      '50%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  /*Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.onPrimaryFixedVariant,
                                      borderRadius:
                                          BorderRadiusDirectional.only(
                                            topEnd: Radius.circular(15),
                                            bottomEnd: Radius.circular(15),
                                          ),
                                    ),
                                    child: Text(
                                      'الأكثر مبيعاً',
                                      style: TextStyle(
                                        color: colors.onPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),*/
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CircularAppFavouriteIcon(
                                  isFavourite: false,
                                  onFavouriteChanged: (currentFavourite) {

                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
              Container(
                height: constraints.maxHeight * 0.38,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  borderRadius: AppBorderRadius.brCircular12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 7,
                      children: [
                        AutoSizeText(
                          'sdsd',
                          style: AppTextStyles.style16SemiBold.copyWith(
                            color: colors.onTertiaryFixed,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            PriceWithCurrency(
                              color: colors.onPrimaryFixedVariant,
                              price: '20',
                            ),
                            PreviousPriceWithCurrency(),
                          ],
                        ),
                        Row(
                          spacing: 7,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Assets.media.images.svg.starRate.svg(width: 20),
                            AutoSizeText(
                              '4',
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.onTertiaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: CircularBrandLogo(
                        radius: 25,
                        logoUrl:
                            'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
