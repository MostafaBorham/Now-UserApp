import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';

// Shared Google Map view used across the app (address map screen, home
// delivery address sheet, …). Resolves the device location when no
// [currentLocation] is given, draws the styled map with a single pin, and
// reports moves back through [onLocationChanged].
//
// The map is fully interactive in every host (it uses an eager gesture
// recognizer so panning works even inside a scrolling sheet), carries its own
// "current location" button that recenters the camera on the device, and sizes
// its pin to the area it is drawn in — larger on a full screen, smaller in a
// compact preview.
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
  // Fraction of the map's shortest visible side used as the pin width, so the
  // marker scales with the area the map is drawn in.
  static const double _markerSizeFactor = 0.2;

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

  // Best-effort device position: current fix first, last known as fallback.
  Future<LatLng?> _fetchDeviceLocation() async {
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

    return resolved;
  }

  Future<void> _resolveDeviceLocation() async {
    final resolved = await _fetchDeviceLocation();

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

  // Recenter on the device. Always resolves a fresh, exact fix and animates the
  // camera to it — the camera can be panned without touching [_target], so we
  // never short-circuit on a stale comparison.
  Future<void> _onCurrentLocationTapped() async {
    final device = await _fetchDeviceLocation();
    if (!mounted || device == null) return;

    setState(() {
      _target = device;
    });
    widget.onLocationChanged?.call(device);
    _animateToTarget();
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

  // Load the styling JSON from application assets
  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString(Assets.json.map);
    if (!mounted) return;
    setState(() {
      _mapStyle = style;
    });
  }

  // Rasterize the pin once we know how wide the map is drawn.
  void _ensureMarkerLoaded(double width) {
    if (_markerIcon != null || _loadingMarker || width <= 0) return;
    _loadingMarker = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMarkerIcon(width));
  }

  Future<void> _loadMarkerIcon(double width) async {
    final icon = await _bitmapDescriptorFromSvg(
      Assets.media.images.svg.mapMarkerIcon.path,
      width: width,
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
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Size the pin to the drawn area: full-screen maps get a larger marker,
        // compact previews a smaller one.
        _ensureMarkerLoaded(
          constraints.biggest.shortestSide * _markerSizeFactor,
        );

        // Wait for both the deferred platform-view build and the resolved
        // location, so the first frame of the map is already on the right spot.
        if (!_mapReady || !_locationResolved) {
          return const Center(child: CircularProgressIndicator());
        }

        final LatLng markerPosition = _target ?? _fallbackTarget;
        return Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                style: _mapStyle,
                zoomControlsEnabled: false,
                // Win drag gestures eagerly so the map pans even when it lives
                // inside a scrolling parent (e.g. the home address sheet).
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                },
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
                  // No camera move here: [initialCameraPosition] is already the
                  // final target, since the map is not built before the
                  // location is resolved.
                  _mapController = controller;
                },
                onTap: _onMapTapped,
              ),
            ),
            PositionedDirectional(
              bottom: 12,
              end: 12,
              child: GestureDetector(
                onTap: _onCurrentLocationTapped,
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 8,
                    end: 10,
                    top: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.white,
                    borderRadius: AppBorderRadius.brCircular30,
                    boxShadow: [
                      BoxShadow(
                        color: colors.black.withValues(alpha: 0.08),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Assets.media.images.svg.currentLocationIcon.svg(
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colors.tertiaryContainer,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        LangKeys.currentLocationKey.tr(),
                        style: AppTextStyles.style12SemiBold.copyWith(
                          color: colors.tertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
