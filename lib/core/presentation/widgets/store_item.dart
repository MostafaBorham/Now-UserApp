import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

import '../../../features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'rate/app_rate_widget.dart';

class StoreItem extends StatefulWidget {
  const StoreItem({super.key, this.storeModel});
  final StoreModel? storeModel;
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
                            widget.storeModel?.coverUrl??'',
                        width: double.infinity,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularAppFavouriteIcon(
                          size: stackCon.maxHeight * 0.12,
                          isFavourite: false,
                          onFavouriteChanged: (currentFavourite) {},
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Material(
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 1,
                        shadowColor: colors.onSurface.withValues(alpha: 0.5),
                        child: CircularBrandLogo(
                          radius: stackCon.maxHeight * 0.25,
                          backgroundColor: colors.onPrimary,
                          logoUrl:
                              widget.storeModel?.logoUrl??'',
                        ),
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
                          widget.storeModel?.name??'',
                          style: AppTextStyles.style18Bold.copyWith(
                            color: colors.onSecondary,
                          ),
                        ),
                      ),
                      Flexible(
                        child: AutoSizeText(
                          widget.storeModel?.description??'',
                          maxLines: 2,
                          style: AppTextStyles.style12Medium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              spacing: 5,
                              children: [
                                Assets.media.images.svg.shippingIcon.svg(
                                  colorFilter: ColorFilter.mode(
                                    colors.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                  width: 15,
                                ),
                                Assets.media.images.svg.realSaudiCurrency.svg(
                                  colorFilter: ColorFilter.mode(
                                    colors.onSecondary,
                                    BlendMode.srcIn,
                                  ),
                                  width: 15,
                                ),
                                AutoSizeText(
                                  '${widget.storeModel?.deliveryFee}',
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
                                  width: 15,
                                ),
                                AutoSizeText(
                                  '${widget.storeModel?.deliveryTime}',
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
                                  width: 13,
                                ),
                                AutoSizeText(
                                  '${widget.storeModel?.distance}',
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ],
                            ),
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
                              child: AppRateWidget(
                                starColor: colors.onSecondaryContainer,
                                rateRatio: '${widget.storeModel?.rating}',
                                rateCount: '${widget.storeModel?.ratingCount}',
                                rateColor: colors.onSurface,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
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
  }
}
