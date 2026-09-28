import 'package:flutter/material.dart';

/// A deeper, more saturated, fully opaque version of [color], dark enough to
/// read as text over a light surface tinted with it (a featured store's own
/// `store_color` on its frosted panel). Greys stay grey: a colour with no
/// saturation is only darkened.
Color sharpenColor(
  Color color, {
  double saturationBoost = 0.25,
  double maxLightness = 0.35,
}) {
  final HSLColor hsl = HSLColor.fromColor(color);
  final double saturation = hsl.saturation == 0
      ? 0
      : (hsl.saturation + saturationBoost).clamp(0.0, 1.0);
  return hsl
      .withAlpha(1)
      .withSaturation(saturation)
      .withLightness(hsl.lightness.clamp(0.0, maxLightness))
      .toColor();
}
