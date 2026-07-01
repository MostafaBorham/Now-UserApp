import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/images/app_cached_network_image.dart';

class StoreItem extends StatefulWidget {
  const StoreItem({super.key});

  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular20,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, stackCon) {
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: stackCon.maxHeight * 0.1,
                      ),
                      child: AppCachedNetworkImage(
                        imageUrl:
                            'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                        width: double.infinity,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: InkWell(
                        onTap: () {
                          isFavorite = !isFavorite;
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Material(
                            elevation: 1,
                            shape: const CircleBorder(),
                            child: CircleAvatar(
                              radius: stackCon.maxHeight * 0.12,
                              backgroundColor: colors.onPrimary,
                              child:
                                  (isFavorite
                                          ? Assets
                                                .media
                                                .images
                                                .svg
                                                .filledFavouriteIcon
                                          : Assets
                                                .media
                                                .images
                                                .svg
                                                .favouriteIcon)
                                      .svg(
                                        width: stackCon.maxHeight * 0.12,
                                        colorFilter: ColorFilter.mode(
                                          isFavorite
                                              ? colors.errorContainer
                                              : colors.onTertiaryFixed,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Material(
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 1,
                        child: CircularBrandLogo(
                          radius: stackCon.maxHeight * 0.25,
                          backgroundColor: colors.onPrimary,
                          logoUrl:
                              'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                        ),
                        shadowColor: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (context, categoryDetailsCon) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: categoryDetailsCon.maxHeight * 0.1,
                  ).copyWith(bottom: categoryDetailsCon.maxHeight * 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AutoSizeText(
                          'Panda',
                          style: AppTextStyles.style18Bold.copyWith(
                            color: colors.onSecondary,
                          ),
                        ),
                      ),
                      Flexible(
                        child: AutoSizeText(
                          'Panda is supermarket contain everything',
                          maxLines: 2,
                          style: AppTextStyles.style12Medium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Assets.media.images.svg.shippingIcon.svg(
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                  width: 15
                                ),
                                Assets.media.images.svg.realSaudiCurrency.svg(
                                  colorFilter: ColorFilter.mode(
                                    colors.onSecondary,
                                    BlendMode.srcIn,
                                  ),
                                  width: 15
                                ),
                                AutoSizeText(
                                  '10',
                                  style: AppTextStyles.style14SemiBold.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),

                                5.wSpace,
                                Assets.media.images.svg.timeIcon.svg(
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                  width: 15
                                ),
                                AutoSizeText(
                                  '40-50 minutes',
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                                5.wSpace,
                                Assets.media.images.svg.locationIcon.svg(
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                  width: 13
                                ),
                                AutoSizeText(
                                  '40 - 50 km',
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: categoryDetailsCon.maxHeight * 0.1,
                                vertical: categoryDetailsCon.maxHeight * 0.05,
                              ),
                              decoration: BoxDecoration(
                                color: colors.tertiaryFixed,
                                borderRadius: AppBorderRadius.brCircular20,
                              ),
                              child: FittedBox(
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    Assets.media.images.svg.starIcon.svg(
                                      width: 17,
                                      colorFilter: ColorFilter.mode(colors.surface, BlendMode.srcIn)
                                    ),
                                    AutoSizeText(
                                      '4.5 (12)',
                                      style: AppTextStyles.style14Medium
                                          .copyWith(color: colors.onSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular20,
        boxShadow: AppBoxShadows.blackBottomShadow2,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCachedNetworkImage(
                  imageUrl:
                      'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                  width: double.infinity,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      AutoSizeText(
                        'Panda',
                        style: AppTextStyles.style18Bold.copyWith(
                          color: colors.onSecondary,
                        ),
                      ),
                      AutoSizeText(
                        'Panda is suprmarket contain everything',
                        style: AppTextStyles.style14Regular.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      Row(
                        spacing: 5.w,
                        children: [
                          Assets.media.images.svg.shippingIcon.svg(
                            width: 16.sp,
                            colorFilter: ColorFilter.mode(
                              colors.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                          AutoSizeText(
                            '10',
                            style: AppTextStyles.style14SemiBold.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                          Assets.media.images.svg.realSaudiCurrency.svg(
                            width: 15.sp,
                            colorFilter: ColorFilter.mode(
                              colors.onSecondary,
                              BlendMode.srcIn,
                            ),
                          ),
                          5.wSpace,
                          Assets.media.images.svg.timeIcon.svg(
                            width: 16.sp,
                            colorFilter: ColorFilter.mode(
                              colors.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                          AutoSizeText(
                            '10',
                            style: AppTextStyles.style12Medium.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                          5.wSpace,
                          Assets.media.images.svg.locationIcon.svg(
                            width: 14.sp,
                            colorFilter: ColorFilter.mode(
                              colors.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                          AutoSizeText(
                            '10',
                            style: AppTextStyles.style12Medium.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                          20.wSpace,
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.tertiaryFixed,
                              borderRadius: AppBorderRadius.brCircular20.r,
                            ),
                            child: Row(
                              spacing: 5,
                              children: [
                                Assets.media.images.svg.starRate.svg(),
                                AutoSizeText(
                                  '4.5 (12)',
                                  style: AppTextStyles.style14Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: InkWell(
              onTap: () {
                isFavorite = !isFavorite;
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  elevation: 1,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: colors.onPrimary,
                    child:
                        (isFavorite
                                ? Assets.media.images.svg.filledFavouriteIcon
                                : Assets.media.images.svg.favouriteIcon)
                            .svg(
                              width: 16.sp,
                              colorFilter: ColorFilter.mode(
                                isFavorite
                                    ? colors.errorContainer
                                    : colors.onTertiaryFixed,
                                BlendMode.srcIn,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 30.0),
              child: CircularBrandLogo(
                radius: 30.r,
                logoUrl:
                    'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
