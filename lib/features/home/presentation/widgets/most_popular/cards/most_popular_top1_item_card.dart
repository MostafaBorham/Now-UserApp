import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';





class MostPopularTop1ItemCard extends StatelessWidget {
  const MostPopularTop1ItemCard({super.key});
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (context,con) {
        return Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: AppBorderRadius.brCircular16,
            boxShadow: AppBoxShadows.greyElevation2,
            border: Border.all(
              color: colors.neutral500.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: AppCachedNetworkImage(
                        imageUrl:
                            'https://i.pinimg.com/236x/ea/a7/7c/eaa77cb87594418722bf12af28481fdb.jpg',
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: colors.primaryFixedDim,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '#1',
                          style: AppTextStyles.style10Medium.copyWith(
                            color: colors.white,
                            fontSize: con.maxWidth*0.04
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 5,
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Row(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'VALENTINO',
                                maxLines: 1,
                                style: AppTextStyles.style10Regular.copyWith(
                                  color: colors.neutral500,
                                  letterSpacing: 1,
                                  fontSize: con.maxWidth*0.03
                                ),
                              ),
                            ),
                            CircularAppFavouriteIcon(
                              onFavouriteChanged: (p0) {

                              },
                            ),

                          ],
                        ),
                        Text(
                          'Valentino Uomo Noir',
                          maxLines: 1,
                          style: AppTextStyles.style16Bold.copyWith(
                            color: colors.neutral1200,
                              fontSize: con.maxWidth*0.04
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryFixedDim.withValues(alpha: 0.13),
                            borderRadius: AppBorderRadius.brCircular30,
                          ),
                          child: Text(
                            '🔥 ${LangKeys.hotKey.tr()}',
                            style: AppTextStyles.style10Regular.copyWith(
                              color: colors.primaryFixedDim,
                                fontSize: con.maxWidth*0.03
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 3,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                Assets.media.images.svg.starRate.svg(
                                  width: con.maxWidth*0.04,
                                  height: con.maxWidth*0.04,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    colors.primaryFixedDim,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  '4.9',
                                  style: AppTextStyles.style12SemiBold.copyWith(
                                      color: colors.neutral1200,
                                      fontSize: con.maxWidth*0.03
                                  ),
                                ),
                                Text(
                                  textDirection: TextDirection.ltr,
                                  '· 12.4k ${LangKeys.soldKey.tr()}',
                                  maxLines: 1,
                                  style: AppTextStyles.style12Regular.copyWith(
                                      color: colors.neutral500,
                                      fontSize: con.maxWidth*0.03
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: .min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 5,
                              children: [
                                NewPriceWidget(
                                  color: colors.primaryFixedDim,
                                  price: '10',
                                  size: con.maxWidth*0.06,
                                ),
                                OldPriceWidget(
                                  color: colors.neutral500,
                                  price: '10',
                                  size: con.maxWidth*0.03,
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primaryFixedDim,
                              borderRadius: BorderRadiusGeometry.circular(con.maxWidth*0.04),
                            ),
                            child: Icon(Icons.add,color: colors.white,size: con.maxWidth*0.05,),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      }
    );
  }
}
