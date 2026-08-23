import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/animated_delivery_man_motorcycle_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_delivery_address_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';

class HomeHeaderView extends ConsumerStatefulWidget {
  const HomeHeaderView({super.key, this.searchFieldKey});

  final Key? searchFieldKey;

  @override
  ConsumerState<HomeHeaderView> createState() => _HomeHeaderViewState();
}

class _HomeHeaderViewState extends ConsumerState<HomeHeaderView> {
  String? _displayedAddress;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedFromProvider(ref.read(getMyAddressesProvider));
    });
  }

  /// Fills the header once, the first time addresses are available: the first
  /// saved address's name. When the list is empty [_displayedAddress] is left
  /// null, so the header shows the red "no address selected" placeholder — the
  /// same state a guest (whose addresses never load) always sees.
  void _seedFromProvider(AsyncValue<PaginationModel<AddressModel>> state) {
    if (_seeded || !state.hasValue || !mounted) return;
    _seeded = true;
    final List<AddressModel> addresses = state.valueOrNull?.data ?? const [];
    if (addresses.isEmpty) return;
    setState(() => _displayedAddress = _addressName(addresses.first));
  }

  Future<void> _openDeliveryAddressSheet() async {
    final AddressModel? picked = await showModalBottomSheet<AddressModel>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => const HomeDeliveryAddressView(),
    );
    if (picked == null || !mounted) return;
    setState(() => _displayedAddress = _addressName(picked));
  }

  String _addressName(AddressModel address) {
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
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool hasAddress =
        _displayedAddress != null && _displayedAddress!.isNotEmpty;
    // Seed as soon as the addresses arrive, without resetting on later changes.
    ref.listen<AsyncValue<PaginationModel<AddressModel>>>(
      getMyAddressesProvider,
      (_, AsyncValue<PaginationModel<AddressModel>> next) =>
          _seedFromProvider(next),
    );
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
                                                ? _displayedAddress!
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
                                          onTap: _openDeliveryAddressSheet,
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
                          PrimarySearchField(
                            key: widget.searchFieldKey,
                            onTap: () =>
                                context.pushNamed(AppRoutes.searchScreen),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedDeliveryManMotorcycleView(),
                    ),
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
