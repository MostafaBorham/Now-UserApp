import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_box_shadows.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';

class CategoryStoreItem extends StatefulWidget {
  const CategoryStoreItem({super.key});

  @override
  State<CategoryStoreItem> createState() => _CategoryStoreItemState();
}

class _CategoryStoreItemState extends State<CategoryStoreItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular20,
        boxShadow: AppBoxShadows.blackBottomShadow2
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  width: double.infinity,
                  imageUrl:
                  'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                  fit: BoxFit.cover,
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
                          )
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
                setState(() {
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Material(
                  elevation: 1,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: colors.onPrimary,
                    child: (isFavorite? Assets.media.images.svg.filledFavouriteIcon : Assets.media.images.svg.favouriteIcon).svg(
                      width: 16.sp,
                      colorFilter: ColorFilter.mode(
                        isFavorite ? colors.errorContainer : colors.onTertiaryFixed,
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