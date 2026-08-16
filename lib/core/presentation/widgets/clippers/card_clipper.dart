import 'package:flutter/material.dart';

class BreadCardClipper extends CustomClipper<Path> {
  const BreadCardClipper({this.textDirection = TextDirection.ltr});

  final TextDirection textDirection;

  @override
  Path getClip(Size size) {
    const double outerRadius = 8;
    const double notchSize = 36;
    const double notchRadius = 12;

    final path = Path();

    // Top Left
    path.moveTo(outerRadius, 0);
    path.quadraticBezierTo(0, 0, 0, outerRadius);

    // Left Side
    path.lineTo(0, size.height - outerRadius);

    // Bottom Left
    path.quadraticBezierTo(
      0,
      size.height,
      outerRadius,
      size.height,
    );

    // Bottom Edge until notch
    path.lineTo(
      size.width - notchSize - notchRadius,
      size.height,
    );

    // Curve 1 (bottom edge -> notch left side)
    path.quadraticBezierTo(
      size.width - notchSize,
      size.height,
      size.width - notchSize,
      size.height - notchRadius,
    );

    // Notch Left Side
    path.lineTo(
      size.width - notchSize,
      size.height - notchSize + notchRadius,
    );

    // Curve 2 (notch left side -> notch top)
    path.quadraticBezierTo(
      size.width - notchSize,
      size.height - notchSize,
      size.width - notchSize + notchRadius,
      size.height - notchSize,
    );

    // Notch Top
    path.lineTo(
      size.width - notchRadius,
      size.height - notchSize,
    );

    // Curve 3 (notch top -> right edge)
    path.quadraticBezierTo(
      size.width,
      size.height - notchSize,
      size.width,
      size.height - notchSize - notchRadius,
    );

    // Right Side
    path.lineTo(size.width, outerRadius);

    // Top Right
    path.quadraticBezierTo(
      size.width,
      0,
      size.width - outerRadius,
      0,
    );

    path.close();

    // Mirror the notch to the opposite corner for RTL layouts.
    if (textDirection == TextDirection.rtl) {
      return path.transform(
        (Matrix4.identity()
              ..translate(size.width, 0.0)
              ..scale(-1.0, 1.0))
            .storage,
      );
    }

    return path;
  }

  @override
  bool shouldReclip(BreadCardClipper oldClipper) =>
      oldClipper.textDirection != textDirection;
}