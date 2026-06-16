import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import '../../responsive/spacing_extension.dart';
import '../../styles/app_border_radius.dart';
import '../../styles/text_styles.dart';
import 'circular_brand_logo.dart';

class BestNearbyStoresListItem extends StatefulWidget {
  const BestNearbyStoresListItem({super.key});

  @override
  State<BestNearbyStoresListItem> createState() =>
      _BestNearbyStoresListItemState();
}

class _BestNearbyStoresListItemState extends State<BestNearbyStoresListItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constrains) {
        return SizedBox(
          width: 280.w,
          child: Card(
            elevation: 2,
            shadowColor: colors.onTertiaryContainer.withValues(alpha: 0.4),
            color: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular18,
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              spacing: 8,
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
                          radius: 24.r,
                          logoUrl:
                              'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          isFavorite = !isFavorite;
                          setState(() {});
                        },
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: constrains.maxHeight * 0.08,
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
                                        width: constrains.maxHeight * 0.08,
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
                        'متجر الباندا',
                        style: AppTextStyles.style18SemiBold.copyWith(
                          color: colors.onSecondary,
                        ),
                      ),
                      2.hSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 5.w,
                        children: [
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
