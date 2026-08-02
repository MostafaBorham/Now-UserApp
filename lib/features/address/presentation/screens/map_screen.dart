import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/location_permission_service.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.currentLocation;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.addNewAddress.tr(),style: AppTextStyles.style24SemiBold.copyWith(
          color: colors.onSecondary
        ),),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: ReverseWidget(child: ArrowBackButton(onTap: () => context.pop())),
        actions: [Assets.media.images.svg.search.svg()],
      ),
      body: AppMap(
        currentLocation: widget.currentLocation,
        onLocationChanged: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
      persistentFooterDecoration: BoxDecoration(
        color: colors.onPrimary
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [PrimaryAppButton(
        title: LangKeys.enterAddressKey.tr(),
        onTap: () => context.pushNamed(
          AppRoutes.addressDetailsScreen,
          extra: _selectedLocation,
        ),
      )],
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
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, _targetZoom),
    );
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
      width: MediaQuery.sizeOf(context).width*0.2,
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