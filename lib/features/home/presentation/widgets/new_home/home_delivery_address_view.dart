import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/home_address_provider.dart';
import 'package:nowdelivery_user_app/features/address/presentation/utils/address_line.dart';

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

  // The point being resolved, held so the map keeps its pin there while the
  // lookup runs. Cleared when it settles: on success the point becomes the
  // selection, on failure the map is handed the previous selection back — so
  // the pin can never be left on a spot that is not the highlighted address.
  LatLng? _pendingPick;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _viewModel = ref.read(getMyAddressesProvider.notifier);
    // Guests have no saved-addresses list (their addresses provider is never
    // filled — see AuthSessionViewModel), so the fetch is only kicked off for a
    // logged-in user. Fetches the first time the sheet opens, or retries if a
    // previous open failed (an errored provider has no value); an already-loaded
    // list is reused as-is. Retrying here means an error state becomes loading
    // again, so the list falls back to its shimmer instead of an error view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isUser =
          ref.read(authSessionProvider).sessionType == SessionType.user;
      if (isUser && !ref.read(getMyAddressesProvider).hasValue) {
        _viewModel.loadFirstPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Pull the next page only once the very end of the sheet is reached, so the
    // load-more shimmer appears exactly when the list tail is fully visible.
    if (_scrollController.position.extentAfter <= 0) {
      _viewModel.loadNextPage();
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
    setState(() {
      _resolvingPick = true;
      _pendingPick = location;
    });

    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );

    if (!mounted) return;

    if (placemark == null) {
      // The selection did not change, so the pin goes back to it. It used to
      // stay on the tapped point while the list still highlighted the old
      // address — and picking that address again did nothing, because the map
      // only moves when the location it is handed changes.
      setState(() {
        _resolvingPick = false;
        _pendingPick = null;
      });
      AppToast.showError(context, LangKeys.failedToGetAddress);
      return;
    }

    setState(() {
      _resolvingPick = false;
      _pendingPick = null;
      _pickedOnMap = true;
      _mapPickedAddress = AddressModel.fromPlacemark(placemark, location);
      _selectedAddressId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // A guest never has a saved-addresses list: the provider stays perpetually
    // loading (nothing fills it), so its list and the map's provider-gated
    // placeholder are both suppressed for guests, and the add-address button
    // bounces them to phone verification instead.
    final bool isUser =
        ref.watch(authSessionProvider.select((s) => s.sessionType)) ==
        SessionType.user;
    final AsyncValue<PaginationModel<AddressModel>> addressesState = ref.watch(
      getMyAddressesProvider,
    );

    // Surface a load-more failure as a snackbar, so a paging error never
    // replaces the already-visible list.
    ref.listen<AsyncValue<PaginationModel<AddressModel>>>(
      getMyAddressesProvider,
      (
        AsyncValue<PaginationModel<AddressModel>>? previous,
        AsyncValue<PaginationModel<AddressModel>> next,
      ) {
        final String? nextPageError = PaginationStatus<AddressModel>.from(
          next,
        ).nextPageError;
        if (nextPageError != null) {
          AppToast.showError(context, nextPageError);
        }
      },
    );

    // Resolve the current selection. Unless the user picked a point on the map
    // or tapped a saved address, the sheet opens on the address currently shown
    // on the home page ([homeAddressProvider]) — the user's default saved
    // address until they confirm another, else the current location — so it is
    // highlighted in the list with the map pin on it from the first frame.
    final AddressModel? homeAddress = ref.watch(homeAddressProvider);
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
      selectedAddress ??= homeAddress;
    }

    // The location driving the map marker/camera and the confirm button — the
    // selected address's coordinates (a saved address or the reverse-geocoded
    // map pick).
    final LatLng? selectedLocation = selectedAddress == null
        ? null
        : _locationOf(selectedAddress);

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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AppMap(
                          currentLocation: _pendingPick ?? selectedLocation,
                          onLocationChanged: _onMapLocationChanged,
                          // Opening the sheet must never prompt for the location:
                          // it shows the home address (or the fallback), and only
                          // the current-location button reaches for the device.
                          resolveDeviceLocationWhenEmpty: false,
                        ),
                      ),
                      // Dim the map with a spinner while a hand-picked point is
                      // being reverse-geocoded into an address.
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
              // space it needs, and scrolls internally once it hits the sheet
              // cap. Shown only for a logged-in user — a guest has no saved
              // addresses, so its slot is simply left out.
              if (isUser)
                Flexible(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: _AddressList(
                      state: addressesState,
                      selectedAddressId: selectedAddress?.id,
                      onSelect: _onAddressSelected,
                    ),
                  ),
                ),
              GestureDetector(
                // A guest can't own addresses, so adding one first requires an
                // account: bounce to phone verification. A user goes straight to
                // the add-address flow.
                onTap: () {
                  if (redirectGuestToLogin(context)) return;
                  context.pushNamed(AppRoutes.addNewAddressFromMapScreen);
                },
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
                isDisabled: selectedLocation == null || _resolvingPick,
                // Make this the address the home page shows, then close the
                // sheet. The header watches [homeAddressProvider], so the
                // pick surfaces there without passing it back through pop.
                onTap: () {
                  final AddressModel confirmed = selectedAddress!;
                  ref.read(homeAddressProvider.notifier).state = confirmed;
                  unawaited(
                    CurrentLocationCacheService().saveCurrentLocation(
                      confirmed,
                    ),
                  );
                  context.pop();
                },
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
    required this.selectedAddressId,
    required this.onSelect,
  });

  final AsyncValue<PaginationModel<AddressModel>> state;
  final int? selectedAddressId;
  final ValueChanged<AddressModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final PaginationStatus<AddressModel> status =
        PaginationStatus<AddressModel>.from(state);

    // Nothing on screen yet: a first page in flight or a failed first page both
    // fall back to the shimmer, so an error never shows a bare empty sheet.
    if (!status.hasLoadedPage) return const _AddressShimmerList();

    final int loadingItemsCount = status.isNextPageLoading ? 2 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        for (final AddressModel address in status.items)
          _AddressItem(
            icon: _iconForLabel(address.label),
            title: context.getLocalizedApiText(address.label),
            subtitle: addressLine(context, address),
            highlighted: address.id == selectedAddressId,
            onTap: () => onSelect(address),
            onEdit: () => context.pushNamed(
              AppRoutes.addressDetailsScreen,
              extra: address,
            ),
          ),
        for (int i = 0; i < loadingItemsCount; i++) const _AddressItemShimmer(),
      ],
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
