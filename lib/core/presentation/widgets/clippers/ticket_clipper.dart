import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  const TicketClipper({
    this.radius = 16,
    this.notchRadius = 17,
    this.notchFraction = 0.69,
    this.textDirection = TextDirection.ltr,
  });

  final double radius;
  final double notchRadius;

  final double notchFraction;

  final TextDirection textDirection;

  @override
  Path getClip(Size size) {
    final double fraction = textDirection == TextDirection.rtl
        ? 1 - notchFraction
        : notchFraction;
    final double dx = size.width * fraction;
    final Path base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final Path notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(dx, 0), radius: notchRadius))
      ..addOval(
        Rect.fromCircle(center: Offset(dx, size.height), radius: notchRadius),
      );
    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchFraction != notchFraction ||
      oldClipper.textDirection != textDirection;
}
