import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Holds the map's immutable resources — the style JSON and the parsed pin
/// vector — for the whole app lifetime.
///
/// Registered as a single instance in the service locator (see
/// `service_locator.dart`) and [preload]ed during bootstrap, before `runApp`,
/// so every [AppMap] pulls these from memory instead of re-reading the asset or
/// re-parsing the marker SVG on each open.
class MapResources {
  String? _mapStyle;
  PictureInfo? _markerPicture;

  // The marker bitmap depends on the pixel size it is rasterized at, which
  // differs per call site (a full-screen map vs. the small home preview). The
  // vector is parsed once; one bitmap is cached per distinct pixel size.
  final Map<int, Future<BitmapDescriptor>> _markerIcons =
      <int, Future<BitmapDescriptor>>{};

  /// Loads the size-independent resources. Awaited once in `main` so the style
  /// JSON is read and the marker SVG parsed before the first frame; only the
  /// final size-specific rasterization is left for the map to trigger.
  Future<void> preload() async {
    _mapStyle = await rootBundle.loadString(Assets.json.map);
    _markerPicture = await vg.loadPicture(
      SvgAssetLoader(Assets.media.images.svg.mapMarkerIcon.path),
      null,
    );
  }

  /// The map styling JSON, ready in memory after [preload].
  String get mapStyle => _mapStyle!;

  /// A pin [BitmapDescriptor] rasterized to [width] logical pixels for the
  /// given [devicePixelRatio]. Cached per physical-pixel size, so repeatedly
  /// opening the same map screen reuses the same bitmap.
  Future<BitmapDescriptor> markerIcon({
    required double width,
    required double devicePixelRatio,
  }) {
    final int key = (width * devicePixelRatio).round();
    return _markerIcons[key] ??= _rasterizeMarker(
      width: width,
      devicePixelRatio: devicePixelRatio,
    );
  }

  Future<BitmapDescriptor> _rasterizeMarker({
    required double width,
    required double devicePixelRatio,
  }) async {
    final PictureInfo pictureInfo = _markerPicture!;
    final ui.Size logicalSize = pictureInfo.size;

    final double targetWidth = width * devicePixelRatio;
    final double scale = targetWidth / logicalSize.width;
    final double targetHeight = logicalSize.height * scale;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..scale(scale)
      ..drawPicture(pictureInfo.picture);
    final ui.Picture scaledPicture = recorder.endRecording();

    final ui.Image image = await scaledPicture.toImage(
      targetWidth.round(),
      targetHeight.round(),
    );
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Only the per-size scratch is disposed. [pictureInfo.picture] is the shared
    // parsed vector and stays alive for the app lifetime.
    scaledPicture.dispose();
    image.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: width,
      height: targetHeight / devicePixelRatio,
    );
  }
}
