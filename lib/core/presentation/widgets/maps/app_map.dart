import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';

// Shared Google Map view used across the app (address map screen, home
// delivery address sheet, …). Resolves the device location when no
// [currentLocation] is given, draws the styled map with a single pin, and
// reports moves back through [onLocationChanged]. Set [interactive] to false
// to render a compact, tap-locked preview (e.g. inside a bottom sheet).
class AppMap extends StatefulWidget {
  const AppMap({
    super.key,
    this.currentLocation,
    this.onLocationChanged,
    this.interactive = true,
  });

  final LatLng? currentLocation;
  final ValueChanged<LatLng>? onLocationChanged;
  final bool interactive;

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
      // In non-interactive previews, lock gestures so the sheet scrolls
      // instead of the map panning under the finger.
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      rotateGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
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
      onTap: widget.interactive ? _onMapTapped : null,
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
