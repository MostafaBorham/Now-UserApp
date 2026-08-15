import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_add_to_cart_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/card_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_counter_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/previous_price_with_currency.dart';

class HomeNeverMissOffersItem extends StatefulWidget {
  const HomeNeverMissOffersItem({super.key});

  @override
  State<HomeNeverMissOffersItem> createState() =>
      _HomeNeverMissOffersItemState();
}

class _HomeNeverMissOffersItemState extends State<HomeNeverMissOffersItem> {
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: BreadCardClipper(),
                  child: LayoutBuilder(
                    builder: (context, con) {
                      return Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.black.withValues(alpha: 0.15),
                              offset: Offset(0, 0),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
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
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: CircularAppFavouriteIcon(
                                    isFavourite: false,
                                    onFavouriteChanged: (currentFavourite) {},
                                    size: con.maxWidth * 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.2,
                alignment: AlignmentDirectional.bottomEnd,
                child: AnimatedCartButton(),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context,con) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadiusGeometry.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: colors.black.withValues(alpha: 0.15),
                    offset: Offset(0, 0),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 7,
                children: [
                  Text(
                    'Coffee Machine',
                    maxLines: 1,
                    style: AppTextStyles.style16SemiBold.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 7,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              NewPriceWidget(color: colors.black, price: '10',size: con.maxWidth*0.1,),
                              OldPriceWidget(color: colors.neutral500, price: '15',size: con.maxWidth*0.08)
                            ],
                          ),
                          Wrap(
                            spacing: 7,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Assets.media.images.svg.starRate.svg(width: 20),
                              AutoSizeText(
                                '4.7',
                                style: AppTextStyles.style14Regular.copyWith(
                                  color: colors.neutral1200,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: con.maxWidth*0.25,
                        height: con.maxWidth*0.25,
                        child: CachedNetworkImage(
                          imageUrl: 'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox.shrink(),
                          errorWidget: (context, url, error) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }
}