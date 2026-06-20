import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/home/add_to_cart_button.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/clippers/card_clipper.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/price_with_currency.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';

import 'add_to_cart_counter_widget.dart';
import '../shared/previous_price_with_currency.dart';

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
    final TextTheme textThemes = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: 170.w,
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
                              InkWell(
                                onTap: () {
                                  isFavorite = !isFavorite;
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Material(
                                    elevation: 1,
                                    shape: const CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: colors.onPrimary,
                                      child:
                                          (isFavorite
                                                  ? Assets
                                                        .media
                                                        .images
                                                        .svg
                                                        .filledFavouriteIcon
                                                  : Assets
                                                        .media
                                                        .images
                                                        .svg
                                                        .favouriteIcon)
                                              .svg(
                                                width: 16.sp,
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
                            Assets.media.images.svg.starRate.svg(width: 20.sp),
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
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Favorite
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Discount
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '50%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Best Seller
              Positioned(
                top: 34,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xff4CAF50),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'الأكثر مبيعاً',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Content
        ],
      ),
    );
    return Column(
      children: [
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(borderRadius: AppBorderRadius.brCircular10),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg',
                fit: BoxFit.cover,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.onPrimary,
                    child: Icon(Icons.favorite_border),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: colors.errorContainer,
                        ),
                        child: AutoSizeText('50%'),
                      ),
                      Container(
                        width: 35,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          color: colors.primary,
                        ),
                        child: AutoSizeText('50%'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(),
      ],
    );
  }
}
