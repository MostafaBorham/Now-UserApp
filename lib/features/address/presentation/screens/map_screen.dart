import 'dart:ui' as ui;

// `show Either`: dartz also exports a `State` monad, which would shadow
// Flutter's `State` and break every widget in this file.
import 'package:dartz/dartz.dart' show Either;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/arrow_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';

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
      ErrorSnackBar.show(context, LangKeys.failedToGetAddress);
      return;
    }

    final Either<Failure, AddressModel> result = await ref
        .read(resolveMapAddressProvider.notifier)
        .resolve(location);

    if (!mounted) return;

    result.fold(
      (Failure failure) => ErrorSnackBar.show(context, failure.message),
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
              child: _selectedLocation != null
                  ? PrimaryAppButton(
                      title: confirmLabel,
                      isLoading: isResolvingAddress,
                      onTap: _onEnterAddressTapped,
                    )
                  : PrimaryAppDisabledButton(title: confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class AppMap extends StatefulWidget {
  const AppMap({super.key, this.currentLocation, this.onLocationChanged});

  final LatLng? currentLocation;
  final ValueChanged<LatLng>? onLocationChanged;

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  /// Shown only when the device location cannot be resolved at all. Central
  /// Riyadh — the delivery market — so the pin never starts outside it.
  static const LatLng _fallbackTarget = LatLng(24.713552, 46.675297);
  static const double _targetZoom = 16;

  GoogleMapController? _mapController;
  String? _mapStyle;
  BitmapDescriptor? _markerIcon;
  bool _loadingMarker = false;
  LatLng? _target;
  bool _mapReady = false;
  bool _locationResolved = false;

  @override
  void initState() {
    super.initState();
    _target = widget.currentLocation;
    _loadMapStyle();
    // The map is only built once the camera target is final, so it never
    // loads on one location and then jumps to another.
    if (_target != null) {
      _locationResolved = true;
    } else {
      _resolveDeviceLocation();
    }
    // Defer building the GoogleMap platform view until after the push
    // transition finishes, so navigation feels instant and the heavy native
    // view creation happens while the placeholder is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _mapReady = true;
      });
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _resolveDeviceLocation() async {
    LatLng? resolved;

    final granted = await LocationManager.requestPermissions();

    if (mounted && granted) {
      try {
        final current = await Geolocator.getCurrentPosition();
        resolved = LatLng(current.latitude, current.longitude);
      } catch (_) {
        // Service off, timeout, etc. — try last known below.
      }
    }

    if (mounted && resolved == null) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          resolved = LatLng(last.latitude, last.longitude);
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _target = resolved;
      _locationResolved = true;
    });

    if (resolved != null) {
      widget.onLocationChanged?.call(resolved);
    }
  }

  void _animateToTarget() {
    final controller = _mapController;
    final target = _target;
    if (controller == null || target == null) return;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, _targetZoom));
  }

  @override
  void didUpdateWidget(covariant AppMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent can move the pin from outside — an address picked in the
    // search screen. Ignore the echo of our own onTap updates, which come back
    // down already equal to [_target].
    final LatLng? incoming = widget.currentLocation;
    if (incoming == null ||
        incoming == oldWidget.currentLocation ||
        incoming == _target) {
      return;
    }

    setState(() {
      _target = incoming;
    });
    _animateToTarget();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is valid here (not in initState); load the marker once.
    if (_markerIcon == null && !_loadingMarker) {
      _loadingMarker = true;
      _loadMarkerIcon();
    }
  }

  // Load the styling JSON from application assets
  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString(Assets.json.map);
    if (!mounted) return;
    setState(() {
      _mapStyle = style;
    });
  }

  // Rasterize the SVG marker into a BitmapDescriptor that Google Maps can draw.
  Future<void> _loadMarkerIcon() async {
    final icon = await _bitmapDescriptorFromSvg(
      Assets.media.images.svg.mapMarkerIcon.path,
      width: MediaQuery.sizeOf(context).width * 0.2,
    );
    if (!mounted) return;
    setState(() {
      _markerIcon = icon;
    });
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvg(
    String assetName, {
    required double width,
  }) async {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetName), null);
    final logicalSize = pictureInfo.size;

    final targetWidth = width * devicePixelRatio;
    final scale = targetWidth / logicalSize.width;
    final targetHeight = logicalSize.height * scale;

    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..scale(scale)
      ..drawPicture(pictureInfo.picture);
    final scaledPicture = recorder.endRecording();

    final image = await scaledPicture.toImage(
      targetWidth.round(),
      targetHeight.round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    pictureInfo.picture.dispose();
    scaledPicture.dispose();
    image.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: width,
      height: targetHeight / devicePixelRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wait for both the deferred platform-view build and the resolved
    // location, so the first frame of the map is already on the right spot.
    if (!_mapReady || !_locationResolved) {
      return const Center(child: CircularProgressIndicator());
    }
    final LatLng markerPosition = _target ?? _fallbackTarget;
    return GoogleMap(
      style: _mapStyle,
      zoomControlsEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _target ?? _fallbackTarget,
        zoom: _target != null ? _targetZoom : 10,
      ),
      markers: {
        if (_markerIcon != null)
          Marker(
            markerId: const MarkerId('selected-location'),
            position: markerPosition,
            icon: _markerIcon!,
          ),
      },
      onMapCreated: (GoogleMapController controller) {
        // No camera move here: [initialCameraPosition] is already the final
        // target, since the map is not built before the location is resolved.
        _mapController = controller;
      },
      onTap: _onMapTapped,
    );
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _target = position;
    });
    widget.onLocationChanged?.call(position);
    _animateToTarget();
  }
}
