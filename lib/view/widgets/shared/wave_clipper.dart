import 'package:flutter/material.dart';

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 40);

    path.quadraticBezierTo(
      size.width * 0.125,
      0,
      size.width * 0.25,
      40,
    );

    path.quadraticBezierTo(
      size.width * 0.375,
      80,
      size.width * 0.5,
      40,
    );

    path.quadraticBezierTo(
      size.width * 0.625,
      0,
      size.width * 0.75,
      40,
    );

    path.quadraticBezierTo(
      size.width * 0.875,
      80,
      size.width,
      40,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}