import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../assets/assets.gen.dart';
import '../../responsive/spacing_extension.dart';
import '../../styles/app_border_radius.dart';
import '../../styles/text_styles.dart';
import 'circular_brand_logo.dart';
import '../shared/price_with_currency.dart';
import '../shared/previous_price_with_currency.dart';
import '../shared/reverse_widget.dart';

class HomeStoreListItem extends StatefulWidget {
  const HomeStoreListItem({super.key});

  @override
  State<HomeStoreListItem> createState() => _HomeStoreListItemState();
}

class _HomeStoreListItemState extends State<HomeStoreListItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
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
                child: CachedNetworkImage(
                  width: double.infinity,
                  imageUrl:
                      'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 85.0,
                        end: 16,
                        top: 8,
                      ),
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'Panda',
                            style: AppTextStyles.style18Bold.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Assets.media.images.svg.starRate.svg(),
                              AutoSizeText(
                                '4.5 (12)',
                                style: AppTextStyles.style14Medium.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          AutoSizeText(
                            'Panda is suprmarket contain everything',
                            style: AppTextStyles.style14Regular.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          Row(
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
                              5.wSpace,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadiusDirectional.only(
                      bottomEnd: Radius.circular(16),
                    ),
                  ),
                  child: const AutoSizeText(
                    '50%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    isFavorite = !isFavorite;
                    setState(() {
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 1,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 20,
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
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12.0),
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
