import 'package:flutter/material.dart';

/// Clips a rounded rectangle with a semicircular notch punched out of the
/// centre of its top and bottom edges, at [notchFraction] of the width — the
/// classic tear-off ticket silhouette.
///
/// The defaults are the coupon-card geometry, so a card and its loading
/// placeholder can share one source of the ticket shape.
///
/// [notchFraction] is measured from the *start* edge, so the perforation tracks
/// the card content across text directions: pass [textDirection] and the notch
/// is mirrored to the right edge in RTL. Without it the fraction is taken from
/// the left edge (LTR).
class TicketClipper extends CustomClipper<Path> {
  const TicketClipper({
    this.radius = 16,
    this.notchRadius = 17,
    this.notchFraction = 0.69,
    this.textDirection = TextDirection.ltr,
  });

  final double radius;
  final double notchRadius;

  /// Position of the perforation from the start edge, as a fraction of width.
  final double notchFraction;

  /// Reading direction; mirrors the notch to the right edge when [TextDirection.rtl].
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
