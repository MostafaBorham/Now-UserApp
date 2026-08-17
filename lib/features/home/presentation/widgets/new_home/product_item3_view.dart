import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

class ProductItem3View extends StatelessWidget {
  const ProductItem3View({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AspectRatio(
      aspectRatio: 0.65,
      child: LayoutBuilder(
        builder: (context,con) {
          return Card(
            elevation: 2,
            shadowColor: colors.black.withValues(alpha: 0.25),
            color: colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular12,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        imageUrl:
                            'https://ccwetpprodstorage.blob.core.windows.net/prodpublicaccessblob/public-files/64d51e54708fb908287aca6f2d5091a2.jpeg?raw=1',
                        fit: BoxFit.fill,
                      ),
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircularBrandLogo(
                                radius: con.maxWidth*0.1,
                                logoUrl:
                                    'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                              ),
                              CircularAppFavouriteIcon(
                                size: con.maxWidth*0.08,
                                isFavourite: false,
                                onFavouriteChanged: (currentFavourite) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        end: 5,
                        bottom: 5,
                        child: AnimatedCartButton(
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppRateWidget(
                              starColor: colors.amber500,
                              rateRatio: '4.5',
                              rateColor: colors.black,
                              size: con.maxWidth*0.1,
                            ),
                            true
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.errorContainer,
                                      borderRadius: BorderRadiusGeometry.circular(5),
                                    ),
                                    child: Row(
                                      textDirection: TextDirection.ltr,
                                      spacing: 3,
                                      children: [
                                        Text('10%',style: TextStyle(
                                            color: colors.white,
                                            fontSize: con.maxWidth*0.07,
                                            fontWeight: FontWeight.w700
                                        ),),
                                        Assets.media.images.svg.zigzagArrowIcon.svg(
                                          colorFilter: ColorFilter.mode(colors.white,BlendMode.srcIn),
                                          width: con.maxWidth*0.04
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                        true
                            ? Row(
                                spacing: 4,
                                children: [
                                  NewPriceWidget(
                                    color: colors.primary700,
                                    price: '10.00',
                                    size: con.maxWidth*0.12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Text(
                                    '15.00',
                                    style: TextStyle(
                                      color: colors.neutral500,
                                      fontSize: con.maxWidth*0.09,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.lineThrough,
                                      decorationThickness: 1,
                                      decorationColor: colors.neutral500.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : NewPriceWidget(
                                color: colors.black,
                                price: '10.00',
                                size: con.maxWidth*0.13,
                              ),
                        Expanded(
                          child: Text(
                            'غسالة بحوضين مع خاصية التجفيف بالهواءومسحوق أبيض',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: con.maxWidth*0.1,
                              fontWeight: FontWeight.w600,
                              color: colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
