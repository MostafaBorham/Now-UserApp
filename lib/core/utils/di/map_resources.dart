import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class MapResources {
  String? _mapStyle;
  PictureInfo? _markerPicture;

  final Map<int, Future<BitmapDescriptor>> _markerIcons =
      <int, Future<BitmapDescriptor>>{};

  Future<void> preload() async {
    _mapStyle = await rootBundle.loadString(Assets.json.map);
    _markerPicture = await vg.loadPicture(
      SvgAssetLoader(Assets.media.images.svg.mapMarkerIcon.path),
      null,
    );
  }

  String get mapStyle => _mapStyle!;

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

    scaledPicture.dispose();
    image.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: width,
      height: targetHeight / devicePixelRatio,
    );
  }
}
