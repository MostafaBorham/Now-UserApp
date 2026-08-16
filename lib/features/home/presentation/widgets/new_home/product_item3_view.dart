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
    return Card(
      elevation: 2,
      shadowColor: colors.black.withValues(alpha: 0.25),
      color: colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.brCircular16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        spacing: 12,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    width: double.infinity,
                    height: double.infinity,
                    imageUrl:
                        'https://ccwetpprodstorage.blob.core.windows.net/prodpublicaccessblob/public-files/64d51e54708fb908287aca6f2d5091a2.jpeg?raw=1',
                    fit: BoxFit.fill,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: CircularBrandLogo(
                    radius: 24,
                    logoUrl:
                        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularAppFavouriteIcon(
                      size: 24,
                      isFavourite: false,
                      onFavouriteChanged: (currentFavourite) {},
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: AnimatedCartButton(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
            child: Column(
              spacing: 3,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppRateWidget(
                      starColor: colors.surface,
                      rateRatio: '4.5',
                      rateCount: '12',
                      rateColor: colors.black,
                      size: 15,
                    ),
                    true? Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.onError,
                        borderRadius: BorderRadiusGeometry.circular(4),
                      ),
                      child: Row(
                        spacing: 3,
                        children: [
                          Assets.media.images.svg.zigzagArrowIcon.svg(),
                          Text('10%'),
                        ],
                      ),
                    ) : SizedBox.shrink(),
                  ],
                ),
                true
                    ? Row(
                        spacing: 4,
                        children: [
                          NewPriceWidget(
                            color: colors.primary500Main,
                            price: '10.00',
                            size: 20,
                          ),
                          Text(
                            '15.00',
                            style: TextStyle(
                              color: colors.neutral500,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
                        size: 20,
                      ),
                Text(
                  'Panda Store',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
