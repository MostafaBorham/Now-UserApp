import 'package:flutter/material.dart';

/// Clips the top edge into a series of repeating waves (default 4), like the
/// scalloped band in the store header. Each wave is a full crest-and-trough
/// cycle drawn with cubic Béziers, with optional rounded bottom corners.
class TopWaveClipper extends CustomClipper<Path> {
  const TopWaveClipper({
    this.waveCount = 4,
    this.waveHeight = 22,
    this.cornerRadius = 0,
  });

  /// Number of full wave cycles across the width.
  final int waveCount;

  /// Vertical amplitude of the waves measured from the top edge.
  final double waveHeight;

  /// Radius of the two bottom corners.
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double waveWidth = width / waveCount;

    final path = Path();

    // Start at the top-left, at the mid-line of the wave band.
    path.moveTo(0, waveHeight);

    // Draw each wave as a crest (up) followed by a trough (down),
    // so every full cycle spans one waveWidth.
    for (int i = 0; i < waveCount; i++) {
      final double startX = waveWidth * i;

      // Crest: rise to the top over the first half of the wave.
      path.cubicTo(
        startX + waveWidth * 0.25,
        0,
        startX + waveWidth * 0.25,
        0,
        startX + waveWidth * 0.5,
        waveHeight,
      );

      // Trough: dip below the mid-line over the second half.
      path.cubicTo(
        startX + waveWidth * 0.75,
        waveHeight * 2,
        startX + waveWidth * 0.75,
        waveHeight * 2,
        startX + waveWidth,
        waveHeight,
      );
    }

    // Right Side
    path.lineTo(width, height - cornerRadius);

    // Bottom Right
    if (cornerRadius > 0) {
      path.quadraticBezierTo(width, height, width - cornerRadius, height);
    } else {
      path.lineTo(width, height);
    }

    // Bottom Edge
    path.lineTo(cornerRadius, height);

    // Bottom Left
    if (cornerRadius > 0) {
      path.quadraticBezierTo(0, height, 0, height - cornerRadius);
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TopWaveClipper oldClipper) =>
      oldClipper.waveCount != waveCount ||
      oldClipper.waveHeight != waveHeight ||
      oldClipper.cornerRadius != cornerRadius;
}
