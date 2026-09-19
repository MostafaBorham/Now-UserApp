import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/home_address_provider.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/animated_delivery_man_motorcycle_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_delivery_address_view.dart';

class HomeHeaderView extends ConsumerWidget {
  const HomeHeaderView({
    super.key,
    this.searchFieldKey,
    this.searchBarHeight,
    this.showCategories = true,
  });

  final Key? searchFieldKey;

  final ValueListenable<double>? searchBarHeight;

  /// Whether the categories carousel (and its "see all") render. The header
  /// chrome — greeting, address, search, logo, motorcycle — is always shown; a
  /// missing `categories` section only hides the carousel, not the header.
  final bool showCategories;

  Future<void> _openDeliveryAddressSheet(BuildContext context) {
    // The sheet writes the confirmed address into [homeAddressProvider] itself,
    // which this header watches — so there is nothing to read back on close.
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => const HomeDeliveryAddressView(),
    );
  }

  String _addressName(BuildContext context, AddressModel address) {
    final String full = address.fullAddress ?? '';
    if (full.isNotEmpty) return full;

    final String label = context.getLocalizedApiText(address.label);
    if (label.isNotEmpty) return label;

    return <String?>[
      address.street,
      address.area,
      address.city,
    ].whereType<String>().where((String e) => e.isNotEmpty).join('، ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    // The delivery address the home page shows: the current location (or the
    // default) by default, or whatever the user last confirmed in the sheet.
    final AddressModel? current = ref.watch(homeAddressProvider);
    final String displayedAddress =
        current == null ? '' : _addressName(context, current);
    final bool hasAddress = displayedAddress.isNotEmpty;
    return LayoutBuilder(
      builder: (context, con) {
        return Stack(
          children: [
            ReverseWidget(
              applyReverse: !context.isRTL,
              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Assets.media.images.svg.homeHeaderBackground.svg(
                  fit: BoxFit.cover,
                  width: con.maxWidth,
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  spacing: 10,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ).copyWith(top: 8),
                      child: Column(
                        spacing: 12,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Expanded(
                                child: Column(
                                  spacing: 5,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LangKeys.homeGreetingKey.tr(),
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: con.maxWidth * 0.04,
                                      ),
                                    ),
                                    Row(
                                      spacing: 5,
                                      children: [
                                        Assets.media.images.svg.homeLocationIcon
                                            .svg(width: con.maxWidth * 0.05),
                                        Flexible(
                                          child: Text(
                                            hasAddress
                                                ? displayedAddress
                                                : LangKeys.noAddressSelectedKey
                                                      .tr(),
                                            textDirection: TextDirection.ltr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: hasAddress
                                                  ? colors.black
                                                  : colors.error,
                                              fontWeight: FontWeight.w400,
                                              fontSize: con.maxWidth * 0.03,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              _openDeliveryAddressSheet(context),
                                          child: RotatedBox(
                                            quarterTurns: 1,
                                            child: Assets
                                                .media
                                                .images
                                                .svg
                                                .arrowBrokenIcon
                                                .svg(
                                                  width: con.maxWidth * 0.04,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Assets.media.images.svg.appLogos.homeWhiteAppLogo
                                  .svg(
                                    fit: BoxFit.contain,
                                    width: con.maxWidth * 0.3,
                                  ),
                            ],
                          ),
                          ValueListenableBuilder<double>(
                            valueListenable:
                                searchBarHeight ?? ValueNotifier<double>(0),
                            builder: (context, height, _) => SizedBox(
                              key: searchFieldKey,
                              width: double.infinity,
                              height: height > 0
                                  ? height
                                  : 30 + con.maxWidth * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedDeliveryManMotorcycleView(),
                    ),
                    // The categories carousel + its "see all" are driven by the
                    // `categories` home section; hidden when it is absent.
                    if (showCategories) ...<Widget>[
                      Expanded(flex: 4, child: HomeAppCategoriesView()),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () =>
                              context.pushNamed(AppRoutes.categoriesScreen),
                          behavior: HitTestBehavior.opaque,
                          child: IgnorePointer(
                            child: RepaintBoundary(
                              child: AnimatedSvgPicture.asset(
                                context.isRTL
                                    ? Assets.media.images.svg.viewAllArabic.path
                                    : Assets
                                          .media
                                          .images
                                          .svg
                                          .englishAnimatedSeeAll
                                          .path,
                                fit: BoxFit.contain,
                                playbackRate: 1,
                                autoPlay: true,
                                placeholderBuilder: (BuildContext context) =>
                                    SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
