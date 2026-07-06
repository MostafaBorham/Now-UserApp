import 'package:flutter/material.dart';

/// Clips the top edge into the hand-drawn scalloped wave from the store header
/// design. The wave path is baked from the Figma component (Shape Builder
/// export) and scaled uniformly to the target width; the region then fills
/// straight down to the bottom of the widget.
///
/// The path is authored against a [_designWidth]-wide artboard, with the
/// original `translate(3.96, -2.54)` already folded into every coordinate so
/// the shape spans `x ∈ [0, _designWidth]`.
class TopWaveClipper extends CustomClipper<Path> {
  const TopWaveClipper();

  /// Artboard width the wave coordinates were authored against.
  static const double _designWidth = 402.29;

  @override
  Path getClip(Size size) {
    final double s = size.width / _designWidth;
    final double width = size.width;
    final double height = size.height;

    final path = Path();

    // Top-left start of the wave (a crest), then trace the wavy top edge
    // left → right with the exact cubics from the design.
    path.moveTo(0, 40 * s);
    path.cubicTo(10.0 * s, -20.0 * s, 49.92 * s, 22.11 * s, 63.85 * s, 24.15 * s);
    path.cubicTo(74.85 * s, 25.76 * s, 85.89 * s, 22.09 * s, 96.33 * s, 18.28 * s);
    path.cubicTo(107.23 * s, 14.30 * s, 118.31 * s, 9.91 * s, 129.70 * s, 10.33 * s);
    path.cubicTo(141.99 * s, 10.78 * s, 153.59 * s, 16.78 * s, 165.29 * s, 21.35 * s);
    path.cubicTo(176.99 * s, 25.92 * s, 189.90 * s, 29.05 * s, 201.41 * s, 23.83 * s);
    path.cubicTo(209.47 * s, 20.18 * s, 215.87 * s, 13.36 * s, 224.38 * s, 10.43 * s);
    path.cubicTo(233.64 * s, 7.25 * s, 243.58 * s, 6.78 * s, 252.99 * s, 9.32 * s);
    path.cubicTo(272.90 * s, 14.70 * s, 290.70 * s, 32.71 * s, 311.03 * s, 30.60 * s);
    path.cubicTo(328.61 * s, 28.77 * s, 342.05 * s, 12.95 * s, 358.18 * s, 6.10 * s);
    path.cubicTo(372.52 * s, 0.00 * s, 393.22 * s, 11.64 * s, width, 25 * s);

    // Extend straight to the right edge, then fill the body down to the bottom.
    path.lineTo(width, 29.54 * s);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.lineTo(0, 13.69 * s);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TopWaveClipper oldClipper) => false;
}
