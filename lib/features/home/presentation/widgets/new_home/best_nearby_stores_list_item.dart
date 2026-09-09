import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_type.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

/// A detail row of the store card, shrunk to fit rather than overflowing.
///
/// The rows hold feed-driven text of unpredictable width, so they are sized
/// down as a whole — keeping the design's icon-to-text proportions — instead of
/// ellipsizing one value or clipping the row. Same approach as
/// `HomeFeaturedStoreItem`'s store info row.
class _ScaledRow extends StatelessWidget {
  const _ScaledRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 5,
        children: children,
      ),
    );
  }
}

/// One store card of the `nearby_stores` section: the store's cover with its
/// logo centred over it, a favourite toggle, then the store's name, rating,
/// delivery fee, travel time and distance.
///
/// Every detail below the name is optional — a feed section still sending the
/// thin vendor item (id/name/image_url only) leaves them null, and each row is
/// simply left out rather than rendered as a zero.
class BestNearbyStoresListItem extends StatelessWidget {
  const BestNearbyStoresListItem({super.key, required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, constrains) {
        // Icon and text sizes are proportional to the card so the section keeps
        // its design proportions at any height the home feed gives it.
        final double iconSize = constrains.maxHeight * 0.08;
        return SizedBox(
          width: constrains.maxHeight * 1.1,
          child: Card(
            elevation: 2,
            shadowColor: colors.onTertiaryContainer.withValues(alpha: 0.4),
            color: colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.brCircular18,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              spacing: 16,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AppCachedNetworkImage(
                          imageUrl: store.coverUrl ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // The design's scrim over the cover, so a light storefront
                      // photo never washes out the logo sitting on top of it.
                      // Both stops are the design's literal values — neither
                      // has a theme token (the palette's nearest neutral is
                      // #A1A1A1, visibly lighter than the #666 this fades to).
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0x33000000),
                                Color(0x33666666),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: CircularBrandLogo(
                          // 0.12 of the card height puts the circle at the
                          // design's 48px, and the logo inside it fills the
                          // design's ~28px rather than the 0.7 default's 17px.
                          radius: constrains.maxHeight * 0.12,
                          logoUrl: store.logoUrl ?? '',
                          backgroundColor: colors.white,
                          logoScale: 1.2,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularAppFavouriteIcon(
                            size: iconSize,
                            isFavourite: store.isFavorite ?? false,
                            favouriteType: FavouriteType.store,
                            itemId: store.id,
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
                        context.getLocalizedApiText(store.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.style18SemiBold.copyWith(
                          color: colors.black,
                        ),
                      ),
                      2.hSpace,
                      // Both detail rows scale down instead of overflowing:
                      // their content is data-driven (a '120-150' delivery
                      // window, a two-digit distance, a four-figure rating
                      // count) and the card is only ever as wide as the height
                      // the feed gives the section.
                      _ScaledRow(
                        children: [
                          if (store.deliveryFee != null) ...[
                            ReverseWidget(
                              child: Assets.media.images.svg.shippingIcon.svg(
                                width: iconSize,
                                colorFilter: ColorFilter.mode(
                                  colors.neutral500,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            NewPriceWidget(
                              color: colors.black,
                              price: '${formatDouble(store.deliveryFee)}',
                              size: iconSize,
                            ),
                          ],
                          if (store.rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.tertiaryFixed,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: AppRateWidget(
                                starColor: colors.surface,
                                rateRatio: '${formatDouble(store.rating)}',
                                rateCount: store.ratingCount?.toString(),
                                rateColor: colors.black,
                                size: constrains.maxHeight * 0.07,
                              ),
                            ),
                        ],
                      ),
                      _ScaledRow(
                        children: [
                          if (store.deliveryTime != null) ...[
                            Assets.media.images.svg.timeIcon.svg(
                              width: iconSize,
                              colorFilter: ColorFilter.mode(
                                colors.neutral500,
                                BlendMode.srcIn,
                              ),
                            ),
                            Text(
                              '${store.deliveryTime} ${LangKeys.minutesKey.tr()}',
                              maxLines: 1,
                              style: AppTextStyles.style14Medium.copyWith(
                                color: colors.black,
                              ),
                            ),
                          ],
                          if (store.distance != null) ...[
                            Assets.media.images.svg.locationIcon.svg(
                              width: constrains.maxHeight * 0.07,
                              colorFilter: ColorFilter.mode(
                                colors.neutral500,
                                BlendMode.srcIn,
                              ),
                            ),
                            Text(
                              '${formatDouble(store.distance)} ${LangKeys.kmKey.tr()}',
                              maxLines: 1,
                              style: AppTextStyles.style14Medium.copyWith(
                                color: colors.black,
                              ),
                            ),
                          ],
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
