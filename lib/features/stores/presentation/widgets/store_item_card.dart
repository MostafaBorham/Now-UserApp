import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/circular_brand_logo.dart';

class StoreItemCard extends StatefulWidget {
  const StoreItemCard({super.key});

  @override
  State<StoreItemCard> createState() => _StoreItemCardState();
}

class _StoreItemCardState extends State<StoreItemCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, storeItemConstraints) {
        final double currentViewWidth = storeItemConstraints.maxWidth;
        return Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            color: colors.onTertiaryContainer,
            borderRadius: AppBorderRadius.brCircular20,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, con) {
                        return Container(
                          color: colors.error,
                          child: Stack(
                            children: [
                              AppCachedNetworkImage(
                                imageUrl:
                                    'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                                width: double.infinity,
                                height: 100,
                              ),
                              Align(
                                alignment: AlignmentDirectional.topCenter,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.errorContainer,
                                          borderRadius:
                                              BorderRadiusDirectional.only(
                                                bottomEnd: Radius.circular(
                                                  con.maxHeight * 0.14,
                                                ),
                                              ),
                                        ),
                                        child: FittedBox(
                                          child: Text(
                                            '25%',
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: colors.onPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: con.maxHeight * 0.12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        end: 16.0,
                                        top: 8,
                                      ),
                                      child: CircularAppFavouriteIcon(
                                        isFavourite: false,
                                        size: con.maxHeight * 0.17,
                                        onFavouriteChanged: (currentFavourite) {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  spacing: 8,
                                  children: [
                                    CircularBrandLogo(
                                      radius: 30,
                                      elevation: 0.5,
                                      logoUrl:
                                      'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Panda',
                                        style: AppTextStyles.style18Bold.copyWith(
                                          color: colors.onSecondary,
                                        ),
                                      ),
                                    ),
                                    AppRateWidget(
                                      starColor: colors.onSecondaryContainer,
                                      rateRatio: '4.5',
                                      rateCount: '4',
                                      rateColor: colors.onSurface,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              'Panda is suprmarket contain everything',
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                Assets.media.images.svg.timeIcon.svg(
                                  width: 16,
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  '40-50 minutes',
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                5.wSpace,
                                Assets.media.images.svg.locationIcon.svg(
                                  width: 14,
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  '40 - 50 km',
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                5.wSpace,
                                Assets.media.images.svg.shippingIcon.svg(
                                  width: 16,
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                NewPriceWidget(
                                  color: colors.onSecondary,
                                  price: '10',
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    /*          Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12.0),
                  child: CircularBrandLogo(
                    radius: 30,
                    elevation: 0.5,
                    logoUrl:
                        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                  ),
                ),
              ),*/
            ],
          ),
        );
      },
    );
  }
}
