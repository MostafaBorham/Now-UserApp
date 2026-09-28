import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Recolours a single-colour SVG icon while it is parsed: pass it as the
/// generated `svg()`'s `colorMapper` where one would pass
/// `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)`.
///
/// Same look, without the cost: with a colour filter, flutter_svg draws the
/// icon through a `saveLayer` — an offscreen pass on every frame it is
/// painted — and Home's cards paint dozens. It compares by value because
/// flutter_svg keys its parse cache on the mapper: each icon is parsed once per
/// colour, not once per build.
///
/// Only for icons drawn in one opaque colour. Every colour the SVG names turns
/// into [color], masks included, so a luminance mask or a two-tone icon would
/// not survive it.
class SvgTint extends ColorMapper {
  const SvgTint(this.color);

  final Color color;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color original,
  ) => color.withValues(alpha: color.a * original.a);

  @override
  bool operator ==(Object other) => other is SvgTint && other.color == color;

  @override
  int get hashCode => color.hashCode;
}
