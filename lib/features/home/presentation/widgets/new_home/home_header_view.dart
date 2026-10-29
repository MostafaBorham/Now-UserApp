import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/home_address_provider.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/animated_delivery_man_motorcycle_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/header_intro_animations.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_delivery_address_view.dart';
import 'package:nowdelivery_user_app/features/address/presentation/utils/address_line.dart';

class HomeHeaderView extends ConsumerWidget {
  const HomeHeaderView({
    super.key,
    this.searchFieldKey,
    this.searchBarHeight,
    this.showCategories = true,
    this.categories = const <CategoryModel>[],
  });

  final Key? searchFieldKey;

  final ValueListenable<double>? searchBarHeight;

  /// Whether the categories carousel (and its "see all") render. The header
  /// chrome — greeting, address, search, logo, motorcycle — is always shown; a
  /// missing `categories` section only hides the carousel, not the header.
  final bool showCategories;

  /// Items of the feed's `categories` section, rendered by the carousel.
  final List<CategoryModel> categories;

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
    final String line = addressLine(context, address);
    return line.isNotEmpty ? line : context.getLocalizedApiText(address.label);
  }

  // home_header_background.svg is 390 wide; the shape is 457 tall and the
  // viewBox adds 60 of headroom above it.
  static const double _artWidth = 390;
  static const double _artHeight = 457;
  static const double _artHeadroom = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final double statusBar = MediaQuery.paddingOf(context).top;
    // The delivery address the home page shows: the user's default saved
    // address (else the current location), or whatever they last confirmed in
    // the sheet.
    final AddressModel? current = ref.watch(homeAddressProvider);
    final String displayedAddress = current == null
        ? ''
        : _addressName(context, current);
    final bool hasAddress = displayedAddress.isNotEmpty;
    return LayoutBuilder(
      builder: (context, con) {
        final double artScale = con.maxWidth / _artWidth;
        // The logo row sits under the status bar but the shape scales with the
        // width alone, so a status bar taller than 24 dp (notch, camera hole)
        // put the logo on the shape's bottom edge (realme C35). The shape
        // moves down by the difference, uncovering the SVG's headroom.
        final double artDrop = (statusBar - 24).clamp(
          0.0,
          _artHeadroom * artScale,
        );
        return Stack(
          children: [
            ReverseWidget(
              applyReverse: !context.isRTL,
              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                // Sized from outside: given both, SvgPicture drops the width
                // and keeps the art's aspect ratio from the height.
                child: SizedBox(
                  width: con.maxWidth,
                  height: _artHeight * artScale + artDrop,
                  child: Assets.media.images.svg.homeHeaderBackground.svg(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                bottom: false,
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
                          // Its height places the search field's slot below
                          // it; Home re-measures the slot when that changes.
                          SizeChangedLayoutNotifier(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      // The whole row opens the sheet, not just
                                      // the small arrow at its end.
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            _openDeliveryAddressSheet(context),
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            // No pin without an address: a pin
                                            // over "set your location" read as a
                                            // location the app had found.
                                            if (hasAddress)
                                              Assets
                                                  .media
                                                  .images
                                                  .svg
                                                  .homeLocationIcon
                                                  .svg(
                                                    width: con.maxWidth * 0.05,
                                                  ),
                                            Flexible(
                                              child: Text(
                                                hasAddress
                                                    ? displayedAddress
                                                    : LangKeys
                                                          .setYourLocationKey
                                                          .tr(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colors.black,
                                                  fontWeight: hasAddress
                                                      ? FontWeight.w400
                                                      : FontWeight.w600,
                                                  fontSize: con.maxWidth * 0.03,
                                                ),
                                              ),
                                            ),
                                            RotatedBox(
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Assets
                                    .media
                                    .images
                                    .svg
                                    .appLogos
                                    .homeWhiteAppLogo
                                    .svg(
                                      fit: BoxFit.contain,
                                      width: con.maxWidth * 0.3,
                                    ),
                              ],
                            ),
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
                      Expanded(
                        flex: 4,
                        child: HomeAppCategoriesView(categories: categories),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () =>
                              context.pushNamed(AppRoutes.categoriesScreen),
                          behavior: HitTestBehavior.opaque,
                          child: const IgnorePointer(
                            child: RepaintBoundary(child: SeeAllAnimation()),
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
