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
  const AppMap({super.key, this.currentLocation, this.onLocationChanged});

  final LatLng? currentLocation;
  final ValueChanged<LatLng>? onLocationChanged;

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  static const LatLng _fallbackTarget = LatLng(30.115508, 31.403403);
  static const double _targetZoom = 16;


  static const double _markerSizeFactor = 0.2;



  final MapResources _mapResources = getIt<MapResources>();

  GoogleMapController? _mapController;
  BitmapDescriptor? _markerIcon;
  bool _loadingMarker = false;




  final ValueNotifier<LatLng?> _target = ValueNotifier<LatLng?>(null);



  bool _mapCreated = false;
  bool _locationResolved = false;

  @override
  void initState() {
    super.initState();
    _target.value = widget.currentLocation;
    if (_target.value != null) {
      _locationResolved = true;
    } else {
      _resolveDeviceLocation();
    }
  }

  @override
  void dispose() {
    _target.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _resolveDeviceLocation() async {
    final resolved = await LocationManager.getCurrentLatLng();

    if (!mounted) return;

    _target.value = resolved;


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




  Future<void> _onCurrentLocationTapped() async {
    final device = await LocationManager.getCurrentLatLng();
    if (!mounted || device == null) return;

    _target.value = device;
    widget.onLocationChanged?.call(device);
    _animateToTarget();
  }

  @override
  void didUpdateWidget(covariant AppMap oldWidget) {
    super.didUpdateWidget(oldWidget);



    final LatLng? incoming = widget.currentLocation;
    if (incoming == null ||
        incoming == oldWidget.currentLocation ||
        incoming == _target.value) {
      return;
    }

    _target.value = incoming;
    _animateToTarget();
  }




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





        if (!_locationResolved) {
          return const Center(child: CircularProgressIndicator());
        }





        final LatLng initialTarget = _target.value ?? _fallbackTarget;
        final CameraPosition initialCameraPosition = CameraPosition(
          target: initialTarget,
          zoom: _target.value != null ? _targetZoom : 10,
        );

        return Stack(
          children: [

            Positioned.fill(
              child: RepaintBoundary(



                child: ValueListenableBuilder<LatLng?>(
                  valueListenable: _target,
                  builder: (context, target, _) {
                    return GoogleMap(
                      style: _mapResources.mapStyle,
                      zoomControlsEnabled: false,



                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              EagerGestureRecognizer.new,
                            ),
                          },
                      initialCameraPosition: initialCameraPosition,
                      markers: {
                        if (_markerIcon != null)
                          Marker(
                            markerId: const MarkerId('selected-location'),
                            position: target ?? _fallbackTarget,
                            icon: _markerIcon!,
                          ),
                      },
                      onMapCreated: (GoogleMapController controller) {



                        _mapController = controller;


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
