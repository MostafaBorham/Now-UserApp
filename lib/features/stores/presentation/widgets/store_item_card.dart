import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

import 'store_info_row.dart';

class StoreItemCard extends StatelessWidget {
  const StoreItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, storeItemConstraints) {
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
                        return Stack(
                          children: [
                            Positioned.fill(
                              bottom: con.maxHeight*0.23,
                              child: AppCachedNetworkImage(
                                imageUrl:
                                    'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                                width: double.infinity,
                                height: double.infinity,
                              ),
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
                                                con.maxHeight * 0.12,
                                              ),
                                            ),
                                      ),
                                      child: FittedBox(
                                        child: Text(
                                          '25%',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: con.maxHeight * 0.1,
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
                                      size: con.maxHeight * 0.15,
                                      onFavouriteChanged: (currentFavourite) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: con.maxWidth*0.05),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  spacing: 8,
                                  children: [
                                    CircularBrandLogo(
                                      radius: con.maxHeight*0.2,
                                      elevation: 0.5,
                                      logoUrl:
                                      'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Panda',
                                        style: AppTextStyles.style18Bold.copyWith(
                                          color: colors.black,
                                          fontSize: con.maxHeight*0.12
                                        ),
                                      ),
                                    ),
                                    AppRateWidget(
                                      starColor: colors.onSecondaryContainer,
                                      rateRatio: '4.5',
                                      rateCount: '4',
                                      rateColor: colors.neutral500,
                                      size: con.maxHeight*0.1,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context,con) {
                      return Padding(
                        padding:  EdgeInsets.symmetric(horizontal: con.maxWidth*0.05,vertical: con.maxWidth*0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              'Panda is supermarket contain everything',
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.neutral500,
                                fontSize: con.maxWidth*0.04
                              ),
                            ),
                            StoreInfoRow(
                              infoFontSize: con.maxWidth*0.04,
                              infoIconSize: con.maxWidth*0.04,
                            ),
                          ],
                        ),
                      );
                    }
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

