import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/animated_delivery_man_motorcycle_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_delivery_address_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_search_field.dart';

class HomeHeaderView extends ConsumerStatefulWidget {
  const HomeHeaderView({super.key});

  @override
  ConsumerState<HomeHeaderView> createState() => _HomeHeaderViewState();
}

class _HomeHeaderViewState extends ConsumerState<HomeHeaderView> {
  // The delivery address shown in the header. Seeded once from the first saved
  // address (see [_seedFromProvider]); afterwards it only ever changes when the
  // delivery-address sheet returns a pick — later provider refreshes leave it
  // untouched.
  String? _displayedAddress;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    // Seed from an already-loaded provider; the not-yet-loaded case is caught by
    // the ref.listen in build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedFromProvider(ref.read(getMyAddressesProvider));
    });
  }

  /// Fills the header once, the first time addresses are available: the first
  /// address's name, or the localized "no address" text when the list is empty.
  void _seedFromProvider(AsyncValue<PaginationModel<AddressModel>> state) {
    if (_seeded || !state.hasValue || !mounted) return;
    _seeded = true;
    final List<AddressModel> addresses = state.valueOrNull?.data ?? const [];
    setState(() {
      _displayedAddress = addresses.isEmpty
          ? LangKeys.noAddressKey.tr()
          : _addressName(addresses.first);
    });
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

    return <String?>[address.street, address.area, address.city]
        .whereType<String>()
        .where((String e) => e.isNotEmpty)
        .join('، ');
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                        Expanded(
                                          child: Text(
                                            _displayedAddress ?? '',
                                            textDirection: TextDirection.ltr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: colors.black,
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
                                                .svg(width: con.maxWidth * 0.04),
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
                          HomeSearchField(),
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
                      child: RepaintBoundary(
                        child: AnimatedSvgPicture.asset(
                          context.isRTL? Assets.media.images.svg.viewAllArabic.path : Assets.media.images.svg.englishAnimatedSeeAll.path,
                          fit: BoxFit.contain,
                          playbackRate: 1,
                          autoPlay: true,
                          placeholderBuilder: (BuildContext context) =>
                              SizedBox.shrink(),
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