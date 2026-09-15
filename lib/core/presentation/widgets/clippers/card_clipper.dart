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


    path.moveTo(outerRadius, 0);
    path.quadraticBezierTo(0, 0, 0, outerRadius);


    path.lineTo(0, size.height - outerRadius);


    path.quadraticBezierTo(
      0,
      size.height,
      outerRadius,
      size.height,
    );


    path.lineTo(
      size.width - notchSize - notchRadius,
      size.height,
    );


    path.quadraticBezierTo(
      size.width - notchSize,
      size.height,
      size.width - notchSize,
      size.height - notchRadius,
    );


    path.lineTo(
      size.width - notchSize,
      size.height - notchSize + notchRadius,
    );


    path.quadraticBezierTo(
      size.width - notchSize,
      size.height - notchSize,
      size.width - notchSize + notchRadius,
      size.height - notchSize,
    );


    path.lineTo(
      size.width - notchRadius,
      size.height - notchSize,
    );


    path.quadraticBezierTo(
      size.width,
      size.height - notchSize,
      size.width,
      size.height - notchSize - notchRadius,
    );


    path.lineTo(size.width, outerRadius);


    path.quadraticBezierTo(
      size.width,
      0,
      size.width - outerRadius,
      0,
    );

    path.close();


    if (textDirection == TextDirection.rtl) {
      return path.transform(
        (Matrix4.identity()
              ..translateByDouble(size.width, 0.0, 0.0, 1.0)
              ..scaleByDouble(-1.0, 1.0, 1.0, 1.0))
            .storage,
      );
    }

    return path;
  }

  @override
  bool shouldReclip(BreadCardClipper oldClipper) =>
      oldClipper.textDirection != textDirection;
}
