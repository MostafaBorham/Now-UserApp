import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

class StoreDetailsHeader extends StatelessWidget {
  const StoreDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.onSecondaryFixed,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : null,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.onPrimary,
                      child: Assets.media.images.svg.appBackArrow.svg(width: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      LangKeys.storesKey.tr(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: AppTextStyles.style24SemiBold.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.onPrimary,
                    child: Assets.media.images.svg.shoppingCartIcon.svg(
                      width: 20,
                      colorFilter: ColorFilter.mode(
                        colors.onSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                AppCachedNetworkImage(
                  imageUrl:
                      'https://thumbs.dreamstime.com/b/fresh-produce-display-rustic-wooden-tabletop-grocery-store-background-image-design-projects-stunning-bird-eye-view-366982676.jpg',
                  width: double.infinity,
                  height: 150,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 118),
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.onPrimary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      AutoSizeText(
                        'I am a store that sells food products and all basic needs',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style14Medium.copyWith(
                          color: colors.onSecondary,
                        ),
                      ),
                      12.hSpace,
                      const _StoreDeliveryDetails(),
                    ],
                  ),
                ),
                PositionedDirectional(
                  bottom: 96,
                  child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 2,
                    child: CircularBrandLogo(
                      radius: 32,
                      backgroundColor: colors.onPrimary,
                      logoUrl:
                          'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreDeliveryDetails extends StatelessWidget {
  const _StoreDeliveryDetails();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          _DeliveryDetailItem(
            icon: Assets.media.images.svg.timeIcon,
            label: '40-50 minutes',
          ),
          _DeliveryDetailItem(
            icon: Assets.media.images.svg.locationIcon,
            label: '40 - 50 km',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Assets.media.images.svg.shippingIcon.svg(
                width: 16,
                colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
              ),
              Assets.media.images.svg.realSaudiCurrency.svg(
                width: 13,
                colorFilter: ColorFilter.mode(
                  colors.onSecondary,
                  BlendMode.srcIn,
                ),
              ),
              Text(
                '10',
                style: AppTextStyles.style14SemiBold.copyWith(
                  color: colors.onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryDetailItem extends StatelessWidget {
  const _DeliveryDetailItem({required this.icon, required this.label});
  final SvgGenImage icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        icon.svg(
          width: 16,
          colorFilter: ColorFilter.mode(colors.onSurface, BlendMode.srcIn),
        ),
        Text(
          label,
          style: AppTextStyles.style12Medium.copyWith(
            color: colors.onSecondary,
          ),
        ),
      ],
    );
  }
}
