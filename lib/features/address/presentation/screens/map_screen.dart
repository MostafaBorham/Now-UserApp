import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/add_address_button.dart';
import 'package:nowdelivery_user_app/features/settings/components/profile_header.dart';

class AddNewAddressFromMap extends StatelessWidget {
  const AddNewAddressFromMap({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(LangKeys.addNewAddress.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: ArrowBackButton(onTap: () => context.pop()),
        actions: [Assets.media.images.svg.search.svg()],
      ),
      body: AppMap(),
      persistentFooterDecoration: BoxDecoration(
        color: colors.onPrimary
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [PrimaryAppButton(title: 'Enter address',onTap: () {

      },)],
    );
  }
}

class AppMap extends StatefulWidget {
  const AppMap({super.key});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  static const LatLng _initialTarget = LatLng(30.115508, 31.403403);

  late GoogleMapController _mapController;
  String? _mapStyle;
  BitmapDescriptor? _markerIcon;
  bool _loadingMarker = false;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
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
      width: MediaQuery.sizeOf(context).width*0.1,
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
    return GoogleMap(
      style: _mapStyle,
      zoomControlsEnabled: false,
      initialCameraPosition: const CameraPosition(target: _initialTarget),
      markers: {
        if (_markerIcon != null)
          Marker(
            markerId: const MarkerId('selected-location'),
            position: _initialTarget,
            icon: _markerIcon!,
          ),
      },
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
    );
  }
}