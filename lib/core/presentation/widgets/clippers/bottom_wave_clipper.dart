import 'package:flutter/material.dart';

class BottomWaveClipper extends CustomClipper<Path> {
  const BottomWaveClipper({
    this.textDirection = TextDirection.rtl,
    this.flatten = kAlwaysDismissedAnimation,
  }) : super(reclip: flatten);

  final TextDirection textDirection;
  final Animation<double> flatten;

  static const double _designWidth = 390;

  @override
  Path getClip(Size size) {
    final double s = size.width / _designWidth;
    final double width = size.width;
    final double height = size.height;

    final Path belowWave = Path()
      ..moveTo(0, 163.50 * s)
      ..cubicTo(
        -0.12 * s,
        155.73 * s,
        16.80 * s,
        141.23 * s,
        22.44 * s,
        136.30 * s,
      )
      ..cubicTo(
        30.95 * s,
        128.88 * s,
        40.62 * s,
        122.67 * s,
        50.95 * s,
        117.86 * s,
      )
      ..cubicTo(
        52.20 * s,
        117.13 * s,
        53.45 * s,
        116.42 * s,
        54.71 * s,
        115.73 * s,
      )
      ..cubicTo(
        84.44 * s,
        99.54 * s,
        117.82 * s,
        95.35 * s,
        148.33 * s,
        99.57 * s,
      )
      ..cubicTo(
        168.07 * s,
        102.30 * s,
        184.53 * s,
        110.05 * s,
        201.76 * s,
        117.88 * s,
      )
      ..cubicTo(
        227.26 * s,
        129.46 * s,
        252.24 * s,
        144.14 * s,
        281.25 * s,
        148.69 * s,
      )
      ..cubicTo(
        308.40 * s,
        152.94 * s,
        338.10 * s,
        149.28 * s,
        365.13 * s,
        136.18 * s,
      )
      ..cubicTo(
        390.24 * s,
        124.01 * s,
        420.98 * s,
        98.72 * s,
        423.46 * s,
        71 * s,
      )
      ..lineTo(423.46 * s, height)
      ..lineTo(0, height)
      ..close();

    final double flattenValue = flatten.value;
    if (flattenValue >= 1) return Path()..addRect(Offset.zero & size);

    final Path path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      belowWave.transform(
        (Matrix4.identity()
              ..translateByDouble(0.0, height, 0.0, 1.0)
              ..scaleByDouble(1.0, 1 - flattenValue, 1.0, 1.0)
              ..translateByDouble(0.0, -height, 0.0, 1.0))
            .storage,
      ),
    );

    if (textDirection == TextDirection.ltr) {
      return path.transform(
        (Matrix4.identity()
              ..translateByDouble(width, 0.0, 0.0, 1.0)
              ..scaleByDouble(-1.0, 1.0, 1.0, 1.0))
            .storage,
      );
    }

    return path;
  }

  @override
  bool shouldReclip(covariant BottomWaveClipper oldClipper) =>
      oldClipper.textDirection != textDirection ||
      oldClipper.flatten != flatten;
}
