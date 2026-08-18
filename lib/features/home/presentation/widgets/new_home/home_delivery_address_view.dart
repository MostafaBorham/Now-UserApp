import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';

class HomeDeliveryAddressView extends StatefulWidget {
  const HomeDeliveryAddressView({super.key});

  @override
  State<HomeDeliveryAddressView> createState() =>
      _HomeDeliveryAddressViewState();
}

class _HomeDeliveryAddressViewState extends State<HomeDeliveryAddressView> {
  // Single-selection: the currently active address in the list.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
                  child: Icon(
                    Icons.clear,
                    color: colors.black,
                    applyTextScaling: true,
                    size: 20,
                  ),
                ),
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
                child: const AppMap(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _AddressItem(
                  icon: Assets.media.images.svg.workAddressIcon,
                  title: 'Al-Bahli Street, 2651',
                  subtitle: 'RDDA2651, Zahra Al-Oudah, Riyadh',
                  highlighted: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                  onEdit: () => context.pushNamed(
                    AppRoutes.addressDetailsScreen,
                    extra: const AddressModel(
                      street: 'Al-Bahli Street, 2651',
                      area: 'RDDA2651, Zahra Al-Oudah, Riyadh',
                    ),
                  ),
                ),
                _AddressItem(
                  icon: Assets.media.images.svg.homeUnselected,
                  title: 'Home',
                  subtitle: '7185 Wadi Al-Sharaf, Al-Qadisiyah',
                  highlighted: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                  onEdit: () => context.pushNamed(
                    AppRoutes.addressDetailsScreen,
                    extra: const AddressModel(
                      street: 'Home',
                      area: '7185 Wadi Al-Sharaf, Al-Qadisiyah',
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () =>
                  context.pushNamed(AppRoutes.addNewAddressFromMapScreen),
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
                      colorFilter: ColorFilter.mode(
                        colors.primary500Main,
                        BlendMode.srcIn,
                      ),
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
            PrimaryAppButton(
              title: LangKeys.confirmAddressKey.tr(),
              onTap: () => context.pop(),
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
    required this.onTap,
    required this.onEdit,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Assets.media.images.svg.editIcon.svg(
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
