import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

class HomeDeliveryAddressView extends ConsumerStatefulWidget {
  const HomeDeliveryAddressView({super.key});

  @override
  ConsumerState<HomeDeliveryAddressView> createState() =>
      _HomeDeliveryAddressViewState();
}

class _HomeDeliveryAddressViewState
    extends ConsumerState<HomeDeliveryAddressView> {
  final ScrollController _scrollController = ScrollController();
  late final GetMyAddressesViewModel _viewModel;

  // Id of the saved address the user tapped in the list. Null means "no explicit
  // choice yet", in which case the selection defaults to the first address (see
  // the derivation in [build]).
  int? _selectedAddressId;

  // Set once the user picks a point on the map directly. While true the list has
  // no highlighted item and the selection is [_mapPickedAddress] — an address
  // reverse-geocoded from the picked point — instead of a saved address.
  bool _pickedOnMap = false;
  AddressModel? _mapPickedAddress;

  // True while a hand-picked point is being reverse-geocoded into an address.
  bool _resolvingPick = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _viewModel = ref.read(getMyAddressesProvider.notifier);
    _viewModel.loadMoreState.addListener(_onLoadMoreStateChanged);
    // Fetch the saved addresses the first time the sheet opens, or retry if a
    // previous open failed (an errored provider has no value); an already-loaded
    // list is reused as-is. Retrying here means an error state becomes loading
    // again, so the list falls back to its shimmer instead of an error view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(getMyAddressesProvider).hasValue) {
        _viewModel.getMyAddresses();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.loadMoreState.removeListener(_onLoadMoreStateChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Pull the next page only once the very end of the sheet is reached, so the
    // load-more shimmer appears exactly when the list tail is fully visible.
    if (_scrollController.position.extentAfter <= 0) {
      _viewModel.loadMore();
    }
  }

  /// Surfaces a load-more failure as a snackbar, so a paging error never
  /// replaces the already-visible list.
  void _onLoadMoreStateChanged() {
    final AsyncValue<bool> loadMoreState = _viewModel.loadMoreState.value;
    if (loadMoreState.hasError && mounted) {
      ErrorSnackBar.show(context, loadMoreState.error.toString());
    }
  }

  /// Parses an address's stored lat/lng strings into a map coordinate, or null
  /// when either is missing or malformed.
  LatLng? _locationOf(AddressModel address) {
    final double? lat = double.tryParse(address.latitude ?? '');
    final double? lng = double.tryParse(address.longitude ?? '');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _onAddressSelected(AddressModel address) {
    setState(() {
      _pickedOnMap = false;
      _selectedAddressId = address.id;
    });
  }

  // A hand-picked point carries only coordinates, so resolve its textual address
  // first (reverse geocoding), store the built address as the current selection,
  // then let the map settle on it. The marker itself already moved to the tapped
  // point inside [AppMap]; only the name resolves in the background here.
  Future<void> _onMapLocationChanged(LatLng location) async {
    setState(() => _resolvingPick = true);

    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );

    if (!mounted) return;

    if (placemark == null) {
      setState(() => _resolvingPick = false);
      ErrorSnackBar.show(context, LangKeys.failedToGetAddress);
      return;
    }

    setState(() {
      _resolvingPick = false;
      _pickedOnMap = true;
      _mapPickedAddress = AddressModel.fromPlacemark(placemark, location);
      _selectedAddressId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<AddressModel>> addressesState = ref.watch(
      getMyAddressesProvider,
    );

    // Resolve the current selection. Unless the user picked a point on the map,
    // the highlighted address is their explicit list choice, defaulting to the
    // first address when none has been tapped yet — so the sheet always opens
    // with the first address selected and shown on the map.
    final List<AddressModel> addresses =
        addressesState.valueOrNull?.data ?? const <AddressModel>[];
    AddressModel? selectedAddress;
    if (_pickedOnMap) {
      selectedAddress = _mapPickedAddress;
    } else {
      for (final AddressModel address in addresses) {
        if (address.id == _selectedAddressId) {
          selectedAddress = address;
          break;
        }
      }
      selectedAddress ??= addresses.isEmpty ? null : addresses.first;
    }

    // The location driving the map marker/camera and the confirm button — the
    // selected address's coordinates (a saved address or the reverse-geocoded
    // map pick).
    final LatLng? selectedLocation = selectedAddress == null
        ? null
        : _locationOf(selectedAddress);

    // Hold the map on its loading placeholder until the first selection is
    // known, so [AppMap] is built with the address location from the start and
    // never resolves (and jumps to) the device location first.
    final bool showMapPlaceholder =
        selectedLocation == null && !addressesState.hasValue;

    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      // The sheet grows with its content up to 85% of the screen; past that the
      // address list scrolls internally while everything else stays pinned.
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
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
                  child: showMapPlaceholder
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: AppMap(
                                currentLocation: selectedLocation,
                                onLocationChanged: _onMapLocationChanged,
                              ),
                            ),
                            // Dim the map with a spinner while a hand-picked point
                            // is being reverse-geocoded into an address.
                            if (_resolvingPick)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: colors.black.withValues(alpha: 0.15),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              // The only scrollable region: the address list. It takes just the
              // space it needs, and scrolls internally once it hits the sheet cap.
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: _AddressList(
                    state: addressesState,
                    loadMoreState: _viewModel.loadMoreState,
                    selectedAddressId: selectedAddress?.id,
                    onSelect: _onAddressSelected,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed(
                  AppRoutes.addNewAddressFromMapScreen,
                  extra: selectedLocation,
                ),
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
              (selectedLocation == null || _resolvingPick)
                  ? PrimaryAppDisabledButton(
                      title: LangKeys.confirmAddressKey.tr(),
                    )
                  : PrimaryAppButton(
                      title: LangKeys.confirmAddressKey.tr(),
                      // Close the sheet and hand the picked address back to the
                      // header. A hand-picked map point has no saved address, so
                      // nothing is returned in that case.
                      onTap: () => context.pop(selectedAddress),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The saved-addresses section of the sheet.
///
/// Mirrors the provider state: a shimmer list while the first page loads (and
/// on error, since the sheet re-fetches on open, turning error back into
/// loading), and the real list once data arrives — appending load-more shimmers
/// while the next page is in flight.
class _AddressList extends StatelessWidget {
  const _AddressList({
    required this.state,
    required this.loadMoreState,
    required this.selectedAddressId,
    required this.onSelect,
  });

  final AsyncValue<PaginationModel<AddressModel>> state;
  final ValueListenable<AsyncValue<bool>> loadMoreState;
  final int? selectedAddressId;
  final ValueChanged<AddressModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const _AddressShimmerList(),
      error: (Object error, StackTrace stackTrace) =>
          const _AddressShimmerList(),
      data: (PaginationModel<AddressModel> page) {
        final List<AddressModel> addresses = page.data;
        return ValueListenableBuilder<AsyncValue<bool>>(
          valueListenable: loadMoreState,
          builder:
              (BuildContext context, AsyncValue<bool> loadMore, Widget? child) {
                final int loadingItemsCount = loadMore.isLoading ? 2 : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: <Widget>[
                    for (final AddressModel address in addresses)
                      _AddressItem(
                        icon: _iconForLabel(address.label),
                        title: context.getLocalizedApiText(address.label),
                        subtitle: address.fullAddress ?? '',
                        highlighted: address.id == selectedAddressId,
                        onTap: () => onSelect(address),
                        onEdit: () => context.pushNamed(
                          AppRoutes.addressDetailsScreen,
                          extra: address,
                        ),
                      ),
                    for (int i = 0; i < loadingItemsCount; i++)
                      const _AddressItemShimmer(),
                  ],
                );
              },
        );
      },
    );
  }
}

/// Picks the address glyph from the stored label, matching the segments used on
/// the address details screen: `Work` → work icon, `Other` → other icon, and
/// anything else (including `Home`) → home icon. Matched on the English label,
/// the same value the details screen round-trips.
SvgGenImage _iconForLabel(Map<String, dynamic>? label) {
  final String key = (label?['en'] ?? '').toString().toLowerCase();
  return switch (key) {
    'work' => Assets.media.images.svg.workSelected,
    'other' => Assets.media.images.svg.otherSelected,
    _ => Assets.media.images.svg.homeSelected,
  };
}

/// First-load placeholder: a short column of [_AddressItemShimmer]s laid out
/// like the real address list.
class _AddressShimmerList extends StatelessWidget {
  const _AddressShimmerList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        _AddressItemShimmer(),
        _AddressItemShimmer(),
        _AddressItemShimmer(),
      ],
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
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style16SemiBold.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Skeleton placeholder mirroring [_AddressItem]'s geometry — the circular icon
/// slot plus the two stacked text lines and the trailing edit slot.
class _AddressItemShimmer extends StatelessWidget {
  const _AddressItemShimmer();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AppShimmer(
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.neutral500.withValues(alpha: 0.1),
          borderRadius: AppBorderRadius.brCircular12,
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.black,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 0.6,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
