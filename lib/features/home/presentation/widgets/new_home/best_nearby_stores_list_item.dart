import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class BestNearbyStoresListItem extends StatelessWidget {
  const BestNearbyStoresListItem({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, constrains) {
        return SizedBox(
          width: constrains.maxHeight * 1.1,
          child: Card(
            elevation: 2,
            shadowColor: colors.onTertiaryContainer.withValues(alpha: 0.4),
            color: colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular18,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              spacing: 16,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        width: double.infinity,
                        height: double.infinity,
                        imageUrl:
                            'https://ccwetpprodstorage.blob.core.windows.net/prodpublicaccessblob/public-files/64d51e54708fb908287aca6f2d5091a2.jpeg?raw=1',
                        fit: BoxFit.cover,
                      ),
                      Align(
                        alignment: Alignment.center,
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
                            size: constrains.maxHeight * 0.08,
                            isFavourite: false,
                            onFavouriteChanged: (currentFavourite) {},
                          ),
                        ),
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
                      AutoSizeText(
                        'متجر بنده',
                        style: AppTextStyles.style18SemiBold.copyWith(
                          color: colors.black,
                        ),
                      ),
                      2.hSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 5,
                        children: [
                          ReverseWidget(
                            child: Assets.media.images.svg.shippingIcon.svg(
                              width: constrains.maxHeight*0.08,
                              colorFilter: ColorFilter.mode(
                                colors.neutral500,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          NewPriceWidget(
                            color: colors.black,
                            price: '10',
                            size: constrains.maxHeight * 0.08,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: AppRateWidget(
                              starColor: colors.surface,
                              rateRatio: '4.5',
                              rateCount: '12',
                              rateColor: colors.black,
                              size: constrains.maxHeight * 0.07,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Assets.media.images.svg.timeIcon.svg(
                            width: constrains.maxHeight*0.08,
                            colorFilter: ColorFilter.mode(
                              colors.neutral500,
                              BlendMode.srcIn,
                            ),
                          ),
                          AutoSizeText(
                            '40-50 دقيقة',
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.black,
                            ),
                          ),
                          Assets.media.images.svg.locationIcon.svg(
                            width: constrains.maxHeight*0.07,
                            colorFilter: ColorFilter.mode(
                              colors.neutral500,
                              BlendMode.srcIn,
                            ),
                          ),
                          AutoSizeText(
                            '40-50 كم',
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
