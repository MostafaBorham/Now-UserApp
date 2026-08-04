import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
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
  const StoreItem({super.key, this.storeModel, this.onTap});
  final StoreModel? storeModel;
  final VoidCallback? onTap;
  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap:
          widget.onTap ??
          () => context.pushNamed(
            AppRoutes.storeDetailsScreen,
            extra: widget.storeModel?.id,
          ),
      child: Container(
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
                          imageUrl: widget.storeModel?.coverUrl ?? '',
                          width: double.infinity,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularAppFavouriteIcon(
                            size: stackCon.maxHeight * 0.12,
                            favouriteType: FavouriteType.store,
                            itemId: widget.storeModel?.id,
                            isFavourite: widget.storeModel?.isFavorite,
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
                            logoUrl: widget.storeModel?.logoUrl ?? '',
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
                        AutoSizeText(
                          context.getLocalizedApiText(widget.storeModel?.name),
                          style: AppTextStyles.style18Bold.copyWith(
                            color: colors.onSecondary,
                          ),
                        ),
                        AutoSizeText(
                          context.getLocalizedApiText(
                            widget.storeModel?.description,
                          ),
                          maxLines: 1,
                          style: AppTextStyles.style12Medium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        5.hSpace,
                        Flexible(
                          child: Row(
                            spacing: 10,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    ReverseWidget(
                                      child: Assets
                                          .media
                                          .images
                                          .svg
                                          .shippingIcon
                                          .svg(
                                            colorFilter: ColorFilter.mode(
                                              colors.onSurface,
                                              BlendMode.srcIn,
                                            ),
                                            width:
                                                categoryDetailsCon.maxWidth *
                                                0.045,
                                          ),
                                    ),
                                    NewPriceWidget(
                                      color: colors.onSecondary,
                                      price:
                                          '${widget.storeModel?.deliveryFee}',
                                      size: categoryDetailsCon.maxWidth * 0.045,
                                    ),
                                    5.wSpace,
                                    ReverseWidget(
                                      child: Assets.media.images.svg.timeIcon.svg(
                                        colorFilter: ColorFilter.mode(
                                          colors.onSurface,
                                          BlendMode.srcIn,
                                        ),
                                        width:
                                            categoryDetailsCon.maxWidth * 0.045,
                                      ),
                                    ),
                                    AutoSizeText(
                                      '${widget.storeModel?.deliveryTime}',
                                      style: AppTextStyles.style12Medium
                                          .copyWith(
                                            color: colors.onSecondary,
                                            fontSize:
                                                categoryDetailsCon.maxWidth *
                                                0.035,
                                          ),
                                    ),
                                    5.wSpace,
                                    ReverseWidget(
                                      child: Assets.media.images.svg.locationIcon.svg(
                                        colorFilter: ColorFilter.mode(
                                          colors.onSurface,
                                          BlendMode.srcIn,
                                        ),
                                        width: categoryDetailsCon.maxWidth*0.04,
                                      ),
                                    ),
                                    AutoSizeText(
                                      '${widget.storeModel?.distance}',
                                      style: AppTextStyles.style12Medium
                                          .copyWith(color: colors.onSecondary,fontSize: categoryDetailsCon.maxWidth*0.035,),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      categoryDetailsCon.maxHeight * 0.1,
                                  vertical: categoryDetailsCon.maxHeight * 0.05,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.tertiaryFixed,
                                  borderRadius: AppBorderRadius.brCircular20,
                                ),
                                child: AppRateWidget(
                                  starColor: colors.surface,
                                  rateRatio: '${widget.storeModel?.rating}',
                                  rateCount:
                                      '${widget.storeModel?.ratingCount}',
                                  rateColor: colors.onSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  size: categoryDetailsCon.maxWidth*0.04,
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
      ),
    );
  }
}
