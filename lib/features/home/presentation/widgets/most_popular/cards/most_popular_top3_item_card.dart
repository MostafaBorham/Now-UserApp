
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/white_gradient_overlay_effect.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';

/// A compact horizontal product card used inside the "Most Popular" filters list.
///
/// Static/dummy content is hardcoded inline for fast UI iteration; real data
/// will be wired in later.
class MostPopularTop3ItemCard extends StatelessWidget {
  const MostPopularTop3ItemCard({super.key,});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme
        .of(context)
        .colorScheme;
    return LayoutBuilder(
      builder: (context, con) {
        return Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            color: colors.scrim,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.onSurface.withValues(alpha: 0.2), // #00000014
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: colors.onSurface.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    AppCachedNetworkImage(
                      imageUrl:
                      'https://www.britinsurance.com/media/q1vfhqrh/brit-sneakers-01.png?width=768&height=902&v=1dad8ecde3c5bb0',
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Positioned.fill(child: WhiteGradientOverlayEffect()),
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.outlineVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '#2',
                          style: AppTextStyles.style10Medium.copyWith(
                              color: colors.onPrimary,
                              fontSize: con.maxWidth*0.06
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7,vertical: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.onPrimary,
                          borderRadius: BorderRadius.circular(con.maxWidth*0.07),
                        ),
                        child: Text(
                          textDirection: TextDirection.ltr,
                          '-22%',
                          style: AppTextStyles.style10Medium.copyWith(
                              color: colors.outlineVariant,
                              fontSize: con.maxWidth*0.06
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 9,
                      start: 9,
                      child: AppFavouriteIcon(size: con.maxWidth * 0.07),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 0,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VALENTINO',
                                  style: AppTextStyles.style10Regular.copyWith(
                                      color: colors.onSurface,
                                      letterSpacing: 1.2,
                                      fontSize: con.maxWidth*0.05
                                  ),
                                ),
                                Text(
                                  'Valentino Uomo Noir',
                                  maxLines: 1,
                                  style: AppTextStyles.style14Bold.copyWith(
                                      color: colors.onTertiaryFixed,
                                      fontSize:  con.maxWidth*0.08
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Assets.media.images.svg.starRate.svg(
                            width: con.maxWidth*0.07,
                            colorFilter: ColorFilter.mode(
                              colors.onSecondaryContainer,
                              BlendMode.srcIn,
                            ),
                          ),
                          5.wSpace,
                          Text(
                            '4.9',
                            style: AppTextStyles.style14SemiBold.copyWith(
                                color: colors.onTertiaryFixed,
                                fontSize: con.maxWidth*0.07
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NewPriceWidget(
                                color: colors.outlineVariant,
                                price: '10',
                                size: con.maxWidth*0.15,
                              ),
                              OldPriceWidget(
                                color: colors.onSurface,
                                price: '10',
                                size: con.maxWidth*0.07,
                              ),
                            ],
                          ),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.outlineVariant,
                                borderRadius: BorderRadiusGeometry.circular(
                                  con.maxWidth * 0.09,
                                ),
                              ),
                              child: Icon(
                                Icons.add,
                                color: colors.onPrimary,
                                size: con.maxWidth * 0.1,
                              ),
                            ),
                          ),
                          /*                   FloatingActionButton(
                            onPressed: () {},
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(17),
                            ),
                            mini: true,
                            backgroundColor: colors.outlineVariant,
                            child: Text(
                              '+',
                              style: AppTextStyles.style20SemiBold.copyWith(
                                color: colors.onPrimary,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}