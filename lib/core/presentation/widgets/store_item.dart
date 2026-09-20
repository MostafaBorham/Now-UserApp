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
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';

import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'rate/app_rate_widget.dart';

class StoreItem extends StatefulWidget {
  const StoreItem({
    super.key,
    this.storeModel,
    this.onTap,
    this.onFavouriteChanged,
  });
  final StoreModel? storeModel;
  final VoidCallback? onTap;

  final ValueChanged<bool>? onFavouriteChanged;
  @override
  State<StoreItem> createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final int? storeId = widget.storeModel?.id;
    return InkWell(
      // A store that arrived without an id can't be opened; the item still
      // renders, it just doesn't navigate — same guard as [StoreCardView].
      onTap:
          widget.onTap ??
          (storeId == null
              ? null
              : () => context.pushNamed(
                  AppRoutes.storeDetailsScreen,
                  pathParameters: <String, String>{'id': '$storeId'},
                  extra: widget.storeModel?.name,
                )),
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          color: colors.white,
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
                            onFavouriteChanged: widget.onFavouriteChanged,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Material(
                          shape: CircleBorder(),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 1,
                          shadowColor: colors.neutral500.withValues(alpha: 0.5),
                          child: CircularBrandLogo(
                            radius: stackCon.maxHeight * 0.25,
                            backgroundColor: colors.white,
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
                            color: colors.black,
                          ),
                        ),
                        AutoSizeText(
                          context.getLocalizedApiText(
                            widget.storeModel?.description,
                          ),
                          maxLines: 1,
                          style: AppTextStyles.style12Medium.copyWith(
                            color: colors.neutral500.withValues(alpha: 0.8),
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
                                              colors.neutral500,
                                              BlendMode.srcIn,
                                            ),
                                            width:
                                                categoryDetailsCon.maxWidth *
                                                0.045,
                                          ),
                                    ),
                                    NewPriceWidget(
                                      color: colors.black,
                                      price:
                                          '${widget.storeModel?.deliveryFee}',
                                      size: categoryDetailsCon.maxWidth * 0.045,
                                    ),
                                    5.wSpace,
                                    ReverseWidget(
                                      child: Assets.media.images.svg.timeIcon.svg(
                                        colorFilter: ColorFilter.mode(
                                          colors.neutral500,
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
                                            color: colors.black,
                                            fontSize:
                                                categoryDetailsCon.maxWidth *
                                                0.035,
                                          ),
                                    ),
                                    5.wSpace,
                                    ReverseWidget(
                                      child: Assets.media.images.svg.locationIcon.svg(
                                        colorFilter: ColorFilter.mode(
                                          colors.neutral500,
                                          BlendMode.srcIn,
                                        ),
                                        width: categoryDetailsCon.maxWidth*0.04,
                                      ),
                                    ),
                                    AutoSizeText(
                                      '${widget.storeModel?.distance}',
                                      style: AppTextStyles.style12Medium
                                          .copyWith(color: colors.black,fontSize: categoryDetailsCon.maxWidth*0.035,),
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
                                  rateRatio:
                                      '${widget.storeModel?.rating ?? 0}',
                                  rateCount:
                                      '${widget.storeModel?.ratingCount ?? 0}',
                                  rateColor: colors.black.withValues(
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
