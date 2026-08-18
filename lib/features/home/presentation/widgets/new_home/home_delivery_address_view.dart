import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

class HomeDeliveryAddressView extends StatelessWidget {
  const HomeDeliveryAddressView({
    super.key,
    this.onClose,
    this.onCurrentLocation,
    this.onAddNewAddress,
    this.onConfirm,
  });

  final VoidCallback? onClose;
  final VoidCallback? onCurrentLocation;
  final VoidCallback? onAddNewAddress;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(

      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.neutral300,
                  borderRadius: AppBorderRadius.brCircular30,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LangKeys.deliveryAddressKey.tr(),
                  style: AppTextStyles.style20SemiBold.copyWith(
                    color: colors.tertiaryContainer,
                  ),
                ),
                InkWell(
                    onTap: () => context.pop(),
                    child: Icon(Icons.clear,color: colors.black,applyTextScaling: true,size: 20,))
              ],
            ),
            ClipRRect(
              borderRadius: AppBorderRadius.brCircular12,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.neutral200),
                  borderRadius: AppBorderRadius.brCircular12,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Assets.media.images.png.map.image(
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: Assets.media.images.svg.mapMarkerIcon.svg(
                        width: 20,
                        height: 20,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 7,
                      end: 3,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onCurrentLocation,
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8,
                            end: 10,
                            top: 8,
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.white,
                            borderRadius: AppBorderRadius.brCircular30,
                            boxShadow: [
                              BoxShadow(
                                color: colors.black.withValues(alpha: 0.08),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Assets.media.images.svg.locationIcon.svg(
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  colors.tertiaryContainer,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Text(
                                LangKeys.currentLocationKey.tr(),
                                style: AppTextStyles.style12SemiBold.copyWith(
                                  color: colors.tertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _AddressItem(
                  icon: Assets.media.images.svg.workUnselected,
                  title: 'Al-Bahli Street, 2651',
                  subtitle: 'RDDA2651, Zahra Al-Oudah, Riyadh',
                  highlighted: true,
                ),
                _AddressItem(
                  icon: Assets.media.images.svg.homeUnselected,
                  title: 'Home',
                  subtitle: '7185 Wadi Al-Sharaf, Al-Qadisiyah',
                  highlighted: false,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAddNewAddress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.brCircular8,
                      border: Border.all(color: colors.neutral200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Assets.media.images.svg.addCircle.svg(
                          width: 24,
                          height: 24,
                        ),
                        Text(
                          LangKeys.addNewAddress.tr(),
                          style: AppTextStyles.style16Medium.copyWith(
                            color: colors.primary500Main,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            PrimaryAppButton(
              title: LangKeys.confirmAddressKey.tr(),
              onTap: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? colors.scrim : colors.primaryFixed,
        borderRadius: AppBorderRadius.brCircular12,
        border: highlighted
            ? Border.all(color: colors.surfaceContainerHigh)
            : null,
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted
                  ? colors.surfaceContainerHigh
                  : colors.onPrimaryContainer,
            ),
            child: icon.svg(
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                colors.neutral1200,
                BlendMode.srcIn,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: AppTextStyles.style16SemiBold.copyWith(
                    color: colors.neutral1200,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Assets.media.images.svg.edit.svg(width: 20, height: 20),
        ],
      ),
    );
  }
}
