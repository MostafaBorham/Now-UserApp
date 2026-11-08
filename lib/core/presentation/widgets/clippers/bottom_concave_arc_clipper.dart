import 'package:flutter/material.dart';

class BottomConcaveArcClipper extends CustomClipper<Path> {
  const BottomConcaveArcClipper();

  static const double _designWidth = 390;
  static const double _designArcDepth = 22.97;

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double scale = width / _designWidth;
    final double arcTop = height - _designArcDepth * scale;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height)
      ..cubicTo(width, height, 271.56 * scale, arcTop, width / 2, arcTop)
      ..cubicTo(118.44 * scale, arcTop, 0, height, 0, height)
      ..close();
  }

  @override
  bool shouldReclip(covariant BottomConcaveArcClipper oldClipper) => false;
}
