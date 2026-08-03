import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/core/utils/location_permission_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/add_address_button.dart';
import 'package:nowdelivery_user_app/features/settings/components/profile_header.dart';

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
      extra: _selectedLocation,
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

    final String area = [
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' - ');

    final AddressModel address = AddressModel(
      country: placemark.country,
      city: placemark.locality,
      area: area.isEmpty ? placemark.name : area,
      street: placemark.street,
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
    );

    context.pushReplacementNamed(
      AppRoutes.addressDetailsScreen,
      extra: address,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LangKeys.addNewAddress.tr(),
          style: AppTextStyles.style24SemiBold.copyWith(
            color: colors.onSecondary,
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
      body: AppMap(
        // The selected point, not the constructor argument, so a location
        // picked in the search screen moves the pin.
        currentLocation: _selectedLocation,
        onLocationChanged: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
      persistentFooterDecoration: BoxDecoration(color: colors.onPrimary),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        PrimaryAppButton(
          title: LangKeys.enterAddressKey.tr(),
          isLoading: _resolvingAddress,
          onTap: _onEnterAddressTapped,
        ),
      ],
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
  static const LatLng _fallbackTarget = LatLng(30.115508, 31.403403);
  static const double _targetZoom = 16;

  GoogleMapController? _mapController;
  String? _mapStyle;
  BitmapDescriptor? _markerIcon;
  bool _loadingMarker = false;
  LatLng? _target;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _target = widget.currentLocation;
    _loadMapStyle();
    if (_target == null) {
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

  // Falls back through: getCurrentPosition -> getLastKnownPosition.
  // getLastKnownPosition can still return a fix even when the location
  // service is currently disabled, so it is the safety net.
  Future<void> _resolveDeviceLocation() async {
    final granted = await LocationPermissionService.request();
    if (!mounted) return;

    LatLng? resolved;

    if (granted) {
      try {
        final current = await Geolocator.getCurrentPosition();
        resolved = LatLng(current.latitude, current.longitude);
      } catch (_) {
        // Service off, timeout, etc. — try last known below.
      }
    }

    if (!mounted) return;

    if (resolved == null) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          resolved = LatLng(last.latitude, last.longitude);
        }
      } catch (_) {}
    }

    if (!mounted || resolved == null) return;
    setState(() {
      _target = resolved;
    });
    widget.onLocationChanged?.call(resolved);
    _animateToTarget();
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
    if (!_mapReady) {
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
        _mapController = controller;
        // If widget.currentLocation was provided, initialCameraPosition
        // already frames it; this animate is a no-op in that case but
        // guarantees the camera lands on any location resolved after the
        // map was built.
        _animateToTarget();
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
