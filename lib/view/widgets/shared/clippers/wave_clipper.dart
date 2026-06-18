import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);

    path.lineTo(0, size.height - 14);

    // القمة الأولى
    path.cubicTo(
      size.width * 0.03,
      size.height + 2,
      size.width * 0.07,
      size.height + 2,
      size.width * 0.10,
      size.height - 14,
    );

    // القاع الأول
    path.cubicTo(
      size.width * 0.15,
      size.height - 32,
      size.width * 0.20,
      size.height - 32,
      size.width * 0.30,
      size.height - 14,
    );

    // القمة الثانية
    path.cubicTo(
      size.width * 0.36,
      size.height + 2,
      size.width * 0.42,
      size.height + 2,
      size.width * 0.50,
      size.height - 14,
    );

    // القاع الثاني
    path.cubicTo(
      size.width * 0.58,
      size.height - 32,
      size.width * 0.64,
      size.height - 32,
      size.width * 0.73,
      size.height - 14,
    );

    // القمة الثالثة
    path.cubicTo(
      size.width * 0.79,
      size.height + 2,
      size.width * 0.85,
      size.height + 2,
      size.width * 0.92,
      size.height - 14,
    );

    // النهاية اليمنى
    path.cubicTo(
      size.width * 0.96,
      size.height - 20,
      size.width * 0.99,
      size.height - 20,
      size.width,
      size.height - 10,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}