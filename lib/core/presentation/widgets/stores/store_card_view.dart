import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

class StoreCardView extends StatelessWidget {
  const StoreCardView({super.key, this.store});

  final StoreModel? store;

  static const String _demoCoverUrl =
      'https://ccwetpprodstorage.blob.core.windows.net/prodpublicaccessblob/public-files/64d51e54708fb908287aca6f2d5091a2.jpeg?raw=1';
  static const String _demoLogoUrl =
      'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png';

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final bool hasStore = store != null;
    final String coverUrl = hasStore ? (store!.coverUrl ?? '') : _demoCoverUrl;
    final String logoUrl = hasStore ? (store!.logoUrl ?? '') : _demoLogoUrl;
    final String storeName = hasStore
        ? context.getLocalizedApiText(store!.name)
        : 'شركة دار الاميرات';
    final String storeDescription = hasStore
        ? context.getLocalizedApiText(store!.description)
        : 'شركة دار الأميرات هي واحدة من أشهر وأبرز الوجهات في المملكة العربية السعودية المتخصصة في عالم التجميل';
    final String rating = hasStore ? '${formatDouble(store!.rating)}' : '4.5';
    final String ratingCount = hasStore ? '${store!.ratingCount ?? 0}' : '4';
    final String deliveryTime = hasStore
        ? (store!.deliveryTime ?? '0 ${LangKeys.minutesKey.tr()}')
        : '40-50 ${LangKeys.minutesKey.tr()}';
    final String distance = hasStore
        ? '${formatDouble(store!.distance)} ${LangKeys.kmKey.tr()}'
        : '40 - 50 ${LangKeys.kmKey.tr()}';
    final String deliveryFee = hasStore ? '${formatDouble(store!.deliveryFee)}' : '10';

    return LayoutBuilder(
      builder: (context, con) {
        final double w = con.maxWidth;
        final double logoRadius = w * 0.09;
        final double coverHeight = w * 0.32;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: AppBorderRadius.brCircular16,
            boxShadow: [
              BoxShadow(
                color: colors.black.withValues(alpha: 0.25),
                offset: Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AppCachedNetworkImage(
                        imageUrl: coverUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: const BorderRadiusDirectional.only(
                            bottomEnd: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          '25%',
                          style: AppTextStyles.style14Bold.copyWith(
                            color: colors.white,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: 8,
                      top: 8,
                      child: CircularAppFavouriteIcon(
                        size: w * 0.05,
                        favouriteType: FavouriteType.store,
                        itemId: store?.id,
                        isFavourite: store?.isFavorite ?? false,
                        onFavouriteChanged: (currentFavourite) {},
                      ),
                    ),
                    PositionedDirectional(
                      start: 16,
                      bottom: -logoRadius,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.neutral200.withValues(alpha: 0.5)),
                        ),
                        child: CircularBrandLogo(
                          radius: logoRadius,
                          elevation: 0,
                          backgroundColor: colors.white,
                          logoUrl: logoUrl,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ).copyWith(top: 8, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: logoRadius * 2 + 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              storeName,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: AppTextStyles.style18Bold.copyWith(
                                color: colors.black,
                              ),
                            ),
                          ),
                          AppRateWidget(
                            starColor: colors.amber500,
                            rateRatio: rating,
                            rateCount: ratingCount,
                            rateColor: colors.neutral500,
                            size: w * 0.045,
                          ),
                        ],
                      ),
                    ),
                    AutoSizeText(
                      textDirection: TextDirection.ltr,
                      storeDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                    ),
                    StoreInfoRow(
                      deliveryTime: deliveryTime,
                      distance: distance,
                      deliveryFee: deliveryFee,
                      infoIconSize: w * 0.045,
                      infoFontSize: w * 0.04,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
