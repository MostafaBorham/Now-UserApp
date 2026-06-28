import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/previous_price_with_currency.dart';

/// A compact horizontal product card used inside the "Most Popular" filters list.
///
/// Static/dummy content is hardcoded inline for fast UI iteration; real data
/// will be wired in later.
class MostPopularHorizontalItem extends StatelessWidget {
  const MostPopularHorizontalItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppBorderRadius.brCircular16,
        boxShadow: AppBoxShadows.greyElevation2,
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1.w,
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
                        'https://images3.alphacoders.com/641/thumb-1920-641462.jpg',
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
                PositionedDirectional(
                  top: 8.h,
                  start: 8.w,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primaryFixedDim,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#1',
                      style: AppTextStyles.style10Medium.copyWith(
                        color: colors.onPrimary,
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
                // Brand, name, favourite + Hot tag
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
                              color: colors.onSurface,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Icon(Icons.favorite_outline, color: colors.onSurface),
                      ],
                    ),
                    Text(
                      'Valentino Uomo Noir',
                      maxLines: 1,
                      style: AppTextStyles.style16Bold.copyWith(
                        color: colors.onTertiaryFixed,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryFixedDim.withValues(alpha: 0.13),
                        borderRadius: AppBorderRadius.brCircular30,
                      ),
                      child: Text(
                        '🔥 ${LangKeys.hotKey.tr()}',
                        style: AppTextStyles.style10Regular.copyWith(
                          color: colors.primaryFixedDim,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Assets.media.images.svg.starRate.svg(
                              width: 12.w,
                              height: 12.w,
                              colorFilter: ColorFilter.mode(
                                colors.primaryFixedDim,
                                BlendMode.srcIn,
                              ),
                            ),
                            Text(
                              '4.9',
                              style: AppTextStyles.style12SemiBold.copyWith(
                                color: colors.onTertiaryFixed,
                              ),
                            ),
                            Text(
                              '· 12.4k ${LangKeys.soldKey.tr()}',
                              maxLines: 1,
                              style: AppTextStyles.style12Regular.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Assets.media.images.svg.realSaudiCurrency.svg(
                              height: 25,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                colors.primaryFixedDim,
                                BlendMode.srcIn,
                              ),
                            ),
                            4.wSpace,
                            Text(
                              '10',
                              style: AppTextStyles.style32SemiBold.copyWith(
                                color: colors.primaryFixedDim,
                                height: 1
                              ),
                            ),
                            8.wSpace,
                            const PreviousPriceWithCurrency(),
                          ],
                        ),
                      ],
                    ),
                    FloatingActionButton(onPressed: () {

                    },mini: true,backgroundColor: colors.primaryFixedDim,child: Text('+',style: AppTextStyles.style20SemiBold.copyWith(
                      color: colors.onPrimary
                    ),),)
                  ],
                ),
              ],
            ),
          ),
          /*          Stack(
            children: [
              Positioned.fill(
                child: AppCachedNetworkImage(
                  imageUrl:
                      'https://images3.alphacoders.com/641/thumb-1920-641462.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              PositionedDirectional(
                top: 8.h,
                start: 8.w,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryFixedDim,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '#1',
                    style: AppTextStyles.style10Medium.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand, name, favourite + Hot tag
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VALENTINO',
                                maxLines: 1,
                                style: AppTextStyles.style10Regular.copyWith(
                                  color: colors.onSurface,
                                  letterSpacing: 1,
                                ),
                              ),
                              2.hSpace,
                              Text(
                                'Valentino Uomo Noir',
                                maxLines: 1,
                                style: AppTextStyles.style16Bold.copyWith(
                                  color: colors.onTertiaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        8.wSpace,
                        Assets.media.images.svg.favouriteIcon.svg(
                          width: 18.w,
                          height: 18.w,
                          colorFilter: ColorFilter.mode(
                            colors.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                    8.hSpace,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primaryFixedDim.withValues(alpha: 0.13),
                        borderRadius: AppBorderRadius.brCircular30,
                      ),
                      child: Text(
                        '🔥 ${LangKeys.hotKey.tr()}',
                        style: AppTextStyles.style10Regular.copyWith(
                          color: colors.primaryFixedDim,
                        ),
                      ),
                    ),
                  ],
                ),
                // Rating, price + add button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Assets.media.images.svg.starRate.svg(
                                width: 12.w,
                                height: 12.w,
                                colorFilter: ColorFilter.mode(
                                  colors.primaryFixedDim,
                                  BlendMode.srcIn,
                                ),
                              ),
                              4.wSpace,
                              Text(
                                '4.9',
                                style: AppTextStyles.style12SemiBold.copyWith(
                                  color: colors.onTertiaryFixed,
                                ),
                              ),
                              4.wSpace,
                              Flexible(
                                child: Text(
                                  '· 12.4k ${LangKeys.soldKey.tr()}',
                                  maxLines: 1,
                                  style: AppTextStyles.style12Regular.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          4.hSpace,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Assets.media.images.svg.realSaudiCurrency.svg(
                                width: 20.w,
                                height: 22.h,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  colors.primaryFixedDim,
                                  BlendMode.srcIn,
                                ),
                              ),
                              4.wSpace,
                              Text(
                                '10',
                                style: AppTextStyles.style32SemiBold.copyWith(
                                  color: colors.primaryFixedDim,
                                  height: 1,
                                ),
                              ),
                              8.wSpace,
                              const PreviousPriceWithCurrency(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    8.wSpace,
                    Container(
                      width: 38.w,
                      height: 38.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primaryFixedDim,
                        borderRadius: AppBorderRadius.brCircular14,
                      ),
                      child: Assets.media.images.svg.addToCartIcon.svg(
                        width: 18.w,
                        height: 18.w,
                        colorFilter: ColorFilter.mode(
                          colors.onPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}
