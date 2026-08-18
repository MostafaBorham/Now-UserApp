import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';

import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/profile_header.dart';

class AddNewAddressFromMap extends StatefulWidget {
  const AddNewAddressFromMap({super.key, this.currentLocation});

  final LatLng? currentLocation;

  @override
  State<AddNewAddressFromMap> createState() => _AddNewAddressFromMapState();
}

class _AddNewAddressFromMapState extends State<AddNewAddressFromMap> {
  LatLng? _selectedLocation;
  bool _resolvingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.currentLocation;
  }

  // Opens the address search and waits for the address the user picks there.
  // The search pops its result back instead of pushing a second map, so the
  // pin simply moves on the map already on screen.
  Future<void> _onSearchTapped() async {
    final LatLng? picked = await context.pushNamed<LatLng>(
      AppRoutes.addressSearchScreen,
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedLocation = picked;
    });
  }

  // Reverse-geocode the picked point before navigating. Builds an
  // [AddressModel] from the resolved placemark and the picked [LatLng], then
  // continues to the details screen. Only proceeds when a placemark is
  // resolved; otherwise surfaces an error and stays on the map.
  Future<void> _onEnterAddressTapped() async {
    final LatLng? location = _selectedLocation;
    if (location == null) {
      ErrorSnackBar.show(context, LangKeys.failedToGetAddress);
      return;
    }

    setState(() {
      _resolvingAddress = true;
    });

    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );

    if (!mounted) return;

    setState(() {
      _resolvingAddress = false;
    });

    if (placemark == null) {
      ErrorSnackBar.show(context, LangKeys.failedToGetAddress);
      return;
    }

    final AddressModel address = AddressModel.fromPlacemark(placemark, location);

    // Push (not replace) so this map stays underneath: the "Change" action on
    // the details screen pops back to it instead of building a fresh map. On a
    // successful save the details screen pops this map itself, returning to the
    // address list.
    await context.pushNamed<void>(
      AppRoutes.addressDetailsScreen,
      extra: (address: address, fromMap: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LangKeys.addNewAddress.tr(),
          style: AppTextStyles.style24SemiBold.copyWith(
            color: colors.black,
          ),
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
            padding: const EdgeInsets.all(20.0),
            child: AspectRatio(
              aspectRatio: 7,
              child: _selectedLocation!=null? PrimaryAppButton(
                title: LangKeys.enterAddressKey.tr(),
                isLoading: _resolvingAddress,
                onTap: _onEnterAddressTapped,
              ) : PrimaryAppDisabledButton(title: LangKeys.enterAddressKey.tr(),),
            ),
          ),
        ],
      ),
    );
  }
}

