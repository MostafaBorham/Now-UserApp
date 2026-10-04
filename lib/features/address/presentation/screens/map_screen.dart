// `show Either`: dartz also exports a `State` monad, which would shadow
// Flutter's `State` and break every widget in this file.
import 'package:dartz/dartz.dart' show Either;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/arrow_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/resolve_map_address_vm.dart';

class AddNewAddressFromMap extends ConsumerStatefulWidget {
  const AddNewAddressFromMap({super.key, this.address});

  /// The address whose location is being changed, when the map was opened from
  /// the details screen's "Change" action. Null when adding a new address —
  /// which is what switches this screen between its two titles and its pin
  /// between the stored location and the device's.
  final AddressModel? address;

  @override
  ConsumerState<AddNewAddressFromMap> createState() =>
      _AddNewAddressFromMapState();
}

class _AddNewAddressFromMapState extends ConsumerState<AddNewAddressFromMap> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Start on the address being changed, so the map opens on the pin the user
    // came to move rather than resolving the device location again.
    final double? lat = double.tryParse(widget.address?.latitude ?? '');
    final double? lng = double.tryParse(widget.address?.longitude ?? '');
    if (lat != null && lng != null) {
      _selectedLocation = LatLng(lat, lng);
    }
  }

  // Opens the address search and waits for the address the user picks there.
  // The search pops its result back instead of pushing a second map, so the
  // pin simply moves on the map already on screen.
  Future<void> _onSearchTapped() async {
    final LatLng? picked = await context.pushNamed<LatLng>(
      AppRoutes.addressSearchScreen,
      // The live pin, so Places ranks addresses near what the map is showing.
      extra: (
        bias: _selectedLocation,
        isChangingAddress: widget.address != null,
      ),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedLocation = picked;
    });
  }

  // Resolve the picked point into an address before navigating, and continue
  // to the details screen with it. Only proceeds when the point resolves;
  // otherwise surfaces an error and stays on the map.
  Future<void> _onEnterAddressTapped() async {
    final LatLng? location = _selectedLocation;
    if (location == null) {
      AppToast.showError(context, LangKeys.failedToGetAddress);
      return;
    }

    final Either<Failure, AddressModel> result = await ref
        .read(resolveMapAddressProvider.notifier)
        .resolve(location);

    if (!mounted) return;

    result.fold(
      (Failure failure) => AppToast.showError(context, failure.message),
      // Push (not replace) so this map stays underneath: the "Change" action on
      // the details screen pops back to it instead of building a fresh map. On
      // a successful save the details screen pops this map itself, returning to
      // the address list.
      (AddressModel resolved) => context.pushNamed<void>(
        AppRoutes.addressDetailsScreen,
        extra: (
          address: _merge(resolved),
          fromMap: true,
          isEdit: widget.address != null,
        ),
      ),
    );
  }

  /// The address to hand to the details screen: the freshly geocoded one when
  /// adding, or the address being changed carrying the new location when the
  /// map was opened from its "Change" action.
  ///
  /// Built on top of [resolved] rather than the other way round so every
  /// location field is the new one — the geocoder leaves fields it cannot fill
  /// null, and `copyWith` would keep the stale value for those.
  AddressModel _merge(AddressModel resolved) {
    final AddressModel? editing = widget.address;
    if (editing == null) return resolved;

    return resolved.copyWith(
      id: editing.id,
      userId: editing.userId,
      label: editing.label,
      phone: editing.phone,
      buildingNumber: editing.buildingNumber,
      floor: editing.floor,
      apartment: editing.apartment,
      notes: editing.notes,
      isDefault: editing.isDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isResolvingAddress = ref
        .watch(resolveMapAddressProvider)
        .isLoading;
    final bool isChangingAddress = widget.address != null;
    final String confirmLabel = isChangingAddress
        ? LangKeys.changeAddress.tr()
        : LangKeys.enterAddressKey.tr();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isChangingAddress
              ? LangKeys.changeAddress.tr()
              : LangKeys.addNewAddress.tr(),
          style: AppTextStyles.style24SemiBold.copyWith(color: colors.black),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: ReverseWidget(
          child: ArrowBackButton(onTap: () => context.pop()),
        ),
        actions: [
          IconButton(
            onPressed: _onSearchTapped,
            icon: Assets.media.images.svg.search.svg(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AppMap(
              // The selected point, not the constructor argument, so a location
              // picked in the search screen moves the pin.
              currentLocation: _selectedLocation,
              onLocationChanged: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
            ),
          ),
          Padding(
            // Clears the system navigation bar: on Android 15+ the app draws
            // edge-to-edge, and a 3-button bar covered the button.
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: AspectRatio(
              aspectRatio: 7,
              child: PrimaryAppButton(
                title: confirmLabel,
                buttonPadding: 8,
                titleStyle: AppTextStyles.style20SemiBold,
                isLoading: isResolvingAddress,
                isDisabled: _selectedLocation == null,
                onTap: _onEnterAddressTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
