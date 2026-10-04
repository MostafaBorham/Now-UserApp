import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/utils/di/map_resources.dart';
import 'package:nowdelivery_user_app/core/utils/di/service_locator.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';

class AppMap extends StatefulWidget {
  const AppMap({
    super.key,
    this.currentLocation,
    this.onLocationChanged,
    this.resolveDeviceLocationWhenEmpty = true,
  });

  final LatLng? currentLocation;
  final ValueChanged<LatLng>? onLocationChanged;

  /// Whether the map resolves (and so prompts for) the device location on its
  /// own when [currentLocation] is null. `true` for the add-address flow, which
  /// should open on the device's position. `false` where a prompt on open is
  /// unwanted (the home delivery-address sheet): the map then opens on its
  /// fallback target and only reaches for the device when the current-location
  /// button is tapped.
  final bool resolveDeviceLocationWhenEmpty;

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> with WidgetsBindingObserver {
  static const LatLng _fallbackTarget = LatLng(30.115508, 31.403403);
  static const double _targetZoom = 16;
  // Fraction of the map's shortest visible side used as the pin width, so the
  // marker scales with the area the map is drawn in.
  static const double _markerSizeFactor = 0.2;

  // Immutable map resources, resolved from the service locator and preloaded
  // during bootstrap — never re-read or re-parsed per screen.
  final MapResources _mapResources = getIt<MapResources>();

  GoogleMapController? _mapController;
  BitmapDescriptor? _markerIcon;
  bool _loadingMarker = false;
  // The selected point drives only the marker, so it lives in a notifier: a
  // tap, a recenter, or an external pin move rebuilds just the map layer via
  // its [ValueListenableBuilder], never the surrounding button or the
  // one-time asset-loading scaffolding.
  final ValueNotifier<LatLng?> _target = ValueNotifier<LatLng?>(null);
  // Flipped by the real [GoogleMap.onMapCreated] callback — the map surface is
  // built and ready — instead of a fixed delay. Until then a spinner overlays
  // the (already-building) map.
  bool _mapCreated = false;
  bool _locationResolved = false;
  bool _awaitingPermissionFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _target.value = widget.currentLocation;
    if (_target.value != null) {
      _locationResolved = true;
    } else if (widget.resolveDeviceLocationWhenEmpty) {
      _resolveDeviceLocation();
    } else {
      // No location to open on and device resolution is opted out: reveal the
      // map on its fallback target with no permission/service prompt.
      _locationResolved = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _target.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !_awaitingPermissionFromSettings) {
      return;
    }
    _awaitingPermissionFromSettings = false;
    _resolveAfterSettingsReturn();
  }

  Future<void> _resolveAfterSettingsReturn() async {
    final LocationPermissionStatus status =
        await LocationManager.currentPermissionStatus();
    if (!mounted || status != LocationPermissionStatus.granted) return;
    await _moveToDeviceLocation();
  }

  Future<void> _resolveDeviceLocation() async {
    final resolved = await LocationManager.getCurrentLatLng();

    if (!mounted) return;

    _target.value = resolved;
    // Only the gate flips here; the target itself is a notifier, so this
    // rebuild is the one that first reveals the map, not a per-move churn.
    setState(() {
      _locationResolved = true;
    });

    if (resolved != null) {
      widget.onLocationChanged?.call(resolved);
    }
  }

  void _animateToTarget() {
    final controller = _mapController;
    final target = _target.value;
    if (controller == null || target == null) return;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, _targetZoom));
  }

  // Recenter on the device. This is the one entry point that may surface the OS
  // location dialogs: it first asks to switch the location service on in place
  // (native prompt), then resolves a fresh fix — which requests the permission —
  // and animates the camera to it. The camera can be panned without touching
  // [_target], so we never short-circuit on a stale comparison.
  Future<void> _onCurrentLocationTapped() async {
    final bool serviceEnabled = await LocationManager.requestService();
    if (!mounted || !serviceEnabled) return;

    final LocationPermissionStatus status =
        await LocationManager.requestPermissionStatus();
    if (!mounted) return;

    if (status == LocationPermissionStatus.deniedForever) {
      final bool opened = await LocationManager.openAppSettings();
      if (!mounted) return;
      _awaitingPermissionFromSettings = opened;
      return;
    }

    if (status != LocationPermissionStatus.granted) return;

    await _moveToDeviceLocation();
  }

  Future<void> _moveToDeviceLocation() async {
    final device = await LocationManager.getCurrentLatLng();
    if (!mounted || device == null) return;

    _target.value = device;
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
        incoming == _target.value) {
      return;
    }

    _target.value = incoming;
    _animateToTarget();
  }

  // Rasterize the pin once we know how wide the map is drawn. The parsed SVG is
  // shared through the injected [MapResources]; only the size-specific bitmap is
  // produced here, and it too is cached per size for later opens.
  void _ensureMarkerLoaded(double width) {
    if (_markerIcon != null || _loadingMarker || width <= 0) return;
    _loadingMarker = true;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadMarkerIcon(width, devicePixelRatio),
    );
  }

  Future<void> _loadMarkerIcon(double width, double devicePixelRatio) async {
    final icon = await _mapResources.markerIcon(
      width: width,
      devicePixelRatio: devicePixelRatio,
    );
    if (!mounted) return;
    setState(() {
      _markerIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        _ensureMarkerLoaded(
          constraints.biggest.shortestSide * _markerSizeFactor,
        );

        // Only the location gates the bare spinner: without a resolved target
        // there is no [initialCameraPosition] to build the map with. Once it is
        // known the map is built immediately, and the "map creating" spinner is
        // an overlay driven by [onMapCreated] — no fixed delay.
        if (!_locationResolved) {
          return const Center(child: CircularProgressIndicator());
        }

        // Snapshot the camera's starting point once. [initialCameraPosition] is
        // only honored on first build, so later target changes are driven
        // imperatively through [_animateToTarget], not by rebuilding with a new
        // value here.
        final LatLng initialTarget = _target.value ?? _fallbackTarget;
        final CameraPosition initialCameraPosition = CameraPosition(
          target: initialTarget,
          zoom: _target.value != null ? _targetZoom : 10,
        );

        return Stack(
          children: [
            // Isolate the map's repaints from the surrounding sheet/scroll view.
            Positioned.fill(
              child: RepaintBoundary(
                // Only the marker depends on the moving target, so only this
                // builder reruns on a tap/recenter — the current-location
                // button and the rest of the tree stay put.
                child: ValueListenableBuilder<LatLng?>(
                  valueListenable: _target,
                  builder: (context, target, _) {
                    return GoogleMap(
                      style: _mapResources.mapStyle,
                      zoomControlsEnabled: false,
                      // Win drag gestures eagerly so the map pans even when it
                      // lives inside a scrolling parent (e.g. the home address
                      // sheet).
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              EagerGestureRecognizer.new,
                            ),
                          },
                      initialCameraPosition: initialCameraPosition,
                      // No pin until there is a real point: the camera may open
                      // on the fallback, but a pin there read as the user's
                      // location.
                      markers: {
                        if (_markerIcon != null && target != null)
                          Marker(
                            markerId: const MarkerId('selected-location'),
                            position: target,
                            icon: _markerIcon!,
                          ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        // No camera move here: [initialCameraPosition] is
                        // already the final target, since the map is not built
                        // before the location is resolved.
                        _mapController = controller;
                        // The real "map is ready" signal — reveal it now,
                        // dropping the overlay spinner.
                        if (!_mapCreated) {
                          setState(() {
                            _mapCreated = true;
                          });
                        }
                      },
                      onTap: _onMapTapped,
                    );
                  },
                ),
              ),
            ),
            // Covers the map while the platform view is being created; removed
            // the instant [onMapCreated] fires, so there is no arbitrary wait.
            if (!_mapCreated)
              Positioned.fill(
                child: ColoredBox(
                  color: colors.white,
                  child: const Center(child: CircularProgressIndicator()),
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
    _target.value = position;
    widget.onLocationChanged?.call(position);
    _animateToTarget();
  }
}
