import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/circular_brand_logo.dart';

import 'current_price_with_currency.dart';
import 'previous_price_with_currency.dart';

class MostPopularItem extends StatelessWidget {
  const MostPopularItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context,constraints) {
        return SizedBox(
          width: 170.w,
          child: Column(
            spacing: 5,
            children: [
              Container(
                  height: constraints.maxHeight*0.6,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    image: const DecorationImage(
                      image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg'),
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
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Material(
                            elevation: 1,
                            shape: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: colors.onPrimary,
                              child: Assets.media.images.svg.favouriteIcon.svg(
                                  width: 16.sp,
                                  colorFilter : ColorFilter.mode(colors.onTertiaryFixed,BlendMode.srcIn)
                              ),
                            ),
                          ),
                        ),
                        Column(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.errorContainer,
                                borderRadius: BorderRadiusDirectional.only(
                                  bottomStart: Radius.circular(16),

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
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                              decoration: BoxDecoration(
                                color: colors.onPrimaryFixedVariant,
                                borderRadius: BorderRadiusDirectional.only(
                                  topStart: Radius.circular(15),
                                  bottomStart: Radius.circular(15),
                                ),
                              ),
                              child:  Text(
                                'الأكثر مبيعاً',
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Assets.media.images.svg.addToCartBtn.svg()
                  ],
                ),
              ),
              Container(
                height: constraints.maxHeight*0.38,
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  borderRadius: AppBorderRadius.brCircular8
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
                        AutoSizeText('sdsd',style: AppTextStyles.style16SemiBold.copyWith(
                          color: colors.onTertiaryFixed
                        ),),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            CurrentPriceWithCurrency(color: colors.onPrimaryFixedVariant,price: '20',),
                            PreviousPriceWithCurrency(),
                          ],
                        ),
                        Row(
                          spacing: 7,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Assets.media.images.svg.starRate.svg(
                              width: 20.sp
                            ),
                            AutoSizeText('4',style: AppTextStyles.style14Regular.copyWith(
                                color: colors.onTertiaryFixed
                            ),),
                          ],
                        )

                      ],
                    ),
                    Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: CircularBrandLogo(radius: 25, logoUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png'))
                  ],
                ),
              )
            ],
          ),
        );
      }
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
                    image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg'),
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
