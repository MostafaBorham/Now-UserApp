import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 15);

    // Wave 1
    path.quadraticBezierTo(
      size.width * 0.06,
      -8,
      size.width * 0.125,
      10,
    );

    // Wave 2
    path.quadraticBezierTo(
      size.width * 0.19,
      28,
      size.width * 0.25,
      10,
    );

    // Wave 3
    path.quadraticBezierTo(
      size.width * 0.31,
      -8,
      size.width * 0.375,
      10,
    );

    // Wave 4
    path.quadraticBezierTo(
      size.width * 0.44,
      28,
      size.width * 0.50,
      10,
    );

    // Wave 5
    path.quadraticBezierTo(
      size.width * 0.56,
      -8,
      size.width * 0.625,
      10,
    );

    // Wave 6
    path.quadraticBezierTo(
      size.width * 0.69,
      28,
      size.width * 0.75,
      10,
    );

    // Wave 7
    path.quadraticBezierTo(
      size.width * 0.81,
      -8,
      size.width * 0.875,
      10,
    );

    // Wave 8
    path.quadraticBezierTo(
      size.width * 0.94,
      28,
      size.width,
      10,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}